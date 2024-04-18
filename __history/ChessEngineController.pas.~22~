unit ChessEngineController;

interface

uses
  FMX.Dialogs,      // ShowMessage()
  FMX.Forms,

  System.Classes,
  System.SysUtils,


  gTypes,
  Parser,
  DiagramTypes,
  ChessPosition,
  PositionInformation;

{$DEFINE ENGINEDEBUG}

const
  kMaximumVariations = 12;

type

  TChessEngineController = class(TObject)
    constructor Create;

    destructor Destroy; override;

    protected

    { $IFDEF ENGINEDEBUG}
    // fDebuggingEngine: Boolean;
    // fLogFile: TextFile;
    // fLogFileName: String;
    // fLogFileIsOpen: Boolean;
    { $ENDIF}


    fTicksAtStartOfAnalysis,
    fTicksAtLastRequest: Int64;

    fCurrentClientWindow: TForm;

    fNumberOfOverdrives: Integer;

    fEngineNickName: String;
    fCopyrightInformation: String;

    fEngineIsAnalyzing: Boolean;
    fNumberOfCommandsProcessed: LongInt;
    fProcessingCommands: Boolean;

    fInStartupPhase: Boolean;
    fProcessing: Boolean;

    fConnected : Boolean;

    // fHowToConnect : TChessEngineConnectionType;
    fEngineFileName: String;

    fNumberOfBytesInBuffer: Integer;
    fLastCommandFragment: String;
    // fCommandOutputLine : String;

    fEngineTotalPrincipleVariations: Integer;                                 // FIXEDIN build 197
    fEngineMaximumPrincipleVariations: Integer;                               // FIXEDIN build 197
    fEngineNumberOfMovesUntilMate: Array[1..kMaximumVariations] of LongInt;   // FIXEDIN build 197
    fEngineIsMating: Array[1..kMaximumVariations] of Boolean;                 // FIXEDIN build 197
    fEngineScore: Array[1..kMaximumVariations] of LongInt;                    // FIXEDIN build 197
    fEnginePrincipleVariation: Array[1..kMaximumVariations] of String;        // FIXEDIN build 197
    fEngineSecondaryVariation: String;
    fEngineNodeCount: Int64; // FIXEDIN build 103
    fEngineDepth: LongInt;
    fEngineNodesPerSecond: LongInt;

    fEngineSearchTime,
    fEngineSearchStartTime: LongInt; // DWORD;

    fEPDPosition : String;
    // fPositionsInSync : Boolean;
    fNumberOfPliesPlayed : Integer;
    fWhiteOnMove : Boolean;

    fEngineNameString,
    fEngineVersionString : String;

    fBestLine: String;
    fHintMove: String[10];

    fKingLetter,
    fQueenLetter,
    fRookLetter,
    fBishopLetter,
    fKnightLetter: Char;
    // fKnightLetter: String[1];

    fSearching: Boolean;
    fTimeAtLastReminderCommand: Cardinal;

    fParser: TChessParser;
    fBoard: ChessBoardType;

    fWaitForBestMoveBeforeSendingPosition: Boolean;
    fTimeStartedWaitingForBestMove: Cardinal;
    fQueuedPositionEPD: String;

    fBestMove: String;

    fWaitingForEngineToCatchUp: Boolean;
    fWaitingForEngineToCatchUpSince: Cardinal;

    procedure SendCommand(theCommandString: AnsiString); virtual; abstract;

    private

    { $IFDEF ENGINEDEBUG}
    fDebuggingEngine: Boolean;
    fLogFile: TextFile;
    fLogFileName: String;
    fLogFileIsOpen: Boolean;
    { $ENDIF}

    public

    function GetEPDBeingAnalyzed: String;

    function GetTotalPrincipleVariations: Integer;

    function Connected: Boolean;   virtual;

    procedure Connect(theEngineFileName: String);  virtual; abstract;

    procedure Disconnect(AbortConnection: Boolean);  virtual; abstract;

    function GetEngineFileName: String; virtual;

    function EngineTimeStamp: String;  virtual;

    procedure StartTalkingWithThisWindow(theForm: TForm);

    procedure SendEPDPositionToEngine(theEPDString : String;
                                      theNumberOfPliesPlayed : Integer;
                                      theWhiteOnMove : Boolean;
                                      IgnoreIfAlreadyAnalyzingThisPosition : Boolean;
                                      theClientID: String);  virtual; abstract;

    procedure StopAnalyzing; virtual; abstract;

    procedure ProcessCommands; virtual; abstract;

    procedure CheckPipes; virtual; abstract;   // This method should be called in its own thread in case it blocks.

    function GetTimeSpentAnalyzing: Int64;
    function GetTimeSinceLastRequest: Int64;

    function GetNumberOfOverdrives: Integer; virtual;

    procedure SetLogFileName(theLogFileName: String);
    procedure WriteToLog(ToEngine: Boolean; theString: String);

    function GetScore(theMultiPVNumber: Integer): LongInt;
    function GetPrincipleVariation(theMultiPVNumber: Integer): String;
    // function GetSecondaryVariation: String;
    function GetNodeCount: Int64;  // FIXEDIN build 103
    function GetDepth: LongInt;
    function GetEngineNickname: String;
    procedure SetEngineNickname(theNickname: String);
    function GetHintMove: String;
    function GetBestLine: String;
    function GetCopyright: String;

    function GetClientID: String;

    procedure SetPieceLetters(theKingLetter,
                              theQueenLetter,
                              theRookLetter,
                              theBishopLetter,
                              theKnightLetter: Char);

    protected

      fClientID: String;


  end;


implementation

// uses
//   GameForm,
//   EbookForm;



function TChessEngineController.EngineTimeStamp: String;
var
  theTempString: String;
  theShortString: ShortString;

begin
  Str(TThread.GetTickCount:1, theShortString);

  theTempString := String(theShortString);

  Insert('.', theTempString, Length(theTempString) - 2);

  while (Length(theTempString) < 12)
    do theTempString := '0' + theTempString;

  Result := '[' + theTempString + ']';
end;



constructor TChessEngineController.Create;
var
  K: Integer;

begin
  inherited Create;

  { $IFDEF ENGINEDEBUG}
  fDebuggingEngine := False;
  fLogFileName := '';
  fLogFileIsOpen := False;
  { $ENDIF}

  fClientID := '';

  fCurrentClientWindow := nil;

  fNumberOfOverdrives := 0;

  fConnected := False;

  fEngineNickname := '???';
  fCopyrightInformation := '???';
  fEngineIsAnalyzing := False;
  fNumberOfCommandsProcessed := 0;
  fProcessingCommands := False;

  fInStartupPhase := True;
  fProcessing := False;

  fTimeAtLastReminderCommand := TThread.GetTickCount;

  fEngineFileName := '';

  fNumberOfBytesInBuffer := 0;
  fLastCommandFragment := '';
  // fCommandOutputLine := '';

    // FIXEDIN build 197
  fEngineMaximumPrincipleVariations := 3;
  fEngineTotalPrincipleVariations := 0;
  for K := 1 to kMaximumVariations do
    begin
      fEngineIsMating[K] := False;
      fEngineScore[K] := kNoNumericAssessment;
      fEnginePrincipleVariation[K] := '';
      fEngineNumberOfMovesUntilMate[K] := 9999;
    end;
  // fEngineSecondaryVariation := '';
  fEngineSearchTime := 0;
  fEngineSearchStartTime := 0;
  fEngineNodeCount := 0;
  fEngineDepth := 0;
  fEngineNodesPerSecond := 0;

  fEPDPosition := '';
  // fPositionsInSync := False;
  fNumberOfPliesPlayed := 0;
  fWhiteOnMove := True;

  fEngineNameString := '';
  fEngineVersionString := '';

  fBestLine := '';
  fHintMove := '';

  fKingLetter := 'K';
  fQueenLetter := 'Q';
  fRookLetter := 'R';
  fBishopLetter := 'B';
  fKnightLetter := 'N';

  fSearching := False;

  fWaitForBestMoveBeforeSendingPosition := False;
  fQueuedPositionEPD := '';

  fBestMove := '';

  fWaitingForEngineToCatchUp := False;
  fWaitingForEngineToCatchUpSince := TThread.GetTickCount;

  fParser := TChessParser.Create;

  fParser.SetPieceLetters('K',
                          'Q',
                          'R',
                          'B',
                          'N');
end;



destructor TChessEngineController.Destroy;
begin
  if Connected
    then Disconnect(False);

  { $IFDEF ENGINEDEBUG}
  if fLogFileIsOpen
    then
      begin

        try

          CloseFile(fLogFile);
          IOResult;

        except

        end;
      end;
  { $ENDIF}

  fParser.Free;

  inherited Destroy;
end;



procedure TChessEngineController.StartTalkingWithThisWindow(theForm: TForm);
begin
  Assert(False, 'Not in use');
end;



function TChessEngineController.Connected: Boolean;
begin
  Result := fConnected;
end;



function TChessEngineController.GetClientID: String;
begin
  Result := fClientID;
end;



function TChessEngineController.GetCopyright: String;
begin
  Result := fCopyrightInformation;
end;



function TChessEngineController.GetScore(theMultiPVNumber: Integer): LongInt;
begin
  // Assert(theMultiPVNumber <= GetTotalPrincipleVariations, 'GetScore() has an out of range MultiPV');

  Result := fEngineScore[theMultiPVNumber];
end;



function TChessEngineController.GetTimeSpentAnalyzing: Int64;
begin
  Result := TThread.GetTickCount64 - fTicksAtStartOfAnalysis;
end;



function TChessEngineController.GetTimeSinceLastRequest: Int64;
begin
  Result := TThread.GetTickCount64 - fTicksAtLastRequest;
end;



function TChessEngineController.GetTotalPrincipleVariations: Integer;
begin
  Result := fEngineTotalPrincipleVariations;
end;



function TChessEngineController.GetPrincipleVariation(theMultiPVNumber: Integer): String;
begin
  // Assert(theMultiPVNumber <= GetTotalPrincipleVariations, 'GetPrincipleVariation() has an out of range MultiPV');

  fTicksAtLastRequest := TThread.GetTickCount64;

  Result := fEnginePrincipleVariation[theMultiPVNumber];     // FIXEDIN build 197
end;



function TChessEngineController.GetNodeCount: Int64;
begin
  Result := fEngineNodeCount;
end;



function TChessEngineController.GetNumberOfOverdrives: Integer;
begin
  Result := fNumberOfOverdrives;
end;



function TChessEngineController.GetDepth : LongInt;
begin
  Result := fEngineDepth;
end;



function TChessEngineController.GetEngineFileName: String;
begin
  Result := fEngineFileName;
end;



function TChessEngineController.GetEngineNickname: String;
begin
  Result := fEngineNickname;
end;



function TChessEngineController.GetEPDBeingAnalyzed: String;
begin
  Result := fEPDPosition;
end;



procedure TChessEngineController.SetEngineNickname(theNickname: String);
begin
  fEngineNickname := theNickName;
end;



function TChessEngineController.GetHintMove: String;
begin
  Result := String(fHintMove);
end;



function TChessEngineController.GetBestLine: String;
begin
  Result := fBestLine;
end;



procedure TChessEngineController.SetLogFileName(theLogFileName: String);
begin
  { $IFDEF ENGINEDEBUG}
  fDebuggingEngine := True;   // If we're logging then we're debugging.

  fLogFileName := theLogFileName;

  try

    if fLogFileIsOpen
      then
        begin
          CloseFile(fLogFile);
          IOResult;

          fLogFileIsOpen := False;
        end;

  except

  end;

  if (fLogFileName = '')
    then Exit;

  try

    AssignFile(fLogFile, fLogFileName);
    Rewrite(fLogFile);

    WriteLn(fLogFile, '====' + System.SysUtils.DateTimeToStr(Now) + '====');

    fLogFileIsOpen := True;

  except

    ShowMessage('TChessEngineController.SetLogFileName() failed.');

  end;
  { $ENDIF}
end;



procedure TChessEngineController.SetPieceLetters(theKingLetter,
                                                 theQueenLetter,
                                                 theRookLetter,
                                                 theBishopLetter,
                                                 theKnightLetter: Char);
begin
  {
  fKingLetter := AnsiChar(theKingLetter);
  fQueenLetter := AnsiChar(theQueenLetter);
  fRookLetter := AnsiChar(theRookLetter);
  fBishopLetter := AnsiChar(theBishopLetter);
  fKnightLetter := AnsiChar(theKnightLetter);
  }
  fKingLetter := theKingLetter;
  fQueenLetter := theQueenLetter;
  fRookLetter := theRookLetter;
  fBishopLetter := theBishopLetter;
  fKnightLetter := theKnightLetter;

  fParser.SetPieceLetters(theKingLetter,
                          theQueenLetter,
                          theRookLetter,
                          theBishopLetter,
                          theKnightLetter);
end;




procedure TChessEngineController.WriteToLog(ToEngine: Boolean; theString: String);
begin
  { $IFDEF ENGINEDEBUG}
  if not fLogFileIsOpen
    then Exit;

  try

    if ToEngine
      then WriteLn(fLogFile, '<-- ', EngineTimeStamp, ' ', theString)
      else WriteLn(fLogFile, '--> ', EngineTimeStamp, ' ', theString);

    Flush(fLogfile);

  except

  end;
  { $ENDIF}
end;



end.
