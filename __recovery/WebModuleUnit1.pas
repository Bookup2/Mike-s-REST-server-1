unit WebModuleUnit1;

interface

uses
  System.SysUtils, System.Classes, Web.HTTPApp;

const
  kMaximumChessEngines = 4;

type
  TWebModule1 = class(TWebModule)
    procedure WebModule1DefaultHandlerAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1WebActionItem1Action(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1WebActionItem2Action(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  WebModuleClass: TComponentClass = TWebModule1;

implementation

uses
  Winsock,
  // System.Threading,
  // System.UITypes,

  RegistrationDatabase,

  Form.Main;

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TWebModule1.WebModule1DefaultHandlerAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin

  Response.Content :=
    '<html>' +
    '<head><title>PocketGM Server</title></head>' +
    '<body>' +
    'Welcome to the Bookup Chess Engine Server for PocketGM.<br><br>' +
    MainForm.ServerStatusForBrowser +
    '</body>' +
    '</html>';
end;



procedure TWebModule1.WebModule1WebActionItem1Action(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  theLine: String;
  theFields: TStringList;
  theCount: Integer;
  theFEN,
  theReplyForTheClient,
  theClientID: String;

begin
  if (Request.MethodType <> mtGet)
    then Exit;

  theLine := Request.Content;

  theFields := TStringList.Create;

  Request.ExtractQueryFields(theFields);

  theCount := theFields.Count;

  TThread.Synchronize(TThread.Current,
    procedure
    var
      K: Integer;

    begin
      // MainForm.RequestsMemo.Lines.Add(Request.Content);

      theCount := theFields.Count;

      if theCount = 2
        then
          begin
            for K := 0 to (theFields.Count -1) do
            begin
              theFields.Strings[K] := StringReplace(theFields.Strings[K], '+', ' ', [rfReplaceAll]);
              // theFields.Strings[K] := TIdURI.URLDecode(theFields.Strings[i], enUtf8);

              // MainForm.RequestsMemo.Lines.Add('theCount is ' + theCount.ToString);
              // MainForm.RequestsMemo.Lines.Add(theFields.Strings[K]);
            end;

            theFEN := theFields.Strings[0];
            theClientID := theFields.Strings[1];
            MainForm.AnalyzeThisPositionForClient(theFEN,theClientID,theReplyForTheClient);
           end;
    end);

  Response.ContentType := 'application/json;charset=utf-8';
  Response.Content := theReplyForTheClient;

  theFields.Free;
end;



procedure TWebModule1.WebModule1WebActionItem2Action(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  theLine: String;
  theFields: TStringList;
  theCount: Integer;
  theReplyForTheClient,
  theEmailAddress,
  theProductKey,
  theIPAddress,
  theFirstName,
  theLastName,
  theCOWTypeString: String;
  theCOWType: TCOWType;

begin
  // localhost:80/checkcowproregistration?emailaddress=testemail@bookup.com&productkey=COWPRO-XXXX&IPAddress=186.0.0.1&FirstName=Mike&LastName=Leahy&COWType=PW
  // localhost:80/checkcowproregistration?testemail@bookup.com&COWPRO-XXXX&186.0.0.1&Mike&Leahy&PW

  if (Request.MethodType <> mtGet)
    then Exit;

  theLine := Request.Content;

  theFields := TStringList.Create;

  Request.ExtractQueryFields(theFields);

  theCount := theFields.Count;

  theReplyForTheClient := 'ERROR: General Error';

  if (theCount <> 6) then theReplyForTheClient := 'ERROR: Expected 6 fields and got ' + theCount.ToString;

  TThread.Synchronize(TThread.Current,
    procedure
    var
      K: Integer;

    begin
      // MainForm.RequestsMemo.Lines.Add(Request.Content);

      theCount := theFields.Count;

      if theCount = 6
        then
          begin
            for K := 0 to (theFields.Count -1) do
            begin
              theFields.Strings[K] := StringReplace(theFields.Strings[K], '+', ' ', [rfReplaceAll]);
              // theFields.Strings[K] := TIdURI.URLDecode(theFields.Strings[i], enUtf8);

              // MainForm.RequestsMemo.Lines.Add('theCount is ' + theCount.ToString);
              // MainForm.RequestsMemo.Lines.Add(theFields.Strings[K]);
            end;

            theEmailAddress := theFields.Strings[0];
            theProductKey := theFields.Strings[1];
            theIPAddress := theFields.Strings[2];
            theFirstName := theFields.Strings[3];
            theLastName := theFields.Strings[4];
            theCOWTypeString := theFields.Strings[5];
          end;

          if (theCOWTypeString = 'PW') then theCOWType := kCOWProWin;
          if (theCOWTypeString = 'PM') then theCOWType := kCOWProMac;
          if (theCOWTypeString = 'EW') then theCOWType := kCOWExpressWin;
          if (theCOWTypeString = 'EM') then theCOWType := kCOWExpressMac;

         //  TCOWType = (kCOWProWin, kCOWProMac, kCOWExpressWin, kCOWExpressMac);

          if (theCOWTypeString <> 'PW') and
             (theCOWTypeString <> 'PM') and
             (theCOWTypeString <> 'EW') and
             (theCOWTypeString <> 'EM')
            then theReplyForTheClient := 'ERROR: COW type is incorrect.'
            else
              begin
                MainForm.ProcessRegistrationRequest(theCOWType,
                                                    theEmailAddress,
                                                    theProductKey,
                                                    theIPAddress,
                                                    theFirstName,
                                                    theLastName,
                                                    theReplyForTheClient);

                                                {
                                               theCOWType: TCOWType;
                                               theEmailAddress: String;
                                               theProductKey: String;
                                               theIPAddress: String;
                                               theFirstName: String;
                                               theLastName: String;
                                               var theReplyForTheClient: String);
                                               }
              end;
    end);

  Response.ContentType := 'application/json;charset=utf-8';
  Response.Content := theReplyForTheClient;

  theFields.Free;
end;



end.
