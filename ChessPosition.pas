unit ChessPosition;

{ $DEFINE DEBUGEDGESQUARE    The code that generates all legal moves does try edge squares. }

INTERFACE

uses
  System.SysUtils,
  System.UITypes,
  FMX.Dialogs,
  DiagramTypes;

const
  EPDWhitePawnLetter   = 'P';
  EPDWhiteKnightLetter = 'N';
  EPDWhiteBishopLetter = 'B';
  EPDWhiteRookLetter   = 'R';
  EPDWhiteQueenLetter  = 'Q';
  EPDWhiteKingLetter   = 'K';

  EPDBlackPawnLetter   = 'p';
  EPDBlackKnightLetter = 'n';
  EPDBlackBishopLetter = 'b';
  EPDBlackRookLetter   = 'r';
  EPDBlackQueenLetter  = 'q';
  EPDBlackKingLetter   = 'k';


function EdgeSquare(theSquare: SquareType): Boolean;

type
  { TBoardNormalization = (kBoardNormal,
                         kBoardMirroredTopToBottom,
                         kBoardMirroredLeftToRight,
                         kBoardColorReversal,
                         kBoardMirroredTopToBottomAndLeftToRight,
                         kBoardColorReversalAndLeftToRight); }

                         
  TChessPosition = class(TObject)
    constructor Create;

    function GetBoard: PChessBoardType;
    procedure SetBoard (const aBoard : ChessBoardType);
    function GetNormalizedBoard: PChessBoardType;
    procedure GetNormalization(var ColorReversal,
                                   MirroredLeftToRight,
                                   MirroredTopToBottom: Boolean);
    function PieceOnSquare (theSquare: SquareType) : PieceType;

    function MirrorLeftToRight: Boolean;
    function MirrorTopToBottom: Boolean;
    function MirrorWhiteToBlack: Boolean;

    function WhiteCanCastleKingside : Boolean;
    function WhiteCanCastleQueenside : Boolean;
    function BlackCanCastleKingside : Boolean;
    function BlackCanCastleQueenside : Boolean;
    function WhiteOnMove : Boolean;
    procedure PutPieceOnSquare (thePiece: PieceType;
                                theSquare: SquareType);

    procedure SetWhiteCanCastleKingside (Yes: Boolean);
    procedure SetWhiteCanCastleQueenside (Yes: Boolean);
    procedure SetBlackCanCastleKingside (Yes: Boolean);
    procedure SetBlackCanCastleQueenside (Yes: Boolean);
    procedure SetWhiteOnMove (Yes: Boolean);
    procedure SetEnPassantSquareTo (theSquare : SquareType);

    function EnPassantSquare : SquareType;
    // function EdgeSquare (theSquare: SquareType) : Boolean;
    function SomethingOn (theSquare: SquareType) : Boolean;

    function GetEPDString: ShortString;
    // function GetZarkovString : String;
    function MakeBoardFromEPD(var aBoard: ChessBoardType;
                              EPDString: ShortString): Boolean;
    function SquareOfKingOnMove: SquareType;
    function NoPawns: Boolean;

    private

    fBoard,
    fNormalizedBoard: ChessBoardType;

    procedure FlipBoardColor;
  end;

  PChessPosition = ^TChessPosition;


{=============================================================================}

IMPLEMENTATION


function EdgeSquare(theSquare: SquareType): Boolean;
begin
    // Must have Integer(theSquare) or it won't work in Delphi 7!
  EdgeSquare := (theSquare > 77) or
                (theSquare < 0) or
                (Integer(theSquare) in [8, 9, 18, 19, 28, 29, 38, 39, 48, 49, 58, 59, 68, 69]);
end;



constructor TChessPosition.Create;
var
  Rank, K: Integer;
  // TESTSize: Integer;

begin
    { This entire method is dedicated to setting up the member field "fBoard." }

  PutPieceOnSquare(kWhiteRook, 0);
  PutPieceOnSquare(kWhiteKnight, 1);
  PutPieceOnSquare(kWhiteBishop, 2);
  PutPieceOnSquare(kWhiteQueen, 3);
  PutPieceOnSquare(kWhiteKing, 4);
  PutPieceOnSquare(kWhiteBishop, 5);
  PutPieceOnSquare(kWhiteKnight, 6);
  PutPieceOnSquare(kWhiteRook, 7);

  PutPieceOnSquare(kBlackRook, 70);
  PutPieceOnSquare(kBlackKnight, 71);
  PutPieceOnSquare(kBlackBishop, 72);
  PutPieceOnSquare(kBlackQueen, 73);
  PutPieceOnSquare(kBlackKing, 74);
  PutPieceOnSquare(kBlackBishop, 75);
  PutPieceOnSquare(kBlackKnight, 76);
  PutPieceOnSquare(kBlackRook, 77);

  for K := 10 to 17 do
    PutPieceOnSquare(kWhitePawn, SquareType(K));

  for K := 60 to 67 do
    PutPieceOnSquare(kBlackPawn, SquareType(K));

  for Rank := 2 to 5 do
    for K := 0 to 7 do
      PutPieceOnSquare(kEmptySquare, SquareType(Rank * 10 + K));

    // These procs replace what was in the [16] word value of the legacy code.
  SetWhiteOnMove(True);

  SetWhiteCanCastleKingside(True);
  SetWhiteCanCastleQueenside(True);
  SetBlackCanCastleKingside(True);
  SetBlackCanCastleQueenside(True);

  SetEnPassantSquareTo(0);
end;



function TChessPosition.GetBoard: PChessBoardType;
begin
  GetBoard := @fBoard;
end;



procedure TChessPosition.SetBoard (const aBoard: ChessBoardType);
begin
  fBoard := aBoard;
end;



function TChessPosition.GetNormalizedBoard: PChessBoardType;
var
  ColorReversal,
  MirroredLeftToRight,
  MirroredTopToBottom: Boolean;
  theOriginalBoard: ChessBoardType;
  theRank,
  theFile,
  theOppositeRank,
  theOppositeFile: Integer;
  theSourceSquare,
  theOppositeSquare: SquareType;
  theCastlingRight: Boolean;
  theEnPassantSquare: SquareType;
  theSourcePiece: PieceType;
  theNormalizedPosition: TChessPosition;

begin
    // Figure out what needs to be done to normalize the board.
  GetNormalization(ColorReversal,
                   MirroredLeftToRight,
                   MirroredTopToBottom);

  if not ColorReversal and
     not MirroredLeftToRight and
     not MirroredTopToBottom
    then
      begin
        Result := @fBoard;

        Exit;
      end;

  Assert(ColorReversal = not WhiteOnMove);

    // Remember the board as it is.
  theOriginalBoard := fBoard;

    // Normalized boards are always white to move.
  if ColorReversal
    then SetWhiteOnMove(True);

  theNormalizedPosition := TChessPosition.Create;

  try

    if ColorReversal
      then
        begin
            // trade castling rights
          theCastlingRight := WhiteCanCastleKingside;
          SetWhiteCanCastleKingside(BlackCanCastleKingside);
          SetBlackCanCastleKingside(theCastlingRight);

          theCastlingRight := WhiteCanCastleQueenside;
          SetWhiteCanCastleQueenside(BlackCanCastleQueenside);
          SetBlackCanCastleQueenside(theCastlingRight);
        end;

            // flip the en passant square
    theEnPassantSquare := EnPassantSquare;

    if (theEnPassantSquare <> 0)
      then
        begin
          theRank := theEnPassantSquare div 10;
          theFile := theEnPassantSquare mod 10;

          if ColorReversal
            then theRank := 7 - theRank;

          if MirroredTopToBottom
            then theRank := 7 - theRank;

          if MirroredLeftToRight
            then theFile := 7 - theFile;

          SetEnPassantSquareTo(theRank * 10 + theFile);
        end;

    theNormalizedPosition.SetBoard(fBoard);

    for theRank := 0 to 7 do
      for theFile := 0 to 7 do
        begin
          theSourceSquare := theRank * 10 + theFile;

          theOppositeRank := theRank;
          theOppositeFile := theFile;

          Assert(ColorReversal or MirroredLeftToRight or MirroredTopToBottom);

          if ColorReversal
            then theOppositeRank := 7 - theOppositeRank;

          if MirroredTopToBottom
            then theOppositeRank := 7 - theOppositeRank;

          if MirroredLeftToRight
            then theOppositeFile := 7 - theOppositeFile;

          theOppositeSquare := theOppositeRank * 10 + theOppositeFile;

            // NOTE: The 'opposite' squares could be the same squares
            //       if ColorReversal and MirroredTopToBottom are both true.

            // Trade the contents of the source and mirror squares.
          theSourcePiece := PieceOnSquare(theSourceSquare);
          // theOppositePiece := PieceOnSquare(theOppositeSquare);

          if ColorReversal
            then
              begin
                case theSourcePiece of
                  kWhiteKing: theSourcePiece := kBlackKing;
                  kWhiteQueen: theSourcePiece := kBlackQueen;
                  kWhiteRook: theSourcePiece := kBlackRook;
                  kWhiteBishop: theSourcePiece := kBlackBishop;
                  kWhiteKnight: theSourcePiece := kBlackKnight;
                  kWhitePawn: theSourcePiece := kBlackPawn;

                  kBlackKing: theSourcePiece := kWhiteKing;
                  kBlackQueen: theSourcePiece := kWhiteQueen;
                  kBlackRook: theSourcePiece := kWhiteRook;
                  kBlackBishop: theSourcePiece := kWhiteBishop;
                  kBlackKnight: theSourcePiece := kWhiteKnight;
                  kBlackPawn: theSourcePiece := kWhitePawn;
                end;
              end;

          theNormalizedPosition.PutPieceOnSquare(theSourcePiece,theOppositeSquare);
        end;

  finally

    fNormalizedBoard := theNormalizedPosition.GetBoard^;
    fBoard := theOriginalBoard;

    FreeAndNil(theNormalizedPosition);
  end;

  Result := @fNormalizedBoard;
end;



{ * These methods set the bit masks that represent castling rights, }
{ * which side is on move and which square (if any) can be taken en passant. }

{
const
  kWhiteCanCastleKingSideBit = $1;
  kWhiteCanCastleQueenSideBit = $2;
  kBlackCanCastleKingSideBit = $4;
  kBlackCanCastleQueenSideBit = $8;
  kWhiteOnMoveBit = $10;
}


procedure TChessPosition.SetWhiteCanCastleKingSide(Yes: Boolean);
begin
  fBoard.WhiteCanCastleKingside := Yes;
end;



procedure TChessPosition.SetWhiteCanCastleQueenSide (Yes: Boolean);
begin
  fBoard.WhiteCanCastleQueenside := Yes;
end;



procedure TChessPosition.SetBlackCanCastleKingSide (Yes: Boolean);
begin
  fBoard.BlackCanCastleKingside := Yes;
end;



procedure TChessPosition.SetBlackCanCastleQueenSide (Yes: Boolean);
begin
  fBoard.BlackCanCastleQueenside := Yes;
end;



procedure TChessPosition.SetWhiteOnMove(Yes: Boolean);
begin
  fBoard.WhiteOnMove := Yes;
end;



procedure TChessPosition.SetEnPassantSquareTo (theSquare: SquareType);
begin
  fBoard.EnPassantSquare := theSquare;
end;



{ * These methods interpret the bit masks that represent castling rights, }
{ * which side is on move and which square (if any) can be taken en passant. }

function TChessPosition.WhiteCanCastleKingSide: Boolean;
begin
  Result := fBoard.WhiteCanCastleKingSide;
end;



function TChessPosition.WhiteCanCastleQueenSide: Boolean;
begin
  Result := fBoard.WhiteCanCastleQueenSide;
end;



function TChessPosition.BlackCanCastleKingSide: Boolean;
begin
  Result := fBoard.BlackCanCastleKingSide;
end;



function TChessPosition.BlackCanCastleQueenSide: Boolean;
begin
  Result := fBoard.BlackCanCastleQueenSide;
end;



function TChessPosition.WhiteOnMove: Boolean;
begin
  Result := fBoard.WhiteOnMove;
end;



function TChessPosition.EnPassantSquare: SquareType;
begin
  Result := fBoard.EnPassantSquare;
end;



function TChessPosition.SomethingOn (theSquare: SquareType): Boolean;
  begin
    if EdgeSquare(theSquare) then
      begin
        SomethingOn := False;
        Exit;    { looking further would be out of range }
      end;

    SomethingOn := (PieceOnSquare(theSquare) > 0);
  end;



{ This method returns the piece on a square in this position. }

function TChessPosition.PieceOnSquare(theSquare: SquareType): PieceType;
var
  WhichInteger, WhichSetOfBits: Byte;
  TempWord : Word;

begin
  if EdgeSquare(theSquare) then
    begin
      {$IFDEF DEBUGEDGESQUARE}
      MessageDlg('ChessPosition.pas PieceOnSquare() was passed an "edge" square.',
                          TMsgDlgtype.mtInformation,
                          [TMsgDlgBtn.mbOk], 0);
      {$ENDIF}

      PieceOnSquare := kEmptySquare;

      Exit;
    end;

    { Subtract two edge squares for each rank. }
  theSquare := theSquare - ((theSquare div 10) * 2);

    { Which one of the 16 integers (0..15) in the board contains this square? }
  WhichInteger := theSquare div 4;

    { Which of the four 4-bit areas in the integer will hold this square? }
  WhichSetOfBits := theSquare mod 4;

    { Install the piece in the appropriate 4-bit area in the appropriate integer. }

  case WhichSetOfBits of
    0:
      begin
        TempWord := fBoard.Squares[WhichInteger] and $F000;
        PieceOnSquare := TempWord shr 12;
      end;
    1:
      begin
        TempWord := fBoard.Squares[WhichInteger] and $0F00;
        PieceOnSquare := TempWord shr 8;
      end;
    2:
      begin
        TempWord := fBoard.Squares[WhichInteger] and $00F0;
        PieceOnSquare := TempWord shr 4;
      end;
    3:
      begin
        PieceOnSquare := (fBoard.Squares[WhichInteger] and $000F);
      end

    else
      begin
        PieceOnSquare := 0;

        MessageDlg('PieceOnSquare() is hosed.',
                    TMsgDlgType.mtInformation,
                    [TMsgDlgBtn.mbOk],
                    0);
      end;

  end;
end;



{ This method puts a piece on a square in this position. }

procedure TChessPosition.PutPieceOnSquare(thePiece: PieceType;
                                          theSquare: SquareType);
var
  WhichInteger,
  WhichSetOfBits: Byte;

begin
  if EdgeSquare(theSquare)
    then
      begin
        {$IFDEF DEBUG}
        { TellTheUser (kDlgStrProgramProblem,
                     kDlgStrPutPieceOnSquareWasPassedAnEdgeSquare); }

        MessageDlg('PutPieceOnSquare() was passed an "edge" square.',
                    TMsgDlgType.mtInformation,
                    [TMsgDlgBtn.mbOk],
                    0);
        {$ENDIF}

        Exit;
      end;

    { Subtract two edge squares for each rank. }
  theSquare := theSquare - ((theSquare div 10) * 2);

    { Which one of the 16 integers (0..15) in the board contains this square? }
  WhichInteger := theSquare div 4;

    { Which of the four 4-bit areas in the integer will hold this square? }
  WhichSetOfBits := theSquare mod 4;

    {  $PUSH  Store the compiler directive settings (Symantec only!) }
    {  $V-  Turn Overflow detection off (Symantec only!) }
    { Install the piece in the appropriate 4-bit area in the appropriate integer. }
    case WhichSetOfBits of
      0:
        fBoard.Squares[WhichInteger] := (fBoard.Squares[WhichInteger] and $0FFF) + (ThePiece shl 12);
      1:
        fBoard.Squares[WhichInteger] := (fBoard.Squares[WhichInteger] and $F0FF) + (ThePiece shl 8);
      2:
        fBoard.Squares[WhichInteger] := (fBoard.Squares[WhichInteger] and $FF0F) + (ThePiece shl 4);
      3:
        fBoard.Squares[WhichInteger] := (fBoard.Squares[WhichInteger] and $FFF0) + ThePiece;
    end;
    {  $POP Restore the compiler directive settings (Symantec only!) }
  end;



function TChessPosition.GetEPDString: ShortString;
var
  TempString : ShortString;
  SpacesString : String [1];
  theCharacter : String [1];
  TotalSpaces : Integer;
  rank, column : Integer;
  theSquare : SquareType;
  theEnPassantSquare : SquareType;
  EnPassantRank,
  EnPassantFile : 1..8;

begin
  TempString := '';
  theCharacter := '';
  TotalSpaces := 0;

  for rank := 7 downto 0 do
    begin
      for column := 0 to 7 do
        begin
          theSquare := Rank * 10 + Column;

          case PieceOnSquare (theSquare) of
            kBlackKing   : theCharacter := 'k';
            kBlackQueen  : theCharacter := 'q';
            kBlackRook   : theCharacter := 'r';
            kBlackBishop : theCharacter := 'b';
            kBlackKnight : theCharacter := 'n';
            kBlackPawn   : theCharacter := 'p';
            kWhiteKing   : theCharacter := 'K';
            kWhiteQueen  : theCharacter := 'Q';
            kWhiteRook   : theCharacter := 'R';
            kWhiteBishop : theCharacter := 'B';
            kWhiteKnight : theCharacter := 'N';
            kWhitePawn   : theCharacter := 'P';

            kEmptySquare : theCharacter := '';
          end;

          if (theCharacter = '')
            then Inc (TotalSpaces)
            else
              begin
                  { Are there any spaces stored up? }
                if (TotalSpaces > 0)
                  then
                    begin
                      Str (TotalSpaces:0, SpacesString);
                      TempString := TempString + SpacesString;
                      TotalSpaces := 0;
                    end;

                TempString := TempString + theCharacter;
              end;
        end;

        { Are there any spaces stored up? }
      if (TotalSpaces > 0)
        then
          begin
            Str (TotalSpaces:0, SpacesString);
            TempString := TempString + SpacesString;
            TotalSpaces := 0;
          end;

      if (rank > 0)
        then TempString := TempString + '/';
    end;

  if WhiteOnMove
    then TempString := TempString + ' w '
    else TempString := TempString + ' b ';

  if WhiteCanCastleKingside
    then TempString := TempString + 'K';
  if WhiteCanCastleQueenside
    then TempString := TempString + 'Q';
  if BlackCanCastleKingside
    then TempString := TempString + 'k';
  if BlackCanCastleQueenside
    then TempString := TempString + 'q';

  if not WhiteCanCastleKingside and
     not BlackCanCastleKingside and
     not WhiteCanCastleQueenside and
     not BlackCanCastleQueenside
    then TempString := TempString + '-';

  theEnPassantSquare := EnPassantSquare;

    { Adjusted Oct 20, 1997 to NOT add a trailing blank. }
  if (theEnPassantSquare = 0)
    then TempString := TempString + ' -'
    else
      begin
        EnPassantRank := theEnPassantSquare div 10 + 1;   { Rank goes 1 to 8 }
        EnPassantFile := theEnPassantSquare - ((EnPassantRank - 1)) * 10 + 1;   { File goes 1 to 8 }

          { Zarkov (and EPD?) require the en passant square be the square }
          { on which the capture takes place. }
        if WhiteOnMove
          then Inc (EnPassantRank)
          else Dec (EnPassantRank);

        TempString := ShortString(Concat (String(TempString),
                              ' ',
                              Copy (String('abcdefgh'), EnPassantFile, 1),
                              Copy (String('12345678'), EnPassantRank, 1)));
      end;

  GetEPDString := TempString;
end;



function TChessPosition.MakeBoardFromEPD (var aBoard: ChessBoardType;
                                          EPDString: ShortString) : Boolean;
var
  Column: Word;
  Nibble: AnsiChar;
  NumberOfEmptySquares: Byte;
  theRank,
  theFile: Byte;
  ErrorResult: Integer;
  K: Byte;
  theSquare: SquareType;
  thePiece: PieceType;
  PositionString : String [71];   // 64 squares and the 7 slashes

begin
  MakeBoardFromEPD := False;  { an assumption }

    { Start with the character in the first column. }
  Column := 1;
  theRank := 7;
  theFile := 0;

  PositionString := Copy (EPDString, 1, Pos (' ', String(EPDString)) - 1);

  while (Column <= Length (PositionString)) do
    begin
      Nibble := AnsiChar(EPDString [Column]);
      Inc (Column);

        { Skip over the '/' characters. }
      if (Nibble = '/')
        then
          begin
            Nibble := AnsiChar(EPDString[Column]);
            Inc (Column);
          end;

        { If it's a number then put in blank squares. }
      if (Nibble >= '1') and
         (Nibble <= '8')
        then
          begin
            Val (String(Nibble), NumberOfEmptySquares, ErrorResult);
            if (ErrorResult <> 0)
              then Exit;

              { It is an error to fill in more squares than remain on }
              { this rank. }
            if (theFile + NumberOfEmptySquares > 9)
              then Exit;

            for K := 1 to NumberOfEmptySquares do
              begin
                theSquare := theRank * 10 + theFile;

                PutPieceOnSquare (kEmptySquare, theSquare);
                Inc (theFile);
                if (theFile > 7) and
                   (theRank > 0)
                  then
                    begin
                      theFile := 0;
                      Dec (theRank);
                     end;
              end;
          end
        else         { It is not a number from 1 to 8. }
          begin
            thePiece := kEmptySquare;

            if (Nibble = EPDBlackPawnLetter)
              then thePiece := kBlackPawn;
            if (Nibble = EPDBlackKnightLetter)
              then thePiece := kBlackKnight;
            if (Nibble = EPDBlackBishopLetter)
              then thePiece := kBlackBishop;
            if (Nibble = EPDBlackRookLetter)
              then thePiece := kBlackRook;
            if (Nibble = EPDBlackQueenLetter)
              then thePiece := kBlackQueen;
            if (Nibble = EPDBlackKingLetter)
              then thePiece := kBlackKing;

            if (Nibble = EPDWhitePawnLetter)
              then thePiece := kWhitePawn;
            if (Nibble = EPDWhiteKnightLetter)
              then thePiece := kWhiteKnight;
            if (Nibble = EPDWhiteBishopLetter)
              then thePiece := kWhiteBishop;
            if (Nibble = EPDWhiteRookLetter)
              then thePiece := kWhiteRook;
            if (Nibble = EPDWhiteQueenLetter)
              then thePiece := kWhiteQueen;
            if (Nibble = EPDWhiteKingLetter)
              then thePiece := kWhiteKing;

            theSquare := theRank * 10 + theFile;

            PutPieceOnSquare (thePiece, theSquare);
            Inc (theFile);
            if (theFile > 7) and
               (theRank > 0)
              then
                begin
                  theFile := 0;
                  Dec (theRank);
                 end;
          end;

    end;   { While (Column... }


    { If we didn't go through each and every square then bail out. }
  if (theRank <> 0) or
     (theFile <> 8)
    then Exit;

    { Trim off the position part and its trailing blank. }
  EPDString := Copy (EPDString, Pos (' ', String(EPDString)) + 1, 255);

    { The on move indicator, castling indicators and en passant indicators }
    { are still expected. }

  Assert (Length (EPDString) > 0);

  if (Length (EPDString) = 0)
    then Exit;

    { The first character should now be w or b. }
  if (EPDString [1] <> 'w') and
     (EPDString [1] <> 'b')
    then Exit;

  SetWhiteOnMove (EPDString [1] = 'w');

    { Trim off the on move character and its trailing blank. }
  EPDString := Copy (EPDString, Pos (' ', String(EPDString)) + 1, 255);

    { The castling indicators and en passant indicators }
    { are still expected. }

  Assert (Length (EPDString) > 0);

  if (Length (EPDString) = 0)
    then Exit;

  if (Pos (EPDWhiteKingLetter, String(EPDString)) > 0)
    then SetWhiteCanCastleKingside (True)
    else SetWhiteCanCastleKingside (False);

  if (Pos (EPDWhiteQueenLetter, String(EPDString)) > 0)
    then SetWhiteCanCastleQueenside (True)
    else SetWhiteCanCastleQueenside (False);

  if (Pos (EPDBlackKingLetter, String(EPDString)) > 0)
    then SetBlackCanCastleKingside (True)
    else SetBlackCanCastleKingside (False);

  if (Pos (EPDBlackQueenLetter, String(EPDString)) > 0)
    then SetBlackCanCastleQueenside (True)
    else SetBlackCanCastleQueenside (False);

    { Trim off the castling indicators and the trailing blank. }
  EPDString := Copy (EPDString, Pos (' ', String(EPDString)) + 1, 255);

    { The en passant indicator is still expected. }
  Assert(Length (EPDString) > 0);

  if (Length (EPDString) = 0)
    then Exit;

  if (EPDString[1] = '-')
    then SetEnPassantSquareTo (0)
    else
      begin
        theSquare := 10 * (Pos (String(EPDString[2]), '12345678') - 1) +
                     Pos (String(EPDString[1]), 'abcdefgh') - 1;

          { Zarkov (EPD!?) sets the en passant square BEHIND the }
          { pawn that can be captured.  This program makes it the square }
          { of the pawn that can be captured en passant. }
        if WhiteOnMove
          then theSquare := theSquare - 10
          else theSquare := theSquare + 10;

        if not ((theSquare >= 30) and (theSquare <= 37)) and
           not ((theSquare >= 40) and (theSquare <= 47))
          then
            begin
              {$IFDEF DEBUG}
              { TellTheUser (kDlgStrEPDProblem,
                           kDlgStrTheEnPassantSquareWasNotCorrect); }
              MessageDlg('TChessPosition.MakeBoardFromEPD() - en passant square is not correct.',
                          TMsgDlgType.mtInformation,
                          [TMsgDlgBtn.mbOk],
                          0);
              {$ENDIF}

              theSquare := 0;
            end;

        SetEnPassantSquareTo (theSquare);
      end;


  aBoard := fBoard;

  MakeBoardFromEPD := True;
end;



procedure TChessPosition.GetNormalization(var ColorReversal,
                                              MirroredLeftToRight,
                                              MirroredTopToBottom: Boolean);
var
  theSquareOfKingOnMove: SquareType;
  theOriginalBoard: ChessBoardType;

begin
    { To normalize a board, (no pawns or opponent castling rights) the white king
      must be on move.
      If the opponent can castle then the board is normalized no matter where the
      white king is.
      If the opponent cannot castle but there are pawns, then the white king
      must be on the right side of the board. }


    // starting assumptions
  ColorReversal := False;
  MirroredLeftToRight := False;
  MirroredTopToBottom := False;


    // Normalized boards are always White to move.
  if not WhiteOnMove
    then
      begin
        ColorReversal := True;

        theOriginalBoard := fBoard;  // Keep a copy so we can set it back before exiting.

        FlipBoardColor;
      end;


    // If the king on the side to move is on the queenside and
    // the opponent cannot castle then the position should be
    // mirrored in order to be normal (placing the king on the
    // side to move on the kingside).

    // The king on move can be anywhere on a normalized board
    // if the opponent can still castle.
  if (BlackCanCastleKingside or BlackCanCastleQueenside)
    then
      begin
        if ColorReversal
          then fBoard := theOriginalBoard;

        Exit;
      end;

  { if not WhiteOnMove and
     (WhiteCanCastleKingside or WhiteCanCastleQueenside)
    then
      begin
        Result := kBoardColorReversal;

        if ColorReversal
          then fBoard := theOriginalBoard;

        Exit;
      end; }


    // What quadrant is the king in?
  theSquareOfKingOnMove := SquareOfKingOnMove;

    // The king on move is in the lower righthand corner, always normalized.
  if (Integer(theSquareOfKingOnMove) in [4,5,6,7,14,15,16,17,24,25,26,27,34,35,36,37])
    then
      begin
        if ColorReversal
          then fBoard := theOriginalBoard;

        Exit;
      end;


    // The king on move is in the upper righthand corner.
  if (Integer(theSquareOfKingOnMove) in [44,45,46,47,54,55,56,57,64,65,66,67,74,75,76,77])
    then
      begin
        if NoPawns
          then MirroredTopToBottom := True;

        if ColorReversal
          then fBoard := theOriginalBoard;

        Exit;
      end;


    // The king on move is in the lower lefthand corner.
  if (Integer(theSquareOfKingOnMove) in [0,1,2,3,10,11,12,13,20,21,22,23,30,31,32,33])
    then
      begin
        MirroredLeftToRight := True;

        if ColorReversal
          then fBoard := theOriginalBoard;
      end;


    // The king on move is in the upper lefthand corner.
  if (Integer(theSquareOfKingOnMove) in [40,41,42,43,50,51,52,53,60,61,62,63,70,71,72,73])
    then
      begin
        MirroredLeftToRight := True;

        if NoPawns
          then MirroredTopToBottom := True;

        if ColorReversal
          then fBoard := theOriginalBoard;
      end;
end;



function TChessPosition.SquareOfKingOnMove: SquareType;
var
  theKingLocation: SquareType;
  theKingToFind: PieceType;

begin
  { if WhiteOnMove
    then theKingToFind := kWhiteKing
    else theKingToFind := kBlackKing; }

    // Override this procedure so it always looks for the white king.
  theKingToFind := kWhiteKing;

  theKingLocation := 0;
  while (PieceOnSquare(theKingLocation) <> theKingToFind) and
        (theKingLocation < 77) do
    begin
      theKingLocation := theKingLocation + 1;
      if EdgeSquare(theKingLocation)
        then theKingLocation := theKingLocation + 2;
    end;

  if not (PieceOnSquare(theKingLocation) = theKingToFind)
    then Raise Exception.Create('TChessPosition.SquareOfKingOnMove() has a corrupt position.');

  Result := theKingLocation;
end;



function TChessPosition.NoPawns: Boolean;
var
  theSquare: SquareType;

begin
    // Search the second through seventh ranks for any pawn.
  theSquare := 10;
  while (PieceOnSquare(theSquare) <> kWhitePawn) and
        (PieceOnSquare(theSquare) <> kBlackPawn) and
        (theSquare < 67) do
    begin
      theSquare := theSquare + 1;
      if EdgeSquare(theSquare)
        then theSquare := theSquare + 2;
    end;

  Result := (PieceOnSquare(theSquare) <> kWhitePawn) and
            (PieceOnSquare(theSquare) <> kBlackPawn);
end;



procedure TChessPosition.FlipBoardColor;
var
  theRank,
  theFile: Integer;
  theSourceSquare,
  theOppositeSquare: SquareType;
  theCastlingRight: Boolean;
  theEnPassantSquare: SquareType;
  theSourcePiece,
  theOppositePiece: PieceType;

begin
            // trade castling rights
          theCastlingRight := WhiteCanCastleKingside;
          SetWhiteCanCastleKingside(BlackCanCastleKingside);
          SetBlackCanCastleKingside(theCastlingRight);

          theCastlingRight := WhiteCanCastleQueenside;
          SetWhiteCanCastleQueenside(BlackCanCastleQueenside);
          SetBlackCanCastleQueenside(theCastlingRight);

            // flip the en passant square
          theEnPassantSquare := EnPassantSquare;

          if (theEnPassantSquare <> 0)
            then
              begin
                theRank := 7 - (theEnPassantSquare div 10);
                theFile := theEnPassantSquare mod 10;

                SetEnPassantSquareTo(theRank * 10 + theFile);
              end;

    for theRank := 0 to 3 do        // lower half of the board.
      for theFile := 0 to 7 do
        begin
          theSourceSquare := theRank * 10 + theFile;

          theOppositeSquare := (7 - theRank) * 10 + theFile;

          Assert(theSourceSquare <> theOppositeSquare);

            // Trade the contents of the source and mirror squares.
          theSourcePiece := PieceOnSquare(theSourceSquare);
          theOppositePiece := PieceOnSquare(theOppositeSquare);

                case theSourcePiece of
                  kWhiteKing: theSourcePiece := kBlackKing;
                  kWhiteQueen: theSourcePiece := kBlackQueen;
                  kWhiteRook: theSourcePiece := kBlackRook;
                  kWhiteBishop: theSourcePiece := kBlackBishop;
                  kWhiteKnight: theSourcePiece := kBlackKnight;
                  kWhitePawn: theSourcePiece := kBlackPawn;
                  kBlackKing: theSourcePiece := kWhiteKing;
                  kBlackQueen: theSourcePiece := kWhiteQueen;
                  kBlackRook: theSourcePiece := kWhiteRook;
                  kBlackBishop: theSourcePiece := kWhiteBishop;
                  kBlackKnight: theSourcePiece := kWhiteKnight;
                  kBlackPawn: theSourcePiece := kWhitePawn;
                end;

                case theOppositePiece of
                  kWhiteKing: theOppositePiece := kBlackKing;
                  kWhiteQueen: theOppositePiece := kBlackQueen;
                  kWhiteRook: theOppositePiece := kBlackRook;
                  kWhiteBishop: theOppositePiece := kBlackBishop;
                  kWhiteKnight: theOppositePiece := kBlackKnight;
                  kWhitePawn: theOppositePiece := kBlackPawn;
                  kBlackKing: theOppositePiece := kWhiteKing;
                  kBlackQueen: theOppositePiece := kWhiteQueen;
                  kBlackRook: theOppositePiece := kWhiteRook;
                  kBlackBishop: theOppositePiece := kWhiteBishop;
                  kBlackKnight: theOppositePiece := kWhiteKnight;
                  kBlackPawn: theOppositePiece := kWhitePawn;
                end;

          PutPieceOnSquare(theSourcePiece,theOppositeSquare);
          PutPieceOnSquare(theOppositePiece,theSourceSquare);
        end;
end;



function TChessPosition.MirrorLeftToRight: Boolean;
var
  theFlippedPosition: TChessPosition;
  theEnPassantSquare: SquareType;
  theRank,
  theFile,
  theOppositeRank,
  theOppositeFile: Integer;
  theSourceSquare,
  theOppositeSquare: SquareType;
  theSourcePiece: PieceType;

begin
    // If either side has castling rights then it cannot be flipped left to right.
  if WhiteCanCastleKingside or
     WhiteCanCastleQueenside or
     BlackCanCastleKingside or
     BlackCanCastleQueenside
    then
      begin
        Result := False;
        Exit;
      end;

  theFlippedPosition := TChessPosition.Create;

  theFlippedPosition.SetBoard(fBoard);

  try

    // flip the en passant square
  theEnPassantSquare := EnPassantSquare;

  if (theEnPassantSquare <> 0)
    then
      begin
        theRank := theEnPassantSquare div 10;
        theFile := theEnPassantSquare mod 10;

        theFile := 7 - theFile;

        theFlippedPosition.SetEnPassantSquareTo(theRank * 10 + theFile);
      end;

  for theRank := 0 to 7 do
    for theFile := 0 to 7 do
      begin
        theSourceSquare := theRank * 10 + theFile;

        theOppositeRank := theRank;
        theOppositeFile := theFile;

          // Mirror left to right.
        theOppositeFile := 7 - theOppositeFile;

        theOppositeSquare := theOppositeRank * 10 + theOppositeFile;

          // Trade the contents of the source and mirror squares.
        theSourcePiece := PieceOnSquare(theSourceSquare);

        theFlippedPosition.PutPieceOnSquare(theSourcePiece,theOppositeSquare);
      end;

    fBoard := theFlippedPosition.GetBoard^;

  finally

    FreeAndNil(theFlippedPosition);
  end;

  Result := True;
end;



function TChessPosition.MirrorTopToBottom: Boolean;  
var
  theFlippedPosition: TChessPosition;
  theRank,
  theFile,
  theOppositeRank,
  theOppositeFile: Integer;
  theSourceSquare,
  theOppositeSquare: SquareType;
  theSourcePiece: PieceType;

begin
    // If there are pawns then it cannot be flipped top to bottom.
  if not NoPawns
    then
      begin
        Result := False;
        Exit;
      end;

  theFlippedPosition := TChessPosition.Create;

  theFlippedPosition.SetBoard(fBoard);

    // no pawns in top to bottom positions.
  Assert(EnPassantSquare = 0, 'The en passant square is invalid.');

  try

  for theRank := 0 to 7 do
    for theFile := 0 to 7 do
      begin
        theSourceSquare := theRank * 10 + theFile;

        theOppositeRank := theRank;
        theOppositeFile := theFile;

          // Mirror top to bottom.
        theOppositeRank := 7 - theOppositeRank;

        theOppositeSquare := theOppositeRank * 10 + theOppositeFile;

          // Trade the contents of the source and mirror squares.
        theSourcePiece := PieceOnSquare(theSourceSquare);

        theFlippedPosition.PutPieceOnSquare(theSourcePiece,theOppositeSquare);
      end;

    fBoard := theFlippedPosition.GetBoard^;

  finally

    FreeAndNil(theFlippedPosition);
  end;

  Result := True;
end;



function TChessPosition.MirrorWhiteToBlack: Boolean;
var
  theCastlingRight: Boolean;
  theFlippedPosition: TChessPosition;
  theEnPassantSquare: SquareType;
  theRank,
  theFile,
  theOppositeRank,
  theOppositeFile: Integer;
  theSourceSquare,
  theOppositeSquare: SquareType;
  theSourcePiece: PieceType;

begin
  SetWhiteOnMove(not WhiteOnMove);

    // trade castling rights
  theCastlingRight := WhiteCanCastleKingside;
  SetWhiteCanCastleKingside(BlackCanCastleKingside);
  SetBlackCanCastleKingside(theCastlingRight);

  theCastlingRight := WhiteCanCastleQueenside;
  SetWhiteCanCastleQueenside(BlackCanCastleQueenside);
  SetBlackCanCastleQueenside(theCastlingRight);

    // flip the en passant square
  theEnPassantSquare := EnPassantSquare;

    if (theEnPassantSquare <> 0)
      then
        begin
          theRank := theEnPassantSquare div 10;
          theFile := theEnPassantSquare mod 10;

            // Flip top to bottom when doing color reverses.
          theRank := 7 - theRank;

          SetEnPassantSquareTo(theRank * 10 + theFile);
        end;

  theFlippedPosition := TChessPosition.Create;

  try

    theFlippedPosition.SetBoard(fBoard);

  for theRank := 0 to 7 do
    for theFile := 0 to 7 do
      begin
        theSourceSquare := theRank * 10 + theFile;

        theOppositeRank := theRank;
        theOppositeFile := theFile;

          // Mirror top to bottom when flipping White to move.
        theOppositeRank := 7 - theOppositeRank;
        // theOppositeFile := 7 - theOppositeFile;

        theOppositeSquare := theOppositeRank * 10 + theOppositeFile;

          // Trade the contents of the source and mirror squares.
        theSourcePiece := PieceOnSquare(theSourceSquare);

                case theSourcePiece of
                  kWhiteKing: theSourcePiece := kBlackKing;
                  kWhiteQueen: theSourcePiece := kBlackQueen;
                  kWhiteRook: theSourcePiece := kBlackRook;
                  kWhiteBishop: theSourcePiece := kBlackBishop;
                  kWhiteKnight: theSourcePiece := kBlackKnight;
                  kWhitePawn: theSourcePiece := kBlackPawn;

                  kBlackKing: theSourcePiece := kWhiteKing;
                  kBlackQueen: theSourcePiece := kWhiteQueen;
                  kBlackRook: theSourcePiece := kWhiteRook;
                  kBlackBishop: theSourcePiece := kWhiteBishop;
                  kBlackKnight: theSourcePiece := kWhiteKnight;
                  kBlackPawn: theSourcePiece := kWhitePawn;
                end;

        theFlippedPosition.PutPieceOnSquare(theSourcePiece,theOppositeSquare);
      end;

    fBoard := theFlippedPosition.GetBoard^;

  finally

    FreeAndNil(theFlippedPosition);
  end;

  Result := True;
end;



end.
