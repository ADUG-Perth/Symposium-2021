program CalculatorDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  FCalculator in 'FCalculator.pas' {frmCalculator},
  Formula in 'Formula.pas',
  Formula.Operators in 'Formula.Operators.pas',
  Formula.Values in 'Formula.Values.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmCalculator, frmCalculator);
  Application.Run;
end.
