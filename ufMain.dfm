object MainForm: TMainForm
  Width = 865
  Height = 681
  OnCreate = WebFormCreate
  OnResize = WebFormResize
  object pnlModelInfo: TWebPanel
    Left = 760
    Top = 60
    Width = 105
    Height = 371
    Align = alRight
    object btnShowInitVals: TWebButton
      Left = 16
      Top = 54
      Width = 70
      Height = 25
      Caption = 'Init Vals'
      ChildOrder = 4
      HeightPercent = 100.000000000000000000
      WidthPercent = 100.000000000000000000
      OnClick = btnShowInitValsClick
    end
    object btnShowRates: TWebButton
      Left = 16
      Top = 96
      Width = 70
      Height = 25
      Caption = 'Rate laws'
      ChildOrder = 3
      HeightPercent = 100.000000000000000000
      WidthPercent = 100.000000000000000000
      OnClick = btnShowRatesClick
    end
    object btnModelInfo: TWebButton
      Left = 16
      Top = 6
      Width = 70
      Height = 25
      Caption = 'Model Info'
      ChildOrder = 2
      HeightPercent = 100.000000000000000000
      WidthPercent = 100.000000000000000000
      OnClick = btnModelInfoClick
    end
  end
  object pnlPlot: TWebPanel
    Left = 0
    Top = 60
    Width = 760
    Height = 371
    Align = alClient
    ChildOrder = 1
    ExplicitLeft = 241
    ExplicitWidth = 624
    ExplicitHeight = 378
  end
  object pnlParamSliders: TWebPanel
    Left = 0
    Top = 431
    Width = 865
    Height = 250
    Align = alBottom
    ChildOrder = 2
    ExplicitTop = 438
  end
  object pnlTop: TWebPanel
    Left = 0
    Top = 0
    Width = 865
    Height = 60
    Align = alTop
    ChildOrder = 3
    object lblStepSize: TWebLabel
      Left = 701
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
      Left = 336
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
      Left = 779
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
    object btnLoadModel: TWebButton
      Left = 24
      Top = 16
      Width = 113
      Height = 25
      Caption = 'Load SBML Model'
      HeightPercent = 100.000000000000000000
      WidthPercent = 100.000000000000000000
      OnClick = btnLoadModelClick
    end
    object pnlSimSpeedMult: TWebPanel
      Left = 465
      Top = 4
      Width = 198
      Height = 50
      Hint = 'Speed up simulation, limited by computer resources.'
      ChildOrder = 5
      ShowHint = True
      object lblSpeedMult: TWebLabel
        Left = 35
        Top = 8
        Width = 98
        Height = 13
        Hint = 'Speed up/down simulation'
        Caption = 'Sim Speed Multiplier:'
        HeightPercent = 100.000000000000000000
        WidthPercent = 100.000000000000000000
      end
      object lblSpeedMultVal: TWebLabel
        Left = 137
        Top = 8
        Width = 12
        Height = 13
        Caption = '1x'
        HeightPercent = 100.000000000000000000
        WidthPercent = 100.000000000000000000
      end
      object lblSpeedMultMin: TWebLabel
        Left = 16
        Top = 30
        Width = 22
        Height = 13
        Caption = '0.1x'
        HeightPercent = 100.000000000000000000
        WidthPercent = 100.000000000000000000
      end
      object lblSpeedMultMax: TWebLabel
        Left = 170
        Top = 30
        Width = 12
        Height = 13
        Caption = '3x'
        HeightPercent = 100.000000000000000000
        WidthPercent = 100.000000000000000000
      end
      object trackBarSimSpeed: TWebTrackBar
        Left = 43
        Top = 27
        Width = 121
        Height = 20
        Max = 30
        Min = 1
        Position = 10
        Role = ''
        OnChange = trackBarSimSpeedChange
      end
    end
  end
  object SBMLOpenDialog: TWebOpenDialog
    OnChange = SBMLOpenDialogChange
    OnGetFileAsText = SBMLOpenDialogGetFileAsText
    Left = 273
    Top = 608
  end
end
