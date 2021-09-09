unit Formula.Values;

interface

uses
  System.Generics.Collections, BatSoft.Context, Formula;

type
  TNumber = class(TToken)
  var
    fNumber: Double;
  public
    constructor Create(const ANumber: Double);
    function Evaluate(Context: IContext): Double; override;
  end;

  TVariable = class(TToken)
  var
    fName: string;
  public
    constructor Create(const AName: string);
    function Evaluate(Context: IContext): Double; override;
  end;

procedure RegisterFormulaValues;

implementation

uses
  System.SysUtils, System.Classes;

const
  Numeric = ['0'..'9', '.'];
  Alpha   = ['a'..'z', 'A'..'Z'];

procedure RegisterFormulaValues;
begin
  FormulaBuilder.Register(Numeric,
    function (const Reader: TStringReader; out Ident: TToken): Boolean
    var
      Str: string;
      Val: Double;
    begin
      Str := '';
      while CharInSet(Char(Reader.Peek), Numeric) do
        Str := Str + Char(Reader.Read);
      Result  := TryStrToFloat(Str, Val);
      if  Result  then
        Ident := TNumber.Create(Val);
    end);

  FormulaBuilder.Register(Alpha,
    function (const Reader: TStringReader; out Ident: TToken): Boolean
    var
      Str: string;
    begin
      Str := '';
      while CharInSet(Char(Reader.Peek), Alpha) do
        Str := Str + Char(Reader.Read);
      Ident   := TVariable.Create(Str);
      Result  := True;
    end);
end;

{ TNumber }

constructor TNumber.Create(const ANumber: Double);
begin
  inherited Create();
  fNumber := ANumber;
end;

function TNumber.Evaluate(Context: IContext): Double;
begin
  Result  := fNumber
end;

{ TVariable }

constructor TVariable.Create(const AName: string);
begin
  inherited Create();
  fName := AName;
end;

function TVariable.Evaluate(Context: IContext): Double;
begin
  Result  := Context.GetValue(fName).AsExtended
end;

end.
