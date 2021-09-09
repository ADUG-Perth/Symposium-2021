unit ValueEditors;

interface

uses
  System.Classes, BatSoft.Context, FrContext, FMX.Controls, FMX.Edit, FMX.SpinBox, FMX.Colors;

type
  TTextEditor = class(TEdit, IValueEditor)
  private
    fContext: IContext;
    fVariableName: string;
    procedure Change(Sender: TObject);
  public
    //  IValueEditor interface
    procedure EditValue(Context: IContext; const VariableName: string);
  end;

  TNumberEditor = class(TEdit, IValueEditor)
  private
    fContext: IContext;
    fVariableName: string;
    procedure Change(Sender: TObject);
  public
    //  IValueEditor interface
    procedure EditValue(Context: IContext; const VariableName: string);
  end;

  TColourEditor = class(TColorPicker, IValueEditor)
  private
    fContext: IContext;
    fVariableName: string;
    procedure Change(Sender: TObject);
  public
    //  IValueEditor interface
    procedure EditValue(Context: IContext; const VariableName: string);
  end;

  TPointEditor = class(TControl, IValueEditor)
  private
    edX,edY: TSpinBox;
    fContext: IContext;
    fVariableName: string;
    procedure Change(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    //  IValueEditor interface
    procedure EditValue(Context: IContext; const VariableName: string);
  end;

procedure RegisterValueEditors;

implementation

uses
  System.SysUtils, System.Rtti, System.Types, System.UITypes, FMX.Types;

procedure RegisterValueEditors;
begin
  ValueEditorAbstractFactory.RegisterKind(TTypeKind.tkChar,       TTextEditor);
  ValueEditorAbstractFactory.RegisterKind(TTypeKind.tkWChar,      TTextEditor);
  ValueEditorAbstractFactory.RegisterKind(TTypeKind.tkString,     TTextEditor);
  ValueEditorAbstractFactory.RegisterKind(TTypeKind.tkWString,    TTextEditor);
  ValueEditorAbstractFactory.RegisterKind(TTypeKind.tkUString,    TTextEditor);
  ValueEditorAbstractFactory.RegisterKind(TTypeKind.tkLString,    TTextEditor);
  ValueEditorAbstractFactory.RegisterKind(TTypeKind.tkInteger,    TNumberEditor);
  ValueEditorAbstractFactory.RegisterKind(TTypeKind.tkInt64,      TNumberEditor);
  ValueEditorAbstractFactory.RegisterKind(TTypeKind.tkFloat,      TNumberEditor);
  ValueEditorAbstractFactory.RegisterInfo(TypeInfo(TAlphaColor),  TColourEditor);
  ValueEditorAbstractFactory.RegisterInfo(TypeInfo(TPointF),      TPointEditor);
end;

{ TTextEditor }

procedure TTextEditor.Change(Sender: TObject);
begin
  fContext.SetValue(fVariableName, Text)
end;

procedure TTextEditor.EditValue(Context: IContext; const VariableName: string);
begin
  fContext      := Context;
  fVariableName := VariableName;
  //  Populate the control
  Text      := fContext.GetValue(fVariableName).AsString;
  OnChange  := Change;
end;

{ TNumberEditor }

procedure TNumberEditor.Change(Sender: TObject);
var
  Value: integer;
begin
  if  TryStrToInt(Text, Value)  then
    fContext.SetValue(fVariableName, Value)
end;

procedure TNumberEditor.EditValue(Context: IContext; const VariableName: string);
var
  Number: Extended;
begin
  fContext      := Context;
  fVariableName := VariableName;
  //  Populate the control
  Number    := fContext.GetValue(fVariableName).AsExtended;
  Text      := Number.ToString;
  OnChange  := Change;
end;

{ TColourEditor }

procedure TColourEditor.Change(Sender: TObject);
begin
  fContext.SetValue(fVariableName, TValue.From<TAlphaColor>(Color))
end;

procedure TColourEditor.EditValue(Context: IContext; const VariableName: string);
begin
  fContext      := Context;
  fVariableName := VariableName;
  //  Populate the control
  Color     := fContext.GetValue(fVariableName).AsType<TAlphaColor>();
  OnClick   := Change;
end;

{ TPointEditor }

procedure TPointEditor.Change(Sender: TObject);
var
  Point: TPointF;
begin
  Point.X := edX.Value;
  Point.Y := edY.Value;
  fContext.SetValue(fVariableName, TValue.From<TPointF>(Point))
end;

constructor TPointEditor.Create(AOwner: TComponent);

  function CreateEditor: TSpinBox;
  begin
    Result  := TSpinBox.Create(Self);
    Result.Parent   := Self;
    Result.Align    := TAlignLayout.Top;
    Result.Min      := -MaxInt;
    Result.Max      :=  MaxInt;
    Result.OnChange := Change;
  end;

begin
  inherited;
  edX     := CreateEditor;
  edY     := CreateEditor;
  Height  := edX.Height + edY.Height;
end;

procedure TPointEditor.EditValue(Context: IContext; const VariableName: string);
var
  Point: TPointF;
begin
  fContext      := Context;
  fVariableName := VariableName;
  //  Populate the control
  Point := fContext.GetValue(fVariableName).AsType<TPointF>();
  edX.Value     := Point.X;
  edY.Value     := Point.Y;
end;

end.
