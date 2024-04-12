unit Form.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, IdHTTPWebBrokerBridge, IdGlobal, Web.HTTPApp,
  FMX.Controls.Presentation, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.EditBox, FMX.SpinBox,
  System.INIFiles, System.IOUtils,

  // ChessEngineController,
  ChessEngineControllerUCIForWindows,
  ChessEngineDataThread,

  Globals;


type
  TMainForm = class(TForm)
    ButtonStart: TButton;
    ButtonStop: TButton;
    EditPort: TEdit;
    Label1: TLabel;
    ButtonOpenBrowser: TButton;
    EditLocalIP: TEdit;
    RequestsMemo: TMemo;
    StartEnginesButton: TButton;
    NumberOfEnginesSpinBox: TSpinBox;
    StopEnginesButton: TButton;
    EngineEXEFilenameLabel: TLabel;
    EngineStatusPanel: TPanel;
    EngineStatusMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure ButtonStopClick(Sender: TObject);
    procedure ButtonOpenBrowserClick(Sender: TObject);
    procedure StartEnginesButtonClick(Sender: TObject);
    procedure StopEnginesButtonClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private

    // fNumberOfEnginesRunning: Integer;
    // fChessEngineControllers: Array[1..10] of TChessEngineControllerUCIForWindows;
    fEngineFileName: String;
    fChessEngineDataThread: TChessEngineDataThread;

    FServer: TIdHTTPWebBrokerBridge;

    fNumberOfRequestsServed: Cardinal;

    procedure StopEngines;

    procedure StartServer;
    procedure ApplicationIdle(Sender: TObject; var Done: Boolean);

  public

    procedure AnalyzeThisPositionForClient(theFEN: String;
                                           theClientID: String;
                                           var theReplyForTheClient: String);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
{$IFDEF MSWINDOWS}
  WinApi.Windows, Winapi.ShellApi, Winsock,
{$ENDIF}
  System.Generics.Collections;


const

  kINIFileName = 'ServerSettings.INI';
  kINIEngineFilenameTag = 'EngineEXEFile';
  // kMaximumChessEngines = 10;
  kServerBusy = '#ServerBusy';
  kStartedThinking = '#StartedThinking';


function GetLocalIP: string;
type
  TaPInAddr = array [0..10] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  phe: PHostEnt;
  pptr: PaPInAddr;
  Buffer: array [0..63] of Ansichar;
  i: Integer;
  GInitData: TWSADATA;
begin
  WSAStartup($101, GInitData);
  Result := '';
  GetHostName(Buffer, SizeOf(Buffer));
  phe := GetHostByName(Buffer);
  if phe = nil then
    Exit;
  pptr := PaPInAddr(phe^.h_addr_list);
  i := 0;
  while pptr^[i] <> nil do
  begin
    Result := StrPas(inet_ntoa(pptr^[i]^));
    Inc(i);
  end;
  WSACleanup;
end;


procedure TMainForm.AnalyzeThisPositionForClient(theFEN: String; theClientID: String;
  var theReplyForTheClient: String);
var
  theEngineNumber: Integer;
  DebugString: String;
  K: Integer;
  theEPDBeingAnalyzed: String;
  theClientIDBeingServed: String;
  theScore: Integer;
  theNodeCount: Cardinal;
  theDepth: Integer;

begin
  RequestsMemo.Lines.Add(theClientID  + theFEN);

  theEngineNumber := 0;

    // Look for an engine already serving this client.
  repeat

    Inc(theEngineNumber);

    theEPDBeingAnalyzed := gChessEngineControllers[theEngineNumber].GetEPDBeingAnalyzed;

    theClientIDBeingServed := gChessEngineControllers[theEngineNumber].GetClientID;

  until (theClientIDBeingServed = theClientID) or
        (theEngineNumber = gNumberOfEnginesRunning);

    // We found an engine serving this client for another position.
  if (theClientIDBeingServed = theClientID) and
     (theEPDBeingAnalyzed <> theFEN)
    then
      begin
        gChessEngineControllers[theEngineNumber].StopAnalyzing;

        gChessEngineControllers[theEngineNumber].SendEPDPositionToEngine(theFEN, 0, True, True, theClientID);

        theReplyForTheClient := kStartedThinking; // 'StartedThinking';

        Exit;
      end;


    // If an engine says it is analyzing this position for this client then return the best line.
  if (theClientIDBeingServed = theClientID) and
     (theEPDBeingAnalyzed = theFEN)
    then
      begin
        theReplyForTheClient := '';

        for K := 1 to gChessEngineControllers[theEngineNumber].GetTotalPrincipleVariations do
          begin
            theReplyForTheClient := theReplyForTheClient +
              'pv' + K.ToString + '=' + gChessEngineControllers[theEngineNumber].GetPrincipleVariation(K);

            theScore := gChessEngineControllers[theEngineNumber].GetScore(K);

            theReplyForTheClient := theReplyForTheClient +
              '&score' + K.ToString + '=' + theScore.ToString;

            if (K < gChessEngineControllers[theEngineNumber].GetTotalPrincipleVariations)
              then theReplyForTheClient := theReplyForTheClient + '&';
          end;

        theNodeCount := gChessEngineControllers[theEngineNumber].GetNodeCount;

        theDepth := gChessEngineControllers[theEngineNumber].GetDepth;

        theReplyForTheClient := theReplyForTheClient +
              '&depth=' + theDepth.ToString + '&nodecount=' + theNodeCount.ToString;

        EngineStatusMemo.Lines[theEngineNumber] := 'Engine-' + theEngineNumber.ToString + ' (' + fNumberOfRequestsServed.ToString +  ')' + theReplyForTheClient;

        Exit;
      end;

    // Look for an engine not currently serving a client.
  theEngineNumber := 0;

  repeat

    Inc(theEngineNumber);

    theEPDBeingAnalyzed := gChessEngineControllers[theEngineNumber].GetEPDBeingAnalyzed;

  until (theEPDBeingAnalyzed = '') or
        (theEngineNumber = gNumberOfEnginesRunning);

    // If we cycled through every controller and the last one was analyzing an EPD
    // then the server is busy.
  if (theEPDBeingAnalyzed > '')
    then
      begin
        theReplyForTheClient := kServerBusy; // 'ServerBusy';

        Inc(fNumberOfRequestsServed);

        Exit;
      end;

  gChessEngineControllers[theEngineNumber].SendEPDPositionToEngine(theFEN, 0, True, True, theClientID);
  theReplyForTheClient := kStartedThinking; // 'StartedThinking';

  Inc(fNumberOfRequestsServed);
  EngineStatusMemo.Lines[theEngineNumber] := 'Engine-' + theEngineNumber.ToString + ' (' + fNumberOfRequestsServed.ToString +  ')'  + theReplyForTheClient;
end;



procedure TMainForm.ApplicationIdle(Sender: TObject; var Done: Boolean);
begin
  ButtonStart.Enabled := not FServer.Active;
  ButtonStop.Enabled := FServer.Active;
  EditPort.Enabled := not FServer.Active;
end;


procedure TMainForm.StartEnginesButtonClick(Sender: TObject);
var
  K: Integer;

begin
  if (gNumberOfEnginesRunning > 0) then Exit;

    // Create some engine instances.
  gNumberOfEnginesRunning := Trunc(NumberOfEnginesSpinBox.Value);

  EngineStatusMemo.Text := '***** ENGINE STATUS *****';

  for K := 1 to gNumberOfEnginesRunning do
    begin
      EngineStatusMemo.Lines.Add('Engine ' + K.ToString);
    end;

  for K := 1 to gNumberOfEnginesRunning do
    begin
      gChessEngineControllers[K] := TChessEngineControllerUCIForWindows.Create;

      gChessEngineControllers[K].Connect(fEngineFileName);

      EngineStatusMemo.Lines[K] := 'Engine ' + K.ToString + ' Connected';

      if not gChessEngineControllers[K].Connected
        then
          begin
            ShowMessage('There was a problem connecting with the engine');

            Exit;
          end;

    end;

  gChessEngineControllers[K].SetLogFileName('Engine1LogFile.txt');

  RequestsMemo.Lines.Add(gNumberOfEnginesRunning.ToString + ' engines started.');

  StartEnginesButton.Enabled := False;
  StopEnginesButton.Enabled := True;
end;



procedure TMainForm.ButtonOpenBrowserClick(Sender: TObject);
{$IFDEF MSWINDOWS}
var
  LURL: string;
{$ENDIF}
begin
  StartServer;
{$IFDEF MSWINDOWS}
  LURL := Format('http://localhost:%s', [EditPort.Text]);
  ShellExecute(0,
        nil,
        PChar(LURL), nil, nil, SW_SHOWNOACTIVATE);
{$ENDIF}
end;


procedure TMainForm.ButtonStartClick(Sender: TObject);
begin
  StartServer;
end;


procedure TMainForm.ButtonStopClick(Sender: TObject);
begin
  FServer.Active := False;
  FServer.Bindings.Clear;
end;


procedure TMainForm.FormCreate(Sender: TObject);
var
//   TESTMemoryLeak: TButton;
  theINIFile: TIniFile;
  theINIFileName: String;
  theEXEFileName: String;
  K: Integer;

begin
  EditLocalIP.Text := GetLocalIP;
  FServer := TIdHTTPWebBrokerBridge.Create(Self);
  Application.OnIdle := ApplicationIdle;

  // TESTMemoryLeak := TButton.Create(nil);

  {$IFDEF DEBUG}
  System.ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}

  fNumberOfRequestsServed := 0;

  gNumberOfEnginesRunning := 0;

  StartEnginesButton.Enabled := True;
  StopEnginesButton.Enabled := False;

  theINIFileName := TPath.Combine(ExtractFilePath(ParamStr(0)), kINIFileName);

  Assert(FileExists(theINIFileName), 'The INI file was not found.');

  theINIFile := TIniFile.Create(theINIFileName);

  theEXEFileName := theINIFile.ReadString('ProgramPreferences', kINIEngineFilenameTag, '');

  fEngineFileName := TPath.Combine(ExtractFilePath(ParamStr(0)), 'Engines\' + theEXEFileName);

  EngineEXEFilenameLabel.Text := fEngineFileName;

  theINIFile.Free;

  for K := 1 to kMaximumChessEngines do
    gChessEngineControllers[K] := nil;

  fChessEngineDataThread := TChessEngineDataThread.Create;
end;



procedure TMainForm.FormDestroy(Sender: TObject);
begin
  StopEngines;

  try

    fChessEngineDataThread.FinishUp;
    Sleep(300);

    fChessEngineDataThread.FreeOnTerminate := True;
    fChessEngineDataThread.Terminate;

  except

    ShowMessage('There was a problem ending the conversation with the chess engine.');

  end;

  fChessEngineDataThread.Free;
end;



procedure TMainForm.StartServer;
begin
  if not FServer.Active then
  begin
    FServer.Bindings.Clear;
    FServer.DefaultPort := StrToInt(EditPort.Text);
    FServer.Active := True;
  end;
end;



procedure TMainForm.StopEngines;
var
  K: Integer;

begin
  if (gNumberOfEnginesRunning = 0) then Exit;

  for K := 1 to gNumberOfEnginesRunning do
    begin
      if gChessEngineControllers[K].Connected
        then gChessEngineControllers[K].Disconnect(False);

      gChessEngineControllers[K].Free;
      EngineStatusMemo.Lines[K] := 'Engine ' + K.ToString + ' Freed';
    end;

  RequestsMemo.Lines.Add(gNumberOfEnginesRunning.ToString + ' engines freed.');

  gNumberOfEnginesRunning := 0;

  StartEnginesButton.Enabled := True;
  StopEnginesButton.Enabled := False;
end;



procedure TMainForm.StopEnginesButtonClick(Sender: TObject);
begin
  StopEngines;
end;



end.