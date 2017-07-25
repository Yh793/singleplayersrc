program SinglePlayerMain;

{$mode delphi}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, core, SinglePlayer, SysUtils, loading, Windows,inifiles,Graphics;
var
 pidfile,f:textfile;
 inifilepid:tinifile;

{$R *.res}


begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TMMCCore, MMCCore);
  if fileexists(ExtractFilePath(ParamStr(0))+'PID') then
   begin
    inifilepid := TINIFile.Create(ExtractFilePath(ParamStr(0))+'PID');
    fd:=inifilepid.ReadInteger('singleinfo','formhandle',0);
   end;
  inifilepid.Free;
  EnumWindows (@EnumProc, 1);
  if (CheckTask('explorer.exe')<>0) then killtask('explorer.exe');
  MMCCore.Refresh;
  if fileexists(ExtractFilePath(ParamStr(0))+'logo.bmp') then
   begin
    logoicon:= graphics.tbitmap.Create;
    logoiconP:=Tpicture.Create;
    logoicon.Width  := 800;
    logoicon.Height := 480;
    logoicon.Handle:=LoadBMP(ExtractFilePath(ParamStr(0))+'logo.bmp');
    logoiconP.Bitmap:=logoicon;
   end;
  Application.CreateForm(TLoadingGUI, LoadingGUI);
  LoadingGUI.Show;
  LoadingGUI.Refresh;
  Application.CreateForm(TSinglePlayerGUI, SinglePlayerGUI);
  SinglePlayerGUI.Show;
  assignfile(pidfile,ExtractFilePath(ParamStr(0))+'PID');
  try
  rewrite(pidfile);
  writeln(pidfile,'[singleinfo]');
  writeln(pidfile,'formhandle='+inttostr(SinglePlayerGUI.Handle));
  writeln(pidfile,'formname='+SinglePlayerGUI.Caption);
  writeln(pidfile,'processhandle='+inttostr(GetCurrentProcessId));
  closefile(pidfile);
  except
  end;
  MMCCore.checkpidtimer.Enabled:=true;
  if (directoryexists('\Windows\desktop')=true) then
   begin
    assignfile(f,'\Windows\desktop\SinglePlayer.lnk');
    rewrite(f);
    writeln(f,'29#"'+Application.ExeName+'"');
    closefile(f);
   end;
  Application.Run;
end.

