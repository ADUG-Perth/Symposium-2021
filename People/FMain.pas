unit FMain;

interface

uses
  FMX.Forms, FrPerson, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts,
  FMX.Controls, System.Classes, FMX.Types, FrPeople, FMX.Edit;

type
  TfrmMain = class(TForm)
    framePeople: TframePeople;
    Splitter1: TSplitter;
    Layout1: TLayout;
    Layout2: TLayout;
    butListAll: TButton;
    framePerson: TframePerson;
    edListFilter: TEdit;
    butListFilter: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure butListAllClick(Sender: TObject);
    procedure framePeoplelstPeopleChanged(Sender: TObject);
    procedure framePeoplelstPeopleDblClick(Sender: TObject);
    procedure butListFilterClick(Sender: TObject);
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

uses
  System.StrUtils, BatSoft.Context, uPerson, uPersonStore, FPerson;

{ TfrmMain }

procedure TfrmMain.butListAllClick(Sender: TObject);
begin
  PersonFactory.List(framePeople.People,
      function (PersonInfo: IContext): Boolean
      begin
        Result  := True;
      end)
end;

procedure TfrmMain.butListFilterClick(Sender: TObject);
begin
  PersonFactory.List(framePeople.People,
      function (PersonInfo: IContext): Boolean
      begin
        Result  :=
          ContainsText(PersonInfo.GetValue('PerName').AsString, edListFilter.Text) or
          ContainsText(PersonInfo.GetValue('FamName').AsString, edListFilter.Text);
      end)
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  PersonFactory := TPersonFactory.Create(TPersonStore_Random.Create);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  PersonFactory.Free;
end;

procedure TfrmMain.framePeoplelstPeopleChanged(Sender: TObject);
begin
  framePerson.PerID := framePeople.SelectedID;
end;

procedure TfrmMain.framePeoplelstPeopleDblClick(Sender: TObject);
var
  PersonForm: TfrmPerson;
begin
  if  framePeople.SelectedID <> NoPerson  then
    begin
      PersonForm  := TfrmPerson.Create(Self);
      PersonForm.PerID  := framePeople.SelectedID;
      PersonForm.Show;
    end;
end;

end.
