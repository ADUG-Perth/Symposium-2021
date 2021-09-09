unit FrPerson;

interface

uses
  FMX.Forms, FMX.StdCtrls, FMX.Edit, System.Classes, FMX.Types, FMX.Controls,
  FMX.Controls.Presentation, BatSoft.Observer.Managed, uPerson;

type
  TframePerson = class(TFrame)
    labPerID: TLabel;
    labPerName: TLabel;
    labFamName: TLabel;
    edPerID: TEdit;
    edPerName: TEdit;
    edFamName: TEdit;
    butSave: TButton;
    butReset: TButton;
    procedure butSaveClick(Sender: TObject);
    procedure edFamNameTyping(Sender: TObject);
    procedure edPerNameTyping(Sender: TObject);
    procedure butResetClick(Sender: TObject);
  private
    fPerson: TPerson;
    fSubscription: ISubscription;
    function  GetPerID: TPersonID;
    procedure SetPerID(const Value: TPersonID);
    procedure PopulateFrame;
    procedure PersonChanged(Sender: TObject);
  public
    destructor  Destroy; override;
    property  Person: TPerson   read fPerson;
    property  PerID : TPersonID read GetPerID write SetPerID;
  end;

implementation

{$R *.fmx}

uses
  System.SysUtils;

{ TframePerson }

procedure TframePerson.butResetClick(Sender: TObject);
begin
  fPerson.Restore;
end;

procedure TframePerson.butSaveClick(Sender: TObject);
begin
  PersonFactory.Save(fPerson);
end;

destructor TframePerson.Destroy;
begin
  PerID := NoPerson;
  inherited;
end;

procedure TframePerson.edFamNameTyping(Sender: TObject);
begin
  fPerson.FamName := edFamName.Text
end;

procedure TframePerson.edPerNameTyping(Sender: TObject);
begin
  fPerson.PerName := edPerName.Text
end;

function TframePerson.GetPerID: TPersonID;
begin
  Result  := fPerson.PersonID
end;

procedure TframePerson.PersonChanged(Sender: TObject);
begin
  PopulateFrame;
end;

procedure TframePerson.PopulateFrame;
begin
  if  Assigned(fPerson) then
    begin
      edPerID.Text    := fPerson.PersonID.ToString;
      edPerName.Text  := fPerson.PerName;
      edFamName.Text  := fPerson.FamName;
    end
  else
    begin
      edPerID.Text    := '';
      edPerName.Text  := '';
      edFamName.Text  := '';
    end;
end;

procedure TframePerson.SetPerID(const Value: TPersonID);
begin
  //  Unsubscribe from previous person's events
  fSubscription := nil;
  //  Change person object
  if  Assigned(fPerson) then
    fPerson.Release;
  //
  fPerson := PersonFactory.Obtain(Value);
  //  Subscribe to events
  if  Assigned(fPerson) then
    fSubscription := fPerson.OnChanged.Subscribe(PersonChanged);
  //  Update UI
  PopulateFrame;
end;

end.
