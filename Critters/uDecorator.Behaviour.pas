unit uDecorator.Behaviour;

interface

uses
  BatSoft.Context, uCritter, uDecorator, uField;

type
  TMoveForwards = class(TInterfacedObject, IInitialise, IStep, IClassName)
  public
    procedure Initialise(Context: IContext);
    procedure Step(Critter: TCritter);
    function  GetClassName: string;
  end;

  TTurn = class(TInterfacedObject, IInitialise, IStep, IClassName)
  public
    procedure Initialise(Context: IContext);
    procedure Step(Critter: TCritter);
    function  GetClassName: string;
  end;

procedure RegisterCritterBehaviours;

implementation

uses
  System.Types, System.Math, System.Math.Vectors, System.Rtti, FMX.Graphics, uShape;

//  Recurring const value names
const
  SPEED = 'Speed';
  TURN  = 'Turn';

procedure RegisterCritterBehaviours;
begin
  CritterDecorators.Register('MoveForwards', TMoveForwards.Create);
  CritterDecorators.Register('Turn', TTurn.Create);
end;

{ TMoveForwards }

function TMoveForwards.GetClassName: string;
begin
  Result  := ClassName
end;

procedure TMoveForwards.Initialise(Context: IContext);
begin
  if  not Context.HasValue(SPEED) then
    Context.SetValue(SPEED, 1);
end;

procedure TMoveForwards.Step(Critter: TCritter);
var
  Pos: TPointF;
  Dir: Single;
  Spd: Single;
begin
  Pos := Critter.Position;
  Dir := Critter.Direction;
  Spd := Critter.Context.GetValue(SPEED).AsExtended;
  Dir := DegToRad(Dir);
  Pos.X := Pos.X + Spd * Cos(Dir);
  Pos.Y := Pos.Y + Spd * Sin(Dir);
  Critter.Position  := Pos;
end;

{ TTurn }

function TTurn.GetClassName: string;
begin
  Result  := ClassName
end;

procedure TTurn.Initialise(Context: IContext);
begin
  if  not Context.HasValue(TURN) then
    Context.SetValue(TURN, 1);
end;

procedure TTurn.Step(Critter: TCritter);
var
  Dir: Single;
begin
  Dir := Critter.Direction;
  Dir := Dir + Critter.Context.GetValue(TURN).AsExtended;
  Critter.Direction := Dir;
end;

initialization
  RegisterCritterBehaviours;

end.
