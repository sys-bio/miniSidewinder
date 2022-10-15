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
    Width = 365
    Height = 633
    Align = alClient
    ChildOrder = 1
  end
  object pnlParamSliders: TWebPanel
    Left = 606
    Top = 60
    Width = 243
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
    object lblStepSize: TWebLabel
      Left = 501
      Top = 21
      Width = 72
      Height = 13
      Caption = 'Step Size (ms):'
      HeightPercent = 100.000000000000000000
      WidthPercent = 100.000000000000000000
    end
    object btnRunPause: TWebButton
      Left = 177
      Top = 16
      Width = 128
      Height = 25
      Caption = 'Run model'
      HeightPercent = 100.000000000000000000
      WidthPercent = 100.000000000000000000
      OnClick = btnRunPauseClick
    end
    object btnSimReset: TWebButton
      Left = 376
      Top = 16
      Width = 96
      Height = 25
      Caption = 'Reset '
      ChildOrder = 1
      HeightPercent = 100.000000000000000000
      WidthPercent = 100.000000000000000000
      OnClick = btnSimResetClick
    end
    object edtStepSize: TWebEdit
      Left = 579
      Top = 18
      Width = 65
      Height = 22
      Hint = 'Change step size for integrator.'
      ChildOrder = 3
      HeightPercent = 100.000000000000000000
      ShowHint = True
      Text = '100'
      WidthPercent = 100.000000000000000000
      OnExit = edtStepSizeExit
    end
  end
  object TMSFNCScrollBar1: TTMSFNCScrollBar
    Left = 849
    Top = 60
    Width = 16
    Height = 633
    Align = alRight
    ParentDoubleBuffered = False
    Color = 15592941
    DoubleBuffered = True
    TabOrder = 4
    Fill.Color = 15592941
    Stroke.Color = 8882055
    Appearance.ThumbFill.Color = 14803425
    Appearance.ScrollButtonLeftFill.Color = 14803425
    Appearance.ScrollButtonRightFill.Color = 14803425
    Appearance.ScrollButtonLeftHoverFill.Color = 16511461
    Appearance.ScrollButtonRightHoverFill.Color = 16511461
    Appearance.ScrollButtonLeftDownFill.Color = 16378843
    Appearance.ScrollButtonRightDownFill.Color = 16378843
    Appearance.ThumbButtonLeftFill.Color = 14803425
    Appearance.ThumbButtonRightFill.Color = 14803425
    Appearance.ThumbButtonLeftHoverFill.Color = 16511461
    Appearance.ThumbButtonRightHoverFill.Color = 16511461
    Appearance.ThumbButtonLeftDownFill.Color = 16378843
    Appearance.ThumbButtonRightDownFill.Color = 16378843
    Appearance.ThumbStroke.Color = 8882055
    Appearance.ScrollButtonLeftStroke.Color = 8882055
    Appearance.ScrollButtonRightStroke.Color = 8882055
    Appearance.ScrollButtonLeftHoverStroke.Color = 11632444
    Appearance.ScrollButtonRightHoverStroke.Color = 11632444
    Appearance.ScrollButtonLeftDownStroke.Color = 11632444
    Appearance.ScrollButtonRightDownStroke.Color = 11632444
    Appearance.ThumbButtonLeftStroke.Color = 8882055
    Appearance.ThumbButtonRightStroke.Color = 8882055
    Appearance.ThumbButtonLeftHoverStroke.Color = 11632444
    Appearance.ThumbButtonRightHoverStroke.Color = 11632444
    Appearance.ThumbButtonLeftDownStroke.Color = 11632444
    Appearance.ThumbButtonRightDownStroke.Color = 11632444
  end
  object SBMLOpenDialog: TWebOpenDialog
    OnChange = SBMLOpenDialogChange
    OnGetFileAsText = SBMLOpenDialogGetFileAsText
    Left = 273
    Top = 608
  end
end
