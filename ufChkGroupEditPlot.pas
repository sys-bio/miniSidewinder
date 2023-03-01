unit ufChkGroupEditPlot;

interface

uses
  System.SysUtils, System.Classes, JS, Web, WEBLib.Graphics, WEBLib.Controls,
  WEBLib.Forms, WEBLib.Dialogs, Vcl.Controls, WEBLib.StdCtrls, Vcl.StdCtrls,
  WEBLib.ExtCtrls;
{
 0 = legend visible
 1 = Autoscale

 2 = Change plot species
}
const LEGEND_VIS = 0; AUTO_SCALE = 1; CHANGE_SPECIES = 2;

type
  TfChkGroupEditPlot = class(TWebForm)
    chkGrpEditPlot: TWebCheckGroup;
    btnOkPlotEdit: TWebButton;
    lblYAxisMin: TWebLabel;
    lblYAxisMax: TWebLabel;
    editYAxisMax: TWebEdit;
    editYAxisMin: TWebEdit;
    pnlYAxisMinMax: TWebPanel;
    lblEditYAxis: TWebLabel;
    procedure btnOkPlotEditClick(Sender: TObject);

  private
    { Private declarations }
  public

    procedure checkLegendVisible();
    procedure uncheckLegendInvisible();
    procedure checkAutoscale();
    procedure uncheckAutoscale();
   // procedure uncheckEditYAxis();
    procedure uncheckEditPlotSpecies();
    function  getEditYMax(): double;
    function  getEditYMin(): double;
  end;

var
  fChkGroupEditPlot: TfChkGroupEditPlot;

implementation

{$R *.dfm}

procedure TfChkGroupEditPlot.btnOkPlotEditClick(Sender: TObject);
var lForm: TWebForm;
begin
  lForm := TWebForm((Sender as TWebButton).Parent);
  lForm.Close;
  lForm.Free;
end;

procedure TfChkGroupEditPlot.checkLegendVisible();
begin
  self.chkGrpEditPlot.Checked[LEGEND_VIS] := true;
end;
procedure TfChkGroupEditPlot.uncheckLegendInvisible();
begin
  self.chkGrpEditPlot.Checked[LEGEND_VIS] := false;
end;

procedure TfChkGroupEditPlot.checkAutoscale();
begin
  self.chkGrpEditPlot.Checked[AUTO_SCALE] := true;
end;
procedure TfChkGroupEditPlot.uncheckAutoscale();
begin
  self.chkGrpEditPlot.Checked[AUTO_SCALE] := false;
end;

{procedure TfChkGroupEditPlot.uncheckEditYAxis();
begin
  self.chkGrpEditPlot.Checked[EDIT_Y_AXIS] := false;
end; }

procedure TfChkGroupEditPlot.uncheckEditPlotSpecies();
begin
  self.chkGrpEditPlot.Checked[CHANGE_SPECIES] := false;
end;

function TfChkGroupEditPlot.getEditYMax(): double;
begin
  try
    Result := strtofloat(self.editYAxisMax.Text);
  except
    Result := 0.0;
  end;
end;

function  TfChkGroupEditPlot.getEditYMin(): double;
begin
  try
    Result := strtofloat(self.editYAxisMin.Text);
  except
    Result := 0.0;
  end;
end;

end.