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
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
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

procedure DrawBG(canvas : TCanvas; Width, Height: Integer);
var
  Rect, WindowRect, BoxRect: TRect;
  WindowWidth, WindowHeight, BoxWidth, BoxHeight, i: Integer;
  Disks: Integer;
  LevelHeight: Integer; // Высота одного уровня
  BaseWidth: Integer; // Ширина основания пирамиды
  CurrentWidth: Integer; // Текущая ширина уровня
  CurrentLeft: Integer; // Отступ слева для текущего уровня
begin

  //стена
  Rect.Left := 0;
  Rect.Top := 0;
  Rect.Right := Width;
  Rect.Bottom := Height div 2;
  Canvas.Brush.Color := clSilver;
  Canvas.FillRect(Rect);
  //пол
  Rect.Left := 0;
  Rect.Top := Height div 2;
  Rect.Right := Width;
  Rect.Bottom := Height;
  Canvas.Brush.Color := clBlue;
  Canvas.FillRect(Rect);
  //окно
  WindowWidth := Width div 3;
  WindowHeight := Height div 3;
  WindowRect.Left := 550;
  WindowRect.Top := 50;
  WindowRect.Right := WindowRect.Left + WindowWidth;
  WindowRect.Bottom := WindowRect.Top + WindowHeight;
  //фон окна
  Canvas.Brush.Color := clWhite;
  Canvas.FillRect(WindowRect);

  //рамка окна
  Canvas.Pen.Color := clBlack;
  Canvas.Pen.Width := 2;
  Canvas.Rectangle(WindowRect);

  //решётка вертикальная
  Canvas.MoveTo(WindowRect.Left + WindowWidth div 2, WindowRect.Top);
  Canvas.LineTo(WindowRect.Left + WindowWidth div 2, WindowRect.Bottom);

  // решётка горизонтальная
  Canvas.MoveTo(WindowRect.Left, WindowRect.Top + WindowHeight div 2);
  Canvas.LineTo(WindowRect.Right, WindowRect.Top + WindowHeight div 2);

  // диски
  Disks := 4; // Количество дисков
  LevelHeight := 20; // Высота одного диска
  BaseWidth := 200; // Ширина основания первого диска
  CurrentWidth := BaseWidth; // Начинаем с основания

  for i := 0 to Disks - 1 do
  begin
    //отступ
    CurrentLeft := (Width - CurrentWidth) div 2;

    //сам диск
    BoxRect.Left := CurrentLeft;
    BoxRect.Top := Height - (i + 1) * LevelHeight - 90; // Высота от пола
    BoxRect.Right := BoxRect.Left + CurrentWidth;
    BoxRect.Bottom := Height - 85;
    Canvas.Brush.Color := clBlack;
    Canvas.FillRect(BoxRect);

    // Уменьшаем ширину для следующего уровня
    CurrentWidth := CurrentWidth - 40; // Ширина уменьшается на 40 пикселей
  end;

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



procedure TForm2.FormPaint(Sender: TObject);
begin
   DrawBG(Form2.Canvas, ClientWidth, ClientHeight);
end;

procedure TForm2.FormResize(Sender: TObject);
begin
    Invalidate;
end;

procedure TForm2.Init(Sender: TObject);
begin
  targetPos := 1;
  frameId := 0;

  currentPos := positions[0];
  DrawBG(Form2.Canvas, ClientWidth, ClientHeight);
end;

end.
