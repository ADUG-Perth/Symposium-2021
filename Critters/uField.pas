unit uField;

interface

uses
  System.Types, System.Math.Vectors, System.UITypes, FMX.Graphics, FMX.Controls;

type
  TField = class(TControl)
  private
    fBackgroundColour: TAlphaColor;
  protected
    procedure Paint; override;
  public
    property  BackgroundColour  : TAlphaColor read fBackgroundColour  write fBackgroundColour;
    function  CreateTransform(const Scale, Rotation: Single; const Translation: TPointF): TMatrix;
    procedure DrawShape(const PathData: TPathData; const Transform: TMatrix; Pen: TStrokeBrush = nil);
    procedure FillShape(const PathData: TPathData; const Transform: TMatrix; Brush: TBrush = nil);
  end;

implementation

uses
  System.Math;

{ TField }

function TField.CreateTransform(const Scale, Rotation: Single; const Translation: TPointF): TMatrix;
begin
  Result  := TMatrix.CreateScaling(Scale, Scale) *
             TMatrix.CreateRotation(DegToRad(Rotation)) *
             TMatrix.CreateTranslation(Translation.X, Translation.Y);
end;

procedure TField.DrawShape(const PathData: TPathData; const Transform: TMatrix; Pen: TStrokeBrush);
var
  Transformed: TPathData;
begin
  //  Transform the Shape
  Transformed := TPathData.Create;
  try
    Transformed.AddPath(PathData);
    Transformed.ApplyMatrix(Transform);
    //  Draw the shape
    if  not Assigned(Pen)  then
      Pen  := Canvas.Stroke;
    Canvas.DrawPath(Transformed, 1, Pen);
    //  Tidy up
  finally
    Transformed.Free;
  end;
end;

procedure TField.FillShape(const PathData: TPathData; const Transform: TMatrix; Brush: TBrush);
var
  Transformed: TPathData;
begin
  //  Transform the Shape
  Transformed := TPathData.Create;
  try
    Transformed.AddPath(PathData);
    Transformed.ApplyMatrix(Transform);
    //  Paint the shape
    if  not Assigned(Brush) then
      Brush   := Canvas.Fill;
    Canvas.FillPath(Transformed, 1, Brush);
    //  Tidy up
  finally
    Transformed.Free;
  end;
end;

procedure TField.Paint;
begin
  inherited;
  Canvas.ClearRect(BoundsRect, fBackgroundColour);
end;

end.
