unit FrContext;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.ListBox, FMX.Controls.Presentation, System.Generics.Collections, System.TypInfo,
  BatSoft.Classes, BatSoft.Context, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView, FMX.Edit,
  BatSoft.Spinners, FMX.Colors;

type
  TframeContext = class(TFrame)
    panContext: TGroupBox;
    lstContext: TListSpinner;
    edRow: TEdit;
    procedure lstContextChange(Sender: TObject);
    function lstContextGetShowItem(Sender: TListSpinner; Index: Integer): TControl;
  private
    fContext: IContext;
    fEditor: TControl;
    fNames: TStringList;
    procedure SetContext(const Value: IContext);
    function GetSelectedName: string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    property  Context       : IContext  read fContext         write SetContext;
    property  SelectedName  : string    read GetSelectedName;
  end;

  IValueEditor = interface
    ['{264820A0-6849-405D-B4D2-A9DA1010988F}']
    procedure EditValue(AContext: IContext; const AVariableName: string);
  end;

  TControlClass = class of TControl;

  TValueEditorAbstractFactory = class
  private
    fByTypeInfo: TDictionary<PTypeInfo, TControlClass>;
    fByTypeKind: TDictionary<TTypeKind, TControlClass>;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure RegisterInfo(const Info: PTypeInfo; const ValueEditorClass: TControlClass);
    procedure RegisterKind(const Kind: TTypeKind; const ValueEditorClass: TControlClass);
    function  CreateEditor(Context: IContext; const VariableName: string; const AOwner: TComponent): TControl;
  end;

var
  ValueEditorAbstractFactory: TValueEditorAbstractFactory;

implementation

{$R *.fmx}

uses
  System.Rtti, FMX.SpinBox, ValueEditors;

resourcestring
  EMUST_BE_EDITOR = 'Control class must support interface IValueEditor.';

{ TframeValueEditor }

constructor TframeContext.Create(AOwner: TComponent);
begin
  inherited;
  fNames := TStringList.Create;
  edRow.Visible := False;
end;

destructor TframeContext.Destroy;
begin
  fNames.Free;
  inherited;
end;

function TframeContext.GetSelectedName: string;
begin
  if  lstContext.ItemIndex < 0  then
    Result  := string.Empty
  else
    Result  := fNames[lstContext.ItemIndex]
end;

procedure TframeContext.lstContextChange(Sender: TObject);
begin
  FreeAndNil(fEditor);

  fEditor := ValueEditorAbstractFactory.CreateEditor(fContext, SelectedName, Self);
  if  Assigned(fEditor) then
    begin
      fEditor.Parent  := panContext;
      fEditor.Align   := TAlignLayout.Bottom;
      if  fEditor is TStyledControl then
        (fEditor as TStyledControl).ApplyStyleLookup;
    end;
end;

function TframeContext.lstContextGetShowItem(Sender: TListSpinner; Index: Integer): TControl;
var
  ValueStr: string;
  Value: TValue;
begin
  Result    := edRow;
  //  Determine what text to show
  Value     := Context.GetValue(fNames[Index]);
  ValueStr  := '<>';
  case Value.Kind of
    tkInteger, tkInt64, tkFloat,
    tkChar, tkWChar, tkString, tkUString, tkLString, tkWString, tkVariant :
      ValueStr  := VarToStr(Value.AsVariant);
    tkEnumeration :
      ValueStr  := GetEnumName(Value.TypeInfo, Value.AsOrdinal);
    tkSet :
      ValueStr  := GetSetElementName(Value.TypeInfo, Value.AsOrdinal);
    tkRecord, tkMRecord :
      if  Value.TypeInfo = TypeInfo(TPointF)  then
        ValueStr  := '(' + Round(Value.AsType<TPointF>().X).ToString + ', ' + Round(Value.AsType<TPointF>().Y).ToString + ')';
  end;
  edRow.Text  := fNames[Index] + ' = ' + ValueStr;
end;

procedure TframeContext.SetContext(const Value: IContext);
begin
  lstContext.ItemIndex  := -1;
  fContext := Value;
  if  Assigned(fContext)  then
    begin
      fNames.Clear;
      fContext.GetNames(fNames);
      lstContext.ItemCount  := fNames.Count;
    end
  else
    lstContext.ItemCount  := 0;
end;

{ TValueEditorAbstractFactory }

constructor TValueEditorAbstractFactory.Create;
begin
  inherited;
  fByTypeKind := TDictionary<TTypeKind, TControlClass>.Create;
  fByTypeInfo := TDictionary<PTypeInfo, TControlClass>.Create;
end;

function TValueEditorAbstractFactory.CreateEditor(Context: IContext; const VariableName: string; const AOwner: TComponent): TControl;
var
  Value: TValue;
  ControlClass: TControlClass;
  Editor: IValueEditor;
begin
  Result  := nil;
  if  not Context.HasValue(VariableName)  then
    Exit;
  Value   := Context.GetValue(VariableName);
  if  fByTypeInfo.TryGetValue(Value.TypeInfo, ControlClass) or
      fByTypeKind.TryGetValue(Value.Kind, ControlClass)
  then
    begin
      Result  := ControlClass.Create(AOwner);
      Supports(Result, IValueEditor, Editor);
      Editor.EditValue(Context, VariableName)
    end;
end;

destructor TValueEditorAbstractFactory.Destroy;
begin
  fByTypeKind.Free;
  fByTypeInfo.Free;
  inherited;
end;

procedure TValueEditorAbstractFactory.RegisterInfo(const Info: PTypeInfo; const ValueEditorClass: TControlClass);
begin
  if  not Supports(ValueEditorClass, IValueEditor)  then
    raise Exception.Create(EMUST_BE_EDITOR);
  fByTypeInfo.Add(Info, ValueEditorClass);
end;

procedure TValueEditorAbstractFactory.RegisterKind(const Kind: TTypeKind; const ValueEditorClass: TControlClass);
begin
  if  not Supports(ValueEditorClass, IValueEditor)  then
    raise Exception.Create(EMUST_BE_EDITOR);
  fByTypeKind.Add(Kind, ValueEditorClass);
end;

initialization
  ValueEditorAbstractFactory  := TValueEditorAbstractFactory.Create;
  RegisterValueEditors;

finalization
  ValueEditorAbstractFactory.Free;

end.
