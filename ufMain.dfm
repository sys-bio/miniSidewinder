object MainForm: TMainForm
  Width = 865
  Height = 693
  OnCreate = WebFormCreate
  object pnlModelInfo: TWebPanel
    Left = 0
    Top = 60
    Width = 241
    Height = 633
    Align = alLeft
    object labelInitVals: TWebLabel
      Left = 24
      Top = 64
      Width = 176
      Height = 16
      Caption = 'Initial values and assignments:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      HeightPercent = 100.000000000000000000
      ParentFont = False
      WidthPercent = 100.000000000000000000
    end
    object labelRateLaws: TWebLabel
      Left = 24
      Top = 240
      Width = 139
      Height = 16
      Caption = 'Reaction and Rate laws:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      HeightPercent = 100.000000000000000000
      ParentFont = False
      WidthPercent = 100.000000000000000000
    end
    object btnLoadModel: TWebButton
      Left = 56
      Top = 16
      Width = 113
      Height = 25
      Caption = 'Load SBML Model'
      HeightPercent = 100.000000000000000000
      WidthPercent = 100.000000000000000000
      OnClick = btnLoadModelClick
    end
    object lb_InitVals: TWebListBox
      Left = 24
      Top = 86
      Width = 185
      Height = 134
      HeightPercent = 100.000000000000000000
      ItemHeight = 13
      WidthPercent = 100.000000000000000000
      ItemIndex = -1
    end
    object lbRateLaws: TWebListBox
      Left = 24
      Top = 262
      Width = 185
      Height = 163
      HeightPercent = 100.000000000000000000
      ItemHeight = 13
      WidthPercent = 100.000000000000000000
      ItemIndex = -1
    end
  end
  object pnlPlot: TWebPanel
    Left = 241
    Top = 60
    Width = 436
    Height = 633
    Align = alClient
    ChildOrder = 1
    object SliderEditLB: TWebListBox
      Left = 328
      Top = 264
      Width = 121
      Height = 97
      HeightPercent = 100.000000000000000000
      ItemHeight = 13
      WidthPercent = 100.000000000000000000
      OnClick = SliderEditLBClick
      ItemIndex = -1
    end
  end
  object pnlParamSliders: TWebPanel
    Left = 677
    Top = 60
    Width = 188
    Height = 633
    Align = alRight
    ChildOrder = 2
  end
  object pnlTop: TWebPanel
    Left = 0
    Top = 0
    Width = 865
    Height = 60
    Align = alTop
    ChildOrder = 3
    object btnRunPause: TWebButton
      Left = 241
      Top = 16
      Width = 128
      Height = 25
      Caption = 'Run model'
      HeightPercent = 100.000000000000000000
      WidthPercent = 100.000000000000000000
      OnClick = btnRunPauseClick
    end
    object btnSimReset: TWebButton
      Left = 624
      Top = 16
      Width = 96
      Height = 25
      Caption = 'Reset '
      ChildOrder = 1
      HeightPercent = 100.000000000000000000
      WidthPercent = 100.000000000000000000
      OnClick = btnSimResetClick
    end
  end
  object SBMLOpenDialog: TWebOpenDialog
    OnChange = SBMLOpenDialogChange
    OnGetFileAsText = SBMLOpenDialogGetFileAsText
    Left = 273
    Top = 608
  end
end
