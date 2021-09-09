program PeopleDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMain in 'FMain.pas' {frmMain},
  uPerson in 'uPerson.pas',
  uPersonStore in 'uPersonStore.pas',
  FrPerson in 'FrPerson.pas' {framePerson: TFrame},
  FrPeople in 'FrPeople.pas' {framePeople: TFrame},
  FPerson in 'FPerson.pas' {frmPerson};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
