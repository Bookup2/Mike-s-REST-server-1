program PocketGMServer;
{$APPTYPE GUI}

uses
  System.StartUpCopy,
  FMX.Forms,
  Web.WebReq,
  IdHTTPWebBrokerBridge,
  Form.Main in 'Form.Main.pas' {MainForm},
  WebModuleUnit1 in 'WebModuleUnit1.pas' {WebModule1: TWebModule},
  RegistrationDatabase in 'RegistrationDatabase.pas',
  Form.COWRegistrations in 'Form.COWRegistrations.pas' {COWRegistrationWindow};

{$R *.res}

begin
  if WebRequestHandler <> nil then
    WebRequestHandler.WebModuleClass := WebModuleClass;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TCOWRegistrationWindow, COWRegistrationWindow);
  Application.Run;
end.
