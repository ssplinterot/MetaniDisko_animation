unit Animator;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls;

type
  TForm2 = class(TForm)
    FrameTimer: TTimer;
    TargetTimer: TTimer;
    DrawTimer: TTimer;
    procedure ChangeFrame(Sender: TObject);
    procedure Init(Sender: TObject);
    procedure ChangeMoveTarget(Sender: TObject);
    procedure DrawFrame(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  FrameData = Record
    bodyHeight : integer;
  End;

  PositionData = Record
    x, y : integer;
    scale : real;
  End;

var
  Form2: TForm2;

implementation

const
positions : Array[0..2] of PositionData =
(
  (x : 100; y : 100; scale : 1),
  (x : 400; y : 500; scale : 2),
  (x : 800; y : 350; scale : 0.5)
);

frames : Array[0..0] of FrameData =
(
  (bodyHeight : 100)
);

var
  frameId, targetPos : integer;
  currentPos: PositionData;

{$R *.dfm}

procedure DrawBG(canvas : TCanvas);
begin
  //��������� ����
end;

procedure RecalculatePosition();
var mult : real;
begin
  mult := Form2.DrawTimer.Interval / Form2.TargetTimer.Interval;

  currentPos.x:= currentPos.x + Round(mult*(positions[targetPos].x - positions[targetPos-1].x));
  currentPos.y:= currentPos.y + Round(mult*(positions[targetPos].y - positions[targetPos-1].y));
  currentPos.scale:= currentPos.scale + mult*(positions[targetPos].scale - positions[targetPos-1].scale);
end;

procedure RedrawFrame(canvas : TCanvas; pos : PositionData; frame : FrameData);
var headRadius : integer;
begin
  headRadius := Round(40 * pos.scale);
  Form2.Canvas.Pen.Color := clBlack;
  Form2.Canvas.Ellipse(pos.x - headRadius, pos.y - headRadius, pos.x + headRadius, pos.y + headRadius);
end;

procedure TForm2.ChangeFrame(Sender: TObject);
begin
  Inc(frameId);
end;


procedure TForm2.ChangeMoveTarget(Sender: TObject);
begin
  Inc(targetPos);
end;

procedure TForm2.DrawFrame(Sender: TObject);
begin
  Form2.Canvas.Pen.Color := clWhite;
  Form2.Canvas.FillRect(ClientRect);

  RecalculatePosition();
  RedrawFrame(Form2.Canvas, currentPos, frames[0]);
end;

procedure TForm2.Init(Sender: TObject);
begin
  targetPos := 1;
  frameId := 0;

  currentPos := positions[0];
  DrawBG(Form2.Canvas);
end;

end.
