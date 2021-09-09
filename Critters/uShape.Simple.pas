unit uShape.Simple;

interface

procedure RegisterShapes;

implementation

uses
  System.Types, FMX.Types, FMX.Graphics, uShape;

const
  Diameter  = 2;
  Radius    = Diameter / 2;

procedure AddDirection(PathData: TPathData);
begin
  PathData.MoveTo(PointF(Radius,     0));
  PathData.LineTo(PointF(Radius / 2, 0));
end;

procedure RegisterShapes;
begin
  //  Register rectangle shape
  ShapeRegister.Register('Rectangle',
    procedure (const PathData: TPathData)
    begin
      PathData.AddRectangle(RectF(-Radius, -Radius, Radius, Radius), 0, 0, [], TCornerType.Bevel);
      AddDirection(PathData);
    end);
  //  Register circle shape
  ShapeRegister.Register('Circle',
    procedure (const PathData: TPathData)
    begin
      PathData.AddEllipse(RectF(-Radius, -Radius, Radius, Radius));
      AddDirection(PathData);
    end);
  //  Register diamond shape
  ShapeRegister.Register('Diamond',
    procedure (const PathData: TPathData)
    begin
      PathData.MoveTo(PointF(      0, -Radius));
      PathData.LineTo(PointF( Radius,       0));
      PathData.LineTo(PointF(      0,  Radius));
      PathData.LineTo(PointF(-Radius,       0));
      PathData.LineTo(PointF(      0, -Radius));
      AddDirection(PathData);
    end);
end;

end.
