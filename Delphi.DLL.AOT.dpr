program Delphi.DLL.AOT;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  RbtmqLib in 'RbtmqLib.pas';

begin
  try
    Writeln('Iniciando Aplicação DELPHI');

    var h: TRbtmqHandle;
    var rc: Integer;
    var err: PAnsiChar;

    Writeln('Criando classe do RBMTQ Publisher');

    h := rbtmq_publisher_create;
    if h = nil then
      raise Exception.Create('Falha ao criar handle');

    rc := rbtmq_connect(h,
      PAnsiChar(UTF8String('Delphi - LINUX')),
      PAnsiChar(UTF8String('10.100.131.80')),
      PAnsiChar(UTF8String('iob')),
      PAnsiChar(UTF8String('X490KO8p9b')),
      5672,
      PAnsiChar(UTF8String('/')));

    if rc <> 0 then
    begin
      err := rbtmq_last_error;
      try
        if err <> nil then
          raise Exception.Create(UTF8ToString(err))
        else
          raise Exception.Create('Erro desconhecido');
      finally
        rbtmq_free_string(err);
      end;
    end;

    Writeln('Digite uma mensagem para enviar a fila ''hello''');

    var mensagem: string := EmptyStr;
    Readln(mensagem);

    var mensagemUtf8: UTF8String := UTF8String(mensagem);
    rc := rbtmq_publish_queue(h, PAnsiChar(UTF8String('hello')), PAnsiChar(mensagemUtf8));

    if rc <> 0 then
    begin
      err := rbtmq_last_error;
      try
        if err <> nil then
          raise Exception.Create(UTF8ToString(err))
        else
          raise Exception.Create('Erro desconhecido');
      finally
        rbtmq_free_string(err);
      end;
    end;

    Writeln('Aperte ''q'' para encerrar a aplicação');

    var escape := EmptyStr;
    While escape <> 'q' do
    begin
      Readln(escape);
      Sleep(300);
    end;

    rbtmq_disconnect(h);
    rbtmq_free(h);

    Writeln('Encerrada Aplicação DELPHI');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
