object fAbout: TfAbout
  Width = 421
  Height = 177
  Color = clCream
  CSSLibrary = cssBootstrap
  ElementFont = efCSS
  object memoAbout: TWebMemo
    Left = 16
    Top = 16
    Width = 385
    Height = 105
    AutoSize = False
    BorderStyle = bsNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    HeightPercent = 100.000000000000000000
    Lines.Strings = (
      'memoAbout')
    ParentFont = False
    SelLength = 0
    SelStart = 0
    WidthPercent = 100.000000000000000000
  end
  object btnAboutClose: TWebButton
    Left = 168
    Top = 130
    Width = 75
    Height = 20
    ButtonType = 'btn-small'
    Caption = 'Close'
    ChildOrder = 1
    ElementClassName = 'btn btn-dark btn-sm'
    ElementFont = efCSS
    HeightStyle = ssAuto
    HeightPercent = 100.000000000000000000
    WidthPercent = 100.000000000000000000
    OnClick = btnAboutCloseClick
  end
end
