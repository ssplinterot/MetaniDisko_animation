program CanvasProject;

uses
  System.StartUpCopy,
  FMX.Forms,
  Animator in 'Animator.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
