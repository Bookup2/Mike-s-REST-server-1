unit Form.COWRegistrations;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls;

type
  TCOWRegistrationWindow = class(TForm)
    DatabaseFileNameLabel: TLabel;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  COWRegistrationWindow: TCOWRegistrationWindow;

implementation

{$R *.fmx}

procedure TCOWRegistrationWindow.FormActivate(Sender: TObject);
begin
  DatabaseFileNameLabel.Text := 'asdf';
end;



end.
