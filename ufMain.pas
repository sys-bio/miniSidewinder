unit ufMain;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, StrUtils,
  JS, Web, WEBLib.Graphics, WEBLib.Controls, WEBLib.Forms, WEBLib.Dialogs,
  Vcl.Controls, WEBLib.ExtCtrls, Vcl.StdCtrls, WEBLib.StdCtrls, uSimulation,
  uControllerMain, ufVarSelect, uSidewinderTypes, uGraphPanel, uTestModel,
  uModel, uSBMLClasses, uSBMLClasses.rule, upnlParamSlider,
  VCL.TMSFNCTypes, VCL.TMSFNCUtils, VCL.TMSFNCGraphics, VCL.TMSFNCGraphicsTypes,
  VCL.TMSFNCCustomControl, VCL.TMSFNCScrollBar, Vcl.Menus, ufModelInfo, ufLabelPopUp,
  WEBLib.Menus, WEBLib.WebCtrls, ufChkGroupEditPlot, ufAbout, ufInputText;

const SIDEWINDER_VERSION = 'MiniSidewinder Version 0.9.4';
      COPYRIGHT = 'Copyright 2023, Bartholomew Jardine and Herbert M. Sauro, University of Washington, USA';
      GRANT_INFO = 'This project was funded by NIH/NIGMS (R01-GM123032-04).';
      DEFAULT_RUNTIME = 10000;
      DEFAULT_STATICRUN = 50;
      EDITBOX_HT = 25;
      ZOOM_SCALE = 20;
      MAX_PLOTSPECIES = 8;
      MAX_SLIDERS = 12;
      MAX_PARAMETER_SLIDERS = 8;
    //  MAX_SPECIES_SLIDERS = 4;
      SLIDERS_PER_ROW = 4;
      MAX_STR_LENGTH = 50; // Max User inputed string length for Rxn/spec/param id
      NULL_NODE_TAG = '_Null'; // from uNetwork, just in case, probably not necessary
      DEFAULT_NUMB_PLOTS = 1; // Currently only works with 1 plot.
      // Component look, bootstrap strings:
      BTN_DISABLED = 'btn btn-dark btn-sm disabled';
      BTN_ENABLED = 'btn btn-dark btn-sm';
      LOAD_BTN_DISABLED = 'btn btn-primary btn-sm disabled';
      LOAD_BTN = 'btn btn-primary btn-sm';
      BTN_TOP_PANEL_WIDTH = 0.10; // top btn panels percent width of pnlTop


type
  TMainForm = class(TWebForm)
    pnlSimInfo: TWebPanel;
    pnlPlot: TWebPanel;
    pnlSliders: TWebPanel; // Holds all of the param and species sliders ....
    btnLoadModel: TWebButton;
    btnRunPause: TWebButton;
    btnSimReset: TWebButton;
    SBMLOpenDialog: TWebOpenDialog;
    pnlTop: TWebPanel;
    lblStepSize: TWebLabel;
    edtStepSize: TWebEdit;
    pnlSimSpeedMult: TWebPanel;
    trackBarSimSpeed: TWebTrackBar;
    lblSpeedMult: TWebLabel;
    lblSpeedMultVal: TWebLabel;
    lblSpeedMultMin: TWebLabel;
    lblSpeedMultMax: TWebLabel;
    btnModelInfo: TWebButton;
    btnExample: TWebButton;
    chkbxStaticSimRun: TWebCheckBox;
    graphEditPopup: TWebPopupMenu;
    editPlot1: TMenuItem;
    pnlRunTime: TWebPanel;
    lblRunTime: TWebLabel;
    editRunTime: TWebEdit;
    btnEditGraph: TWebButton;
    pnlLoadModel: TWebPanel;
    pnlSimReset: TWebPanel;
    pnlRunPause: TWebPanel;
    pnlStepSize: TWebPanel;
    pnlStaticSim: TWebPanel;
    pnlModelInfo: TWebPanel;
    pnlEditGraph: TWebPanel;
    pnlExample: TWebPanel;
    pnlEditSliders: TWebPanel;
    btnEditSliders: TWebButton;
    pnlAbout: TWebPanel;
    btnAbout: TWebButton;
    pnlPlotResults: TWebPanel;
    btnSavePlotResults: TWebButton;
    pnlEditSpSliders: TWebPanel;
    btnEditSpSliders: TWebButton;

    procedure WebFormCreate(Sender: TObject);
    procedure btnSimResetClick(Sender: TObject);
    procedure btnLoadModelClick(Sender: TObject);
    procedure btnRunPauseClick(Sender: TObject);
    procedure ParamSliderOnChange(Sender: TObject);
    procedure SpeciesSliderOnChange(Sender: TObject);
    procedure SBMLOpenDialogChange(Sender: TObject);
    procedure SBMLOpenDialogGetFileAsText(Sender: TObject; AFileIndex: Integer;
      AText: string);
    procedure SliderEditLBClick(Sender: TObject);
    procedure edtStepSizeExit(Sender: TObject);
    procedure trackBarSimSpeedChange(Sender: TObject);
    procedure WebFormResize(Sender: TObject);
    procedure btnModelInfoClick(Sender: TObject);
    procedure btnExampleClick(Sender: TObject);
    procedure chkbxStaticSimRunClick(Sender: TObject);
    procedure editPlot1Click(Sender: TObject);
    procedure oggleautoscale1Click(Sender: TObject);
  //  procedure ChangeminmaxYaxis1Click(Sender: TObject);
  //  procedure Changeplotspecies1Click(Sender: TObject);
    procedure ChangeParameter1Click(Sender: TObject);  // Maybe remove ? just use button on side.
    procedure editRunTimeExit(Sender: TObject);
    procedure btnEditGraphClick(Sender: TObject);
    procedure btnEditSlidersClick(Sender: TObject);
    procedure WebFormDestroy(Sender: TObject);
    procedure WebFormExit(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure btnSavePlotResultsClick(Sender: TObject);
    procedure btnEditSpSlidersClick(Sender: TObject);

  private
    numbPlots: Integer; // Number of plots displayed
    slidersPerRow: Integer; // Number of parameter sliders per row.
    intSliderHeight: Integer;
    stepSize: double; // default is 0.1
    SliderEditLB: TWebListBox;
    fModelInfo: TfModelInfo;
    strListInitVals: TStringList;
    strListRates: TStringList;
    currentModelInfo: string;
    xAxisLabel: string;
    yAxisLabel: string;
    spToPlot: string; // Passed in through session store, comma separated list;
    varForSliders: string; // Passed in "   ", comma separated list of var ids;
   //speciesForSliders: string; // Passed in "   ", comma separated list;
    lastStaticSimData: TList<TTimeVarNameValList>; // Holds data from last static sim run.
    lastStaticSimParVals: TVarNameValList; // Holds param vals from last static sim run.
    debug: boolean; // true then show debug console output and any other debug related
    procedure initializePlots();
    procedure initializePlot( n: integer);
    procedure addParamSlider();
    procedure addAllParamSliders(); // add sliders without user intervention.
    procedure addSpeciesSlider();
    procedure addAllSpeciesSliders(); // add sliders without user intervention.
    function  calcSliderWidth(): integer;
    function  calcSliderLeft(index: integer): integer; // calc left side of slider relative to pnlSliders
    function  calcSliderTop(index: integer): integer;
    procedure deleteSlider(sn: Integer); // sn: slider index
    procedure deleteParamSlider(sn: Integer); // sn: slider index
    procedure deleteSpeciesSlider(sn: Integer); // sn: slider index
    procedure deleteAllSliders();
    procedure deleteAllParamSliders();
    procedure deleteAllSpeciesSliders();
    procedure clearSlider(sn: Integer); // sn: slider index
    procedure clearParamSlider(sn: Integer); // sn: slider index
    procedure clearSpeciesSlider(sn: Integer); // sn: slider index
    //function  getSliderIndex(sliderTag: integer): Integer;
    function  getParamSliderIndex(sliderTag: integer): Integer;
    function  getSpeciesSliderIndex(sliderTag: integer): Integer;
    function  getNumberOfParamSliders(): integer;
    function  getNumberOfSpeciesSliders(): integer;
    function  getNumberOfSliders(): integer;
    function  calcSlidersPanelHeight(): integer;
    procedure EditSliderList(sn: Integer);
    procedure SetSliderParamValues(sn, paramForSlider: Integer);
    procedure SetSliderSpeciesValue(sn, speciesForSlider: Integer);
    procedure resetSliderPositions(); // Reset param and species position to init model values.
    procedure resetParSliderPositions(); // Reset param position to init model param value.
    procedure resetSpeciesSliderPositions(); // Reset species position to init model sp value.
    procedure selectParameter(sIndex: Integer); // Get parameter for slider
    procedure selectSpecies(sIndex: Integer); // Get species for slider
    procedure newSliderParamList(); // Pick parameters for sliders
    procedure newSliderSpeciesList(); // Pick species for sliders
    procedure resetSliderSpeciesTags(numOfParSliders: integer); // When num of par sliders changes, need to change sp position tags
    function  checkIfInVarForSlidersList(varToCheck: string): boolean; // see if in inputed list of va ids
    //function  checkIfInSpeciesForSlidersList(speciesToCheck: string): boolean; // see if in inputed list of species
    procedure resetBtnOnLineSim(); // reset to default look and caption of 'Start simulation'
    procedure clearOutModel(); // Clear out previous model/sim, disable appropriate buttons
    function  checkIfModelValid(newModel:TModel): string; // chk If SBML errors or unsupported functions ( events, piecewise, etc)
    procedure runSim();
    procedure runStaticSim();
    procedure stopSim();
    procedure resetSim(); // clear results and set time to 0
    procedure setUpSimulationUI();
    procedure refreshPlotAndSliderPanels();
    procedure refreshPlotPanels();
    procedure refreshSliderPanels();
   // function  getParamsNotAssignedSliders(): TStringArray;
    function  getVarsNotAssignedSliders( sliderIndexAr: array of integer; varNamesAr: array of String): TStringArray;
    procedure addPlot(yMax: double); // Add a plot, yMax: largest initial val of plotted species
    procedure resetPlots();  // Reset plots for new simulation.
    procedure selectPlotSpecies(plotnumb: Integer);
    procedure addPlotAll(); // add plot of all species
    procedure deletePlot(plotIndex: Integer); // Index of plot to delete
    procedure deleteAllPlots();
    function  getEmptyPlotPosition(): Integer;
    function  getPlotPBIndex(plotTag: integer): Integer;
    function  checkIfInSpeciesPlotList(spToCheck: string): boolean;// check if species is in self.spToPlot list
    procedure setListBoxInitValues();
    procedure displayModelInfo();
    procedure displayAbout(strAbout: String);
    procedure setListBoxRateLaws();
    procedure setLabelModelInfo();
    procedure getFileNameFromUser(strDefaultName: string);
    function  enableStepSizeEdit(): boolean; // true: success
    function  disableStepSizeEdit(): boolean;// true: success
    function  enableRunTimeEdit(): boolean;  // true: success
    function  disableRunTimeEdit(): boolean; // true: suncces
    function  enableSimSpeedMult(): boolean;
    function  disableSimSpeedMult(): boolean;
    function  disableSliderEditBtns(): boolean; // true: success, disable param and species btns
    function  enableSliderEditBtns(): boolean; // true: success
    function  disablePlotEditBtn(): boolean; // true: success
    function  enablePlotEditBtn(): boolean; // true: success
    function  disableInfoBtn(): boolean;     // true: success
    function  enableInfoBtn(): boolean;
    procedure setTopPanelSpacing; // Set spacing of components
    procedure setLoadPnlSpacing;
    procedure setRunPausePnlSpacing;
    procedure setSimResetPnlSpacing;
    procedure saveCurrentSimParamVals();
    procedure saveStaticSimRunResults(newResults: TList<TTimeVarNameValList>;
                              parValues: TVarNameValList; saveFileName: string);
    procedure writeSimData(fileName: string; data: TStrings);

    procedure setMinUI(isStaticRun: boolean); // Used when model is passed into app.
    procedure setMaxUI(); // Used when user choses model.
    procedure clearBrowserSessionStorage;
    procedure testUI(); // Used for testing

  public
    fileName: string;
    simStarted: boolean; // true sim has been started
    runTime: double;
    currentGeneration: Integer; // Used by plots as current x axis point
    fPlotSpecies: TVarSelectForm;
    plotSpecies: TList<TSpeciesList>; // species list to graph for each plot
    graphPanelList: TList<TGraphPanel>; // Panels in which each plot resides

    fSliderParameter: TVarSelectForm;// Pop up form to choose parameter for slider.
    sliderParamAr: array of Integer;// holds parameter array index (p_vals) of parameter to use for each slider
    pnlSliderParamAr: array of TPnlParamSlider; // Holds parameter sliders, Change class to TPnlSlider

    fSliderSpecies: TVarSelectForm;// Pop up form to choose species for slider.
    sliderSpeciesAr: array of Integer;// holds species array index (s_vals) of species to use for each slider
    pnlSliderSpeciesAr: array of TPnlParamSlider; // Holds species sliders, Change class to TPnlSlider

   // sliderEditPopupsList: TList<TWebPopupMenu>; // Not in use
    strFileInput: string;  // File name that may be passed to form.

    // Displays slider param name and current value
    paramUpdated: Boolean; // true if a parameter has been updated.
    mainController: TControllerMain;
    procedure SliderOnMouseDown(Sender: TObject; Button: TMouseButton;
                                Shift: TShiftState; X, Y: Integer);

    procedure PingSBMLLoaded(newModel:TModel); // Notify when done loading or model changes
    procedure getVals( newTime: Double; newVals: TVarNameValList);// Get new values (species amt) from simulation run
    procedure getStaticSimResults ( newResults: TList<TTimeVarNameValList> ); // static Sim results/
    procedure processGraphEvent(plotPosition: integer; editType: integer); // not currently necessary
  end;

var
  MainForm: TMainForm;
  

implementation

{$R *.dfm}


procedure TMainForm.btnAboutClick(Sender: TObject);
var infoStr: string;
begin
infoStr := SIDEWINDER_VERSION + sLineBreak;
infoStr := infoStr + COPYRIGHT + sLineBreak + GRANT_INFO;
 // notifyUser(infoStr);
  self.displayAbout(infoStr);
end;

procedure TMainForm.btnEditGraphClick(Sender: TObject);
var fEditgraph: TfChkGroupEditPlot;
    indexChosen: integer;

  procedure AfterShowModal(AValue: TModalResult);
  begin
   // NOTHING for now.ok, thanks

  end;

  procedure processUserCheck(Sender: TObject;  AIndex: Integer);
  begin
    indexChosen := AIndex;
    if assigned(self.graphPanelList[0]) then
     begin
     case indexChosen of
       0: self.graphPanelList[0].toggleLegendVisibility;
       1: self.graphPanelList[0].toggleAutoScaleYaxis;
      { 2: begin
          self.deletePlot(0);
          self.selectPlotSpecies(1); // want position
          fEditGraph.uncheckEditPlotSpecies;
          end;}
       end;
     end;
  end;



  procedure okClick(Sender: TObject);
  var lForm: TfChkGroupEditPlot;
      yMin, yMax: double;
  begin
    lForm := TfChkGroupEditPlot((Sender as TWebButton).Parent);
    yMin := lForm.getEditYMin;
    yMax := lForm.getEditYMax;
    if assigned(self.graphPanelList[0]) then
      self.graphPanelList[0].updateYMinMax(yMin, yMax);
    lForm.Close;
    lForm.Free;
  end;

  procedure changePlotSpClick(Sender: TObject);
  begin
    if assigned(self.graphPanelList[0]) then
      begin
      self.deletePlot(0);  // plot index
      self.selectPlotSpecies(1); // want plot position
      end;
  end;

  procedure AfterCreate(AForm: TObject);
  begin
   (AForm as TfChkGroupEditPlot).chkGrpEditPlot.OnCheckClick := processUserCheck;
   (AForm as TfChkGroupEditPlot).btnOkPlotEdit.OnClick := okClick;
   (AForm as TfChkGroupEditPlot).btnChangePlotSp.OnClick := changePlotSpClick;
   if assigned(self.graphPanelList[0]) then
    begin
    (AForm as TfChkGroupEditPlot).editYAxisMax.Text := floattostr(self.graphPanelList[0].getYMax);
    (AForm as TfChkGroupEditPlot).editYAxisMin.Text := floattostr(self.graphPanelList[0].getYMin);
    if self.graphPanelList[0].isLegendVisible then (AForm as TfChkGroupEditPlot).checkLegendVisible
    else (AForm as TfChkGroupEditPlot).uncheckLegendInvisible;

    if self.graphPanelList[0].isAutoScale then (AForm as TfChkGroupEditPlot).checkAutoscale
    else (AForm as TfChkGroupEditPlot).uncheckAutoscale;
    end;
  end;

begin
  indexChosen := -1;
  fEditgraph := TfChkGroupEditPlot.CreateNew(@AfterCreate);
  fEditgraph.Popup := true;
  fEditgraph.ShowClose := true;
  fEditgraph.ShowModal(@AfterShowModal);
  fEditgraph.PopupOpacity := 0.3;
  //fEditgraph.Border := fbDialogSizeable;
end;


procedure TMainForm.btnEditSlidersClick(Sender: TObject);
begin
  self.newSliderParamList;
end;

procedure TMainForm.btnEditSpSlidersClick(Sender: TObject);
begin
  self.newSliderSpeciesList;
end;

procedure TMainForm.btnExampleClick(Sender: TObject);

var s : string;
begin
  s := getTestModel(1);
 { if DEBUG then
    begin
    SBMLmodelMemo.Lines.Text := s;
    SBMLmodelMemo.visible := true;
    end;  }
  SBMLOpenDialogGetFileAsText( nil, 0, s);
end;

procedure TMainForm.btnLoadModelClick(Sender: TObject);
begin
  self.SBMLOpenDialog.execute();
end;

procedure TMainForm.btnModelInfoClick(Sender: TObject);
begin
  self.displayModelInfo();
end;

procedure TMainForm.btnSavePlotResultsClick(Sender: TObject);
begin
  //fileName := InputBox('Save last simulation data to the Downloads directory',
  //  'Enter File Name:', 'newSimResults.csv');
  fileName := 'newSimResults.csv';
  self.getFileNameFromUser(fileName);
  {if fileName <> '' then
    begin
      self.saveStaticSimRunResults(self.lastStaticSimData, self.lastStaticSimParVals, fileName);
      //self.writeSimData(fileName, newData);
    end
  else
    notifyUser('Save cancelled'); }
end;

procedure TMainForm.btnRunPauseClick(Sender: TObject);
begin
  if self.MainController.IsModelLoaded then
  begin
    try
      self.disableStepSizeEdit;
      if MainController.isOnline = false then
        begin
      //  self.btnEditGraph.Enabled := false;
      //  self.btnEditGraph.ElementClassName := BTN_DISABLED;
      //  self.btnEditSliders.Enabled := false;
      //  self.btnEditSliders.ElementClassName := BTN_DISABLED;
        if self.chkbxStaticSimRun.Checked then
          begin
          self.resetSim;  // this stops current sim.
          if assigned(self.graphPanelList) then self.resetPlots;
          end
        else self.chkbxStaticSimRun.Enabled := false;
        self.runSim;
        end
      else  // stop simulation
        begin
        self.stopSim;
        self.chkbxStaticSimRun.Enabled := true;
        end;
    except
      on E: Exception do
        notifyUser(E.Message);
    end;
  end
  else notifyUser('Model not loaded, please load model or refresh browser window.');
end;


procedure TMainForm.btnSimResetClick(Sender: TObject);
begin   // Reset sim to original model settings/values
  try
  self.resetSliderPositions();
  self.enableStepSizeEdit;
  self.resetSim; // Uses current param and init vals, if they exist
  self.mainController.resetSimParamValues;  // Reload orig model vals
  self.mainController.resetSimSpeciesValues;
  self.resetPlots;
  except
    on E: Exception do
      notifyUser('Error resetting simulation, refresh browser.');

  end;
end;

procedure TMainForm.resetSim();
begin  // Uses current param vals and init vals, does not reload orig model vals
  try
    self.enableStepSizeEdit;
    if self.chkbxStaticSimRun.Checked then
      begin
      self.stopSim;
      self.btnRunPause.Enabled := true;
      self.btnRunPause.ElementClassName := BTN_ENABLED;
      end;
    self.mainController.createSimulation();

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

  self.clearOutModel; // get rid of previous model, if exists
  self.MainController.loadSBML(AText);
end;

procedure TMainForm.clearOutModel();
begin
  self.currentModelInfo := 'None.';
  self.deleteAllPlots;
  self.deleteAllSliders;
  self.resetBtnOnLineSim;
  self.simStarted := false;
  self.mainController.clearModel;
  self.mainController.clearSim;
  self.btnSimReset.enabled := false;
  self.btnSimReset.ElementClassName := BTN_DISABLED;
end;

procedure TMainForm.WebFormCreate(Sender: TObject);
var sRun: boolean;
begin
  self.debug := false;
  sRun := true; // Default to static.
  self.chkbxStaticSimRun.Checked := true;
  self.numbPlots := 0;
  self.slidersPerRow := SLIDERS_PER_ROW;
  if sRun then
    self.runTime := DEFAULT_STATICRUN
  else self.runTime := DEFAULT_RUNTIME;
  self.setTopPanelSpacing;
  self.intSliderHeight := 35;
  self.pnlSliders.height := 5;
  self.stepSize := 0.1;
  self.edtStepSize.Text := floatToStr(self.stepSize * 1000);
  self.disableRunTimeEdit;
  self.simStarted := false;
 // self.sliderEditPopupsList := TList<TWebPopupMenu>.create; // Not in use
  self.mainController := TControllerMain.Create();
  self.mainController.setOnline(false);
  self.mainController.setODEsolver;
 // self.saveSimResults := false;
  self.currentGeneration := 0;
  self.currentModelInfo := 'None.';
  self.disableInfoBtn;
  self.disablePlotEditBtn;
  self.disableSliderEditBtns;
  self.btnSavePlotResults.Enabled := false;
  self.btnSavePlotResults.ElementClassName := BTN_DISABLED;
  self.strFileInput := '';
  self.xAxisLabel := '';
  self.yAxisLabel := '';
  self.spToPlot := '';
  self.varForSliders := '';     // List of par sliders specified at runtime
 // self.speciesForSliders := ''; // List of species sliders specified at runtime

  asm // javascript:
    var newModel = sessionStorage.getItem("MODEL");
    var newRT = parseFloat(sessionStorage.getItem("RUNTIME"));
    if(newRT > 0) {
      this.runTime = newRT;
    }
    //console.log('Runtime passed in: ',sessionStorage.getItem("RUNTIME"));
    var newSS = parseFloat(sessionStorage.getItem("STEPSIZE"));
    if(newSS > 0) {
      this.stepSize = newSS;
    }
    if( this.debug ) {
      console.log('Stepsize passed in: ',sessionStorage.getItem("STEPSIZE"));}

    // Three values for staticRun:
    // 'false': Only Plot updates during run
    // 'true': Only plots at end of run.
    // '' : allows both static and plot updates during run
    var staticRun = sessionStorage.getItem("STATIC");
    if( staticRun != null ) {
      if(staticRun.toUpperCase() == 'TRUE') {
        //console.log(' Static run');
        sRun = true;
      }
      if( (staticRun.toUpperCase() == 'FALSE') || (staticRun == '')  ) {
        if( this.debug ) {console.log(' Plot during run');}
        sRun = false;
      }

    }
   if( this.debug ){ console.log('Static run? passed in: ',sessionStorage.getItem("STATIC"));}
    if(sessionStorage.getItem("SLIDERS") != null) {
      this.varForSliders = sessionStorage.getItem("SLIDERS");
      }
    if(sessionStorage.getItem("PLOT_SPECIES") != null) {
      this.spToPlot = sessionStorage.getItem("PLOT_SPECIES");
      }
    if(sessionStorage.getItem("X_LABEL") != null) {
      this.xAxisLabel = sessionStorage.getItem("X_LABEL");
    }
    else { this.xAxisLabel = 'unit time'; } // Default

    if(sessionStorage.getItem("Y_LABEL") != null) {
      this.yAxisLabel = sessionStorage.getItem("Y_LABEL");
    } else { this.yAxisLabel = 'Conc'; } // default


    this.strFileInput = newModel;
  end;
   // Assume sbml model. XML format. May need to parse later for other formats.
  if assigned(self.strFileInput) and (self.strFileInput <> '') then
    begin
    if self.debug then console.log('File passed in: ', self.strFileInput);
    // Update runtime and stepsize:
    if length(self.strFileInput) > 20 then // assumed model larger than 20 chars
      begin
      self.edtStepSize.Text := floatToStr(self.stepSize * 1000);
      if assigned(self.btnLoadModel) then self.btnLoadModel.Enabled := false;  // Do not allow user to load adifferent model.
      self.SBMLOpenDialogGetFileAsText( nil, 0, self.strFileInput);
      self.setMinUI(sRun);
      end
    else
      begin
      if self.debug then console.log('No model loaded, model string less than 20 chars');
      self.setMaxUI;
      end;

    end
  else self.setMaxUI;

  if sRun then
    begin
    self.enableRunTimeEdit;
    self.chkbxStaticSimRun.Checked := true;
    self.chkbxStaticSimRunClick(nil);
    end;
  if assigned(self.pnlRunTime) then
    self.editRunTime.Text := floatToStr(self.runTime);
  self.btnSimReset.Visible := true;
  self.btnSimReset.Enabled := false;
  self.btnSimReset.ElementClassName := BTN_DISABLED;
  self.btnRunPause.Enabled := false;
  self.btnRunPause.ElementClassName := BTN_DISABLED;
  if assigned(self.pnlSimSpeedMult) then self.trackBarSimSpeed.Enabled := false;
  self.enableStepSizeEdit;
  if not self.debug then self.pnlExample.Free;
  self.mainController.addSBMLListener( @self.PingSBMLLoaded );
  self.mainController.addSimListener( @self.getVals ); // notify when new Sim results
  self.mainController.addStaticSimResultsListener( @self.getStaticSimResults ); // notify when static run done.
 // console.log('Species to Plot: ', self.spToPlot);
 // console.log(' Length of spToPlot: ', length(self.spToPlot));
  self.clearBrowserSessionStorage;

end;


procedure TMainForm.WebFormDestroy(Sender: TObject);
begin
  self.clearBrowserSessionStorage;
  console.log(' On form destroy..');
end;

procedure TMainForm.WebFormExit(Sender: TObject);
begin
  self.clearBrowserSessionStorage;
  console.log(' On form exit..');
end;

procedure TMainForm.WebFormResize(Sender: TObject);
begin
  //console.log('Changing');
  self.refreshPlotAndSliderPanels;
  self.setTopPanelSpacing;
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

procedure TMainForm.oggleautoscale1Click(Sender: TObject);
var i: integer;
begin
 // console.log( ' autoscale y axis');

  if Sender is TMenuItem then
    begin
  //  console.log('Menu Item');
    i := TMenuItem(Sender).tag -1; // want index.
    if i > -1 then
      begin
      self.graphPanelList[i].toggleAutoScaleYaxis;
      end
    else console.log('Bad index number TMainForm.oggleautoscale1Click');
    end;


end;

procedure TMainForm.editPlot1Click(Sender: TObject);
var i: integer;
begin
  if Sender is TMenuItem then
    begin
   // console.log('Menu Item');
    i := TMenuItem(Sender).tag -1; // want index.
    if i > -1 then
      begin
      btnEditGraphClick(Sender);
      //self.graphPanelList[i].toggleLegendVisibility;
      end
    else console.log('Bad index number TMainForm.editPlot1Click');
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
            self.EditSliderList(i{, X, Y});
          end;
      end;
  end;

procedure TMainForm.addParamSlider(); // assume slider index is at last position, otherwise it is just an edit.
// default TBar range: 0 to initVal*10
var i, j, sliderTBarWidth, sliderPanelLeft, sliderPanelWidth: integer;
    sliderTop: Integer;
    newMenu: TMenuItem;
begin
  i := self.getNumberOfParamSliders; // array index for current slider to be added.
  SetLength(self.pnlSliderParamAr, i + 1);
  sliderTop := self.calcSliderTop(i);
  // Left most position of the panel that holds the slider
  sliderPanelLeft := self.calcSliderLeft(i);
  sliderPanelWidth := self.calcSliderWidth;

  self.pnlSliderParamAr[i] := TpnlParamSlider.create(self.pnlSliders, i,{ @self.EditSliderList,}
                                                @self.paramSliderOnChange );

 // self.sliderEditPopupsList.Add(TWebPopupMenu.Create(self)) ;  // Do not use mouse click popup

 // newMenu := TMenuItem.Create(self.sliderEditPopupsList[i]);
 // newMenu.tag := i + 1; // tag slider position
 // newMenu.Caption := 'Change parameter';
//  newMenu.OnClick := self.ChangeParameter1Click;
//  self.sliderEditPopupsList[i].Items.add(newMenu);
//  self.sliderEditPopupsList[i].Parent := self;
//  self.pnlSliderParamAr[i].PopupMenu := self.sliderEditPopupsList[i] ;
 // console.log(' popup parent: ', self.sliderEditPopupsList[i].Parent);

  self.pnlSliderParamAr[i].configPSliderPanel(sliderPanelLeft, sliderPanelWidth, self.intSliderHeight, sliderTop);
  self.SetSliderParamValues(i, self.sliderParamAr[i]);
  self.pnlSliderParamAr[i].configPSliderTBar;
end;

procedure TMainForm.addAllParamSliders();
var i, numParSliders: integer;
    sliderP: string;
    bSliderInList: boolean; // Use to check if prepopulated list has par in actual model.
begin
  bSliderInList := false;
  numParSliders := 0;
  numParSliders := length(self.mainController.getModel.getP_Names);
 // console.log('AddAllParamSliders: Length of varForSliders: ',length(self.varForSliders));
  for i := 0 to numParSliders -1 do
    begin
    sliderP := '';
    // CHeck if param on init slider list:
    sliderP := self.mainController.getModel.getP_Names[i];
    if (self.checkIfInVarForSlidersList(sliderP)) or (length(self.varForSliders) < 1) then
      begin
      bSliderInList := true;
      if self.getNumberOfParamSliders < Max_PARAMETER_SLIDERS then
        begin
        SetLength(self.sliderParamAr, length(self.sliderParamAr) + 1);    // add a slider
        self.sliderParamAr[length(self.sliderParamAr)-1] := i; // assign param index to slider
        self.addParamSlider(); // <-- Add dynamically created slider
        end;
      end;
    end;
//  self.varForSliders := ''; // clear it out
  if (not bSliderInList) and  (length(self.varForSliders) < 1)
    then self.addAllParamSliders; // No param sliders added and prepopulated list is empty.

end;

procedure TMainForm.addAllSpeciesSliders(); // add sliders without user intervention.
var i, numSp: integer;
    sliderS: string;
    bSliderInList: boolean; // Use to check if prepopulated list has par in actual model.
begin
  bSliderInList := false;
  numSp := 0;
  numSp := length(self.mainController.getModel.getS_Names);
 // console.log('AddAllApeciesSliders: Length of speciesForSliders: ',length(self.speciesForSliders));
  for i := 0 to numSp -1 do
    begin
    sliderS := '';
    // CHeck if param on init slider list:
    sliderS := self.mainController.getModel.getS_Names[i];
    if (self.checkIfInVarForSlidersList(sliderS)) or (length(self.varForSliders) < 1)  then
  //  if (self.checkIfInVarForSlidersList(sliderS)) or (self.getNumberOfParamSliders < 1) then
      begin
      bSliderInList := true;
      if self.getNumberOfSpeciesSliders < (MAX_SLIDERS - self.getNumberOfParamSliders) then
        begin
        SetLength(self.sliderSpeciesAr, length(self.sliderSpeciesAr) + 1);    // add a slider
        self.sliderSpeciesAr[length(self.sliderSpeciesAr)-1] := i; // assign param index to slider
        self.addSpeciesSlider(); // <-- Add dynamically created slider
        end;
      end;
    end;

 // if (not bSliderInList) and  (length(self.varForSliders) < 1)    ???? why is thi here ?
 //   then self.addAllSpeciesSliders; // No sliders added and prepopulated list is empty.
  self.varForSliders := ''; // clear it out, assumes all par sliders have been set up

end;

procedure TMainForm.addSpeciesSlider();  // Species slider added after all of the param sliders
// default TBar range: 0 to initVal*10
var i, j, sliderTBarWidth, sliderPanelLeft, sliderPanelWidth: integer;
    sliderTop: Integer;
    sliderIndex: Integer; // Index to current slider ( param slider + species Slider).
    newMenu: TMenuItem;
begin
  i := self.getNumberOfSpeciesSliders; // array index for current slider to be added.
  sliderIndex := self.getNumberOfParamSliders + i; // index for next position for all of sliders,
  SetLength(self.pnlSliderSpeciesAr, i + 1);
  sliderTop := self.calcSliderTop(sliderIndex);
  // Left most position of the panel that holds the slider
  sliderPanelLeft := self.calcSliderLeft(sliderIndex);
  sliderPanelWidth := self.calcSliderWidth;

  self.pnlSliderSpeciesAr[i] := TpnlParamSlider.create(self.pnlSliders, sliderIndex,{ @self.EditSliderList,}
                                                @self.speciesSliderOnChange );

 // self.sliderEditPopupsList.Add(TWebPopupMenu.Create(self)) ; // do not use mouse-click popup.

 // newMenu := TMenuItem.Create(self.sliderEditPopupsList[i]);
 // newMenu.tag := i + 1; // tag slider position
 // newMenu.Caption := 'Change species';
 // newMenu.OnClick := self.ChangeParameter1Click;
 // self.sliderEditPopupsList[i].Items.add(newMenu);
 // self.sliderEditPopupsList[i].Parent := self;
 // self.pnlSliderAr[i].PopupMenu := self.sliderEditPopupsList[i] ;
 // console.log(' popup parent: ', self.sliderEditPopupsList[i].Parent);
  self.pnlSliderSpeciesAr[i].setBackgroundColor(clCream);
  self.pnlSliderSpeciesAr[i].configPSliderPanel(sliderPanelLeft, sliderPanelWidth, self.intSliderHeight, sliderTop);
  self.SetSliderSpeciesValue(i, self.sliderSpeciesAr[i]);
  self.pnlSliderSpeciesAr[i].configPSliderTBar;
end;


function TMainForm.checkIfInVarForSlidersList(varToCheck: string): boolean;
var i: integer;
    parList: array of string;
begin
  Result := false;
  parList := splitString(self.varForSliders, ',');
  for i := 0 to length(parList) -1 do
    begin
    if varToCheck = parList[i].Trim then
      Result := true;
    end;
end;


procedure TMainForm.newSliderParamList ();
var fSelectParams: TVarSelectForm;
   // Pass back to caller after closing popup:
  procedure AfterShowModal(AValue: TModalResult);
  var
    i, sliderIndex: Integer; slidersUpdated: boolean;
    sliderPar: string;
  begin
    slidersUpdated := false;
    for i := 0 to fSelectParams.SpPlotCG.Items.Count - 1 do // chk if user wants new list.
      begin
        if fSelectParams.SpPlotCG.checked[i] then slidersUpdated := true;
      end;
    if slidersUpdated then
      begin
      self.deleteAllParamSliders;
      for i := 0 to fSelectParams.SpPlotCG.Items.Count - 1 do
        begin
        sliderPar := '';
        if fSelectParams.SpPlotCG.checked[i] then
          begin
          if length(self.sliderParamAr) < MAX_PARAMETER_SLIDERS then // Ignore any more that are checked.
            begin
            sliderIndex := length(self.sliderParamAr);
            SetLength(self.sliderParamAr, length(self.sliderParamAr) + 1);
            self.sliderParamAr[sliderIndex] := i; // assign param index to slider
            self.addParamSlider(); // <-- Add dynamically created slider
            end;
          end;
        end;
      end;
    self.resetSliderSpeciesTags(self.getNumberOfParamSliders);
    self.refreshSliderPanels;
  end;

  // async, call for TVarSelectForm
  procedure AfterCreate(AForm: TObject);
  var i, lgth: integer;
     strList: array of String;
     curStr: string;
  begin
    lgth := 0;
    for i := 0 to length(self.mainController.getModel.getP_Names) -1 do
    begin
      curStr := '';
      curStr := self.mainController.getModel.getP_names[i];
      lgth := Length(strList);
      setLength(strList, lgth + 1);
      strList[lgth] := curStr;
    end;
    (AForm as TVarSelectForm).Top := trunc(self.Height*0.1); // put popup %10 from top
    (AForm as TVarSelectForm).speciesList := strList;
    (AForm as TVarSelectForm).ParentFormHeight := self.Height;
    (AForm as TVarSelectForm).fillSpeciesCG();
  end;

begin
  fSelectParams := TVarSelectForm.CreateNew(@AfterCreate);
  fSelectParams.Popup := true;
  fSelectParams.ShowClose := false;
  fSelectParams.PopupOpacity := 0.3;
  fSelectParams.Border := fbDialogSizeable;
  fSelectParams.Caption := 'Replace Paramater sliders';
  fSelectParams.ShowModal(@AfterShowModal);
end;

procedure TMainForm.newSliderSpeciesList(); // Pick species for sliders
var fSelectSpecies: TVarSelectForm;
   // Pass back to caller after closing popup:
  procedure AfterShowModal(AValue: TModalResult);
  var
    i, sliderIndex: Integer; slidersUpdated: boolean;
    //sliderSp: string;
  begin
    slidersUpdated := false;
    for i := 0 to fSelectSpecies.SpPlotCG.Items.Count - 1 do // chk if user wants new list.
      begin
        if fSelectSpecies.SpPlotCG.checked[i] then slidersUpdated := true;
      end;
    if slidersUpdated then
      begin
      self.deleteAllSpeciesSliders;
      for i := 0 to fSelectSpecies.SpPlotCG.Items.Count - 1 do
        begin
        //sliderSp := '';
        if fSelectSpecies.SpPlotCG.checked[i] then
          begin
          if length(self.sliderSpeciesAr) < (MAX_SLIDERS - self.getNumberOfParamSliders) then // Ignore any more that are checked.
            begin
            sliderIndex := length(self.sliderSpeciesAr);
            SetLength(self.sliderSpeciesAr, length(self.sliderSpeciesAr) + 1);
            self.sliderSpeciesAr[sliderIndex] := i; // assign param index to slider
            self.addSpeciesSlider(); // <-- Add dynamically created slider
            end;
          end;
        end;
      end;

  end;

  // async, call for TVarSelectForm
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
      lgth := Length(strList);
      setLength(strList, lgth + 1);
      strList[lgth] := curStr;
    end;
    (AForm as TVarSelectForm).Top := trunc(self.Height*0.1); // put popup %10 from top
    (AForm as TVarSelectForm).speciesList := strList;
    (AForm as TVarSelectForm).ParentFormHeight := self.Height;
    (AForm as TVarSelectForm).fillSpeciesCG();
  end;

begin
  fSelectSpecies := TVarSelectForm.CreateNew(@AfterCreate);
  fSelectSpecies.Popup := true;
  fSelectSpecies.ShowClose := false;
  fSelectSpecies.PopupOpacity := 0.3;
  fSelectSpecies.Border := fbDialogSizeable;
  fSelectSpecies.Caption := 'Replace species sliders';
  fSelectSpecies.ShowModal(@AfterShowModal);
end;


procedure TMainForm.resetSliderSpeciesTags(numOfParSliders: integer);
var i: integer; // When num of par sliders changes, need to change sp position tags.
begin           // Assumes species sliders come after param sliders.
for i := 0 to self.getNumberOfSpeciesSliders -1 do
  begin
  self.pnlSliderSpeciesAr[i].Tag := numOfParSliders + i ;
  end;
end;


function TMainForm.calcSliderWidth(): integer;
begin
   if(round(self.pnlSliders.Width/self.slidersPerRow) > 120 ) then
    Result := round( (self.pnlSliders.width)/self.slidersPerRow )   // four sliders across
  else Result := 120;
end;

procedure TMainForm.ChangeParameter1Click(Sender: TObject);
var i: integer;
begin
  console.log( ' Change slider parameter');
  if Sender is TMenuItem then
    begin
    i := TMenuItem(Sender).tag -1; // want index.
    if i > -1 then
      self.selectParameter(i);
    end;
end;

function TMainForm.calcSliderLeft(index: integer): integer;
var
  i: Integer;
  modVal: Integer;
begin

  if index = 0 then Result := 1
  else
    begin
    modVal := index mod self.slidersPerRow;
    if modVal = 0 then Result := 1
    else
      begin
      for i := 0 to self.slidersPerRow -1 do
        begin
        if modVal = i then
          Result := i * self.calcSliderWidth ;
        end;
      end;
    end;

end;

function TMainForm.calcSliderTop(index: integer): integer;
var numRows: integer;
begin
  if index = 0 then numRows := 1
  else
    begin
    numRows := (index + 1) div self.slidersPerRow;
    if (index + 1) mod self.slidersPerRow > 0 then inc(numRows);
    end;
 // console.log('Rows: ', numRows);
  Result := (numRows - 1) * self.intSliderHeight{ SLIDERPHEIGHT};
end;

function  TMainForm.getNumberOfSliders(): integer;// WHY? just get length()
var i: integer;
begin
  i := 0;
  if self.pnlSliderParamAr <> nil then
    i := length(self.pnlSliderParamAr);
  if self.pnlSliderSpeciesAr <> nil then
    i := i + length(self.pnlSliderSpeciesAr);
  Result := i;
end;

function  TMainForm.getNumberOfParamSliders(): integer;// WHY? just get length()
begin
  if self.pnlSliderParamAr <> nil then
    Result := length(self.pnlSliderParamAr)
  else  Result := 0;
end;

function  TMainForm.getNumberOfSpeciesSliders(): integer;// WHY? just get length()
begin
  if self.pnlSliderSpeciesAr <> nil then
   Result := length(self.pnlSliderSpeciesAr)
  else Result := 0;
end;

// Called when adding or updating a param slider. sn = slider index
procedure TMainForm.SetSliderParamValues(sn, paramForSlider: Integer);
var
  rangeMult: Integer;
  pVal:Double;
  pName: String;
begin
  rangeMult := SLIDER_RANGE_MULT; //10; // default.
  pName :=  self.mainController.getModel.getP_Names[paramForSlider{self.sliderParamAr[sn]}];
  pVal := self.mainController.getModel.getP_Vals[paramForSlider{self.sliderParamAr[sn]}];
  self.pnlSliderParamAr[sn].setUpSliderVals(pName, pVal);
end;

procedure TMainForm.SetSliderSpeciesValue(sn, speciesForSlider: Integer);
var
  rangeMult: Integer;
  sVal:Double;
  sName: String;
begin
  rangeMult := SLIDER_RANGE_MULT; // default.
  sName :=  self.mainController.getModel.getS_Names[speciesForSlider{self.sliderSpeciesAr[sn]}];
  sVal := self.mainController.getModel.getS_Vals[speciesForSlider{self.sliderSpeciesAr[sn]}];
  self.pnlSliderSpeciesAr[sn].setUpSliderVals(sName + ' init val', sVal);
end;

procedure TMainForm.resetSliderPositions();
begin
  self.resetParSliderPositions;
  self.resetSpeciesSliderPositions;
end;

procedure TMainForm.resetParSliderPositions(); // Reset param position to init model param value.
var pVal: double; i: integer;
    pName: string;
begin
  for i := 0 to length(self.pnlSliderParamAr) - 1 do
    begin
      pName :=  self.mainController.getModel.getP_Names[self.sliderParamAr[i]];
      pVal := self.mainController.getModel.getP_Vals[self.sliderParamAr[i]];
      self.pnlSliderParamAr[i].setUpSliderVals( pName, pVal );
    end;
end;

procedure TMainForm.resetSpeciesSliderPositions(); // Reset species position to init model sp value.
var sVal: double; i: integer;
    sName: string;
begin
  for i := 0 to length(self.pnlSliderSpeciesAr) - 1 do
    begin
      sName :=  self.mainController.getModel.getS_Names[self.sliderSpeciesAr[i]];
      sVal := self.mainController.getModel.getS_Vals[self.sliderSpeciesAr[i]];
      self.pnlSliderSpeciesAr[i].setUpSliderVals( sName + ' init val', sVal );
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

      newPVal := self.pnlSliderParamAr[i].getSliderPosition * 0.01 *
        (self.pnlSliderParamAr[i].getSliderHighVal - self.pnlSliderParamAr[i].getSliderLowVal);

      if self.mainController.IsOnline then
        begin
          self.MainController.stopTimer;
          isRunning := true;
        end;
      self.MainController.changeSimParameterVal( p, newPVal );
      if isRunning and (not self.chkbxStaticSimRun.Checked) then self.MainController.startTimer;

      self.pnlSliderParamAr[i].setTrackBarLabel(self.MainController.getModel.getP_Names[self.sliderParamAr[i]] + ': '
                                                         + FloatToStr(newPVal) );
      if self.chkbxStaticSimRun.Checked then
        begin
        self.currentGeneration := 0;
        if assigned(self.graphPanelList) then self.resetPlots;
        self.MainController.changeSimParameterVal( p, newPVal );
        self.mainController.setCurrTime(self.currentGeneration);
        self.runStaticSim;

        end;
    end;
end;

procedure TMainForm.SpeciesSliderOnChange(Sender: TObject);  // pass this in to upnlParamSlider.OnChange ?
var
  index, i, S: Integer;
  newSVal: double;
  isRunning: boolean;
begin
  if Sender is TWebTrackBar then
    begin
      newSVal := 0;
      isRunning := false; // simulation not active.
      index := TWebTrackBar(Sender).tag;
      i := index - self.getNumberOfParamSliders;
      self.MainController.speciesUpdated := true;
      s := self.sliderSpeciesAr[i];  // get species position to update values
      newSVal := self.pnlSliderSpeciesAr[i].getSliderPosition * 0.01 *
        (self.pnlSliderSpeciesAr[i].getSliderHighVal - self.pnlSliderSpeciesAr[i].getSliderLowVal);

      if self.mainController.IsOnline then
        begin
          self.MainController.stopTimer;
          isRunning := true;
        end;
      self.MainController.changeSimSpeciesVal( s, newSVal );
      if isRunning and (not self.chkbxStaticSimRun.Checked) then self.MainController.startTimer;

      self.pnlSliderSpeciesAr[i].setTrackBarLabel(self.MainController.getModel.getS_Names[self.sliderSpeciesAr[i]] + ' init val: '
                                                         + FloatToStr(newSVal) );
      if self.chkbxStaticSimRun.Checked then
        begin
        self.currentGeneration := 0;
        if assigned(self.graphPanelList) then self.resetPlots;
        self.MainController.changeSimSpeciesVal( s, newSVal );
        self.mainController.setCurrTime(self.currentGeneration);
        self.runStaticSim;

        end;
    end;
end;

// Select parameter to use for slider  : pass this method to upnlParamSlider.onMouseClick
procedure TMainForm.selectParameter(sIndex: Integer); // sIndex is slider index
var
  paramIndex: Integer; // param chosen in radiogroup
  // Pass back to caller after closing popup:
  procedure AfterShowModal(AValue: TModalResult);
  var
    i, j:Integer;
    addingSlider: Boolean;
    sliderP: string;
  begin
    addingSlider := false;
    sliderP := '';
    if sIndex > length(self.sliderParamAr) -1 then
      addingSlider := true
    else addingSlider := false; // Changing existing param slider,

    for i := 0 to fSliderParameter.SpPlotCG.Items.Count - 1 do
      begin
        sliderP := '';
        if fSliderParameter.SpPlotCG.checked[i] then
          begin
            j := self.mainController.getModel.findIndexForParamStr(fSliderParameter.speciesList[i]);
            if addingSlider then
              begin         // need to get correct param index
              SetLength(self.sliderParamAr, length(self.sliderParamAr) + 1);    // add a slider
              self.sliderParamAr[length(self.sliderParamAr) -1] := j {i}; // assign param index from param array to slider
              end;
            if not addingSlider then
              begin
              self.clearSlider(sIndex);
              self.sliderParamAr[getParamSliderIndex(sIndex)] := -1; // Clear param location in param Array
              self.sliderParamAr[sIndex] := j {i}; // assign param index from param array to slider
              self.SetSliderParamValues(sIndex, self.sliderParamAr[sIndex]);
              self.pnlSliderParamAr[sIndex].Visible := true;
              self.pnlSliderParamAr[sIndex].Invalidate;
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
  var paramList: array of string;
  begin
    (AForm as TVarSelectForm).ParentFormHeight := self.Height;
    (AForm as TVarSelectForm).Top := trunc(self.Height*0.2); // put popup %20 from top
    if length(self.mainController.getModel.getP_Names) > MAX_PARAMETER_SLIDERS then
      //(AForm as TVarSelectForm).speciesList := self.getParamsNotAssignedSliders
      (AForm as TVarSelectForm).speciesList :=
          self.getVarsNotAssignedSliders( self.sliderParamAr, self.mainController.getModel.getP_Names )
    else (AForm as TVarSelectForm).speciesList := self.mainController.getModel.getP_Names;
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

// Select species to use for slider  : pass this method to upnlSpeciesSlider.onMouseClick
procedure TMainForm.selectSpecies(sIndex: Integer); // sIndex is slider index
var
  speciesIndex: Integer; // species chosen in radiogroup
  // Pass back to caller after closing popup:
  procedure AfterShowModal(AValue: TModalResult);
  var
    i, j:Integer;
    addingSlider: Boolean;
    sliderS: string;
  begin
    addingSlider := false;
    sliderS := '';
    if sIndex > length(self.sliderSpeciesAr) -1 then
      addingSlider := true
    else addingSlider := false; // Changing existing slider,

    for i := 0 to fSliderSpecies.SpPlotCG.Items.Count - 1 do
      begin
        sliderS := '';
        if fSliderSpecies.SpPlotCG.checked[i] then
          begin
            j := self.mainController.getModel.findIndexForSpeciesStr(fSliderSpecies.speciesList[i]);
            if addingSlider then
              begin         // need to get correct param index
              SetLength(self.sliderSpeciesAr, length(self.sliderSpeciesAr) + 1);    // add a slider
              self.sliderSpeciesAr[length(self.sliderSpeciesAr) -1] := j ; // assign index from species array to slider
              end;
            if not addingSlider then
              begin
              self.clearSlider(sIndex);
              self.sliderSpeciesAr[getSpeciesSliderIndex(sIndex)] := -1; // Clear location in species Array
              self.sliderSpeciesAr[sIndex] := j {i}; // assign index from species array to slider
              self.SetSliderSpeciesValue(sIndex, self.sliderSpeciesAr[sIndex]);
              self.pnlSliderSpeciesAr[sIndex].Visible := true;
              self.pnlSliderSpeciesAr[sIndex].Invalidate;
              end
            else
              begin
              self.addSpeciesSlider(); // <-- Add dynamically created slider to end of array
              end;

          end;

      end;

  end;

// async called OnCreate for TParamSliderSForm
  procedure AfterCreate(AForm: TObject);
  var speciesList: array of string;
  begin
    (AForm as TVarSelectForm).ParentFormHeight := self.Height;
    (AForm as TVarSelectForm).Top := trunc(self.Height*0.2); // put popup %20 from top
    if length(self.mainController.getModel.getS_Names) > (MAX_SLIDERS - self.getNumberOfParamSliders) then
      (AForm as TVarSelectForm).speciesList :=
          self.getVarsNotAssignedSliders( self.sliderSpeciesAr, self.mainController.getModel.getS_Names )
    else (AForm as TVarSelectForm).speciesList := self.mainController.getModel.getS_Names;
    (AForm as TVarSelectForm).fillSpeciesCG();
  end;

begin
  fSliderParameter := TVarSelectForm.CreateNew(@AfterCreate);
  fSliderParameter.Popup := true;
  fSliderParameter.ShowClose := false;
  fSliderParameter.PopupOpacity := 0.3;
  fSliderParameter.Border := fbDialogSizeable;
  fSliderParameter.unCheckGroup();
  fSliderParameter.caption := 'Pick species for sliders:';
  fSliderParameter.ShowModal(@AfterShowModal);
end;


{function  TMainForm.getParamsNotAssignedSliders(): array of string;
var paramAr: array of string;
    i, j: integer;
    unused: boolean;
begin
  unused := true;
  paramAr := self.mainController.getModel.getP_Names;
  for i := 0 to length(paramAr) -1 do
    begin
    for j := 0 to length(self.sliderParamAr) -1 do
      begin
      if self.sliderParamAr[j] = i then unused := false;
      end;
    if unused then
      begin
      setLength(Result,length(Result) +1);
      Result[length(Result) -1] := paramAr[i];
      end;
    unused := true;
    end;
end;
    }

function  TMainForm.getVarsNotAssignedSliders( sliderIndexAr: array of integer; varNamesAr: array of String): TStringArray;
var i, j: integer;
    unused: boolean;
begin
  unused := true;
 // paramAr := self.mainController.getModel.getP_Names;
  for i := 0 to length(varNamesAr) -1 do
    begin
    for j := 0 to length(sliderIndexAr) -1 do
      begin
      if (sliderIndexAr[j] = i) then unused := false;
      end;
    if unused then
      begin
      setLength(Result,length(Result) +1);
      Result[length(Result) -1] := varNamesAr[i];
      end;
    unused := true;
    end;
end;

procedure TMainForm.resetBtnOnLineSim();
begin
  self.btnRunPause.caption := 'Start'; //'Start Simulation';
  self.btnRunPause.Hint := 'Start simulation';
 // self.btnAddPlot.Enabled := false;
 // self.btnParamAddSlider.Enabled := false;
  self.enableStepSizeEdit;

end;

procedure TMainForm.chkbxStaticSimRunClick(Sender: TObject);
var i: integer;
begin
  self.mainController.setstaticSimRun(self.chkbxStaticSimRun.Checked);
  if self.chkbxStaticSimRun.Checked = true then
    begin
    self.enableRunTimeEdit;
    if self.runTime = DEFAULT_RUNTIME then
      begin
      self.runTime := DEFAULT_STATICRUN;
      end;
    if (assigned(self.graphPanelList)) and (self.graphPanelList.Count >0) then
      begin
      for i := 0 to self.graphPanelList.Count -1 do
        begin
        self.graphPanelList[i].setStaticGraph( true );
        end;
      end;
    end
  else // false
    begin
    self.btnSavePlotResults.Enabled := false;
    self.btnSavePlotResults.ElementClassName := BTN_DISABLED;
    self.disableRunTimeEdit;
    self.runTime := DEFAULT_RUNTIME;
    if (assigned(self.graphPanelList)) and (self.graphPanelList.Count >0) then
      begin
      for i := 0 to self.graphPanelList.Count -1 do
        begin
        self.graphPanelList[i].setStaticGraph( false );
        end;
      end;
    end;
  if assigned(self.pnlRunTime) then
    self.editRunTime.Text := floatToStr(self.runTime);
end;

procedure TMainForm.refreshPlotAndSliderPanels();
begin
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
       self.graphPanelList[i].setPanelHeight(self.graphPanelList[i].Parent.Height);
       self.graphPanelList[i].Invalidate;    // needed ??
       end;
     end;
   end;
end;

procedure TMainForm.refreshSliderPanels;
var i, sliderWidth, sliderTop, sliderLeft: integer;
begin
 // self.pnlSliders.Width := self.pnlPlot.Width + self.pnlSimInfo.Width + 5;
  sliderWidth := self.calcSliderWidth;
  if assigned(self.pnlSliderParamAr) then
    begin
    for i := 0 to Length(self.pnlSliderParamAr) - 1 do
      begin
      sliderTop := self.calcSliderTop(i);
      sliderLeft := self.calcSliderLeft(i);
      self.pnlSliderParamAr[i].configPSliderPanel(sliderLeft, sliderWidth, self.intSliderHeight, sliderTop);
      self.pnlSliderParamAr[i].configPSliderTBar;
      end;
    end;

   if assigned(self.pnlSliderSpeciesAr) then
    begin
    for i := 0 to Length(self.pnlSliderSpeciesAr) - 1 do
      begin
      sliderTop := self.calcSliderTop(i + Length(self.pnlSliderParamAr) );
      sliderLeft := self.calcSliderLeft(i + Length(self.pnlSliderParamAr));
      self.pnlSliderSpeciesAr[i].configPSliderPanel(sliderLeft, sliderWidth, self.intSliderHeight, sliderTop);
      self.pnlSliderSpeciesAr[i].configPSliderTBar;
      end;
    end;
end;

  procedure TMainForm.runSim();
begin
  self.enableStepSizeEdit;
  //  self.mainController.SetRunTime(self.runTime);  // needed ??
  if self.simStarted = false then
    begin
    self.setUpSimulationUI;
    self.btnRunPause.font.color := clgreen;
    self.btnRunPause.caption := 'Play'; //'Simulation: Play';
    self.btnRunPause.Hint := 'Continue simulation';
     // add a default plot:
    if self.numbPlots < 1 then
      begin
      addPlotAll()
      end ;
      // add default param sliders:
    if self.getNumberOfParamSliders < 1 then
      begin
      self.addAllParamSliders;
      end;

    if self.getNumberOfSpeciesSliders < 1 then
      begin
      self.addAllSpeciesSliders;
      end;
    end;

  // ******************
  if self.mainController.IsModelLoaded then
    begin
      self.mainController.setOnline(true);
      self.mainController.SetRunTime(self.runTime);
      self.btnSimReset.Enabled := false;
      self.btnSimReset.ElementClassName := BTN_DISABLED;
      self.disablePlotEditBtn;
      self.disableStepSizeEdit;
      if assigned(self.pnlSimSpeedMult) then self.trackBarSimSpeed.Enabled := true;
      self.btnRunPause.font.color := clred;
      self.btnRunPause.caption := 'Pause';
      self.btnRunPause.Hint := 'Pause simulation';
     // if DEBUG then
     //   simResultsMemo.visible := true;

      // default timer interval is 100 msec:
      // multiplier default is 10, range 1 - 50
      if assigned(self.pnlSimSpeedMult) then
        self.mainController.SetTimerInterval(round(1000/self.trackBarSimSpeed.position));
      self.mainController.SetStepSize(self.stepSize);

      if self.chkbxStaticSimRun.Checked {self.staticSimRunFlag} then
        begin
        self.runStaticSim;
        end
      else
        begin
        self.mainController.SetTimerEnabled(true); // Turn on web timer (Start simulation)
        end;
      end
   else notifyUser(' No model created for simulation. ');
end;

procedure TMainForm.runStaticSim();
begin
  self.btnSavePlotResults.Enabled := true;
  self.btnSavePlotResults.ElementClassName := BTN_ENABLED;
  self.disablePlotEditBtn;
  self.disableSliderEditBtns;
  self.mainController.SetRunTime(self.runTime);
  self.mainController.setStaticSimRun(self.chkbxStaticSimRun.Checked );
  self.mainController.SetStepSize(self.stepSize);  // just in case ?
  if assigned(self.pnlSimSpeedMult) then self.trackBarSimSpeed.Enabled := false;
  self.btnRunPause.Enabled := false;
  self.btnRunPause.ElementClassName := BTN_DISABLED;
  self.mainController.resetCurrTime;
  self.mainController.startStaticSimulation;
end;

procedure TMainForm.stopSim();
begin
   MainController.setOnline(false);
   self.btnSimReset.Enabled := true;
   self.btnSimReset.ElementClassName := BTN_ENABLED;
   self.enablePlotEditBtn;
   self.enableSliderEditBtns;
   self.enableStepSizeEdit;
   self.MainController.SetTimerEnabled(false); // Turn off web timer (Stop simulation)
   self.btnRunPause.font.color := clgreen;
   self.btnRunPause.caption := 'Play'; //'Simulation: Play';
   self.btnRunPause.Hint := 'Continue simulation';
 {  if self.saveSimResults then
     begin
     self.mainController.writeSimData(self.lblSimDataFileName.Caption, self.simResultsMemo.Lines);
     end;   }
end;

procedure TMainForm.trackBarSimSpeedChange(Sender: TObject);
  var position: double;
begin
  if assigned(self.pnlSimSpeedMult) then
    begin
    position := self.trackBarSimSpeed.Position;
    self.lblSpeedMultVal.Caption := floattostr( (position*0.1) ) + 'x';
    self.MainController.SetTimerInterval( round(1000/position) ); //timer interval does change. Speeds up/down sim
    end;
end;

procedure TMainForm.setUpSimulationUI();
var i: integer;
begin

  self.currentGeneration := 0; // reset current x axis point (pixel)

  if self.mainController.getModel = nil then
  begin
    self.mainController.createModel;
  end;
  self.mainController.createSimulation;
  if self.chkbxStaticSimRun.Checked {self.staticSimRunFlag} then
    begin
    self.mainController.setStaticSimRun(self.chkbxStaticSimRun.Checked {self.staticSimRunFlag});
   // self.mainController.addStaticSimResultsListener(@self.getStaticSimResults);
    end;

  if self.numbPlots >0 then
    self.resetPlots();
  self.simStarted := true;
end;

procedure TMainForm.SliderEditLBClick(Sender: TObject);
begin
  if self.SliderEditLB.ItemIndex = 0 then // change param for slider
    begin
      self.selectParameter(self.SliderEditLB.tag);
    end;
  self.SliderEditLB.tag := -1;
  self.SliderEditLB.visible := false;
  self.SliderEditLB.Top := 2; // default
  self.SliderEditLB.Free;
end;

procedure TMainForm.PingSBMLLoaded(newModel:TModel);
var errList: string;
    i: integer;
begin
  errList := '';
  if assigned(self.lastStaticSimData) then self.lastStaticSimData.free;
  if assigned(self.lastStaticSimParVals) then self.lastStaticSimParVals.free;
  self.btnSavePlotResults.Enabled := false;
  self.btnSavePlotResults.ElementClassName := BTN_DISABLED;

  if self.checkIfModelValid(newModel) <> '' then
    begin
    self.clearOutModel;
    self.disableSliderEditBtns;
    self.disablePlotEditBtn;
    self.disableInfoBtn;
    end
  else  // Good model:
    begin
    self.pnlSliders.height := self.calcSlidersPanelHeight;
    self.btnRunPause.Enabled := true;
    self.btnRunPause.ElementClassName := BTN_ENABLED;
    self.setListBoxInitValues;
    self.setListBoxRateLaws;
    self.setLabelModelInfo;
    if self.chkbxStaticSimRun.Checked then self.enableRunTimeEdit;

    self.enableInfoBtn;
    end;
 
end;

function  TMainForm.checkIfModelValid(newModel:TModel): string; // model OK: returns '' else error string
var errList: string;
    i: integer;
begin
  Result := '';
  errList := '';
  if newModel.getNumSBMLErrors >0 then
    begin
    errList := 'Error reading SBML model: ';
    for i := 0 to newModel.getNumSBMLErrors -1 do
      begin
      errList := errList + newModel.getSBMLErrorStrs()[i] + #13#10 ; // new line char
      end;
    errList := errList +  'Please fix or load a new model.';
    notifyUser(errList);
    end
  else
  begin
    if newModel.getNumModelEvents > 0 then
      begin
      errList := ' SBML Events not supported at this time. Load a different SBML Model';
      notifyUser(errList);
      end
    else if newModel.getNumPiecewiseFuncs >0 then
      begin
      errList := ' SBML piecewise() function not supported at this time. Load a different SBML Model';
      notifyUser(errList);
      end
  end;

  Result := errList;
end;


function  TMainForm.calcSlidersPanelHeight(): integer;
var numVars, numRows: integer;
begin  // Assume only options of max rows, max rows -1, max rows -2
  numRows := trunc( (self.getNumberOfParamSliders + self.getNumberOfSpeciesSliders)/ SLIDERS_PER_ROW );
  if numRows < 3 then numRows := 3; // just in case, adjust below if max rows is 2 or less.

  if self.mainController.IsModelLoaded then
    begin
    numVars := length(self.mainController.getModel.getP_Names);
    numVars := numVars + length(self.mainController.getModel.getS_Names);
    if numVars >= MAX_SLIDERS -3 then
      Result := trunc( numRows * self.intSliderHeight ) +2   // 3 rows (9+ sliders)  if 4 sliders per row
      else if MAX_SLIDERS - numVars < 8 then  // 2 rows (5+ sliders)
           Result := trunc( (numRows -1) * self.intSliderHeight ) +2
         else Result := trunc( (numRows -2) * self.intSliderHeight ) +2;
    end
  else Result := trunc( numRows * self.intSliderHeight) +2;
end;

procedure TMainForm.addPlotAll(); // add plot with all species
var i,spIdAdded, numSpeciesToPlot: integer; maxYVal: double; plotSp: string;
    bSpPlotted: boolean; // Confirm at least one species is plotted.
begin
  spIdAdded := 0 ;   // Number of plot species currently added.
  bSpPlotted := false;
  maxYVal := 0;
  numSpeciesToPlot := 0;
  if self.plotSpecies = nil then
    self.plotSpecies := TList<TSpeciesList>.create;
  self.plotSpecies.Add(TSpeciesList.create);
  numSpeciesToPlot := length(self.mainController.getModel.getS_Names);

  for i := 0 to numSpeciesToPlot -1 do // Check if species list contains model species.
    begin
    plotSp := self.mainController.getModel.getS_names[i];
    if (self.checkIfInSpeciesPlotList(plotSp)) then bSpPlotted := true;
    end;
  if not bSpPlotted then self.spToPlot := '';

  for i := 0 to numSpeciesToPlot -1 do
    begin
    plotSp := '';
    plotSp := self.mainController.getModel.getS_names[i];
    if ( plotSp.contains( NULL_NODE_TAG ) ) then plotSp := ''  // Null node
      else
        begin
        if (self.checkIfInSpeciesPlotList(plotSp)) or (length(self.spToPlot) < 1) then
          begin
          if self.mainController.getModel.getSBMLspecies(plotSp).isSetInitialAmount then
            begin
            if self.mainController.getModel.getSBMLspecies(plotSp).getInitialAmount > maxYVal then
              maxYVal := self.mainController.getModel.getSBMLspecies(plotSp).getInitialAmount;
            end
          else
            if self.mainController.getModel.getSBMLspecies(plotSp).getInitialConcentration > maxYVal then
              maxYVal := self.mainController.getModel.getSBMLspecies(plotSp).getInitialConcentration;

          if spIdAdded < MAX_PLOTSPECIES then
            inc(spIdAdded)
            else plotSp := ''; // Do not plot since already plotting MAX_PLOTSPECIES
          end
        else plotSp := ''; // do not plot
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
  self.graphPanelList[plotPositionToAdd -1].setXAxisLabel(self.xAxisLabel);
  self.graphPanelList[plotPositionToAdd -1].setYAxisLabel(self.yAxisLabel);
  if self.chkbxStaticSimRun.Checked then
    begin
    self.graphPanelList[plotPositionToAdd -1].setStaticGraph(true);
    self.graphPanelList[plotPositionToAdd -1].setXMax(self.runTime);
    end;
  self.graphPanelList[plotPositionToAdd -1].PopupMenu := self.graphEditPopup;
  for i := 0 to self.graphEditPopup.Items.Count -1 do
    begin
    self.graphEditPopup.Items.Items[i].tag := plotPositionToAdd; // tage with position
    end;

  self.graphPanelList[plotPositionToAdd -1].userChangeVarSeries := true;
  newHeight := round( self.pnlPlot.Height );  // default
  if self.numbPlots > DEFAULT_NUMB_PLOTS then
  begin
    newHeight := round(self.pnlPlot.Height/self.numbPlots);
  end;

 // Not used for now: self.graphPanelList[self.numbPlots - 1].OnPlotUpdate := self.editPlotList;
 // if self.numbPlots > DEFAULT_NUMB_PLOTS then    Only one plot, so do not worry
  // Adjust plots to new height:
  for i := 0 to self.numbPlots - 1 do
    self.graphPanelList[i].adjustPanelHeight(newHeight);
  self.initializePlot (self.numbPlots - 1);
 end;

procedure TMainForm.resetPlots();  // Reset plots for new simulation.
 var i: integer;
    initSVals: TVarNameValList;
    displayLegend: boolean;
begin // Easier to just delete/create than reset time, xaxis labels, etc.
  if assigned(self.graphPanelList) then
    begin
    for i := 0 to self.graphPanelList.Count -1 do
      begin
      self.graphPanelList[i].setChartDelta(self.stepSize); //Added
      if self.chkbxStaticSimRun.Checked then self.graphPanelList[i].setXMax(self.runTime);
      displayLegend := self.graphPanelList[i].isLegendVisible;
      self.graphPanelList[i].deleteChart;
      self.graphPanelList[i].createChart;
      self.graphPanelList[i].setupChart;
      if not displayLegend then self.graphPanelList[i].toggleLegendVisibility;// default is true

      end;
    initSVals := TVarNameValList.create;
    for i := 0 to length(self.mainController.getModel.getS_Names) -1 do
      begin
      initSVals.add(TVarNameVal.create(self.mainController.getModel.getS_Names[i],
                                      self.mainController.getModel.getS_initVals[i]) );
      end;
    self.refreshPlotPanels;
    self.getVals( 0, initSVals ); // Display correctly sized graph window on reset
    self.enablePlotEditBtn;
    self.enableSliderEditBtns;
    end;
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
    self.resetPlots;
    self.refreshSliderPanels;
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
    (AForm as TVarSelectForm).ParentFormHeight := self.Height;
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

function TMainForm.checkIfInSpeciesPlotList(spToCheck: string): boolean;
var i: integer;
   spList: array of string;
begin
  Result := false;
  spList := splitString(self.spToPlot, ',');
  for i := 0 to length(spList) -1 do
    begin
    if spTocheck = spList[i].Trim then
      Result := true; // sp is in list
    end;

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
  self.pnlSliderParamAr[sn].free;
  delete(self.pnlSliderParamAr, (sn), 1);
  delete(self.sliderParamAr,(sn), 1);
  self.pnlSliders.Invalidate;
end;

procedure TMainForm.deleteParamSlider(sn: Integer); // sn: slider index
begin
  // console.log('Delete Slider: slider #: ',sn);
  self.pnlSliderParamAr[sn].free;
  delete(self.pnlSliderParamAr, (sn), 1);
  delete(self.sliderParamAr,(sn), 1);
  self.pnlSliders.Invalidate;
end;

procedure TMainForm.deleteSpeciesSlider(sn: Integer); // sn: slider index
begin
  // console.log('Delete Slider: slider #: ',sn);
  self.pnlSliderSpeciesAr[sn].free;
  delete(self.pnlSliderSpeciesAr, (sn), 1);
  delete(self.sliderSpeciesAr,(sn), 1);
 // self.pnlSpeciesSliders.Invalidate;
  self.pnlSliders.Invalidate;
end;

procedure TMainForm.deleteAllSliders();

begin
  self.deleteAllParamSliders;
  self.deleteAllSpeciesSliders;
end;

procedure TMainForm.deleteAllParamSliders();
var i: integer;
begin
  for I := Length(self.pnlSliderParamAr) -1 downto 0 do
    self.deleteParamSlider(i);
  self.pnlSliders.Invalidate;
end;

procedure TMainForm.deleteAllSpeciesSliders();
var i: integer;
begin
  for I := Length(self.pnlSliderSpeciesAr) -1 downto 0 do
    self.deleteSpeciesSlider(i);
 // self.pnlSpeciesSliders.Invalidate;
  self.pnlSliders.Invalidate;
end;


procedure TMainForm.EditSliderList(sn: Integer);  // Not needed? used for mouse clock over slider panel.
// change param slider as needed. sn is slider index
var editList: TStringList;
begin                                           // Use fVarSelect
  if length(self.pnlSliderParamAr) > sn then
    begin
    self.SliderEditLB := TWebListBox.create(self.pnlSliderParamAr[sn]);
    self.SliderEditLB.OnClick := self.SliderEditLBClick;
    self.SliderEditLB.parent := self.pnlSliderParamAr[sn];
    self.SliderEditLB.height := self.SliderEditLB.parent.height - 2;
    self.SliderEditLB.width := 150;
    editList := TStringList.create();
    editList.Add('Change slider parameter.');
    editList.Add('Cancel');
    self.SliderEditLB.Items := editList;
    self.SliderEditLB.Top := 2;
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
  self.pnlSliderParamAr[sn].Visible := false;
  self.sliderParamAr[sn] := -1; // no param index
  self.pnlSliders.Invalidate;
end;

procedure TMainForm.clearParamSlider(sn: Integer); // sn: slider index
begin
  self.pnlSliderParamAr[sn].Visible := false;
  self.sliderParamAr[sn] := -1; // no param index
  self.pnlSliders.Invalidate;
end;

procedure TMainForm.clearSpeciesSlider(sn: Integer); // sn: slider index
begin
  self.pnlSliderSpeciesAr[sn].Visible := false;
  self.sliderSpeciesAr[sn] := -1; // no species index
 // self.pnlSpeciesSliders.Invalidate;
  self.pnlSliders.Invalidate;
end;

{function  TMainForm.getSliderIndex(sliderTag: integer): Integer; // REMOVE
var i: integer;
begin
  Result := -1;
  for i := 0 to length(self.pnlSliderParamAr) -1 do
  begin
    if self.pnlSliderParamAr[i].Tag = sliderTag then
      Result := i;
  end;
end;  }

function  TMainForm.getParamSliderIndex(sliderTag: integer): Integer;
var i: integer;
begin
  Result := -1;
  for i := 0 to length(self.pnlSliderParamAr) -1 do
  begin
    if self.pnlSliderParamAr[i].Tag = sliderTag then
      Result := i;
  end;
end;

function  TMainForm.getSpeciesSliderIndex(sliderTag: integer): Integer;
var i: integer;
begin
  Result := -1;
  for i := 0 to length(self.pnlSliderSpeciesAr) -1 do
  begin
    if self.pnlSliderSpeciesAr[i].Tag = sliderTag then
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
var i: Integer;
  //newValsAr: array of double;
  currentStepSize:double;
  //dataStr: string;    // May use later.
begin
  // Update table of data;
  //newValsAr := newVals.getValAr;
 { dataStr := '';
  dataStr := floatToStrf(newTime, ffFixed, 4, 4) + ', ';
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
 //  console.log(dataStr);
  // Update plots:
  if self.graphPanelList.count > 0 then
    begin
    for i := 0  to self.graphPanelList.count -1 do
      begin
      self.graphPanelList[i].getVals(newTime, newVals); // Faster than own listener ??
      end;
    end;
end;
      // Listener:
procedure TMainForm.getStaticSimResults ( newResults: TList<TTimeVarNameValList> );
var i: integer;
begin
   // Update plots:
  if self.graphPanelList.count > 0 then
    begin
    for i := 0  to self.graphPanelList.count -1 do
      begin
     // self.graphPanelList[i].setYMax();
      self.graphPanelList[i].setStaticSimResults(newResults);
      end;
    end;
  //self.saveStaticSimRunResults(newResults);
  if assigned(self.lastStaticSimData) then self.lastStaticSimData := newResults
  else
    begin
    self.lastStaticSimData := TList<TTimeVarNameValList>.create;
    self.lastStaticSimData := newResults;
    end;

  self.saveCurrentSimParamVals();
//  console.log('TMainForm.getStaticSimResults done plotting');
  self.btnSimReset.Enabled := true;
  self.btnSimReset.ElementClassName := BTN_ENABLED;
  self.stopSim; // ?
  self.resetSim; // ?
  self.btnRunPause.Enabled := true;
  self.btnRunPause.ElementClassName := BTN_ENABLED;
end;


procedure TMainForm.setListBoxInitValues();
var i: integer;
    curId, curAssign, temp: string;
    curVal: double;
    paramAr: array of TSBMLparameter;
    compAr: array of TSBMLCompartment;
    floatSpeciesAr: array of TSBMLSpecies;
    boundarySpeciesAr: array of TSBMLSpecies;
begin
  self.strListInitVals := TStringList.Create;
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
      self.strListInitVals.Add(temp);
      end
    else
      begin
      temp := curId+ ' = ' + floatToStr(paramAr[i].getValue);
      self.strListInitVals.Add(temp);
      end;
    end;

  compAr := self.mainController.getModel.getSBMLcompartmentsArr;
  for i := 0 to length(compAr) -1 do
    begin
    temp := '';
    curId := '';
    curVal := 0.0;
    temp := compAr[i].getID + ' = ' + floatToStr(compAr[i].getVolume);
    self.strListInitVals.Add(temp);
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
      self.strListInitVals.Add(temp);
      end
    else
      begin
      temp := curId+ ' = ';
      if floatSpeciesAr[i].isSetInitialConcentration then
        temp := temp + floatToStr(floatSpeciesAr[i].getInitialConcentration)
      else temp := temp + floatToStr(floatSpeciesAr[i].getInitialAmount);
      self.strListInitVals.Add(temp);
      end;
    end;

  boundarySpeciesAr := self.mainController.getModel.getSBML_ConstBC_SpeciesAr;
  for i := 0 to length(boundarySpeciesAr) -1 do
    begin
    temp := '';
    curId := '';
    curVal := 0.0;
    curId := boundarySpeciesAr[i].getId;
    temp := 'Const boundary species ' + curId + ' = ';
    if self.mainController.getModel.getInitialAssignmentWithSymbolId(curId) <> nil then
      begin
      temp := temp + self.mainController.getModel.getInitialAssignmentWithSymbolId(curId).getFormula;
      self.strListInitVals.Add(temp);
      end
    else
      begin
      //temp := curId+ ' = ';
      if boundarySpeciesAr[i].isSetInitialConcentration then
        temp := temp + floatToStr(boundarySpeciesAr[i].getInitialConcentration)
      else temp := temp + floatToStr(boundarySpeciesAr[i].getInitialAmount);
      self.strListInitVals.Add(temp);
      end;
    end;
end;


procedure TMainForm.displayModelInfo();
   procedure AfterCreate(AForm: TObject);
   begin
    (AForm as TfModelInfo).Top := trunc(self.Height*0.1); // put popup %10 from top
    (AForm as TfModelInfo).setModelName(self.currentModelInfo);
    (AForm as TfModelInfo).setListBoxInitVals(self.strListInitVals);
    (AForm as TfModelInfo).setListBoxRates(self.strListRates);
   end;
begin
  self.fModelInfo := TfModelInfo.CreateNew(@AfterCreate);
  self.fModelInfo.Popup := true;
  self.fModelInfo.ShowClose := true;
  self.fModelInfo.PopupOpacity := 0.3;
  self.fModelInfo.Border := fbDialogSizeable;
  self.fModelInfo.caption := 'Model information:';
end;

procedure TMainForm.displayAbout(strAbout: string);
var fAbout: TfAbout;

  procedure AfterAboutCreate(AForm: TObject);
   begin
   (AForm as TfAbout).Top := trunc(self.Height*0.1); // put popup %10 from top
   (AForm as TfAbout).memoAbout.Text := strAbout;

   end;

begin
  fAbout := TfAbout.CreateNew(@AfterAboutCreate);
  fAbout.Popup := true;
  //fAbout.ShowClose := true;
  fAbout.PopupOpacity := 0.3;
end;

procedure TMainForm.getFileNameFromUser(strDefaultName: string);
var fgetFileName: TfInputText;

  procedure AfterShowModal(AValue: TModalResult);
  var newFileName: String; lForm: TWebForm;
   begin
   newFileName := '';
   if Assigned(fgetFileName) then
     newFileName := fgetFileName.editText.Text;
   if newFileName <> '' then
     begin
     self.saveStaticSimRunResults(self.lastStaticSimData, self.lastStaticSimParVals, newFileName);
     end
   else
     notifyUser('File Save cancelled');
   end;

  procedure AfterCreate(AForm: TObject);
   begin
   (AForm as TfInputText).Top := trunc(self.Height*0.1); // put popup %10 from top
   (AForm as TfInputText).lblInput.Caption := 'Enter File Name:';
   (AForm as TfInputText).editText.Text := strDefaultName;
   (AForm as TfInputText).editText.Font.Size := 12;
   (AForm as TfInputText).lblInfo.Caption := 'Save last simulation data to the Downloads directory.';
   end;

begin
  fgetFileName := TfInputText.CreateNew(@AfterCreate);
  fgetFileName.Popup := true;
  fgetFileName.PopupOpacity := 0.3;
  fgetFileName.ShowModal(@AfterShowModal);
end;

procedure TMainForm.editRunTimeExit(Sender: TObject);
var newRunTime: double;
begin
  try
    if assigned(self.pnlRunTime) then
      begin
      newRunTime := strToFloat(self.editRunTime.Text);
      if newRunTime >0 then
        begin
        self.runTime := newRunTime;
        self.mainController.SetRunTime(self.runTime);
        if self.chkbxStaticSimRun.Checked then
          begin

          self.resetPlots;
          end;
        end
      else notifyUser ('Run Time must be a positive number');
      end;

  except
       on Exception: EConvertError do
         notifyUser ('Run Time must be a positive number');
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

procedure TMainForm.setLabelModelInfo();
begin
  if self.mainController.getModel.getModelId <> '' then
    self.currentModelInfo := stringReplace(self.mainController.getModel.getModelId, '_', ' ',[rfReplaceAll]);
end;


procedure TMainForm.setListBoxRateLaws();
var i: integer;
    curVar, temp: string;
    rateAr: array of TSBMLrule;
    rxnAr: array of SBMLReaction;
begin
  self.strListRates := TStringList.Create;
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
    self.strListRates.Add(temp);


    end;
  //self.lbRateLaws.Items := strListRates;

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

function TMainForm.enableRunTimeEdit(): boolean;  // true: success
begin
  if assigned(self.pnlRunTime) then
    begin
    self.pnlRunTime.Enabled := true;
    self.lblRunTime.Enabled := true;
    self.editRunTime.Enabled := true;
    Result := true;
    end
  else Result := false;
end;
function TMainForm.disableRunTimeEdit(): boolean; // true: success
begin
  if assigned(self.pnlRunTime) then
    begin
    self.pnlRunTime.Enabled := false;
    self.lblRunTime.Enabled := false;
    self.editRunTime.Enabled := false;
    Result := true;
    end
  else Result := false;
end;

function TMainForm.enableSimSpeedMult: Boolean;
begin
  if assigned(self.pnlSimSpeedMult) then
    begin
    self.pnlSimSpeedMult.Enabled := true;
    self.lblSpeedMult.Enabled := true;
    self.lblSpeedMultVal.Enabled := true;
    self.lblSpeedMultMin.Enabled := true;
    self.lblSpeedMultMax.Enabled := true;
    self.trackBarSimSpeed.Enabled := true;
    Result := true;
    end
  else Result := false;
end;

function TMainForm.disableSimSpeedMult: Boolean;
begin
  if assigned(self.pnlSimSpeedMult) then
    begin
    self.pnlSimSpeedMult.Enabled := false;
    self.lblSpeedMult.Enabled := false;
    self.lblSpeedMultVal.Enabled := false;
    self.lblSpeedMultMin.Enabled := false;
    self.lblSpeedMultMax.Enabled := false;
    self.trackBarSimSpeed.Enabled := false;
    Result := true;
    end
  else Result := false;
end;

function  TMainForm.disableSliderEditBtns(): boolean; // true: success, disable param and species btns
begin
  if assigned(self.pnlEditSliders) then
    begin
    self.btnEditSliders.Enabled := false;
    self.btnEditSliders.ElementClassName := BTN_DISABLED;
    self.btnEditSpSliders.Enabled := false;
    self.btnEditSpSliders.ElementClassName := BTN_DISABLED;
    Result := true;
    end
  else Result := false;
end;
function  TMainForm.enableSliderEditBtns(): boolean; // true: success
begin
  if assigned(self.pnlEditSliders) then
    begin
    self.btnEditSliders.Enabled := true;
    self.btnEditSliders.ElementClassName := BTN_ENABLED;
    self.btnEditSpSliders.Enabled := true;
    self.btnEditSpSliders.ElementClassName := BTN_ENABLED;
    Result := true;
    end
  else Result := false;
end;

function  TMainForm.disablePlotEditBtn(): boolean; // true: success
begin
  if assigned(self.pnlEditGraph) then
    begin
    self.btnEditGraph.Enabled := false;
    self.btnEditGraph.ElementClassName := BTN_DISABLED;
    Result := true;
    end
  else Result := false;
end;

function  TMainForm.enablePlotEditBtn(): boolean; // true: success
begin
  if assigned(self.pnlEditGraph) then
    begin
    self.btnEditGraph.Enabled := true;
    self.btnEditGraph.ElementClassName := BTN_ENABLED;
    Result := true;
    end
  else Result := false;
end;

function  TMainForm.disableInfoBtn(): boolean;     // true: success
begin
  if assigned(self.pnlModelInfo) then
    begin
    self.btnModelInfo.Enabled := false;
    self.btnModelInfo.ElementClassName := BTN_DISABLED;
    Result := true;
    end
  else Result := false;
end;

function  TMainForm.enableInfoBtn(): boolean;
begin
  if assigned(self.pnlModelInfo) then
    begin
    self.btnModelInfo.Enabled := true;
    self.btnModelInfo.ElementClassName := BTN_ENABLED;
    Result := true;
    end
  else Result := false;
end;

procedure TMainForm.setTopPanelSpacing;
begin
  self.setLoadPnlSpacing;
  self.setRunPausePnlSpacing;
  self.setSimResetPnlSpacing;
end;

procedure TMainForm.setLoadPnlSpacing;
//var btnWidth: integer;
begin
  if assigned(self.pnlLoadModel) then
    begin
    self.pnlLoadModel.Width := trunc(self.pnlTop.Width * BTN_TOP_PANEL_WIDTH);
    //btnWidth := self.btnLoadModel.Width;
    self.btnLoadModel.Left := trunc(self.pnlLoadModel.Width/2 - self.btnLoadModel.Width/2);
    end;
end;

procedure TMainForm.setRunPausePnlSpacing;
begin
  if assigned(self.pnlRunPause) then
    begin
    self.pnlRunPause.Width := trunc(self.pnlTop.Width * BTN_TOP_PANEL_WIDTH);
    self.btnRunPause.Left := trunc(self.pnlRunPause.Width/2 - self.btnRunPause.Width/2);
    end;
end;

procedure TMainForm.setSimResetPnlSpacing;
begin
  if assigned(self.pnlSimReset) then
    begin
    self.pnlSimReset.Width := trunc(self.pnlTop.Width * BTN_TOP_PANEL_WIDTH);
    self.btnSimReset.Left := trunc(self.pnlSimReset.Width/2 - self.btnSimReset.Width/2);
    end;
end;

procedure TMainForm.setMinUI(isStaticRun: boolean); // Used when model is passed into app.
begin
 // console.log('Minimum UI');
  if isStaticRun then
    begin     // Only static simulations:
    self.pnlStaticSim.Visible := false;
    self.pnlStepSize.Visible := true;
    self.pnlSimSpeedMult.Visible := false;
    end
  else
    begin  // allow both static and realtime sims
    self.pnlStaticSim.Visible := true;
    self.pnlStepSize.Visible := true;
    self.pnlSimSpeedMult.Visible := true;
    end;

  if assigned(self.pnlModelInfo) then self.pnlModelInfo.Free;
  if assigned(self.pnlExample) then self.pnlExample.Free;
 // if assigned(self.pnlLoadModel) then self.pnlLoadModel.visible := false;
  if assigned(self.pnlLoadModel) then
    begin
    self.btnLoadModel.Free;
    self.pnlLoadModel.Free;
    end;
  //self.btnLoadModel.visible := false;
  //
  if isStaticRun then
    begin
    if assigned(self.pnlRunTime) then self.enableRunTimeEdit;
    if assigned(self.pnlSimSpeedMult) then
      self.disableSimSpeedMult;// Actually do not want it visible.
    end
  else
    begin
    if assigned(self.pnlRunTime) then self.disableRunTimeEdit;
    if assigned(self.pnlSimSpeedMult) then
      self.enableSimSpeedMult;
   // self.lblRunTime.visible := false;
   // self.editRunTime.visible := false;
    end;

end;
procedure TMainForm.setMaxUI(); // Used when user choses model.
begin
  console.log('Max UI');
  //TODO ?
end;

procedure TMainForm.saveCurrentSimParamVals();
begin
  //self.lastStaticSimParVals := self.mainController.getSimulation.getP_Vals; // Get current param vals
  self.lastStaticSimParVals := self.mainController.getCurrentParamValues; // Get current param vals
end;

procedure TMainForm.saveStaticSimRunResults(newResults: TList<TTimeVarNameValList>;
  parValues: TVarNameValList; saveFileName: string);
var i, j: integer;
    nameLine: string;
    valLine: string;
    simResults: TStringList;
    curParamVals: TVarNameValList;
begin
  simResults := TStringList.Create;
  //curParamVals := self.mainController.getSimulation.getP_Vals; // Get current param vals
  curParamVals := parValues;
  nameLine := '';
  valLine := '';
  for i := 0 to curParamVals.getNumPairs -1 do
    begin
    nameLine := nameLine + curParamVals.getNameVal(i).getId;
    valLine := valLine + floattostr(curParamVals.getNameVal(i).getVal);
    if i < curParamVals.getNumPairs then
      begin
      nameLine := nameLine + ', ';
      valLine := valLine + ', ';
      end;
    end;
    console.log(nameLine);
    console.log(valLine);
  simResults.Add(nameLine);
  simResults.Add(valLine);
  simResults.Add('  ');
  nameLine := '';
  valLine := '';
  nameLine := 'Time';
  for I := 0 to newResults[0].varNV_List.getNumPairs -1 do
    begin
    nameLine := nameLine + ', ' + newResults[0].varNV_list.getNameVal(i).getId;
    end;
  simResults.Add(nameLine);
  console.log(nameLine);
  for i := 0 to newResults.count -1 do
    begin
    valLine := '';
    valLine := valLine + floattostr(newResults[i].time);
    for j := 0 to newResults[i].varNV_List.getNumPairs -1 do
      begin
      valLine := valLine + ', ' + floattostr(newResults[i].varNV_List.getNameVal(j).getVal);
      end;
    console.log(valLine);
    simResults.Add(valLine);
    end;
  self.writeSimData(saveFileName, simResults);
end;

procedure TMainForm.writeSimData(fileName: string; data: TStrings);
var simData: string;
    i: integer;
begin
  simData := '';
  for i := 0 to data.count -1 do
    begin
      simData := simData + data[i] + sLineBreak;
    end;

   try
     Application.DownloadTextFile(simData, fileName);
   except
       on E: Exception do
          notifyUser(E.message);
   end;

end;



procedure TMainForm.clearBrowserSessionStorage;
 // Delete contents of sessionStorage, if browser refresh button is pushed then
 // default values are loaded into miniSidewinder.
begin
  //console.log('clearBrowserSessionStorage');
  asm
   // sessionStorage.clear;
    sessionStorage.setItem('MODEL', 'empty');
    sessionStorage.setItem('RUNTIME', '0');
    sessionStorage.setItem('STEPSIZE', '0.00');
    sessionStorage.setItem('STATIC', 'false');
    sessionStorage.setItem('SLIDERS', '');
    sessionStorage.setItem('PLOT_SPECIES', '');
  end;
end;

procedure TMainForm.testUI(); // Used for testing
begin
  //console.log('Test UI');
  self.setMaxUI;
end;

end.