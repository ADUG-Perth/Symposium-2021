unit uDecorator;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  BatSoft.Classes, BatSoft.Context, uField;

type
  TDecoratorRunner = reference to procedure (Context: IContext; Decorator: IInterface);

  TDecorators = class
  private
    fDecorators: TInterfaceList;
    function GetCount: integer;
    function GetItems(const Index: integer): IInterface;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure Run(Context: IContext; const Runner: TDecoratorRunner);
    //  Management
    procedure Add(Decorator: IInterface; Context: IContext);
    procedure Insert(Decorator: IInterface; Context: IContext; const Index: integer);
    procedure Remove(Decorator: IInterface);
    property  Count : integer read GetCount;
    property  Items[const Index: integer]: IInterface read GetItems; default;
  end;

  TRegisteredDecorators = class
  private
    fFlyweights: TDictionary<string, IInterface>;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure Register(const Name: string; const Flyweight: IInterface);
    function  Obtain(const Name: string): IInterface;
    procedure List(const Strs: TStrings);
  end;

  IInitialise = interface
    ['{81629293-C26C-4902-BECA-A3F26D90D7E6}']
    procedure Initialise(Context: IContext);
  end;

  IClassName = interface
    ['{A70EEBA3-7656-47B6-A808-23B2F8406AFA}']
    function GetClassName: string;
  end;

implementation

{ TDecorators }

procedure TDecorators.Add(Decorator: IInterface; Context: IContext);
var
  Init: IInitialise;
begin
  fDecorators.Add(Decorator);
  if  Supports(Decorator, IInitialise, Init)  then
    Init.Initialise(Context);
end;

constructor TDecorators.Create;
begin
  inherited;
  fDecorators := TInterfaceList.Create;
end;

destructor TDecorators.Destroy;
begin
  fDecorators.Free;
  inherited;
end;

function TDecorators.GetCount: integer;
begin
  Result  := fDecorators.Count
end;

function TDecorators.GetItems(const Index: integer): IInterface;
begin
  Result  := fDecorators[Index]
end;

procedure TDecorators.Insert(Decorator: IInterface; Context: IContext; const Index: integer);
var
  Init: IInitialise;
begin
  fDecorators.Insert(Index, Decorator);
  if  Supports(Decorator, IInitialise, Init)  then
    Init.Initialise(Context);
end;

procedure TDecorators.Remove(Decorator: IInterface);
begin
  fDecorators.Remove(Decorator)
end;

procedure TDecorators.Run(Context: IContext; const Runner: TDecoratorRunner);
var
  i: integer;
begin
  for i := 0 to fDecorators.Count - 1 do
    Runner(Context, fDecorators[i]);
end;

{ TRegisteredDecorators }

constructor TRegisteredDecorators.Create;
begin
  inherited;
  fFlyweights  := TDictionary<string, IInterface>.Create;
end;

destructor TRegisteredDecorators.Destroy;
begin
  fFlyweights.Free;
  inherited;
end;

procedure TRegisteredDecorators.List(const Strs: TStrings);
var
  Name: string;
begin
  Strs.Clear;
  for Name in fFlyweights.Keys do
    Strs.Add(Name);
end;

function TRegisteredDecorators.Obtain(const Name: string): IInterface;
begin
  if  not fFlyweights.TryGetValue(UpperCase(Name), Result) then
    Result  := nil
end;

procedure TRegisteredDecorators.Register(const Name: string; const Flyweight: IInterface);
begin
  fFlyweights.AddOrSetValue(UpperCase(Name), Flyweight)
end;

end.
