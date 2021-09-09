unit uCritter;

interface

uses
  System.Types, Generics.Collections, FMX.Graphics, BatSoft.Context, uDecorator, uField;

type
  TCritter = class
  private
    fPosition: TPointF;
    fDirection: Single;
    fScale: Single;
    fShape: TPathData;
    fDecorators: TDecorators;
    fContext: IContext;
    fContextValues, fContextProperties: IContext;
  public
    constructor Create(Context: IContext);
    destructor  Destroy; override;
    //  Placement
    property  Shape       : TPathData   read fShape       write fShape;
    property  Scale       : Single      read fScale       write fScale;
    property  Position    : TPointF     read fPosition    write fPosition;
    property  Direction   : Single      read fDirection   write fDirection;
    //  Decorators
    property  Decorators  : TDecorators read fDecorators;
    //  Context
    property  Context     : IContext    read fContext;
    //  - Used only for demo purposes
    property  ContextValues     : IContext  read fContextValues;
    property  ContextProperties : IContext  read fContextProperties;
    //  Tools
    function  ContainsPoint(const Point: TPointF; out Distance: Single): Boolean;
  end;

  TCritters = class(TObjectList<TCritter>)
  public
    function  AtPosition(const Point: TPointF): TCritter;
    procedure Step;
    procedure Draw(const Field: TField);
  end;

  IStep = interface
    ['{013BB093-0937-4E0D-B047-E577D9DE89FD}']
    procedure Step(Critter: TCritter);
  end;

  IDraw = interface
    ['{A3A70ABA-EE90-460F-8A60-013E2D3875C5}']
    procedure Draw(Critter: TCritter; const Field: TField);
  end;

var
  CritterDecorators: TRegisteredDecorators;

implementation

uses
  System.SysUtils, System.Math, System.Classes, BatSoft.Context.Objects;

{ TCritter }

function TCritter.ContainsPoint(const Point: TPointF; out Distance: Single): Boolean;
begin
  Distance  := Sqrt(Sqr(Point.X - Position.X) + Sqr(Point.Y - Position.Y));
  Result    := Distance < Scale;
end;

constructor TCritter.Create(Context: IContext);
begin
  inherited Create;
  fDecorators := TDecorators.Create;
  //  Contexts
  fContextValues      := TContextValues.Create;
  fContextProperties  := TContextObject.Create(Self);
  fContext    := TContexts.Create([Context, fContextValues, fContextProperties]);
end;

destructor TCritter.Destroy;
begin
  fDecorators.Free;
  inherited;
end;

{ TCritters }

function TCritters.AtPosition(const Point: TPointF): TCritter;
var
  Item: TCritter;
  MinDist, NewDist: Single;
begin
  MinDist := MaxSingle;
  Result  := nil;
  for Item in Self do
    if  Item.ContainsPoint(Point, NewDist)  then
      if  MinDist > NewDist then
        begin
          MinDist := NewDist;
          Result  := Item;
        end;
end;

procedure TCritters.Draw(const Field: TField);
begin
  for var Critter in Self do
    Critter.Decorators.Run(Critter.Context,
        procedure (Context: IContext; Decorator: IInterface)
        var
          Draw: IDraw;
        begin
          if Supports(Decorator, IDraw, Draw) then
            Draw.Draw(Critter, Field);
        end)
end;

procedure TCritters.Step;
begin
  for var Critter in Self do
    Critter.Decorators.Run(Critter.Context,
        procedure (Context: IContext; Decorator: IInterface)
        var
          Turn: IStep;
        begin
          if  Supports(Decorator, IStep, Turn)  then
            Turn.Step(Critter);
        end)
end;

initialization
  CritterDecorators := TRegisteredDecorators.Create;

finalization
  CritterDecorators.Free;

end.
