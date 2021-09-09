unit uTextQueue;

interface

uses
  System.Generics.Collections, System.SyncObjs;

type
  TTextQueue = class
  private
    fLock: TCriticalSection;
    fTexts: TQueue<string>;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure Push(const Text: string);
    function  Pop(out Text: string): Boolean;
  end;

var
  TextQueue: TTextQueue;

implementation

{ TTextQueue }

constructor TTextQueue.Create;
begin
  inherited;
  fLock   := TCriticalSection.Create;
  fTexts  := TQueue<string>.Create;
end;

destructor TTextQueue.Destroy;
begin
  fLock.Free;
  fTexts.Free;
  inherited;
end;

function TTextQueue.Pop(out Text: string): Boolean;
begin
  fLock.Enter;
  try
    Result  := fTexts.Count > 0;
    if  Result  then
      Text  := fTexts.Dequeue
  finally
    fLock.Leave;
  end;
end;

procedure TTextQueue.Push(const Text: string);
begin
  fLock.Enter;
  try
    fTexts.Enqueue(Text)
  finally
    fLock.Leave;
  end;
end;

initialization
  TextQueue := TTextQueue.Create;

finalization
  TextQueue.Free;

end.
