object fInputText: TfInputText
  Width = 438
  Height = 127
  Color = clCream
  CSSLibrary = cssBootstrap
  ElementFont = efCSS
  object lblInput: TWebLabel
    Left = 15
    Top = 42
    Width = 70
    Height = 18
    Caption = 'Enter text:'
    Color = clCream
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    HeightPercent = 100.000000000000000000
    ParentFont = False
    WidthPercent = 100.000000000000000000
  end
  object lblInfo: TWebLabel
    Left = 15
    Top = 8
    Width = 5
    Height = 18
    Color = clCream
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
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
    Left = 130
    Top = 44
    Width = 241
    Height = 22
    ChildOrder = 2
    HeightPercent = 100.000000000000000000
    WidthPercent = 100.000000000000000000
  end
end
