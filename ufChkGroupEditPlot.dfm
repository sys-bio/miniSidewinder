object fChkGroupEditPlot: TfChkGroupEditPlot
  Width = 245
  Height = 223
  Caption = 'Edit Plot'
  object chkGrpEditPlot: TWebCheckGroup
    Left = 14
    Top = 8
    Width = 126
    Height = 97
    Caption = 'Edit Plot'
    Columns = 1
    Items.Strings = (
      'View Legend'
      'Autoscale'
      'Change plot species')
    Role = ''
  end
  object btnOkPlotEdit: TWebButton
    Left = 83
    Top = 177
    Width = 45
    Height = 30
    Caption = 'Ok'
    ChildOrder = 1
    ElementClassName = 'btn btn-primary btn-sm'
    HeightPercent = 100.000000000000000000
    WidthPercent = 100.000000000000000000
    OnClick = btnOkPlotEditClick
  end
  object pnlYAxisMinMax: TWebPanel
    Left = 14
    Top = 111
    Width = 213
    Height = 60
    ChildOrder = 6
    object lblYAxisMin: TWebLabel
      Left = 10
      Top = 26
      Width = 51
      Height = 13
      Caption = 'Y axis min:'
      HeightPercent = 100.000000000000000000
      WidthPercent = 100.000000000000000000
    end
    object lblYAxisMax: TWebLabel
      Left = 105
      Top = 26
      Width = 55
      Height = 13
      Caption = 'Y axis max:'
      HeightPercent = 100.000000000000000000
      WidthPercent = 100.000000000000000000
    end
    object lblEditYAxis: TWebLabel
      Left = 8
      Top = 0
      Width = 134
      Height = 13
      Caption = 'Update Y axis min-max:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      HeightPercent = 100.000000000000000000
      ParentFont = False
      WidthPercent = 100.000000000000000000
    end
    object editYAxisMin: TWebEdit
      Left = 67
      Top = 24
      Width = 30
      Height = 22
      ChildOrder = 5
      HeightPercent = 100.000000000000000000
      Text = '0'
      WidthPercent = 100.000000000000000000
    end
    object editYAxisMax: TWebEdit
      Left = 165
      Top = 24
      Width = 40
      Height = 22
      ChildOrder = 4
      HeightPercent = 100.000000000000000000
      Text = '2'
      WidthPercent = 100.000000000000000000
    end
  end
end
