unit ufInputText;

interface

uses
  System.SysUtils, System.Classes, JS, Web, WEBLib.Graphics, WEBLib.Controls,
  WEBLib.Forms, WEBLib.Dialogs, Vcl.StdCtrls, WEBLib.StdCtrls, Vcl.Controls;

type
  TfInputText = class(TWebForm)
    btnOk: TWebButton;
    lblInput: TWebLabel;
    editText: TWebEdit;
    lblInfo: TWebLabel;
    procedure btnOkClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fInputText: TfInputText;

implementation

{$R *.dfm}





procedure TfInputText.btnOkClick(Sender: TObject);
var lForm: TWebForm;
begin
  lForm := TWebForm((Sender as TWebButton).Parent);
  lForm.Close;
  lForm.Free;
end;


end.
