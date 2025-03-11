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
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  FrameData = Record

    rhAngle1 : real;
    rhAngle2 : real;
    lhAngle1 : real;
    lhAngle2 : real;
    rlAngle1 : real;
    rlAngle2 : real;
    llAngle1 : real;
    llAngle2 : real;

    bodyHeight : integer;

  End;

  PositionData = Record
    x, y : real;
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


frames : Array[0..3] of FrameData =
(
  (rhAngle1 : 0; rhAngle2 : 45; lhAngle1 : -30; lhAngle2 : 60; rlAngle1 : -60; rlAngle2 : 0; llAngle1 : -60; llAngle2 : 0),
  (rhAngle1 : 50; rhAngle2 : 55; lhAngle1 : -40; lhAngle2 : 0; rlAngle1 : -30; rlAngle2 : 0; llAngle1 : -60; llAngle2 : 50),
  (rhAngle1 : 50; rhAngle2 : 55; lhAngle1 : -40; lhAngle2 : 0; rlAngle1 : -30; rlAngle2 : 0; llAngle1 : -60; llAngle2 : 50),
  (rhAngle1 : 50; rhAngle2 : 55; lhAngle1 : -40; lhAngle2 : 0; rlAngle1 : -30; rlAngle2 : 0; llAngle1 : -60; llAngle2 : 50)
);

Deg2Rad = Pi / 180;

lineWidth = 2;
bodyHeight = 80;
headRadius = 20;

armHeight = 65;
armLen = 40;
legLen = 50;

addDiskFrame = 2;
startFlyDiskFrame = 3;
diskSpeedX = 10;
diskSpeedY = 3;

var
  targetFrame, targetPos, diskx1, diskx2, disky1, disky2 : integer;
  currentPos: PositionData;
  currentFrame : FrameData;
  bg, buffer : TBitmap;

{$R *.dfm}

procedure DrawBG(canvas : TCanvas; Width, Height: Integer);
var
  Rect, WindowRect, BoxRect: TRect;
  WindowWidth, WindowHeight, BoxWidth, BoxHeight, i: Integer;
  Disks: Integer;
  LevelHeight: Integer; // ������ ������ ������
  BaseWidth: Integer; // ������ ��������� ��������
  CurrentWidth: Integer; // ������� ������ ������
  CurrentLeft: Integer; // ������ ����� ��� �������� ������
begin

  //�����
  Rect.Left := 0;
  Rect.Top := 0;
  Rect.Right := Width;
  Rect.Bottom := Height div 2;
  Canvas.Brush.Color := clSilver;
  Canvas.FillRect(Rect);
  //���
  Rect.Left := 0;
  Rect.Top := Height div 2;
  Rect.Right := Width;
  Rect.Bottom := Height;
  Canvas.Brush.Color := clBlue;
  Canvas.FillRect(Rect);
  //����
  WindowWidth := Width div 3;
  WindowHeight := Height div 3;
  WindowRect.Left := 550;
  WindowRect.Top := 50;
  WindowRect.Right := WindowRect.Left + WindowWidth;
  WindowRect.Bottom := WindowRect.Top + WindowHeight;
  //��� ����
  Canvas.Brush.Color := clWhite;
  Canvas.FillRect(WindowRect);

  //����� ����
  Canvas.Pen.Color := clBlack;
  Canvas.Pen.Width := 2;
  Canvas.Rectangle(WindowRect);

  //������� ������������
  Canvas.MoveTo(WindowRect.Left + WindowWidth div 2, WindowRect.Top);
  Canvas.LineTo(WindowRect.Left + WindowWidth div 2, WindowRect.Bottom);

  // ������� ��������������
  Canvas.MoveTo(WindowRect.Left, WindowRect.Top + WindowHeight div 2);
  Canvas.LineTo(WindowRect.Right, WindowRect.Top + WindowHeight div 2);

  // �����
  Disks := 4; // ���������� ������
  LevelHeight := 20; // ������ ������ �����
  BaseWidth := 200; // ������ ��������� ������� �����
  CurrentWidth := BaseWidth; // �������� � ���������

  for i := 0 to Disks - 1 do
  begin
    //������
    CurrentLeft := (Width - CurrentWidth) div 2;

    //��� ����
    BoxRect.Left := CurrentLeft;
    BoxRect.Top := Height - (i + 1) * LevelHeight - 90; // ������ �� ����
    BoxRect.Right := BoxRect.Left + CurrentWidth;
    BoxRect.Bottom := Height - 85;
    Canvas.Brush.Color := clBlack;
    Canvas.FillRect(BoxRect);

    // ��������� ������ ��� ���������� ������
    CurrentWidth := CurrentWidth - 40; // ������ ����������� �� 40 ��������
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

procedure RecalculateFrame();
var mult : real;
begin
  if Form2.FrameTimer.Enabled then
  begin
  mult := Form2.DrawTimer.Interval / Form2.FrameTimer.Interval;

  currentFrame.rhAngle1:= currentFrame.rhAngle1 + (mult*(frames[targetFrame].rhAngle1 - frames[targetFrame-1].rhAngle1));
  currentFrame.rhAngle2:= currentFrame.rhAngle2 + (mult*(frames[targetFrame].rhAngle2 - frames[targetFrame-1].rhAngle2));

  currentFrame.lhAngle1:= currentFrame.lhAngle1 + (mult*(frames[targetFrame].lhAngle1 - frames[targetFrame-1].lhAngle1));
  currentFrame.lhAngle2:= currentFrame.lhAngle2 + (mult*(frames[targetFrame].lhAngle2 - frames[targetFrame-1].llAngle2));

  currentFrame.rlAngle1:= currentFrame.rlAngle1 + (mult*(frames[targetFrame].rlAngle1 - frames[targetFrame-1].rlAngle1));
  currentFrame.rlAngle2:= currentFrame.rlAngle2 + (mult*(frames[targetFrame].rlAngle2 - frames[targetFrame-1].rlAngle2));

  currentFrame.llAngle1:= currentFrame.llAngle1 + (mult*(frames[targetFrame].llAngle1 - frames[targetFrame-1].llAngle1));
  currentFrame.llAngle2:= currentFrame.llAngle2 + (mult*(frames[targetFrame].llAngle2 - frames[targetFrame-1].llAngle2));
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
var head, handY, middleX, middleY, hrx, hry, hlx, hly : integer;
begin
  canvas.Pen.Width := Ceil(lineWidth * pos.scale);        //��������� ����
  canvas.Pen.Color := clBlack;
  canvas.Brush.Color := clWhite;

  canvas.MoveTo(Round(pos.x), Round(pos.y));                            //����
  canvas.LineTo(Round(pos.x), Round(pos.y - pos.scale * bodyHeight));

  head := Round(headRadius * pos.scale);                  //������
  canvas.Ellipse(Round(pos.x - head), Round(pos.y - pos.scale * bodyHeight),
  Round(pos.x + head), Round(pos.y - pos.scale * bodyHeight) - 2 * head);

  handY := Round(pos.y - pos.scale * armHeight);          //����

  canvas.MoveTo(Round(pos.x), handY);                                      //������
  middleX := Round(pos.x + pos.scale * armLen * cos(frame.rhAngle1* Deg2Rad));
  middleY := handY + Round(pos.scale * armLen * sin(frame.rhAngle1* Deg2Rad));
  canvas.LineTo(middleX, middleY);
  hrx := middleX + Round(pos.scale * armLen * cos(frame.rhAngle1* Deg2Rad + frame.rhAngle2* Deg2Rad));
  hry :=   middleY + Round(pos.scale * armLen * sin(frame.rhAngle1* Deg2Rad + frame.rhAngle2* Deg2Rad));
  canvas.LineTo(hrx, hry);

  canvas.MoveTo(Round(pos.x), handY);                                      //�����
  middleX := Round(pos.x - pos.scale * armLen * cos(frame.lhAngle1* Deg2Rad));
  middleY := handY + Round(pos.scale * armLen * sin(frame.lhAngle1* Deg2Rad));
  canvas.LineTo(middleX, middleY);
  hlx := middleX - Round(pos.scale * armLen * cos(frame.lhAngle1* Deg2Rad + frame.lhAngle2* Deg2Rad));
  hly := middleY + Round(pos.scale * armLen * sin(frame.lhAngle1* Deg2Rad + frame.lhAngle2* Deg2Rad));
  canvas.LineTo(hlx, hly);

                                                           //����

  canvas.MoveTo(Round(pos.x), Round(pos.y));                                      //������
  middleX := Round(pos.x + pos.scale * legLen * cos(frame.rlAngle1* Deg2Rad));
  middleY := Round(pos.y - pos.scale * legLen * sin(frame.rlAngle1* Deg2Rad));
  canvas.LineTo(middleX, middleY);
  canvas.LineTo(middleX + Round(pos.scale * legLen * cos(frame.rlAngle1* Deg2Rad + frame.rlAngle2* Deg2Rad)),
  middleY - Round(pos.scale * legLen * sin(frame.rlAngle1* Deg2Rad + frame.rlAngle2* Deg2Rad)));

  canvas.MoveTo(Round(pos.x), Round(pos.y));                                      //�����
  middleX := Round(pos.x - pos.scale * legLen * cos(frame.llAngle1* Deg2Rad));
  middleY := Round(pos.y - pos.scale * legLen * sin(frame.llAngle1* Deg2Rad));
  canvas.LineTo(middleX, middleY);
  canvas.LineTo(middleX - Round(pos.scale * legLen * cos(frame.llAngle1* Deg2Rad + frame.llAngle2* Deg2Rad)),
  middleY - Round(pos.scale * legLen * sin(frame.llAngle1* Deg2Rad + frame.llAngle2* Deg2Rad)));

  if targetFrame >= addDiskFrame then
  begin
    if targetFrame >= startFlyDiskFrame then
    begin
      Inc(diskx1, diskSpeedX);
      Inc(diskx2, diskSpeedX);
      Inc(disky1, diskSpeedY);
      Inc(disky2, diskSpeedY);
    end
    else
    begin
      diskX1 := hrx;
      diskX2 := hlx;
      diskY1 := hry;
      diskY2 := hly;
    end;

    canvas.Brush.Color := clBlack;
    canvas.Ellipse(diskx1, disky1, diskx2, disky2);
  end;
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

  RecalculatePosition();
  RecalculateFrame();

  buffer.Canvas.Draw(0, 0, bg);
  RedrawFrame(buffer.Canvas, currentPos, currentFrame);

  Form2.Canvas.Draw(0, 0, buffer);
end;

procedure TForm2.FormPaint(Sender: TObject);
begin
   bg.SetSize(ClientWidth, ClientHeight);
   buffer.SetSize(ClientWidth, ClientHeight);
   DrawBG(bg.Canvas, ClientWidth, ClientHeight);
end;

procedure TForm2.FormResize(Sender: TObject);
begin
    Invalidate;
end;

procedure TForm2.Init(Sender: TObject);
begin
  targetPos := 1;
  targetFrame := 1;

  currentPos := positions[0];
  currentFrame := frames[0];

  currentPos := positions[0];

  bg := TBitMap.Create;
  bg.SetSize(ClientWidth, ClientHeight);
  buffer := TBitMap.Create;
  buffer.SetSize(ClientWidth, ClientHeight);

  DrawBG(bg.Canvas, ClientWidth, ClientHeight);
end;

end.
