object MainForm: TMainForm
  Width = 865
  Height = 680
  OnCreate = WebFormCreate
  OnResize = WebFormResize
  object pnlModelInfo: TWebPanel
    Left = 785
    Top = 60
    Width = 80
    Height = 370
    Align = alRight
    object btnModelInfo: TWebButton
      Left = 10
      Top = 6
      Width = 60
      Height = 25
      Hint = 'Model information, if available.'
      Caption = 'Info'
      ChildOrder = 2
      HeightPercent = 100.000000000000000000
      ShowHint = True
      WidthPercent = 100.000000000000000000
      OnClick = btnModelInfoClick
    end
    object btnExample: TWebButton
      Left = 10
      Top = 64
      Width = 60
      Height = 25
      Hint = 'Load example model.'
      Caption = 'Example'
      ChildOrder = 3
      HeightPercent = 100.000000000000000000
      ShowHint = True
      WidthPercent = 100.000000000000000000
      OnClick = btnExampleClick
    end
  end
  object pnlPlot: TWebPanel
    Left = 0
    Top = 60
    Width = 785
    Height = 370
    Align = alClient
    ChildOrder = 1
  end
  object pnlTop: TWebPanel
    Left = 0
    Top = 0
    Width = 865
    Height = 60
    Align = alTop
    ChildOrder = 3
    object lblStepSize: TWebLabel
      Left = 555
      Top = 21
      Width = 72
      Height = 13
      Caption = 'Step Size (ms):'
      HeightPercent = 100.000000000000000000
      WidthPercent = 100.000000000000000000
    end
    object btnRunPause: TWebButton
      Left = 153
      Top = 16
      Width = 104
      Height = 25
      Caption = 'Run model'
      HeightPercent = 100.000000000000000000
      WidthPercent = 100.000000000000000000
      OnClick = btnRunPauseClick
    end
    object btnSimReset: TWebButton
      Left = 272
      Top = 16
      Width = 73
      Height = 25
      Caption = 'Reset '
      ChildOrder = 1
      HeightPercent = 100.000000000000000000
      WidthPercent = 100.000000000000000000
      OnClick = btnSimResetClick
    end
    object edtStepSize: TWebEdit
      Left = 630
      Top = 18
      Width = 50
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
      Left = 361
      Top = 4
      Width = 170
      Height = 50
      Hint = 'Speed up simulation, limited by browser resources.'
      ChildOrder = 5
      ShowHint = True
      object lblSpeedMult: TWebLabel
        Left = 26
        Top = 8
        Width = 98
        Height = 13
        Hint = 'Speed up/down simulation'
        Caption = 'Sim Speed Multiplier:'
        HeightPercent = 100.000000000000000000
        WidthPercent = 100.000000000000000000
      end
      object lblSpeedMultVal: TWebLabel
        Left = 130
        Top = 8
        Width = 12
        Height = 13
        Caption = '1x'
        HeightPercent = 100.000000000000000000
        WidthPercent = 100.000000000000000000
      end
      object lblSpeedMultMin: TWebLabel
        Left = 13
        Top = 30
        Width = 22
        Height = 13
        Caption = '0.1x'
        HeightPercent = 100.000000000000000000
        WidthPercent = 100.000000000000000000
      end
      object lblSpeedMultMax: TWebLabel
        Left = 150
        Top = 30
        Width = 12
        Height = 13
        Caption = '3x'
        HeightPercent = 100.000000000000000000
        WidthPercent = 100.000000000000000000
      end
      object trackBarSimSpeed: TWebTrackBar
        Left = 41
        Top = 27
        Width = 100
        Height = 20
        Max = 30
        Min = 1
        Position = 10
        Role = ''
        OnChange = trackBarSimSpeedChange
      end
    end
    object chkbxStaticSimRun: TWebCheckBox
      Left = 764
      Top = 18
      Width = 100
      Height = 22
      Caption = 'Static Sim Run'
      ChildOrder = 7
      Color = clNone
      HeightPercent = 100.000000000000000000
      State = cbUnchecked
      WidthPercent = 100.000000000000000000
      OnClick = chkbxStaticSimRunClick
    end
    object pnlRunTime: TWebPanel
      Left = 686
      Top = 9
      Width = 70
      Height = 45
      ChildOrder = 7
      object lblRunTime: TWebLabel
        Left = 10
        Top = 5
        Width = 44
        Height = 13
        Caption = 'Run Time'
        HeightPercent = 100.000000000000000000
        WidthPercent = 100.000000000000000000
      end
      object editRunTime: TWebEdit
        Left = 5
        Top = 22
        Width = 55
        Height = 20
        ChildOrder = 1
        HeightPercent = 100.000000000000000000
        WidthPercent = 100.000000000000000000
        OnExit = editRunTimeExit
      end
    end
  end
  object pnlParamSliders: TWebPanel
    Left = 0
    Top = 430
    Width = 865
    Height = 250
    Align = alBottom
    ChildOrder = 2
  end
  object SBMLOpenDialog: TWebOpenDialog
    OnChange = SBMLOpenDialogChange
    OnGetFileAsText = SBMLOpenDialogGetFileAsText
    Left = 273
    Top = 608
  end
  object graphEditPopup: TWebPopupMenu
    Appearance.HamburgerMenu.Caption = 'Menu'
    Appearance.SubmenuIndicator = '&#9658;'
    Left = 752
    Top = 494
    object ogglelegend1: TMenuItem
      Caption = 'Toggle legend'
      OnClick = ogglelegend1Click
    end
    object oggleautoscale1: TMenuItem
      Caption = 'Toggle auto scale'
      OnClick = oggleautoscale1Click
    end
    object ChangeminmaxYaxis1: TMenuItem
      Caption = 'Change min/max Y axis'
      OnClick = ChangeminmaxYaxis1Click
    end
    object Changeplotspecies1: TMenuItem
      Caption = 'Change plot species'
      OnClick = Changeplotspecies1Click
    end
  end
end
