unit uPersonStore;

interface

//  WARNING:  Please don't study this unit.  It contains some very bad code.
//  It contains a mock-up database implementation to support the demo.

uses
  System.SysUtils, Generics.Collections, uPerson;

type
  TPersonStore_Random = class(TInterfacedObject, IPersonStore)
  private type

    TPersonRecord = record
      PerName: string;
      FamName: string;
      IsCustomer: Boolean;
      IsEmployee: Boolean;
    end;

  private
    fNewID: TPersonID;
    fPeople: TDictionary<TPersonID, TPersonRecord>;
    procedure Populate;
    procedure SavePersonRec(const PerID: TPersonID; const PerName, FamName: string);
  public
    constructor Create;
    destructor  Destroy; override;
    //  IPersonStore interface
    procedure LoadPersonIDs(const PerIDs: TPersonIDs; PersonFilter: TPersonFilter);
    procedure LoadPerson(const Person: TPerson);
    procedure SavePerson(const Person: TPerson); overload;
    function  NewID: TPersonID;
  end;

  EPersonStore_Random = class(Exception);

implementation

uses
  System.Classes, BatSoft.Context;

{ TPersonStore_Random }

constructor TPersonStore_Random.Create;
begin
  inherited;
  fPeople := TDictionary<TPersonID, TPersonRecord>.Create;
  Populate;
end;

destructor TPersonStore_Random.Destroy;
begin
  fPeople.Free;
  inherited;
end;

procedure TPersonStore_Random.LoadPerson(const Person: TPerson);
var
  PerRec: TPersonRecord;
begin
  if  not fPeople.TryGetValue(Person.PersonID, PerRec) then
    raise EPersonStore_Random.Create('Person not found.');
  Person.OnChanged.Enabled  := False;
  try
    Person.PerName    := PerRec.PerName;
    Person.FamName    := PerRec.FamName;
    Person.Backup;
  finally
    Person.OnChanged.Enabled  := True;
    Person.OnChanged.Call()
  end;
end;

procedure TPersonStore_Random.LoadPersonIDs(const PerIDs: TPersonIDs; PersonFilter: TPersonFilter);
var
  Pair: TPair<TPersonID, TPersonRecord>;

  function CreateContext: IContext;
  begin
    Result  := TContextValues.Create();
    Result.SetValue('PerID',      Pair.Key);
    Result.SetValue('PerName',    Pair.Value.PerName);
    Result.SetValue('FamName',    Pair.Value.FamName);
    Result.SetValue('IsCustomer', Pair.Value.IsCustomer);
    Result.SetValue('IsEmployee', Pair.Value.IsEmployee);
  end;

begin
  PerIDs.Clear;
  for Pair in fPeople do
    if  PersonFilter(CreateContext) then
      PerIDs.Add(Pair.Key);
end;

function TPersonStore_Random.NewID: TPersonID;
begin
  inc(fNewID);
  Result  := fNewID;
end;

procedure TPersonStore_Random.Populate;
const
  NrPeople  = 211;
  incPer    = 3;
  incFam    = 7;

  function RandomName(const Names: TStrings; var nx: integer; const incNx: integer): string;
  begin
    nx  := Random(Names.Count);
    nx  := (nx + incNx) mod Names.Count;
    Result  := Names[nx];
  end;

var
  PerNames  : TStringList;
  FamNames  : TStringList;
  nxPer, nxFam: integer;
  PerID: Integer;
begin
  PerNames  := TStringList.Create;
  FamNames  := TStringList.Create;
  try
    PerNames.AddStrings(['Kristofer', 'Christina', 'Anne', 'Maria',
      'Carina', 'Clement', 'David', 'Danielle', 'Diane', 'John', 'Andrew',
      'Floyd', 'Fiona', 'Charlotte', 'Gavin', 'Hannah', 'Henry', 'Victor',
      'Russel', 'Mark', 'Loyd', 'Liam', 'Karl', 'Jasper', 'Nicolas', 'Kylie',
      'Amanda', 'Simon', 'Timothy']);
    FamNames.AddStrings(['Andersson', 'Smith', 'Cooper', 'Farmer',
      'Brewer', 'Johnson', 'Jones', 'Williams', 'Taylor', 'Davies', 'Brown',
      'Wilson', 'Evans', 'Roberts', 'Walker', 'Thompson', 'Edwards', 'Kristensen',
      'Lewis', 'Harris', 'Jackson', 'Barnes', 'Cartwright', 'Archer', 'Jenson',
      'Henson', 'Hopkins', 'Livingston', 'Norrington']);
    for PerID := 1 to NrPeople do
      SavePersonRec(NewID,
        RandomName(PerNames, nxPer, incPer),
        RandomName(FamNames, nxFam, incFam))
  finally
    PerNames.Free;
    FamNames.Free;
  end;
end;

procedure TPersonStore_Random.SavePerson(const Person: TPerson);
begin
  SavePersonRec(Person.PersonID, Person.PerName, Person.FamName);
  Person.Backup;
end;

procedure TPersonStore_Random.SavePersonRec(const PerID: TPersonID; const PerName, FamName: string);
var
  PerRec: TPersonRecord;
begin
  PerRec.PerName    := PerName;
  PerRec.FamName    := FamName;
  fPeople.AddOrSetValue(PerID, PerRec);
end;

end.
