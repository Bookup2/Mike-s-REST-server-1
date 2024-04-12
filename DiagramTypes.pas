unit DiagramTypes;

   interface

const
  {------------------ Chess Stuff -------------------}
  kBlackKing = 12;
  kBlackQueen = 11;
  kBlackRook = 10;
  kBlackBishop = 9;
  kBlackKnight = 8;
  kBlackPawn = 7;

  kWhiteKing = 6;
  kWhiteQueen = 5;
  kWhiteRook = 4;
  kWhiteBishop = 3;
  kWhiteKnight = 2;
  kWhitePawn = 1;

  kEmptySquare = 0;
  kNoSquare = -21;

  kDiacriticNone = 1;
  kDiacriticExclam = 2;
  kDiacriticExclamQuestion = 3;
  kDiacriticDoubleExclam = 4;
  kDiacriticQuestion = 5;
  kDiacriticQuestionExclam = 6;
  kDiacriticDoubleQuestion = 7; // The database checks limits based on these. If one
    // is added then the database must be updated.

    // --------------- Script Commands -------------------
  kSCDiagramClearCommands = 'CC';
  kSCDiagramDotBlue = 'DR';
  kSCDiagramDotRed = 'DD';
  kSCDiagramX = 'DX';
  kSCDiagramArrowLarge = 'DA';
  kSCDiagramArrowSmall = 'DS';
  kSCDiagramHighlight1 = 'H1';
  kSCDiagramHighlight2 = 'H2';

type
  SquareType = -21..98;

  DiacriticType = kDiacriticNone..kDiacriticDoubleQuestion;

  PieceType = kEmptySquare..kBlackKing;

  ChessMoveType = record
    FromSquare, ToSquare: SquareType;
    PromotionPiece: PieceType;
    Diacritic : DiacriticType;
  end;

  TUnMove = record
    FromSquare,
    ToSquare,
    OtherSquare1,
    OtherSquare2: SquareType;
    FromSquarePiece,
    ToSquarePiece,
    OtherSquare1Piece,
    OtherSquare2Piece : PieceType;
    WhiteOnMove: Boolean;
    WhiteCanCastleKingside,
    WhiteCanCastleQueenside,
    BlackCanCastleKingside,
    BlackCanCastleQueenside: Boolean;
    EnPassantSquare: SquareType;
    // RightsWord : Word;  used by the legacy code
  end;

  PChessMoveType = ^ChessMoveType;

     { 0..15 contains packed piece placement }
  ChessBoardType = record
    Squares: array [0..15] of Word;
    WhiteOnMove: Boolean;
    WhiteCanCastleKingside,
    WhiteCanCastleQueenside,
    BlackCanCastleKingside,
    BlackCanCastleQueenside: Boolean;
    EnPassantSquare: SquareType;
  end;
  PChessBoardType = ^ChessBoardType;

  TDiagramMark = (kDMNoMark,
                  kDMDot,
                  kDMX);

  TDiagramMarkArray = array [0..15] of Word; // 16 x 4 bit slots

implementation

end.
