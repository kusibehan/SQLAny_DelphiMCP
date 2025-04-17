program MCPForDelphi;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  System.IOUtils,
  MCP.Attributes in 'MCP\MCP.Attributes.pas',
  MCP.BaseService in 'MCP\MCP.BaseService.pas',
  MCP.MethodProcessor in 'MCP\MCP.MethodProcessor.pas',
  MCP.Prompts in 'MCP\MCP.Prompts.pas',
  MCP.Resources in 'MCP\MCP.Resources.pas',
  MCP.ServiceInterface in 'MCP\MCP.ServiceInterface.pas',
  DirectoryMCP in 'DirectoryMCP.pas';

var

  MCPService: TDirMCPService;

const
  filename = 'notes.txt';

begin
  MCPService := TDirMCPService.Create;
  try
    MCPService.Run;
  finally
    MCPService.Free;
  end;

end.
