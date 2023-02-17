object fChkGroupEditPlot: TfChkGroupEditPlot
  Width = 190
  Height = 174
  Caption = 'Edit Plot'
  object chkGrpEditPlot: TWebCheckGroup
    Left = 14
    Top = 8
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
    Left = 119
    Top = 134
    Width = 57
    Height = 25
    Caption = 'Ok'
    ChildOrder = 1
    HeightPercent = 100.000000000000000000
    WidthPercent = 100.000000000000000000
    OnClick = btnOkPlotEditClick
  end
end
