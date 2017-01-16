{
Author of the code: alex208210.
SinglePlayer code is distributed under Mozilla Public Licence, which means, in short, that it is free for both freeware and commercial use.You can use it in products with closed or open-source freely. The only requirements are:
1) Acknowledge SinglePlayer code is used somewhere in your application (in an about box, credits page or printed manual, etc. with at least a link to http://singleplayer.coddism.com/)
2) Modifications made to SinglePlayer code must be made public (no need to publish the full code, only to state which parts were altered, and how), but feel welcome to open-source your code if you so wish.
}
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
  if fileexists(ExtractFilePath(ParamStr(0))+'logo.jpg') then
   begin
    logoicon:= TJPEGImage.Create;
    logoicon.Width  := 800;
    logoicon.Height := 480;
    logoicon.LoadFromFile(ExtractFilePath(ParamStr(0))+'logo.jpg');
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

