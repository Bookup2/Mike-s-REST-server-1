unit PocketGMBook;

interface

{$DEFINE BOOKREADWRITE}
{$DEFINE DEBUGBOOK}
{ $DEFINE TRACEBOARD}

  // Use FireDAC for Windows, LiteDAC (DevArt) for Macintosh.
{$IFDEF MSWINDOWS}
{$DEFINE USEFIREDAC}
{$ENDIF}

{$IFDEF MACOS}
{ $DEFINE USEDEVART}
{$DEFINE USEFIREDAC}
{$ENDIF}

uses
  System.SysUtils,
  System.UITypes,
  System.Classes,  // TMemoryStream
  System.IOUtils,  // System.IOUtils.TFile
  FMX.StdCtrls,
  // FMX.Memo,  // TMemo
  FMX.Dialogs,   // MessageDlg()

  FireDAC.Comp.Client,    // FDConnection
  FireDAC.Phys.SQLite,    // eliminates the need for the DLL?
  FireDac.Stan.Param,
  FireDac.Stan.Def,
  FireDac.DApt,
  FireDac.Stan.Async,
  FireDAC.FMXUI.Wait,     // TFDGUIxWaitCursor

  FireDAC.Phys.SQLiteWrapper.Stat,  // Needed for static linking (no .DLL)  FIXEDIN build 116

  Data.db,  // ftBlob?

  // gTypes,
  Utils;

  // DiagramTypes,
  // ChessPosition,
  // PositionInformation;


const

  kCarriageReturn = #13;

  kDataVersion = 100;
  kDataVersionAsString = '100';
  kDataVersionMinimumSupported = 100;

  kSQLiteInMemoryDatabase = ':memory:';

  // kASCIICharZero = 48;
  kASCIICharExclamationMark = 33;
  kSQLitePocketGMCacheDatabaseExtension = 'PGC';   //  PocketGM Cache

  kSQLTableDataVersion = 'tDataVersion';
  kSQLTableMainPosition = 'tMainPosition';

  kSQLFieldDataVersion = 'fdata_version';
  kSQLFieldFEN = 'fFEN';
  kSQLFieldCachedServerReply = 'fcached_server_reply';

  kSQLFieldCountResult = 'fcount_result';

  {

  kSQLCreateTableDataVersion = 'CREATE TABLE ' + kSQLTableDataVersion + ' (' +
                                kSQLFieldDataVersion       + ' INT)';

  }

  kSQLCreateTableMainposition = 'CREATE TABLE ' + kSQLTableMainPosition + ' (' +
                                kSQLFieldFEN                            + ' CHAR(70)   PRIMARY KEY,' +
                                kSQLFieldCachedServerReply              + ' TEXT)';

  kSQLCountMainPositions       = 'SELECT COUNT(*) AS ' + kSQLFieldCountResult + ' FROM ' + kSQLTableMainPosition;

  kSQLSelectDataVersion = 'SELECT ' +
                          kSQLFieldDataVersion + ' ' +
                          'FROM ' + kSQLTableDataVersion;

  kSQLSelectMainpositionEverything = 'SELECT * FROM ' + kSQLTableMainPosition + ' ' +
                                     'WHERE ' + kSQLFieldFEN + ' = :' + kSQLFieldFEN;

  kSQLUpdateMainposition = 'UPDATE ' + kSQLTableMainPosition + ' SET ' +
                           kSQLFieldCachedServerReply        + ' = :' + kSQLFieldCachedServerReply       + ' ' +
                           'WHERE ' + kSQLFieldFEN + ' = :' + kSQLFieldFEN;

  kSQLInsertDataVersion = 'INSERT INTO ' + kSQLTableDataVersion + ' (' +
                           kSQLFieldDataVersion             + ') ' +
                           'VALUES (' +
                           ':' + kSQLFieldDataVersion             + ')';

  kSQLInsertMainposition = 'INSERT INTO ' + kSQLTableMainPosition + ' (' +
                           kSQLFieldFEN                   + ', ' +
                           kSQLFieldCachedServerReply     + ') ' +
                           'VALUES (' +
                           ':' + kSQLFieldFEN                   + ', ' +
                           ':' + kSQLFieldCachedServerReply        + ')';


  fSQLSelectFirstFEN = 'SELECT ' + kSQLFieldFEN + ' FROM ' + kSQLTableMainPosition + ' ORDER BY ' + kSQLFieldFEN + ' LIMIT 1';

  fSQLSelectFENAfter = 'SELECT ' + kSQLFieldFEN + ' FROM ' + kSQLTableMainPosition + ' WHERE ' + kSQLFieldFEN + ' > :' + kSQLFieldFEN + ' ORDER BY ' + kSQLFieldFEN + ' LIMIT 1';



type
  TChessFENKeyString = String[70];


  // BufferType = array [1..kLargestRecord + kExtraBufferSpace] of Byte;

  TCachedServerReplyBook = class(TObject)
    constructor Create;

    destructor Destroy; override;

    function CreateDatabase(aFileName: String): Boolean;
    procedure OpenDatabase(aFileName: String);
    procedure CloseDatabase;

    function TableExists(aTablename: String): Boolean;

    function GetDataVersion: Integer;
    procedure SetDataVersion;

    function GetPragma(aPragma: String): String;
    function GetDriverName: String;


    function GetFileName: String;

    function FENExists(const aFEN: String): Boolean;

    procedure FillInEverything(aFEN: String;
                               var aCachedServerReply: String);

    procedure UpdateEverything(aFEN: String;
                               aCachedServerReply: String);

    function NumberOfFENs: LongInt;

    function GetFirstFEN(var theFEN: String): Boolean;
    function GetFENAfter(var theFEN: String): Boolean;

    private

    protected

    fFileName,
    fExpandedFileName: String;
    fDiskNumberOfFileName: Integer;

    fNumberOfMainTableUpdates: Integer;
    fNumberOfMainTableInserts: Integer;

    fSQLite3Connection: TFDConnection;
    fSQLite3Query: TFDQuery;
  end;


{=============================================================================}

implementation



procedure TCachedServerReplyBook.CloseDatabase;
begin
  if fSQLite3Connection.Connected
    then fSQLite3Connection.Connected := False;

  fSQLite3Connection.Params.Clear;
  fSQLite3Connection.DriverName := 'SQLite';
end;



constructor TCachedServerReplyBook.Create;
var
  ForTesting: Integer;

begin
  inherited Create;

  fFileName := '';
  fExpandedFileName := '';

  fDiskNumberOfFileName := -2;

  fSQLite3Connection := TFDConnection.Create(nil);
  fSQLite3Connection.OptionsIntf.FormatOptions.StrsTrim := False;

  ForTesting := fSQLite3Connection.Params.Count;

  fSQLite3Connection.DriverName := 'SQLite';

    // Re: SQLite is slow in OS X https://quality.embarcadero.com/browse/RSP-11827
  fSQLite3Connection.ResourceOptions.SilentMode := True;   // Recommended workaround by Dmitry Arefiev on Dec 8, 2015

  fSQLite3Query := TFDQuery.Create(nil);

  fSQLite3Query.Connection := fSQLite3Connection;
end;



destructor TCachedServerReplyBook.Destroy;
var
  TESTName: String;

begin
  try

    TestName := fFileName;

    if fSQLite3Connection.Connected
      then
        begin
          CloseDatabase;
        end;

  except

  end;

  FreeAndNil(fSQLite3Query);
  FreeAndNil(fSQLite3Connection);

  inherited Destroy;
end;



  { This method creates a new database but does not open it. }
function TCachedServerReplyBook.CreateDatabase(aFileName: String): Boolean;
var
  ExpandedFileName: String;
  theFilePath: String;
  theCurrentMode: String;

begin
  fFileName := aFileName;

  ExpandedFileName := ExpandFileName(fFileName);

  if (Length(ExpandedFileName) > 0)
    then fDiskNumberOfFileName := (Pos(ExpandedFileName[1], 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'))
    else fDiskNumberOfFileName := 0;  { assume the default drive }

  {$IFDEF MSWINDOWS}
  RemoveReadOnlyAttribute(ExpandedFileName);
  {$ENDIF MSWINDOWS}

      { Trim off the extension. }
  // theFilePath := ExtractFilePath(fFileName);

        // Add on the extension
  // fFileName := fFileName + '.' + kSQLiteDatabaseExtension;

  if FileExists(fFileName)
    then
      begin

        try
            // Remove any read-only or system flag.
          {$IFDEF MSWINDOWS}
          FileSetAttr(fFileName, 0);
          {$ENDIF MSWINDOWS}

          System.IOUtils.TFile.Delete(fFileName);  // FIXEDIN build 113

        except
          ShowMessage('A database already exists that cannot be deleted. ' + kCarriageReturn + fFileName);

          raise;

        end;
      end;

  if FileExists(fFileName)
    then
      begin
        Assert(False, 'A database already exists that cannot be deleted. ' + kCarriageReturn + fFileName);
      end;

  try
    // fSQLite3Connection.Params.Clear;
    // fSQLite3Connection.Params.Add('DriverID=SQLite');
    fSQLite3Connection.Params.Add('Database=' + fFilename);

    fSQLite3Connection.Connected := True;

    // fSQLite3Query.SQL.Text := kSQLCreateTableDataVersion;
    // fSQLite3Query.ExecSQL;
    fSQLite3Query.SQL.Text := kSQLCreateTableMainposition;
    fSQLite3Query.ExecSQL;


    SetDataVersion;

    // fSQLite3Query.ExecSQL('PRAGMA synchronous = WHAT');
    // fSQLite3Query.ExecSQL('PRAGMA synchronous = OFF');   // Safety mode is off.

    fSQLite3Query.SQL.Text := 'PRAGMA journal_mode';
    fSQLite3Query.Open;
    // fSQLite3Query.Open('PRAGMA journal_mode');  FireDAC code

    theCurrentMode := fSQLite3Query.Fields[0].AsString;

      // http://www.sqlite.org/pragma.html#pragma_journal_mode
    // fSQLite3Query.ExecSQL('PRAGMA journal_mode=OFF');   // Safety mode is off.

    fSQLite3Query.SQL.Text := 'PRAGMA journal_mode';
    fSQLite3Query.Open;
    theCurrentMode := fSQLite3Query.Fields[0].AsString;

  except

    raise
  end;

    // Break the connection.
  fSQLite3Connection.Connected := False;

  Result := True;
end;



function TCachedServerReplyBook.GetPragma(aPragma: String): String;
begin
  fSQLite3Query.SQL.Text := 'PRAGMA ' + aPragma;
  fSQLite3Query.Open;
  Result := fSQLite3Query.Fields[0].AsString;
end;



function TCachedServerReplyBook.GetDriverName: String;
begin
  Result := 'FireDAC ' + fSQLite3Connection.DriverName;
end;



  { This method opens a database based on SQLite. }
  // NOTE: The default folder must be set before calling this method.
procedure TCachedServerReplyBook.OpenDatabase(aFileName: String);
// var
//   theCurrentMode: String;

begin
  Assert(FileExists(aFileName), 'OpenDatabase() - Database file does not exist.  Folder or file name may have illegal characters.');

  fFileName := aFileName;

  fExpandedFileName := ExpandFileName(fFileName);

  // Assert(not UseSaveMode, 'Code for safety mode with SQLite not tested.');

    // ******************* Is fDiskNumberOfFileName necessary or even possible on MACOS?
  if (Length(fExpandedFileName) > 0)
    then fDiskNumberOfFileName := (Pos(fExpandedFileName[1], 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'))
    else fDiskNumberOfFileName := 0;  { assume the default drive }

  {$IFDEF MSWINDOWS}
  RemoveReadOnlyAttribute(fExpandedFileName);
  {$ENDIF}



    // no extension expected

  fSQLite3Connection.Connected := False;

  // fSQLite3Connection.Params.Clear;
  // fSQLite3Connection.Params.Add('DriverID=SQLite');
  fSQLite3Connection.Params.Add('Database=' + fFilename);

  try
    fSQLite3Connection.Connected := True;

  except
    on E: EAbort do
      ; // user pressed Cancel button in Login dialog

    {
    on E: EFDDBEngineException do
      case E.Kind of
        ekUserPwdInvalid: ; // user name or password are incorrect
        ekUserPwdExpired: ; // user password is expired
        ekServerGone: ;     // DBMS is not accessible due to some reason
      else                // other issues
    end;
    }
  end;
end;



procedure TCachedServerReplyBook.SetDataVersion;
begin
  fSQLite3Query.SQL.Text := 'PRAGMA user_version=' + IntToStr(kDataVersion) + ';';
  fSQLite3Query.ExecSQL;
end;



function TCachedServerReplyBook.TableExists(aTablename: String): Boolean;
begin
  fSQLite3Query.SQL.Text := 'SELECT count(*) AS ' + kSQLFieldCountResult + ' FROM sqlite_master WHERE type=' + #39 +  'table' + #39 +
                            ' AND name=' + #39 + aTablename + #39;
  try
    fSQLite3Query.Open();

    Assert((fSQLite3Query.RecordCount = 1),
           'TableExists() has an invalid RecordCount of ' + IntToStr(fSQLite3Query.RecordCount));
  except


    on E: Exception do

      begin

        ShowMessage(E.Message);

        raise;
      end;
  end;


  Result := (fSQLite3Query.FieldByName(kSQLFieldCountResult).AsInteger > 0);

end;



procedure TCachedServerReplyBook.UpdateEverything(aFEN: String;
                                                  aCachedServerReply: String);
begin
  Assert((Length(aFEN) > 15), 'UpdateEverything had a short or blank FEN');

  if (Copy(aFEN, Length(aFEN), 1) = ' ')
    then aFEN := Copy(aFEN, 1, Length(aFEN) - 1);

  try
    if FENExists(aFEN)
      then
        begin
          fSQLite3Query.SQL.Text := kSQLUpdateMainposition;

          fSQLite3Query.ParamByName(kSQLFieldFEN).AsString               := aFEN;
          fSQLite3Query.ParamByName(kSQLFieldCachedServerReply).AsString := aCachedServerReply;

          {
          if (aCachedServerReply <> nil)
            then fSQLite3Query.ParamByName(kSQLFieldCachedServerReply).AsString := aCachedServerReply.Text
            else fSQLite3Query.ParamByName(kSQLFieldCachedServerReply).AsString := '';
          }
          // fSQLite3Query.ParamByName(kSQLFieldWhatever).LoadFromStream(theStream, ftBlob);

          try

            fSQLite3Query.ExecSQL;

          except

            on E: Exception do
              begin

                ShowMessage(E.Message);

                raise;
              end;
          end;
        end
      else
        begin
          fSQLite3Query.SQL.Text := kSQLInsertMainposition;

          fSQLite3Query.ParamByName(kSQLFieldFEN).AsString               := aFEN;
          fSQLite3Query.ParamByName(kSQLFieldCachedServerReply).AsString := aCachedServerReply;

          {
          if (aCachedServerReply <> nil)
            then fSQLite3Query.ParamByName(kSQLFieldCachedServerReply).AsString := aCachedServerReply.Text
            else fSQLite3Query.ParamByName(kSQLFieldCachedServerReply).AsString := '';
          }

          try

            fSQLite3Query.ExecSQL;

          except

            on E: Exception do
              begin

                ShowMessage(E.Message);

                raise;
              end;
          end;
        end;

  except


    on E: Exception do

      begin

        ShowMessage(E.Message);

        raise;
      end;
  end;
end;



function TCachedServerReplyBook.GetFileName: String;
begin
  GetFileName := fFileName;
end;



function TCachedServerReplyBook.FENExists(const aFEN: String): Boolean;
var
  theFEN: String;

begin
  theFEN := aFEN;

  if (Copy(theFEN, Length(theFEN), 1) = ' ')
    then theFEN := Copy(aFEN, 1, Length(theFEN) - 1);

  fSQLite3Query.SQL.Text := 'SELECT rowid FROM ' + kSQLTableMainposition + ' WHERE ' + kSQLFieldFEN + ' = :' + kSQLFieldFEN;

  try
    fSQLite3Query.ParamByName(kSQLFieldFEN).AsString := theFEN;

    fSQLite3Query.Open();

    Assert((fSQLite3Query.RecordCount = 0) or (fSQLite3Query.RecordCount = 1),
           'BoardExists() has an invalid RecordCount of ' + IntToStr(fSQLite3Query.RecordCount));

    Result := (fSQLite3Query.RecordCount > 0);

  except


    on E: Exception do

      begin

        ShowMessage(E.Message);

        raise;
      end;
  end;
end;



procedure TCachedServerReplyBook.FillInEverything(aFEN: String;
                                                  var aCachedServerReply: String);
var
  theFENExists: Boolean;
  theFENFromSQLite: String;

begin
    { Wipe out the server reply. }
  {
  if (aCachedServerReply <> nil)
    then
      begin
        aCachedServerReply.Text := '';
      end;
  }

  aCachedServerReply := '';


  fSQLite3Query.SQL.Text := kSQLSelectMainpositionEverything;

  try
    fSQLite3Query.ParamByName(kSQLFieldFEN).AsString := aFEN;

    fSQLite3Query.Open();

    Assert((fSQLite3Query.RecordCount = 0) or (fSQLite3Query.RecordCount = 1),
           'FillInEverything() has an invalid RecordCount of ' + IntToStr(fSQLite3Query.RecordCount));

    theFENExists := (fSQLite3Query.RecordCount > 0);

  except

    on E: Exception do

      begin

        ShowMessage(E.Message);

        raise;
      end;
  end;

    // If the database does not have this FEN, exit with a blank server reply.
  if not theFENExists
    then Exit;

    {
  if (aCachedServerReply <> nil)
    then aCachedServerReply.Text := fSQLite3Query.FieldByName(kSQLFieldCachedServerReply).AsString;
  }

    aCachedServerReply := fSQLite3Query.FieldByName(kSQLFieldCachedServerReply).AsString;

  theFENFromSQLite := fSQLite3Query.FieldByName(kSQLFieldFEN).AsString;

  if (aFEN <> theFENFromSQLite)
    then ShowMessage('Database corruption');

end;



function TCachedServerReplyBook.GetDataVersion: Integer;
var
  theVersionString: String;
  theVersionNumber, theErrorCode: Integer;

begin
  theVersionString := GetPragma('user_version');

  Val(theVersionString, theVersionNumber, theErrorCode);

  Result := theVersionNumber;

  {
  if not TableExists(kSQLTableDataVersion)
    then
      begin
        Result := 0;
        Exit;
      end;

  fSQLite3Query.SQL.Text := kSQLSelectDataVersion;

  try
    fSQLite3Query.Open();

    Assert((fSQLite3Query.RecordCount = 1),
           'GetDataVersion() has an invalid RecordCount of ' + IntToStr(fSQLite3Query.RecordCount));

  except


    on E: Exception do

      begin

        ShowMessage(E.Message);

        raise;
      end;
  end;


  Result := fSQLite3Query.FieldByName(kSQLFieldDataVersion).AsInteger;

  }

end;



function TCachedServerReplyBook.NumberOfFENs: LongInt;
begin
  fSQLite3Query.SQL.Text := kSQLCountMainPositions;

  try
    fSQLite3Query.Open();

    Assert((fSQLite3Query.RecordCount = 1),
           'NumberOfPositions() has an invalid RecordCount of ' + IntToStr(fSQLite3Query.RecordCount));

  except


    on E: Exception do

      begin

        ShowMessage(E.Message);

        raise;
      end;
  end;

  NumberOfFENs := fSQLite3Query.FieldByName(kSQLFieldCountResult).AsInteger;
end;



function TCachedServerReplyBook.GetFirstFEN(var theFEN: String): Boolean;
begin
  fSQLite3Query.SQL.Text := fSQLSelectFirstFEN;

  try
    fSQLite3Query.Open();

    Assert((fSQLite3Query.RecordCount = 0) or (fSQLite3Query.RecordCount = 1),
           'GetFirstFEN() has an invalid RecordCount of ' + IntToStr(fSQLite3Query.RecordCount));

  except


    on E: Exception do

      begin

        ShowMessage(E.Message);

        raise;
      end;
  end;


  if (fSQLite3Query.RecordCount = 0)
    then
      begin
        Result := False;
        Exit;
      end;

  theFEN := fSQLite3Query.FieldByName(kSQLFieldFEN).AsString;

  Result := True;
end;



function TCachedServerReplyBook.GetFENAfter(var theFEN: String): Boolean;
var
  aNextBoardString: String;

begin
  fSQLite3Query.SQL.Text := fSQLSelectFENAfter;

  try
    fSQLite3Query.ParamByName(kSQLFieldFEN).AsString := theFEN;

    fSQLite3Query.Open();

    Assert((fSQLite3Query.RecordCount = 0) or (fSQLite3Query.RecordCount = 1),
           'TCachedServerReplyBook.GetFENAfter() has an invalid RecordCount of ' + IntToStr(fSQLite3Query.RecordCount));

    if (fSQLite3Query.RecordCount = 0)
      then
        begin
          Result := False;
          Exit;
        end;

  except


    on E: Exception do

      begin

        ShowMessage(E.Message);

        raise;
      end;
  end;


  theFEN := fSQLite3Query.FieldByName(kSQLFieldFEN).AsString;


  Result := True;
end;



end.
