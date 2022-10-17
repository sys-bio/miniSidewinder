unit ufMain;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, StrUtils,
  JS, Web, WEBLib.Graphics, WEBLib.Controls, WEBLib.Forms, WEBLib.Dialogs,
  Vcl.Controls, WEBLib.ExtCtrls, Vcl.StdCtrls, WEBLib.StdCtrls, uSimulation,
  uControllerMain, ufVarSelect, {uParamSliderLayout,} uSidewinderTypes, uGraphPanel,
  uModel, uSBMLClasses, uSBMLClasses.rule, upnlParamSlider,
  VCL.TMSFNCTypes, VCL.TMSFNCUtils, VCL.TMSFNCGraphics, VCL.TMSFNCGraphicsTypes,
  VCL.TMSFNCCustomControl, VCL.TMSFNCScrollBar;

const SIDEWINDER_VERSION = 'Version 0.2 alpha';
      DEFAULT_RUNTIME = 10000;
      EDITBOX_HT = 25;
      ZOOM_SCALE = 20;
      MAX_SLIDERS = 10;
      MAX_STR_LENGTH = 50; // Max User inputed string length for Rxn/spec/param id
      NULL_NODE_TAG = '_Null'; // from uNetwork, just in case, probably not necessary
      DEFAULT_NUMB_PLOTS = 1;
type
  TMainForm = class(TWebForm)
    pnlModelInfo: TWebPanel;
    pnlPlot: TWebPanel;
    pnlParamSliders: TWebPanel;
    btnLoadModel: TWebButton;
    btnRunPause: TWebButton;
    btnSimReset: TWebButton;
    SBMLOpenDialog: TWebOpenDialog;
    pnlTop: TWebPanel;
    lb_InitVals: TWebListBox;
    lbRateLaws: TWebListBox;
    labelInitVals: TWebLabel;
    labelRateLaws: TWebLabel;
    lblStepSize: TWebLabel;
    edtStepSize: TWebEdit;
    procedure WebFormCreate(Sender: TObject);
    procedure btnSimResetClick(Sender: TObject);
    procedure btnLoadModelClick(Sender: TObject);
    procedure btnRunPauseClick(Sender: TObject);
    procedure ParamSliderOnChange(Sender: TObject);
    procedure SBMLOpenDialogChange(Sender: TObject);
    procedure SBMLOpenDialogGetFileAsText(Sender: TObject; AFileIndex: Integer;
      AText: string);
    procedure SliderEditLBClick(Sender: TObject);
    procedure edtStepSizeExit(Sender: TObject);

  private
    numbPlots: Integer; // Number of plots displayed
    numbSliders: Integer; // Number of parameter sliders
    stepSize: double; // default is 0.1
    SliderEditLB: TWebListBox;
    procedure initializePlots();
    procedure initializePlot( n: integer);
    procedure addParamSlider();
    procedure addAllParamSliders(); // add sliders without user intervention.
    procedure deleteSlider(sn: Integer); // sn: slider index
    procedure deleteAllSliders();
    procedure clearSlider(sn: Integer); // sn: slider index
    function  getSliderIndex(sliderTag: integer): Integer;
    procedure EditSliderList(sn: Integer);
    procedure SetSliderParamValues(sn, paramForSlider: Integer);
    procedure resetSliderPositions(); // Reset param position to init model param value.
    procedure selectParameter(sIndex: Integer); // Get parameter for slider
    procedure resetBtnOnLineSim(); // reset to default look and caption of 'Start simulation'
    procedure runSim();
    procedure stopSim();
    procedure setUpSimulationUI();
    procedure refreshPlotAndSliderPanels();
    procedure refreshPlotPanels();
    procedure refreshSliderPanels();
    procedure addPlot(yMax: double); // Add a plot, yMax: largest initial val of plotted species
    procedure resetPlots();  // Reset plots for new simulation.
    procedure selectPlotSpecies(plotnumb: Integer);
    procedure addPlotAll(); // add plot of all species
    procedure deletePlot(plotIndex: Integer); // Index of plot to delete
    procedure deleteAllPlots();
    function  getEmptyPlotPosition(): Integer;
    function  getPlotPBIndex(plotTag: integer): Integer;
    procedure setListBoxInitValues();
    procedure setListBoxRateLaws();
    function  enableStepSizeEdit(): boolean; // true: success
    function  disableStepSizeEdit(): boolean; // true: success
    //procedure checkIfFilePassedIn(); // See if model file name is passed to form as a string

  public
    { Public declarations }
    fileName: string;
    simStarted: boolean; // true sim has been started
    currentGeneration: Integer; // Used by plots as current x axis point
    fPlotSpecies: TVarSelectForm;
    plotSpecies: TList<TSpeciesList>; // species to graph for each plot
    graphPanelList: TList<TGraphPanel>; // Panels in which each plot resides

    fSliderParameter: TVarSelectForm;// Pop up form to choose parameter for slider.
    sliderParamAr: array of Integer;// holds parameter array index (p_vals) of parameter to use for each slider
    pnlSliderAr: array of TPnlParamSlider; // Holds parameter sliders
    strFileInput: string;  // File name that may be passed to form.

    // Displays slider param name and current value
    paramUpdated: Boolean; // true if a parameter has been updated.
    mainController: TControllerMain;
    procedure SliderOnMouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);

    procedure PingSBMLLoaded(newModel:TModel); // Notify when done loading or model changes
    procedure getVals( newTime: Double; newVals: TVarNameValList);// Get new values (species amt) from simulation run
    procedure processGraphEvent(plotPosition: integer; editType: integer); // not currently necessary
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.btnLoadModelClick(Sender: TObject);
begin
  self.SBMLOpenDialog.execute();
end;

procedure TMainForm.btnRunPauseClick(Sender: TObject);
begin
  if self.MainController.IsModelLoaded then
  begin
    try
      self.disableStepSizeEdit;
      if MainController.isOnline = false then
        self.runSim
      else  // stop simulation
        begin
        self.stopSim;
 //  self.btnAddPlot.Enabled := true;
        end;
    except
      on E: Exception do
        notifyUser(E.Message);
    end;
  end
  else notifyUser('Model not loaded, please load model or refresh browser window.');
end;

procedure TMainForm.btnSimResetClick(Sender: TObject);
begin
  try
  self.resetSliderPositions();
  self.enableStepSizeEdit;
  self.mainController.createSimulation();
 // self.initializePlots;
  self.resetPlots;
  self.simStarted := false;
  self.currentGeneration := 0;
  except
    on E: Exception do
      notifyUser('Error resetting simulation, refresh browser.');

  end;
end;

procedure TMainForm.SBMLOpenDialogChange(Sender: TObject);
begin
  if SBMLOpenDialog.Files.Count > 0 then
    SBMLOpenDialog.Files[0].GetFileAsText;
end;

procedure TMainForm.SBMLOpenDialogGetFileAsText(Sender: TObject;
  AFileIndex: Integer; AText: string);
begin
  {if DEBUG then
    begin
    SBMLmodelMemo.Lines.Text := AText;
    SBMLmodelMemo.visible := true;
    end;  }
  // Check if sbmlmodel already created, if so, destroy before creating ?
  self.deleteAllPlots;
  self.deleteAllSliders;
  self.resetBtnOnLineSim;

  self.simStarted := false;
  self.mainController.clearModel;
  self.mainController.clearSim;
 //self.btnResetSimSpecies.enabled := false;

 // self.btnParamReset.enabled := false;
  self.btnSimReset.enabled := false;
  self.MainController.loadSBML(AText);
end;

procedure TMainForm.WebFormCreate(Sender: TObject);

begin
  self.numbPlots := 0;
  self.numbSliders := 0;
  self.stepSize := 0.1;
  self.edtStepSize.Text := floatToStr(self.stepSize * 1000);
  self.simStarted := false;
  self.mainController := TControllerMain.Create();
  self.mainController.setOnline(false);
  self.mainController.setODEsolver;
 // self.saveSimResults := false;
  self.currentGeneration := 0;

  asm
    this.strFileInput = location.search.substring(1);
  end;

  console.log('File passed in: ', self.strFileInput);

  self.btnSimReset.Visible := true;
  self.btnSimReset.Enabled := false;
  self.btnRunPause.Enabled := false;
  self.enableStepSizeEdit;
  self.mainController.addSBMLListener( @self.PingSBMLLoaded );
  self.mainController.addSimListener( @self.getVals ); // notify when new Sim results

end;


procedure TMainForm.initializePlots();
  var i: Integer;
begin
  if graphPanelList <> nil then
    begin
    for i := 0 to graphPanelList.Count - 1 do
      begin

      self.initializePlot(i);
      end;
    end;
end;

procedure TMainForm.initializePlot( n: integer); // n is index
begin
  try
    self.graphPanelList[n].initializePlot( self.plotSpecies[n], 0 {newYMax},
          0 {newYMin}, false {autoUp}, false {autoDown}, self.stepSize,
          clWhite {newBkgrndColor});
    //self.mainController.addSimListener(@self.graphPanelList[n].getVals);// slow?? just use TMainForm.getVals instead
  except
    on E: Exception do
      notifyUser(E.message);
  end;

end;

  procedure TMainForm.SliderOnMouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
  var
    i: Integer; // grab plot which received event
  begin
    if (Button = mbRight) or (Button = mbLeft) then // Both for now.
      begin
        if Sender is TWebPanel then
          begin
            i := TWebPanel(Sender).tag;
            // assume only slider TWebpanel in right panel.
            // ShowMessage('WebPanel sent mouse msg (addParamSlider):  '+ inttostr(i));
            self.EditSliderList(i);
          end;
      end;
  end;

procedure TMainForm.addParamSlider(); // assume slider index is at last position, otherwise it is just an edit.
// default TBar range: 0 to initVal*10
var
  i, sliderTBarWidth, sliderPanelLeft, sliderPanelWidth: Integer;
begin
  // Left most position of the panel that holds the slider
  sliderPanelWidth :=  self.pnlParamSliders.width;
  sliderPanelLeft := 0;    // not used anymore, just set to default

  i := length(self.pnlSliderAr);
  // array index for current slider to be added.
  SetLength(self.pnlSliderAr, i + 1);
  self.pnlSliderAr[i] := TpnlParamSlider.create(self.pnlParamSliders, i, @self.EditSliderList,
                                                @self.paramSliderOnChange );
  self.pnlSliderAr[i].configPSliderPanel(sliderPanelLeft, sliderPanelWidth, SLIDERPHEIGHT);

  self.SetSliderParamValues(i, self.sliderParamAr[i]);
  self.pnlSliderAr[i].configPSliderTBar;
end;

procedure TMainForm.addAllParamSliders();
var i, numParSliders: integer;
    sliderP: string;
begin
  numParSliders := 0;
  numParSliders := length(self.mainController.getModel.getP_Names);
  if numParSliders > MAX_SLIDERS then numParSliders := MAX_SLIDERS;

  for i := 0 to numParSliders -1 do
    begin
    sliderP := '';
    SetLength(self.sliderParamAr, self.numbSliders + 1);    // add a slider
    //sliderP := self.mainController.getModel.getP_names[i];   // needed?
    self.sliderParamAr[self.numbSliders] := i; // assign param indexto slider ??
    inc(self.numbSliders);
    self.addParamSlider(); // <-- Add dynamically created slider

    end;

end;

// Called when adding or updating a param slider. sn = slider index
procedure TMainForm.SetSliderParamValues(sn, paramForSlider: Integer);
var
  rangeMult: Integer;
  pVal:Double;
  pName: String;
begin
  rangeMult := SLIDER_RANGE_MULT; //10; // default.
  pName :=  self.mainController.getModel.getP_Names[self.sliderParamAr[sn]];
  pVal := self.mainController.getModel.getP_Vals[self.sliderParamAr[sn]];
  self.pnlSliderAr[sn].setUpParamSliderVals(pName, pVal);

end;

procedure TMainForm.resetSliderPositions();
var pVal: double; i: integer;
    pName: string;
begin
  for i := 0 to length(self.pnlSliderAr) - 1 do
    begin
      pName :=  self.mainController.getModel.getP_Names[self.sliderParamAr[i]];
      pVal := self.mainController.getModel.getP_Vals[self.sliderParamAr[i]];
      self.pnlSliderAr[i].setUpParamSliderVals( pName, pVal );
    end;
end;

procedure TMainForm.ParamSliderOnChange(Sender: TObject);  // pass this in to upnlParamSlider.OnChange
var
  i, p: Integer;
  newPVal: double;
  isRunning: boolean;
begin
  if Sender is TWebTrackBar then
    begin
      newPVal := 0;
      isRunning := false; // simulation not active.
      i := TWebTrackBar(Sender).tag;
      self.MainController.paramUpdated := true;
      p := self.sliderParamAr[i];  // get param position to update values

      newPVal := self.pnlSliderAr[i].getSliderPosition * 0.01 *
        (self.pnlSliderAr[i].getSliderHighVal - self.pnlSliderAr[i].getSliderLowVal);

      if self.mainController.IsOnline then
        begin
          self.MainController.stopTimer;
          isRunning := true;
        end;
      self.MainController.changeSimParameterVal( p, newPVal );
      if isRunning then self.MainController.startTimer;
      self.pnlSliderAr[i].setTrackBarLabel(self.MainController.getModel.getP_Names[self.sliderParamAr[i]] + ': '
                                                         + FloatToStr(newPVal) );
    end;
end;

// Select parameter to use for slider  : pass this method to upnlParamSlider.onMouseClick
procedure TMainForm.selectParameter(sIndex: Integer); // sIndex is slider index
var
  paramIndex: Integer; // param chosen in radiogroup
  // Pass back to caller after closing popup:
  procedure AfterShowModal(AValue: TModalResult);
  var
    i:Integer;
    addingSlider: Boolean;
    sliderP: string;
  begin
    addingSlider := false;
    sliderP := '';
    if sIndex > length(self.sliderParamAr) -1 then
      addingSlider := true
    else
      begin    // Changing species to plot, so clear out old param entries:
        addingSlider := false;
        self.clearSlider(sIndex);
        self.sliderParamAr[getSliderIndex(sIndex)] := -1; // Clear param location in param Array
      end;

    for i := 0 to fSliderParameter.SpPlotCG.Items.Count - 1 do
      begin
        sliderP := '';
        if fSliderParameter.SpPlotCG.checked[i] then
          begin
            if addingSlider then
              begin
              SetLength(self.sliderParamAr, length(self.sliderParamAr) + 1);    // add a slider
              self.sliderParamAr[length(self.sliderParamAr) -1] := i; // assign param index from param array to slider
              end;
            if not addingSlider then
              begin
              self.sliderParamAr[sIndex] := i; // assign param index from param array to slider
              self.SetSliderParamValues(sIndex, self.sliderParamAr[sIndex]);
              self.pnlSliderAr[sIndex].Visible := true;
              self.pnlSliderAr[sIndex].Invalidate;
              end
            else
              begin
              self.addParamSlider(); // <-- Add dynamically created slider to end of array
              end;

          end;

      end;


  end;

// async called OnCreate for TParamSliderSForm
  procedure AfterCreate(AForm: TObject);
  begin
    (AForm as TVarSelectForm).Top := trunc(self.Height*0.2); // put popup %20 from top
    (AForm as TVarSelectForm).speciesList := self.mainController.getModel.getP_Names;
    (AForm as TVarSelectForm).fillSpeciesCG();
  end;

begin
  fSliderParameter := TVarSelectForm.CreateNew(@AfterCreate);
  fSliderParameter.Popup := true;
  fSliderParameter.ShowClose := false;
  fSliderParameter.PopupOpacity := 0.3;
  fSliderParameter.Border := fbDialogSizeable;
  fSliderParameter.unCheckGroup();
  fSliderParameter.caption := 'Pick parameters for sliders:';
  fSliderParameter.ShowModal(@AfterShowModal);

end;

{procedure TMainForm.pnlParamSlidersMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); // edit slider panel
begin

end;  }

procedure TMainForm.resetBtnOnLineSim();
begin
  self.btnRunPause.ElementClassName := 'btn btn-primary btn-sm';
  self.btnRunPause.caption := 'Start Simulation';
 // self.btnAddPlot.Enabled := false;
 // self.btnParamAddSlider.Enabled := false;
  self.enableStepSizeEdit;

end;

procedure TMainForm.refreshPlotAndSliderPanels();
begin
  if not self.mainController.IsOnline then
    self.refreshPlotPanels;
  self.refreshSliderPanels;

end;

procedure TMainForm.refreshPlotPanels;
var i: integer;
begin
 if assigned(self.graphPanelList) then
   begin
     if self.graphPanelList.count >0 then
     begin
     //console.log(' PlotWPanel width: ', plotsPanelList[0].plotWPanel.width, 'plot PB width: ', plotsPanelList[0].plotPB.width);
     for i := 0 to self.graphPanelList.count -1 do
       begin
       self.graphPanelList[i].Width := self.graphPanelList[i].Parent.Width;
       self.graphPanelList[i].setChartWidth( self.graphPanelList[i].Width );
       self.graphPanelList[i].Invalidate;    // needed ??
       end;
     end;
   end;
end;

procedure TMainForm.refreshSliderPanels;
var i: integer;
begin
  if assigned(self.pnlSliderAr) then
    begin
    for i := 0 to Length(self.pnlSliderAr) - 1 do
      begin
      self.pnlSliderAr[i].configPSliderPanel(0, self.pnlParamSliders.width, SLIDERPHEIGHT);
      self.pnlSliderAr[i].configPSliderTBar;
      {configPSliderPanel(i, 0, self.pnlParamSliders.width, SLIDERPHEIGHT,
                         self.pnlSliderAr);
      configPSliderTBar(i, self.pnlParamSliders.width, self.sliderPTBarAr,
             self.sliderPHLabelAr, self.sliderPLLabelAr, self.sliderPTBLabelAr);  }
      end;
    end;
end;

  procedure TMainForm.runSim();
begin
 // self.btnAddPlot.Enabled := true;
//  self.btnParamAddSlider.Enabled := true;
    self.enableStepSizeEdit;
    if self.simStarted = false then
 // if self.networkUpdated = true then
      begin
      self.setUpSimulationUI;
      self.btnRunPause.font.color := clgreen;
      self.btnRunPause.ElementClassName := 'btn btn-danger btn-sm';
      self.btnRunPause.caption := 'Simulation: Play';
     // add a default plot:
      if self.numbPlots < 1 then
        begin
        addPlotAll()
        end ;
   // else self.btnAddPlotClick(nil);   Only 1 plot for now
      // add default param sliders:
      if self.numbSliders < 1 then
        begin
        self.addAllParamSliders;
      //if length( self.mainController.getModel.getP_Names ) < 11 then
        //self.btnParamAddSlider.Enabled := false;
        end;
    //else self.btnParamAddSliderClick(nil);

      end;

  // ******************
  if self.mainController.IsModelLoaded then
    begin
      MainController.setOnline(true);
	   // self.btnResetSimSpecies.Enabled := false;
     // self.btnParamReset.Enabled := false;
      self.btnSimReset.Enabled := false;
      self.disableStepSizeEdit;
      self.btnRunPause.font.color := clred;
      self.btnRunPause.ElementClassName := 'btn btn-success btn-sm';
      self.btnRunPause.caption := 'Simulation: Pause';
     // if DEBUG then
     //   simResultsMemo.visible := true;
     // self.btnAddPlot.Enabled := false; // Do not add plot while sim running
      self.mainController.SetRunTime(DEFAULT_RUNTIME);
       // default timer interval is 100 msec:
      // multiplier default is 10, range 1 - 50
//      self.mainController.SetTimerInterval(round(1000/self.trackBarSimSpeed.position));
       self.mainController.SetTimerInterval(100);
      self.mainController.SetStepSize(self.stepSize);
     // if self.mainController.getCurrTime = 0  then
    //    self.InitSimResultsTable();  // Set table of Sim results.
      //self.rightPanelType := SIMULATION_PANEL;
      //self.setRightPanels;
      MainController.SetTimerEnabled(true); // Turn on web timer (Start simulation)
      end
   else notifyUser(' No model created for simulation. ');
end;

procedure TMainForm.stopSim();
begin
   MainController.setOnline(false);
  // self.btnResetSimSpecies.Enabled := true;
  // self.btnParamReset.Enabled := true;
   self.btnSimReset.Enabled := true;
   self.enableStepSizeEdit;
   self.MainController.SetTimerEnabled(false); // Turn off web timer (Stop simulation)
   self.btnRunPause.font.color := clgreen;
   self.btnRunPause.ElementClassName := 'btn btn-danger btn-sm';
   self.btnRunPause.caption := 'Simulation: Play';
 {  if self.saveSimResults then
     begin
     self.mainController.writeSimData(self.lblSimDataFileName.Caption, self.simResultsMemo.Lines);
     end;   }
end;

procedure TMainForm.setUpSimulationUI();
var i: integer;
begin
 // btnParamAddSlider.Enabled := true;
 // btnAddPlot.Enabled := true;

  self.currentGeneration := 0; // reset current x axis point (pixel)
 { if self.networkUpdated then // No network layout so no need to update model.
    begin
      // delete existing plots
    if self.numbPlots >0 then
    begin
      if (self.graphPanelList.Count) > 0 then
      begin
        for i := self.graphPanelList.Count-1 downto 0 do
        begin
          self.DeletePlot(i);
        end;
        self.numbPlots := 0;
      end;

    end;
    // delete existing param sliders.
    if self.pnlSliderAr <> nil then
    begin
      if length(self.pnlSliderAr) >0 then
      begin
        self.deleteAllSliders;

        setLength(self.pnlSliderAr, 0);
      end;
    end;
    mainController.createModel;
   self.networkUpdated := false;
    end;   }

 // self.rightPanelType := SIMULATION_PANEL;
 // self.setRightPanels;
  if self.mainController.getModel = nil then
  begin
    self.mainController.createModel;
   // self.networkUpdated := false;
  end;
  self.mainController.createSimulation;
  if self.numbPlots >0 then
    self.resetPlots();
  //self.RSimWPanel.invalidate;
  self.simStarted := true;
end;

procedure TMainForm.SliderEditLBClick(Sender: TObject);
begin
  if self.SliderEditLB.ItemIndex = 0 then // change param for slider
    begin
      self.selectParameter(self.SliderEditLB.tag);
    end;
{  if self.SliderEditLB.ItemIndex = 1 then // delete slider
    begin
      if getSliderIndex(self.SliderEditLB.tag) < length(self.pnlSliderAr) + 1 then
        begin
          self.clearSlider(getSliderIndex(self.SliderEditLB.tag));
        end
      else self.deleteSlider(getSliderIndex(self.SliderEditLB.tag));
    end;  }
  // else ShowMessage('Cancel');
  self.SliderEditLB.tag := -1;
  self.SliderEditLB.visible := false;
  self.SliderEditLB.Top := 2; // default
  self.SliderEditLB.Free;
end;

procedure TMainForm.PingSBMLLoaded(newModel:TModel);
var errList: string;
    i: integer;
begin
  if newModel.getNumSBMLErrors >0 then
    begin
    errList := '';
    for i := 0 to newModel.getNumSBMLErrors -1 do
      begin
      errList := errList + newModel.getSBMLErrorStrs()[i] + #13#10 ; // new line char
      end;
    errList := errList +  'Please fix or load a new model.';
    notifyUser(errList);
    //clearNetwork();
    end
  else
  begin
    if newModel.getNumModelEvents > 0 then
      begin
      notifyUser(' SBML Events not supported at this time. Load a different SBML Model');
      //clearNetwork();
      end
    else if newModel.getNumPiecewiseFuncs >0 then
      begin
      notifyUser(' SBML piecewise() function not supported at this time. Load a different SBML Model');
      //clearNetwork();
      end
  end;

  self.btnRunPause.Enabled := true;
  self.setListBoxInitValues;
  self.setListBoxRateLaws;
 
end;

procedure TMainForm.addPlotAll(); // add plot with all species
var i, numSpeciesToPlot: integer; maxYVal: double; plotSp: string;
begin
  maxYVal := 0;
  numSpeciesToPlot := 0;
  if self.plotSpecies = nil then
    self.plotSpecies := TList<TSpeciesList>.create;
  self.plotSpecies.Add(TSpeciesList.create);
  numSpeciesToPlot := length(self.mainController.getModel.getS_Names);
  if numSpeciesToPlot > 8 then numSpeciesToPlot := 8;

  for i := 0 to numSpeciesToPlot -1 do
    begin
      plotSp := '';
      plotSp := self.mainController.getModel.getS_names[i];
      if ( plotSp.contains( NULL_NODE_TAG ) ) then plotSp := ''  // Null node
      else
      begin
        if self.mainController.getModel.getSBMLspecies(plotSp).isSetInitialAmount then
          begin
          if self.mainController.getModel.getSBMLspecies(plotSp).getInitialAmount > maxYVal then
            maxYVal := self.mainController.getModel.getSBMLspecies(plotSp).getInitialAmount;
          end
        else
          if self.mainController.getModel.getSBMLspecies(plotSp).getInitialConcentration > maxYVal then
            maxYVal := self.mainController.getModel.getSBMLspecies(plotSp).getInitialConcentration;
      end;
     self.plotSpecies[self.numbPlots].Add(plotSp);

    end;
  for i := 0 to Length(self.mainController.getModel.getSBMLspeciesAr) -1 do
    begin
      if numSpeciesToPlot < (i +1) then
        begin
        self.plotSpecies[self.numbPlots].Add('');
        end;
    end;

  if maxYVal = 0 then
    maxYVal := DEFAULTSPECIESPLOTHT  // default for plot Y max
  else maxYVal := maxYVal * 2.0;  // add 100% margin
  self.addPlot(maxYVal); // <-- Add dynamically created plot at this point
  self.refreshPlotAndSliderPanels;
end;

procedure TMainForm.addPlot(yMax: double); // Add a plot
var plotPositionToAdd: integer; // Add plot to next empty position.
    plotWidth: integer;
    newHeight: integer; i: Integer;
begin

  if self.graphPanelList <> nil then self.btnSimResetClick(nil); // need event notification
  inc(self.numbPlots);    // ?? added , change plotall
  plotWidth := 0;
  plotPositionToAdd := -1;
  plotPositionToAdd := self.getEmptyPlotPosition(); // position 1 is index 0

  if self.graphPanelList = nil then
    self.graphPanelList := TList<TGraphPanel>.create;
  self.graphPanelList.Add( TGraphPanel.create(pnlPlot, plotPositionToAdd, yMax) );
  self.graphPanelList[plotPositionToAdd -1].setChartTimeInterval(self.stepSize);
  self.graphPanelList[plotPositionToAdd -1].OnEditGraphEvent := processGraphEvent;
  newHeight := round( self.pnlPlot.Height );  // default
  if self.numbPlots > DEFAULT_NUMB_PLOTS then
  begin
    newHeight := round(self.pnlPlot.Height/self.numbPlots);
  end;

 // Not used for now: self.graphPanelList[self.numbPlots - 1].OnPlotUpdate := self.editPlotList;
  self.initializePlot (self.numbPlots - 1);
  if self.numbPlots > DEFAULT_NUMB_PLOTS then
  begin  // Adjust plots to new height:
    for i := 0 to self.numbPlots - 1 do
      self.graphPanelList[i].adjustPanelHeight(newHeight);

  end;
 end;

procedure TMainForm.resetPlots();  // Reset plots for new simulation.
 var i: integer;
begin // Easier to just delete/create than reset time, xaxis labels, etc.
  for i := 0 to self.graphPanelList.Count -1 do
    begin
    self.graphPanelList[i].setChartDelta(self.stepSize); //Added
    self.graphPanelList[i].deleteChart;
    self.graphPanelList[i].createChart;
    self.graphPanelList[i].setupChart;
    end;
  self.refreshPlotPanels;
end;

procedure TMainForm.selectPlotSpecies(plotnumb: Integer);
 // plotnumb: plot number, not index, to be added or modified

  // Pass back to caller after closing popup:
  procedure AfterShowModal(AValue: TModalResult);
  var
    i: Integer; maxYVal: double; plotSp: string;
    addingPlot: Boolean;
  begin
    maxYVal := 0;
    plotSp := '';
    if self.plotSpecies = nil then
      self.plotSpecies := TList<TSpeciesList>.create;
    if self.plotSpecies.Count < plotnumb then
      begin
        // Add a plot with species list
        addingPlot := true;
        self.plotSpecies.Add(TSpeciesList.create);
      end
    else
      begin    // Changing species to plot, so clear out old entries:
        addingPlot := false;
        self.plotSpecies.Items[getPlotPBIndex(plotNumb)].Clear;
      end;

    for i := 0 to fPlotSpecies.SpPlotCG.Items.Count - 1 do
      begin
        plotSp := '';
        if fPlotSpecies.SpPlotCG.checked[i] then
          begin
            plotSp := self.mainController.getModel.getS_names[i];
          //  plotSp := self.mainController.getModel.getSBMLspecies(i).getID;
            if self.mainController.getModel.getSBMLspecies(plotSp).isSetInitialAmount then
            begin
              if self.mainController.getModel.getSBMLspecies(plotSp).getInitialAmount > maxYVal then
                maxYVal := self.mainController.getModel.getSBMLspecies(plotSp).getInitialAmount;
            end
            else
              if self.mainController.getModel.getSBMLspecies(plotSp).getInitialConcentration > maxYVal then
                maxYVal := self.mainController.getModel.getSBMLspecies(plotSp).getInitialConcentration;

            if addingPlot then
              self.plotSpecies[plotnumb - 1].Add(plotSp)
            else
              self.plotSpecies[getPlotPBIndex(plotNumb)].Add(plotSp);
          end
        else
          if addingPlot then
            self.plotSpecies.Items[plotnumb - 1].Add('')
          else self.plotSpecies.Items[getPlotPBIndex(plotNumb)].Add('');
      end;

    //for i := 0 to Length(self.mainController.getModel.getSBMLspeciesAr) -1 do
    for i := 0 to length(self.mainController.getModel.getS_Names) -1 do
    begin
      if fPlotSpecies.SpPlotCG.Items.Count < (i +1) then
      begin
        if addingPlot then
            self.plotSpecies[plotnumb - 1].Add('')
        else self.plotSpecies[getPlotPBIndex(plotNumb)].Add('');
      end;
    end;

    if maxYVal = 0 then
      maxYVal := DEFAULTSPECIESPLOTHT  // default for plot Y max
    else maxYVal := MaxYVal * 2.0;  // add 100% margin
    if addingPlot then
      self.addPlot(maxYVal) // <-- Add dynamically created plot at this point
    else
      begin   // ???????
      self.graphPanelList[getPlotPBIndex(plotNumb)].setYMax(maxYVal);
      end;

    self.refreshPlotAndSliderPanels;
  end;

// async called OnCreate for TVarSelectForm
  procedure AfterCreate(AForm: TObject);
  var i, lgth: integer;
     strList: array of String;
     curStr: string;
  begin
    lgth := 0;

    for i := 0 to length(self.mainController.getModel.getS_Names) -1 do
    begin
      curStr := '';
      curStr := self.mainController.getModel.getS_names[i];
     { if self.mainController.getModel.getSBMLspecies(i).isSetIdAttribute then
         curStr := self.mainController.getModel.getSBMLspecies(i).getID
      else curStr := self.mainController.getModel.getSBMLspecies(i).getName; }

      if not curStr.Contains( NULL_NODE_TAG ) then
        begin
          lgth := Length(strList);
          setLength(strList, lgth + 1);
          strList[lgth] := curStr;
        end;
    end;
    (AForm as TVarSelectForm).Top := trunc(self.Height*0.2); // put popup %20 from top
    (AForm as TVarSelectForm).speciesList := strList;
    (AForm as TVarSelectForm).fillSpeciesCG();
  end;

begin
  fPlotSpecies := TVarSelectForm.CreateNew(@AfterCreate);
  fPlotSpecies.Popup := true;
  fPlotSpecies.ShowClose := false;
  fPlotSpecies.PopupOpacity := 0.3;
  fPlotSpecies.Border := fbDialogSizeable;
  fPlotSpecies.caption := 'Species to plot:';
  fPlotSpecies.ShowModal(@AfterShowModal);
end;

procedure TMainForm.deletePlot(plotIndex: Integer);
var tempObj: TObject;
begin
  try
    begin
      try
        begin
          self.graphPanelList[plotIndex].deleteChart;
          tempObj := self.graphPanelList[plotIndex];
          tempObj.Free;
          self.graphPanelList.Delete(plotIndex);
          self.plotSpecies.Delete(plotIndex);
          self.numbPlots := self.numbPlots - 1;
        end;
      finally
        self.pnlPlot.Invalidate;
      end;
    end;
  except
     on EArgumentOutOfRangeException do
      notifyUser('Error: Plot number not in array');
  end;
end;

procedure TMainForm.deleteAllPlots();
var i: integer;
begin
  for i := self.numbPlots - 1 downto 0 {1} do
    self.deletePlot(i);
  self.pnlPlot.Invalidate;
end;

procedure TMainForm.deleteSlider(sn: Integer); // sn: slider index
begin
  // console.log('Delete Slider: slider #: ',sn);
  self.pnlSliderAr[sn].free;
  delete(self.pnlSliderAr, (sn), 1);
  delete(self.sliderParamAr,(sn), 1);  // added
  self.pnlParamSliders.Invalidate;
end;

procedure TMainForm.deleteAllSliders();
var i: integer;
begin
  for I := Length(self.pnlSliderAr) -1 downto 0 do
    self.deleteSlider(i);
  self.pnlParamSliders.Invalidate;
  self.numbSliders := 0;
end;

procedure TMainForm.EditSliderList(sn: Integer);
// change param slider as needed. sn is slider index
var
  sliderXposition, sliderYposition: Integer;
  editList: TStringList;
begin
  if length(self.pnlSliderAr) > sn then
    begin
    self.SliderEditLB := TWebListBox.create(self.pnlSliderAr[sn]);
    self.SliderEditLB.OnClick := self.SliderEditLBClick;
    self.SliderEditLB.parent := self.pnlSliderAr[sn];
    self.SliderEditLB.height := self.SliderEditLB.parent.height - 2;
    self.SliderEditLB.width := 200;
    sliderXposition := self.pnlSliderAr[sn].Left + 10; // needs parent to be self.pnlSliderAr[sn]
    sliderYposition := 2;
    editList := TStringList.create();
    editList.Add('Change slider parameter.');
  //  editList.Add('Delete slider.');
    editList.Add('Cancel');
    self.SliderEditLB.Items := editList;
    self.SliderEditLB.Top := sliderYposition;
    self.SliderEditLB.left := sliderXposition;
    self.SliderEditLB.tag := sn;
    self.SliderEditLB.bringToFront;
    self.SliderEditLB.visible := true;
    end;
end;

procedure TMainForm.edtStepSizeExit(Sender: TObject);
var newStep: integer;
    dblNewStep: double;
begin
  try
    dblNewStep := strToFloat(self.edtStepSize.Text);
    if dblNewStep >0 then
      begin
      self.stepSize := dblNewStep * 0.001;
      self.mainController.SetStepSize(self.stepSize);
      end
    else notifyUser ('Step size must be a positive integer');

  except
       on Exception: EConvertError do
         notifyUser ('Step size must be a positive integer');
  end;

  if self.mainController.IsModelLoaded then
  begin
    self.mainController.createSimulation();
    if self.numbPlots >0 then
      //self.initializePlots;
      self.resetPlots;
    self.currentGeneration := 0;
  end;
end;

procedure TMainForm.clearSlider(sn: Integer); // sn: slider index
begin
  self.pnlSliderAr[sn].Visible := false;
  self.sliderParamAr[sn] := -1; // no param index
  self.pnlParamSliders.Invalidate;
end;

function  TMainForm.getSliderIndex(sliderTag: integer): Integer;
var i: integer;
begin
  Result := -1;
  for i := 0 to length(self.pnlSliderAr) -1 do
  begin
    if self.pnlSliderAr[i].Tag = sliderTag then
      Result := i;
  end;
end;

function TMainForm.getEmptyPlotPosition(): Integer;
var i, plotPosition, totalPlots: Integer;
begin
  plotPosition := 1;
  totalPlots := self.numbPlots;
  if self.numbPlots >1 then
  begin
    for i := 0 to totalPlots -2 do
    begin
      if self.graphPanelList[i].Tag = plotPosition then
        inc(plotPosition);
    end;
  end;

  Result := plotPosition;
end;

procedure TMainForm.processGraphEvent(plotPosition: integer; editType: integer);
var yMax: double;
begin
  if editType = EDIT_TYPE_DELETEPLOT then
    begin
    self.deletePlot(plotPosition -1);
    end
  else if editType = EDIT_TYPE_SPECIES then
    begin
    yMax := self.graphPanelList[plotPosition -1].getYMax;

    // delete plot and then select species and add plot.
    self.deletePlot(plotPosition -1);
    self.selectPlotSpecies(plotPosition);

    end;

end;

function  TMainForm.getPlotPBIndex(plotTag: integer): Integer;
var i: integer;
begin
  Result := -1;
  for i := 0 to self.numbPlots -1 do
  begin
    if self.graphPanelList[i].Tag = plotTag then
      Result := i;
  end;
end;

// Get new values (species amt) from simulation run (ODE integrator)
procedure TMainForm.getVals( newTime: Double; newVals: TVarNameValList );
var
//  dataStr: String;
  i: Integer;
 // newValsAr: array of double;
  currentStepSize:double;
begin
  // Update table of data;
 // newValsAr := newVals.getValAr;
//  dataStr := '';
 { dataStr := floatToStrf(newTime, ffFixed, 4, 4) + ', ';
  for i := 0 to length(newValsAr) - 1 do
    begin
      if not containsText(newVals.getNameVal(i).getId, '_Null') then // do not show null nodes
        begin
        if i = length(newValsAr)-1 then
          dataStr := dataStr + floatToStrf(newValsAr[i], ffExponent, 6, 2)
        else
          dataStr := dataStr + floatToStrf(newValsAr[i], ffExponent, 6, 2) + ', ';
        end;
    end;  }
 // simResultsMemo.Lines.Add(dataStr);  Not used

  // Update plots:
  if self.graphPanelList.count > 0 then
    begin
    for i := 0  to self.graphPanelList.count -1 do
      begin
      self.graphPanelList[i].getVals(newTime, newVals); // Faster than own listener ??
      end;
    end;
end;


procedure TMainForm.setListBoxInitValues();
var i: integer;
    curId, curAssign, temp: string;
    curVal: double;
    strListInitVals: TStringList;
    paramAr: array of TSBMLparameter;
    compAr: array of TSBMLCompartment;
    floatSpeciesAr: array of TSBMLSpecies;
    boundarySpeciesAr: array of TSBMLSpecies;
begin
  strListInitVals := TStringList.Create;
  paramAr := self.mainController.getModel.getSBMLparameterAr;
  for i := 0 to length(paramAr) -1 do
    begin
    temp := '';
    curId := '';
    curVal := 0.0;
    curId := paramAr[i].getId;
    if self.mainController.getModel.getInitialAssignmentWithSymbolId(curId) <> nil then
      begin
      temp := curId + ' = ' + self.mainController.getModel.getInitialAssignmentWithSymbolId(curId).getFormula;
      strListInitVals.Add(temp);
      end
    else
      begin
      temp := curId+ ' = ' + floatToStr(paramAr[i].getValue);
      strListInitVals.Add(temp);
      end;
    end;

  compAr := self.mainController.getModel.getSBMLcompartmentsArr;
  for i := 0 to length(compAr) -1 do
    begin
    temp := '';
    curId := '';
    curVal := 0.0;
    temp := compAr[i].getID + ' = ' + floatToStr(compAr[i].getVolume);
    strListInitVals.Add(temp);
    end;

  floatSpeciesAr := self.mainController.getModel.getSBMLFloatSpeciesAr;
  for i := 0 to length(floatSpeciesAr) -1 do
    begin
    temp := '';
    curId := '';
    curVal := 0.0;
    curId := floatSpeciesAr[i].getId;
    if self.mainController.getModel.getInitialAssignmentWithSymbolId(curId) <> nil then
      begin
      temp := curId + ' = ' + self.mainController.getModel.getInitialAssignmentWithSymbolId(curId).getFormula;
      strListInitVals.Add(temp);
      end
    else
      begin
      temp := curId+ ' = ';
      if floatSpeciesAr[i].isSetInitialConcentration then
        temp := temp + floatToStr(floatSpeciesAr[i].getInitialConcentration)
      else temp := temp + floatToStr(floatSpeciesAr[i].getInitialAmount);
      strListInitVals.Add(temp);
      end;
    end;

  boundarySpeciesAr := self.mainController.getModel.getSBML_BC_SpeciesAr;
  for i := 0 to length(boundarySpeciesAr) -1 do
    begin
    temp := '';
    curId := '';
    curVal := 0.0;
    curId := boundarySpeciesAr[i].getId;
    temp := 'Boundary species ' + curId + ' = ';
    if self.mainController.getModel.getInitialAssignmentWithSymbolId(curId) <> nil then
      begin
      temp := temp + self.mainController.getModel.getInitialAssignmentWithSymbolId(curId).getFormula;
      strListInitVals.Add(temp);
      end
    else
      begin
      //temp := curId+ ' = ';
      if boundarySpeciesAr[i].isSetInitialConcentration then
        temp := temp + floatToStr(boundarySpeciesAr[i].getInitialConcentration)
      else temp := temp + floatToStr(boundarySpeciesAr[i].getInitialAmount);
      strListInitVals.Add(temp);
      end;
    end;

  self.lb_InitVals.Items := strListInitVals;
end;

procedure TMainForm.setListBoxRateLaws();
var i: integer;
    curVar, temp: string;
    strListRates: TStringList;
    rateAr: array of TSBMLrule;
    rxnAr: array of SBMLReaction;
begin
  strListRates := TStringList.Create;
  rateAr := self.mainController.getModel.getSBMLmodelRules;
  for i := 0 to length(rateAr) -1 do
    begin
    temp := '';
    curVar := '';
    if rateAr[i].isRate then
      begin
      temp := rateAr[i].getVariable + ' : ';
      temp := temp + rateAr[i].getFormula;
      strListRates.Add(temp);
      end;

    end;

  rxnAr := self.mainController.getModel.getReactions;
  for i := 0 to length(rxnAr) -1 do
    begin
    temp := '';
    curVar := '';
    temp := rxnAr[i].getID + ' : ';
    temp := temp + rxnAr[i].getKineticLaw.getFormula;
    strListRates.Add(temp);


    end;
  self.lbRateLaws.Items := strListRates;

end;

function TMainForm.enableStepSizeEdit(): boolean; // true: success
begin
  self.lblStepSize.Enabled := true;
  self.edtStepSize.Enabled := true;
  Result := true;
end;
function TMainForm.disableStepSizeEdit(): boolean;// true: success
begin
  self.lblstepSize.Enabled := false;
  self.edtStepSize.Enabled := false;
  Result := true;

end;


end.