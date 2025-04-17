unit MCPService;

interface

uses
  System.JSON;

type

  TBaseService = class(TObject)
  public
    procedure ProcessRequest(const RequestStr: string; out ResponseStr: string);
    procedure ProcessJSONRPCRequest(Request: TJSONObject;
      out Response: TJSONObject);
    procedure Run;

  end;

  TMCPMethodProcessor = class(TObject)

  end;

implementation

{ TBaseService }

procedure TBaseService.ProcessJSONRPCRequest(Request: TJSONObject;
  out Response: TJSONObject);
var
  Method: string;
  Params: TJSONObject;
  RequestID: string;
  RequestIDValue: TJSONValue;
  MethodProcessor: TMCPMethodProcessor;
begin
  // Get the method
  if not Request.TryGetValue<string>('method', Method) then
  begin
    Response := CreateJSONRPCErrorResponse('', -32600,
      'Invalid Request: missing method');
    Exit;
  end;

  // Get the request ID (if any)
  if Request.TryGetValue<TJSONValue>('id', RequestIDValue) then
  begin
    if RequestIDValue is TJSONString then
      RequestID := TJSONString(RequestIDValue).Value
    else if RequestIDValue is TJSONNumber then
      RequestID := TJSONNumber(RequestIDValue).ToString
    else
      RequestID := '';
  end
  else
    RequestID := '';

  // Get the parameters (if any)
  if not Request.TryGetValue<TJSONObject>('params', Params) then
    Params := TJSONObject.Create;

  // Try to find and execute a method with the same name as the RPC method using RTTI
  MethodProcessor := TMCPMethodProcessor.Create(Self);
  try
    if Assigned(MethodProcessor.GetToolMethodByName(Method)) then
    begin
      // Execute the method
      var
      ResultValue := MethodProcessor.ExecuteToolMethod(Method, Params);

      // Format the result for MCP response
      var
      ContentArray := TJSONArray.Create;
      var
      ResponseContent := TJSONObject.Create;

      // If the result is a TJSONArray, assume it's already formatted content
      if ResultValue is TJSONArray then
      begin
        ResponseContent.AddPair('content', ResultValue);
      end
      else
      begin
        // Create text content from the value
        var
        TextContent := TJSONObject.Create;
        TextContent.AddPair('type', 'text');
        TextContent.AddPair('text', ResultValue.ToString);
        ContentArray.Add(TextContent);
        ResponseContent.AddPair('content', ContentArray);
      end;

      // Return the response
      Response := CreateJSONRPCResponse(RequestID, ResponseContent);
    end
    else
    begin
      // Standard MCP methods
      if Method = 'tools/call' then
      begin
        Response := HandleToolsCall(RequestID, Params);
      end
      else if Method = 'tools/list' then
      begin
        Response := HandleToolsList(RequestID);
      end
      else if Method = 'resources/list' then
      begin
        Response := HandleResourcesList(RequestID);
      end
      else if Method = 'prompts/list' then
      begin
        Response := HandlePromptsList(RequestID);
      end
      else if Method = 'getCapabilities' then
      begin
        Response := HandleGetCapabilities(RequestID);
      end
      else if Method = 'ping' then
      begin
        Response := HandlePing(RequestID);
      end
      else if Method = 'initialize' then
      begin
        Response := HandleInitialize(Request);
      end
      else if Method = 'notifications/initialized' then
      begin
        // This is a notification and doesn't need a response
        Response := nil;
      end
      else
      begin
        // Method not found
        Response := CreateJSONRPCErrorResponse(RequestID, -32601,
          Format('Method not found: %s', [Method]));
      end;
    end;
  finally
    MethodProcessor.Free;
  end;
end;

procedure TBaseService.ProcessRequest(const RequestStr: string;
  out ResponseStr: string);
var
  Request, Response: TJSONObject;
begin
  Request := TJSONObject.ParseJSONValue(RequestStr) as TJSONObject;

  try

  finally

  end;
end;

procedure TBaseService.Run;
var
  inputline, outputline: string;
begin
  Readln(inputline);

end;

end.
