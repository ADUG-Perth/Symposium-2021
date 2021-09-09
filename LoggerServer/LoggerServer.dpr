program LoggerServer;

uses
  System.StartUpCopy,
  FMX.Forms,
  FLoggerServer in 'FLoggerServer.pas' {frmLoggerServer},
  uTextQueue in 'uTextQueue.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmLoggerServer, frmLoggerServer);
  Application.Run;
end.
