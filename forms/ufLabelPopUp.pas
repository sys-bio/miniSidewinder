unit ufLabelPopUp;

interface

uses
  System.SysUtils, System.Classes, JS, Web, WEBLib.Graphics, WEBLib.Controls,
  WEBLib.Forms, WEBLib.Dialogs, Vcl.Controls, Vcl.StdCtrls, WEBLib.StdCtrls;

type
  TfLabelPopUp = class(TWebForm)
    lbl_Info: TWebLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fLabelPopUp: TfLabelPopUp;

implementation

{$R *.dfm}

end.