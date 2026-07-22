unit chatform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  chatgpt;

type
  { TfrmChat }

  TfrmChat = class(TForm)
    memChat: TMemo;
    pnlInput: TPanel;
    edtQuestion: TEdit;
    btnSend: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnSendClick(Sender: TObject);
    procedure edtQuestionKeyPress(Sender: TObject; var Key: char);
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
  // FChatGPT is destroyed automatically as Self is the Owner
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
  edtQuestion.SetFocus;
end;

procedure TfrmChat.btnSendClick(Sender: TObject);
var
  QText: string;
begin
  QText := Trim(edtQuestion.Text);
  if QText = '' then Exit;

  memChat.Lines.Add('>>> Voce: ' + QText);
  edtQuestion.Text := '';

  // Configura o componente de Chat
  FChatGPT.Provider := AIP_LOCAL;
  FChatGPT.LocalIP := 'http://127.0.0.1:' + FPort;
  FChatGPT.CustomModel := FModel;
  FChatGPT.TOKEN := 'local'; // dummy key for local API auth

  Screen.Cursor := crHourGlass;
  btnSend.Enabled := False;
  try
    if FChatGPT.SendQuestion(QText) then
      memChat.Lines.Add('>>> IA: ' + FChatGPT.Response)
    else
      memChat.Lines.Add('>>> Erro: ' + FChatGPT.Response);
    memChat.Lines.Add('');
  finally
    btnSend.Enabled := True;
    Screen.Cursor := crDefault;
    edtQuestion.SetFocus;
  end;
end;

procedure TfrmChat.edtQuestionKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
  begin
    Key := #0;
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
      end;
    1: { Portugues }
      begin
        Caption := 'Chat de IA Local';
        btnSend.Caption := 'Enviar';
      end;
    2: { Francais }
      begin
        Caption := 'Chat IA Local';
        btnSend.Caption := 'Envoyer';
      end;
    3: { Deutsch }
      begin
        Caption := 'Lokaler KI-Chat';
        btnSend.Caption := 'Senden';
      end;
    4: { Espanol }
      begin
        Caption := 'Chat de IA Local';
        btnSend.Caption := 'Enviar';
      end;
    5: { Arabic }
      begin
        Caption := 'دردشة ذكاء اصطناعي محلي';
        btnSend.Caption := 'إرسال';
      end;
    6: { Chinese }
      begin
        Caption := '本地 AI 聊天';
        btnSend.Caption := '发送';
      end;
    7: { Japanese }
      begin
        Caption := 'ローカルAIチャット';
        btnSend.Caption := '送信';
      end;
    8: { Russian }
      begin
        Caption := 'Локальный ИИ Чат';
        btnSend.Caption := 'Отправить';
      end;
  end;
end;

end.
