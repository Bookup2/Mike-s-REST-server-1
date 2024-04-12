Unit Utils;

interface

uses
  System.SysUtils,

  System.UITypes,

  {$IFDEF MSWINDOWS}
  System.Win.Registry,
  {$ENDIF MSWINDOWS}

  {$IFDEF iOS}
  iOSapi.Foundation,
  Macapi.Helpers,
  {$ENDIF}
  {$IFDEF MacOS}
  Macapi.Foundation,
  Macapi.Helpers,
  {$ENDIF}

  FMX.Dialogs,
  FMX.DialogService,

  // Globals,
  gTypes,
  DiagramTypes;

  // Beeper,

const
   _PU = '_';
   libFoundation = '/System/Library/Frameworks/Foundation.framework/Foundation';

type
   NSUInteger = LongWord;
   NSSearchPathDirectory = NSUInteger;
   NSSearchPathDomainMask = NSUInteger;

   // 10.2.3 apparently no longer needs this code. FIXEDIN build 99
// function NSSearchPathForDirectoriesInDomains(directory: NSSearchPathDirectory; domainMask: NSSearchPathDomainMask;
//   expandTilde: Boolean): Pointer {NSArray}; cdecl;
//   external libFoundation name _PU + 'NSSearchPathForDirectoriesInDomains';

  {$IFDEF MACOS}
  function GetMacUserApplicationSupportDir: String;
  function GetMacSystemApplicationSupportDirXXX: String;
  {$ENDIF}

  procedure Delay (Milliseconds : Longword);

  {
  procedure TellTheUser (TitleStringNumber,
                         MessageStringNumber : Integer);
  }

  procedure Unimplemented;

  function HasLegalFileNameCharacters(theFileName: String): Boolean;

  procedure BadBeep;

  procedure HighShortBeep;

  procedure RemoveTrailingBlanks(var theString: String);
  procedure RemoveTrailingBlanksFromAnsiString(var theString: AnsiString);

  {
  procedure MassageMove(var TheMove: CandidateNotationType); overload;
  procedure MassageMove(var TheMove: CandidateNotationType;
                        UsePGNLetters: Boolean); overload;
  }
  procedure MassageMove(var TheMove: CandidateNotationType;
                        KingLetter,
                        QueenLetter,
                        RookLetter,
                        BishopLetter,
                        KnightLetter: Char);

  function IsLongAlgebraicNotation (aNotation : CandidateNotationType) : Boolean;

  function ExtractDiacriticFrom (aNotation : CandidateNotationType): Byte;

  function SameBoard(FirstBoard, SecondBoard: ChessBoardType) : Boolean;

  procedure AddDiacriticToNotation (theMove : ChessMoveType;
                                    var theMoveNotation : CandidateNotationType);

  function SameMove (FirstMove, SecondMove : ChessMoveType) : Boolean;

  function BetterRate (FirstRate,
                       SecondRate : InformantRateType;
                       WhiteOnMove : Boolean;
                       IgnoreNonratedPositions : Boolean;
                       FavorUnclearOverEquality: Boolean) : InformantRateType;

  function LetterForInformantRate (theRate : InformantRateType) : Char;

  procedure ChangeToFigurines(var theNotation : CandidateNotationType;
                              KingLetter,
                              QueenLetter,
                              RookLetter,
                              BishopLetter,
                              KnightLetter: Char;
                              FigurineKingNumber,
                              FigurineQueenNumber,
                              FigurineRookNumber,
                              FigurineBishopNumber,
                              FigurineKnightNumber: Byte);

  // function LocalizedString (StringNumber : Integer) : String;

  function MoveIsAlreadyACandidate(theMove: ChessMoveType;
                                   theNumberOfCandidates: Byte;
                                   theCandidateArray: TCandidateArray): Boolean;

  function UnMoveIsAlreadyAnUnCandidate(theUnMove: TUnMove;
                                        theNumberOfUnCandidates: Byte;
                                        theUnCandidateArray: TUnCandidateArray): Boolean;

  procedure ConvertSquareToString(theSquare: SquareType;
                                  var theString: String);

  function SquareFromString(const theString: String): SquareType;

  function TimeRemaining(OperationsPerSecond: LongInt;
                         TotalRemaining: LongInt): String;

  function WhatIsInQuotes (theString : String) : ShortString;

  // function PGNIndexFilesOkay(thePGNFileName: String): Boolean;

  {$IFDEF MSWINDOWS}
  function RemoveReadOnlyAttribute(aFileName: String): Boolean;

  function LegacyRightsWordWhiteCanCastleKingSide(theWord: Word): Boolean;
  function LegacyRightsWordWhiteCanCastleQueenSide(theWord: Word): Boolean;
  function LegacyRightsWordBlackCanCastleKingSide(theWord: Word): Boolean;
  function LegacyRightsWordBlackCanCastleQueenSide(theWord: Word): Boolean;
  function LegacyRightsWordWhiteOnMove(theWord: Word): Boolean;
  function LegacyRightsWordEnPassantSquare(theWord: Word): SquareType;
  {$ENDIF}

  function OppositeInformantRate(theRate: InformantRateType): InformantRateType;

  // function TrainingCoverageMode: Boolean;   moved to ebookform.pas method on 2016-01-29

  function EdgeSquare(theSquare: SquareType): Boolean;

  function AddCommasTo(theNumber: String): String;

  {$IFDEF MSWINDOWS}
  function GetRootDataFolderFromInstaller: String;
  function GetRootDataFolderFromOLDInstaller: String;    // FIXEDIN build 141
  {$ENDIF MSWINDOWS}

  function ConfirmWithMessage(theMessage: String): Boolean;
  function ConfirmYesNoCancelWithMessage(theMessage: String): Integer;
  procedure InformWithMessage(theMessage: String);
  procedure InformErrorWithMessage(theMessage: String);


implementation

uses
  System.Classes;


const
  kLegacyRightsWordWhiteCanCastleKingSideBit = $1;
  kLegacyRightsWordWhiteCanCastleQueenSideBit = $2;
  kLegacyRightsWordBlackCanCastleKingSideBit = $4;
  kLegacyRightsWordBlackCanCastleQueenSideBit = $8;
  kLegacyRightsWordWhiteOnMoveBit = $10;

{
var
  gBadBeep,
  gShortHighBeep: TNoise;
}


{$IFDEF MACOS}
function GetMacUserApplicationSupportDir: String;

var
   Paths : NSArray;
   Dir : NSString;

begin
   Paths := TNSArray.Wrap(NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, True));

   Dir := TNSString.Wrap(Paths.objectAtIndex(0));

   Result := NSStrToStr(Dir);
end;



function GetMacSystemApplicationSupportDirXXX: String;

var
   Paths : NSArray;
   Dir : NSString;

begin
   ShowMessage('System Library should not be accessed.');

   Paths := TNSArray.Wrap(NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSSystemDomainMask, True));

   Dir := TNSString.Wrap(Paths.objectAtIndex(0));

   Result := NSStrToStr(Dir);
end;
{$ENDIF}



procedure Delay (Milliseconds : LongWord);
var
  StartingTime : Cardinal;

begin
  StartingTime := TThread.GetTickCount;  { *API* }

  repeat        
  until (TThread.GetTickCount > StartingTime + Milliseconds);
end;



{
procedure TellTheUser (TitleStringNumber,
                       MessageStringNumber : Integer);
var
  thePascalTitleString : String;
  thePascalMessageString : String;

  MessageNumberStr : AnsiString;

begin
  if (TitleStringNumber <> kDlgStrBlank)
    then thePascalTitleString := LoadStr(gLanguage + TitleStringNumber)
    else thePascalTitleString := '';

  if (MessageStringNumber <> kDlgStrBlank)
    then thePascalMessageString := LoadStr (gLanguage + MessageStringNumber)
    else thePascalMessageString := '';

  if (thePascalMessageString = '')
    then
      begin
        Str(MessageStringNumber:0, MessageNumberStr);

        thePascalMessageString := 'Could not load message ' +
                                MessageNumberStr;
      end;

  MessageDlg(thePascalMessageString,
             TMsgDlgType.mtInformation,
             [TMsgDlgBtn.mbOk], 0);
end;
}



procedure BadBeep;
begin
  // MessageBeep (2 {MB_ICONEXCLAMATION});     { *API* }
  Beep;
  // ShowMessage('BadBeep!');  // This showed that the beeping for move keys is not coming from this proc.
  // Assert(False, 'BadBeep was called.');
end;



procedure HighShortBeep;
begin
  // MessageBeep (2 {MB_ICONEXCLAMATION});     { *API* }

  {$IFDEF MACOS}
  Beep;
  // ShowMessage('Beep!');  // This showed that the beeping for move keys is not coming from this proc.
  {$ENDIF}

  {$IFDEF MSWINDOWS}
  Beep;
  // gShortHighBeep.Play;
  {$ENDIF}
end;



procedure RemoveTrailingBlanks(var theString: String);
begin
  if (Length(theString) = 0)
    then Exit;

  while (Copy(theString, Length(theString), 1) = ' ')
    do theString := Copy(theString, 1, Length(theString) - 1);
end;



procedure RemoveTrailingBlanksFromAnsiString(var theString:AnsiString);
begin
  if (Length(theString) = 0)
    then Exit;

  while (Copy(theString, Length(theString), 1) = ' ')
    do theString := Copy(theString, 1, Length(theString) - 1);
end;



{ This procedure reformats a string to contain only characters that would }
{ be part of a legal chess notation (from the first 8 characters. }

procedure MassageMove(var TheMove: CandidateNotationType;
                      KingLetter,
                      QueenLetter,
                      RookLetter,
                      BishopLetter,
                      KnightLetter: Char);
var
  HoldString : Str255;
  K: Integer;

begin
    { The move part of any snippet should appear in the first 6 characters. }
  HoldString := TheMove;

  TheMove := '';

    { If there is an 'ep' hanging on the end of the move then trim it. }
  if (Length (HoldString) > 3) and
     ((Copy (HoldString, Length (HoldString) -1, 2) = 'ep') or
      (Copy (HoldString, Length (HoldString) -1, 2) = 'EP'))
    then HoldString := Copy (HoldString, 1, Length (HoldString) - 2);

    { If this is not a simple pawn move like 'e4' or 'c6' and the first }
    { letter looks like a piece then uppercase the piece. }
  if (Pos (HoldString [2], '12345678') = 0) and
     (Pos (HoldString [1], 'abcdefgh') = 0)
    then HoldString [1] := UpCase (HoldString [1]);

  for K := 1 to Length (HoldString) do
    {
    if (Pos(HoldString [K], 'abcdefgh12345678O0o') > 0) or
       (HoldString [K] in [gPreferences.KingLetter,
                           gPreferences.QueenLetter,
                           gPreferences.RookLetter,
                           gPreferences.BishopLetter,
                           gPreferences.KnightLetter])
    }
    if (Pos(HoldString [K], 'abcdefgh12345678O0o') > 0) or
       (HoldString [K] in [KingLetter,
                           QueenLetter,
                           RookLetter,
                           BishopLetter,
                           KnightLetter])
      then
        begin
            { Change any castling zeroes or lowercase O's to uppercase letter 'O'. }
          if (HoldString[K] = '0') or
             (HoldString[K] = 'o')
            then TheMove := Concat(TheMove, 'O')
            else TheMove := Concat(TheMove, HoldString[K]);
        end;

  if (TheMove = 'OO')
    then TheMove := 'O-O';

  if (TheMove = 'OOO')
    then TheMove := 'O-O-O';
end;



{
procedure MassageMove(var TheMove: CandidateNotationType;
                      UsePGNLetters: Boolean);
var
  HoldString : Str255;
  K: Integer;
  theKingLetter,
  theQueenLetter,
  theRookLetter,
  theBishopLetter,
  theKnightLetter: Char;   // AnsiChar

begin
  if UsePGNLetters
    then
      begin
        theKingLetter := gPreferences.KingLetter;
        theQueenLetter := gPreferences.QueenLetter;
        theRookLetter := gPreferences.RookLetter;
        theBishopLetter := gPreferences.BishopLetter;
        theKnightLetter := gPreferences.KnightLetter;
      end
    else
      begin
        theKingLetter := 'K';
        theQueenLetter := 'Q';
        theRookLetter := 'R';
        theBishopLetter := 'B';
        theKnightLetter := 'N';
      end;

    // The move part of any snippet should appear in the first 6 characters.
  HoldString := TheMove;

  TheMove := '';

    // If there is an 'ep' hanging on the end of the move then trim it.
  if (Length (HoldString) > 3) and
     ((Copy (HoldString, Length (HoldString) -1, 2) = 'ep') or
      (Copy (HoldString, Length (HoldString) -1, 2) = 'EP'))
    then HoldString := Copy (HoldString, 1, Length (HoldString) - 2);

    // If this is not a simple pawn move like 'e4' or 'c6' and the first
    // letter looks like a piece then uppercase the piece.
  if (Pos (HoldString [2], '12345678') = 0) and
     (Pos (HoldString [1], 'abcdefgh') = 0)
    then HoldString [1] := UpCase (HoldString [1]);

  for K := 1 to Length (HoldString) do
    if (Pos(HoldString [K], 'abcdefgh12345678O0o') > 0) or
       (HoldString [K] in [theKingLetter,
                           theQueenLetter,
                           theRookLetter,
                           theBishopLetter,
                           theKnightLetter])
      then
        begin
            // Change any castling zeroes or lowercase O's to uppercase letter 'O'.
          if (HoldString[K] = '0') or
             (HoldString[K] = 'o')
            then TheMove := Concat(TheMove, 'O')
            else TheMove := Concat(TheMove, HoldString[K]);
        end;

  if (TheMove = 'OO')
    then TheMove := 'O-O';

  if (TheMove = 'OOO')
    then TheMove := 'O-O-O';
end;
}



function IsLongAlgebraicNotation(aNotation: CandidateNotationType) : Boolean;
begin
  IsLongAlgebraicNotation :=
     (Pos (aNotation [1], 'abcdefgh') > 0) and
     (Pos (aNotation [2], '12345678') > 0) and
     (Pos (aNotation [3], 'abcdefgh') > 0) and
     (Pos (aNotation [4], '12345678') > 0);
end;



  { This function returns any detected standard diacritic in a notation. }
function ExtractDiacriticFrom (aNotation : CandidateNotationType): Byte;
begin
  if (Pos('??', aNotation) > 0) then
    begin
      ExtractDiacriticFrom := kDiacriticDoubleQuestion;
      Exit;
    end;

  if (Pos('!!', aNotation) > 0) then
    begin
      ExtractDiacriticFrom := kDiacriticDoubleExclam;
      Exit;
    end;

  if (Pos('!?', aNotation) > 0) then
    begin
      ExtractDiacriticFrom := kDiacriticExclamQuestion;
      Exit;
    end;

  if (Pos('?!', aNotation) > 0) then
    begin
      ExtractDiacriticFrom := kDiacriticQuestionExclam;
      Exit;
    end;

  if (Pos('?', aNotation) > 0) then
    begin
      ExtractDiacriticFrom := kDiacriticQuestion;
      Exit;
    end;

  if (Pos('!', aNotation) > 0) then
    begin
      ExtractDiacriticFrom := kDiacriticExclam;
      Exit;
    end;

  ExtractDiacriticFrom := 1;    { The default is no diacritic. }
end;



function SameBoard(FirstBoard, SecondBoard: ChessBoardType): Boolean;
var
  K : Integer;

begin
  for K := 0 to 15 do
    begin
      if (FirstBoard.Squares[K] <> SecondBoard.Squares[K])
        then
          begin
            SameBoard := False;
            Exit;
          end;
    end;

  if (FirstBoard.WhiteOnMove             <> SecondBoard.WhiteOnMove) or
     (FirstBoard.WhiteCanCastleKingside  <> SecondBoard.WhiteCanCastleKingside) or
     (FirstBoard.WhiteCanCastleQueenside <> SecondBoard.WhiteCanCastleQueenside) or
     (FirstBoard.BlackCanCastleKingside  <> SecondBoard.BlackCanCastleKingside) or
     (FirstBoard.BlackCanCastleQueenside <> SecondBoard.BlackCanCastleQueenside) or
     (FirstBoard.EnPassantSquare         <> SecondBoard.EnPassantSquare)
    then
      begin
        SameBoard := False;
        Exit;
      end;

  SameBoard := True;
end;



procedure AddDiacriticToNotation(theMove: ChessMoveType;
                                  var theMoveNotation : CandidateNotationType);
begin
  case theMove.Diacritic of
    1 : theMoveNotation := Concat (theMoveNotation, '');  { no diacritic }
    2 : theMoveNotation := Concat (theMoveNotation, '!');
    3 : theMoveNotation := Concat (theMoveNotation, '!?');
    4 : theMoveNotation := Concat (theMoveNotation, '!!');
    5 : theMoveNotation := Concat (theMoveNotation, '?');
    6 : theMoveNotation := Concat (theMoveNotation, '?!');
    7 : theMoveNotation := Concat (theMoveNotation, '??');
    else
      begin
        BadBeep;

        { TellTheUser ('Program Problem',
                   'AddDiacriticToNotation was passed a bad diacritic.'); }

        Assert (False);
      end;
  end;
end;



function SameMove(FirstMove, SecondMove: ChessMoveType) : Boolean;
begin
  SameMove := (FirstMove.FromSquare = SecondMove.FromSquare) and
              (FirstMove.ToSquare = SecondMove.ToSquare) and
              (FirstMove.PromotionPiece = SecondMove.PromotionPiece);
end;



function BetterRate (FirstRate,
                     SecondRate : InformantRateType;
                     WhiteOnMove : Boolean;
                     IgnoreNonratedPositions : Boolean;
                     FavorUnclearOverEquality: Boolean) : InformantRateType;
begin
    { Determine the most favored Informant rate. }

    { Assume the FirstRate is the better rate. }

    { If we're ignoring nonrated positions then check for them now. }
  if IgnoreNonratedPositions
    then
      begin
        if (FirstRate = kNoRate)
          then
            begin
                { Anything in the second rate has to be as good or better. }
              BetterRate := SecondRate;
              Exit;
            end;

        if (SecondRate = kNoRate)
          then
            begin
                { Anything in the first rate has to be as good or better. }
              BetterRate := FirstRate;
              Exit;
            end;
      end;

    // If we have a nonrated position, and we didn't exit above because
    // they are being ignored, then favor kNoRate.
    // fixedin COW build 17
  if (FirstRate = kNoRate) or
     (SecondRate = kNoRate)
    then
      begin
        BetterRate := kNoRate;

        Exit;
      end;

  if WhiteOnMove
    then
      begin
          { Allow the user preference to override the }
          { the backsolve value of equal vs. unclear. }
        // if gPreferences.FavorUnclearOverEquality
        if FavorUnclearOverEquality
          then
            begin
              if (SecondRate = kUnclear) and
                 (FirstRate = kEqual)
                then
                  begin
                      { Set both so that the case statement }
                      { won't change them no matter what. }
                    FirstRate := kUnclear;
                    SecondRate := kUnclear;
                  end;

              if (SecondRate = kEqual) and
                 (FirstRate = kUnclear)
                then
                  begin
                      { Set both so that the case statement }
                      { won't change them no matter what. }
                    FirstRate := kUnclear;
                    SecondRate := kUnclear;
                  end;
            end;

        if (FirstRate = kLoop)     // fixedin COW build 24
          then
            begin
              if SecondRate in [kWhiteSlightAdvantage, kWhiteClearAdvantage, kWhiteIsWinning]
                then FirstRate := SecondRate  // White to move prefers an advantage.
                else SecondRate := kLoop;  // report the loop
            end;

        if (SecondRate = kLoop)     // fixedin COW build 24
          then
            begin
              if FirstRate in [kWhiteSlightAdvantage, kWhiteClearAdvantage, kWhiteIsWinning]
                then SecondRate := FirstRate  // White to move prefers an advantage.
                else FirstRate := kLoop;
            end;

          { Tendency is towards a better assessment and }
          { for "Equal" rather and "Unclear" or "W/Comp" }
        case SecondRate of
            { An unknown rate takes precedence over any rate. }
          kNoRate : FirstRate := kNoRate;

          kWhiteIsWinning,
          kWhiteClearAdvantage,
          kWhiteSlightAdvantage,
          kEqual,
          kUnclear,
          kWithCompensation,
          kBlackSlightAdvantage,
          kBlackClearAdvantage,
          kBlackIsWinning :
              { If this candidate is better for White }
              { and the optimum hasn't already been forced to pick }
              { "no rate" so far then take this new optimum candidate rate. }
            if (SecondRate < FirstRate)
              then FirstRate := SecondRate;
        end;  // code removed  fixedin COW build 24
      end

    else     { Black on move }
      begin
          { Allow the user preference to override the }
          { the backsolve value of equal vs. unclear. }
        // if gPreferences.FavorUnclearOverEquality
        if FavorUnclearOverEquality
          then
            begin
              if (SecondRate = kUnclear) and
                 (FirstRate = kEqual)
                then
                  begin
                      { Set both so that the case statement }
                      { won't change them no matter what. }
                    FirstRate := kUnclear;
                    SecondRate := kUnclear;
                  end;

              if (SecondRate = kEqual) and
                 (FirstRate = kUnclear)
                then
                  begin
                      { Set both so that the case statement }
                      { won't change them no matter what. }
                    FirstRate := kUnclear;
                    SecondRate := kUnclear;
                  end;
            end;

        if (FirstRate = kLoop)     // fixedin COW build 24
          then
            begin
              if SecondRate in [kBlackSlightAdvantage, kBlackClearAdvantage, kBlackIsWinning]
                then FirstRate := SecondRate  // Black to move prefers an advantage.
                else SecondRate := kLoop;  // report the loop
            end;

        if (SecondRate = kLoop)     // fixedin COW build 24
          then
            begin
              if FirstRate in [kBlackSlightAdvantage, kBlackClearAdvantage, kBlackIsWinning]
                then SecondRate := FirstRate  // Black to move prefers an advantage.
                else FirstRate := kLoop;
            end;

        case SecondRate of
            { An unknown rate takes precedence over any rate. }
          kNoRate : FirstRate := kNoRate;

          kWhiteIsWinning,
          kWhiteClearAdvantage,
          kWhiteSlightAdvantage,
          kBlackSlightAdvantage,
          kBlackClearAdvantage,
          kBlackIsWinning :
              { If this candidate offers a better rate for Black and }
              { we haven't been forced to pick "no rate" then take }
              { this candidate as the new optimum. }
            if (SecondRate > FirstRate)
              then FirstRate := SecondRate;

            { Prefer equal over anything but a disadvantage. }
          kEqual :
            begin
              if (FirstRate < kEqual) or   { White has some ad }
                 (FirstRate = kWithCompensation) or
                 (FirstRate = kUnclear)
                then FirstRate := kEqual;
            end;

            { Prefer compensation over a disadvantage but }
            { not over equal. }
          kWithCompensation :
            if (FirstRate < kEqual)
              then FirstRate := kWithCompensation;

            { Prefer an unclear position over a disadvantage }
            { or a sacrificial position. }
          kUnclear :
            begin
              if (FirstRate < kEqual) or
                 (FirstRate = kWithCompensation)
                then FirstRate := kUnclear;
            end;

        end;  // code removed  fixedin COW build 24
      end;

  BetterRate := FirstRate;
end;



function LetterForInformantRate (theRate : InformantRateType) : Char;
begin
  case
    theRate of
      kWhiteIsWinning : LetterForInformantRate := 'i';
      kWhiteClearAdvantage : LetterForInformantRate := 'j';
      kWhiteSlightAdvantage : LetterForInformantRate := 'k';
      kEqual : LetterForInformantRate := 'l';
      kUnclear : LetterForInformantRate := 'm';
      kWithCompensation : LetterForInformantRate := 'n';
      kBlackSlightAdvantage : LetterForInformantRate := 'o';
      kBlackClearAdvantage : LetterForInformantRate := 'p';
      kBlackIsWinning : LetterForInformantRate := 'q';
      kNoRate : LetterForInformantRate := ' ';
      kLoop : LetterForInformantRate := 'g';
      else
        begin
          LetterForInformantRate := ' ';

          ShowMessage('An unsupported Informant code was discovered.');
          // TellTheUser (kDlgStrDatabaseProblem,
          //              kDlgStrAnUnsupportedInformantCodeWasDiscovered);
        end;
  end;
end;



procedure ChangeToFigurines(var theNotation: CandidateNotationType;
                            KingLetter,
                            QueenLetter,
                            RookLetter,
                            BishopLetter,
                            KnightLetter: Char;
                            FigurineKingNumber,
                            FigurineQueenNumber,
                            FigurineRookNumber,
                            FigurineBishopNumber,
                            FigurineKnightNumber: Byte);
var
  K: Integer;

begin
  for K := 1 to Length(theNotation) do
    begin
      if (theNotation[K] = AnsiChar(KingLetter))
        then theNotation[K] := AnsiChar(FigurineKingNumber);   // legacy was Char()

      if (theNotation[K] = AnsiChar(QueenLetter))
        then theNotation[K] := AnsiChar(FigurineQueenNumber);

      if (theNotation[K] = AnsiChar(RookLetter))
        then theNotation[K] := AnsiChar(FigurineRookNumber);

      if (theNotation[K] = AnsiChar(BishopLetter))
        then theNotation[K] := AnsiChar(FigurineBishopNumber);

      if (theNotation[K] = AnsiChar(KnightLetter))
        then theNotation[K] := AnsiChar(FigurineKnightNumber);
    end;
end;



{
function LocalizedString(StringNumber : Integer) : String;
begin
  LocalizedString := LoadStr(gLanguage + StringNumber);
end;
}



function MoveIsAlreadyACandidate(theMove: ChessMoveType;
                                 theNumberOfCandidates: Byte;
                                 theCandidateArray: TCandidateArray): Boolean;
var
  K: Integer;

begin
  for K := 1 to theNumberOfCandidates do
    begin
      if (theCandidateArray [K].Move.FromSquare = theMove.FromSquare) and
         (theCandidateArray [K].Move.ToSquare = theMove.ToSquare) and
         (theCandidateArray [K].Move.PromotionPiece = theMove.PromotionPiece)
        then
          begin
            MoveIsAlreadyACandidate := True;
            Exit;
          end;
    end;

  MoveIsAlreadyACandidate := False;
end;



function UnMoveIsAlreadyAnUnCandidate(theUnMove: TUnMove;
                                      theNumberOfUnCandidates: Byte;
                                      theUnCandidateArray: TUnCandidateArray): Boolean;
var
  K: Integer;

begin
  for K := 1 to theNumberOfUnCandidates do
    begin
      if (theUnCandidateArray [K].FromSquare = theUnMove.FromSquare) and
         (theUnCandidateArray [K].ToSquare = theUnMove.ToSquare) and
         (theUnCandidateArray [K].OtherSquare1 = theUnMove.OtherSquare1) and
         (theUnCandidateArray [K].OtherSquare2 = theUnMove.OtherSquare2) and
         (theUnCandidateArray [K].FromSquarePiece = theUnMove.FromSquarePiece) and
         (theUnCandidateArray [K].ToSquarePiece = theUnMove.ToSquarePiece) and
         (theUnCandidateArray [K].OtherSquare1Piece = theUnMove.OtherSquare1Piece) and
         (theUnCandidateArray [K].OtherSquare2Piece = theUnMove.OtherSquare2Piece) and
         // (theUnCandidateArray [K].RightsWord = theUnMove.RightsWord) held the next six values in legacy code
         (theUnCandidateArray [K].WhiteOnMove = theUnMove.WhiteOnMove) and
         (theUnCandidateArray [K].WhiteCanCastleKingside = theUnMove.WhiteCanCastleKingside) and
         (theUnCandidateArray [K].WhiteCanCastleQueenside = theUnMove.WhiteCanCastleQueenside) and
         (theUnCandidateArray [K].BlackCanCastleKingside = theUnMove.BlackCanCastleKingside) and
         (theUnCandidateArray [K].BlackCanCastleQueenside = theUnMove.BlackCanCastleQueenside) and
         (theUnCandidateArray [K].EnPassantSquare = theUnMove.EnPassantSquare)
        then
          begin
            UnMoveIsAlreadyAnUnCandidate := True;
            Exit;
          end;
    end;

  UnMoveIsAlreadyAnUnCandidate := False;
end;



procedure ConvertSquareToString(theSquare: SquareType;
                                var theString: String);
var
  theRank, theFile: 1..8;

begin
  theRank := theSquare div 10 + 1;                        { Rank goes 1 to 8 }
  theFile := theSquare - ((theRank - 1)) * 10 + 1;        { File goes 1 to 8 }

  theString := Concat(Copy('abcdefgh', theFile, 1),
                      Copy('12345678', theRank, 1));
end;



function SquareFromString(const theString: String): SquareType;
var
  theRank, theFile: Integer;

begin
  Assert(Length(theString) = 2);

  if (Length(theString) <> 2)
    then
      begin
        Result := 0;
        Exit;
      end;

  theRank := Pos(theString[2], '12345678');
  theFile := Pos(theString[1], 'abcdefgh');

  Result := theFile - 1 + 10 * (theRank - 1);
end;



function TimeRemaining(OperationsPerSecond: LongInt;
                       TotalRemaining: LongInt): String;
var
  Hours,
  Minutes,
  Seconds,
  RemainingSeconds: LongInt;
  HoursString,
  MinutesString,
  SecondsString: String;

begin
  if OperationsPerSecond > 0
    then RemainingSeconds := Trunc(((1.0 /OperationsPerSecond) * TotalRemaining))
    else RemainingSeconds := 0;     // fixedin COW build 24

  Hours := RemainingSeconds div 3600;
  RemainingSeconds := RemainingSeconds - Hours * 3600;
  Minutes :=  RemainingSeconds div 60;
  RemainingSeconds := RemainingSeconds - Minutes * 60;
  Seconds :=  RemainingSeconds;

  HoursString := IntToStr(Hours) + ':';
  if (Length(HoursString) < 3)
    then HoursString := '0' + HoursString;
  MinutesString := IntToStr(Minutes) + ':';
  if (Length(MinutesString) < 3)
    then MinutesString := '0' + MinutesString;

  SecondsString := IntToStr(Seconds);
  if (Length(SecondsString) < 2)
    then SecondsString := '0' + SecondsString;

  Result := HoursString + MinutesString + SecondsString;
end;



function WhatIsInQuotes(theString: String): ShortString;
var
  QuotePosition : Integer;

begin
    { Get everything after the first quote. }
  QuotePosition := Pos ('"', theString);

  theString := Copy (theString, QuotePosition + 1, 255);

    { Keep everything before the second quote. }
  QuotePosition := Pos ('"', theString);

  theString := Copy (theString, 1, QuotePosition - 1);

  WhatIsInQuotes := ShortString(theString);
end;



{$IFDEF MSWINDOWS}
function RemoveReadOnlyAttribute(aFileName: String): Boolean;
var
  theExpandedFileName: String;
  theDiskNumberOfFileName: Integer;
  Attributes: Integer;

begin
  theExpandedFileName := ExpandFileName(aFileName);

  if (Length(theExpandedFileName) < 1)
    then
      begin
        Result := False;
        Exit;
      end;

  theDiskNumberOfFileName := (Pos(theExpandedFileName[1], 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'));

    // If this is a CD ROM, bail out.
    // CD ROMs have no bytes free.

  if (DiskFree(theDiskNumberOfFileName) = 0)
    then
      begin
        Result := False;
        Exit;
      end;

  Attributes := FileGetAttr(theExpandedFileName);

  if (Attributes and faReadOnly <> 0)
    then Result := (FileSetAttr(theExpandedFileName, Attributes - faReadOnly) = 0)
    else Result := True;
end;
  {$ENDIF MSWINDOWS}



function OppositeInformantRate(theRate: InformantRateType): InformantRateType;
begin
  case theRate of
    kWhiteIsWinning: Result := kBlackIsWinning;
    kWhiteClearAdvantage: Result := kBlackClearAdvantage;
    kWhiteSlightAdvantage: Result := kBlackSlightAdvantage;
    kBlackSlightAdvantage: Result := kWhiteSlightAdvantage;
    kBlackClearAdvantage: Result := kWhiteClearAdvantage;
    kBlackIsWinning: Result := kWhiteIsWinning;

    else Result := theRate;
  end;
end;



{
function TrainingCoverageMode: Boolean;
begin
  Result := (gPreferences.TrainingMode = kRandomCoverage) or
            (gPreferences.TrainingMode = kSequentialCoverage);
end;
}


function EdgeSquare(theSquare: SquareType): Boolean;
begin
    // Must have Integer(theSquare) to work in Delphi 7.
  EdgeSquare := (theSquare > 77) or
                (theSquare < 0) or
                (Integer(theSquare) in [8, 9, 18, 19, 28, 29, 38, 39, 48, 49, 58, 59, 68, 69]);
end;



function AddCommasTo(theNumber: String): String;
var
  theCommaPosition: Integer;

begin
  theCommaPosition := Length(theNumber) - 2;

  while (theCommaPosition > 1) do
    begin
      Insert(',', theNumber, theCommaPosition);

      theCommaPosition := theCommaPosition - 3
    end;

  Result := theNumber;
end;



{$IFDEF MSWINDOWS}
function GetRootDataFolderFromInstaller: String;
var
  theRegistry: TRegistry;
  Successful: Boolean;
  theDataFolder: String;

begin
  Result := '';

  theDataFolder := '';

    // Get the book path from the registry.  It's placed there first by the installer and
    // later by the program.
  theRegistry := TRegistry.Create;

  try

    Successful := theRegistry.OpenKey(kRegistryKeySoftware, False);

    Assert(Successful, 'Could not access registry''s Software section.');

    Successful := theRegistry.OpenKey(kRegistryKeyCompany, True);

    Assert(Successful);

    Successful := theRegistry.OpenKey(kRegistryKeyProgram, True);

    Assert(Successful);

    Successful := theRegistry.OpenKey(kRegistryKeyInstallerSettings, True);

    Assert(Successful);

    theDataFolder := theRegistry.ReadString(kRegistryKeyInstallerSettingsDataFolder);

  finally

    theRegistry.Free;

  end;

      // If it's not blank then use it.
  if (theDataFolder <> '')
    then
      begin
          // Add a trailing backslash if necessary.
        if (theDataFolder[Length(theDataFolder)] <> '\')
          then theDataFolder := theDataFolder + '\';

        Result := theDataFolder;
      end
    else Result := '';
end;



function GetRootDataFolderFromOLDInstaller: String;    // FIXEDIN build 141
var
  theRegistry: TRegistry;
  Successful: Boolean;
  theDataFolder: String;

begin
  Result := '';

  theDataFolder := '';

    // Get the book path from the registry.  It's placed there first by the installer and
    // later by the program.
  theRegistry := TRegistry.Create;

  try

    Successful := theRegistry.OpenKey(kRegistryKeySoftware, False);

    Assert(Successful, 'Could not access registry''s Software section.');

    Successful := theRegistry.OpenKey(kRegistryKeyCompany, True);

    Assert(Successful);

    Successful := theRegistry.OpenKey(kRegistryKeyProgramForOlderVersion, True);

    Assert(Successful);

    Successful := theRegistry.OpenKey(kRegistryKeyInstallerSettingsForOlderVersion, True);

    Assert(Successful);

    theDataFolder := theRegistry.ReadString(kRegistryKeyInstallerSettingsDataFolder);

  finally

    theRegistry.Free;

  end;

      // If it's not blank then use it.
  if (theDataFolder <> '')
    then
      begin
          // Add a trailing backslash if necessary.
        if (theDataFolder[Length(theDataFolder)] <> '\')
          then theDataFolder := theDataFolder + '\';

        Result := theDataFolder;
      end
    else Result := '';
end;
{$ENDIF MSWINDOWS}



procedure Unimplemented;
begin
  // Assert(false, 'This function is not yet implemented');

  // MessageDlg('The function is not implemented yet.',
  //                          TMsgDlgType.mtInformation,
  //                          [TMsgDlgBtn.mbOk], 0);

    // FIXEDIN build 91
  InformWithMessage('The function is not implemented yet.');
end;



{ * These methods interpret the bit masks that represent castling rights, }
{ * which side is on move and which square (if any) can be taken en passant. }

function LegacyRightsWordWhiteCanCastleKingSide(theWord: Word): Boolean;
begin
  Result := ((theWord and kLegacyRightsWordWhiteCanCastleKingSideBit) > 0);
end;



function LegacyRightsWordWhiteCanCastleQueenSide(theWord: Word): Boolean;
begin
  Result := ((theWord and kLegacyRightsWordWhiteCanCastleQueenSideBit) > 0);
end;



function LegacyRightsWordBlackCanCastleKingSide(theWord: Word): Boolean;
begin
  Result := ((theWord and kLegacyRightsWordBlackCanCastleKingSideBit) > 0);
end;



function LegacyRightsWordBlackCanCastleQueenSide(theWord: Word): Boolean;
begin
  Result := ((theWord and kLegacyRightsWordBlackCanCastleQueenSideBit) > 0);
end;



function LegacyRightsWordWhiteOnMove(theWord: Word): Boolean;
begin
  Result := ((theWord and kLegacyRightsWordWhiteOnMoveBit) > 0);
end;



function LegacyRightsWordEnPassantSquare(theWord: Word): SquareType;
var
  theByte : Byte;

begin
    { To get the 8 most significant bits as a value, do a }
    { Bit Shift Right 8 bits. }
    { EnPassantSquare := BSR(fBoard[16], 8); }
  theByte := theWord shr 8;

    { If these bits are wacked out then set the en passant }
    { square to zero and warn the user. }
  if ((theByte >= 30) and
      (theByte <= 47)) or
     (theByte = 0)
    then Result := theByte
    else
      begin
        Result := 0;

        Assert(False, 'LegacyRightsWordEnPassantSquare() had a bad value');
        { TellTheUser (kDlgStrDatabaseProblem,
                     kDlgStrTheEnPassantSquareForThisBoardIsNotCorrect); }
      end;
end;



function HasLegalFileNameCharacters(theFileName: String): Boolean;
begin
    if (Pos('/', theFileName) > 0) or
       (Pos('\', theFileName) > 0) or
       (Pos('?', theFileName) > 0) or
       (Pos(':', theFileName) > 0) or
       (Pos('*', theFileName) > 0)
      then
        begin
          Result := False;
          Exit;
        end;

  Result := True;
end;




function ConfirmWithMessage(theMessage: String): Boolean;
var
  lResult: Boolean;

begin
  lResult:=False;

  TDialogService.PreferredMode:=TDialogService.TPreferredMode.Platform;
  TDialogService.MessageDialog(theMessage, TMsgDlgType.mtConfirmation,
    FMX.Dialogs.mbYesNo, TMsgDlgBtn.mbNo, 0,
    procedure(const AResult: TModalResult)
    begin
      case AResult of
        mrYes: lResult:=True;
        mrNo:  lResult:=False;
      end;
    end);

  Result:=lResult;
end;



function ConfirmYesNoCancelWithMessage(theMessage: String): Integer;
var
  lResult: Integer;

begin
  lResult:=mrCancel;

  TDialogService.PreferredMode:=TDialogService.TPreferredMode.Platform;
  TDialogService.MessageDialog(theMessage, TMsgDlgType.mtConfirmation,
    FMX.Dialogs.mbYesNo, TMsgDlgBtn.mbNo, 0,
    procedure(const AResult: TModalResult)
    begin
      case AResult of
        mrYes: lResult:=mrYes;
        mrNo:  lResult:=mrNo;
        mrCancel:  lResult:=mrCancel;
      end;
    end);

  Result:=lResult;
end;



procedure InformWithMessage(theMessage: String);
var
  lResult: Boolean;

begin
  lResult:=False;

  TDialogService.PreferredMode:=TDialogService.TPreferredMode.Platform;
  TDialogService.MessageDialog(theMessage, TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0,
    procedure(const AResult: TModalResult)
    begin
      case AResult of
        mrOK: lResult:=True;
        mrCancel:  lResult:=False;
      end;
    end);

  // Result:=lResult;
end;



procedure InformErrorWithMessage(theMessage: String);
var
  lResult: Boolean;

begin
  lResult:=False;

  TDialogService.PreferredMode:=TDialogService.TPreferredMode.Platform;
  TDialogService.MessageDialog(theMessage, TMsgDlgType.mtError,
    [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0,
    procedure(const AResult: TModalResult)
    begin
      case AResult of
        mrOK: lResult:=True;
        mrCancel:  lResult:=False;
      end;
    end);

  // Result:=lResult;
end;



begin
  {
  gBadBeep := TNoise.Create(3800, 100, 120);
  gShortHighBeep := TNoise.Create(3800, 100, 120);
  }
end.
