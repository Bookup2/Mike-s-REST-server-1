unit PositionInformation;

interface

uses
  Classes,

  gTypes,
  DiagramTypes;

  // Utils;


type
  TPositionInformation = class(TObject)
    NumberOfCandidates: Byte;
    NumberOfUnCandidates: Byte;
    StaticInformantRate,
    BacksolvedInformantRate: InformantRateType;
    TotalVariationsInTree: BackSolveTotalType;
    NumericAssessment: Integer; // NumericAssessmentType;
    Certainty: Integer; // TCertainty;
    Board: ChessBoardType;
    CandidateArray: TCandidateArray;
    UnCandidateArray: TUnCandidateArray;
    OpeningCode: OpeningCodeType;
    GameMasterWhiteWins,
    GameMasterDraws,
    GameMasterBlackWins: Integer;
    GameMasterLatestYear: Word;

    fMarkupCommands: TStringList;      // FIXEDIN build 141
    fComments: TStringList;  // replaces the use of TMemo     FIXEDIN build 124

    NumberOfTimesMultimediaPlayed: Integer; // FIXEDIN build 141

    constructor Create;

    destructor Destroy; override;

    procedure Clear;
  end;



implementation

constructor TPositionInformation.Create;
begin
  inherited Create;

  fMarkupCommands := TStringList.Create;
  fComments := TStringList.Create;

  OpeningCode := '';
  TotalVariationsInTree := 1;  // just this variation so far
  NumericAssessment := kNoNumericAssessment;
  StaticInformantRate := kNoRate;
  BacksolvedInformantRate := kNoRate;

  NumberOfCandidates := 0;
  NumberOfUnCandidates := 0;
  Certainty := 0; // kCertaintyNone;
end;



destructor TPositionInformation.Destroy;
begin
  if (fMarkupCommands <> nil)
    then fMarkupCommands.Free;

  if (fComments <> nil)
    then fComments.Free;

  inherited Destroy;
end;



procedure TPositionInformation.Clear;
begin
  fMarkupCommands.Text := '';
  fComments.Text := '';

  OpeningCode := '';
  TotalVariationsInTree := 1;
  NumericAssessment := kNoNumericAssessment;
  StaticInformantRate := kNoRate;
  BacksolvedInformantRate := kNoRate;

  NumberOfCandidates := 0;
  NumberOfUnCandidates := 0;

  NumberOfTimesMultimediaPlayed := 0;  // FIXEDIN build 141
end;



end.
