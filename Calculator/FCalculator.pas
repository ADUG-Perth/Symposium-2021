unit FCalculator;

interface

uses
  FMX.Forms, FMX.StdCtrls, System.Classes, FMX.Types, FMX.Controls,
  FMX.Controls.Presentation, FMX.Edit;

type
  TfrmCalculator = class(TForm)
    edFormula: TEdit;
    butCalculate: TButton;
    edResult: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure butCalculateClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCalculator: TfrmCalculator;

implementation

{$R *.fmx}

uses
  System.SysUtils, Formula, Formula.Operators, Formula.Values;

{ TfrmCalculator }

procedure TfrmCalculator.butCalculateClick(Sender: TObject);
var
  Formula: TToken;
begin
  Formula := FormulaBuilder.Build(edFormula.Text);
  try
    edResult.Text := Formula.Evaluate(nil).ToString
  finally
    Formula.Free;
  end;
end;

procedure TfrmCalculator.FormCreate(Sender: TObject);
begin
  RegisterFormulaOperators;
  RegisterFormulaValues;
end;

end.
