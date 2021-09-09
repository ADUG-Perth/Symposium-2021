unit Formula.Operators;

interface

uses
  System.Generics.Collections, BatSoft.Context, Formula;

type
  TPlus = class(TBinary)
  public
    function Evaluate(Context: IContext): Double; override;
  end;

  TMinus = class(TBinary)
  public
    function Evaluate(Context: IContext): Double; override;
  end;

  TMultiply = class(TBinary)
  public
    function Evaluate(Context: IContext): Double; override;
  end;

  TDivide = class(TBinary)
  public
    function Evaluate(Context: IContext): Double; override;
  end;

procedure RegisterFormulaOperators;

implementation

uses
  System.SysUtils, System.Classes;

procedure RegisterFormulaOperators;
begin
  FormulaBuilder.Register(['*'],
    function (const Reader: TStringReader; out Ident: TToken): Boolean
    begin
      Reader.Read;
      Ident   := TMultiply.Create;
      Result  := True;
    end);

  FormulaBuilder.Register(['/'],
    function (const Reader: TStringReader; out Ident: TToken): Boolean
    begin
      Reader.Read;
      Ident   := TDivide.Create;
      Result  := True;
    end);

  FormulaBuilder.Register(['+'],
    function (const Reader: TStringReader; out Ident: TToken): Boolean
    begin
      Reader.Read;
      Ident   := TPlus.Create;
      Result  := True;
    end);

  FormulaBuilder.Register(['-'],
    function (const Reader: TStringReader; out Ident: TToken): Boolean
    begin
      Reader.Read;
      Ident   := TMinus.Create;
      Result  := True;
    end);

end;

{ TPlus }

function TPlus.Evaluate(Context: IContext): Double;
begin
  Result  := Left.Evaluate(Context) + Right.Evaluate(Context)
end;

{ TMinus }

function TMinus.Evaluate(Context: IContext): Double;
begin
  Result  := Left.Evaluate(Context) - Right.Evaluate(Context)
end;

{ TMultiply }

function TMultiply.Evaluate(Context: IContext): Double;
begin
  Result  := Left.Evaluate(Context) * Right.Evaluate(Context)
end;

{ TDivide }

function TDivide.Evaluate(Context: IContext): Double;
begin
  Result  := Left.Evaluate(Context) / Right.Evaluate(Context)
end;

end.
