unit SQLAnyMCPServer;

interface

uses
  DotEnv4Delphi,
  System.SysUtils,
  MCP.BaseService,
  System.Classes,
  System.IOUtils,
  MCP.Attributes,
  MCP.ServiceInterface,
  MCP.Resources,
  MCP.Prompts,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  FireDAC.Phys,
  FireDAC.DApt,
  FireDAC.Stan.Async,
  FireDAC.Stan.Def,
  FireDAC.Phys.ASA,
  FireDAC.Phys.ODBCBase,
  FireDAC.Phys.ODBC,
  FireDAC.UI.Intf,
  System.Generics.Collections,
  FireDAC.ConsoleUI.Wait;

type

  TSQLAnyMCPServer = class(TMCPBaseService, IMCPService)

  private
    FResourceManager: TMCPResourceManager;
    FPromptManager: TMCPPromptManager;
    FConnection: TFDConnection;

    function GetServiceName: string;
    function GetServiceVersion: string;

    procedure SetDataBaseConnection(DataBaseConnection: TFDConnection);
    function DataSetToJson(const DS: TFDQuery): string;

    procedure InitializeResources;
    procedure InitializePrompts;
    function QueryData(AConnection: TFDConnection; sql: string): string;

  public
    constructor Create;

    [MCPTool('ExecuteQuery', 'Executes Queries against connected Database')]
    function ExecuteQuery([MCPParameter('sql')] const sql: String): string;

  end;

implementation

uses
  System.JSON;

{ TSQLAnyMCPServer }

constructor TSQLAnyMCPServer.Create;
begin
  inherited Create('SQLANYMCP', '1.0', 'SQLANY MCP Service');
end;

function TSQLAnyMCPServer.DataSetToJson(const DS: TFDQuery): string;
var
  jArr: TJSONArray;
  jObj: TJSONObject;
  i: Integer;
begin
  jArr := TJSONArray.Create;
  try
    DS.First;
    while not DS.Eof do
    begin
      jObj := TJSONObject.Create;
      for i := 0 to DS.FieldCount - 1 do
        jObj.AddPair(DS.Fields[i].FieldName, DS.Fields[i].AsString);
      jArr.AddElement(jObj);
      DS.Next;
    end;
    Result := jArr.ToJSON;
  finally
    jArr.Free;
  end;

end;

function TSQLAnyMCPServer.ExecuteQuery(const sql: String): string;
var
  FDConnection: TFDConnection;
begin
  FDConnection := TFDConnection.Create(nil);
  try
    SetDataBaseConnection(FDConnection);
    Result := QueryData(FDConnection, sql)
  finally
    FDConnection.Free;
  end;
end;

function TSQLAnyMCPServer.QueryData(AConnection: TFDConnection;
  sql: string): string;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := AConnection;
    Query.sql.Text := sql;
    Query.Open;
    Result := DataSetToJson(Query);
  finally
    Query.Free;
  end;
end;

function TSQLAnyMCPServer.GetServiceName: string;
begin
  Result := FServiceName;
end;

function TSQLAnyMCPServer.GetServiceVersion: string;
begin
  Result := FServiceVersion;
end;

procedure TSQLAnyMCPServer.InitializePrompts;
begin
  //
end;

procedure TSQLAnyMCPServer.InitializeResources;
begin
  //
end;

procedure TSQLAnyMCPServer.SetDataBaseConnection(DataBaseConnection
  : TFDConnection);
var
  DataBaseFileParam, DataBaseFilePath: string;
begin
  DataBaseConnection.DriverName := DotEnv.Env('DRIVERNAME');
  DataBaseConnection.Params.UserName := DotEnv.Env('DBUSERNAME');
  DataBaseConnection.Params.Password := DotEnv.Env('PASSWORD');
  DataBaseConnection.Params.Add(DotEnv.Env('ARGS'));
  DataBaseFilePath := DotEnv.Env('DATABASEFILEPATH');
  DataBaseFileParam := Format('DatabaseFile=%s', [DataBaseFilePath]);
  DataBaseConnection.Params.Add(DataBaseFileParam);
  DataBaseConnection.Connected := True;
end;

end.
