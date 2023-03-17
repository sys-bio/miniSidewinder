unit ufModelInfo;
 // pop up form that displays a list.
interface

uses
  System.SysUtils, System.Classes, JS, Web, WEBLib.Graphics, WEBLib.Controls,
  WEBLib.Forms, WEBLib.Dialogs, Vcl.Controls, Vcl.StdCtrls, WEBLib.StdCtrls,
  System.StrUtils;

type
  TfModelInfo = class(TWebForm)
    listBoxInitVals: TWebListBox;
    listBoxRates: TWebListBox;
    lblInitVals: TWebLabel;
    lblRates: TWebLabel;
    memoModelName: TWebMemo;
  private
    { Private declarations }
  public
  procedure setlistBoxInitVals(newList: TStringList);
  procedure setlistBoxRates(newList: TStringList);
  procedure setModelName(newName: string);
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

 procedure TfModelInfo.setModelName(newName: string);
 var i, width: integer;
     strName: string;
 begin
   if (newName = '') or (newName.Contains('None'))then
     self.memoModelName.Text := 'No Model ID.'
   else self.memoModelName.Text := newName;
 end;

end.