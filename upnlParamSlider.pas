unit upnlParamSlider;

interface

uses System.SysUtils, System.Classes, System.Generics.Collections, StrUtils,
  JS, Web, WEBLib.Graphics, WEBLib.Controls, WEBLib.Forms, WEBLib.Dialogs,
  Vcl.Controls, WEBLib.ExtCtrls, Vcl.StdCtrls, WEBLib.StdCtrls, ufVarSelect;


type
TEditSliderEvent = procedure( index: integer ) of object;

TpnlParamSlider = class(TWebPanel)
  private
    fSliderParameter: TVarSelectForm;// Pop up form to choose parameter for slider.
   // sliderParam: Integer;// holds parameter array index (p_vals) of parameter to use for each slider

    sliderPHigh: Double; // High value for parameter slider
    sliderPLow: Double;  // Low value for parameter slider
    sliderPTBar: TWebTrackBar;
    sliderPHLabel: TWebLabel; // Displays sliderPHigh
    sliderPLLabel: TWebLabel; // Displays sliderPLow
    sliderPTBLabel: TWebLabel;
   // sliderNumber: integer;  // Starts at 1, Not index , use tag
    id: string;    // name of parameter to adjust
    initVal: double;
    multiplier: integer; // Sets range of low to high
    fEditSlider: TEditSliderEvent;

  public
    constructor create(newParent: TWebPanel; index: integer;
                editSliderCallBack: TEditSliderEvent; trackBarChange: TNotifyEvent);
    procedure configPSliderPanel(sPLeft, sliderPanelWidth, sliderPanelHeight: integer);
    procedure configPSliderTBar({sliderPanelWidth : integer});
    procedure setTrackBarLabel( newStr: string );
    procedure clearSlider();
    // Called when adding or updating a param slider:
    procedure setUpParamSliderVals(pName: string; pVal: double);
    procedure resetSliderPosition(pName: string; pVal: double);
    function  getSliderHighVal(): double;
    procedure setSliderHighVal( newVal: double );
    function  getSliderLowVal(): double;
    procedure setSliderLowVal( newVal: double );
    function  getSliderPosition(): integer;
    procedure setSliderRangeMultiplier( newVal: integer );
    function  getSliderRangeMultiplier(): integer;
  //  procedure EditSliderList(sn: Integer);
    procedure SliderOnMouseDown(Sender: TObject; Button: TMouseButton;
                                 Shift: TShiftState; X, Y: Integer);
    property OnEditSlider: TEditSliderEvent read fEditSlider write fEditSlider;
end;


implementation

  constructor TpnlParamSlider.create(newParent: TWebPanel; index: integer;
                  editSliderCallBack: TEditSliderEvent; trackBarChange: TNotifyEvent);
  begin
    inherited create(newParent);
    self.parent := newParent;
    self.OnMouseDown := self.SliderOnMouseDown;// mouseDownCallBack;
    self.OnEditSlider := editSliderCallBack;
    if index > -1 then
      self.tag := index
    else self.tag := 0;
    self.multiplier := 10;  // Default
    self.sliderPTBar := TWebTrackBar.create(self);
    self.sliderPTBar.parent := self;
    self.sliderPTBar.OnChange := trackBarChange;
    self.sliderPHLabel := TWebLabel.create(self);
    self.sliderPHLabel.parent := self;
    self.sliderPLLabel := TWebLabel.create(self);
    self.sliderPLLabel.parent := self;
    self.sliderPTBLabel := TWebLabel.create(self);
    self.sliderPTBLabel.parent := self;
    self.configPSliderTBar;
    self.Invalidate;
  end;

  procedure TpnlParamSlider.configPSliderPanel(sPLeft, sliderPanelWidth, sliderPanelHeight: integer);
  begin
    self.Anchors := [akLeft,akRight,akTop];
    self.visible := true;
    self.Top := sliderPanelHeight*self.tag + 3;
    self.Left := sPLeft;
    self.Height := sliderPanelHeight;
    self.Width := sliderPanelWidth - 6; // -6 to move it in from the extreme right edge
    self.Invalidate;
  end;

  // Define the sliders inside the panel that holds the sliders
procedure TpnlParamSlider.configPSliderTBar({sliderPanelWidth : integer }{ newSBarAr: array of TWebTrackBar;}
       );
var sliderTBarWidth : integer;
  begin
    // Width of the slider inside the panel
    sliderTBarWidth:= trunc (0.70*self.width {sliderPanelWidth}); // 70% of the panel's width
    // This defines the location of the slider itself (not the position of the panel)
    self.sliderPTBar.visible:= True;
    self.sliderPTBar.Tag:= self.tag;  // keep track of slider index number.
    self.sliderPTBar.Left:= 20;
    self.sliderPTBar.Top:= 27;
    self.sliderPTBar.Width:= sliderTBarWidth;
    self.sliderPTBar.Height:= 20;

    // Value (high) positioned on the right-side of slider
    self.sliderPHLabel.visible:= True;
    self.sliderPHLabel.Tag:= self.tag;
    self.sliderPHLabel.Top:= 30;
   // self.sliderPHLabel.Left:= sliderPanelWidth - trunc (0.15*sliderPanelWidth);
    self.sliderPHLabel.Left:= self.Width - trunc (0.15 * self.Width);

    // Value (low) positioned on the left-side of slider
    self.sliderPLLabel.visible:= True;
    self.sliderPLLabel.Tag:= self.tag;
    self.sliderPLLabel.Top:= 30;
    self.sliderPLLabel.Left:= 4;

    // parameter label and current value
    self.sliderPTBLabel.visible:= True;
    self.sliderPTBLabel.Tag:= self.tag;
    self.sliderPTBLabel.Left:= 48;
    self.sliderPTBLabel.Top:= 3;
  end;


procedure TpnlParamSlider.setUpParamSliderVals(pName: string; pVal: double);
begin
  self.id := pName;
  self.initVal := pVal;
  self.sliderPTBLabel.caption := pName + ': ' + FloatToStr(pVal);
  self.sliderPLow := 0;
  self.sliderPLLabel.caption := FloatToStr(self.sliderPLow);
  self.sliderPTBar.Min := 0;
  self.sliderPTBar.Position := trunc((1 / self.multiplier) * 100);
  self.sliderPTBar.Max := 100;
  if pVal > 0 then
    begin
      self.sliderPHLabel.caption := FloatToStr(pVal * self.multiplier);
      self.sliderPHigh := pVal * self.multiplier;
    end
  else
    begin
      self.sliderPHLabel.caption := FloatToStr(100);
      self.sliderPHigh := 100; // default if init param val <= 0.
    end;

end;

procedure TpnlParamSlider.clearSlider();
begin
  self.sliderPHLabel.Caption := '';
  self.sliderPLLabel.Caption := '';
  self.sliderPTBLabel.Caption := '';
  self.sliderPHigh := 0;
  self.sliderPLow := 0;
end;

procedure TpnlParamSlider.resetSliderPosition(pName: string; pVal: double);
begin
  self.id := pName;
  self.initVal := pVal;
  self.sliderPTBLabel.caption := pName + ': ' + FloatToStr(pVal);
  self.sliderPTBar.Position := trunc((1 / self.multiplier) * 100);
end;

procedure TpnlParamSlider.setTrackBarLabel( newStr: string );
begin
  self.sliderPTBLabel.Caption := newStr;
end;

function  TpnlParamSlider.getSliderHighVal(): double;
begin
  Result := self.sliderPHigh;
end;
procedure TpnlParamSlider.setSliderHighVal( newVal: double ); // No multiplier used
begin
  self.sliderPHigh := newVal;
  self.sliderPHLabel.Caption := floattostr(newVal);
end;
function  TpnlParamSlider.getSliderLowVal(): double;
begin
  Result := self.sliderPLow;
end;
procedure TpnlParamSlider.setSliderLowVal( newVal: double );
begin
  self.sliderPLow := newVal;
end;

function TpnlParamSlider.getSliderPosition(): integer;
begin
  Result := self.sliderPTBar.Position;
end;

procedure TpnlParamSlider.setSliderRangeMultiplier( newVal: integer );
begin
  if newVal > 0 then self.multiplier := newVal;
end;
function  TpnlParamSlider.getSliderRangeMultiplier(): integer;
begin
  Result := self.multiplier;
end;

procedure TpnlParamSlider.SliderOnMouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
  var
    i: Integer; // grab plot which received event
  begin
    if (Button = mbRight) or (Button = mbLeft) then // Both for now.
      begin
        if Sender is TpnlParamSlider {TWebPanel} then
          begin
            i := TpnlParamSlider(Sender).tag;
            // ShowMessage('WebPanel sent mouse msg (addParamSlider):  '+ inttostr(i));
            if i = self.Tag then
              begin
              if assigned( self.fEditSlider) then

              self.fEditSlider(i); // call listener instead
              end;
          end;
      end;
  end;

{procedure TpnlParamSlider.EditSliderList(sn: Integer);
// delete, change param slider as needed. sn is slider index
var
  sliderXposition, sliderYposition: Integer;
  editList: TStringList;
  lbSliderEdit: TWebListBox;
begin
  sliderXposition := self.Left + 10; // needs parent to be self.pnlSliderAr[sn]
  sliderYposition := self.Top + 1;
  editList := TStringList.create();
  editList.Add('Change slider parameter.');
  //editList.Add('Delete slider.');
  editList.Add('Cancel');
  lbSliderEdit := TWebListBox.create(self);
  lbSliderEdit.parent := self;
  lbSliderEdit.Items := editList;
  lbSliderEdit.Top := sliderYposition;
  lbSliderEdit.left := sliderXposition;
  lbSliderEdit.Height := 100;
  lbSliderEdit.tag := sn;
  lbSliderEdit.bringToFront;
  lbSliderEdit.visible := true;

end;      }

{procedure TpnlParamSlider.pnlParamSliderMouseDown(Sender: TObject;  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;   }


end.