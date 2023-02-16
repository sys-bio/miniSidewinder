object fChkGroupEditPlot: TfChkGroupEditPlot
  Width = 245
  Height = 235
  object chkGrpEditPlot: TWebCheckGroup
    Left = 32
    Top = 47
    Width = 160
    Height = 113
    Caption = 'Edit Plot'
    Columns = 1
    Items.Strings = (
      'View Legend'
      'Autoscale'
      'Edit Y axis min-max'
      'Change plot species')
    Role = ''
  end
  object btnOkPlotEdit: TWebButton
    Left = 151
    Top = 8
    Width = 57
    Height = 25
    Caption = 'Ok'
    ChildOrder = 1
    HeightPercent = 100.000000000000000000
    WidthPercent = 100.000000000000000000
    OnClick = btnOkPlotEditClick
  end
end
