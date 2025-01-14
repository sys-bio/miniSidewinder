unit uODE_FormatUtility;

// Takes a list of SBML reactions and Lists of Species and parameters and returns
// An array of equation strings with the names replaced with simple array names.
// array lists is in same order ans size as lists of species and parameters that were passed in.
// Convert basic math functions to javascript notation (ie pow() -> Math.pow() )
// * Only support species rate rule for now.

interface
uses System.SysUtils, System.StrUtils, System.Types, web, uSBMLClasses, uModel,
uSBMLClasses.rule, System.Generics.Collections, uSidewinderTypes;

const ODESTART = 'dydt_s[';  // Used for building up ODE eqs.
      LSODA_ODESTART = 'dydt_s.setVal('; // use this with lsoda integrator

type
TFormatODEs = class
  private

  var odeEqs: array of String; // list of ODE eqs using std notation
    odeEqs2: array of String; // LSODA list of eqs.
    odeEqSet:String;  // Contains all eqs as one String
    odeEqSet2:String; // LSODA specific
    assignParamEqs: array of String; // List of SBML param assignment formulas, to be added to final odeEqSet.
    assignSpeciesEqs: array of String; // List of SBML spec assignment formulas, to be added to final odeEqSet
    initialAssignParamEqs: TList<string>; // Only used at t=0
    initialAssignSpeciesEqs: TList<string>;//  "          "
    rxns: array of SBMLreaction;
    prods: array of TSBMLSpeciesReference; // TODO: move to buildODE_LHS()
    reactants: array of TSBMLSpeciesReference; // TODO: move to buildODE_LHS()
    speciesStrAr: array of String;   // keep to convert short name to long name.
    speciesAr: array of TSBMLSpecies;
    paramsStrAr: array of String;    // keep to convert short name to long name.
    sVals: array of double;   // init val of species, same size as speciesStrAr
    pVals: array of double;   // init val of parameters, same size as paramsStrAr.
    //compartments: TList<String>;  // NOT needed ??

  function  buildODE_LHS( rxn: SBMLreaction ): array of String; // build the 'dydt_s[]=' or '-dydt_s[]=', store in rhsSymbols
  function  getODEeqLoc(Speciesdydt : String): Integer; // return index of Species in odeEqs.
  procedure BuildAssignmentEqs(model: TModel);
  procedure Buildeqs(model: TModel); // Build Assignment, rate rules and reaction ->kinetic Law equations for each species.
  function  replaceVarStrWithIndex( lhsSymbol: String; spStrAr: array of String ): String;
  function replaceSymbolsInRxnEq(newODE: String; newRxnComp: String; lhsSymbols: array of String; count: Integer ): Integer;
  procedure buildInitialAssignEqs(model: TModel); // generate init Assignment eqs (valid only at t=0).
  function spBoundaryCondition(speciesId: String): boolean;

 public
  constructor create( model: TModel );
  function  replaceStrNames(names: array of String; stringtoedit: String; prefixStr: String):String;
  function  StrInArray(const Value : String; const ArrayOfString : Array of String) : Integer;
  function  testStrReplace( ): String;  // testing....
  function  getODEs(): array of String;
  function  getODEs2(): array of String; // LSODA eqs
  function  getODEeqSet(): String;
  function  getODEeqSet2(): String; // LSODA eq set.
  function  get_sVals(): array of double; // get init vals for species used in eqs.
  function  get_pVals(): array of double; // get init vals for params, including comp vols used in eqs.
  function  get_speciesStrAr(): array of String;  // SBML Species id
  function  get_paramsStrAr(): array of String;   // SBML parameter and compartment ids.
  procedure buildLSODAeqs();   // build LSODA eqs (odeEqs2)

  procedure buildFinalEqSet(); // Build up final ODE eqs list as one string for use by solver.
  function getInitialAssignParamEqs(): TList<string>;
  function getInitialAssignSpeciesEqs: TList<string>;
  function getAssignRuleParamEqs: array of string;
  function getAssignRuleSpeciesEqs: array of string;
end;
// Currently no support for user defined functions in kinetic law formula.

function JSMathConvert(eqStr: String): String;

implementation

constructor TFormatODEs.create (model: TModel);
var i, j,k: Integer;
begin
  self.assignParamEqs := nil;
  self.assignSpeciesEqs := nil;
  self.initialAssignParamEqs := TList<string>.Create;
  self.initialAssignSpeciesEqs := TList<string>.Create;
  setLength(self.speciesAr,Length(model.getSBMLspeciesAr()));
  self.speciesAr := model.getSBMLspeciesAr();
  setLength(paramsStrAr, Length(model.getSBMLparameterAr()));
  self.speciesStrAr := model.getS_Names;
  self.sVals := model.getS_Vals;
  self.paramsStrAr := model.getP_Names;
  self.pVals := model.getP_Vals;

  self.BuildAssignmentEqs(model);
  self.buildInitialAssignEqs(model);
  //self.compartments := TList<String>.create;
  // *******************************************************************
  // put Assignment rules, rate rules, reaction.kinetic laws into a list of eqs to be solved by integrator (LSODA):
  self.Buildeqs(model);

end;

procedure TFormatODEs.BuildEqs(model: TModel); // Build rate rules and reaction ->kinetic Law equations for each species.
var i, j,k,  count: Integer;
    curODE ,odeStr, templhsStr, tempSp: String;
    lhsSymbols: array of String; // contains the 'dydt_s[]=' argument.
    splitStrAr: TStringDynArray;
    rxnComp: string;  // compartment id that rxn is in
begin
  count := 0;
  lhsSymbols := nil;
 // go through each rate rule and reaction eq and replace all species and params in arrays:
 // Rate rules:
  for j := 0 to Length(model.getSBMLmodelRules) -1 do
    begin
    curODE := '';
    templhsStr := '';
    if model.getSBMLRule(j).isRate then  // CHeck if rate rule.
      begin
      if model.getSBMLRule(j).isSetFormula then
        begin                            // Only support species rate rules.
        if model.getSBMLRule(j).isSpeciesConcentration or model.getSBMLRule(j).isSpeciesReference then
          begin
          SetLength(lhsSymbols, length(lhsSymbols) +1);
          curODE := model.getSBMLRule(j).getFormula;
          curODE := model.convertFuncDefToKineticLaw(curODE); // Get any Func Def that rate rule uses, and substiute
          lhsSymbols[length(lhsSymbols)-1] := ODESTART + model.getSBMLRule(j).getVariable + ']= ';
          curODE := '(' + curODE + ')';
          odeStr := replaceStrNames(self.speciesStrAr, curODE,'s');// Replace names in string with array names ('species1' -> 's[0]')
          odeStr := replaceStrNames(self.paramsStrAr, odeStr,'p');

          templhsStr := replaceVarStrWithIndex( lhsSymbols[length(lhsSymbols)-1], self.speciesStrAr );
          console.log('LHS: ', templhsStr);
          odeStr := templhsStr + odeStr; // equate lhs with odeStr
          count := length(lhsSymbols);
          setLength (self.odeEqs,length(lhsSymbols));
          self.odeEqs[length(lhsSymbols)-1] := odeStr;
          end;
        end;
      end;
    end;

 // Get reactions:
  self.rxns:= Copy(model.getReactions(), 0, model.getNumReactions());
  for j := 0 to Length(rxns)-1 do
    begin
    rxnComp := '';
    if rxns[j].isSetKineticLaw() then
       begin
       lhsSymbols := buildODE_LHS(rxns[j]);  // check if existing LHS, then just // add eq to it.
       curODE := rxns[j].getKineticLaw().getFormula();
       curODE := model.convertFuncDefToKineticLaw(curODE); // Get any Func Def that kin law uses, and substiute
       end;
    if rxns[j].isSetCompartment then
      begin
      rxnComp := rxns[j].getCompartment;
    //  if not self.compartments.Contains(rxnComp) then
    //    self.compartments.Add(rxnComp);
      end;
    setLength (self.odeEqs,length(lhsSymbols) + count);
  // Make a Common function call:
    count := self.replaceSymbolsInRxnEq(curODE, rxnComp, lhsSymbols, count);

    end;
  // *********************************************************************************
  // Now replace math operators in all equations, including assignment rules:
  for i := 0 to Length(odeEqs)-1 do
      begin
      self.odeEqs[i] := JSMathConvert(odeEqs[i]);
      end;
  buildLSODAeqs();

end;

   // spStrAr: array of variable names, return array index of posiiton where name found in lhsSymbol.
 function TFormatODEs.replaceVarStrWithIndex( lhsSymbol: String; spStrAr: array of String ): String;
 var i: integer;
    newLHS: String;
    tempSp: String;
    found: boolean;
 begin
   Result := '';
   newLHS := '';
   found := false;
   for i := 0 to length(spStrAr) -1 do
            begin
            if not found then
              begin
              if lhsSymbol.Contains(spStrAr[i]) then
                begin
                tempSp := intToStr(i);
                newLHS := StringReplace(lhsSymbol, spStrAr[i], tempSp,[] );
                console.log('LHS: ', newLHS);
                found := true;
                end;
              end;
            end;
   Result := newLHS;
 end;



// Find all Species in Rxns and insert rate law eqs based on whether product or reactant.
// Ex: S1 -> S2; (10 * S1 - 2 * S2) / (1 + S1 + S2);
// dS1/dt = - (10 * S1 - 2 * S2) / (1 + S1 + S2)
// dS2/dt =  (10 * S1 - 2 * S2) / (1 + S1 + S2);
function TFormatODEs.replaceSymbolsInRxnEq(newODE: String; newRxnComp: String; lhsSymbols: array of String; count: Integer ): Integer;
var k: Integer;
    odeStr: String;
    found_dydt: Integer;
    splitStrAr: TStringDynArray;
begin
  odeStr := '';
  // For equations using species concentrations then need compartment in denomenator:
  //  ds/st = 1/Comp * (curODE);
  if newRxnComp <> '' then
     newODE := '(1/' + newRxnComp + ') *(' + newODE + ')';
  // console.log(' TFormatODEs.create: ', curODE);
  odeStr := replaceStrNames(self.speciesStrAr, newODE,'s');// Replace names in string with array names ('species1' -> 's[0]')
  odeStr := replaceStrNames(self.paramsStrAr, odeStr,'p');
  // setLength (odeEqs,length(lhsSymbols) + count);
      found_dydt := -1; // not found
      for k := 0 to length(lhsSymbols)-1 do
          begin
          found_dydt :=  self.getODEeqLoc(lhsSymbols[k] );
         // console.log(' found_dydt: ', found_dydt);
          if found_dydt < 0 then // not found
             begin
             if lhsSymbols[k] = '' then
                self.odeEqs[count] := ''   // Do not add ODE eq for this species
             else
                self.odeEqs[count] := lhsSymbols[k] + odeStr + ')';  // rhs inclosed in perenthesis.
             count := count + 1;  // count: Total number of eqs: Sum(prod+reactants per rxn)
             end
          else
          begin
          splitStrAr := SplitString(lhsSymbols[k],'='); // grab the stoich coeff
          if ContainsText(lhsSymbols[k],'(-1)*') then  // still need to put in stoich coeff
            begin
           // splitStrAr := SplitString(lhsSymbols[k],'=' ); // grab the stoich coeff
            if Length(splitStrAr) > 1 then
              begin
            //  console.log('-1 on lhs: ', splitStrAr[1]);
               self.odeEqs[found_dydt] := self.odeEqs[found_dydt] + '+ ' + splitStrAr[1]+ odeStr + ')' ;
              end;

            end
          else
            begin
            //splitStrAr := nil;
            //splitStrAr := SplitString(lhsSymbols[k],'='); // grab the stoich coeff
            if Length(splitStrAr) > 1 then
              self.odeEqs[found_dydt] := self.odeEqs[found_dydt] + '+ ' + splitStrAr[1] + odeStr + ')';
            end;
         // console.log('current odeEqs: ', self.odeEqs[found_dydt]);
          end;
        end;
  Result := count;
end;


// Replace names in string with array names ('species1' -> 's[0]')
 function TFormatODEs.replaceStrNames(names: array of String; stringtoedit: String; prefixStr: String):String;
 var tmpStoE,tmpCatStr, currEqStr: String; // temp holder for string
 var i,j,k: integer;
 var beginC, endC: String;
 const eqdelims: array of String = [' ', '(', ')', '+', '-', '*', '/', ','];

 begin
   currEqStr:= Copy(stringtoedit,1,MaxInt);  // use instead of stringtoedit
   tmpStoE:= '';
   tmpCatStr:= '';
   for i := 0 to Length(names)-1 do
     begin
       tmpStoE:= '';
       tmpCatStr:= '';
       j:=1; // Position to check in string where name may be.    was 0.
       while j < length(currEqStr) do // TODO: Chk if names[i]=''
         begin
           k:= 0; // position in string where name found.
           beginC:= ''; endC:= '';
           k:= PosEx(names[i],currEqStr,j);  // returns 1 if name found at currEqStr[0]
           if ( k>0) then    // found name
             begin
     //         console.log('Found match: ',names[i]);  // Found at correct position, k
               if k =1 then beginC:= ' ' // First char of formula string is in names[i]
               else beginC:= Copy(currEqStr,(k-1),1);
               endC:= Copy(currEqStr,(k+length(names[i])),1);
               if StrInArray(beginC,eqdelims) > -1  then
                 begin
                   tmpCatStr:= Copy(currEqStr,j,(k-j));
                   if (StrInArray(endC,eqdelims) > -1) or (endC= '') then   // end of string chk
                   begin
      //                console.log('A second delimeter found! j:',j,', k: ',k);
                   // Put new eq str together. Append prefix[i] to it.
                     tmpStoE:= tmpStoE + tmpCatStr + PrefixStr+ '['+inttostr(i)+']';
                   end
                   else
                   begin
                    // leave str alone:
                     tmpStoE:= tmpStoE + tmpCatStr + names[i];
                  //   console.log('No match, string: ',tmpStoE);
                   end;

                end
                else
                begin
                  tmpCatStr:= Copy(currEqStr,j,(k-j));
                  tmpStoE:= tmpStoE + tmpCatStr + names[i];
      //                console.log('No match a part of another name, string: ',tmpStoE);
                end;    // end new
                if (length(names[i])<1) then j:= j+1
                else
                   begin
                     j:= k+ length(names[i]);
                     if j=length(currEqStr) then tmpStoE:= tmpStoE + endC; // added

                   end;
              end
              else
              begin
                tmpCatStr:= Copy(currEqStr,j,(Length(currEqStr)-(j-1)));
                tmpStoE:= tmpStoE + tmpCatStr;
                j:= length(currEqStr);  // name Not found.
              end;
         end;
             // Now copy tmpStoE to stringtoedit and start over for next name.
         currEqStr:= Copy(tmpStoE,1,Length(tmpStoE));
         //console.log('.. Current value currEqStr: ', currEqStr);
     end;
     Result:= currEqStr;
 end;

// ****************************************************************
 function TFormatODEs.StrInArray(const Value : String; const ArrayOfString : Array of String) : Integer;
var
 Loop : String;
 i: Integer;
begin
  i:= -1; // Not found
  for Loop in ArrayOfString do
  begin
  i:=i+1;
  //console.log('Loop= ',Loop,', Value: ',Value);
    if Value = Loop then
    begin

       Exit(i);
    end;
  end;
  result := -1;
end;

// ********************************************************
function TFormatODEs.testStrReplace( ): String;
var testEq, spList, parList: array of String;
    finalEq: String;
    i: integer;
begin
  SetLength(testEq,2);
  testEq[0]:= 'store * (Vm3 * pow(Y, m) * pow(Z, p) / ((pow(Kr, m) + pow(Y, m)) * (pow(Ka, p) + pow(Z, p))))';
  testEq[1]:= 'v1 * ((1 -m) / m * Z - Y)';
  spList:= ['Z', 'Y'];
  parList:= ['v1','Vm3','m', 'n', 'Kr','Ka','p'];
  for i := 0 to Length(testEq)-1 do
    begin
    //console.log('TEST - Init Eq: ', testEq[i]);
    finalEq:= replaceStrNames(spList, testEq[i],'s');
    finalEq:= replaceStrNames(parList, finalEq,'p');
    //console.log('TEST -> Final Eq: ', finalEq);
    end;
end;

// **********************************************
function TFormatODEs.getODEs(): array of String;
begin
  result:= self.odeEqs;
end;

function TFormatODEs.getODEs2(): array of String;
begin
  Result:= self.odeEqs2;
end;

// **********************************************
function TFormatODEs.getODEeqSet(): String;
begin
  Result:= self.odeEqSet;
end;

// **********************************************
function TFormatODEs.getODEeqSet2(): String;
begin
  Result:= self.odeEqSet2;
end;

// **********************************************
// get init vals for species used in eqs.
function TFormatODEs.get_sVals(): array of double;
begin
  result:= sVals;
end;

// **********************************************
// get init vals for params, including comp vols used in eqs.
function TFormatODEs.get_pVals(): array of double;
begin
  result:= pVals;
end;

// *************************************************
function TFormatODEs.get_speciesStrAr(): array of String;
begin
  result:= self.speciesStrAr;
end;

// **************************************************
function TFormatODEs.get_paramsStrAr(): array of String;
begin
  result:= self.paramsStrAr;
end;

// ***********************************************
// build the 'dydt_s[]=' or 'dydt_s[]= (-1)*', store in lhsSymbols[]
// TODO: Put in Stoich coeffs.
function TFormatODEs.buildODE_LHS(rxn: SBMLreaction):array of String;
var i, nr, np: Integer;
    stoich: double;
    tmpSpId: String;
    lhs: array of String;
 // TODO move self.products and self.reactants to here
begin
  nr:= rxn.getNumReactants();
  np:= rxn.getNumProducts();
  // check previous reaction strings and see if LHS for species already exists.
  // If so, then flag it.
  // When checking if product or reactant just add eq to previous one.
  SetLength(lhs,nr+np);
  if np>0 then
  begin
    self.prods:= rxn.getRxnProducts();
    if length(self.prods)>0 then
      begin
        for i := 0 to np-1 do
        begin
          stoich := 1.0;  // default
          if self.prods[i].isSetSpecies() then
          begin
            tmpSpId:= self.prods[i].getSpecies();
            if self.spBoundaryCondition(tmpSpId) = false then  // <-- need actual species in array of species.
            begin
              if self.prods[i].isSetStoichiometry then stoich := self.prods[i].getStoichiometry;
                lhs[i]:= ODESTART + IntToStr(strInArray(self.prods[i].getSpecies(),speciesStrAr))+']'+'= (1)*('+stoich.ToString+')* ('; // dydt_name
            end
            else lhs[i]:= '';  // No ODE for boundary condition.
          //  console.log('... Products lhs: ', lhs[np+i]);
          end;
        end;
      end;
  end;

  if nr>0 then
  begin
    self.reactants:= rxn.getRxnReactants();
    // Works with only one product/reactant, need to generalize for many products.DONE ??
    // Need one ODE one for Reactant (-);
  if length(self.reactants)>0 then
     begin
      for i := 0 to nr-1 do
      begin
        tmpSpId:= '';
        stoich := 1;  // default
        if self.reactants[i].isSetSpecies() then
        begin
          tmpSpId:= self.reactants[i].getSpecies;
          if self.spBoundaryCondition(tmpSpId) = false then    // <-- need actual species in array of species.
          begin
          //console.log('Boundary condition not set');
            if self.reactants[i].isSetStoichiometry then stoich := self.reactants[i].getStoichiometry;
              lhs[np+i]:= ODESTART + IntToStr(strInArray(reactants[i].getSpecies(),speciesStrAr))+']'+'= (-1)*('+stoich.ToString+')* (' ;   // dydt_name
          end
          else
          begin
           // console.log('Boundary condition SET!!!');
            lhs[np+i]:= '';
          end;
         // console.log('. Reactants lhs: ', lhs[np+i]);
        end;
      end;
     end;
   end;
  Result:= lhs;
end;
    // Speciesdydt: dydt_s[n]
function TFormatODEs.getODEeqLoc(Speciesdydt : String): Integer; // return index of Species in odeEqs.
var i,found: Integer;
  spStr, b_str: String;

begin
  spStr:= '';
  b_str:= '';
  found:= -1;
  for i := 0 to Length(self.speciesStrAr) -1 do
    begin
      b_str:= '['+IntToStr(i)+']';
      if ContainsText(Speciesdydt,b_str) then
      begin
        spStr:= ODESTART + IntToStr(i)+ ']'; // 'dydt_s[i]'
   //     console.log('Found Speciesdydt: ', Speciesdydt, ', spStr: ', spStr);
      end;

    end;
  for i := 0 to Length(Self.odeEqs)-1 do
  begin
    if Not (spStr = '') then
    begin
      if ContainsText(odeEqs[i], spStr) then
      begin
        found:= i;
      end;
    end;


  end;

  Result:= found;

end;

 procedure TFormatODEs.buildLSODAeqs();
 var i,j:integer;
    replStr:String;
    editStr: String;
   begin
   for j := 0 to Length(self.svals)-1 do
  // for i := 0 to Length(self.odeEqs)-1 do
     begin
     for i := 0 to Length(self.odeEqs)-1 do
     //for j := 0 to Length(self.svals)-1 do
       begin
       editStr:= ODESTART +intToStr(j)+']=';
       //editStr:= 'dydt_s['+intToStr(j)+']=';
       //replStr:= 'dydt_s.setVal('+intToStr(j+1)+','; // LSODA Uses TVector which start at 1, not 0.
       replStr:= LSODA_ODESTART + intToStr(j+1)+','; // LSODA Uses TVector which start at 1, not 0.
       if ContainsText(self.odeEqs[i],editStr) then
         begin
         self.odeEqs2[i]:= StringReplace(self.odeEqs[i],editStr,replStr,[])+')';

         end;

       end;
     end;
   end;

 procedure TFormatODEs.BuildAssignmentEqs(model: TModel);
 var i : integer;
     currString: String;
     currLHS, templhsStr: string;
     rules: array of TSBMLrule;
 begin
   rules:= model.getSBMLmodelRules();
   if Length(rules) >0 then
   begin
     for i := 0 to Length(rules) - 1 do
       begin
         currString:= '';
         currLHS := '';
         if rules[i].isAssignment then
         begin

           if rules[i].isSetVariable then
           begin
           templhsStr := '';
             //currLHS := rules[i].getVariable() + '= '; // Start building assignment
             if rules[i].isSpeciesConcentration() or rules[i].isSpeciesReference then
               begin
               currLHS := 's['+ rules[i].getVariable() + ']= '; // Start building assignment
               templhsStr := self.replaceVarStrWithIndex( currLHS, self.speciesStrAr ); // replace spname with s[#]
               console.log('templhsStr: ', templhsStr);
               end
             else if rules[i].isParameter then
               begin
               currLHS := 'p[' + rules[i].getVariable() + ']= '; // Start building assignment p[#]=
               templhsStr := self.replaceVarStrWithIndex( currLHS, self.paramsStrAr );
               end;
             if rules[i].isSetFormula then
               currString:= currString + rules[i].getFormula()
             else currString:= currString + '0';
             currString:= replaceStrNames(self.speciesStrAr, currString,'s');
             currString:= replaceStrNames(self.paramsStrAr, currString,'p');
             currString := templhsStr + currString;
             currString:= JSMathConvert(currString);
           end;
           if rules[i].isParameter then
           begin
             SetLength(self.assignParamEqs, Length(self.assignParamEqs)+1);
             self.assignParamEqs[Length(assignParamEqs)-1]:= currString;
            // console.log(' param Assign eq: ',self.assignParamEqs[Length(assignParamEqs)-1]);
           end
           else if rules[i].isSpeciesConcentration or rules[i].isSpeciesReference then
                begin
                  SetLength(self.assignSpeciesEqs, Length(self.assignSpeciesEqs)+1);
                  self.assignSpeciesEqs[Length(self.assignSpeciesEqs)-1]:= currString;
                  //console.log(' Species Assign eq: ',self.assignSpeciesEqs[Length(self.assignSpeciesEqs)-1]);
                end;

         end;
       end;
   end;
 end;

 function TFormatODES.getAssignRuleParamEqs: array of string;
 begin
   Result := self.assignParamEqs;
 end;
  function TFormatODEs.getAssignRuleSpeciesEqs: array of string;
  begin
    Result := self.assignSpeciesEqs;
  end;

 procedure TFormatODEs.buildInitialAssignEqs(model: TModel);
 var i: integer;
     curEq, curSymbol: string;
 begin
   if model.getNumInitialAssignments > 0 then
     begin
     for i := 0 to model.getNumInitialAssignments -1 do
       begin
       curEq:= '';
       curSymbol := model.getInitialAssignment(i).getSymbol;
       if curSymbol <> '' then
         begin
         curEq:= model.getInitialAssignment(i).getSymbol + ' = '; // Start building assignment
         if model.getInitialAssignment(i).getFormula <> '' then
           curEq := curEq + model.getInitialAssignment(i).getFormula
         else curEq := curEq + '0';
         curEq:= replaceStrNames(self.speciesStrAr, curEq,'s');
         curEq:= replaceStrNames(self.paramsStrAr, curEq,'p');
         curEq:= JSMathConvert(curEq);
         if self.StrInArray(curSymbol, self.paramsStrAr) > -1 then
           begin
           self.initialAssignParamEqs.Add(curEq);
           //console.log('Init Assignment for: ',curSymbol,': ',curEq);
           end
         else if self.StrInArray(curSymbol, self.speciesStrAr) > -1 then
            self.initialAssignSpeciesEqs.Add(curEq);

         end;
       end;
     end;

 end;
   // Build up final ODE eqs list as one string for use by solver
 procedure TFormatODEs.buildFinalEqSet();
 var i,lsodaInt:Integer;
     leftHS: string;
     leftHS_2, tempStr: String;
     tempStrAr: TArray<String>;
     spArValStr: TArray<String>;
     spArNum: string;
     delimitAr : Array[0..1] of Char;
 begin
  self.odeEqSet:= '';
  leftHS_2 := '';
  self.odeEqSet2:= self.odeEqSet2 + 'let dydt_s = pas.uVector.TVector.$create("create$1",[s.length]); ';  // Eq set for LSODA

  // Stick parameter and species assignments in front of ODE calcs:
   if Length(self.assignParamEqs)>0 then
   begin
     for i := 0 to Length(self.assignParamEqs)-1 do
     begin
       self.odeEqSet:= self.odeEqSet + self.assignParamEqs[i] + ';' ;
       self.odeEqSet2:= self.odeEqSet2 + self.assignParamEqs[i] + ';' ;
     end;

   end;

   if Length(self.assignSpeciesEqs)>0 then
   begin
     for i := 0 to Length(self.assignSpeciesEqs)-1 do
     begin
       self.odeEqSet:= self.odeEqSet + self.assignSpeciesEqs[i] + ';' ;
       self.odeEqSet2:= self.odeEqSet2 + self.assignSpeciesEqs[i] + ';' ;
     end;

   end;

   for i := 0 to Length(self.ODEeqs)-1 do
    begin
      if Length(self.ODEeqs[i])>1 then  // Do not add empty statements
      begin
        odeEqSet:= odeEqSet+self.ODEeqs[i]+ ';'  ;
        odeEqSet2:= odeEqSet2 + self.ODEeqs2[i]+ ';';
      end;
    end;

    // Run Simulation using info from odeFormat:
   odeEqSet:= odeEqSet + ' return dydt_s ;' ;
   odeEqSet2:= odeEqSet2 + ' return dydt_s;';  // Add eqs LSODA list.
  // console.log(' ** LSODA eqs: **');
  // console.log(odeEqSet2);
 end;

 function TFormatODEs.spBoundaryCondition(speciesId: String): boolean;
var
  i: Integer;
 begin
   Result:= false; // default
   for i := 0 to Length(self.speciesAr)-1 do
     begin
     if self.speciesAr[i].getId = speciesId then
       begin
       Result:= self.speciesAr[i].getBoundaryCondition();
       end;
     end;

 end;

 function TFormatODEs.getInitialAssignParamEqs(): TList<string>;
 begin
   Result := self.initialAssignParamEqs;
 end;
 function TFormatODEs.getInitialAssignSpeciesEqs: TList<string>;
 begin
   Result := self.initialAssignSpeciesEqs;
 end;

// SBML math operators:
// arithmetic operators:  power, root, abs, exp, ln, log, floor, ceiling,
// factorial, quotient, max, min, rem
//  trigonometric operators: sin, cos, tan, sec, csc, cot, sinh, cosh, tanh, sech, csch, coth, arcsin, arccos,
// arctan, arcsec, arccsc, arccot, arcsinh, arccosh, arctanh, arcsech, arccsch, arccoth
// constants:  notanumber, pi, infinity, exponentiale

// Assumes left parenthesis follows operator: 'pow(a,b)', not 'pow (a,b)' or 'pow a,b'
function JSMathConvert(eqStr: String): String;
const
  sbmlOp: array[0..5] of String = ('pow', 'ln','log', 'exp', 'abs', 'pi');
  jsMathOp: array[0..5] of String = ('Math.pow', 'Math.log', 'Math.log10', 'Math.exp', 'Math.abs', 'Math.PI');
var
 i: Integer;
 sbmlStr: String;
 jsStr, currStr: String;

begin
  currStr:= eqStr;
  for i := 0 to Length(sbmlOp)-1 do
    begin
      sbmlStr:= sbmlOp[i] + '(';
      //console.log( ' Sbml Math op: ',sbmlStr);
      jsStr:= jsMathOp[i] + '(';
      currStr:= StringReplace(currStr, sbmlStr, jsStr, [rfReplaceAll, rfIgnoreCase]);

    end;
  //console.log( 'JS Math string Replace:', currStr );
  result:= currStr;
end;


end.


