unit ufModelInfo;
 // pop up form that displays a list.
interface

uses
  System.SysUtils, System.Classes, JS, Web, WEBLib.Graphics, WEBLib.Controls,
  WEBLib.Forms, WEBLib.Dialogs, Vcl.Controls, Vcl.StdCtrls, WEBLib.StdCtrls;

type
  TfModelInfo = class(TWebForm)
    listBoxInitVals: TWebListBox;
    lblModelName: TWebLabel;
    listBoxRates: TWebListBox;
    lblInitVals: TWebLabel;
    lblRates: TWebLabel;
  private
    { Private declarations }
  public
  procedure setlistBoxInitVals(newList: TStringList);
  procedure setlistBoxRates(newList: TStringList);
  end;

var
  fModelInfo: TfModelInfo;

implementation

{$R *.dfm}
 procedure TfModelInfo.setlistBoxInitVals(newList: TStringList);
 var itemCount: integer;
 begin
   self.listBoxInitVals.Items := newList;
   itemCount := newList.Count;
   self.listBoxInitVals.Height := trunc(self.listBoxInitVals.Font.Size * 1.8 * itemCount);
   self.Height := self.listBoxInitVals.Height + 100;
 end;

 procedure TfModelInfo.setlistBoxRates(newList: TStringList);
 var itemCount: integer;
 begin
   self.listBoxRates.Items := newList;
   itemCount := newList.Count;
   self.listBoxRates.Height := trunc(self.listBoxRates.Font.Size * 1.8 * itemCount);

 end;

end.