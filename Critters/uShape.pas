unit uShape;

interface

uses
  System.Classes, Generics.Collections, FMX.Graphics;

type
  TShapeBuilder = reference to procedure (const PathData: TPathData);

  TShapeRegister = class
  private
    fShapes: TDictionary<string, TPathData>;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure Register(const Name: string; Builder: TShapeBuilder);
    function  ByName(const ShapeName: string): TPathData;
    procedure List(const Strs: TStrings);
  end;

var
  ShapeRegister: TShapeRegister;

implementation

uses
  System.SysUtils;

{ TShapeRegister }

function TShapeRegister.ByName(const ShapeName: string): TPathData;
begin
  if  not fShapes.TryGetValue(UpperCase(ShapeName), Result)  then
    Result  := nil;
end;

constructor TShapeRegister.Create;
begin
  inherited;
  fShapes := TDictionary<string, TPathData>.Create;
end;

destructor TShapeRegister.Destroy;
begin
  for var Shape in fShapes.Values do
    Shape.Free;
  fShapes.Free;
  inherited;
end;

procedure TShapeRegister.List(const Strs: TStrings);
begin
  Strs.Clear;
  for var Shape in fShapes  do
    Strs.AddObject(Shape.Key, Shape.Value);
end;

procedure TShapeRegister.Register(const Name: string; Builder: TShapeBuilder);
var
  Shape: TPathData;
begin
  Shape := TPathData.Create;
  try
    Builder(Shape);
  except
    Shape.Free;
    raise;
  end;
  fShapes.AddOrSetValue(UpperCase(Name), Shape);
end;

initialization
  ShapeRegister := TShapeRegister.Create;

finalization
  ShapeRegister.Free;

end.
