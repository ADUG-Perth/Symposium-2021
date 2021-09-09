unit FrPeople;

interface

uses
  System.Classes, FMX.Types, FMX.Forms, FMX.Effects, FMX.Edit, BatSoft.Spinners,
  FMX.Controls, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts,
  BatSoft.Observer.Managed, uPerson;

type
  TframePeople = class(TFrame)
    GroupBox1: TGroupBox;
    Layout1: TLayout;
    lstPeople: TListSpinner;
    edPerson: TEdit;
    InnerGlow: TInnerGlowEffect;
    function lstPeopleGetShowItem(Sender: TListSpinner; Index: Integer): TControl;
  private
    fPeople: TPeople;
    fSubscription: ISubscription;
    function GetSelected: TPersonID;
    procedure PeopleChanged(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    property  People    : TPeople   read fPeople;
    property  SelectedID: TPersonID read GetSelected;
  end;

implementation

{$R *.fmx}

{ TframePeople }

constructor TframePeople.Create(AOwner: TComponent);
begin
  inherited;
  //  Hide list controls
  edPerson.Visible  := False;
  //  Initialise
  fPeople       := TPeople.Create;
  fSubscription := fPeople.OnChanged.Subscribe(PeopleChanged);
end;

destructor TframePeople.Destroy;
begin
  fPeople.Free;
  inherited;
end;

function TframePeople.GetSelected: TPersonID;
begin
  if  lstPeople.ItemIndex < 0 then
    Result  := NoPerson
  else
    Result  := fPeople[lstPeople.ItemIndex].PersonID
end;

function TframePeople.lstPeopleGetShowItem(Sender: TListSpinner; Index: Integer): TControl;
begin
  InnerGlow.Enabled := Index = Sender.ItemIndex;
  edPerson.Text     := fPeople[Index].FullName;
  Result  := edPerson;
end;

procedure TframePeople.PeopleChanged(Sender: TObject);
begin
  lstPeople.ItemCount := fPeople.Count;
  lstPeople.Invalidate;
end;

end.
