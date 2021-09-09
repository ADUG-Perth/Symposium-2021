unit Formula;

interface

uses
  System.Classes, System.Generics.Collections, BatSoft.Context;

type
  TToken = class abstract
  public
    function Evaluate(Context: IContext): Double; virtual; abstract;
  end;

  TUnary = class(TToken)
  private
    fRight: TToken;
  public
    destructor  Destroy; override;
    property  Right : TToken read fRight;
  end;

  TBinary = class(TUnary)
  private
    fLeft: TToken;
  public
    destructor  Destroy; override;
    property  Left  : TToken read fLeft;
  end;

  TTokenFactory = reference to function (const Reader: TStringReader; out Ident: TToken): Boolean;

  FormulaBuilder = class
  private type
    TChars  = set of Char;

    TOperator = record
      Chars: TChars;
      TokenCreator: TTokenFactory;
    end;
  private
    class var _Operators: TList<TOperator>;
    class function  PeekMatches(const Reader: TStringReader; const Chars: TChars): Boolean;
    class procedure ReadTokens(const Str: string; const TokenList: TList<TToken>);
    class procedure Restructure(const TokenList: TList<TToken>);
  public
    class constructor Create;
    class destructor  Destroy;
    class function  Build(const Str: string): TToken; overload;
    class procedure Register(const Chars: TChars; const Factory: TTokenFactory);
  end;

implementation

uses
  System.SysUtils;

{ TUnary }

destructor TUnary.Destroy;
begin
  fRight.Free;
  inherited;
end;

{ TBinary }

destructor TBinary.Destroy;
begin
  fLeft.Free;
  inherited;
end;

{ FormulaBuilder }

class function FormulaBuilder.Build(const Str: string): TToken;
var
  TokenList: TList<TToken>;
begin
  TokenList  := TList<TToken>.Create;
  try
    ReadTokens(Str, TokenList);
    Restructure(TokenList);
    //  Done...?
    if  TokenList.Count > 1  then
      raise Exception.Create('Formulaic error');
    Result  := TokenList[0];
    //  Tidy up
  finally
    TokenList.Free;
  end;
end;

class constructor FormulaBuilder.Create;
begin
  inherited;
  _Operators  := TList<TOperator>.Create;
end;

class destructor FormulaBuilder.Destroy;
begin
  _Operators.Free;
  inherited;
end;

class function FormulaBuilder.PeekMatches(const Reader: TStringReader; const Chars: TChars): Boolean;
var
  NextChar: integer;
begin
  Result    := False;
  NextChar  := Reader.Peek;
  for var Char in Chars do
    if  NextChar = Ord(Char)  then
      Exit(True);
end;

class procedure FormulaBuilder.ReadTokens(const Str: string; const TokenList: TList<TToken>);
var
  Reader: TStringReader;
  Token: TToken;
begin
  Reader  := TStringReader.Create(Str);
  try
    //  Read in the operators
    while Reader.Peek > 0 do
      begin
        //  Ignore whitespace
        while PeekMatches(Reader, [' '])  do
          Reader.Read;
        //  Read token
        for var Operator in _Operators  do
          if  PeekMatches(Reader, Operator.Chars) then
            if  Operator.TokenCreator(Reader, Token)  then
              begin
                TokenList.Add(Token);
                Break;
              end;
      end;
  finally
    Reader.Free;
  end;
end;

class procedure FormulaBuilder.Register(const Chars: TChars; const Factory: TTokenFactory);
var
  Operator: TOperator;
begin
  Operator.Chars        := Chars;
  Operator.TokenCreator := Factory;
  _Operators.Add(Operator)
end;

class procedure FormulaBuilder.Restructure(const TokenList: TList<TToken>);
var
  i: integer;
begin
  i := TokenList.Count - 1;
  while i >= 0  do
    begin
      if  TokenList[i] is TUnary then
        (TokenList[i] as TUnary).fRight := TokenList.ExtractAt(i + 1);
      if  TokenList[i] is TBinary then
        begin
          (TokenList[i] as TBinary).fLeft := TokenList[i - 1];
          TokenList.Delete(i - 1);
          Dec(i);
        end;
      Dec(i);
    end;
end;

end.
