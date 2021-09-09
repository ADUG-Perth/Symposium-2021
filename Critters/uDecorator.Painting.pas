unit uDecorator.Painting;

interface

uses
  System.Types, System.Math.Vectors, FMX.Graphics, BatSoft.Context, uCritter, uDecorator, uField;

type
  TDrawBody = class(TInterfacedObject, IDraw, IClassName)
  public
    procedure Draw(Critter: TCritter; const Field: TField);
    function GetClassName: string;
  end;

  TFillBody = class(TInterfacedObject, IDraw, IClassName)
  public
    procedure Draw(Critter: TCritter; const Field: TField);
    function GetClassName: string;
  end;

  //  Used by subsequent classes
  IDrawExtra = interface
    ['{F5637C88-97F8-4BBC-A2FB-AC773FBB7E56}']
    procedure DrawShape(const Shape: TPathData; const Critter: TCritter; const Field: TField);
  end;

  //  Used by subsequent classes
  TDrawExtra = class abstract(TInterfacedObject, IDrawExtra, IClassName)
  private
    fScale: Single;
    fRotation: Single;
    fPosition: TPointF;
  public
    constructor Create(const AScale, ARotation: Single; const APosition: TPointF);
    procedure DrawShape(const Shape: TPathData; const Critter: TCritter; const Field: TField);
    function GetClassName: string;
  end;

  TDrawTail = class(TDrawExtra, IInitialise, IDraw)
  public
    constructor Create;
    procedure Initialise(Context: IContext);
    procedure Draw(Critter: TCritter; const Field: TField);
  end;

  TDrawFins = class(TInterfacedObject, IDraw, IClassName)
  private
    fLeft, fRight: IDrawExtra;
  public
    constructor Create;
    procedure Draw(Critter: TCritter; const Field: TField);
    function GetClassName: string;
  end;

procedure RegisterCritterPainting;

implementation

uses
  System.UITypes, FMX.Controls, uShape;

//  Recurring const value names
const
  TAIL_SHAPE  = 'TailShape';

procedure RegisterCritterPainting;
begin
  CritterDecorators.Register('DrawBody', TDrawBody.Create);
  CritterDecorators.Register('FillBody', TFillBody.Create);
  CritterDecorators.Register('DrawTail', TDrawTail.Create);
  CritterDecorators.Register('DrawFins', TDrawFins.Create);
end;

{ TDrawBody }

procedure TDrawBody.Draw(Critter: TCritter; const Field: TField);
var
  Transform: TMatrix;
  int: Cardinal;
begin
  int := Critter.Context.GetValue('Pen').AsInt64;
  Field.Canvas.Stroke.Color := int;
//  Field.Canvas.Stroke.Color := Critter.Context.GetValue('Pen').AsType<TAlphaColor>();
  Transform := Field.CreateTransform(Critter.Scale, Critter.Direction, Critter.Position);
  Field.DrawShape(Critter.Shape, Transform);
end;

function TDrawBody.GetClassName: string;
begin
  Result  := ClassName
end;

{ TFillBody }

procedure TFillBody.Draw(Critter: TCritter; const Field: TField);
var
  Transform: TMatrix;
begin
  Field.Canvas.Fill.Color := Critter.Context.GetValue('Brush').AsType<TAlphaColor>();
  Transform := Field.CreateTransform(Critter.Scale, Critter.Direction, Critter.Position);
  Field.FillShape(Critter.Shape, Transform);
end;

function TFillBody.GetClassName: string;
begin
  Result  := ClassName
end;

{ TDrawExtra }

constructor TDrawExtra.Create(const AScale, ARotation: Single; const APosition: TPointF);
begin
  inherited Create;
  fScale    := AScale;
  fRotation := ARotation;
  fPosition := APosition;
end;

procedure TDrawExtra.DrawShape(const Shape: TPathData; const Critter: TCritter; const Field: TField);
var
  Transform: TMatrix;
begin
  Transform :=
    Field.CreateTransform(fScale, fRotation, fPosition) *
    Field.CreateTransform(Critter.Scale, Critter.Direction, Critter.Position);
  Field.DrawShape(Shape, Transform);
end;

function TDrawExtra.GetClassName: string;
begin
  Result  := ClassName
end;

{ TDrawTail }

constructor TDrawTail.Create;
begin
  inherited Create(0.5, 0, PointF(-1, 0))
end;

procedure TDrawTail.Draw(Critter: TCritter; const Field: TField);
var
  TailShapeName: string;
  Transform: TMatrix;
  TailShape: TPathData;
begin
  Transform := Field.CreateTransform(Critter.Scale, Critter.Direction, Critter.Position);
  TailShapeName := Critter.Context.GetValue(TAIL_SHAPE).AsString;
  TailShape := ShapeRegister.ByName(TailShapeName);
  DrawShape(TailShape, Critter, Field)
end;

procedure TDrawTail.Initialise(Context: IContext);
begin
  if  not Context.HasValue(TAIL_SHAPE)  then
    Context.SetValue(TAIL_SHAPE, 'Diamond');
end;

{ TDrawFins }

constructor TDrawFins.Create;
begin
  inherited;
  fLeft   := TDrawExtra.Create(0.5, -90, PointF(0,  1));
  fRight  := TDrawExtra.Create(0.5,  90, PointF(0, -1));
end;

procedure TDrawFins.Draw(Critter: TCritter; const Field: TField);
var
  Shape: TPathData;
begin
  Shape := ShapeRegister.ByName('Circle');
  fLeft.DrawShape(Shape, Critter, Field);
  fRight.DrawShape(Shape, Critter, Field);
end;

function TDrawFins.GetClassName: string;
begin
  Result  := ClassName
end;

initialization
  RegisterCritterPainting;

end.
