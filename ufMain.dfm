object MainForm: TMainForm
  Width = 865
  Height = 680
  OnCreate = WebFormCreate
  OnDestroy = WebFormDestroy
  OnExit = WebFormExit
  OnResize = WebFormResize
  object pnlSimInfo: TWebPanel
    Left = 806
    Top = 50
    Width = 59
    Height = 406
    Align = alRight
    object pnlModelInfo: TWebPanel
      Left = 0
      Top = 0
      Width = 59
      Height = 45
      Align = alTop
      BorderColor = clBtnFace
      ChildOrder = 3
      ExplicitWidth = 57
      DesignSize = (
        59
        45)
      object btnModelInfo: TWebButton
        Left = 4
        Top = 10
        Width = 50
        Height = 30
        Hint = 'Model information, if available.'
        Anchors = [akRight]
        Caption = 'Info'
        ChildOrder = 2
        HeightPercent = 100.000000000000000000
        ShowHint = True
        WidthPercent = 100.000000000000000000
        OnClick = btnModelInfoClick
        ExplicitLeft = 2
      end
    end
    object pnlEditGraph: TWebPanel
      Left = 0
      Top = 45
      Width = 59
      Height = 45
      Align = alTop
      BorderColor = clBtnFace
      ChildOrder = 3
      ExplicitWidth = 57
      object btnEditGraph: TWebButton
        Left = 2
        Top = 10
        Width = 50
        Height = 30
        Hint = 'Change species, update Y axis'
        Caption = 'Plot'
        ChildOrder = 2
        HeightPercent = 100.000000000000000000
        ShowHint = True
        WidthPercent = 100.000000000000000000
        OnClick = btnEditGraphClick
      end
    end
    object pnlExample: TWebPanel
      Left = 0
      Top = 135
      Width = 59
      Height = 45
      Align = alTop
      BorderColor = clBtnFace
      ChildOrder = 3
      ExplicitWidth = 57
      DesignSize = (
        59
        45)
      object btnExample: TWebButton
        Left = 10
        Top = 10
        Width = 45
        Height = 30
        Hint = 'Load example model.'
        Anchors = [akRight]
        Caption = 'Ex.'
        ChildOrder = 3
        HeightPercent = 100.000000000000000000
        ShowHint = True
        WidthPercent = 100.000000000000000000
        OnClick = btnExampleClick
        ExplicitLeft = 8
      end
    end
    object pnlEditSliders: TWebPanel
      Left = 0
      Top = 90
      Width = 59
      Height = 45
      Align = alTop
      BorderColor = clBtnFace
      ChildOrder = 3
      ExplicitWidth = 57
      object btnEditSliders: TWebButton
        Left = 2
        Top = 10
        Width = 50
        Height = 30
        Hint = 'Chose different parameter sliders'
        Caption = 'Slider'
        HeightPercent = 100.000000000000000000
        ShowHint = True
        WidthPercent = 100.000000000000000000
        OnClick = btnEditSlidersClick
      end
    end
  end
  object pnlPlot: TWebPanel
    Left = 0
    Top = 50
    Width = 806
    Height = 406
    Align = alClient
    ChildOrder = 1
    ExplicitWidth = 808
  end
  object pnlTop: TWebPanel
    Left = 0
    Top = 0
    Width = 865
    Height = 50
    Align = alTop
    ChildOrder = 3
    object pnlSimSpeedMult: TWebPanel
      Left = 189
      Top = 0
      Width = 139
      Height = 50
      Hint = 'Speed up simulation, limited by browser resources.'
      Align = alLeft
      ChildOrder = 5
      ShowHint = True
      object lblSpeedMult: TWebLabel
        Left = 10
        Top = 5
        Width = 98
        Height = 13
        Hint = 'Speed up/down simulation'
        Caption = 'Sim Speed Multiplier:'
        HeightPercent = 100.000000000000000000
        WidthPercent = 100.000000000000000000
      end
      object lblSpeedMultVal: TWebLabel
        Left = 112
        Top = 5
        Width = 12
        Height = 13
        Caption = '1x'
        HeightPercent = 100.000000000000000000
        WidthPercent = 100.000000000000000000
      end
      object lblSpeedMultMin: TWebLabel
        Left = 10
        Top = 23
        Width = 22
        Height = 13
        Caption = '0.1x'
        HeightPercent = 100.000000000000000000
        WidthPercent = 100.000000000000000000
      end
      object lblSpeedMultMax: TWebLabel
        Left = 115
        Top = 23
        Width = 12
        Height = 13
        Caption = '3x'
        HeightPercent = 100.000000000000000000
        WidthPercent = 100.000000000000000000
      end
      object trackBarSimSpeed: TWebTrackBar
        Left = 38
        Top = 30
        Width = 70
        Height = 0
        ElementClassName = 'slider'
        HeightStyle = ssPercent
        HeightPercent = 10.000000000000000000
        Max = 30
        Min = 1
        Position = 10
        Role = ''
        OnChange = trackBarSimSpeedChange
      end
    end
    object pnlRunTime: TWebPanel
      Left = 393
      Top = 0
      Width = 65
      Height = 50
      Hint = 'Set simulation run time. Static run only.'
      Align = alLeft
      BorderColor = clBtnFace
      ChildOrder = 7
      ShowHint = True
      object lblRunTime: TWebLabel
        Left = 5
        Top = 5
        Width = 48
        Height = 13
        Caption = 'Run Time:'
        HeightPercent = 100.000000000000000000
        WidthPercent = 100.000000000000000000
      end
      object editRunTime: TWebEdit
        Left = 5
        Top = 20
        Width = 55
        Height = 20
        ChildOrder = 1
        HeightPercent = 100.000000000000000000
        WidthPercent = 100.000000000000000000
        OnExit = editRunTimeExit
      end
    end
    object pnlLoadModel: TWebPanel
      Left = 0
      Top = 0
      Width = 65
      Height = 50
      Align = alLeft
      BorderColor = clBtnFace
      ChildOrder = 8
      object btnLoadModel: TWebButton
        Left = 7
        Top = 10
        Width = 55
        Height = 30
        Hint = 'Load SBML model'
        Caption = 'SBML'
        ElementClassName = 'btn btn-primary btn-sm'
        HeightPercent = 100.000000000000000000
        ShowHint = True
        WidthPercent = 100.000000000000000000
        OnClick = btnLoadModelClick
      end
    end
    object pnlSimReset: TWebPanel
      Left = 129
      Top = 0
      Width = 60
      Height = 50
      Align = alLeft
      BorderColor = clBtnFace
      ChildOrder = 8
      object btnSimReset: TWebButton
        Left = 1
        Top = 10
        Width = 55
        Height = 30
        Hint = 'Reset simulation'
        Caption = 'Reset '
        ChildOrder = 1
        ElementClassName = 'btn btn-dark btn-sm'
        HeightPercent = 100.000000000000000000
        ShowHint = True
        WidthPercent = 100.000000000000000000
        OnClick = btnSimResetClick
      end
    end
    object pnlRunPause: TWebPanel
      Left = 65
      Top = 0
      Width = 64
      Height = 50
      Align = alLeft
      BorderColor = clBtnFace
      ChildOrder = 8
      object btnRunPause: TWebButton
        Left = 3
        Top = 10
        Width = 55
        Height = 30
        Hint = 'Run model'
        Caption = 'Run'
        ElementClassName = 'btn btn-dark btn-sm'
        HeightPercent = 100.000000000000000000
        ShowHint = True
        WidthPercent = 100.000000000000000000
        OnClick = btnRunPauseClick
      end
    end
    object pnlStepSize: TWebPanel
      Left = 328
      Top = 0
      Width = 65
      Height = 50
      Hint = 'Integrator step size. 1000 = 1 time unit (usually sec)'
      Align = alLeft
      BorderColor = clBtnFace
      ChildOrder = 8
      ShowHint = True
      DesignSize = (
        65
        50)
      object lblStepSize: TWebLabel
        Left = 8
        Top = 5
        Width = 50
        Height = 14
        Caption = 'Step (ms):'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        HeightPercent = 100.000000000000000000
        ParentFont = False
        WidthPercent = 100.000000000000000000
      end
      object edtStepSize: TWebEdit
        Left = 10
        Top = 20
        Width = 50
        Height = 20
        Hint = 'Change step size for integrator.'
        Anchors = [akLeft]
        ChildOrder = 3
        HeightPercent = 100.000000000000000000
        ShowHint = False
        Text = '100'
        WidthPercent = 100.000000000000000000
        OnExit = edtStepSizeExit
      end
    end
    object pnlStaticSim: TWebPanel
      Left = 458
      Top = 0
      Width = 80
      Height = 50
      Align = alLeft
      BorderColor = clBtnFace
      ChildOrder = 7
      DesignSize = (
        80
        50)
      object chkbxStaticSimRun: TWebCheckBox
        Left = 5
        Top = 13
        Width = 100
        Height = 22
        Hint = 'Plot results after simulation is complete.'
        Anchors = [akLeft]
        Caption = 'Static Run'
        ChildOrder = 7
        Color = clNone
        HeightPercent = 100.000000000000000000
        ShowHint = True
        State = cbUnchecked
        WidthPercent = 100.000000000000000000
        OnClick = chkbxStaticSimRunClick
      end
    end
  end
  object pnlParamSliders: TWebPanel
    Left = 0
    Top = 456
    Width = 865
    Height = 224
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
