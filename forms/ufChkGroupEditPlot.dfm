object fChkGroupEditPlot: TfChkGroupEditPlot
  Width = 232
  Height = 269
  Color = clCream
  ElementClassName = ' '
  ElementFont = efCSS
  object chkGrpEditPlot: TWebCheckGroup
    Left = 14
    Top = 8
    Width = 126
    Height = 81
    Caption = 'Edit Plot:'
    Columns = 1
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    Items.Strings = (
      'View Legend'
      'Autoscale')
    ParentFont = False
    Role = ''
  end
  object btnOkPlotEdit: TWebButton
    Left = 95
    Top = 217
    Width = 45
    Height = 30
    Caption = 'OK'
    ChildOrder = 1
    ElementClassName = 'btn btn-primary btn-sm'
    HeightPercent = 100.000000000000000000
    WidthPercent = 100.000000000000000000
    OnClick = btnOkPlotEditClick
  end
  object pnlYAxisMinMax: TWebPanel
    Left = 14
    Top = 103
    Width = 203
    Height = 60
    ChildOrder = 6
    Color = clCream
    object lblYAxisMin: TWebLabel
      Left = 10
      Top = 26
      Width = 35
      Height = 14
      Caption = 'Y min:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      HeightPercent = 100.000000000000000000
      ParentFont = False
      WidthPercent = 100.000000000000000000
    end
    object lblYAxisMax: TWebLabel
      Left = 100
      Top = 26
      Width = 38
      Height = 14
      Caption = 'Y max:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      HeightPercent = 100.000000000000000000
      ParentFont = False
      WidthPercent = 100.000000000000000000
    end
    object lblEditYAxis: TWebLabel
      Left = 8
      Top = 0
      Width = 128
      Height = 14
      Caption = 'Update Y axis min-max:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      HeightPercent = 100.000000000000000000
      ParentFont = False
      WidthPercent = 100.000000000000000000
    end
    object editYAxisMin: TWebEdit
      Left = 52
      Top = 24
      Width = 30
      Height = 22
      ChildOrder = 5
      HeightPercent = 100.000000000000000000
      Text = '0'
      WidthPercent = 100.000000000000000000
    end
    object editYAxisMax: TWebEdit
      Left = 145
      Top = 24
      Width = 40
      Height = 22
      ChildOrder = 4
      HeightPercent = 100.000000000000000000
      Text = '2'
      WidthPercent = 100.000000000000000000
    end
  end
  object btnChangePlotSp: TWebButton
    Left = 14
    Top = 175
    Width = 126
    Height = 30
    Caption = 'Edit plot species'
    ChildOrder = 3
    ElementClassName = 'btn btn-outline-secondary btn-sm'
    HeightPercent = 100.000000000000000000
    WidthPercent = 100.000000000000000000
    OnClick = btnChangePlotSpClick
  end
end
