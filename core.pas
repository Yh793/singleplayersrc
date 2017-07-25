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

type
TIniMas = array of string;

var
  MMCCore: TMMCCore;
  FS, FSnapshotHandle: THandle;
  FP, FProcessEntry32: TProcessEntry32;
  Co:boolean;
  fd,ButtonTimeOld,ButtonTime:integer;
  pi: TPROCESSINFORMATION;
  ShortTap:boolean;


procedure RunSaver;
function KillTask (ExeFileName: string): Integer;
function LaunchProcess(const APath: String; ACmdLine: String = ''): Boolean;
function EnumProc (Wd: HWnd; Param: LongInt): Boolean; stdcall;
procedure GetTap;
procedure IniSelectSection(var IniMas: TIniMas; Section: String; var SFrom: Integer; var STo: Integer);
function IniReadInteger(var IniMas: TIniMas; Section, Value: String; Def: Integer; SFrom: Integer = 0; STo: Integer = 0): Integer;
function IniReadString(var IniMas: TIniMas; Section, Value, Def: String; SFrom: Integer = 0; STo: Integer = 0): String;
procedure LoadIni (Path: String; var IniMas: TIniMas);
function TrimGarbage(const S: String): String;
function TrimCommas(const S: String): String;


implementation

uses singleplayer, loading;

{$R *.lfm}


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
  singleplayerGUI.pubtracktitle.Caption:=ansitoutf8(delbanner(artist+'|'+title));
  senderstr(delbanner(artist+'|'+title));
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

function IniReadString(var IniMas: TIniMas; Section, Value, Def: String; SFrom: Integer = 0; STo: Integer = 0): String;
var I, StartI, EndI: Integer;
    FlagStart: Boolean;
    Header: String;
begin
  Result:=Def;
  FlagStart:=False;
  EndI:=Length(IniMas)-1;
  Header:='['+Section+']';
  if (EndI<1) then Exit;
  if (SFrom>0) then
  begin
    if (STo>SFrom) then
    begin
      FlagStart:=True;
      StartI:=SFrom;
      EndI:=STo;
    end;
  end
  else
  for I:=0 to Length(IniMas)-1 do
  begin
    if (Header=IniMas[I]) then
    begin
      FlagStart:=True;
      StartI:=I;
      Continue;
    end;
    if FlagStart then if (Length(IniMas[I])>0) then if (IniMas[I][1]='[') and (IniMas[I][Length(IniMas[I])]=']') then
    begin
      EndI:=I;
      Break;
    end;
  end;
  if FlagStart then for I:=StartI+1 to EndI do if (Pos(Value+'=',IniMas[I])=1) then
   begin
     Result:=System.Copy(IniMas[I],Pos('=',IniMas[I])+1,99999);
     Break;
   end;
   Result:=TrimCommas(TrimGarbage(Result));
end;

function IniReadInteger(var IniMas: TIniMas; Section, Value: String; Def: Integer; SFrom: Integer = 0; STo: Integer = 0): Integer;
begin
  Result:=StrToIntDef(IniReadString(IniMas, Section, Value, IntToStr(Def), SFrom, STo),Def);
end;

procedure IniSelectSection(var IniMas: TIniMas; Section: String; var SFrom: Integer; var STo: Integer);
var I, EndI: Integer;
    Header: String;
    FlagStart: Boolean;
begin
  EndI:=Length(IniMas)-1;
  STo:=EndI;
  SFrom:=0;
  Header:='['+Section+']';
  FlagStart:=False;
  if (EndI<1) then Exit;
  for I:=0 to Length(IniMas)-1 do
  begin
    if (Pos(Header,IniMas[I])>0) then
    begin
      FlagStart:=True;
      SFrom:=I;
      Continue;
    end;
    if FlagStart then if (Length(IniMas[I])>0) then if (IniMas[I][1]='[') and (IniMas[I][Length(IniMas[I])]=']') then
    begin
      STo:=I;
      Break;
    end;
  end;
  if (SFrom=0) then STo:=0;
end;

procedure LoadIni (Path: String; var IniMas: TIniMas);
var F: Text;
    CounterF: Integer;
begin
  SetLength(IniMas,0);
  try
    AssignFile(F,Path);
    Reset(F);
    CounterF:=0;
    while not EOF(F) do
    begin
      Inc(CounterF);
      SetLength(IniMas,CounterF);
      ReadLn(F,IniMas[CounterF-1]);
    end;
    CloseFile(F);
  except
  end;
end;

function TrimGarbage(const S: String): String;
const GarbageSymbols = [#0..' '];
var Ist, IEnd: Integer;
begin
  IEnd:=Length(S);
  while ((IEnd>0) and (S[IEnd] in GarbageSymbols)) do Dec(IEnd);
  ISt:=1;
  while ((ISt<=IEnd) and (S[ISt] in GarbageSymbols)) do Inc(ISt);
  Result:=Copy(S,ISt,1+IEnd-ISt);
end;

function TrimCommas(const S: String): String;
begin
  Result:=S;
  if Length(S)<2 then Exit;
  if ((S[1]='"') and (S[Length(S)]='"')) then Result:=Copy(S,2,Length(S)-2);
end;




end.

