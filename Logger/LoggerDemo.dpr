program LoggerDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  FLogger in 'FLogger.pas' {frmLogger},
  Log in 'Log.pas',
  LogToScreen in 'LogToScreen.pas',
  LogToServer in 'LogToServer.pas' {dmLogToServer: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmLogger, frmLogger);
  Application.Run;
end.
