unit ChessEngineDataThread;

interface

uses
  System.Classes,
  System.SyncObjs,  // TCriticalSection

  Globals;

type
  TChessEngineDataThread = class(TThread)

  fCriticalSection: System.SyncObjs.TCriticalSection;

  private
    { Private declarations }
    fDone: Boolean;

  protected

    procedure Execute; override;

  public

    procedure FinishUp;

  end;

implementation

{ 
  Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);  

  and UpdateCaption could look like,

    procedure TChessEngineDataThread.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; 
    
    or 
    
    Synchronize( 
      procedure 
      begin
        Form1.Caption := 'Updated in thread via an anonymous method' 
      end
      )
    );
    
  where an anonymous method is passed.
  
  Similarly, the developer can call the Queue method with similar parameters as 
  above, instead passing another TThread class as the first parameter, putting
  the calling thread in a queue with the other thread.
    
}

{ TChessEngineDataThread }


procedure TChessEngineDataThread.Execute;
var
  K: Integer;

begin
  fDone := False;  // Not done until the thread is killed.

  fCriticalSection := TCriticalSection.Create;

  repeat

    fCriticalSection.Acquire;

    try

      for K := 1 to gNumberOfEnginesRunning do
        begin
          if (gChessEngineControllers[K] <> nil)
            then
              begin

                try   // Don't let the thread die because of an error.

                  gChessEngineControllers[K].CheckPipes;

                except

                end;

                Inc(gNumberOfChessEngineDataThreadExecutes);
              end;
        end;

    finally

      fCriticalSection.Release;

    end;

    Sleep(200);
  until fDone;

  fCriticalSection.Free;
end;



procedure TChessEngineDataThread.FinishUp;
begin
  fDone := True;
end;



end.
