object Form2: TForm2
  Left = 0
  Top = 0
  Caption = '2'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = Init
  TextHeight = 15
  object FrameTimer: TTimer
    Interval = 2000
    OnTimer = ChangeFrame
    Left = 472
    Top = 384
  end
  object TargetTimer: TTimer
    Interval = 5000
    OnTimer = ChangeMoveTarget
    Left = 568
    Top = 384
  end
  object DrawTimer: TTimer
    Interval = 100
    OnTimer = DrawFrame
    Left = 384
    Top = 384
  end
end
