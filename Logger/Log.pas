unit Log;

interface

type
  ILogger = interface
    ['{2DC6486F-E1EC-49EE-8CEC-055F63E2E604}']
    procedure Log(Text: string);
  end;

var
  LogStrategy: ILogger;

implementation

end.
