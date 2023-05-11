object VarSelectForm: TVarSelectForm
  Top = 20
  Width = 200
  Height = 160
  Color = clCream
  CSSLibrary = cssBootstrap
  ShowClose = False
  OnCreate = plotFormCreate
  object okButton1: TWebButton
    Left = 150
    Top = 2
    Width = 40
    Height = 30
    Anchors = [akTop]
    Caption = 'OK'
    ChildOrder = 1
    ElementClassName = 'btn btn-primary btn-sm'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    HeightPercent = 100.000000000000000000
    ParentFont = False
    WidthPercent = 100.000000000000000000
    OnClick = okButton1Click
  end
  object SpPlotCG: TWebCheckGroup
    Left = 0
    Top = 0
    Width = 91
    Height = 140
    Caption = ''
    ChildOrder = 2
    Columns = 1
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Role = ''
    OnCheckClick = SpPlotCGCheckClick
  end
end
