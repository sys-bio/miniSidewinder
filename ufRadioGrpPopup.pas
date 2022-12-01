unit ufRadioGrpPopup;

interface

uses
  System.SysUtils, System.Classes, JS, Web, WEBLib.Graphics, WEBLib.Controls,
  WEBLib.Forms, WEBLib.Dialogs, Vcl.StdCtrls, WEBLib.StdCtrls, Vcl.Controls;

type
  TfPlotEdit = class(TWebForm)
    rgEditPlot: TWebRadioGroup;
    btnOk: TWebButton;
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fPlotEdit: TfPlotEdit;

implementation

{$R *.dfm}

procedure TfPlotEdit.btnOkClick(Sender: TObject);
var lForm: TWebForm;
begin
  lForm := TWebForm((Sender as TWebButton).Parent);
  lForm.Close;
  lForm.Free;
end;



end.