unit uSimulation;

// Set up and execute a simulation.

interface

 Uses Classes, Types, JS, Web, StrUtils, SysUtils, System.Generics.Collections, adamsbdf,
     uVector, uModel, uODE_FormatUtility, WEBLib.ExtCtrls, uSidewinderTypes;

const
  RETURN_P = 'return p;';
  RETURN_S = 'return s;';

type
  TUpdateValEvent = procedure(time:double; updatedVals: TVarNameValList) of object;
  TSimResults = procedure(simResults: TList<TTimeVarNameValList>) of object;
  ODESolver = (EULER, RK4, LSODAS); // ONLY LSODAS used
 TSimulationJS = class (TObject)
   private
    np, ny: Integer;  // Number of parameters, species (ny).
    dydt: TDoubleDynArray;
    s_Vals: array of Double; // species, Changes, one to one correlation: s_Vals[n] <=> s_Names[n]
    s_Names: array of String; // Use species ID as name
    s_NameValAr: TVarNameValList;  // user can change
    s_AssignNameValAr: TVarNameValList; // holds species that have assignment rules, these become params in simulation.

    s_assignRules: array of integer; // s_NameValAr indexes of species with Assignment rules only.
    s_odes: array of integer; // s_NameValAr indexes of species solved through ODEs (need integrator).
    s_InitAssignEqs: string; // Assignment Eqs to be eval at t = 0
    s_AssignEqs: string;  // Assignment equations for species

    simResultsList: TList<TTimeVarNameValList>;
    p_InitAssignEqs: string; // Eqs to be eval at t = 0
    p_AssignEqs: string;  // Assignment equations for params
    p_NameValAr: TVarNameValList;  // user can change
    eqList: String;   // Euler, RK4 ODE eq list.
    LSODAeq: String;  // Formated ODE eq list for LSODA solver.
    step: double;       // time stepsize
    time: double;       // Current time of run.
    runTime: double;    // Length of simulation.
    solverUsed: ODESolver;
    lode: TLsoda;       // LSODA solver
    model: TModel;     // SBML model to simulate
    WebTimer1: TWebTimer;
    online: Boolean; // Simulation running
    ODEready: Boolean; // TRUE: ODE solver is setup. NEEDED ??
    FUpdate: TUpdateValEvent;// Used to send Updated values (species amts) to listeners.
    FStaticSimResults: TSimResults;
    procedure WebTimer1Timer(Sender: TObject);
    procedure buildSpeciesNameValAr(); // Creates s_NameValAr and s_AssignNameValAr
    procedure buildParameterNameValAr(); // Create p_NameValAr: includes species with assignment rules.

   // procedure setSpeciesWithAssignmentRules(); // Needed?populate s_assignRules to be removed from species ode equations to be solved.
    procedure updateLSODAeqsWithNewPSymbols(); // update LSODAeqs with species with assign rules treated as parameters.
    procedure updateSpeciesAssignmentEqsWithNewPSymbols();

   public
    p : TDoubleDynArray;   // System/Model Parameters
    staticSimRun: boolean; // true if run sim to the end, then report results.

    constructor Create ( runTime, nStepSize: double; newModel: TModel; solver: ODESolver ); Overload ;
    procedure setODEsolver(solverToUse: ODESolver);
    procedure nextEval(newTime: double; s: array of double; newPVals: array of double);
  //  procedure eval (newTime: double; s: array of double) ; // currently not used
    procedure eval2 ( time:double; s: array of double); // LSODA integrator
    property OnUpdate: TUpdateValEvent read FUpdate write FUpdate;
    { Notify listener of updated values }
    property OnSimResultsNotify: TSimResults read FStaticSimResults write FStaticSimResults;
    procedure updateVals(time:double; updatedVals: array of double);
    function  getStepSize(): double;
    procedure setStepSize(newStep: double);
    procedure generateEquations(); // Take SBML model and generate eqs compatible for solver.
    function  getLSODAeqs(): string;
    function  getParamInitAssignEqs(): string;
    function  getSpeciesInitAssignEqs(): string;
    function  IsOnline(): Boolean;
    function  IsStaticSimRun(): Boolean;
    procedure setStaticSimRun( staticRun: boolean );
    procedure SetOnline(bOnline: Boolean);
    procedure SetTimerEnabled(bTimer: Boolean);
    procedure SetTimerInterval(nInterval: Integer);
    procedure stopTimer();
    procedure startTimer();
    function  getTime():double;
    // TODO: ??procedure updateInitialAssignments(); If any InitAssignments, calc them here then set param, species init vals to these.
    procedure setRuntime( newRunTime: double );
    procedure setTime( newTime: double );
    procedure startSimulation();
    procedure startStaticSimulation();
    procedure updateSimulation();
    procedure updateP_Vals(newP_ValList:TVarNameValList);
    procedure updateP_Val( index: integer; newVal: double );
    function  getP_Vals(): TVarNameValList;
    procedure updateS_Vals(newS_ValList:TVarNameValList);
    procedure updateS_Val( index: integer; newVal: double );
    function  getS_NameValList(): TVarNameValList;
    procedure setInitValues(); // set init Assignment vals of params. species at t=0
    procedure updateAssignedPValues(); // update p_NameValAr from assignment rules before sending to integrator
    procedure updateAssignedSValues(); // update s_NameValAr from assignment rules
    procedure testLSODA();  // Solve test equations. All pascal code.
 end;

implementation

constructor TSimulationJS.Create ( runTime, nStepSize: double; newModel: TModel; solver: ODESolver ) Overload ;
var
  i: integer;
  mod_p: TDoubleDynArray;
begin
  self.staticSimRun := false;  // default
  self.WebTimer1 := TWebTimer.Create(nil);
  self.WebTimer1.OnTimer := WebTimer1Timer;
  self.WebTimer1.Enabled := false;
  self.WebTimer1.Interval := 100;  // default, msec
  self.online := false;
  self.model := newModel;

  self.buildSpeciesNameValAr(); // Creates s_NameValAr and s_AssignNameValAr
  self.ny := self.s_NameValAr.getNumPairs;
  for i := 0 to ny - 1 do
    begin
    self.s_Vals[i] := self.s_NameValAr.getNameVal(i).getVal;
    self.s_Names[i] := self.s_NameValAr.getNameVal(i).getId;
    end;

  self.buildParameterNameValAr(); // Create p_NameValAr: includes species with assignment rules.
  self.np := self.p_NameValAr.getNumPairs;
  self.solverUsed:= solver;
  self.generateEquations(); // replace species that are assign with params

  // update LSODAeq with speceies with assignment rules made into parameters.
  // ie. Only want species in reactions and rate rules to be solved by integrator.
  //self.setSpeciesWithAssignmentRules;
  setLength(self.p,self.np);
  self.p := self.p_NameValAr.getValAr;  // get parameter values array for integrator

  setLength(self.dydt,self.ny);
 // console.log(' nStepSize: ',nStepSize,' web interval: ',self.WebTimer1.Interval  );
  self.step:= nStepSize;
  if self.step <=0 then
    self.step:= 0.1; //  Default

  if runTime >0 then
    self.runTime:= runTime
  else self.runTime:= 500;
  self.time:= 0;

  // lsoda setup
  if self.solverUsed = LSODAS then
  begin
    self.lode :=  TLsoda.create(ny);
    for i := 1 to ny do
    begin
      self.lode.rtol[i] := 1e-4;
      self.lode.atol[i] := 1e-6;
    end;
    self.lode.itol := 2;
    self.lode.itask := 1;
    self.lode.istate := 1;
    self.lode.iopt := 0;
    self.lode.jt := 2;
   asm
    //console.log('Create: LSODA Funct: ', this.LSODAeq);
    var ODE_func2 = new Function('time', 's','p', this.LSODAeq);
    this.lode.Setfcn (ODE_func2);
   end;
  end;

end;

procedure TSimulationJS.startSimulation();     // Continue here .....
begin
  if self.s_AssignEqs <> '' then
    self.updateAssignedSValues;   // update val for species with Assignment rule.
  self.p := self.p_NameValAr.getValAr;
  self.ODEready := true;
  //console.log('Init time: ', self.time);
  self.updateSimulation;
end;

procedure TSimulationJS.startStaticSimulation();
var i, totalNumberOfEvals: integer;
begin
  if self.online then
  begin
    // TODO: stop current run and reset everything? Maybe just have maincontroller reset sim
    self.stopTimer;
  end;
  totalNumberOfEvals := round(self.runTime / self.step);
  self.ODEready := true; // ?? need to check instead ?

  if self.s_AssignEqs <> '' then
    self.updateAssignedSValues;   // update val for species with Assignment rule.
  self.p := self.p_NameValAr.getValAr;   // Only first element is defined here.... <-----

  self.StaticSimRun := true;
  if self.simResultsList <> nil then self.simResultsList.free
  else self.simResultsList := TList<TTimeVarNameValList>.create;
  self.online := false;
  for i := 0 to totalNumberOfEvals -1 do
    begin
    self.updateSimulation;
    end;
 // console.log('Simulation done: iter: ', i); // Now notify listener....
  if Assigned(FStaticSimResults) then
       begin
       FStaticSimResults( self.simResultsList );
       end;
end;

procedure TSimulationJS.updateSimulation();
begin
  if self.ODEready = true then
    begin
      if self.time = 0.0 then // assume run starts at 0.0
        begin
        self.setInitValues; // executes assignment rules as well.
        end;
      if self.p_AssignEqs <> '' then
        begin
        self.updateAssignedPValues;
        end;
      self.p := self.p_NameValAr.getValAr;
      //  console.log('updateSimulation: self.time, s[0]: ',self.time,', ',self.s_Vals);
      self.nextEval(self.time, self.s_Vals, self.p);
    end
    // else error msg needed?
  else
    self.startSimulation();
end;

procedure TSimulationJS.generateEquations();
var
  i: Integer;
  odeFormat: TFormatODEs;
begin
  odeFormat := TFormatODEs.create(self.model);
  // Run Simulation using info from odeFormat:
  odeFormat.buildFinalEqSet();
 // console.log(' ODE eq set2:',odeFormat.getODEeqSet2());
   if self.solverUsed = LSODAS then
    self.LSODAeq := odeFormat.getODEeqSet2()
  else
    self.eqList := odeFormat.getODEeqSet();
  if self.s_AssignNameValAr.getNumPairs > 0 then
    self.updateLSODAeqsWithNewPSymbols(); // Now replace all species assign with parms names: ie s[#] -> p[#]
  self.p_InitAssignEqs := '';
  self.s_InitAssignEqs := '';
  self.s_AssignEqs := '';
  self.p_AssignEqs := '';
  // need to add species assignments rules in ODE list, assume always ODEs? (calc diff)
  for i := 0 to length(odeFormat.getAssignRuleParamEqs) -1 do
    self.p_assignEqs := self.p_assignEqs + odeFormat.getAssignRuleParamEqs[i] + sLineBreak;
  for i := 0 to length(odeFormat.getAssignRuleSpeciesEqs) -1 do
    self.s_assignEqs := self.s_assignEqs + odeFormat.getAssignRuleSpeciesEqs[i] + sLineBreak;
  if self.p_AssignEqs <> '' then
    self.p_AssignEqs := self.p_AssignEqs + RETURN_P + sLineBreak;
  if self.s_AssignEqs <> '' then
    self.s_AssignEqs := self.s_AssignEqs + RETURN_S + sLineBreak;
  self.updateSpeciesAssignmentEqsWithNewPSymbols; // Now move all symbols of species with assignment rules to parameter symbols.

  // Initial assignments:
  for i := 0 to odeFormat.getInitialAssignParamEqs.Count -1 do
    self.p_InitAssignEqs := self.p_InitAssignEqs + odeFormat.getInitialAssignParamEqs[i] + sLineBreak;
  for i := 0 to odeFormat.getInitialAssignSpeciesEqs.count -1 do
    self.s_InitAssignEqs := self.s_InitAssignEqs + odeFormat.getInitialAssignSpeciesEqs[i] + sLineBreak;
  if self.p_InitAssignEqs <> '' then
    self.p_InitAssignEqs := self.p_InitAssignEqs + RETURN_P + sLineBreak;
  if self.s_InitAssignEqs <> '' then
    self.s_InitAssignEqs := self.s_InitAssignEqs + RETURN_S + sLineBreak;
//  console.log( '*** p Init eqs: ', self.p_InitAssignEqs );
//  console.log( '** s Init eqs: ', self.s_InitAssignEqs );
end;

 procedure TSimulationJS.nextEval(newTime: double; s: array of double; newPVals: array of double);
begin
  self.p := newPVals;
   // Get last time and s values and pass into eval2:
  if length(s) > 0 then
    begin
      if self.solverUsed = LSODAS then
        self.eval2(newTime, s);
    end;
end;



procedure  TSimulationJS.eval2 ( time:double; s: array of double);
 var i,j: Integer;
 var numSteps: Integer;
 var p_mod: TDoubleDynArray; // includes species with assignment rules
     y: TVector;
     tNext: double;
     spAssignRules: boolean; // true if species assignment rules are used.
begin
   spAssignRules := false;
  // console.log('eval2: s vals: ', s);
  // console.log('eval 2: p vals: ', self.p);
   numSteps:= Round(self.runTime/self.step);
   if self.solverUsed = LSODAS then
   begin
   // update params to include species assignment rules, subtract species assignments from species list
    if self.s_AssignEqs <> '' then
      spAssignRules := true;
    self.lode.p:= self.p; // set param vals.

    tNext:= time + self.step;
    y:= TVector.create(Length(s));
    for i := 1 to Length(s) do
      begin
        y[i]:= s[i-1];
      end;
    self.time:= time; // reset time to current time.
    self.lode.Execute (y, self.time, tNext);
    self.time := tNext;
   
     // Convert TVector back to array of double ( y ->s)
    for i:= 0 to Length(s)-1 do
      begin
        s[i]:= y[i+1];
      end;
    if spAssignRules then
      begin
      self.updateAssignedSValues;   // ??? Calc assignment rules after rxns and rate rules
      end;

    console.log('eval2 after integration: s vals: ', s);
    self.updateVals(self.time,s);
    if self.lode.istate < 0 then
      begin
        console.log ('Error, istate = ', self.lode.istate);
      end;
      tNext:= tNext + self.step;
   end;

  end;

 procedure TSimulationJS.buildSpeciesNameValAr(); // Creates s_NameValAr and s_AssignNameValAr
 var i: integer;
    tempNameValAr: TVarNameValList;
 begin
    self.s_NameValAr := TVarNameValList.create;
    self.s_AssignNameValAr := TVarNameValList.create;
    tempNameValAr := TVarNameValList.create;
    tempNameValAr.copy(self.model.getS_initNameValAr); // List of species in model
    for i := 0 to tempNameValAr.getNumPairs -1 do
      begin
      if (self.model.getSBMLRuleWithVarId(tempNameValAr.getNameVal(i).getId) <> nil )
       and self.model.getSBMLRuleWithVarId(tempNameValAr.getNameVal(i).getId).isAssignment then
        begin
        self.s_AssignNameValAr.add(tempNameValAr.getNameVal(i));
        setLength(self.s_assignRules, length(self.s_assignRules) +1);
        self.s_assignRules[length(self.s_assignRules) - 1] := i;// Save index to species solved through Assignment rule
        end
      else
        begin
        self.s_NameValAr.add(tempNameValAr.getNameVal(i));
        setLength(self.s_odes, length(self.s_odes) + 1);
        self.s_odes[length(self.s_odes) - 1] := i; // Save index to species solved through integrator.
        end;

      end;
 end;

 procedure TSimulationJS.buildParameterNameValAr(); // Create p_NameValAr: includes species with assignment rules.
 var i: integer;
     tempNameValAr: TVarNameValList;
 begin
   self.p_NameValAr := TVarNameValList.create;
   tempNameValAr := TVarNameValList.create;
   tempNameValAr.copy(self.model.getP_NameValAr); // List of parameters in model
   for i := 0 to tempNameValAr.getNumPairs -1 do
     self.p_NameValAr.add(tempNameValAr.getNameVal(i));
   for i := 0 to self.s_AssignNameValAr.getNumPairs -1 do // Add species with Assignment rules
     self.p_NameValAr.add(self.s_AssignNameValAr.getNameVal(i));
 end;

{ procedure TSimulationJS.setSpeciesWithAssignmentRules(); // populate s_assignRules  NOT needed, done in buildSpeciesNameValAr()
 // Create an array of species that have assignment rules assigned them.
 // Save index from self.s_NameValAr that corresponds to the species.
 // Also create array of species that are solved by integrator,
 // saving corresponding index from self.s_NameValAr
 var i: integer;
 begin
   for i := 0 to self.s_NameValAr.getNumPairs -1 do
     begin
     if (self.model.getSBMLRuleWithVarId(self.s_NameValAr.getNameVal(i).getId) <> nil )
       and self.model.getSBMLRuleWithVarId(self.s_NameValAr.getNameVal(i).getId).isAssignment then
       begin
       setLength(self.s_assignRules, length(self.s_assignRules) +1);
       self.s_assignRules[length(self.s_assignRules) - 1] := i;// Save index to species solved through Assignment rule
       end
     else
       begin
       setLength(self.s_odes, length(self.s_odes) + 1);
       self.s_odes[length(self.s_odes) - 1] := i; // Save index to species solved through integrator.
       end;

     end;

 end;    }


procedure TSimulationJS.updateLSODAeqsWithNewPSymbols();
// update LSODAeqs with new param list that includes species with assign rules.
var i: integer;
    cur_sIndexStr: string; // species index to be replaced with p ( s[#] -> p[##] )
    cur_pIndexStr: string;
    newLSODAStr: string;
begin
   newLSODAStr := '';
   for i := 0 to length(self.s_assignRules) - 1 do
     begin
     cur_sIndexStr := 's[' + inttostr(self.s_assignRules[i]) +']';
     console.log('LSODA eq, before: ',self.LSODAeq);
     cur_pIndexStr := 'p[' + inttostr(length(self.p_NameValAr.getValAr) - length(self.s_assignRules) + i) +']';
     newLSODAStr := ReplaceStr(self.LSODAeq,cur_sIndexStr,cur_pIndexStr);
     self.LSODAeq := newLSODAStr;
     console.log('LSODA eq, after: ',self.LSODAeq);
     end;
   console.log('AssignRule pars Updated lsodaEqs: ', self.LSODAeq);
end;


procedure TSimulationJS.updateSpeciesAssignmentEqsWithNewPSymbols();
var i: integer;
    cur_sIndexStr: string; // species index to be replaced with p ( s[#] -> p[##] )
    cur_pIndexStr: string;
    newAssignStr: string;
begin
console.log('updateSpeciesAssignmentEqsWithNewPSymbols: orig:', self.s_AssignEqs);
  for i := 0 to length(self.s_assignRules) - 1 do
    begin
    cur_sIndexStr := 's[' + inttostr(self.s_assignRules[i]) +']';
    cur_pIndexStr := 'p[' + inttostr(length(self.p_NameValAr.getValAr) - length(self.s_assignRules) + i) +']';
    newAssignStr := ReplaceStr(self.s_AssignEqs, cur_sIndexStr,cur_pIndexStr);
    end;
  newAssignStr := ReplaceStr(newAssignStr, RETURN_S, RETURN_P);
  self.s_AssignEqs := newAssignStr;
  console.log('updateSpeciesAssignmentEqsWithNewPSymbols- Updated:', self.s_AssignEqs);
end;

  // return current time of run and variable values to listener:
procedure TSimulationJS.UpdateVals( time: double; updatedVals: array of double);
var i, j, currentIndex: integer;
    newSpVals: array of double; // updated model species array of values.
    newSpNames: array of string; // updated model species array of names.
    found: boolean;
    updatedList: TVarNameValList;
    updatedTimeVarList: TTimeVarNameValList;
 begin
  // Make sure species assignment vals have been moved from params to orig model species list...
  // s_AssignNameValAr
  // s_assignRules: each array val holds index to orig species array in model
   currentIndex := 0;
   for i := 0 to length(self.model.getS_Names) - 1 do
     begin
     found := false;
     for j := 0 to length(self.s_assignRules) -1 do
       begin
       if self.s_assignRules[j] = i then
         begin // assign species val goes here
         setLength(newSpVals, length(newSpVals) + 1);
         setLength(newSpNames, length(newSpNames) + 1);
         newSpVals[i] := self.s_AssignNameValAr.getNameVal(j).getVal; // get rid of..
         newSpNames[i] := self.s_AssignNameValAr.getNameVal(j).getId; // get rid of...
         if self.s_AssignNameValAr.getNameVal(j).getId = self.model.getS_Names[i] then
           begin
           found := true;
           newSpVals[i] := self.s_AssignNameValAr.getNameVal(j).getVal;
           newSpNames[i] := self.s_AssignNameValAr.getNameVal(j).getId;
           end
         else console.log('TSimulationJS.UpdateVals: wrong species name!' );
         end;
       end;
     if not found then
       begin
       if currentIndex < length(updatedVals) then
         begin
         setLength(newSpVals, length(newSpVals) + 1); // ??
         setLength(newSpNames, length(newSpNames) + 1); // ??
         newSpVals[i] := updatedVals[currentIndex];
         newSpNames[i] := self.s_Names[currentIndex];
         inc(currentIndex);
         end
       else console.log('TSimulationJS.UpdateVals: currentIndex > length(updatedVals) !' );
       end;

     end;

   updatedList := TVarNameValList.create;        // Bug here.... ??
     for i := 0 to Length(updatedVals) + Length(self.s_assignRules) -1 do
       begin
     //  updatedList.add( TVarNameVal.create( self.s_Names[i], newSpVals[i] ) );  // <--- need to get sp_Assign name as well
       updatedList.add( TVarNameVal.create( newSpNames[i], newSpVals[i] ) );
       end;

   if self.staticSimRun then
     begin
     updatedTimeVarList := TTimeVarNameValList.create(time, updatedList);
     self.simResultsList.add(updatedTimeVarList);
     end
   else
     if Assigned(FUpdate) then
       FUpdate( time, updatedList );
 end;


procedure TSimulationJS.updateP_Vals(newP_ValList:TVarNameValList);
var i, j: integer;
begin
//console.log('TSimulationJS.updateP_Vals:');
  // Updating p values so do not delete....
  for i := 0 to self.p_NameValAr.getNumPairs -1 do
    begin
    for j := 0 to newP_ValList.getNumPairs -1 do
      begin
      if self.p_NameValAr.getNameVal(i).getId = newP_ValList.getNameVal(j).getId then
        self.p_NameValAr.getNameVal(i).setVal(newP_ValList.getNameVal(j).getVal);
      end;
    end;

  self.p := self.p_NameValAr.getValAr;  // get parameter values array for integrator
end;

procedure TSimulationJS.updateP_Val( index: integer; newVal: double );
var i: integer;
begin
  if (length(self.p) > index) and (index > -1) then
    begin
    self.p[index] := newVal;
    self.p_NameValAr.setVal( index, newVal );
    end;

end;

function TSimulationJS.getP_Vals(): TVarNameValList;
begin
  Result := self.p_NameValAr;
end;

procedure TSimulationJS.updateS_Vals(newS_ValList:TVarNameValList);
var i: integer;
begin
  self.s_NameValAr.Free;
  self.s_NameValAr := TVarNameValList.create;
  self.s_NameValAr.copy(newS_ValList);
  setLength(self.s_Vals, self.s_NameValAr.getNumPairs);
  for i := 0 to self.s_NameValAr.getNumPairs -1 do
    begin
    self.s_Vals[i] := self.s_NameValAr.getNameVal(i).getVal;
    end;

end;

procedure TSimulationJS.updateS_Val( index: integer; newVal: double );
begin
  if (length(self.s_Vals) > index) and (index > -1) then
    begin
    self.s_Vals[index] := newVal;
    self.s_NameValAr.setVal( index, newVal );
    end;

end;

function  TSimulationJS.getS_NameValList(): TVarNameValList;
begin
  Result := self.s_NameValAr;
end;

procedure TSimulationJS.setODEsolver(solverToUse: ODESolver);
begin
   self.solverUsed:= solverToUse;
end;

function  TSimulationJS.getTime():double;
begin
  Result := self.time;
end;

procedure TSimulationJS.setTime( newTime: double );
begin
  if newTime >= 0 then
    self.time := newTime;
end;

procedure TSimulationJS.setRuntime( newRunTime: double );
begin
  if newRunTime >0 then
    self.runTime := newRunTime;
end;
procedure TSimulationJS.setStepSize(newStep: double);
begin
  if newStep > 0.0 then self.step:= newStep
  else self.step := 0.1;
end;

function TSimulationJS.getStepSize(): double;
begin
  Result:= self.step;
end;

function TSimulationJS.IsOnline(): Boolean;
begin
  Result := self.online;
end;

procedure TSimulationJS.SetOnline(bOnline: Boolean);
begin
  self.online := bOnline;
end;

function  TSimulationJS.IsStaticSimRun(): Boolean;
begin
  Result := self.staticSimRun;
end;

procedure TSimulationJS.setStaticSimRun( staticRun: boolean );
begin
  self.staticSimRun := staticRun;
end;

procedure TSimulationJS.SetTimerEnabled(bTimer: Boolean);
begin
  self.WebTimer1.Enabled := bTimer;
end;

procedure TSimulationJS.SetTimerInterval(nInterval: Integer);
begin
  self.WebTimer1.Interval := nInterval;
end;

procedure TSimulationJS.stopTimer();
begin
  self.WebTimer1.enabled := false;
end;

procedure TSimulationJS.startTimer();
begin
  self.WebTimer1.enabled := true;
end;

procedure TSimulationJS.WebTimer1Timer(Sender: TObject);
begin

  self.updateSimulation();
  if self.time > runTime then
    self.WebTimer1.enabled := false;
end;

procedure TSimulationJS.setInitValues(); // Init assignment equations
var i: integer;
begin

  if self.p_InitAssignEqs <> '' then
    begin
    asm
    //  console.log(this.p_InitAssignEqs);
      var initParamFunc = new Function( 's','p', this.p_InitAssignEqs);
      this.p = initParamFunc(this.s_Vals, this.p);
    //  console.log('new p: ', this.p);
    end
    end;
  // Now check if species init vals need to be calculated:
  if self.s_InitAssignEqs <> '' then
    begin
    asm
    //  console.log(this.s_InitAssignEqs);
      var initSpFunc = new Function( 's','p', this.s_InitAssignEqs);
      this.s_Vals = initSpFunc(this.s_Vals, this.p);
    //  console.log('new s init vals: ', this.s);
    end
    end;
  if self.s_AssignEqs <> '' then
    begin
    self.updateAssignedSValues;
    end;

  self.UpdateVals( 0, self.s_Vals);  // Pass init values back to listeners
end;


procedure TSimulationJS.updateAssignedSValues(); //update species with assignment rule
var i, j: integer;        // treat all species with assignments rules as params
    new_pVals: array of double;
begin
 // check if species assignments need to be calculated:
  if self.s_AssignEqs <> '' then
    begin
    asm
    //  console.log(this.s_InitAssignEqs);
      var assignParFunc = new Function( 's','p', this.s_AssignEqs);
      new_pVals = assignParFunc(this.s_Vals, this.p);
      console.log('new Species Assignment vals for p vals: ', new_pVals);
    end
    end;
  for i := 0 to self.getP_Vals.getNumPairs -1 do
    begin
    self.p_NameValAr.setVal(i,new_pVals[i] ); // Make sure list is updated with current vals.
    end;
end;

procedure TSimulationJS.updateAssignedPValues(); // update p_NameValAr from assignment rules
var i: integer;
begin
  // check if species assignments need to be calculated:
  if self.p_AssignEqs <> '' then
    begin
    asm
    //  console.log(this.s_InitAssignEqs);
      var assignParFunc = new Function( 's','p', this.p_AssignEqs);
      this.p = assignParFunc(this.s_Vals, this.p);
      console.log('new Assignment for p vals: ', this.p);
    end
    end;
  for i := 0 to self.getP_Vals.getNumPairs -1 do
    begin
    self.p_NameValAr.setVal(i,self.p[i] ); // Make sure list is updated with current vals.
    end;
end;

function TSimulationJS.getLSODAeqs(): string;
  begin
  Result := self.LSODAeq;
  end;

function  TSimulationJS.getParamInitAssignEqs(): string;
  begin
  Result := self.p_InitAssignEqs;
  end;

function  TSimulationJS.getSpeciesInitAssignEqs(): string;
  begin
  Result := self.s_InitAssignEqs;
  end;

  procedure TSimulationJS.testLSODA();

 begin
   // LSODA.test.test(); //? Use with all Pascal code.
 end;

end.
