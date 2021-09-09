unit FPerson;

interface

uses
  FMX.Forms, System.Classes, FMX.Types, FMX.Controls, FrPerson, uPerson;

type
  TfrmPerson = class(TForm)
    framePerson: TframePerson;
  private
    function  GetPerID: TPersonID;
    procedure SetPerID(const Value: TPersonID);
  public
    property  PerID : TPersonID  read GetPerID write SetPerID;
  end;

implementation

{$R *.fmx}

{ TfrmPerson }

function TfrmPerson.GetPerID: TPersonID;
begin
  Result  := framePerson.PerID
end;

procedure TfrmPerson.SetPerID(const Value: TPersonID);
begin
  framePerson.PerID := Value
end;

end.
