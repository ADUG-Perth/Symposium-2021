unit FLoggerServer;

interface

uses
  FMX.Forms, IdUDPServer, IdGlobal, IdSocketHandle, System.Classes,
  IdBaseComponent, IdComponent, IdUDPBase, FMX.Types, FMX.Memo.Types,
  FMX.Controls, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo;

type
  TfrmLoggerServer = class(TForm)
    IdUDPServer: TIdUDPServer;
    Timer1: TTimer;
    memTexts: TMemo;
    procedure IdUDPServerUDPRead(AThread: TIdUDPListenerThread; const AData: TIdBytes; ABinding: TIdSocketHandle);
    procedure Timer1Timer(Sender: TObject);
  end;

var
  frmLoggerServer: TfrmLoggerServer;

implementation

{$R *.fmx}

uses
  System.SysUtils, uTextQueue;

{ TfrmLoggerServer }

procedure TfrmLoggerServer.IdUDPServerUDPRead(AThread: TIdUDPListenerThread; const AData: TIdBytes; ABinding: TIdSocketHandle);
var
  Text: string;
begin
  Text  := IndyTextEncoding_UTF8.GetString(AData);
  TextQueue.Push(Text);
end;

procedure TfrmLoggerServer.Timer1Timer(Sender: TObject);
var
  Text: string;
begin
  while TextQueue.Pop(Text) do
    memTexts.Lines.Add(Text);
end;

end.
