unit ChessEngineControllerUCI;

interface

uses
  System.Classes,  // TThread.GetTickCount
  System.UITypes,  // MessageDlg
  System.SysUtils, // UpperCase()

  FMX.Memo,
  FMX.Types,
  FMX.Dialogs,  // ShowMessage()

  Globals,
  gTypes,
  Utils,

  Parser,
  DiagramTypes,
  ChessPosition,
  PositionInformation,

  ChessEngineController;

{$DEFINE ENGINEDEBUG}

type


  TChessEngineControllerUCI = class(TChessEngineController)
    constructor Create;

    procedure Connect(theEngineFileName: String); override;
    procedure Disconnect(AbortConnection: Boolean); override;

    procedure StopAnalyzing; override;

    procedure SendEPDPositionToEngine(theEPDString : String;
                                      theNumberOfPliesPlayed : Integer;
                                      theWhiteOnMove : Boolean;
                                      IgnoreIfAlreadyAnalyzingThisPosition : Boolean;
                                      theClientID: String);  override;

    protected

    EngineOutputBuffer: String;

    fUCIInitialized,
    fUCIReady: Boolean;

    fEngineSearchTime,
    fEngineSearchStartTime: Cardinal;

    fEngineSentSomething: Boolean;

    fNumberOfPipeChecks: Integer;

    function GetMultiPVNumber(theLine: String): Integer;     // FIXEDIN build 197

    procedure ProcessCommands; override;

    procedure SendCommand(theCommandString: AnsiString); override;

    procedure LocalizePV(var thePV: AnsiString);
    procedure ProcessCommandLine(theCommand: String);

    procedure ParseScore(theLine: String);
    procedure ParseNodesPerSecond(theLine: String);
    procedure ParseMateIn(theLine: String);
    // procedure ParseSearchTime(theTimeString: String);
    procedure ParseNodeCount(theLine : String);
    procedure ParseDepth(theLine : String);
    procedure ParsePrincipleVariation(theLine: String);
    procedure ParseBestMove(theLine: String);

    procedure SetAnalysisToBlank;

    function ConnectViaPipes: Boolean; virtual;
    procedure DisconnectViaPipes; virtual; abstract;
    function StartEngineViaPipes: Boolean; virtual; abstract;
  end;


implementation



const
  kLineFeed = #10;


constructor TChessEngineControllerUCI.Create;
begin
  inherited Create;

  fTicksAtStartOfAnalysis := TThread.GetTickCount64;

  fEngineSentSomething := False;

  fNumberOfPipeChecks := 0;
  fNumberOfOverdrives := 0;

  fUCIInitialized := False;
  fUCIReady := False;

  SetAnalysisToBlank;
end;



procedure TChessEngineControllerUCI.Connect(theEngineFileName: String);
var
  K: Integer;
  theTimeStartedToWait: Cardinal;
  NumberOfPipeChecksBefore,
  NumberOfPipeChecksAfter: Integer;

begin
  fEngineFileName := theEngineFileName;

  if not ConnectViaPipes
    then
      begin
        MessageDlg('Problem with ConnectViaPipes()',
                          TMsgDlgType.mtInformation,
                          [TMsgDlgBtn.mbOk], 0);

        Exit;
      end;

  EngineOutputBuffer := '';

  // fProcessing := True;

    // Get all the commands that are sent prior to UCIOK.
  ProcessCommands;

        try

          theTimeStartedToWait := TThread.GetTickCount;

          fEngineSentSomething := False;

          repeat
            Sleep(100);
          until fEngineSentSomething or
                (Abs(TThread.GetTickCount - theTimeStartedToWait) > 12000);

          // FIXEDIN build 165
          // Stockfish 15 seems to take too long here on macOS 10.15.7.
          {$IFDEF DEBUG}
          // These messages can stall the program from restarting.
          // FIXEDIN build 4
          // if not fEngineSentSomething then ShowMessage('The engine failed to reply within twelve seconds.');
          {$ENDIF DEBUG}

          if gPreferences.ChessEngineSendStartupCommands
            then
              begin
                for K := 1 to kMaximumUCIStartupCommands do
                  if (gPreferences.UCIChessEngineStartupCommands[K] > '')
                    then SendCommand(gPreferences.UCIChessEngineStartupCommands[K]);
              end;

          theTimeStartedToWait := TThread.GetTickCount;

            // Let the engine process for two seconds.
          repeat
            Sleep(100);
            // CheckPipes;  This should be called by the other thread.
          until fUCIInitialized or
                (Abs(TThread.GetTickCount - theTimeStartedToWait) > 4000);

          SendCommand('isready');

          NumberOfPipeChecksBefore := fNumberOfPipeChecks;

            // Let the engine process for two seconds.
          repeat
            Sleep(100);
            // CheckPipes;  This should be called by the other thread.
          until fUCIReady or
                (Abs(TThread.GetTickCount - theTimeStartedToWait) > 4000);

          NumberOfPipeChecksAfter := fNumberOfPipeChecks;

        finally

          // fProcessing := False;
        end;

  // FIXEDIN build 4
  // if not fUCIReady
  //   then ShowMessage('The UCI engine is not ready.');
end;




procedure TChessEngineControllerUCI.Disconnect(AbortConnection: Boolean);
begin
  Assert(Connected, 'ChessEngineController.Disconnect() called when already disconnected.');

  if not Connected
    then Exit;

  // fConnected := False;

  fProcessing := True;  // thwart all timer activity

  if not AbortConnection
    then SendCommand('quit');

  fUCIInitialized := False;
  fUCIReady := False;

  DisconnectViaPipes;   // Added in build 51 in an attempt to fix the Mac issue

  fEPDPosition := '';

  SetAnalysisToBlank;
end;



procedure TChessEngineControllerUCI.ProcessCommandLine(theCommand: String);
var
  theMultiPVNumber: Integer;

begin
  {$IFDEF ENGINEDEBUG}
  // DebugMemo.Lines.Add(theCommand);
  {$ENDIF}

  if (Length(theCommand) < 1)
    then Exit;

    // See if the engine is identifying itself.
  if (UpperCase(Copy(theCommand, 1, 7)) = 'ID NAME')
    then
      begin
        fEngineNameString := Copy(theCommand, 9, 255);

        Exit;
      end;

    // See if the engine is sending an option.
  if (UpperCase(Copy(theCommand, 1, 6)) = 'OPTION')
    then
      begin

        Exit;
      end;

    // See if the engine is identifying the author.
  if (UpperCase(Copy(theCommand, 1, 9)) = 'ID AUTHOR')
    then
      begin
        fCopyrightInformation := Copy(theCommand, 11, 255);

        Exit;
      end;

  if (UpperCase(Copy(theCommand, 1, 5)) = 'UCIOK')
    then
      begin
        fUCIInitialized := True;

        Exit;
      end;

  if (UpperCase(Copy(theCommand, 1, 7)) = 'READYOK')
    then
      begin
        fUCIReady := True;

        Exit;
      end;

    // a sample line from Ruffian...
    // info depth 9 seldepth 19 nodes 1401457 nps 212987 time 6580 score cp 78 pv d4e5 b8c6 g1f3 d7d5 e5d6 f8d6 b1c3 g8f6 c3b5 d6c5

  if (UpperCase(Copy(theCommand, 1, 9)) = 'BESTMOVE ')
    then ParseBestMove(theCommand);

  {$IFDEF DEBUG}
  // if (Pos('b2b1q', theCommand) > 0)
  //   then theCommand := theCommand;
  {$ENDIF}

  if (UpperCase(Copy(theCommand, 1, 5)) = 'INFO ') and
     fEngineIsAnalyzing and
     (Pos(' pv ', theCommand) > 0)  // added to ignore INFO lines that just have "currmove" and no pv's.
    then
      begin
        {$IFDEF ENGINEDEBUG}
        Inc(fNumberOfCommandsProcessed);
        {$ENDIF}

          // FIXEDIN build 197
        theMultiPVNumber := GetMultiPVNumber(theCommand);

        fEngineTotalPrincipleVariations := theMultiPVNumber;

        if (Pos(' pv ', theCommand) > 0)
          then ParsePrincipleVariation(theCommand);

        if (Pos(' nodes ', theCommand) > 0)
          then ParseNodeCount(theCommand);

        if (Pos(' depth ', theCommand) > 0)
          then ParseDepth(theCommand);

        if (Pos(' mate ', theCommand) > 0)
          then ParseMateIn(theCommand)
          else
            begin
              fEngineIsMating[theMultiPVNumber] := False;
              fEngineNumberOfMovesUntilMate[theMultiPVNumber] := 9999;
            end;

        if (Pos(' cp ', theCommand) > 0)
          then ParseScore(theCommand);

        if (Pos(' nps ', theCommand) > 0)
          then ParseNodesPerSecond(theCommand);

        Exit;
      end;
end;



procedure TChessEngineControllerUCI.ProcessCommands;
var
  theByte: Integer;
  theWaitingTime: Cardinal;
  K: Integer;
  theCommand: String;

begin
  if fProcessingCommands
    then
      begin
        // Beep;

        Inc(fNumberOfOverdrives);

        Exit;
      end
    else fProcessingCommands := True;

  // CheckPipes;   This is now done in its own thread.

    // If it's been a while since we started waiting, stop waiting.
  theWaitingTime := Abs(TThread.GetTickCount - fTimeStartedWaitingForBestMove);

  if (theWaitingTime > 2000) and
     fWaitForBestMoveBeforeSendingPosition and
     (fQueuedPositionEPD > '') and
     fUCIReady  // added in build 37 for Macintosh
    then
      begin
        SendCommand('setoption name MultiPV value 3');  // FIXEDIN build 197
        SendCommand('position fen ' + fQueuedPositionEPD + ' 0 0');
        fQueuedPositionEPD := '';
        fBestMove := '';
        fEngineIsAnalyzing := True;
        SendCommand('go infinite');
      end;

  // Assert(EngineOutputMemo.Text > '', 'EngineOutputMemo was blank in TChessEngineControllerUCI.ProcessCommands()');
  // Assert(EngineOutputBuffer > '', 'EngineOutputBuffer was blank in TChessEngineControllerUCI.ProcessCommands()');

  while (Pos(kLineFeed, EngineOutputBuffer) > 0) do
    begin
      theCommand := Copy(EngineOutputBuffer, 1, Pos(kLineFeed, EngineOutputBuffer) - 1);

        // FIXEDIN build 197
      if (Pos(kCarriageReturn, theCommand) > 0)
        then theCommand := Copy(theCommand, 1, Pos(kCarriageReturn, theCommand) - 1);

      EngineOutputBuffer := Copy(EngineOutputBuffer, Pos(kLineFeed, EngineOutputBuffer) + 1, 9999);

      if (UpperCase(Copy(theCommand, 1, 5)) = 'INFO ') and
         (Pos(' pv ', theCommand) = 0)  // added to ignore INFO lines that just have "currmove" and no pv's.
        then
          begin

          end
        else
          begin
            { $IFDEF ENGINEDEBUG}
            WriteToLog(False, theCommand);
            { $ENDIF}

            ProcessCommandLine(theCommand);
          end;
    end;

  {
  for K := EngineOutputMemo.Lines.Count downto 1 do
    begin
      ProcessCommandLine(EngineOutputMemo.Lines[K-1]);
    end;

  EngineOutputMemo.Lines.Text := '';
  }

  fProcessingCommands := False;
end;



procedure TChessEngineControllerUCI.SendCommand(theCommandString: AnsiString);
begin
  inherited;

  {$IFDEF ENGINEDEBUG}
  WriteToLog(True, theCommandString);
  {$ENDIF}
end;




procedure TChessEngineControllerUCI.SendEPDPositionToEngine(theEPDString: String;
                                                                     theNumberOfPliesPlayed: Integer;
                                                                     theWhiteOnMove,
                                                                     IgnoreIfAlreadyAnalyzingThisPosition: Boolean;
                                                                     theClientID: String);
var
  theChessPosition: TChessPosition;
  K: Integer;

begin
  inherited;

  fClientID := theClientID;

  if not Connected
    then Exit;

    { If the engine is already thinking about this position }
    { and we want it to continue thinking (since it's the same position) }
    { then don't bother telling it again. }
  if IgnoreIfAlreadyAnalyzingThisPosition and
    (fEPDPosition = theEPDString)
    then Exit;

    { Turn on this flag so that this transaction will }
    { not be interrupted. }
  fProcessing := True;

  fBestLine := '';
  fHintMove := '';
  fEngineTotalPrincipleVariations := 0;  // FIXEDIN build 197

  fNumberOfPliesPlayed := theNumberOfPliesPlayed;
  for K := 1 to kMaximumVariations do fEnginePrincipleVariation[K] := '';    // FIXEDIN build 197
  fEngineSecondaryVariation := '';
  fEngineNodeCount := 0;
  fEngineDepth := 0;

  fEPDPosition := theEPDString;

  fTicksAtStartOfAnalysis := TThread.GetTickCount64;
  fTicksAtLastRequest := TThread.GetTickCount64;

  theChessPosition := TChessPosition.Create;

  try
    theChessPosition.MakeBoardFromEPD(fBoard, theEPDString);
    theChessPosition.SetBoard(fBoard);

    fParser.SetBoard(fBoard);

      // Ignore the value passed in.
    fWhiteOnMove := theChessPosition.WhiteOnMove;

  finally

    theChessPosition.Free;

    fProcessing := False;
  end;



    // If this mode is enabled, and the engine is analyzing, and it
    // hasn't spit out its own best move yet...
  if fWaitForBestMoveBeforeSendingPosition and
     fEngineIsAnalyzing and
     (fBestMove = '')
    then
      begin
        StopAnalyzing;
        fTimeStartedWaitingForBestMove := TThread.GetTickCount;
        fQueuedPositionEPD := theEPDString;
        // WaitingLabel.Caption := 'Waiting...';
      end
    else
      begin
        fQueuedPositionEPD := '';
        fBestMove := '';
        SendCommand('stop');
        SendCommand('setoption name MultiPV value 3');  // FIXEDIN build 197
        SendCommand('position fen ' + theEPDString + ' 0 0');
        fEngineIsAnalyzing := True;
        SendCommand('go infinite');
      end;

  fEngineSearchStartTime := TThread.GetTickCount;
end;



procedure TChessEngineControllerUCI.SetAnalysisToBlank;
var
  K: Integer;

begin
    // FIXEDIN build 197
  for K := 1 to kMaximumVariations do
    begin
      fEngineIsMating[K] := False;
      fEngineScore[K] := kNoNumericAssessment;
      fEnginePrincipleVariation[K] := '';
      fEngineNumberOfMovesUntilMate[K] := 9999;
    end;

  fEngineSecondaryVariation := '';
  fEngineSearchTime := 0;
  fEngineSearchStartTime := 0;
  fEngineNodeCount := 0;
  fEngineDepth := 0;
  fEngineNodesPerSecond := 0;
end;



procedure TChessEngineControllerUCI.StopAnalyzing;
begin
  // Assert(fEngineIsAnalyzing);

  fEngineIsAnalyzing := False;

  fEPDPosition := '';

  SendCommand('stop');
end;



procedure TChessEngineControllerUCI.ParseScore(theLine: String);
var
  theErrorCode : Integer;
  theLetter : String[1];
  theScoreString: String;
  theChessPosition: TChessPosition;
  theMultiPV: Integer;

begin
  Assert(Pos(' cp ', theLine) > 0);

  theMultiPV := GetMultiPVNumber(theLine);

  theScoreString := Copy(theLine, Pos(' cp ', theLine) + 4, 999);

  fEngineScore[theMultiPV] := kNoNumericAssessment;  // an assumption

    { Remove leading spaces. }
  while (Length (theScoreString) > 0) and
        (theScoreString [1] = ' ') do
    theScoreString := Copy (theScoreString, 2, 255);

    { Remove any extra parameters by keeping only }
    { the text up to, but not including, the next }
    { blank character. }
  if (Pos(' ', theScoreString) > 0)
    then theScoreString := Copy(theScoreString, 1, Pos(' ', theScoreString) - 1);


  Val(theScoreString, fEngineScore[theMultiPV], theErrorCode);

  if (theErrorCode <> 0)
    then
      begin
        fEngineScore[theMultiPV] := kNoNumericAssessment;

        Exit;
      end;

    // Score is from "engine's point of view."  Convert it to positive for White.
    // So David's idea is to multiply by -1 if it's Black to move.

  theChessPosition := TChessPosition.Create;

  try

    theChessPosition.SetBoard(fBoard);

    if not theChessPosition.WhiteOnMove
      then fEngineScore[theMultiPV] := fEngineScore[theMultiPV] * -1;      // Convert it to positive for White.

  finally

    FreeAndNil(theChessPosition);
  end;
end;



procedure TChessEngineControllerUCI.ParseBestMove(theLine: String);
var
  theBestMoveString: String;

begin
  Assert(UpperCase(Copy(theLine, 1, 9)) = 'BESTMOVE ');

  theBestMoveString := Copy(theLine, Pos('bestmove ', theLine) + 9, 999);

    { Remove leading spaces. }
  while (Length (theBestMoveString) > 0) and
        (theBestMoveString [1] = ' ') do
    theBestMoveString := Copy (theBestMoveString, 2, 255);

    { Remove any extra parameters by keeping only }
    { the text up to, but not including, the next }
    { blank character. }
  if (Pos(' ', theBestMoveString) > 0)
    then theBestMoveString := Copy(theBestMoveString, 1, Pos(' ', theBestMoveString) - 1);


    // If we've been waiting for this 'bestmove' in order to send a queued position...
  if fWaitForBestMoveBeforeSendingPosition and
     (fQueuedPositionEPD > '')
    then
      begin
        // WaitingLabel.Caption := '';

        SendCommand('setoption name MultiPV value 3');  // FIXEDIN build 197
        SendCommand('position fen ' + fQueuedPositionEPD + ' 0 0');
        fQueuedPositionEPD := '';
        fBestMove := '';
        fEngineIsAnalyzing := True;
        SendCommand('go infinite');
      end
    else fBestMove := theBestMoveString;

  {$IFDEF ENGINEDEBUG}
  WriteToLog(False, 'Self.Caption updated with the mate in string.');
  {$ENDIF}
end;



procedure TChessEngineControllerUCI.ParseNodesPerSecond(theLine: String);
var
  theErrorCode : Integer;
  theNodesPerSecondString: String;

begin
  Assert(Pos(' nps ', theLine) > 0);

  theNodesPerSecondString := Copy(theLine, Pos(' nps ', theLine) + 5, 999);

    { Remove leading spaces. }
  while (Length (theNodesPerSecondString) > 0) and
        (theNodesPerSecondString [1] = ' ') do
    theNodesPerSecondString := Copy (theNodesPerSecondString, 2, 255);

    { Remove any extra parameters by keeping only }
    { the text up to, but not including, the next }
    { blank character. }
  if (Pos(' ', theNodesPerSecondString) > 0)
    then theNodesPerSecondString := Copy(theNodesPerSecondString, 1, Pos(' ', theNodesPerSecondString) - 1);


  Val(theNodesPerSecondString, fEngineNodesPerSecond, theErrorCode);

  if (theErrorCode <> 0)
    then fEngineNodesPerSecond := 0;
end;



procedure TChessEngineControllerUCI.ParseMateIn(theLine: String);
var
  theLetter : String[1];
  theMateInString: String;
  theErrorCode: Integer;
  theChessPosition: TChessPosition;
  theMultiPVNumber: Integer;

begin
  Assert(Pos(' mate ', theLine) > 0);

  theMateInString := Copy(theLine, Pos(' mate ', theLine) + 6, 999);

  theMultiPVNumber := GetMultiPVNumber(theLine);

  fEngineIsMating[theMultiPVNumber] := True;

    { Remove leading spaces. }
  while (Length (theMateInString) > 0) and
        (theMateInString [1] = ' ') do
    theMateInString := Copy (theMateInString, 2, 255);

    { Remove any extra parameters by keeping only }
    { the text up to, but not including, the next }
    { blank character. }
  if (Pos(' ', theMateInString) > 0)
    then theMateInString := Copy(theMateInString, 1, Pos(' ', theMateInString) - 1);

    // ******* What should the score be for this mate?
  Val(theMateInString, fEngineNumberOfMovesUntilMate[theMultiPVNumber], theErrorCode);

  if (theErrorCode <> 0)
    then
      begin
        fEngineNumberOfMovesUntilMate[theMultiPVNumber] := 9999;

        fEngineScore[theMultiPVNumber] := kNoNumericAssessment;

        Exit;
      end;

  theChessPosition := TChessPosition.Create;

  try

    theChessPosition.SetBoard(fBoard);

    if theChessPosition.WhiteOnMove
      then
        begin
          if (fEngineNumberOfMovesUntilMate[theMultiPVNumber] > 0)
            then fEngineScore[theMultiPVNumber] := 9999
            else fEngineScore[theMultiPVNumber] := -9999;
        end
      else
        begin
          if (fEngineNumberOfMovesUntilMate[theMultiPVNumber] > 0)
            then fEngineScore[theMultiPVNumber] := -9999
            else fEngineScore[theMultiPVNumber] := 9999;
        end;

  finally

    FreeAndNil(theChessPosition);
  end;


    // Remove the sign.
  // fNumberOfMovesUntilMate := Abs(fNumberOfMovesUntilMate);     FIXEDIN build 197

  {$IFDEF ENGINEDEBUG}
  // WriteLn(fLogFile, '--> ', EngineTimeStamp, ' ', 'Self.Caption updated with the mate in string.');
  {$ENDIF}
end;



procedure TChessEngineControllerUCI.ParseNodeCount(theLine: String);
var
  theNodeCountString: String;
  theErrorCode: Integer;
  tempString: String;

begin
  Assert(Pos(' nodes ', theLine) > 0);

  theNodeCountString := Copy(theLine, Pos(' nodes ', theLine) + 7, 999);


    { Remove leading spaces. }
  while (Length (theNodeCountString) > 0) and
        (theNodeCountString[1] = ' ') do
    theNodeCountString := Copy (theNodeCountString, 2, 255);

    { Remove any extra parameters by keeping only }
    { the text up to, but not including, the next }
    { blank character. }
  if (Pos (' ', theNodeCountString) > 0)
    then theNodeCountString := Copy(theNodeCountString, 1, Pos(' ', theNodeCountString) - 1);


  Val(theNodeCountString, fEngineNodeCount, theErrorCode);

  if (theErrorCode <> 0)
    then
      begin
        fEngineNodeCount := 0;
        Exit;
      end;

  {$IFDEF ENGINEDEBUG}
  // WriteLn(fLogFile, '--> ', EngineTimeStamp, ' ', 'NodesLabel and Self BOTH updated.');
  {$ENDIF}

  fEngineSearchTime := TThread.GetTickCount - fEngineSearchStartTime;
end;



procedure TChessEngineControllerUCI.ParseDepth(theLine: String);
var
  theDepthString: String;
  theErrorCode: Integer;
  tempString: String;

begin
  Assert(Pos(' depth ', theLine) > 0);

  theDepthString := Copy(theLine, Pos(' depth ', theLine) + 7, 999);


    { Remove leading spaces. }
  while (Length (theDepthString) > 0) and
        (theDepthString[1] = ' ') do
    theDepthString := Copy (theDepthString, 2, 255);

    { Remove any extra parameters by keeping only }
    { the text up to, but not including, the next }
    { blank character. }
  if (Pos (' ', theDepthString) > 0)
    then theDepthString := Copy(theDepthString, 1, Pos(' ', theDepthString) - 1);


  Val(theDepthString, fEngineDepth, theErrorCode);

  if (theErrorCode <> 0)
    then
      begin
        fEngineDepth := 0;
        Exit;
      end;
end;



function TChessEngineControllerUCI.GetMultiPVNumber(theLine: String): Integer;
var
  theRestOfTheLine,
  theMultiPVNumberString: String;
  theMultiPVNumber: Integer;
  theErrorCode: Integer;

begin
    // Which pv is it?
  Assert(Pos('multipv', theLine) > 0, 'GetMultiPVNumber() called without a multipv');

  if (Pos('multipv', theLine) > 0)
    then
      begin
        theRestOfTheLine := Copy(theLine, Pos('multipv ', theLine) + 8, 999);

        theMultiPVNumberString := Copy(theRestOfTheLine, 1, Pos(' ', theRestOfTheLine) - 1);

        Val(theMultiPVNumberString, theMultiPVNumber, theErrorCode);

        if (theErrorCode <> 0)
          then theMultiPVNumber := 1;
      end;

  Result := theMultiPVNumber;
end;



procedure TChessEngineControllerUCI.ParsePrincipleVariation(theLine: String);
var
  theMoveNumber : Integer;
  thePlies : Integer;
  thePV,
  theLongAlgebraicPV,
  theEnhancedLine,
  theUnenhancedLine: AnsiString;
  theWhiteMoveIsNext : Boolean;
  BeyondFirstMove : Boolean;
  theSnippet : String;
  theMoveNumberString : String;
  theBlankPosition : Integer;
  // theLastPrincipleVariation: String;
  {
  theTimeString,
  theDepthString,
  theScoreString,
  theNodeCountString: String;
  theErrorCode: Integer;
  }

  {
  MoveNumberA,
  MoveNumberB: String[5];
  MoveNumberAHasAnEllipsis,
  MoveNumberBHasAnEllipsis: Boolean;
  }

  theNodeCountBeforeThePV: Int64; // FIXEDIN build 103
  // theScoreBeforeThePV: LongInt;
  {$IFDEF ENGINEDEBUG}
  theFirstMove: String;
  {$ENDIF ENGINEDEBUG}
  theShortAlgebraicNotation: String;

  theMultiPVNumber: Integer;

begin
  Assert(Pos(' pv ', theLine) > 0);

  theMultiPVNumber := GetMultiPVNumber(theLine);

    // Keep track in case these will be needed for the moving the current
    // analysis to the second pv memo.
  theNodeCountBeforeThePV := fEngineNodeCount;
  // theScoreBeforeThePV := fEngineScore;

  theWhiteMoveIsNext := fWhiteOnMove;

  thePlies := fNumberOfPliesPlayed;

    { If this variation started with Black to move then }
    { add another ply to keep the move numbers straight. }
  if (fWhiteOnMove and Odd (fNumberOfPliesPlayed)) or
     (not fWhiteOnMove and not Odd (fNumberOfPliesPlayed))
    then Inc (thePlies);

    // info depth 9 seldepth 19 nodes 1401457 nps 212987 time 6580 score cp 78 pv d4e5 b8c6 g1f3 d7d5 e5d6 f8d6 b1c3 g8f6 c3b5 d6c5
    { Get everything after the pv. }
  thePV := Copy(theLine, Pos(' pv ', theLine) + 4, 999);

    // Remove all leading blanks.
  while (Length(thePV) > 0) and
        (thePV[1] = ' ') do
    thePV := Copy(thePV, 2, 999);

     // Bug?
  // if (fBestMove > '')
  //   then thePV := fBestMove + ' ' + thePV;

  // fEnginePrincipleVariation[theMultiPVNumber] := '';
  theLongAlgebraicPV := '';
  theSnippet := '';

  while (Length(thePV) > 0) do
    begin
      if (thePV[1] = ' ') and
         (Length(theSnippet) > 1) and
         (theSnippet[1] in ['a','b','c','d','e','f','g','h','K','Q','R','B','N']) and
         (theSnippet[2] in ['a','b','c','d','e','f','g','h','1','2','3','4','5','6','7','8'])
        then
          begin
              // separate the moves with one space
            if (Length(theLongAlgebraicPV) > 0)
              then theLongAlgebraicPV := theLongAlgebraicPV + ' ';

            theLongAlgebraicPV := theLongAlgebraicPV + theSnippet;
            theSnippet := '';
          end
        else
          begin
            theSnippet := theSnippet + thePV[1];
          end;

      Delete(thePV,1,1);
    end;

  if (Length(theSnippet) > 1)
    then
      begin
          // separate the moves with one space
        if (Length(theLongAlgebraicPV) > 0)
          then theLongAlgebraicPV := theLongAlgebraicPV + ' ';

        theLongAlgebraicPV := theLongAlgebraicPV + theSnippet;
        theSnippet := '';
      end;

    // Remove all leading blanks.
  while (Length(theLongAlgebraicPV) > 0) and
        (theLongAlgebraicPV = ' ') do
    theLongAlgebraicPV := Copy(theLongAlgebraicPV, 2, 999);

  if (Length(theLongAlgebraicPV) < 1)
    then Exit;

  if (Pos(' ', theLongAlgebraicPV) = 0)
    then theFirstMove := theLongAlgebraicPV
    else theFirstMove := Copy(theLongAlgebraicPV, 1, Pos(' ', theLongAlgebraicPV) - 1);

  {$IFDEF ENGINEDEBUG}
  // if (theFirstMove = 'd8h4')
  //   then WriteToLog(False, 'd8h4 was detected');
  {$ENDIF}

    // Set the parser to the currently analyzed position.
  fParser.SetBoard(fBoard);

  theShortAlgebraicNotation := fParser.ShortAlgebraicNotationFor(theFirstMove);

  if not (theShortAlgebraicNotation > '')
    then
      begin
        fEnginePrincipleVariation[theMultiPVNumber] := '';
        fEngineSecondaryVariation := '';

        {$IFDEF ENGINEDEBUG}
        // WriteLn(fLogFile, '--> ', EngineTimeStamp, ' ', '...thinking');
        {$ENDIF}

        if not fWaitingForEngineToCatchUp
          then
            begin
              fWaitingForEngineToCatchUp := True;
              fWaitingForEngineToCatchUpSince := TThread.GetTickCount;
            end;

        Exit;
      end;


    // Remove anything that looks like a move number because we add
    // our own.
  theUnenhancedLine := '';

  while (Length(theLongAlgebraicPV) > 0) do
    begin
      theBlankPosition := Pos(' ', theLongAlgebraicPV);

      if (theBlankPosition > 0)
        then theSnippet := Copy(theLongAlgebraicPV, 1, theBlankPosition)
        else theSnippet := theLongAlgebraicPV;

        // Keep this snippet only if it does not look like a move number.
      if (Pos('.', theSnippet) = 0) and
         (Pos(theSnippet[1], '123456789') = 0)
        then
          begin
            theShortAlgebraicNotation := fParser.ShortAlgebraicNotationFor(theSnippet);

            // if (Length(theShortAlgebraicNotation) < 2)
            //   then ShowMessage('ParsePrincipleVariation() Notation too short.');

            fParser.SetNotation(theShortAlgebraicNotation);

            if fParser.NotationIsLegal
              then
                begin
                  fParser.MakeMoveNotation;
                end
              else
                begin
                  { $IFDEF DEBUGENGINE}

                  // ShowMessage('ParsePrincipleVariation() Notation is illegal. >' + theShortAlgebraicNotation + '<');

                  WriteToLog(True, 'ParsePrincipleVariation() Notation is illegal. >' + theShortAlgebraicNotation + '<');

                  // Assert(False, 'Bad Notation');   // TESTING remove in shipping version
                  { $ENDIF}
                end;

            if (Length(theUnenhancedLine) > 0)
              then theUnenhancedLine := theUnenhancedLine + ' ';

            theUnenhancedLine := theUnenhancedLine + theShortAlgebraicNotation;
          end;

      if (theBlankPosition > 0)
        then theLongAlgebraicPV := Copy(theLongAlgebraicPV, theBlankPosition + 1, 9999)
        else theLongAlgebraicPV := '';
    end;


  LocalizePV(theUnenhancedLine);

    // FIXEDIN build 197
  if (theMultiPVNumber = 1)
    then
      begin
        fBestLine := theUnenhancedLine;

        if (Pos(' ', theUnenhancedLine) = 0)
          then fHintMove := theUnenhancedLine
          else fHintMove := Copy(theUnenhancedLine,
                                 1,
                                 Pos(' ', theUnenhancedLine) - 1);
      end;

  theMoveNumber := (thePlies div 2) + 1;

  theEnhancedLine := IntToStr(theMoveNumber);

  if fWhiteOnMove
    then theEnhancedLine := theEnhancedLine + '.'
    else theEnhancedLine := theEnhancedLine + '...';

  BeyondFirstMove := False;

  while (Length(theUnenhancedLine) > 0) do
    begin
      theBlankPosition := Pos(' ', theUnenhancedLine);

      if (theBlankPosition > 0)
        then theSnippet := Copy(theUnenhancedLine, 1, Pos(' ', theUnenhancedLine) - 1)
        else theSnippet := theUnenhancedLine;

      if (Length (theSnippet) > 0)
        then
          begin
            Inc(thePlies);

            if BeyondFirstMove
              then
                begin
                  theMoveNumber := (thePlies div 2) + 1;

                  if theWhiteMoveIsNext
                    then theMoveNumberString := IntToStr(theMoveNumber) + '.'
                    else theMoveNumberString := '';

                  theEnhancedLine := theEnhancedLine + ' ' + theMoveNumberString;
                end
              else BeyondFirstMove := True;

            theEnhancedLine := theEnhancedLine + theSnippet;

            theWhiteMoveIsNext := not theWhiteMoveIsNext;
          end;

        { Trim the snippet from the start of the variation along with }
        { the snippet's trailing space. }
      if (theBlankPosition > 0)
        then theUnenhancedLine := Copy (theUnenhancedLine, Pos (' ', theUnenhancedLine) + 1, 255)
        else theUnenhancedLine := '';
    end;

  fEnginePrincipleVariation[theMultiPVNumber] := theEnhancedLine;

  Assert(fEnginePrincipleVariation[theMultiPVNumber] > '', 'fEnginePrincipleVariation was blank at the end of ' + kLineFeed +
                                         'TChessEngineControllerUCI.ParsePrincipleVariation()');
end;



procedure TChessEngineControllerUCI.LocalizePV(var thePV: AnsiString);
var
  theTempPV: AnsiString;
  K: Integer;

begin
  theTempPV := '';

  for K := 1 to Length(thePV) do
    case thePV[K] of
      'K' : theTempPV := theTempPV + fKingLetter;
      'Q' : theTempPV := theTempPV + fQueenLetter;
      'R' : theTempPV := theTempPV + fRookLetter;
      'B' : theTempPV := theTempPV + fBishopLetter;
      'N' : theTempPV := theTempPV + fKnightLetter;
      else theTempPV := theTempPV + thePV[K];
    end;

  thePV := theTempPV;
end;



function TChessEngineControllerUCI.ConnectViaPipes: Boolean;
var
  K: Integer;

begin
  Result := False;  // an assumption

  Assert(not Connected);

  if Connected
    then Exit;

  fNumberOfBytesInBuffer := 0;
  fLastCommandFragment := '';

    // FIXEDIN build 197
  for K := 1 to kMaximumVariations do
    begin
      fEngineIsMating[K] := False;
      fEngineScore[K] := kNoNumericAssessment;
      fEnginePrincipleVariation[K] := '';
      fEngineNumberOfMovesUntilMate[K] := 9999;
    end;

  fEngineSecondaryVariation := '';
  fEngineSearchTime := 0;
  fEngineNodeCount := 0;
  fEngineDepth := 0;
  fEngineNodesPerSecond := 0;

  if not StartEngineViaPipes
    then
      begin
        // EngineLoadingForm.Hide;
        Exit;
      end;

  fConnected := True;

  Result := True;
end;



end.
