unit ufChkGroupEditPlot;

interface

uses
  System.SysUtils, System.Classes, JS, Web, WEBLib.Graphics, WEBLib.Controls,
  WEBLib.Forms, WEBLib.Dialogs, Vcl.Controls, WEBLib.StdCtrls, Vcl.StdCtrls;

type
  TfChkGroupEditPlot = class(TWebForm)
    chkGrpEditPlot: TWebCheckGroup;
    btnOkPlotEdit: TWebButton;
    btnCancelPlotEdit: TWebButton;
    procedure btnCancelPlotEditClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fChkGroupEditPlot: TfChkGroupEditPlot;

implementation

{$R *.dfm}

procedure TfChkGroupEditPlot.btnCancelPlotEditClick(Sender: TObject);
begin
// TODO
end;

end.