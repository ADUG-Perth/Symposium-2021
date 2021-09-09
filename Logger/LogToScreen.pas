unit LogToScreen;

interface

uses
  Log;

type
  TLogToScreen = class(TInterfacedObject, ILogger)
  public
    //  ILogger interface
    procedure Log(Text: string);
  end;

implementation

uses
  FMX.Dialogs;

{ TLogToScreen }

procedure TLogToScreen.Log(Text: string);
begin
  ShowMessage(Text)
end;

end.
