program miniSidewinder;

uses
  Vcl.Forms,
  WEBLib.Forms,
  ufMain in 'ufMain.pas' {MainForm: TWebForm} {*.html},
  uODE_FormatUtility in 'simulator\uODE_FormatUtility.pas',
  uSimulation in 'simulator\uSimulation.pas',
  uSBMLClasses.FuncDefinition in 'sbml\uSBMLClasses.FuncDefinition.pas',
  uSBMLClasses.Layout in 'sbml\uSBMLClasses.Layout.pas',
  uSBMLClasses in 'sbml\uSBMLClasses.pas',
  uSBMLClasses.Render in 'sbml\uSBMLClasses.Render.pas',
  uSBMLClasses.rule in 'sbml\uSBMLClasses.rule.pas',
  uSBMLReader in 'sbml\uSBMLReader.pas',
  uSBMLWriter in 'sbml\uSBMLWriter.pas',
  uModel in 'model\uModel.pas',
  Adamsbdf in 'math\lsoda\Adamsbdf.pas',
  lsodamat in 'math\lsoda\lsodamat.pas',
  odeEquations in 'math\lsoda\odeEquations.pas',
  uMatrix in 'math\lsoda\uMatrix.pas',
  uVector in 'math\lsoda\uVector.pas',
  uMath in 'math\uMath.pas',
  uGraphPanel in 'Graph\uGraphPanel.pas',
  uScrollingTypes in 'Graph\ScrollingChart\uScrollingTypes.pas',
  uWebComps in 'Graph\ScrollingChart\uWebComps.pas',
  uWebContainer in 'Graph\ScrollingChart\uWebContainer.pas',
  uWebDataSource in 'Graph\ScrollingChart\uWebDataSource.pas',
  uWebGlobalData in 'Graph\ScrollingChart\uWebGlobalData.pas',
  uWebScrollingChart in 'Graph\ScrollingChart\uWebScrollingChart.pas',
  uWebStage in 'Graph\ScrollingChart\uWebStage.pas',
  uControllerMain in 'uControllerMain.pas',
  uSidewinderTypes in 'uSidewinderTypes.pas',
  ufYAxisMinMaxEdit in 'Graph\ufYAxisMinMaxEdit.pas' {FYAxisMinMaxEdit: TWebForm} {*.html},
  upnlParamSlider in 'upnlParamSlider.pas',
  ufModelInfo in 'ufModelInfo.pas' {fModelInfo: TWebForm} {*.html},
  uTestModel in 'uTestModel.pas',
  ufVarSelect in 'ufVarSelect.pas' {VarSelectForm: TWebForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TFYAxisMinMaxEdit, FYAxisMinMaxEdit);
  Application.CreateForm(TfModelInfo, fModelInfo);
  Application.Run;
end.
