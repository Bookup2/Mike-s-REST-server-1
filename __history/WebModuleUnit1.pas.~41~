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
    procedure WebModuleCreate(Sender: TObject);
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

  Form.Main;

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TWebModule1.WebModule1DefaultHandlerAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  Response.Content :=
    '<html>' +
    '<head><title>Mikes Test Title</title></head>' +
    '<body>This is from Mike''''s web server app.</body>' +
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



procedure TWebModule1.WebModuleCreate(Sender: TObject);
begin
  // Create some engine instances.

end;



end.
