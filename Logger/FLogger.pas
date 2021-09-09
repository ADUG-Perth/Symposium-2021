unit FLogger;

interface

uses
  System.Classes, FMX.Forms, FMX.Effects, FMX.StdCtrls, FMX.Edit, FMX.Controls,
  FMX.Controls.Presentation, FMX.Types, FMX.Layouts, Log;

type
  TfrmLogger = class(TForm)
    loLeft: TLayout;
    labText: TLabel;
    labTime: TLabel;
    labStrategy: TLabel;
    loRight: TLayout;
    edText: TEdit;
    tbTime: TTrackBar;
    loControls: TLayout;
    butSend: TButton;
    butLocal: TButton;
    butRemote: TButton;
    GlowEffect: TInnerGlowEffect;
    butToScreen: TButton;
    procedure butLocalClick(Sender: TObject);
    procedure butRemoteClick(Sender: TObject);
    procedure butSendClick(Sender: TObject);
    procedure butToScreenClick(Sender: TObject);
  private
    procedure SetStrategy(Strategy: ILogger; const Button: TButton);
  end;

var
  frmLogger: TfrmLogger;

implementation

{$R *.fmx}

uses
  FMX.Dialogs, LogToScreen, LogToServer;

{ TfrmLogger }

procedure TfrmLogger.butLocalClick(Sender: TObject);
begin
  SetStrategy(nil, butLocal)

end;

procedure TfrmLogger.butRemoteClick(Sender: TObject);
begin
  SetStrategy(TdmLogToServer.Create(Application), butRemote)
end;

procedure TfrmLogger.butSendClick(Sender: TObject);
begin
  LogStrategy.Log(edText.Text)
end;

procedure TfrmLogger.butToScreenClick(Sender: TObject);
begin
  SetStrategy(TLogToScreen.Create, butToScreen)
end;

procedure TfrmLogger.SetStrategy(Strategy: ILogger; const Button: TButton);
begin
  LogStrategy := Strategy;
  //  Show the state in the UI
  GlowEffect.Parent   := Button;
  GlowEffect.Enabled  := True;
end;

end.
