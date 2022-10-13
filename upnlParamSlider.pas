unit upnlParamSlider;

interface

uses System.SysUtils, System.Classes, System.Generics.Collections, StrUtils,
  JS, Web, WEBLib.Graphics, WEBLib.Controls, WEBLib.Forms, WEBLib.Dialogs,
  Vcl.Controls, WEBLib.ExtCtrls, Vcl.StdCtrls, WEBLib.StdCtrls, ufVarSelect;


type

TpnlParamSlider = class(TWebPanel)
  private
    fSliderParameter: TVarSelectForm;// Pop up form to choose parameter for slider.
    sliderParam: Integer;// holds parameter array index (p_vals) of parameter to use for each slider
    //pnlSliderAr: array of TWebPanel; // Holds parameter sliders
    sliderPHigh: Double; // High value for parameter slider
    sliderPLow: Double;  // Low value for parameter slider
    sliderPTBar: TWebTrackBar;
    sliderPHLabel: TWebLabel; // Displays sliderPHigh
    sliderPLLabel: TWebLabel; // Displays sliderPLow
    sliderPTBLabel: TWebLabel;
    sliderNumber: integer;  // Starts at 1, Not index
    id: string;
    initVal: double;
    multiplier: integer; // Sets range of low to high
  public
    constructor create(newParent: TWebPanel; number: integer);
    procedure configPSliderPanel(sPLeft, sliderPanelWidth, sliderPanelHeight: integer);
    procedure configPSliderTBar(sliderPanelWidth : integer);
    procedure setUpParamSlider(newId: string; newVal: double; newMultiplier: integer);
  //  procedure resetSliderPosition();

end;


implementation

  constructor TpnlParamSlider.create(newParent: TWebPanel; number: integer);
  begin
    inherited create(newParent);
    if number > 0 then
      self.sliderNumber := number
    else self.sliderNumber := 1;
  end;

  procedure TpnlParamSlider.configPSliderPanel(sPLeft, sliderPanelWidth, sliderPanelHeight: integer);
  begin
    self.Anchors := [akLeft,akRight,akTop];
    self.visible := true;
    self.Top := sliderPanelHeight*sliderNumber + 3;
    self.Left := sPLeft;
    self.Height := sliderPanelHeight;
    self.Width := sliderPanelWidth - 6; // -6 to move it in from the extreme right edge
  end;

  // Define the sliders inside the panel that holds the sliders
procedure TpnlParamSlider.configPSliderTBar(sliderPanelWidth : integer { newSBarAr: array of TWebTrackBar;}
       );
var sliderTBarWidth : integer;
  begin
    // Width of the slider inside the panel
    sliderTBarWidth:= trunc (0.70*self.width {sliderPanelWidth}); // 70% of the panel's width

    // This defines the location of the slider itself (not the position of the panel)
    self.sliderPTBar.visible:= True;
    self.sliderPTBar.Tag:= self.sliderNumber;  // keep track of slider index number.
    self.sliderPTBar.Left:= 20;
    self.sliderPTBar.Top:= 27;
    self.sliderPTBar.Width:= sliderTBarWidth;
    self.sliderPTBar.Height:= 20;

    // Value (high) positioned on the right-side of slider
    self.sliderPHLabel.visible:= True;
    self.sliderPHLabel.Tag:= sliderNumber;
    self.sliderPHLabel.Top:= 30;
    self.sliderPHLabel.Left:= sliderPanelWidth - trunc (0.15*sliderPanelWidth);

    // Value (low) positioned on the left-side of slider
    self.sliderPLLabel.visible:= True;
    self.sliderPLLabel.Tag:= sliderNumber;
    self.sliderPLLabel.Top:= 30;
    self.sliderPLLabel.Left:= 4;

    // parameter label and current value
    self.sliderPTBLabel.visible:= True;
    self.sliderPTBLabel.Tag:= sliderNumber;
    self.sliderPTBLabel.Left:= 48;
    self.sliderPTBLabel.Top:= 3;
  end;

procedure TpnlParamSlider.setUpParamSlider(newId: string; newVal: double; newMultiplier: integer);
var
  rangeMult: Integer;
  pVal:Double;
  pName: String;
begin
  self.multiplier := newMultiplier;
  pName :=  newId;
  pVal := newVal;
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

end.
