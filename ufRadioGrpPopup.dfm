object fPlotEdit: TfPlotEdit
  Width = 237
  Height = 209
  object rgEditPlot: TWebRadioGroup
    Left = 24
    Top = 31
    Width = 160
    Height = 137
    Caption = 'Edit Plot'
    Columns = 1
    ItemIndex = 4
    Items.Strings = (
      'Toggle Legend'
      'Toggle Autoscale'
      'Edit Y axis min-max'
      'Change plot species'
      'Cancel')
    Role = ''
  end
  object btnOk: TWebButton
    Left = 176
    Top = 0
    Width = 53
    Height = 25
    Caption = 'OK'
    ChildOrder = 1
    HeightPercent = 100.000000000000000000
    WidthPercent = 100.000000000000000000
    OnClick = btnOkClick
  end
end
