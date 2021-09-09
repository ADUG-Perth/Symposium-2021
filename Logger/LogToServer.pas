unit LogToServer;

interface

uses
  System.SysUtils, System.Classes, IdBaseComponent, IdComponent, IdUDPBase,
  IdUDPClient, Log;

type
  TdmLogToServer = class(TDataModule, ILogger)
    IdUDPClient: TIdUDPClient;
  public
    //  ILogger interface
    procedure Log(Text: string);
  end;

//var
//  dmLogToServer: TdmLogToServer;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses
  IdGlobal;

{ TdmLogToServer }

procedure TdmLogToServer.Log(Text: string);
begin
  IdUDPClient.Send(Text, IndyTextEncoding_UTF8);
end;

end.
