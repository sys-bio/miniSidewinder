unit ufVarSelect;

// Contains a plot

interface

uses
  System.SysUtils, System.Classes, JS, Web, WEBLib.Graphics, WEBLib.Controls,
  WEBLib.Forms, WEBLib.Dialogs, Vcl.Controls, WEBLib.ExtCtrls, Vcl.StdCtrls,
  WEBLib.StdCtrls, Types, VCL.TMSFNCTypes, VCL.TMSFNCUtils, VCL.TMSFNCGraphics, VCL.TMSFNCGraphicsTypes;

type
  TVarSelectForm = class(TWebForm)
    okButton1: TWebButton;
    SpPlotCG: TWebCheckGroup;
    procedure plotFormCreate(Sender: TObject);
    procedure okButton1Click(Sender: TObject);
    procedure SpPlotCGCheckClick(Sender: TObject; AIndex: Integer);
    procedure setSpPlotCGFontColor( newColor: TColor);
    procedure unCheckGroup();
    procedure checkGroup();

  private
    function  setChkGrpWidth(): integer; // adjusts width based on longest string in speciesList
    procedure setWidths();
    procedure setHeights();
  public
    speciesList: array of String;
    ParentFormHeight: integer; // Height of main form, do not want form to be taller
    PlotWForm: TVarSelectForm;
    procedure fillSpeciesCG();
    procedure chkSpecies(index: integer);
    procedure unChkSpecies(index: integer);
  end;

implementation

{$R *.dfm}


// Close Plot:
procedure TVarSelectForm.okButton1Click(Sender: TObject);
var lForm: TWebForm;
begin
  lForm := TWebForm((Sender as TWebButton).Parent);
  lForm.Close;
  lForm.Free;
end;

procedure TVarSelectForm.plotFormCreate(Sender: TObject);
begin
  //console.log('Species select form created');
  self.ParentFormHeight := 200; // default
end;


procedure TVarSelectForm.SpPlotCGCheckClick(Sender: TObject; AIndex: Integer);
begin
// TODO ??
end;

procedure TVarSelectForm.setHeights();
var tmpHt: integer;
begin
  self.SpPlotCG.height := round(2.6 * self.SpPlotCG.Font.Size * self.SpPlotCG.Items.Count);
  tmpHt := self.SpPlotCG.Height + 30;
  if tmpHt < self.ParentFormHeight then self.Height := tmpHt
  else self.Height := trunc(self.ParentFormHeight - self.ParentFormHeight * 0.2);
end;

function  TVarSelectForm.setChkGrpWidth(): integer;
var i, maxLength: integer;
begin
  maxLength := 0;
  for i := 0 to length(self.speciesList) -1 do
    begin
    if length(self.speciesList[i]) > maxLength then
      maxLength := length(self.speciesList[i]);
    end;
  if maxLength < 8 then
    maxLength := 8;
  result := maxLength * 9;
end;

procedure TVarSelectForm.setWidths();
begin
  self.SpPlotCG.Width := self.setChkGrpWidth ;// Adjust chkgrp width to fit longest string
  self.okButton1.Left := self.SpPlotCG.Width + self.SpPlotCG.Left + 5;
  self.Width := self.SpPlotCG.Width + self.okButton1.Width + 25; // adjust form width
end;

procedure TVarSelectForm.fillSpeciesCG();
var i : integer;
begin
  self.setWidths;
  for i := 0 to length(speciesList)-1 do
    SpPlotCG.Items.Add ('&nbsp; ' + speciesList[i]);
  self.setHeights;
end;

procedure TVarSelectForm.unCheckGroup();
var i: integer;
begin
  for i := 0 to length(speciesList)-1 do
    SpPlotCG.Checked[i] := false;
end;

procedure TVarSelectForm.checkGroup();
var i: integer;
begin
  for i := 0 to length(speciesList)-1 do
    SpPlotCG.Checked[i] := true;
end;

procedure TVarSelectForm.chkSpecies(index: integer);
begin
  if index < self.SpPlotCG.Items.Count then
    self.SpPlotCG.Checked[index] := true;
end;
procedure TVarSelectForm.unChkSpecies(index: integer);
begin
  if index < self.SpPlotCG.Items.Count then
    self.SpPlotCG.Checked[index] := false;
end;

procedure TVarSelectForm.setSpPlotCGFontColor(newColor: TColor);
begin
  self.SpPlotCG.font.color := newColor;
end;

end.
