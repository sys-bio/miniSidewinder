object fInputText: TfInputText
  Width = 438
  Height = 127
  Color = clCream
  CSSLibrary = cssBootstrap
  ElementFont = efCSS
  object lblInput: TWebLabel
    Left = 24
    Top = 47
    Width = 53
    Height = 13
    Caption = 'Enter text:'
    Color = clCream
    HeightPercent = 100.000000000000000000
    WidthPercent = 100.000000000000000000
  end
  object lblInfo: TWebLabel
    Left = 40
    Top = 8
    Width = 4
    Height = 16
    Color = clCream
    ElementFont = efCSS
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    HeightStyle = ssAuto
    HeightPercent = 100.000000000000000000
    ParentFont = False
    WordWrap = True
    WidthPercent = 100.000000000000000000
  end
  object btnOk: TWebButton
    Left = 168
    Top = 80
    Width = 73
    Height = 33
    ButtonType = 'btn-small'
    Caption = 'OK'
    ElementClassName = 'btn btn-dark btn-sm'
    HeightPercent = 100.000000000000000000
    WidthPercent = 100.000000000000000000
    OnClick = btnOkClick
  end
  object editText: TWebEdit
    Left = 120
    Top = 44
    Width = 241
    Height = 22
    ChildOrder = 2
    HeightPercent = 100.000000000000000000
    WidthPercent = 100.000000000000000000
  end
end
