unit Parser;

interface

uses
  SysUtils,   { FreeAndNil() }

  {$IFDEF DEBUG}
  FMX.Dialogs,
  {$ENDIF}

  gTypes,
  Utils,
  DiagramTypes,

  ChessPosition;



type
  TChessNotationArray = array [1..kMaximumPlies] of CandidateNotationType;

  TChessParser = class(TObject)
    itsChessMove : ChessMoveType;
    itsNotation : CandidateNotationType;
    itsNotationIsOK : Boolean;
    itsMoveIsCapturing,
    itsMoveIsChecking : Boolean;

    RefreshSquare1, RefreshSquare2 : SquareType;

    ToRank, ToFile, FromRank, FromFile, ExplicitRank, ExplicitFile : Integer;
    ToSquare, FromSquare : SquareType;
    PromotionPiece : PieceType;
    WhiteKingLocation, BlackKingLocation : SquareType;

    TotalDirectionsOf : Array [kWhiteKnight..kBlackKing] of Integer;
    PieceShift : Array [kWhiteKnight..kBlackKing, 1..8] of Integer;
    RankCheck, FileCheck : Array [1..8, 1..8] of ShortInt;

    constructor Create;

    destructor Destroy; override;

    procedure SetBoard (aBoard : ChessBoardType);
    function GetBoard : PChessBoardType;
    function GetEPDString : String;

    procedure SetPieceLetters (theKingLetter,
                               theQueenLetter,
                               theRookLetter,
                               theBishopLetter,
                               theKnightLetter: Char);
    procedure GetPieceLetters (var theKingLetter,
                               theQueenLetter,
                               theRookLetter,
                               theBishopLetter,
                               theKnightLetter: Char);

    procedure SetIndicateChecks (Yes : Boolean);
    procedure SetIndicateCaptures (Yes : Boolean);

    procedure PutPieceOnSquare (thePiece: PieceType;
                                theSquare: SquareType);

    function WhiteOnMove : Boolean;
    function PieceOnSquare (theSquare: SquareType) : PieceType;

    procedure SetNotation (aNotation: CandidateNotationType);

    function NotationFor (aChessMove : ChessMoveType) : CandidateNotationType;
    function ShortAlgebraicNotationFor (aNotation : CandidateNotationType) : CandidateNotationType;
    function GetChessMove : PChessMoveType;

    procedure MakeMoveNotation;
    function NotationIsLegal : Boolean;
    procedure GetMoveList(var theNumberOfMoves: Integer;
                          var theMoveArray: TChessNotationArray);

    function IsStalemate: Boolean;
    function IsCheckmate: Boolean;

    private

    fKingLetter,
    fQueenLetter,
    fRookLetter,
    fBishopLetter,
    fKnightLetter: Char;  // legacy was Char;   Newwer code tried AnsiChar

    fIndicateCaptures : Boolean;
    fIndicateChecks : Boolean;

    itsPosition : TChessPosition;

    procedure SetUpSpecialStuff;
    function KingWouldBeLeftInCheck : Boolean;
    function KingIsInCheck: Boolean;
    function KingCanBeTaken : Boolean;
    procedure CheckCastling (Kingside : Boolean);
    procedure WhitePawnMove;
    procedure BlackPawnMove;
    procedure WhitePawnCapture;
    procedure BlackPawnCapture;
    procedure PawnMove;
    procedure PawnCapture;
    procedure PawnPromote;
    procedure MoveThePawn;
    procedure Castles;
    procedure FlipMove;
    procedure FindKings;
    procedure MoveThe (thePiece: PieceType);
  end;


{ var
  gParser : TChessParser; }


{=============================================================================}

IMPLEMENTATION


function EdgeSquare(theSquare: SquareType): Boolean;
begin
    // Must have Integer(theSquare) to work in Delphi 7.
  EdgeSquare := (theSquare > 77) or
                (theSquare < 0) or
                (Integer(theSquare) in [8, 9, 18, 19, 28, 29, 38, 39, 48, 49, 58, 59, 68, 69]);
end;



  { ***** SERIOUS TEST CODE! }
function Strang (theNumber : Integer) : String;
var
  theString : String;
begin
  Str (theNumber:0, theString);
  Result := theString;
end;



{ How to use a parser object without going insane: }

{ First, create and initialize the parser with calls to }
{ New() and Init. Inform the parser of the position }
{ with a call to SetPosition. If you want to know if }
{ a notation is legal, inform the parser of the notation }
{ with a call to SetNotation. Then call IsNotationLegal. }

{ If you want to know the }
{ minimum legal notation for a chess move, set the position }
{ and call NotationFor(theChessMove). This call will return }
{ an empty string if the chess move is not legal. }

{ If you want to make a move in a position, inform the parser }
{ about the move (SetPosition(thePosition)), set the notation }
{ (SetNotation(theNotation)) and call MakeMoveNotation.}

{ If you want to know if a notation is a legal move in the}
{ parser's position, set the notation and call NotationIsLegal. }


constructor TChessParser.Create;
begin
  inherited Create;

  itsChessMove.FromSquare := 0;
  itsChessMove.ToSquare := 0;
  itsChessMove.PromotionPiece := kEmptySquare;
  itsChessMove.Diacritic := 1;

  itsNotation := 'Error';
  itsNotationIsOK := False;

  itsMoveIsCapturing := False;
  itsMoveIsChecking := False;

  RefreshSquare1 := -1;
  RefreshSquare2 := -1;

  ToRank := -1;
  ToFile := -1;
  FromRank := -1;
  FromFile := -1;
  ExplicitRank := -1;
  ExplicitFile := -1;
  ToSquare := -1;
  FromSquare := -1;
  PromotionPiece := kEmptySquare;

  fKingLetter := 'K';
  fQueenLetter := 'Q';
  fRookLetter := 'R';
  fBishopLetter := 'B';
  fKnightLetter := 'N';

  fIndicateCaptures := True;
  fIndicateChecks := True;

  SetUpSpecialStuff;

  itsPosition := TChessPosition.Create;

    { if (itsPosition = nil)
      then
        begin
          TellTheUser (kDlgStrProgramOrMemoryProblem,
                       kDlgStrCParserInitIsFailingDueToNoMemoryForItsPosition);
          Fail;
        end;   }


    { Bug fix in version 8.1. }
    { This call sets WhiteKingLocation and BlackKingLocation. }
  FindKings;
end;



destructor TChessParser.Destroy;
begin
  FreeAndNil(itsPosition);

  inherited Destroy;
end;



procedure TChessParser.SetUpSpecialStuff;
var
  K, L: Integer;

begin
  for K := 0 to 7 do
    for L := 0 to 7 do
      begin
        RankCheck[K + 1, L + 1] := 10 * K + L;
        FileCheck[L + 1, K + 1] := 10 * K + L;
      end;

  TotalDirectionsOf[kWhiteKnight] := 8;
  TotalDirectionsOf[kBlackKnight] := 8;
  TotalDirectionsOf[kWhiteBishop] := 4;
  TotalDirectionsOf[kBlackBishop] := 4;
  TotalDirectionsOf[kWhiteRook] := 4;
  TotalDirectionsOf[kBlackRook] := 4;
  TotalDirectionsOf[kWhiteQueen] := 8;
  TotalDirectionsOf[kBlackQueen] := 8;
  TotalDirectionsOf[kWhiteKing] := 8;
  TotalDirectionsOf[kBlackKing] := 8;

  PieceShift[kWhiteKnight, 1] := -21;
  PieceShift[kWhiteKnight, 2] := 21;
  PieceShift[kWhiteKnight, 3] := -12;
  PieceShift[kWhiteKnight, 4] := 12;
  PieceShift[kWhiteKnight, 5] := -19;
  PieceShift[kWhiteKnight, 6] := 19;
  PieceShift[kWhiteKnight, 7] := 8;
  PieceShift[kWhiteKnight, 8] := -8;

  PieceShift[kBlackKnight, 1] := -21;
  PieceShift[kBlackKnight, 2] := 21;
  PieceShift[kBlackKnight, 3] := -12;
  PieceShift[kBlackKnight, 4] := 12;
  PieceShift[kBlackKnight, 5] := -19;
  PieceShift[kBlackKnight, 6] := 19;
  PieceShift[kBlackKnight, 7] := 8;
  PieceShift[kBlackKnight, 8] := -8;

    PieceShift[kWhiteQueen, 1] := 1;
    PieceShift[kWhiteQueen, 2] := -1;
    PieceShift[kWhiteQueen, 3] := 10;
    PieceShift[kWhiteQueen, 4] := -10;
    PieceShift[kWhiteQueen, 5] := 11;
    PieceShift[kWhiteQueen, 6] := -11;
    PieceShift[kWhiteQueen, 7] := 9;
    PieceShift[kWhiteQueen, 8] := -9;

    PieceShift[kBlackQueen, 1] := 1;
    PieceShift[kBlackQueen, 2] := -1;
    PieceShift[kBlackQueen, 3] := 10;
    PieceShift[kBlackQueen, 4] := -10;
    PieceShift[kBlackQueen, 5] := 11;
    PieceShift[kBlackQueen, 6] := -11;
    PieceShift[kBlackQueen, 7] := 9;
    PieceShift[kBlackQueen, 8] := -9;

    PieceShift[kWhiteKing, 1] := 1;
    PieceShift[kWhiteKing, 2] := -1;
    PieceShift[kWhiteKing, 3] := 10;
    PieceShift[kWhiteKing, 4] := -10;
    PieceShift[kWhiteKing, 5] := 11;
    PieceShift[kWhiteKing, 6] := -11;
    PieceShift[kWhiteKing, 7] := 9;
    PieceShift[kWhiteKing, 8] := -9;

    PieceShift[kBlackKing, 1] := 1;
    PieceShift[kBlackKing, 2] := -1;
    PieceShift[kBlackKing, 3] := 10;
    PieceShift[kBlackKing, 4] := -10;
    PieceShift[kBlackKing, 5] := 11;
    PieceShift[kBlackKing, 6] := -11;
    PieceShift[kBlackKing, 7] := 9;
    PieceShift[kBlackKing, 8] := -9;

    PieceShift[kWhiteRook, 1] := 1;
    PieceShift[kWhiteRook, 2] := -1;
    PieceShift[kWhiteRook, 3] := 10;
    PieceShift[kWhiteRook, 4] := -10;

    PieceShift[kBlackRook, 1] := 1;
    PieceShift[kBlackRook, 2] := -1;
    PieceShift[kBlackRook, 3] := 10;
    PieceShift[kBlackRook, 4] := -10;

    PieceShift[kWhiteBishop, 1] := 9;
    PieceShift[kWhiteBishop, 2] := -9;
    PieceShift[kWhiteBishop, 3] := 11;
    PieceShift[kWhiteBishop, 4] := -11;

    PieceShift[kBlackBishop, 1] := 9;
    PieceShift[kBlackBishop, 2] := -9;
    PieceShift[kBlackBishop, 3] := 11;
  PieceShift[kBlackBishop, 4] := -11;
end;           



procedure TChessParser.SetNotation(aNotation: CandidateNotationType);
begin
    { The notation may be passed in with stuff appended on the end with }
    { commas as delimiters.  If so, truncate the notation. }

  if (pos(',', aNotation) > 0)
    then itsNotation := Copy(aNotation, 1, Pos(',', aNotation) - 1)
    else itsNotation := aNotation;

  MassageMove(itsNotation,
              fKingLetter,
              fQueenLetter,
              fRookLetter,
              fBishopLetter,
              fKnightLetter);

    // We assume that this new move may not be legal (OK to play).
  itsNotationIsOK := False;
end;



procedure TChessParser.SetBoard (aBoard: ChessBoardType);
begin
  itsPosition.SetBoard (aBoard);

    { We assume that the parser's move may not be legal (OK to play)}
    { in this new position. }
  itsNotationIsOK := False;

  FindKings;
end;



function TChessParser.GetBoard : PChessBoardType;
begin
  GetBoard := itsPosition.GetBoard;
end;



function TChessParser.GetEPDString : String;
begin
  GetEPDString := itsPosition.GetEPDString;
end;



procedure TChessParser.SetPieceLetters(theKingLetter,
                                       theQueenLetter,
                                       theRookLetter,
                                       theBishopLetter,
                                       theKnightLetter: Char);
begin
  fKingLetter := theKingLetter;
  fQueenLetter := theQueenLetter;
  fRookLetter := theRookLetter;
  fBishopLetter := theBishopLetter;
  fKnightLetter := theKnightLetter;
end;



procedure TChessParser.GetPieceLetters(var theKingLetter,
                                   theQueenLetter,
                                   theRookLetter,
                                   theBishopLetter,
                                   theKnightLetter: Char);
begin
  theKingLetter := fKingLetter;
  theQueenLetter := fQueenLetter;
  theRookLetter := fRookLetter;
  theBishopLetter := fBishopLetter;
  theKnightLetter := fKnightLetter;
end;



procedure TChessParser.SetIndicateChecks (Yes : Boolean);
begin
  fIndicateChecks := Yes;
end;



procedure TChessParser.SetIndicateCaptures (Yes : Boolean);
begin
  fIndicateCaptures := Yes;
end;



procedure TChessParser.PutPieceOnSquare (thePiece: PieceType;
                                    theSquare: SquareType);
begin
  itsPosition.PutPieceOnSquare (thePiece, theSquare);
end;



function TChessParser.WhiteOnMove: Boolean;
begin
  WhiteOnMove := itsPosition.WhiteOnMove;
end;



function TChessParser.PieceOnSquare(theSquare: SquareType): PieceType;
begin
  PieceOnSquare := itsPosition.PieceOnSquare(theSquare);
end;



{ This method creates the move notation for a proposed move. It }
{ returns a null string if the move would not be legal in this position. }

function TChessParser.NotationFor (aChessMove: ChessMoveType) : CandidateNotationType;
var
  DiagramToRank, DiagramToFile, DiagramFromRank, DiagramFromFile: 1..8;
  PieceLetter: string[1];
  thePiece: PieceType;

begin
    { Assume that the move is not legal. }
  NotationFor := '';    { This is the function result passed back to the calling object. }

    { Has the user simply dropped a piece in the same square s/he picked it up? }
  if (aChessMove.FromSquare = aChessMove.ToSquare)
    then Exit;

  if EdgeSquare(aChessMove.FromSquare) or
     EdgeSquare(aChessMove.ToSquare)
    then
      begin
        { TellTheUser (kDlgStrBlank,
                     kDlgStrNotationForThisMoveCannotBeMade); }
        Exit;
      end;

  thePiece := itsPosition.PieceOnSquare(aChessMove.FromSquare);

  if (thePiece = 0)
    then Exit;

  { sMessageDlg('thePiece = ' + Strang (thePiece),
             mtInformation,
             [mbOk], 0); }

    { If this move tries to move a piece which is not on move then exit. }
  if (thePiece >= kWhitePawn) and
     (thePiece <= kWhiteKing) and
     not itsPosition.WhiteOnMove
    then
      begin
        {
        sMessageDlg('Parser had no piece on FromSquare.',
                   mtInformation,
                   [mbOk], 0);
        }

        Exit;
      end;

  if (thePiece >= kBlackPawn) and
     (thePiece <= kBlackKing) and
     itsPosition.WhiteOnMove
    then Exit;


    { None of the optimizations have screened out a bogus move. }
    { Assume it's not legal and begin checking. }

  itsNotationIsOK := False;    { This is the Parser's internal flag for whether the notation is still legal. }
  itsNotation := '';           { This method will create move notations for aChessMove and test them for legality. }
  itsMoveIsCapturing := False; { an assumption }
  itsMoveIsChecking := False;  { an assumption }


  case thePiece of
    kBlackKing, kWhiteKing:
      PieceLetter := fKingLetter;
    kBlackQueen, kWhiteQueen:
      PieceLetter := fQueenLetter;
    kBlackRook, kWhiteRook:
      PieceLetter := fRookLetter;
    kBlackBishop, kWhiteBishop:
      PieceLetter := fBishopLetter;
    kBlackKnight, kWhiteKnight:
      PieceLetter := fKnightLetter;
    kBlackPawn, kWhitePawn:
      PieceLetter := '';
    else
      begin
        { TellTheUser (kDlgStrBlank { kDlgStrCorruptionWarning , }
                     { kDlgStrProgrammerMessageParserNotationForUnrecognizablePiece); }

        Assert(False);

        Exit;    { God knows what piece got passed in. }
      end;
  end;


  DiagramToRank := aChessMove.ToSquare div 10 + 1;                        { Rank goes 1 to 8 }
  DiagramToFile := aChessMove.ToSquare - ((DiagramToRank - 1)) * 10 + 1;          { File goes 1 to 8 }
  DiagramFromRank := aChessMove.FromSquare div 10 + 1;                            { Rank goes 1 to 8 }
  DiagramFromFile := aChessMove.FromSquare - ((DiagramFromRank - 1) * 10) + 1;  { File goes 1 to 8 }

  {sMessageDlg('DiagramToRank = ' + Strang (DiagramToRank),
             mtInformation,
             [mbOk], 0);

  sMessageDlg('DiagramToFile = ' + Strang (DiagramToFile),
             mtInformation,
             [mbOk], 0);

  sMessageDlg('DiagramFromRank = ' + Strang (DiagramFromRank),
             mtInformation,
             [mbOk], 0);

  sMessageDlg('DiagramFromFile = ' + Strang (DiagramFromFile),
             mtInformation,
             [mbOk], 0);

  sMessageDlg('PieceLetter = ' + PieceLetter,
             mtInformation,
             [mbOk], 0); }

    { Here we try the most explicit description of a piece move. An example is "Ng1f3". }
    { Pawn and King moves cannot be ambiguous so they are excluded from this piece of code. }
    { If the explicit move is not OK, then exit without trying an abbreviated notation for the }
    { move, because it might be OK/legal with another piece from another square. }

      { add source square's file and rank if it's not a pawn or a king }
  if not (thePiece in [kWhitePawn, kBlackPawn, kWhiteKing, kBlackKing])
    then
      begin
        itsNotation := Concat(PieceLetter,
                       Copy('abcdefgh', DiagramFromFile, 1),
                       Copy('12345678', DiagramFromRank, 1),
                       Copy('abcdefgh', DiagramToFile, 1),
                       Copy('12345678', DiagramToRank, 1));

        if not NotationIsLegal
          then Exit;    { If the most unambiguous move won't work, no move will work. }
      end;

    { At this point the most explicit move for the piece is }
    { legal OR the piece is either a pawn or a king. }
    { Now we try just the piece and the target square, e.g. "Nf3" }
  itsNotation := Concat(PieceLetter, Copy('abcdefgh', DiagramToFile, 1), Copy('12345678', DiagramToRank, 1));

   {     sMessageDlg ('Parser.NotationFor thinks... ' + itsNotation,
                    mtInformation,
                    [mbOK],
                    0); }

    { If the piece is a pawn reaching its eighth rank then tack on the promotion piece with an equals sign. }
  if (PieceLetter = '') and ((DiagramToRank = 1) or (DiagramToRank = 8))
    then
      case (aChessMove.PromotionPiece) of
        kWhiteQueen, kBlackQueen:
          itsNotation := Concat(itsNotation, '=', fQueenLetter);
        kWhiteRook, kBlackRook:
          itsNotation := Concat(itsNotation, '=', fRookLetter);
        kWhiteBishop, kBlackBishop:
          itsNotation := Concat(itsNotation, '=', fBishopLetter);
        kWhiteKnight, kBlackKnight:
          itsNotation := Concat(itsNotation, '=', fKnightLetter);
        else
          Exit;    { Did not pass in a legal promotion piece. }
      end;

    { Now we re-decide whether the move is OK with the shorter notation. }
    itsNotationIsOK := NotationIsLegal;

    if not itsNotationIsOK and not (itsPosition.PieceOnSquare(aChessMove.FromSquare) in [kWhiteKing, kBlackKing]) then
      begin
        if (itsPosition.PieceOnSquare(aChessMove.FromSquare) in [kWhitePawn, kBlackPawn]) then
          begin         { Try adding source square's file to a pawn capture (f7 becomes ef7 or gf7)}
            itsNotation := Concat(Copy('abcdefgh', DiagramFromFile, 1), itsNotation);

            if (itsNotation = 'hh6')
              then itsNotation := itsNotation + '!';

            itsNotationIsOK := NotationIsLegal;
          end
        else
          begin         { Try adding source square's file to a piece move. }
            itsNotation := Concat(PieceLetter,
                                  Copy('abcdefgh', DiagramFromFile, 1),
                                  Copy(itsNotation, 2, Length(itsNotation)));
            itsNotationIsOK := NotationIsLegal;
          end;
      end;

  if not itsNotationIsOK and
     not (itsPosition.PieceOnSquare(aChessMove.FromSquare) in [kWhitePawn, kBlackPawn, kWhiteKing, kBlackKing])
    then              { try adding source square's rank }
      begin
        itsNotation := Concat(PieceLetter, Copy('12345678', DiagramFromRank, 1), Copy(itsNotation, 3, Length(itsNotation)));
        itsNotationIsOK := NotationIsLegal;
      end;

  if not itsNotationIsOK and
     not (itsPosition.PieceOnSquare(aChessMove.FromSquare) in [kWhitePawn, kBlackPawn, kWhiteKing, kBlackKing])
    then              { try adding source square's file and rank }
      begin
        itsNotation := Concat(PieceLetter,
                              Copy('abcdefgh', DiagramFromFile, 1),
                              Copy(itsNotation, 2, Length(itsNotation)));
        itsNotationIsOK := NotationIsLegal;
      end;

    { If a King scooted right two squares it probably castled kingside. }
  if not itsNotationIsOK and
     (itsPosition.PieceOnSquare(aChessMove.FromSquare) in [kWhiteKing, kBlackKing]) and
     (aChessMove.ToSquare - aChessMove.FromSquare = 2)
    then
      begin
        itsNotation := 'O-O';
        itsNotationIsOK := NotationIsLegal;
      end;

    { If a King scooted left two squares it probably castled queenside. }
  if not itsNotationIsOK and
     (itsPosition.PieceOnSquare(aChessMove.FromSquare) in [kWhiteKing, kBlackKing]) and
     (aChessMove.ToSquare - aChessMove.FromSquare = -2)
    then
      begin
        itsNotation := 'O-O-O';
        itsNotationIsOK := NotationIsLegal;
      end;

    { Check to see that the pawn came from the right square. }
  if (PieceLetter = '') and
     (FromSquare <> aChessMove.FromSquare)
    then itsNotationIsOK := False;

  if itsNotationIsOK
    then
      begin
        if itsMoveIsCapturing and
           fIndicateCaptures
          then
            begin
                { All captures (except promotions!) put the 'x' 3 chars }
                { from the end of the notation. }
              if (aChessMove.PromotionPiece <> kEmptySquare)
                then itsNotation := Copy (itsNotation, 1, Length (itsNotation) - 4) +
                                    'x' +
                                    Copy (itsNotation, Length (itsNotation) - 3, 255)
                else itsNotation := Copy (itsNotation, 1, Length (itsNotation) - 2) +
                                    'x' +
                                    Copy (itsNotation, Length (itsNotation) - 1, 255)
            end;

        if itsMoveIsChecking and
           fIndicateChecks
          then itsNotation := itsNotation + '+';

        NotationFor := itsNotation;
      end
    else NotationFor := '';
end;



  { This method returns legal short algebraic notation for a long }
  { algebraic move by assembling the chess move and asking for }
  { the notation for that move. }
function TChessParser.ShortAlgebraicNotationFor (aNotation : CandidateNotationType) : CandidateNotationType;
var
  aChessMove : ChessMoveType;
  theToRank, theToFile, theFromRank, theFromFile : Integer;
  thePromotionPieceLetter: Char;

begin
  ShortAlgebraicNotationFor := '';

    { Long algebraic notation should be four characters. }
  if (Length (aNotation) < 4)
    then Exit;

  theFromFile := Pos (aNotation[1], 'abcdefgh');
  theFromRank := Pos (aNotation[2], '12345678');
  theToFile   := Pos (aNotation[3], 'abcdefgh');
  theToRank   := Pos (aNotation[4], '12345678');

  aChessMove.FromSquare := theFromFile - 1 + 10 * (theFromRank - 1);
  aChessMove.ToSquare := theToFile - 1 + 10 * (theToRank - 1);

  thePromotionPieceLetter := ' ';

  if (Length(aNotation) >= 5)
    then thePromotionPieceLetter := AnsiUpperCase(aNotation[5])[1]
    else thePromotionPieceLetter := ' ';

  if (Length(aNotation) >= 5) and
     (thePromotionPieceLetter in [fQueenLetter, fRookLetter, fBishopLetter, fKnightLetter])
    then
      begin
        if (itsPosition.WhiteOnMove)
          then
            begin
              if (thePromotionPieceLetter = fQueenLetter)
                then aChessMove.PromotionPiece := kWhiteQueen;  // FIXEDIN build 67
              if thePromotionPieceLetter = fRookLetter
                then aChessMove.PromotionPiece := kWhiteRook;
              if thePromotionPieceLetter = fKnightLetter
                then aChessMove.PromotionPiece := kWhiteKnight;
              if thePromotionPieceLetter = fBishopLetter
                then aChessMove.PromotionPiece := kWhiteBishop;
            end
          else
            begin
              if thePromotionPieceLetter = fQueenLetter
                then aChessMove.PromotionPiece := kBlackQueen;
              if thePromotionPieceLetter = fRookLetter
                then aChessMove.PromotionPiece := kBlackRook;
              if thePromotionPieceLetter = fKnightLetter
                then aChessMove.PromotionPiece := kBlackKnight;
              if thePromotionPieceLetter = fBishopLetter
                then aChessMove.PromotionPiece := kBlackBishop;
            end;
      end
    else aChessMove.PromotionPiece := kEmptySquare;

  aChessMove.Diacritic := 1;

  ShortAlgebraicNotationFor := NotationFor(aChessMove);
end;



{ MakeMoveNotation changes itsPosition so that it reflects the move notation. }
{ It clears itsNotation and sets itsNotationIsOK to False. }
{ This method assumes that the move passed in is legal. }

procedure TChessParser.MakeMoveNotation;
var
  PromotionPieceColumn: Byte;
  PieceLetter: string[1];

begin
    { Is itsNotation ready to be played? }

  Assert(itsNotationIsOK);
                        
  if not itsNotationIsOK
    then
      begin
        { TellTheUser (kDlgStrBlank } { kDlgStrCorruptionWarning , }
                     { kDlgStrProgrammerMessageParserMakeMoveNotationHasAnIllegalMove); }
        Exit;
      end;



    { Before exiting this procedure, the EnPassant should be set, the move }
    { should be flipped, the King location (if appropriate) should be }
    { updated and the Complex flag should be set. }

    { Assume that no diagram squares need to be refreshed after this move. }
  RefreshSquare1 := -1;
  RefreshSquare2 := -1;

  with itsPosition do
    begin
      if (Copy(itsNotation, 1, 5) = 'O-O-O')
        then
          begin
            if WhiteOnMove
              then
                begin
                PutPieceOnSquare(kEmptySquare, 0);
                PutPieceOnSquare(kWhiteKing, 2);
                WhiteKingLocation := 2;
                PutPieceOnSquare(kWhiteRook, 3);
                PutPieceOnSquare(kEmptySquare, 4);
                SetWhiteCanCastleKingside(False);
                SetWhiteCanCastleQueenside(False);
                FlipMove;
                RefreshSquare1 := 0;    { a1, where the rook came from }
                RefreshSquare2 := 3;    { d1, where the rook will go }
                SetEnPassantSquareTo(0);    { No pawn moved so en passant capture is not possible. }
                itsNotationIsOK := False;
                itsNotation := '';
                Exit;
              end
            else
              begin
                PutPieceOnSquare(kEmptySquare, 70);
                PutPieceOnSquare(kBlackKing, 72);
                BlackKingLocation := 72;
                PutPieceOnSquare(kBlackRook, 73);
                PutPieceOnSquare(kEmptySquare, 74);
                SetBlackCanCastleKingside(False);
                SetBlackCanCastleQueenside(False);
                FlipMove;
                RefreshSquare1 := 70;   { a8, where the rook came from }
                RefreshSquare2 := 73;   { d8, where the rook will go }
                SetEnPassantSquareTo(0);  { No pawn moved so en passant capture is not possible. }
                itsNotationIsOK := False;
                itsNotation := '';
                Exit;
              end;
          end;           { 'O-O-O' }

      if (Copy(itsNotation, 1, 3) = 'O-O') then
        begin
          if WhiteOnMove
            then
              begin
                PutPieceOnSquare(kEmptySquare, 4);
                PutPieceOnSquare(kWhiteRook, 5);
                PutPieceOnSquare(kWhiteKing, 6);
                WhiteKingLocation := 6;
                PutPieceOnSquare(kEmptySquare, 7);
                SetWhiteCanCastleKingside(False);
                SetWhiteCanCastleQueenside(False);
                FlipMove;
                RefreshSquare1 := 5;      { f1, where the rook will go }
                RefreshSquare2 := 7;      { h1, where the rook came from }
                SetEnPassantSquareTo(0);  { No pawn moved so en passant capture is not possible. }
                itsNotationIsOK := False;
                itsNotation := '';
                Exit;
              end
            else
              begin
                PutPieceOnSquare(kEmptySquare, 74);
                PutPieceOnSquare(kBlackRook, 75);
                PutPieceOnSquare(kBlackKing, 76);
                BlackKingLocation := 76;
                PutPieceOnSquare(kEmptySquare, 77);
                SetBlackCanCastleKingside(False);
                SetBlackCanCastleQueenside(False);
                FlipMove;
                RefreshSquare1 := 75;   { f8, where the rook will go }
                RefreshSquare2 := 77;   { h8, where the rook came from }
                SetEnPassantSquareTo(0);  { No pawn moved so en passant capture is not possible. }
                itsNotationIsOK := False;
                itsNotation := '';
                Exit;
              end;
          end;          { 'O-O' }

      case FromSquare of
         0 : SetWhiteCanCastleQueenside(False);
         7 : SetWhiteCanCastleKingside(False);
        70 : SetBlackCanCastleQueenside(False);
        77 : SetBlackCanCastleKingside(False);
         4 :
            begin
                { If ANY piece moved from e1 then obviously castling will never be possible. }
              SetWhiteCanCastleQueenside(False);
              SetWhiteCanCastleKingside(False);
            end;
        74 :
            begin
                { If ANY piece moved from e8 then obviously castling will never be possible. }
              SetBlackCanCastleQueenside(False);
              SetBlackCanCastleKingside(False);
            end;
          else
        end;

      case ToSquare of
         0 : SetWhiteCanCastleQueenside(False);
         7 : SetWhiteCanCastleKingside(False);
        70 : SetBlackCanCastleQueenside(False);
        77 : SetBlackCanCastleKingside(False);
          else
        end;

      { The en passant square is the square of the pawn that can be }
      { captured en passant. }
      { If a pawn is being moved one square beyond the en passant-able square then it is capturing en passant. }
      { Remove the captured pawn from the board. }
      if (PieceOnSquare(FromSquare) = kWhitePawn) and (ToSquare = EnPassantSquare + 10) then
        begin
          PutPieceOnSquare(kEmptySquare, EnPassantSquare);
          RefreshSquare1 := EnPassantSquare;
        end;

      if (PieceOnSquare(FromSquare) = kBlackPawn) and
         (ToSquare = EnPassantSquare - 10) then
        begin
          PutPieceOnSquare(kEmptySquare, EnPassantSquare);
          RefreshSquare1 := EnPassantSquare;
        end;

      SetEnPassantSquareTo(0);    { assume no En Passant possibility for next position }

      if (PieceOnSquare(FromSquare) = kWhitePawn) then
        begin
          { If this pawn came from the second rank into the fourth rank... }
          if (ToSquare > 29) and (FromSquare < 18) then
            begin
          { ...and passed an adjacent enemy pawn... }
              if (not EdgeSquare(ToSquare + 1) and
                 (PieceOnSquare(ToSquare + 1) = kBlackPawn)) or
                 (not EdgeSquare(ToSquare - 1) and
                  (PieceOnSquare(ToSquare - 1) = kBlackPawn))
                then SetEnPassantSquareTo(ToSquare);  { It could be captured EnPassant }
            end;
        end;

      if (PieceOnSquare(FromSquare) = kBlackPawn) then
        begin
            { If this pawn came from the second rank into the fourth rank... }
          if (ToSquare < 48) and (FromSquare > 59) then
            begin
                { ...and passed an adjacent enemy pawn... }
              if (not EdgeSquare(ToSquare + 1) and
                 (PieceOnSquare(ToSquare + 1) = kWhitePawn)) or
                 (not EdgeSquare(ToSquare - 1) and
                 (PieceOnSquare(ToSquare - 1) = kWhitePawn))
                then SetEnPassantSquareTo(ToSquare);  { It could be captured EnPassant }
            end;
        end;

        { Handle promotion }
      if (PieceOnSquare(FromSquare) = kWhitePawn) and
         (ToSquare > 69) then                 { white pawn reaching rank 8 }
        begin
          PromotionPieceColumn := Pos(fQueenLetter, itsNotation);

          if (PromotionPieceColumn = 0)
            then PromotionPieceColumn := Pos(fRookLetter, itsNotation);

          if (PromotionPieceColumn = 0)
            then PromotionPieceColumn := Pos(fBishopLetter, itsNotation);

          if (PromotionPieceColumn = 0)
            then PromotionPieceColumn := Pos(fKnightLetter, itsNotation);

          PieceLetter := itsNotation[PromotionPieceColumn];

          if (PieceLetter = fQueenLetter)
            then PutPieceOnSquare(kWhiteQueen, FromSquare);

          if (PieceLetter = fRookLetter)
            then PutPieceOnSquare(kWhiteRook, FromSquare);

          if (PieceLetter = fBishopLetter)
            then PutPieceOnSquare(kWhiteBishop, FromSquare);

          if (PieceLetter = fKnightLetter)
            then PutPieceOnSquare(kWhiteKnight, FromSquare);
        end;

      if (PieceOnSquare(FromSquare) = kBlackPawn) and (ToSquare < 8) then    { black pawn reaching its 8th rank }
        begin
          PromotionPieceColumn := Pos(fQueenLetter, itsNotation);

          if (PromotionPieceColumn = 0)
            then PromotionPieceColumn := Pos(fRookLetter, itsNotation);

          if (PromotionPieceColumn = 0)
            then PromotionPieceColumn := Pos(fBishopLetter, itsNotation);

          if (PromotionPieceColumn = 0)
            then PromotionPieceColumn := Pos(fKnightLetter, itsNotation);

          PieceLetter := itsNotation[PromotionPieceColumn];
          if (PieceLetter = fQueenLetter)
            then PutPieceOnSquare(kBlackQueen, FromSquare);

          if (PieceLetter = fRookLetter)
            then PutPieceOnSquare(kBlackRook, FromSquare);

          if (PieceLetter = fBishopLetter)
            then PutPieceOnSquare(kBlackBishop, FromSquare);

          if (PieceLetter = fKnightLetter)
            then PutPieceOnSquare(kBlackKnight, FromSquare);
        end;

      PutPieceOnSquare(PieceOnSquare(FromSquare), ToSquare);
      PutPieceOnSquare(kEmptySquare, FromSquare);        (* From square is vacant *)

      if (PieceOnSquare(ToSquare) = kWhiteKing)
        then WhiteKingLocation := ToSquare;

      if (PieceOnSquare(ToSquare) = kBlackKing)
        then BlackKingLocation := ToSquare;
    end;

  FlipMove;
  itsNotationIsOK := False;
  itsNotation := '';
end;                        { MakeMoveNotation }



{ This method creates a ChessMove for a notation. }

function TChessParser.GetChessMove: PChessMoveType;
var
  OK: Boolean;

begin
    { This method should not be called unless the notation and matching chess }
    { move are OK. }
  OK := itsNotationIsOK;

    { GetChessMove was called when the notation was not OK! }
  Assert(OK);

  OK := itsChessMove.FromSquare <> itsChessMove.ToSquare;

  { if not OK
    then
      begin
        TellTheUser (kDlgStrBlank,
                     kDlgStrProgrammerMessageParserGetChessMoveWasCalledItsNotationIsOKIsFalse);
      end; }

    { GetChessMove was called when the move was not OK! }
  Assert(OK);


    { If everything's OK then return the chess move. }
  GetChessMove := @itsChessMove;
end;



{ This method tests itsNotation for legality in itsPosition. }

function TChessParser.NotationIsLegal: Boolean;
begin
{    Castling := False;}
{    Promoting := False;}
{    TookEnPassant := False;}
{    Message := 'Illegal or ambiguous move';}

  itsNotationIsOK := False;     { Assume it is not legal at this point. }

  itsMoveIsCapturing := False;   { an assumption }
  itsMoveIsChecking := False;    { an assumption }

  itsChessMove.FromSquare := 0;
  itsChessMove.ToSquare := 0;
  itsChessMove.PromotionPiece := kEmptySquare;
  itsChessMove.Diacritic := 1;

    { Assume that there is no promotion piece.  It will be filled }
    { in if there is one. }
  PromotionPiece := kEmptySquare;

      { Test for notation that is too short to parse. }
      { NotationIsLegal was called with bad notation. }
  {$IFDEF DEBUG}
  // if (Length(itsNotation) < 2)
  //   then ShowMessage('Short notation.');

  // Assert((Length(itsNotation) >= 2));
  {$ENDIF}


    if (Length(ItsNotation) < 2)
      then
        begin
          NotationIsLegal := False;
          Exit;
        end;

    { Either Pawn or MoveThe or Castles will decide whether to set }
    { itsNotationIsOK to True . }

    if itsPosition.WhiteOnMove then
      begin
        if (Pos(itsNotation[1], 'abcdefgh') > 0) then
          MoveThePawn;
        if (itsNotation[1] = AnsiChar(fKingLetter)) then
          MoveThe(kWhiteKing);
        if (itsNotation[1] = AnsiChar(fQueenLetter)) then
          MoveThe(kWhiteQueen);
        if (itsNotation[1] = AnsiChar(fRookLetter)) then
          MoveThe(kWhiteRook);
        if (itsNotation[1] = AnsiChar(fBishopLetter)) then
          MoveThe(kWhiteBishop);
        if (itsNotation[1] = AnsiChar(fKnightLetter)) then
          MoveThe(kWhiteKnight);
        if (Pos(itsNotation[1], 'O0o') > 0) then
          Castles;
      end
    else
      begin
        if (Pos(itsNotation[1], 'abcdefgh') > 0) then
          MoveThePawn;
        if (itsNotation[1] = AnsiChar(fKingLetter)) then
          MoveThe(kBlackKing);
        if (itsNotation[1] = AnsiChar(fQueenLetter)) then
          MoveThe(kBlackQueen);
        if (itsNotation[1] = AnsiChar(fRookLetter)) then
          MoveThe(kBlackRook);
        if (itsNotation[1] = AnsiChar(fBishopLetter)) then
          MoveThe(kBlackBishop);
        if (itsNotation[1] = AnsiChar(fKnightLetter)) then
          MoveThe(kBlackKnight);
        if (Pos(itsNotation[1], 'O0o') > 0) then
          Castles;
      end;

  NotationIsLegal := itsNotationIsOK;

    { If the Notation is OK, then set up the corresponding chessmove. }
  if (itsNotationIsOK) then
    begin
      itsChessMove.FromSquare := FromSquare;
      itsChessMove.ToSquare := ToSquare;
      itsChessMove.PromotionPiece := PromotionPiece;
      itsChessMove.Diacritic := 1;
    end;
end;



procedure TChessParser.FlipMove;
begin
  itsPosition.SetWhiteOnMove (not itsPosition.WhiteOnMove);
end;



procedure TChessParser.FindKings;
begin
    with itsPosition do
      begin
        WhiteKingLocation := 0;
        while (PieceOnSquare(WhiteKingLocation) <> kWhiteKing) and
              (WhiteKingLocation < 77) do
          begin
            WhiteKingLocation := WhiteKingLocation + 1;
            if EdgeSquare(WhiteKingLocation)
              then WhiteKingLocation := WhiteKingLocation + 2;
          end;

          { White king could not be found. }
        { if (PieceOnSquare (WhiteKingLocation) <> kWhiteKing)
          then
            begin
              TellTheUser (kDlgStrBlank,
                           kDlgStrProgrammerMessageAWhiteKingCouldNotBeFound);
            end; }

        if not (PieceOnSquare(WhiteKingLocation) = kWhiteKing)
          then
            begin
              if not (PieceOnSquare(WhiteKingLocation) = kWhiteKing)
                then Raise EDatabaseProblem.Create('TChessParser.FindKings() has a position with no white king.');
            end;

        BlackKingLocation := 77;
        while (PieceOnSquare(BlackKingLocation) <> kBlackKing) and
              (BlackKingLocation > 0) do
          begin
            BlackKingLocation := BlackKingLocation - 1;
            if EdgeSquare(BlackKingLocation)
              then BlackKingLocation := BlackKingLocation - 2;
          end;

          { Black king could not be found. }
        { if (PieceOnSquare(BlackKingLocation) <> kBlackKing)
          then
            begin
              TellTheUser (kDlgStrBlank,
                           kDlgStrProgrammerMessageABlackKingCouldNotBeFound);
            end; }

        if not (PieceOnSquare(BlackKingLocation) = kBlackKing)
          then Raise EDatabaseProblem.Create('TChessParser.FindKings() has a position with no black king.');
      end;
end;



{ This method looks to see if a king could be captured, which is illegal. }
function TChessParser.KingCanBeTaken: Boolean;
var
  Pawn, Knight, Bishop, Rook, Queen, King: PieceType;
  KingLocation: SquareType;
  L: Byte;
  theSquare: SquareType;
  PawnAttack1, PawnAttack2: Integer;

begin
    KingCanBeTaken := False;
    FindKings;

    if itsPosition.WhiteOnMove then
      begin
        KingLocation := BlackKingLocation;
        PawnAttack1 := -11;
        PawnAttack2 := -9;
        Pawn := kWhitePawn;
        Knight := kWhiteKnight;
        Bishop := kWhiteBishop;
        Rook := kWhiteRook;
        Queen := kWhiteQueen;
        King := kWhiteKing;
      end
    else
      begin
        KingLocation := WhiteKingLocation;
        PawnAttack1 := 11;
        PawnAttack2 := 9;
        Pawn := kBlackPawn;
        Knight := kBlackKnight;
        Bishop := kBlackBishop;
        Rook := kBlackRook;
        Queen := kBlackQueen;
        King := kBlackKing;
      end;

    { In the use of PieceShift [] below, it is NOT an error to use White pieces exclusively. }
    { White pieces have the lower-value constants used by PieceShift []. }
    for L := 1 to 4 do    { Check ranks and files (the way a Rook moves) until you hit a piece or the edge of the board. }
      begin
        theSquare := KingLocation;
        repeat
          theSquare := theSquare + PieceShift[kWhiteRook, L];
        until EdgeSquare(theSquare) or
              itsPosition.SomethingOn(theSquare);

        if not EdgeSquare(theSquare) then
          if (itsPosition.PieceOnSquare(theSquare) in [Rook, Queen]) then
            begin
              KingCanBeTaken := True;
              Exit;
            end;
      end;

    for L := 1 to 4 do    { Check diagonals (the way a Bishop moves) until you hit a piece or the edge of the board. }
      begin
        theSquare := KingLocation;

        repeat
          theSquare := theSquare + PieceShift[kWhiteBishop, L];
        until EdgeSquare(theSquare) or
              itsPosition.SomethingOn(theSquare);

        if not EdgeSquare(theSquare) then
          if (itsPosition.PieceOnSquare(theSquare) in [Bishop, Queen]) then
            begin
              KingCanBeTaken := True;
              Exit;
            end;
      end;

    for L := 1 to 8 do    { Check Knight hops (the way a Knight moves) unless the hop is off the edge of the board. }
      begin
        theSquare := KingLocation + PieceShift[kWhiteKnight, L];

        if not EdgeSquare(theSquare) then
          if (itsPosition.PieceOnSquare(theSquare) in [Knight]) then
            begin
              KingCanBeTaken := True;
              Exit;
            end;
      end;

    for L := 1 to 8 do         { check king opposition }
      begin
        theSquare := KingLocation + PieceShift[kWhiteKing, L];

        if not EdgeSquare(theSquare) then
          if (itsPosition.PieceOnSquare(theSquare) in [King]) then
            begin
              KingCanBeTaken := True;
              Exit;
            end;
      end;

    theSquare := KingLocation + PawnAttack1;     { check pawn checks }

    if not EdgeSquare(theSquare) then
      if (itsPosition.PieceOnSquare(theSquare) in [Pawn]) then
        begin
          KingCanBeTaken := True;
          Exit;
        end;

    theSquare := KingLocation + PawnAttack2;

    if not EdgeSquare(theSquare) then
      if (itsPosition.PieceOnSquare(theSquare) in [Pawn]) then
        begin
          KingCanBeTaken := True;
          Exit;
        end;
  end;



function TChessParser.KingWouldBeLeftInCheck: Boolean;
var
  tempBoard: ChessBoardType;
  tempNotation: CandidateNotationType;
  tempNotationIsOK: Boolean;

begin
    { Save the position because we're about to make a move. }
  tempBoard := itsPosition.GetBoard^;

    { Save the notation because making the move will clear it. }
  tempNotation := itsNotation;
  tempNotationIsOK := itsNotationIsOK;

    { We must assume that the move is legal so far. }
  itsNotationIsOK := True;
  MakeMoveNotation;
  KingWouldBeLeftInCheck := KingCanBeTaken;

    { Let's see if the other king is in check after this move by }
    { reversing the side to move, seeing if the king can be taken and }
    { then switching back the side to move. }
  itsPosition.SetWhiteOnMove (not itsPosition.WhiteOnMove);
  itsMoveIsChecking := KingCanBeTaken;
  itsPosition.SetWhiteOnMove (not itsPosition.WhiteOnMove);

    { Restore itsPosition and itsNotation and the state of the OK flag. }
  itsNotationIsOK := tempNotationIsOK;
  itsNotation := tempNotation;


  itsPosition.SetBoard (tempBoard);
end;



function TChessParser.KingIsInCheck: Boolean;     
begin
    { Let's see if the king is in check by }
    { reversing the side to move, seeing if the king can be taken and }
    { then switching back the side to move. }
  itsPosition.SetWhiteOnMove (not itsPosition.WhiteOnMove);
  KingIsInCheck := KingCanBeTaken;
  itsPosition.SetWhiteOnMove (not itsPosition.WhiteOnMove);
end;



procedure TChessParser.MoveThe (thePiece: PieceType);
var
  GoodSquares, K: Integer;
  OkSquares: array [1..8] of Integer;
  ParsedOK: Boolean;

    function ExplicitMoveOK: Boolean;
    var
      K: Integer;

    begin
      ExplicitMoveOK := True;

      if (ExplicitRank = 0) and (ExplicitFile = 0) then
        Exit;

      if (ExplicitFile > 0) then
        begin
          K := 0;
          repeat
            K := K + 1;
          until (K = 8) or
                (FileCheck[ExplicitFile, K] = FromSquare);

          if (FileCheck[ExplicitFile, K] <> FromSquare) then
            begin
              ExplicitMoveOK := False;
              Exit;
            end;
        end;

      if (ExplicitRank > 0) then
        begin
          for K := 1 to 8 do
            if (RankCheck[ExplicitRank, K] = FromSquare) then
              Exit;

          ExplicitMoveOK := False;
        end;
    end;


  { This routine finds ToRank, ToFile, ExplicitRank, ExplicitFile, ToSquare }
    function ParseSquareInfo: Boolean;
    begin
      { Assume that the square info has been parsed. }
      ParseSquareInfo := True;

      if (Length(itsNotation) >= 5) then
        if (Pos(itsNotation[5], '12345678') > 0) then
          begin
            ToRank := Pos(itsNotation[5], '12345678');
            ToFile := Pos(itsNotation[4], 'abcdefgh');
            ExplicitRank := Pos(itsNotation[3], '12345678');
            ExplicitFile := Pos(itsNotation[2], 'abcdefgh');

            if (ToRank = 0) or (ToFile = 0)
              then ParseSquareInfo := False
              else ToSquare := ToFile - 1 + 10 * (ToRank - 1);

            Exit;
          end;

      if (Length(itsNotation) >= 4) then
        if (Pos(itsNotation[4], '12345678') > 0) then
          begin
            ToRank := Pos(itsNotation[4], '12345678');
            ToFile := Pos(itsNotation[3], 'abcdefgh');
            ExplicitRank := Pos(itsNotation[2], '12345678');
            ExplicitFile := Pos(itsNotation[2], 'abcdefgh');

            if (ToRank = 0) or
               (ToFile = 0)
              then ParseSquareInfo := False
              else ToSquare := ToFile - 1 + 10 * (ToRank - 1);

            Exit;
          end;

      ToRank := Pos(itsNotation[3], '12345678');
      ToFile := Pos(itsNotation[2], 'abcdefgh');
      ExplicitRank := 0;
      ExplicitFile := 0;

      if (ToRank = 0) or
         (ToFile = 0)
        then ParseSquareInfo := False
        else ToSquare := ToFile - 1 + 10 * (ToRank - 1);
    end;


begin
  itsNotationIsOK := False;   { Assume the move is not legal. }

  ParsedOK := ParseSquareInfo;
  if not ParsedOK
    then EXIT;

{    Message := 'That square is occupied'; }

    { Is the user trying to capture his own piece? }
    if itsPosition.whiteOnMove then
      begin
        if (itsPosition.PieceOnSquare(ToSquare) >= kWhitePawn) and
           (itsPosition.PieceOnSquare(ToSquare) <= kWhiteKing)
          then Exit
      end
    else
      begin
        if (itsPosition.PieceOnSquare(ToSquare) >= kBlackPawn) and
           (itsPosition.PieceOnSquare(ToSquare) <= kBlackKing)
          then Exit;
      end;

    GoodSquares := 0;

    { Is there something on the ToSquare to capture? }
{    Capturing := (itsPosition.PieceOnSquare(ToSquare) <> EmptySquare);}

    for K := 1 to TotalDirectionsOf[thePiece] do
      begin
        FromSquare := ToSquare;
        repeat
          FromSquare := FromSquare + PieceShift[thePiece, K];
        until EdgeSquare(FromSquare) or
              (thePiece in [kWhiteKnight, kBlackKnight, kWhiteKing, kBlackKing]) or
              itsPosition.SomethingOn(FromSquare);  { one-jump pieces }

        if not EdgeSquare(FromSquare) then
          begin
            if (itsPosition.PieceOnSquare(FromSquare) = thePiece) then
              begin
              { At this point the move would be legal except if it left the king in check. }
              { So, we copy the current position and execute the move as if it were legal. }
              { If the King is not left in check then the move was legal. (Put the position back.) }
                if not KingWouldBeLeftInCheck then
                  begin
                { If the extra information in the move (the parts that spell out explicit "from" files }
                { and "from" ranks) is not correct, then don't count it as a legal move. }
                    if ExplicitMoveOK then
                      begin
                        GoodSquares := GoodSquares + 1;
                        OKSquares[GoodSquares] := FromSquare;
                      end;
                  end;
              end;
          end;
      end;

{    Message := 'Move is ambiguous'; }

    if (GoodSquares > 1) then
      Exit;

{    Message := 'No move to that square'; }

    if (GoodSquares = 0) then
      Exit;

  FromSquare := OKSquares[1];
  itsNotationIsOK := True;

  itsMoveIsCapturing := (itsPosition.PieceOnSquare (ToSquare) <> kEmptySquare);
end;



procedure TChessParser.CheckCastling (Kingside: Boolean);
var
  EFile, OneFileAway, OriginalWKL, OriginalBKL: SquareType;
  HoldPBoard: ChessBoardType;

begin
  OriginalWKL := WhiteKingLocation;
  OriginalBKL := BlackKingLocation;

  if itsPosition.WhiteOnMove
    then
      begin
        FromSquare := 4;
        EFile := 4
      end
    else
      begin
        FromSquare := 74;
        EFile := 74;
      end;

    if Kingside then
      begin
        OneFileAway := EFile + 1;
        ToSquare := EFile + 2;
      end
    else
      begin
        OneFileAway := EFile - 1;
        ToSquare := EFile - 2;
      end;

    if Kingside then
      begin
        if (itsPosition.WhiteOnMove and not itsPosition.WhiteCanCastleKingside) or
           (not itsPosition.WhiteOnMove and not itsPosition.BlackCanCastleKingside) or
           (itsPosition.PieceOnSquare(OneFileAway) > kEmptySquare) or
           (itsPosition.PieceOnSquare(ToSquare) > kEmptySquare)
            { Castling is blocked by a piece of either color, one or two squares away. }
          then Exit;
      end
    else
      begin
        { If White is moving but can't castle or Black is moving but can't castle then Exit. }
        if (itsPosition.WhiteOnMove and not itsPosition.WhiteCanCastleQueenside) or
           (not itsPosition.WhiteOnMove and not itsPosition.BlackCanCastleQueenside)
          then Exit;

        { If castling is blocked by any piece then Exit. }
        if (itsPosition.PieceOnSquare(OneFileAway) > kEmptySquare) or
           (itsPosition.PieceOnSquare(ToSquare) > kEmptySquare)
          then Exit;
      end;

    HoldPBoard := itsPosition.GetBoard^;
    FlipMove;

    if KingCanBeTaken then
      begin
        itsPosition.SetBoard (HoldPBoard);
        Exit;
      end;

    BlackKingLocation := OneFileAway;
    WhiteKingLocation := OneFileAway;     { Pretend King scoots one file }

    if KingCanBeTaken then
      begin
        BlackKingLocation := OriginalBKL;
        WhiteKingLocation := OriginalWKL;

        itsPosition.SetBoard (HoldPBoard);
        Exit;
      end;

    BlackKingLocation := ToSquare;
    WhiteKingLocation := ToSquare;   { Pretend King scoots another file }

    if KingCanBeTaken then
      begin
        BlackKingLocation := OriginalBKL;
        WhiteKingLocation := OriginalWKL;

        itsPosition.SetBoard (HoldPBoard);
        Exit;
      end;

    BlackKingLocation := OriginalBKL;
    WhiteKingLocation := OriginalWKL;

    itsPosition.SetBoard (HoldPBoard);

    itsNotationIsOK := not KingWouldBeLeftInCheck;
  end;



procedure TChessParser.WhitePawnMove;
begin
  with itsPosition do
    begin
      if (ToRank < 3)
        then Exit;  { first and second ranks }

      if (PieceOnSquare(ToSquare - 10) = kWhitePawn)
        then FromSquare := ToSquare - 10
        else
          begin
            if (ToRank = 4) and (PieceOnSquare(ToSquare - 20) = kWhitePawn) and (PieceOnSquare(ToSquare - 10) = kEmptySquare)
              then FromSquare := ToSquare - 20
              else Exit;
          end;
    end;

  itsNotationIsOK := True;
end;



procedure TChessParser.BlackPawnMove;
begin
    with itsPosition do
      begin
        if (ToRank > 6)
          then Exit;  { first and second ranks }

        if (PieceOnSquare(ToSquare + 10) = kBlackPawn)
          then FromSquare := ToSquare + 10
          else
            begin
              if (ToRank = 5) and (PieceOnSquare(ToSquare + 20) = kBlackPawn) and (PieceOnSquare(ToSquare + 10) = 0)
                then FromSquare := ToSquare + 20
                else Exit;  { first and second ranks }
            end;
      end;

  itsNotationIsOK := True;
end;



  procedure TChessParser.PawnMove;
  begin
    ToRank := Pos(itsNotation[2], '12345678');
    FromFile := Pos(itsNotation[1], 'abcdefgh');
    ToFile := FromFile;
    ToSquare := ToFile - 1 + 10 * (ToRank - 1);
    if (itsPosition.PieceOnSquare(ToSquare) <> kEmptySquare) then
      Exit;  { square occupied }

    if itsPosition.WhiteOnMove then
      WhitePawnMove
    else
      BlackPawnMove;
  end;



  procedure TChessParser.WhitePawnCapture;
  begin
    if (FromFile < ToFile) then
      FromSquare := ToSquare - 11
    else
      FromSquare := ToSquare - 9;

    if (ToSquare - 10 = itsPosition.EnPassantSquare) and (itsPosition.PieceOnSquare(FromSquare) = kWhitePawn) then
      begin
{    TookEnPassant := True;      }
        itsNotationIsOK := True;
        Exit;
      end;

    { If capturing an empty square, your own piece or there isn't even a pawn on the FromSquare then it's illegal. }
    if (itsPosition.PieceOnSquare(ToSquare) < kBlackPawn) or
       (itsPosition.PieceOnSquare(FromSquare) <> kWhitePawn)
      then Exit;

    itsNotationIsOK := True;
  end;



  procedure TChessParser.BlackPawnCapture;
  begin
    if (FromFile < ToFile) then
      FromSquare := ToSquare + 9
    else
      FromSquare := ToSquare + 11;

    if EdgeSquare(FromSquare)  
      then Exit;

    if (ToSquare + 10 = itsPosition.EnPassantSquare) and (itsPosition.PieceOnSquare(FromSquare) = kBlackPawn) then
      begin
{    TookEnPassant := True; }
        itsNotationIsOK := True;
        Exit;
      end;

    { If capturing an empty square, your own piece or there isn't even a pawn on the FromSquare then it's illegal. }
    if (itsPosition.PieceOnSquare(ToSquare) = kEmptySquare) or
       (itsPosition.PieceOnSquare(ToSquare) >= kBlackPawn) or
       (itsPosition.PieceOnSquare(FromSquare) <> kBlackPawn)
      then Exit;

    itsNotationIsOK := True;
  end;



  procedure TChessParser.PawnCapture;
    var
      GuessRank: Byte;

  begin
{    Capturing := True;}
    FromFile := Pos(itsNotation[1], 'abcdefgh');
    ToFile := Pos(itsNotation[2], 'abcdefgh');

    if (Length(itsNotation) > 2) then
      ToRank := Pos(itsNotation[3], '12345678')
    else
      ToRank := 0;

    ToSquare := ToFile - 1 + 10 * (ToRank - 1);

    if (ToRank = 0) then  { No rank specified, like 'ef' rather than 'ef6' }
      begin

        GuessRank := 0;
        repeat
          GuessRank := GuessRank + 1;
          ToRank := GuessRank;          { guess each rank from 1 to 8 }
          ToSquare := ToFile - 1 + 10 * (ToRank - 1);

          if itsPosition.WhiteOnMove then
            WhitePawnCapture
          else
            BlackPawnCapture;
        until (GuessRank = 8) or
              itsNotationIsOK;
      end
    else      { ToRank IS specified }
      begin
        if itsPosition.WhiteOnMove then
          WhitePawnCapture
        else
          BlackPawnCapture;
      end;
  end;



  procedure TChessParser.PawnPromote;
    var
      M: Integer;
      PromotionPieceLetter: AnsiChar;

  begin
    PromotionPieceLetter := AnsiChar(fQueenLetter);  // an assumption

    M := Pos('=', itsNotation);

    { If there is an equal sign and the character after it is a good promotion piece... }
    if (M > 0) then
      begin
        PromotionPieceLetter := itsNotation[M + 1];
        if not (PromotionPieceLetter in [fQueenLetter, fRookLetter, fBishopLetter, fKnightLetter]) then
          begin
            itsNotationIsOK := False;
          { Message := 'No promotion piece after equal sign.'; }
            Exit;
          end;
      end;

    { If there is no equal sign but the last character is a good promotion piece... }
    if (M = 0) then
      begin
        PromotionPieceLetter := itsNotation[Length(ItsNotation)];
        if not (PromotionPieceLetter in [fQueenLetter, fRookLetter, fBishopLetter, fKnightLetter]) then
          begin
            itsNotationIsOK := False;
          { Message := 'No promotion piece'; }
            Exit;
          end;
      end;

{ Promoting := True; }

    if (itsPosition.WhiteOnMove) then
      begin
        if PromotionPieceLetter = AnsiChar(fQueenLetter) then
          PromotionPiece := kWhiteQueen;
        if PromotionPieceLetter = AnsiChar(fRookLetter) then
          PromotionPiece := kWhiteRook;
        if PromotionPieceLetter = AnsiChar(fKnightLetter) then
          PromotionPiece := kWhiteKnight;
        if PromotionPieceLetter = AnsiChar(fBishopLetter) then
          PromotionPiece := kWhiteBishop;
      end
    else
      begin
        if PromotionPieceLetter = AnsiChar(fQueenLetter) then
          PromotionPiece := kBlackQueen;
        if PromotionPieceLetter = AnsiChar(fRookLetter) then
          PromotionPiece := kBlackRook;
        if PromotionPieceLetter = AnsiChar(fKnightLetter) then
          PromotionPiece := kBlackKnight;
        if PromotionPieceLetter = AnsiChar(fBishopLetter) then
          PromotionPiece := kBlackBishop;
      end;
  end;



procedure TChessParser.MoveThePawn;
begin
  if (Pos(itsNotation[2], 'abcdefgh') > 0)
    then
      begin
        PawnCapture;
        itsMoveIsCapturing := True;
      end;

  if (Pos(itsNotation[2], '12345678') > 0)
    then PawnMove;

  if not itsNotationIsOK
    then Exit;

    { At this point we think that itsNotationIsOK unless the king would be left in check. }
  if KingWouldBeLeftInCheck
    then
      begin
        itsNotationIsOK := False;
        Exit;
      end
    else
      itsNotationIsOK := True;

    { itsNotation MUST have a promotion piece letter as its last character. }
    if ((ToRank = 8) or (ToRank = 1)) and
       not (itsNotation[Length(itsNotation)] in [fQueenLetter, fRookLetter, fBishopLetter, fKnightLetter])
      then
        begin
          itsNotationIsOK := False;
             {    Message := 'No promotion piece at the end of the notation.'; }
          Exit;
        end;

    if ((ToRank = 8) or (ToRank = 1)) and
       itsNotationIsOK
      then PawnPromote;
  end;



procedure TChessParser.Castles;
begin
  { Castling := True; }

  if (Copy(itsNotation, 1, 5) = 'O-O-O')
    then
      begin
        CheckCastling(False);   { NOT Kingside }
        Exit;
      end;

  if (Copy(itsNotation, 1, 3) = 'O-O')
    then
      begin
        CheckCastling(True);   { Kingside }
        Exit;
      end;

  //  Message := 'Castles is O-O or O-O-O';
end;



procedure TChessParser.GetMoveList(var theNumberOfMoves: Integer;
                                   var theMoveArray: TChessNotationArray);
var
  theRank, theFile: Integer;
  theSquare: SquareType;
  thePiece: PieceType;
  theNotation: CandidateNotationType;
  theChessMove: ChessMoveType;
  K: Integer;

begin
  theNumberOfMoves := 0;

    { Go to each square and see if the piece on that square can move. }
  for theFile := 0 to 7 do
    for theRank := 0 to 7 do
      begin
        theSquare := 10 * theRank + theFile;

        theChessMove.FromSquare := theSquare;

        thePiece := itsPosition.PieceOnSquare(theSquare);

        theChessMove.PromotionPiece := kEmptySquare;

          { Generate all white pawn moves. }
        if itsPosition.WhiteOnMove and
           (thePiece = kWhitePawn)
          then
            begin
              if (theChessMove.FromSquare < 60)
                then
                  begin
                      { Capture to the left. }
                    theChessMove.ToSquare := theChessMove.FromSquare + 9;
                    theNotation := NotationFor(theChessMove);

                    if (theNotation > '')
                      then
                        begin
                          Inc(theNumberOfMoves);
                          theMoveArray[theNumberOfMoves] := theNotation;
                        end;

                      { Move one square forward. }
                    theChessMove.ToSquare := theChessMove.FromSquare + 10;
                    theNotation := NotationFor(theChessMove);

                    if (theNotation > '')
                      then
                        begin
                          Inc(theNumberOfMoves);
                          theMoveArray[theNumberOfMoves] := theNotation;
                        end;

                      { Capture to the right. }
                    theChessMove.ToSquare := theChessMove.FromSquare + 11;
                    theNotation := NotationFor(theChessMove);

                    if (theNotation > '')
                      then
                        begin
                          Inc(theNumberOfMoves);
                          theMoveArray[theNumberOfMoves] := theNotation;
                        end;

                      { Move two squares forward. }
                    theChessMove.ToSquare := theChessMove.FromSquare + 20;
                    theNotation := NotationFor(theChessMove);

                    if (theNotation > '')
                      then
                        begin
                          Inc(theNumberOfMoves);
                          theMoveArray[theNumberOfMoves] := theNotation;
                        end;
                  end

                  { The pawn is moving to the 8th rank and promotes to 4 possible pieces. }
                else
                  begin
                    for K := 1 to 4 do
                      begin
                        case K of
                          1: theChessMove.PromotionPiece := kWhiteQueen;
                          2: theChessMove.PromotionPiece := kWhiteRook;
                          3: theChessMove.PromotionPiece := kWhiteBishop;
                          4: theChessMove.PromotionPiece := kWhiteKnight;
                        end;

                          { Capture to the left. }
                        theChessMove.ToSquare := theChessMove.FromSquare + 9;
                        theNotation := NotationFor(theChessMove);

                        if (theNotation > '')
                          then
                            begin
                              Inc(theNumberOfMoves);
                              theMoveArray[theNumberOfMoves] := theNotation;
                            end;

                          { Move one square forward. }
                        theChessMove.ToSquare := theChessMove.FromSquare + 10;
                        theNotation := NotationFor(theChessMove);

                        if (theNotation > '')
                          then
                            begin
                              Inc(theNumberOfMoves);
                              theMoveArray[theNumberOfMoves] := theNotation;
                            end;

                          { Capture to the right. }
                        theChessMove.ToSquare := theChessMove.FromSquare + 11;
                        theNotation := NotationFor(theChessMove);

                        if (theNotation > '')
                          then
                            begin
                              Inc(theNumberOfMoves);
                              theMoveArray[theNumberOfMoves] := theNotation;
                            end;
                      end;
                  end;
            end;



          { Generate all black pawn moves. }
        if not itsPosition.WhiteOnMove and
           (thePiece = kBlackPawn)
          then
            begin
                { If the pawn is moving from something other than the 7th rank... }
              if (theChessMove.FromSquare > 17)
                then
                  begin
                    theChessMove.PromotionPiece := kEmptySquare;

                      { Capture to the left. }
                    theChessMove.ToSquare := theChessMove.FromSquare - 9;
                    theNotation := NotationFor(theChessMove);

                    if (theNotation > '')
                      then
                        begin
                          Inc(theNumberOfMoves);
                          theMoveArray[theNumberOfMoves] := theNotation;
                        end;

                      { Move one square forward. }
                    theChessMove.ToSquare := theChessMove.FromSquare - 10;
                    theNotation := NotationFor(theChessMove);

                    if (theNotation > '')
                      then
                        begin
                          Inc(theNumberOfMoves);
                          theMoveArray[theNumberOfMoves] := theNotation;
                        end;

                      { Capture to the right. }
                    theChessMove.ToSquare := theChessMove.FromSquare - 11;
                    if EdgeSquare(theChessMove.ToSquare)
                      then theNotation := ''
                      else theNotation := NotationFor(theChessMove);

                    if (theNotation > '')
                      then
                        begin
                          Inc(theNumberOfMoves);
                          theMoveArray[theNumberOfMoves] := theNotation;
                        end;

                      { Move two squares forward. }
                    theChessMove.ToSquare := theChessMove.FromSquare - 20;
                    if EdgeSquare(theChessMove.ToSquare)
                      then theNotation := ''
                      else theNotation := NotationFor(theChessMove);

                    if (theNotation > '')
                      then
                        begin
                          Inc(theNumberOfMoves);
                          theMoveArray[theNumberOfMoves] := theNotation;
                        end;
                  end

                  { The pawn is moving to the 8th rank and promotes to 4 possible pieces. }
                else
                  begin
                    for K := 1 to 4 do
                      begin
                        case K of
                          1: theChessMove.PromotionPiece := kWhiteQueen;
                          2: theChessMove.PromotionPiece := kWhiteRook;
                          3: theChessMove.PromotionPiece := kWhiteBishop;
                          4: theChessMove.PromotionPiece := kWhiteKnight;
                        end;

                          { Capture to the left. }
                        theChessMove.ToSquare := theChessMove.FromSquare - 9;
                        if EdgeSquare(theChessMove.ToSquare)
                          then theNotation := ''
                          else theNotation := NotationFor(theChessMove);

                        if (theNotation > '')
                          then
                            begin
                              Inc(theNumberOfMoves);
                              theMoveArray[theNumberOfMoves] := theNotation;
                            end;

                          { Move one square forward. }
                        theChessMove.ToSquare := theChessMove.FromSquare - 10;
                        if EdgeSquare(theChessMove.ToSquare)
                          then theNotation := ''
                          else theNotation := NotationFor(theChessMove);

                        if (theNotation > '')
                          then
                            begin
                              Inc(theNumberOfMoves);
                              theMoveArray[theNumberOfMoves] := theNotation;
                            end;

                          { Capture to the right. }
                        theChessMove.ToSquare := theChessMove.FromSquare - 11;
                        if EdgeSquare(theChessMove.ToSquare)
                          then theNotation := ''
                          else theNotation := NotationFor(theChessMove);

                        if (theNotation > '')
                          then
                            begin
                              Inc(theNumberOfMoves);
                              theMoveArray[theNumberOfMoves] := theNotation;
                            end;
                      end;
                  end;
            end;

        if (thePiece in [kBlackKnight, kBlackBishop, kBlackRook, kBlackQueen, kBlackKing]) or
           (thePiece in [kWhiteKnight, kWhiteBishop, kWhiteRook, kWhiteQueen, kWhiteKing])
          then
            begin
              for K := 1 to TotalDirectionsOf[thePiece] do
                begin
                  theChessMove.ToSquare := theChessMove.FromSquare + PieceShift[thePiece, K];

                  while not EdgeSquare(theChessMove.ToSquare) do
                    begin
                      theNotation := NotationFor(theChessMove);

                      if (theNotation > '')
                        then
                          begin
                            Inc(theNumberOfMoves);
                            theMoveArray[theNumberOfMoves] := theNotation;
                          end;

                      theChessMove.ToSquare := theChessMove.ToSquare + PieceShift[thePiece, K];
                    end;
                end;
            end;
      end;
end;



function TChessParser.IsCheckmate: Boolean;   
var
  theNumberOfMoves: Integer;
  theMoveArray: TChessNotationArray;

begin
  GetMoveList(theNumberOfMoves,
              theMoveArray);

  Result := (theNumberOfMoves = 0) and
            KingIsInCheck;
end;



function TChessParser.IsStalemate: Boolean;
var
  theNumberOfMoves: Integer;
  theMoveArray: TChessNotationArray;

begin
  GetMoveList(theNumberOfMoves,
              theMoveArray);

  Result := (theNumberOfMoves = 0) and
            not KingIsInCheck;
end;



end.
