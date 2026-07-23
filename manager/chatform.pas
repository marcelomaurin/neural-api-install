unit chatform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  LCLType, chatgpt;

type

  { TfrmChat }

  TfrmChat = class(TForm)
    memChat: TMemo;
    pnlInput: TPanel;
    pnlRightButtons: TPanel;
    memQuestion: TMemo;
    btnSend: TButton;
    btnAttach: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnSendClick(Sender: TObject);
    procedure btnAttachClick(Sender: TObject);
    procedure memQuestionKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    FChatGPT: TCHATGPT;
    FPort: string;
    FModel: string;
    FLanguageIdx: Integer;
    procedure UpdateUIStrings;
  public
    procedure SetConfig(const APort, AModel: string; ALangIdx: Integer);
  end;

var
  frmChat: TfrmChat;

implementation

{$R *.lfm}

{ TfrmChat }

procedure TfrmChat.FormCreate(Sender: TObject);
begin
  Self.DoubleBuffered := True;
  FChatGPT := TCHATGPT.Create(Self);
  FPort := '8095';
  FModel := '';
  FLanguageIdx := 1;
  UpdateUIStrings;
end;

procedure TfrmChat.FormDestroy(Sender: TObject);
begin
  // FChatGPT é destruído automaticamente pois Self é o Owner
end;

procedure TfrmChat.SetConfig(const APort, AModel: string; ALangIdx: Integer);
begin
  FPort := APort;
  FModel := AModel;
  FLanguageIdx := ALangIdx;
  UpdateUIStrings;
end;

procedure TfrmChat.FormShow(Sender: TObject);
begin
  memQuestion.SetFocus;
end;

procedure TfrmChat.btnSendClick(Sender: TObject);
var
  QText: string;
begin
  QText := Trim(memQuestion.Text);
  if QText = '' then Exit;

  memChat.Lines.Add('>>> Você:');
  memChat.Lines.Add(QText);
  memQuestion.Clear;

  // Configura o componente de Chat
  FChatGPT.Provider := AIP_LOCAL;
  FChatGPT.LocalIP := 'http://127.0.0.1:' + FPort;
  FChatGPT.CustomModel := FModel;
  FChatGPT.TOKEN := 'local'; // dummy key for local API auth

  Screen.Cursor := crHourGlass;
  btnSend.Enabled := False;
  btnAttach.Enabled := False;
  try
    if FChatGPT.SendQuestion(QText) then
      memChat.Lines.Add('>>> IA: ' + FChatGPT.Response)
    else
      memChat.Lines.Add('>>> Erro: ' + FChatGPT.Response);
    memChat.Lines.Add('');
  finally
    btnSend.Enabled := True;
    btnAttach.Enabled := True;
    Screen.Cursor := crDefault;
    memQuestion.SetFocus;
  end;
end;

procedure TfrmChat.btnAttachClick(Sender: TObject);
var
  OpenDlg: TOpenDialog;
  Ext: string;
  SL: TStringList;
begin
  OpenDlg := TOpenDialog.Create(Self);
  try
    OpenDlg.Title := 'Selecionar Foto ou Documento';
    OpenDlg.Filter := 'Todos os arquivos (*.*)|*.*|Imagens (*.png;*.jpg;*.jpeg;*.bmp;*.webp;*.gif)|*.png;*.jpg;*.jpeg;*.bmp;*.webp;*.gif|Documentos (*.txt;*.md;*.pas;*.py;*.json;*.csv;*.log;*.pdf;*.doc)|*.txt;*.md;*.pas;*.py;*.json;*.csv;*.log;*.pdf;*.doc';
    if OpenDlg.Execute then
    begin
      Ext := LowerCase(ExtractFileExt(OpenDlg.FileName));
      if (Ext = '.png') or (Ext = '.jpg') or (Ext = '.jpeg') or (Ext = '.bmp') or (Ext = '.webp') or (Ext = '.gif') then
      begin
        // Imagem/Foto
        if memQuestion.Text <> '' then
          memQuestion.Lines.Add('');
        memQuestion.Lines.Add('[Foto/Imagem Anexada: ' + ExtractFileName(OpenDlg.FileName) + ' (' + OpenDlg.FileName + ')]');
      end
      else
      begin
        // Documento ou Arquivo de Texto
        try
          SL := TStringList.Create;
          try
            SL.LoadFromFile(OpenDlg.FileName);
            if memQuestion.Text <> '' then
              memQuestion.Lines.Add('');
            memQuestion.Lines.Add('--- Documento Anexado: ' + ExtractFileName(OpenDlg.FileName) + ' ---');
            memQuestion.Lines.Add(SL.Text);
            memQuestion.Lines.Add('--- Fim do Documento ---');
          finally
            SL.Free;
          end;
        except
          on E: Exception do
          begin
            if memQuestion.Text <> '' then
              memQuestion.Lines.Add('');
            memQuestion.Lines.Add('[Documento Anexado: ' + ExtractFileName(OpenDlg.FileName) + ' - Erro ao ler conteúdo: ' + E.Message + ']');
          end;
        end;
      end;
    end;
  finally
    OpenDlg.Free;
  end;
end;

procedure TfrmChat.memQuestionKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_RETURN) and (ssCtrl in Shift) then
  begin
    Key := 0;
    btnSendClick(nil);
  end;
end;

procedure TfrmChat.UpdateUIStrings;
begin
  case FLanguageIdx of
    0: { English }
      begin
        Caption := 'Local AI Chat';
        btnSend.Caption := 'Send';
        btnAttach.Caption := 'Attach';
      end;
    1: { Portugues }
      begin
        Caption := 'Chat de IA Local';
        btnSend.Caption := 'Enviar';
        btnAttach.Caption := 'Anexar';
      end;
    2: { Francais }
      begin
        Caption := 'Chat IA Local';
        btnSend.Caption := 'Envoyer';
        btnAttach.Caption := 'Joindre';
      end;
    3: { Deutsch }
      begin
        Caption := 'Lokaler KI-Chat';
        btnSend.Caption := 'Senden';
        btnAttach.Caption := 'Anhängen';
      end;
    4: { Espanol }
      begin
        Caption := 'Chat de IA Local';
        btnSend.Caption := 'Enviar';
        btnAttach.Caption := 'Adjuntar';
      end;
    5: { Arabic }
      begin
        Caption := 'دردشة ذكاء اصطناعي محلي';
        btnSend.Caption := 'إرسال';
        btnAttach.Caption := 'إرفاق';
      end;
    6: { Chinese }
      begin
        Caption := '本地 AI 聊天';
        btnSend.Caption := '发送';
        btnAttach.Caption := '附件';
      end;
    7: { Japanese }
      begin
        Caption := 'ローカルAIチャット';
        btnSend.Caption := '送信';
        btnAttach.Caption := '添付';
      end;
    8: { Russian }
      begin
        Caption := 'Локальный ИИ Чат';
        btnSend.Caption := 'Отправить';
        btnAttach.Caption := 'Прикрепить';
      end;
  end;
end;

end.
