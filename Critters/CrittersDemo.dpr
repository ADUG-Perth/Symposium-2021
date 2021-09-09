program CrittersDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  uField in 'uField.pas',
  FCritters in 'FCritters.pas' {frmCritters},
  uDecorator in 'uDecorator.pas',
  uDecorator.Behaviour in 'uDecorator.Behaviour.pas',
  uDecorator.Painting in 'uDecorator.Painting.pas',
  uCritter in 'uCritter.pas',
  uShape in 'uShape.pas',
  uShape.Simple in 'uShape.Simple.pas',
  FrContext in 'FrContext.pas' {frameContext: TFrame},
  ValueEditors in 'ValueEditors.pas';

{$R *.res}

begin
  RegisterShapes;
  Application.Initialize;
  Application.CreateForm(TfrmCritters, frmCritters);
  Application.Run;
end.
