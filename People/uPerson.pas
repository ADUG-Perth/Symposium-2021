unit uPerson;

interface

{$DEFINE MULTITON}

uses
  System.Classes, Generics.Collections,
  BatSoft.Observer.Managed, BatSoft.Context, BatSoft.Mementos;

{$region 'Person IDs'}
type
  TPersonID = integer;
  TPersonIDs = class(TList<TPersonID>);
const
  NoPerson  : TPersonID = 0;
{$endregion}

{$region 'Person'}
type
  TPerson = class
  private
{$IFDEF MULTITON}
    fRefCount: integer;
{$ENDIF}
    fPersonID: TPersonID;
    fPerName: string;
    fFamName: string;
    fOnChanged: TNotifyEvents;
    procedure SetPerName(const Value: string);
    procedure SetFamName(const Value: string);
  private
    fMemento: TBackupFields;
    //  Lifetime
    constructor Create(const APersonID: TPersonID);
  public
    destructor  Destroy; override;
    function  Obtain: TPerson;
    procedure Release;
    //  Values
    property  PersonID    : TPersonID     read fPersonID;
    property  PerName     : string        read fPerName     write SetPerName;
    property  FamName     : string        read fFamName     write SetFamName;
    function  FullName    : string;
    property  OnChanged   : TNotifyEvents read fOnChanged;
    procedure Backup;
    procedure Restore;
  end;

  TPeople = class(TList<TPerson>)
  private
    fOnChanged: TNotifyEvents;
    fSubscriptions: TInterfaceList;
    procedure PersonChanged(Sender: TObject);
  protected
    procedure Notify(const Item: TPerson; Action: TCollectionNotification); override;
  public
    constructor Create;
    destructor  Destroy; override;
    property  OnChanged   : TNotifyEvents read fOnChanged;
  end;
{$endregion}

{$region 'Factory'}
  TPersonFilter = reference to function (PersonInfo: IContext): Boolean;

  IPersonStore = interface
    ['{13497910-AF88-4827-B5CB-8A47B3E3C528}']
    procedure LoadPersonIDs(const PerIDs: TPersonIDs; PersonFilter: TPersonFilter);
    procedure LoadPerson(const Person: TPerson);
    procedure SavePerson(const Person: TPerson);
    function  NewID: TPersonID;
  end;

  TPersonFactory = class
  private
    //  Interface to database
    fStore: IPersonStore;
{$IFDEF MULTITON}
    //  TPerson object lifetimes
    fAllPeopleInMemory: TDictionary<TPersonID, TPerson>;
{$ENDIF}
  public
    constructor Create(AStore: IPersonStore);
    destructor  Destroy; override;
    //  TPerson object lifetimes
    function  ObtainNew: TPerson;
    function  Obtain(const PerID: TPersonID): TPerson; overload;
    procedure Obtain(const Person: TPerson); overload;
    procedure Release(const Person: TPerson);
    //  TPerson persistance (ie. loading and saving)
    procedure List(const People: TPeople; PersonFilter: TPersonFilter);
    procedure Load(const Person: TPerson);
    procedure Save(const Person: TPerson);
  end;

var
  PersonFactory: TPersonFactory;
{$endregion}

implementation

{ TPerson }

procedure TPerson.Backup;
begin
  fMemento.Backup;
end;

constructor TPerson.Create(const APersonID: TPersonID);
begin
  inherited Create();
  fPersonID   := APersonID;
  fOnChanged  := TNotifyEvents.Create(Self);
  fMemento    := TBackupFields.Create(Self);
end;

destructor TPerson.Destroy;
begin
  fOnChanged.Free;
  fMemento.Free;
  inherited;
end;

function TPerson.FullName: string;
begin
  Result  := PerName + ', ' + FamName
end;

function TPerson.Obtain: TPerson;
begin
  PersonFactory.Obtain(Self);
  Result  := Self;
end;

procedure TPerson.Release;
begin
  PersonFactory.Release(Self)
end;

procedure TPerson.Restore;
begin
  OnChanged.Enabled := False;
  try
    fMemento.Restore;
  finally
    OnChanged.Enabled := True;
    OnChanged.Call;
  end;
end;

procedure TPerson.SetFamName(const Value: string);
begin
  fFamName  := Value;
  fOnChanged.Call;
end;

procedure TPerson.SetPerName(const Value: string);
begin
  fPerName  := Value;
  fOnChanged.Call;
end;

{ TPeople }

constructor TPeople.Create;
begin
  inherited;
  fOnChanged      := TNotifyEvents.Create(Self);
  fSubscriptions  := TInterfaceList.Create;
end;

destructor TPeople.Destroy;
begin
  fOnChanged.Free;
  fSubscriptions.Free;
  inherited;
end;

procedure TPeople.Notify(const Item: TPerson; Action: TCollectionNotification);
begin
  inherited;
  case Action of
    cnAdded :
      begin
        PersonFactory.Obtain(Item);
        fSubscriptions.Add(Item.OnChanged.Subscribe(PersonChanged));
        OnChanged.Call;
      end;
    cnExtracting, cnDeleting :
      begin
        PersonFactory.Release(Item);
        OnChanged.Call;
      end;
  end;
end;

procedure TPeople.PersonChanged(Sender: TObject);
begin
  OnChanged.Call
end;

{ TPersonFactory }

constructor TPersonFactory.Create(AStore: IPersonStore);
begin
  inherited Create;
  fStore  := AStore;
{$IFDEF MULTITON}
  fAllPeopleInMemory := TDictionary<TPersonID, TPerson>.Create();
{$ENDIF}
end;

destructor TPersonFactory.Destroy;
begin
{$IFDEF MULTITON}
  fAllPeopleInMemory.Free;
{$ENDIF}
  inherited;
end;

procedure TPersonFactory.List(const People: TPeople; PersonFilter: TPersonFilter);
var
  PerIDs: TPersonIDs;
  i: integer;
begin
  PerIDs  := TPersonIDs.Create;
  try
    //  Determine which people should be in the list
    fStore.LoadPersonIDs(PerIDs, PersonFilter);
    //  Add those people
    People.Clear;
    for i := 0 to PerIDs.Count - 1 do
      People.Add(Obtain(PerIDs[i]));
    People.OnChanged.Call;
  finally
    PerIDs.Free;
  end;
end;

procedure TPersonFactory.Load(const Person: TPerson);
begin
  fStore.LoadPerson(Person);
end;

procedure TPersonFactory.Obtain(const Person: TPerson);
begin
{$IFDEF MULTITON}
  //  Simply increment the RefCount
  inc(Person.fRefCount);
{$ENDIF}
end;

function TPersonFactory.Obtain(const PerID: TPersonID): TPerson;
begin
  if  PerID = NoPerson  then
    Exit(nil);
{$IFDEF MULTITON}
  //  If the TPerson object already exists in memory, then use that.
  if  not fAllPeopleInMemory.TryGetValue(PerID, Result) then
    try
{$ENDIF}
      //  Person is not currently in memory, so...
      //  - Create new TPerson object
      Result  := TPerson.Create(PerID);
      //  - Load properties from database
      fStore.LoadPerson(Result);
{$IFDEF MULTITON}
      //  - Keep track of it
      fAllPeopleInMemory.Add(PerID, Result);
    except
      //  Load failed, so tidy up and continue the exception.
      Result.Free;
      raise;
    end;
  //  Now that we have it, increment the RefCount
  inc(Result.fRefCount);
{$ENDIF}
end;

function TPersonFactory.ObtainNew: TPerson;
begin
  //  Create new TPerson object
  Result  := TPerson.Create(fStore.NewID);
{$IFDEF MULTITON}
  //  Keep track of it
  fAllPeopleInMemory.Add(Result.PersonID, Result);
  //  Now that we have it, increment the RefCount
  inc(Result.fRefCount);
{$ENDIF}
end;

procedure TPersonFactory.Release(const Person: TPerson);
begin
{$IFDEF MULTITON}
  //  Decrement the reference count
  dec(Person.fRefCount);
  //  If this object is no longer used, then...
  if  Person.fRefCount = 0  then
    begin
      //  - Stop keeping track of it
      fAllPeopleInMemory.Remove(Person.PersonID);
      //  - Free the object
      Person.Free;
    end;
{$ENDIF}
end;

procedure TPersonFactory.Save(const Person: TPerson);
begin
  fStore.SavePerson(Person);
end;

end.
