{
Author of the code: alex208210.
SinglePlayer code is distributed under Mozilla Public Licence, which means, in short, that it is free for both freeware and commercial use.You can use it in products with closed or open-source freely. The only requirements are:
1) Acknowledge SinglePlayer code is used somewhere in your application (in an about box, credits page or printed manual, etc. with at least a link to http://singleplayer.coddism.com/)
2) Modifications made to SinglePlayer code must be made public (no need to publish the full code, only to state which parts were altered, and how), but feel welcome to open-source your code if you so wish.
}
unit core;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Tlhelp32, Windows;

const
  LongTapTime = 500;
  BtnDelay = 150;

type

  { TMMCCore }

  TMMCCore = class(TForm)
    checkpidtimer: TTimer;
    procedure checkpidtimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var {%H-}CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  MMCCore: TMMCCore;
  FS, FSnapshotHandle: THandle;
  FP, FProcessEntry32: TProcessEntry32;
  Co:boolean;
  fd,ButtonTimeOld,ButtonTime:integer;
  pi: TPROCESSINFORMATION;
  ShortTap:boolean;

procedure checkexplorer;
procedure RunSaver;
function CheckTask (ExeFileName: string): Integer;
function KillTask (ExeFileName: string): Integer;
function LaunchProcess(const APath: String; ACmdLine: String = ''): Boolean;
function EnumProc (Wd: HWnd; Param: LongInt): Boolean; stdcall;
procedure GetTap;
procedure SleepAndProcess(X: DWord);

implementation

uses singleplayer, loading;

{$R *.lfm}

procedure checkexplorer;
begin
 if (checktask(SinglePlayerSettings.altmenu)=0) and (CheckTask('explorer.exe')=0) then LaunchProcess('explorer.exe');
 ShowWindow(SinglePlayerGUI.Handle, SW_HIDE);
 MMCCore.hide;
 LoadingGUI.hide;
end;

procedure RunSaver;
begin

end;

function KillTask (ExeFileName: string): Integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: Boolean;
  hProc: Handle;
begin
  {$IFDEF WInCE}
  try
    Result:=0;
    FSnapshotHandle:=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    FProcessEntry32.dwSize:=SizeOf(FProcessEntry32);
    ContinueLoop:=Process32First(FSnapshotHandle, FProcessEntry32);
    while Integer(ContinueLoop)<>0 do
    begin
      if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) = UpperCase(ExeFileName))) then
      begin
        hProc:=OpenProcess(PROCESS_TERMINATE,BOOL(0),FProcessEntry32.th32ProcessID);
        Result:=Integer(TerminateProcess(hProc,0));
        CloseHandle(hProc);
      end;
      ContinueLoop:=Process32Next(FSnapshotHandle, FProcessEntry32);
    end;
    CloseToolhelp32Snapshot(FSnapshotHandle);
  except
  end;
  {$ENDIF}
end;

function CheckTask (ExeFileName: string): Integer;
begin
  {$IFDEF WInCE}
  result:=0;
  FS:=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
  FP.dwSize:=Sizeof(FP);
  Co:=Process32First(FS,FP);
  while integer(Co)<>0 do
  begin
    if ((UpperCase(ExtractFileName(FP.szExeFile))=UpperCase(ExeFileName)) or
       (UpperCase(FP.szExeFile)=UpperCase(ExeFileName))) then Result:=1;
    Co:=Process32Next(FS,FP);
  end;
  CloseToolhelp32Snapshot(FS);
  {$ENDIF}
end;

function LaunchProcess(const APath: String; ACmdLine: String = ''): Boolean;
var
   {$IFDEF WINCE}
   wPath, wCmdLine: WideString;
   pwcCmdLine: PWideChar;
   {$ELSE}
   si: TStartupInfo;
   wPath: String;
   {$ENDIF}
begin
   FillChar(pi,SizeOf(TPROCESSINFORMATION),#0);
   wPath:=APath;
   {$IFDEF WINCE}
   wCmdLine:=ACmdLine;
   if (ACmdLine='') then pwcCmdLine:=nil else pwcCmdLine:=PWideChar(wCmdLine);
   Result:=CreateProcess(PWideChar(wPath), pwcCmdLine, nil, nil, False, CREATE_NEW_CONSOLE, nil, nil, nil, pi);
   if Result then
   begin
     CloseHandle(pi.hThread);
     CloseHandle(pi.hProcess);
   end;
   {$ELSE}
   {Result:=CreateProcess(PChar(APath), nil, nil, nil, False, CREATE_NEW_PROCESS_GROUP, nil, nil, @si, @pi);}
   {$ENDIF}
end;

{ TMMCCore }

procedure TMMCCore.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if (CheckTask('explorer.exe')=0) and (SinglePlayerSettings.altmenu='') then LaunchProcess('explorer.exe');
end;

procedure TMMCCore.checkpidtimerTimer(Sender: TObject);
begin
  MMCCore.hide;
  LoadingGUI.hide;
  if fileexists(ExtractFilePath(ParamStr(0))+'PID')=false then
   begin
    SinglePlayer.PlayerExit;
    MMCCore.checkpidtimer.Enabled:=false;
   end;
  singleplayerGUI.pubtracktitle.Caption:=ansitoutf8(delbanner(artist+title));
  senderstr(delbanner(artist+title));
end;

procedure TMMCCore.FormCreate(Sender: TObject);
begin
  Left:=0;
  Top:=0;
  width:=800;
  height:=480;
  Color:=clBlack;
end;

function EnumProc (Wd: HWnd; Param: LongInt): Boolean; stdcall; // Обязательно stdcall !!!
Var
    Nm:Array[0..255] of wideChar;  // буфер для имени
Begin
    GetWindowText(Wd,Nm,255); // считываем  текст заголовка окна

      if (string(Nm)='Start') and (MMCCore.Handle<>wd) and (param=1) then        {показать окно}
       begin
         if CheckTask('explorer.exe')=1 then killtask('explorer.exe');
         ShowWindow(fd, SW_show);
         PostMessage(fd,WM_IMCOMMAND,0,0);
         setforegroundwindow(fd);
         halt(0);
       end;

    EnumProc := TRUE;  // продолжать искать окна…
end;

procedure GetTap;
begin
  ButtonTime:=GetTickCount();
  if (Abs(ButtonTime-ButtonTimeOld)<LongTapTime) then
  begin
    ShortTap:=True;
    if (Abs(ButtonTime-ButtonTimeOld)<BtnDelay) then Sleep(BtnDelay);
  end
  else ShortTap:=False;
end;

procedure SleepAndProcess(X: DWord);
var CurrentTick: DWord;
begin
  CurrentTick:=GetTickCount();
  while ((GetTickCount()-CurrentTick)<=X) do Application.ProcessMessages; // Sleep, но с обработкой сообщений
end;

end.

