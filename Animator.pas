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
<<<<<<< Updated upstream
    bodyHeight : integer;
=======
    rhAngle1 : integer;
    rhAngle2 : integer;
    lhAngle1 : integer;
    lhAngle2 : integer;
    rlAngle1 : integer;
    rlAngle2 : integer;
    llAngle1 : integer;
    llAngle2 : integer;
    hasDisk: Boolean;
>>>>>>> Stashed changes
  End;

  PositionData = Record
    x, y : integer;
    scale : real;
  End;

var
  Form2: TForm2;
implementation

const
positions : Array[0..3] of PositionData =
(
  (x: 50;  y: 200; scale: 1),    // Стартовая позиция
  (x: 400; y: 400; scale: 1.2),  // Подход к дискам
  (x: 410; y: 300; scale: 1.2),  // Взятие диска
  (x: 800; y: 350; scale: 1)   // Отход с диском
);

<<<<<<< Updated upstream
frames : Array[0..0] of FrameData =
(
  (bodyHeight : 100)
);
=======
frames : Array[0..3] of FrameData =
(
  (rhAngle1: 0;   rhAngle2: 0;  lhAngle1: 0; lhAngle2: 0;
   rlAngle1: 0; rlAngle2: 0;   llAngle1: 0; llAngle2: 0; hasDisk: False),
  (rhAngle1: 0; rhAngle2: 0; lhAngle1: 0; lhAngle2: 0;
   rlAngle1: 0; rlAngle2: 0;   llAngle1: 0; llAngle2: 0; hasDisk: False),
  (rhAngle1: 130; rhAngle2: -80; lhAngle1: -40; lhAngle2: 0;
   rlAngle1: -30; rlAngle2: 0;   llAngle1: -60; llAngle2: 50; hasDisk: True),
  (rhAngle1: 0;   rhAngle2: 45;  lhAngle1: -30; lhAngle2: 60;
   rlAngle1: -60; rlAngle2: 0;   llAngle1: -60; llAngle2: 0; hasDisk: True)
 );
>>>>>>> Stashed changes

var
  frameId, targetPos : integer;
  currentPos: PositionData;
<<<<<<< Updated upstream

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
=======
  currentFrame : FrameData;
  Disks: array of TRect;
  DiskActive: array of Boolean;
{$R *.dfm}

procedure DrawBG(canvas: TCanvas; Width, Height: Integer);
var
  Rect, CloudRect, BoxRect: TRect;
  i, CloudX, CloudY, CloudSize: Integer;
  Disks: Integer;
  LevelHeight: Integer;
  BaseWidth: Integer;
  CurrentWidth: Integer;
  CurrentLeft: Integer;
begin
  // Небо
>>>>>>> Stashed changes
  Rect.Left := 0;
  Rect.Top := 0;
  Rect.Right := Width;
  Rect.Bottom := Height div 2;
<<<<<<< Updated upstream
  Canvas.Brush.Color := clSilver;
  Canvas.FillRect(Rect);
  //пол
=======
  Canvas.Brush.Color := clSkyBlue;
  Canvas.FillRect(Rect);

  // Пол
>>>>>>> Stashed changes
  Rect.Left := 0;
  Rect.Top := Height div 2;
  Rect.Right := Width;
  Rect.Bottom := Height;
<<<<<<< Updated upstream
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
=======
  Canvas.Brush.Color := clGreen;  // Изменим цвет пола на зеленый для травы
  Canvas.FillRect(Rect);

  // Рисуем облака
  Canvas.Pen.Color := clWhite;
  Canvas.Brush.Color := clWhite;

  // Первое облако
  CloudX := 50;
  CloudY := 80;
  CloudSize := 40;
  Canvas.Ellipse(CloudX, CloudY, CloudX + CloudSize, CloudY + CloudSize);
  Canvas.Ellipse(CloudX + 20, CloudY - 15, CloudX + 70, CloudY + 30);
  Canvas.Ellipse(CloudX + 50, CloudY, CloudX + 90, CloudY + 40);

  // Второе облако
  CloudX := 300;
  CloudY := 120;
  Canvas.Ellipse(CloudX, CloudY, CloudX + 60, CloudY + 50);
  Canvas.Ellipse(CloudX + 40, CloudY - 20, CloudX + 100, CloudY + 40);
  Canvas.Ellipse(CloudX + 80, CloudY + 10, CloudX + 130, CloudY + 60);

  // Третье облако (маленькое)
  CloudX := 600;
  CloudY := 60;
  Canvas.Ellipse(CloudX, CloudY, CloudX + 50, CloudY + 40);
  Canvas.Ellipse(CloudX + 30, CloudY - 10, CloudX + 70, CloudY + 30);

  // Диски
  Disks := 4;
  LevelHeight := 20;
  BaseWidth := 200;
  CurrentWidth := BaseWidth;
>>>>>>> Stashed changes

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

<<<<<<< Updated upstream
=======
  {  Canvas.Pen.Color := clBlack;

   Ствол (коричневый прямоугольник)
  Canvas.Brush.Color := RGB(139, 69, 19); // Темно-коричневый
  Canvas.Rectangle(
    100,                               // X левой границы
    Height div 2 - 120,                // Y верхней границы
    120,                               // X правой границы
    Height div 2 + 20                  // Y нижней границы (на поле)
  );

  // Крона (зеленые эллипсы)
  //Canvas.Brush.Color := clGreen;
  //Canvas.Ellipse(50, Height div 2 - 200, 170, Height div 2 - 80);  // Основная крона
  //Canvas.Ellipse(70, Height div 2 - 240, 150, Height div 2 - 120); // Верхний слой
  //Canvas.Ellipse(30, Height div 2 - 180, 130, Height div 2 - 100); // Левый слой }
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
   DrawBG(Form2.Canvas, ClientWidth, ClientHeight);
=======
  Form2.Canvas.Pen.Color := clWhite;
  Form2.Canvas.FillRect(ClientRect);
  DrawBG(Form2.Canvas, ClientWidth, ClientHeight);
  RecalculatePosition();
  RecalculateFrame();
  RedrawFrame(Form2.Canvas, currentPos, currentFrame);
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
=======
  currentFrame := frames[0];

>>>>>>> Stashed changes
  DrawBG(Form2.Canvas, ClientWidth, ClientHeight);
end;

end.
