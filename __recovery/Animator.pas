unit Animator;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

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
    rhAngle1 : integer;
    rhAngle2 : integer;
    lhAngle1 : integer;
    lhAngle2 : integer;
    rlAngle1 : integer;
    rlAngle2 : integer;
    llAngle1 : integer;
    llAngle2 : integer;
    hasDisk: Boolean;
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
  (x: 50;  y: 400; scale: 1),    // Стартовая позиция
  (x: 400; y: 250; scale: 1.2),  // Подход к дискам
  (x: 410; y: 310; scale: 1.2),  // Взятие диска
  (x: 800; y: 350; scale: 1)   // Отход с диском
);

frames : Array[0..7] of FrameData =
(
  (rhAngle1: 70;  rhAngle2: -90;
   lhAngle1: 70; lhAngle2: 90;
   rlAngle1: -70; rlAngle2: -40;
   llAngle1: -70;  llAngle2: 20;
   hasDisk: False),

  // Кадр 1: Промежуточное положение
  (rhAngle1: 70;  rhAngle2: -90;
   lhAngle1: 70; lhAngle2: 90;
   rlAngle1: -90; rlAngle2: 0;
   llAngle1: -90;  llAngle2: 0;
   hasDisk: False),

   (rhAngle1: 70;  rhAngle2: -90;
   lhAngle1: 70; lhAngle2: 90;
   rlAngle1: -70; rlAngle2: -40;
   llAngle1: -70;  llAngle2: 20;
   hasDisk: False),

  // Кадр 2: Центральная позиция
  (rhAngle1: 60;   rhAngle2: -45;
   lhAngle1: 60;   lhAngle2: 45;
   rlAngle1: -90;   rlAngle2: 0;
   llAngle1: -90;   llAngle2: 0;
   hasDisk: False),

  (rhAngle1: 80; rhAngle2: -90;
   lhAngle1: 80;  lhAngle2: 90;
   rlAngle1: -90;  rlAngle2: 0;
   llAngle1: -90; llAngle2: 0;
   hasDisk: False),

  // Кадр 4: Промежуточное положение
  (rhAngle1: 70; rhAngle2: 90;
   lhAngle1: 70;  lhAngle2: -90;
   rlAngle1: -70;  rlAngle2: -40;
   llAngle1: -70; llAngle2: 20;
   hasDisk: False),

  (rhAngle1: 70; rhAngle2: 40;
  lhAngle1: 70; lhAngle2: -40;
   rlAngle1: -90; rlAngle2: 0;
   llAngle1: -90; llAngle2: 0;
   hasDisk: True),

  (rhAngle1: 70;   rhAngle2: 0;
  lhAngle1: 70; lhAngle2: 0;
   rlAngle1: -70; rlAngle2: -40;
   llAngle1: -70; llAngle2: 20;
   hasDisk: True)
 );

Deg2Rad = Pi / 180;

lineWidth = 2;
bodyHeight = 80;
headRadius = 20;

armHeight = 65;
armLen = 40;
legLen = 50;

var
  targetFrame, targetPos : integer;
  currentPos: PositionData;
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
  Rect.Left := 0;
  Rect.Top := 0;
  Rect.Right := Width;
  Rect.Bottom := Height div 2;
  Canvas.Brush.Color := clSkyBlue;
  Canvas.FillRect(Rect);

  // Пол
  Rect.Left := 0;
  Rect.Top := Height div 2;
  Rect.Right := Width;
  Rect.Bottom := Height;
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
end;

procedure RecalculatePosition();
var mult : real;
begin
  if Form2.TargetTimer.Enabled then
  begin
  mult := Form2.DrawTimer.Interval / Form2.TargetTimer.Interval;

  currentPos.x:= currentPos.x + Round(mult*(positions[targetPos].x - positions[targetPos-1].x));
  currentPos.y:= currentPos.y + Round(mult*(positions[targetPos].y - positions[targetPos-1].y));
  currentPos.scale:= currentPos.scale + mult*(positions[targetPos].scale - positions[targetPos-1].scale);
  end;
end;

procedure RecalculateFrame();
var mult : real;
begin
  if Form2.FrameTimer.Enabled then
  begin
  mult := Form2.DrawTimer.Interval / Form2.FrameTimer.Interval;

  currentFrame.rhAngle1:= currentFrame.rhAngle1 + Round(mult*(frames[targetFrame].rhAngle1 - frames[targetFrame-1].rhAngle1));
  currentFrame.rhAngle2:= currentFrame.rhAngle2 + Round(mult*(frames[targetFrame].rhAngle2 - frames[targetFrame-1].rhAngle2));

  currentFrame.lhAngle1:= currentFrame.lhAngle1 + Round(mult*(frames[targetFrame].lhAngle1 - frames[targetFrame-1].lhAngle1));
  currentFrame.lhAngle2:= currentFrame.lhAngle2 + Round(mult*(frames[targetFrame].lhAngle2 - frames[targetFrame-1].llAngle2));

  currentFrame.rlAngle1:= currentFrame.rlAngle1 + Round(mult*(frames[targetFrame].rlAngle1 - frames[targetFrame-1].rlAngle1));
  currentFrame.rlAngle2:= currentFrame.rlAngle2 + Round(mult*(frames[targetFrame].rlAngle2 - frames[targetFrame-1].rlAngle2));

  currentFrame.llAngle1:= currentFrame.llAngle1 + Round(mult*(frames[targetFrame].llAngle1 - frames[targetFrame-1].llAngle1));
  currentFrame.llAngle2:= currentFrame.llAngle2 + Round(mult*(frames[targetFrame].llAngle2 - frames[targetFrame-1].llAngle2));
  end;
end;

function Ceil(Value: Extended): Integer;
begin
  if Value > Trunc(Value) then
    Result := Trunc(Value) + 1
  else
    Result := Trunc(Value);
end;

procedure RedrawFrame(canvas : TCanvas; pos : PositionData; frame : FrameData);
var head, handY, middleX, middleY : integer;
begin
  canvas.Pen.Width := Ceil(lineWidth * pos.scale);        //настройка пера
  canvas.Pen.Color := clBlack;

  canvas.MoveTo(pos.x, pos.y);                            //тело
  canvas.LineTo(pos.x, pos.y - Round(pos.scale * bodyHeight));

  head := Round(headRadius * pos.scale);                  //голова
  Form2.Canvas.Ellipse(pos.x - head, pos.y - Round(pos.scale * bodyHeight),
  pos.x + head, pos.y - Round(pos.scale * bodyHeight) - 2 * head);

  handY := pos.y - Round(pos.scale * armHeight);          //руки

  canvas.MoveTo(pos.x, handY);                                      //правая
  middleX := pos.x + Round(pos.scale * armLen * cos(frame.rhAngle1* Deg2Rad));
  middleY := handY + Round(pos.scale * armLen * sin(frame.rhAngle1* Deg2Rad));
  canvas.LineTo(middleX, middleY);
  canvas.LineTo(middleX + Round(pos.scale * armLen * cos(frame.rhAngle1* Deg2Rad + frame.rhAngle2* Deg2Rad)),
  middleY + Round(pos.scale * armLen * sin(frame.rhAngle1* Deg2Rad + frame.rhAngle2* Deg2Rad)));

  canvas.MoveTo(pos.x, handY);                                      //левая
  middleX := pos.x - Round(pos.scale * armLen * cos(frame.lhAngle1* Deg2Rad));
  middleY := handY + Round(pos.scale * armLen * sin(frame.lhAngle1* Deg2Rad));
  canvas.LineTo(middleX, middleY);
  canvas.LineTo(middleX - Round(pos.scale * armLen * cos(frame.lhAngle1* Deg2Rad + frame.lhAngle2* Deg2Rad)),
  middleY + Round(pos.scale * armLen * sin(frame.lhAngle1* Deg2Rad + frame.lhAngle2* Deg2Rad)));

                                                           //ноги

  canvas.MoveTo(pos.x, pos.y);                                      //правая
  middleX := pos.x + Round(pos.scale * legLen * cos(frame.rlAngle1* Deg2Rad));
  middleY := pos.y - Round(pos.scale * legLen * sin(frame.rlAngle1* Deg2Rad));
  canvas.LineTo(middleX, middleY);
  canvas.LineTo(middleX + Round(pos.scale * legLen * cos(frame.rlAngle1* Deg2Rad + frame.rlAngle2* Deg2Rad)),
  middleY - Round(pos.scale * legLen * sin(frame.rlAngle1* Deg2Rad + frame.rlAngle2* Deg2Rad)));

  canvas.MoveTo(pos.x, pos.y);                                      //левая
  middleX := pos.x - Round(pos.scale * legLen * cos(frame.llAngle1* Deg2Rad));
  middleY := pos.y - Round(pos.scale * legLen * sin(frame.llAngle1* Deg2Rad));
  canvas.LineTo(middleX, middleY);
  canvas.LineTo(middleX - Round(pos.scale * legLen * cos(frame.llAngle1* Deg2Rad + frame.llAngle2* Deg2Rad)),
  middleY - Round(pos.scale * legLen * sin(frame.llAngle1* Deg2Rad + frame.llAngle2* Deg2Rad)));
end;

procedure TForm2.ChangeFrame(Sender: TObject);
begin
  if targetFrame < Length(frames) - 1 then
    Inc(targetFrame)
  else
    TTimer(Sender).Enabled :=  false;
end;


procedure TForm2.ChangeMoveTarget(Sender: TObject);
begin
  if targetPos < Length(positions) - 1 then
    Inc(targetPos)
  else
    TTimer(Sender).Enabled :=  false;
end;

procedure TForm2.DrawFrame(Sender: TObject);
begin
  Form2.Canvas.Pen.Color := clWhite;
  Form2.Canvas.FillRect(ClientRect);
  DrawBG(Form2.Canvas, ClientWidth, ClientHeight);
  RecalculatePosition();
  RecalculateFrame();
  RedrawFrame(Form2.Canvas, currentPos, currentFrame);
end;


procedure TForm2.Init(Sender: TObject);
begin
  targetPos := 1;
  targetFrame := 1;

  currentPos := positions[0];
  currentFrame := frames[0];

  DrawBG(Form2.Canvas, ClientWidth, ClientHeight);
end;

end.
