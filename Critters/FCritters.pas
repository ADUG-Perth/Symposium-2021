unit FCritters;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Effects,
  FMX.Filter.Effects, FMX.ListBox, BatSoft.Context, uCritter, uField,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FrContext, FMX.Edit;

type
  TfrmCritters = class(TForm)
    loField: TLayout;
    grpField: TGroupBox;
    swRun: TSwitch;
    timRun: TTimer;
    butStep: TButton;
    grpOptions: TGroupBox;
    cmbShapes: TComboBox;
    labShapes: TLabel;
    loOptionsLabels: TLayout;
    loOptionsControls: TLayout;
    grpContexts: TGroupBox;
    loControls: TLayout;
    Splitter1: TSplitter;
    grpRunning: TGroupBox;
    frameContextForm: TframeContext;
    frameContextValues: TframeContext;
    frameContextCritter: TframeContext;
    cmbDecorators: TComboBox;
    Label1: TLabel;
    butRefresh: TButton;
    grpDecorators: TGroupBox;
    lstDecorators: TListBox;
    butAddDecorator: TButton;
    cmbVariableType: TComboBox;
    Label2: TLabel;
    butVariableAdd: TButton;
    edVariableName: TEdit;
    Label3: TLabel;
    butVariableDel: TButton;
    butCreateNewCritter: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure swRunSwitch(Sender: TObject);
    procedure RunATurn(Sender: TObject);
    procedure butRefreshClick(Sender: TObject);
    procedure butAddDecoratorClick(Sender: TObject);
    procedure butVariableAddClick(Sender: TObject);
    procedure butVariableDelClick(Sender: TObject);
    procedure butCreateNewCritterClick(Sender: TObject);
  private
    fField: TField;
    fContext: IContext;
    fCritters: TCritters;
    fSelected: TCritter;
    procedure FieldMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure FieldPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    function  CreateAndAddCritter(const Size, Turn, X, Y: Single; const ShapeName: string): TCritter;
    procedure PopulateCritterInfo;
    procedure RefreshView;
  end;

var
  frmCritters: TfrmCritters;

implementation

{$R *.fmx}

uses
  System.Rtti, System.TypInfo, uShape, uDecorator;

{ TfrmCritters }

procedure TfrmCritters.butAddDecoratorClick(Sender: TObject);
var
  DecName: string;
  Decorator: IInterface;
begin
  if  not Assigned(fSelected) or (cmbDecorators.ItemIndex < 0)  then
    Exit;
  DecName   := cmbDecorators.Items[cmbDecorators.ItemIndex];
  Decorator := CritterDecorators.Obtain(DecName);
  fSelected.Decorators.Add(Decorator, fSelected.Context);
  fField.InvalidateRect(fField.BoundsRect);
  PopulateCritterInfo;
end;

procedure TfrmCritters.butCreateNewCritterClick(Sender: TObject);
var
  ShapeName: string;
begin
  if  cmbShapes.ItemIndex < 0 then
    Exit;
  ShapeName := cmbShapes.Items[cmbShapes.ItemIndex];
  CreateAndAddCritter(30, 0, loField.Width / 2, loField.Height / 2, ShapeName);
  RefreshView;
end;

procedure TfrmCritters.butRefreshClick(Sender: TObject);
begin
  fField.InvalidateRect(fField.BoundsRect);
  PopulateCritterInfo;
end;

procedure TfrmCritters.butVariableAddClick(Sender: TObject);
var
  TypeInfo: PTypeInfo;
  EmptyValue: TValue;
begin
  TypeInfo    := PTypeInfo(cmbVariableType.Items.Objects[cmbVariableType.ItemIndex]);
  EmptyValue  := TValue.Empty.Cast(TypeInfo);
  fSelected.Context.SetValue(edVariableName.Text, EmptyValue);
  RefreshView;
end;

procedure TfrmCritters.butVariableDelClick(Sender: TObject);
begin
  fSelected.ContextValues.DelValue(edVariableName.Text);
  RefreshView;
end;

function TfrmCritters.CreateAndAddCritter(const Size, Turn, X, Y: Single; const ShapeName: string): TCritter;
begin
  Result  := TCritter.Create(fContext);
  Result.Shape      := ShapeRegister.ByName(ShapeName);
  Result.Direction  := Turn;
  Result.Scale      := Size;
  Result.Position   := PointF(X, Y);
  Result.Decorators.Add(CritterDecorators.Obtain('DrawBody'), Result.Context);
  fCritters.Add(Result);
end;

procedure TfrmCritters.FieldMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  fSelected := fCritters.AtPosition(PointF(X, Y));
  //  Update status
  PopulateCritterInfo;
end;

procedure TfrmCritters.FieldPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
begin
  //  Reset the pen and brush
  Canvas.Stroke.Thickness := 2;
  Canvas.Stroke.Kind      := TBrushKind.Solid;
  Canvas.Stroke.Dash      := TStrokeDash.Solid;
  Canvas.Stroke.Color     := TAlphaColorRec.Green;
  Canvas.Fill.Color       := TAlphaColorRec.Yellow;
  //  Draw
  fCritters.Draw(fField);
end;

procedure TfrmCritters.FormCreate(Sender: TObject);
var
  Critter: TCritter;
begin
  //  Create playing field
  fField  := TField.Create(Self);
  fField.Parent := loField;
  fField.Align  := TAlignLayout.Client;
  fField.BackgroundColour := TAlphaColorRec.Wheat;
  fField.OnPaint          := FieldPaint;
  fField.OnMouseDown      := FieldMouseDown;
  //  Populate controls
  ShapeRegister.List(cmbShapes.Items);
  CritterDecorators.List(cmbDecorators.Items);

  cmbVariableType.Items.AddObject('Text', TypeInfo(string));
  cmbVariableType.Items.AddObject('Number', TypeInfo(Single));
  cmbVariableType.Items.AddObject('Colour', TypeInfo(TAlphaColor));
  cmbVariableType.Items.AddObject('Point', TypeInfo(TPoint));

  //  Create context
  fContext  := TContextValues.Create;
  fContext.SetValue('Pen',   TValue.From<TAlphaColor>(TAlphaColorRec.Green));
  fContext.SetValue('Brush', TValue.From<TAlphaColor>(TAlphaColorRec.Yellow));
  frameContextForm.Context := fContext;

  //  Create critters
  fCritters  := TCritters.Create(True);
  //  Critter 1
  Critter := CreateAndAddCritter(30, 30, 200, 200, 'Diamond');
  Critter.Decorators.Add(CritterDecorators.Obtain('MoveForwards'), Critter.Context);
  Critter.Decorators.Add(CritterDecorators.Obtain('Turn'), Critter.Context);
  Critter.Context.SetValue('Speed', 3.0);
  //  Critter 2
  Critter := CreateAndAddCritter(30, 0, 100, 100, 'Diamond');
  Critter.Decorators.Add(CritterDecorators.Obtain('MoveForwards'), Critter.Context);
  Critter.Decorators.Add(CritterDecorators.Obtain('DrawTail'), Critter.Context);
  Critter.Decorators.Add(CritterDecorators.Obtain('DrawFins'), Critter.Context);
  Critter.Context.SetValue('Speed', 5.0);

  PopulateCritterInfo;
end;

procedure TfrmCritters.FormDestroy(Sender: TObject);
begin
  fCritters.Free;
end;

procedure TfrmCritters.PopulateCritterInfo;
var
  i: integer;
  Obj: IClassName;
begin
  //  Decorators
  lstDecorators.BeginUpdate;
  try
    lstDecorators.Items.Clear;
    if  Assigned(fSelected) then
      for i := 0 to fSelected.Decorators.Count - 1 do
        if Supports(fSelected.Decorators[i], IClassName, Obj) then
          lstDecorators.Items.Add(Obj.GetClassName);
  finally
    lstDecorators.EndUpdate;
  end;
  //  Contexts
  frameContextForm.Context  := fContext;
  if  Assigned(fSelected) then
    begin
      frameContextValues.Context  := fSelected.ContextValues;
      frameContextCritter.Context := fSelected.ContextProperties;
    end
  else
    begin
      frameContextValues.Context  := nil;
      frameContextCritter.Context := nil;
    end;
  //  Controls
  cmbVariableType.Enabled := Assigned(fSelected);
  edVariableName.Enabled  := Assigned(fSelected);
  butVariableAdd.Enabled  := Assigned(fSelected);
end;

procedure TfrmCritters.RefreshView;
begin
  fField.InvalidateRect(fField.BoundsRect);
  PopulateCritterInfo;
end;

procedure TfrmCritters.RunATurn(Sender: TObject);
begin
  fCritters.Step;
  RefreshView;
end;

procedure TfrmCritters.swRunSwitch(Sender: TObject);
begin
  timRun.Enabled  := swRun.IsChecked;
end;

end.
