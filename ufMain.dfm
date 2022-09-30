object MainForm: TMainForm
  Width = 932
  Height = 687
  OnCreate = WebFormCreate
  object pnlModelInfo: TWebPanel
    Left = 0
    Top = 60
    Width = 241
    Height = 627
    Align = alLeft
    ExplicitTop = 72
    ExplicitHeight = 715
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
  end
  object pnlPlot: TWebPanel
    Left = 241
    Top = 60
    Width = 503
    Height = 627
    Align = alClient
    ChildOrder = 1
    ExplicitTop = 72
    ExplicitHeight = 615
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
    Left = 744
    Top = 60
    Width = 188
    Height = 627
    Align = alRight
    ChildOrder = 2
    ExplicitLeft = 750
    ExplicitTop = 72
    ExplicitHeight = 615
  end
  object pnlTop: TWebPanel
    Left = 0
    Top = 0
    Width = 932
    Height = 60
    Align = alTop
    ChildOrder = 3
    ExplicitLeft = 8
    ExplicitTop = 16
    ExplicitWidth = 924
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
