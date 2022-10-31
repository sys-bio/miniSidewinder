unit ufListBox;
 // pop up form that displays a list.
interface

uses
  System.SysUtils, System.Classes, JS, Web, WEBLib.Graphics, WEBLib.Controls,
  WEBLib.Forms, WEBLib.Dialogs, Vcl.Controls, Vcl.StdCtrls, WEBLib.StdCtrls;

type
  TfListBox1 = class(TWebForm)
    listBox1: TWebListBox;
  private
    { Private declarations }
  public
  procedure setListBox(newList: TStringList);
  end;

var
  fListBox1: TfListBox1;

implementation

{$R *.dfm}
 procedure TfListBox1.setListBox(newList: TStringList);
 begin
   self.listBox1.Items := newList;
 end;


end.