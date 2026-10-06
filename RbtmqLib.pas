unit RbtmqLib;

interface

type
  TRbtmqHandle = Pointer;

function rbtmq_publisher_create: TRbtmqHandle; cdecl;
function rbtmq_free(handle: TRbtmqHandle): Integer; cdecl;
function rbtmq_connect(handle: TRbtmqHandle; identificador, hostServer, userName, password: PAnsiChar; port: Integer; virtualHost: PAnsiChar): Integer; cdecl;
function rbtmq_disconnect(handle: TRbtmqHandle): Integer; cdecl;
function rbtmq_publish_queue(handle: TRbtmqHandle; nomeFila, mensagem: PAnsiChar): Integer; cdecl;
function rbtmq_publish_exchange(handle: TRbtmqHandle; nomeExchange, nomeRota, mensagem: PAnsiChar): Integer; cdecl;
function rbtmq_last_error: PAnsiChar; cdecl;
procedure rbtmq_free_string(ptr: Pointer); cdecl;

implementation

uses
  System.SysUtils, Posix.Dlfcn;

type
  Trbtmq_publisher_create = function: TRbtmqHandle; cdecl;
  Trbtmq_free = function(handle: TRbtmqHandle): Integer; cdecl;
  Trbtmq_connect = function(handle: TRbtmqHandle; identificador, hostServer, userName, password: PAnsiChar; port: Integer; virtualHost: PAnsiChar): Integer; cdecl;
  Trbtmq_disconnect = function(handle: TRbtmqHandle): Integer; cdecl;
  Trbtmq_publish_queue = function(handle: TRbtmqHandle; nomeFila, mensagem: PAnsiChar): Integer; cdecl;
  Trbtmq_publish_exchange = function(handle: TRbtmqHandle; nomeExchange, nomeRota, mensagem: PAnsiChar): Integer; cdecl;
  Trbtmq_last_error = function: PAnsiChar; cdecl;
  Trbtmq_free_string = procedure(ptr: Pointer); cdecl;

var
  LibHandle: UInt64 = 0;
  p_rbtmq_publisher_create: Trbtmq_publisher_create = nil;
  p_rbtmq_free: Trbtmq_free = nil;
  p_rbtmq_connect: Trbtmq_connect = nil;
  p_rbtmq_disconnect: Trbtmq_disconnect = nil;
  p_rbtmq_publish_queue: Trbtmq_publish_queue = nil;
  p_rbtmq_publish_exchange: Trbtmq_publish_exchange = nil;
  p_rbtmq_last_error: Trbtmq_last_error = nil;
  p_rbtmq_free_string: Trbtmq_free_string = nil;

procedure LoadRbtmqLib;
var
  Err: PAnsiChar;
begin
  if LibHandle <> 0 then
    Exit;

  var LibHandle := dlopen('RBTMQ_DLL_AOT.so', RTLD_LAZY);

  if LibHandle = 0 then
    LibHandle := dlopen('./RBTMQ_DLL_AOT.so', RTLD_LAZY);

  if LibHandle = 0 then
  begin
    Err := dlerror;
    if Err <> nil then
      raise Exception.CreateFmt('Falha ao carregar RBTMQ_DLL_AOT.so: %s', [UTF8ToString(Err)])
    else
      raise Exception.Create('Falha ao carregar RBTMQ_DLL_AOT.so');
  end;

  p_rbtmq_publisher_create := Trbtmq_publisher_create(dlsym(LibHandle, 'rbtmq_publisher_create'));
  p_rbtmq_free := Trbtmq_free(dlsym(LibHandle, 'rbtmq_free'));
  p_rbtmq_connect := Trbtmq_connect(dlsym(LibHandle, 'rbtmq_connect'));
  p_rbtmq_disconnect := Trbtmq_disconnect(dlsym(LibHandle, 'rbtmq_disconnect'));
  p_rbtmq_publish_queue := Trbtmq_publish_queue(dlsym(LibHandle, 'rbtmq_publish_queue'));
  p_rbtmq_publish_exchange := Trbtmq_publish_exchange(dlsym(LibHandle, 'rbtmq_publish_exchange'));
  p_rbtmq_last_error := Trbtmq_last_error(dlsym(LibHandle, 'rbtmq_last_error'));
  p_rbtmq_free_string := Trbtmq_free_string(dlsym(LibHandle, 'rbtmq_free_string'));

  if (not Assigned(p_rbtmq_publisher_create)) or
     (not Assigned(p_rbtmq_free)) or
     (not Assigned(p_rbtmq_connect)) or
     (not Assigned(p_rbtmq_disconnect)) or
     (not Assigned(p_rbtmq_publish_queue)) or
     (not Assigned(p_rbtmq_publish_exchange)) or
     (not Assigned(p_rbtmq_last_error)) or
     (not Assigned(p_rbtmq_free_string)) then
  begin
    raise Exception.Create('Falha ao resolver símbolos em RBTMQ_DLL_AOT.so');
  end;
end;

function rbtmq_publisher_create: TRbtmqHandle; cdecl;
begin
  LoadRbtmqLib;
  Result := p_rbtmq_publisher_create();
end;

function rbtmq_free(handle: TRbtmqHandle): Integer; cdecl;
begin
  LoadRbtmqLib;
  Result := p_rbtmq_free(handle);
end;

function rbtmq_connect(handle: TRbtmqHandle; identificador, hostServer, userName, password: PAnsiChar; port: Integer; virtualHost: PAnsiChar): Integer; cdecl;
begin
  LoadRbtmqLib;
  Result := p_rbtmq_connect(handle, identificador, hostServer, userName, password, port, virtualHost);
end;

function rbtmq_disconnect(handle: TRbtmqHandle): Integer; cdecl;
begin
  LoadRbtmqLib;
  Result := p_rbtmq_disconnect(handle);
end;

function rbtmq_publish_queue(handle: TRbtmqHandle; nomeFila, mensagem: PAnsiChar): Integer; cdecl;
begin
  LoadRbtmqLib;

  Writeln('Mensagem que está sendo enviada: ' + UTF8ToString(mensagem));

  Result := p_rbtmq_publish_queue(handle, nomeFila, mensagem);
end;

function rbtmq_publish_exchange(handle: TRbtmqHandle; nomeExchange, nomeRota, mensagem: PAnsiChar): Integer; cdecl;
begin
  LoadRbtmqLib;
  Result := p_rbtmq_publish_exchange(handle, nomeExchange, nomeRota, mensagem);
end;

function rbtmq_last_error: PAnsiChar; cdecl;
begin
  LoadRbtmqLib;
  Result := p_rbtmq_last_error();
end;

procedure rbtmq_free_string(ptr: Pointer); cdecl;
begin
  LoadRbtmqLib;
  p_rbtmq_free_string(ptr);
end;

(*
{$IFDEF LINUX}
finalization
  if LibHandle <> nil then
    dlclose(LibHandle);
{$ENDIF}
*)

end.
