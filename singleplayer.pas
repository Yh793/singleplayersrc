unit SinglePlayer;

{$mode objfpc}{$H+}


{$DEFINE SP_STANDALONE}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, windows,
  inifiles, strutils, ExtCtrls, StdCtrls, bass, bassflac, BASS_FX,bass_aac,bassalac,bass_mpc,Mp3FileUtils,
  ID3v2Frames, tags, contnrs, Core, loading, MMSystem{$IFDEF SP_STANDALONE}, Tlhelp32{$ENDIF};

const
  kolleff=30;     //максимальное количество полос + эффектов эквалайзера
  kollgenre=10;   //максимальное количество жанров эквалайзера
  kollbanner=1000; //максимальное количество строк файла баннерорезки
  kollskins=100; //максимальное количество скинов
  kolfilesfolders=10000; //максимальное количество файлов и каталогов
  kollwords=200; //максимальное количество слов языкового пакета
  allicons=500; //максимальное количество иконок в скине
  kolldisk=13; //максимальное количество дисков
  kollpls=20; //максимальное количество плейлистов
  kollshuff=50;  //количество запомненых номеров треков, переключенных вперед в разброс, для переключения треков назад в той же последовательности
  maxkeys=40; //максимальное количество клавиш в клавиатуре
  maxraskl=10; //максимальное количество раскладок клавиатуры

type
   TPlayerMode = (Stop, Play, Paused, Started, Closed, RadioPlay);

type

  { TSinglePlayerGUI }
    TFFTData  = array [0..512] of Single;
  TSinglePlayerGUI = class(TForm)
    PolSecondTimer:TTimer;
    PlayerTimer:TTimer;
    PeremotkaTimer:TTimer;
    pubtracktitle: TStaticText;
    vizualizationtimer:TTimer;
    scrolltimer:Ttimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormMouseDown(Sender: TObject; {%H-}Button: TMouseButton; {%H-}Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; {%H-}Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      {%H-}Shift: TShiftState; X, Y: Integer);
    procedure FormPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PolSecondTimerTimer(Sender: TObject);
    procedure PlayerTimerTimer(Sender: TObject);
    procedure PeremotkaTimerTimer(Sender: TObject);
    procedure vizualizationtimerTimer(Sender: TObject);
    procedure scrolltimerTimer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    procedure WndProc(var Msg: TMessage); override;
  end;

type
  typesettings = record
    ezf: array [1..kolleff,1..20] of string;   //значения полос и эффектов эквалайзера
    skin:string;    //название скина плеера
    skindir:string;  //путь к скинам плеера
    curentgenre:byte;   //текущий жанр эквалйзера
    curentplaylist:smallint;   //текущий плейлист
    kolltrack:word;        //количество треков в плейлисте
    playedtrack:word; //номер проигрываемого трека
    logmode:byte; //вкл/выкл режима подробного логирования
    langg:string;
    kolltrackbuf:word;
    shufflekey:byte;
    timerrevkey:byte;
    sorttrue:byte;
    curentvol:single{real};
    showcpu:byte;
    curpos:longint;
    savepos:byte;
    playone:byte;
    ciclepls:byte;
    repaintplayergui:smallint;
    autoeq:byte;
    showcoverpl:byte;
    eqon:byte;
    playfromgenre:byte;
    recadd:byte;
    perfeqexit:byte;
    znachcpueq:byte;
    znachcpueqmin:byte;
    perfeqon:byte;
    recone:byte;
    plavzvuk:byte;
    backzero:byte;
    startautoplay:byte;
    eqsetnow:byte;
    favoritfolder:string;
    peremotka:byte;
    mute:byte;
    scrollsmalltrack:byte;
    scrolltrack:byte;
    removebanner:byte;
    folderadd:byte;
    tracknomkol:byte;
    autousb:byte;
    activatemode:byte;
    vizon:byte;
    vizintensivitu:word;
    netbuffer:dword;
    netprebuffer:byte;
    nettimeout:word;
    netreadtimeout:longword;
    playerbuffer:word;
    playupdateperiod:word;
    changenetprebuffer:byte;
    changenettimeout:byte;
    changenetreadtimeout:byte;
    changeplayerbuffer:byte;
    changeplayupdateperiod:byte;
    track2str:byte;
    wheelone:byte;
    swipeon:byte;
    manyadd:byte;
    playaftchangepls:byte;
    SwipeAmount:byte;
    changevizint:byte;
    changenetbuffer:byte;
    inallpls:byte;
    closeaftadd:byte;
    searchintag:byte;
    altmenu:string;
    sortingallpls:byte;
    sysvolchange:byte;
    curentsysvol:word;
    playallpls:byte;
    bqflow:byte;
    bqfhigh:byte;
    bqfPEAKINGEQ:byte;
    bqfBANDPASS:byte;
    reverb:byte;
    echo:byte;
    chorus:byte;
    flanger:byte;
    tempo:byte;
    pitch:byte;
    compressor:byte;
    distortion:byte;
    phaser:byte;
    FREEVERB:byte;
    autowah:byte;
    bqfnotch:byte;
    readtags:byte;
    floatdsp:byte;
    netagent:string;
    playerfreq:byte;
    changeplayerfreq:byte;
    nomlang:byte;
    changelang:byte;
    lasturl:string;
  end;

type
  playerskinsettings  = record
    treeleft:smallint;
    treetop:smallint;
    treeleftsp:smallint;
    treetopsp:smallint;
    treetextsize:byte;
    treetextsizetree:byte;
    treeintervalhorz:smallint;
    treeintervalvert:smallint;
    treetype:byte;
    sortmode:smallint;
    treetextX:smallint;
    treetextY:smallint;
    treeintervalverttree:smallint;
    textinterval:smallint;
    explorertextfolder:integer;
    explorertextfiles:integer;
    tracktimeleft:string;
    tracktimetop:smallint;
    tracktimecolor:integer;
    tracktimesize:byte;
    timetrackleft:string;
    timetracktop:smallint;
    timetrackcolor:integer;
    timetracksize:byte;
    tracktitleleft:string;
    tracktitlewidth:smallint;
    tracktitletop:smallint;
    trackartisttitletop:smallint;
    tracktitlecolor:integer;
    tracktitlesize:byte;
    playedtrackleft:string;
    playedtracktop:smallint;
    playedtrackcolor:integer;
    playedtracksize:byte;
    cureqleft:string;
    cureqtop:smallint;
    cureqcolor:integer;
    cureqsize:byte;
    curvolleft:string;
    curvoltop:smallint;
    curvolcolor:integer;
    curvolsize:byte;
    curplsleft:string;
    curplstop:smallint;
    curplscolor:integer;
    curplssize:byte;
    playerdatetimesize:byte;
    playerdatetimetop:smallint;
    playerdatetimeleft:string;
    playerdatetimecolor:integer;
    curentdirleft:string;
    curentdirtop:smallint;
    curentdircolor:integer;
    curentdirsize:byte;
    curentdirplleft:string;
    curentdirpltop:smallint;
    curentdirplcolor:integer;
    curentdirplsize:byte;
    equpleft:smallint;
    equptop:smallint;
    eqdownleft:smallint;
    eqdowntop:smallint;
    eqftextleft:smallint;
    eqftexttop:smallint;
    eqftextcolor:integer;
    eqftextsize:byte;
    eqztextleft:smallint;
    eqztexttop:smallint;
    eqztextcolor:integer;
    eqztextsize:byte;
    eqsmeshX1:smallint;
    eqsmeshX2:smallint;
    eqsmeshY1:smallint;
    efsmeshX1:smallint;
    efsmeshY1:smallint;
    eqcurgenleft:string;
    eqcurgentop:smallint;
    eqcurgencolor:integer;
    eqcurgensize:byte;
    plsettextcolor:integer;
    plsetfillcolor:integer;
    plsettextsize:byte;
    plsettextleft:smallint;
    plsettexttop:smallint;
    plseticonsm:smallint;
    plsettextsmw:smallint;
    plsettextsmh:smallint;
    setchbsmh:smallint;
    coverinplayerleft:smallint;
    coverinplayertop:smallint;
    coverinzasleft:smallint;
    coverinzastop:smallint;
    coverscrwidth:smallint;
    coverscrheight:smallint;
    coverwidth:smallint;
    coverheight:smallint;
    progressbarcolor:integer;
    progressbarfoncolor:integer;
    progressbarwidth:smallint;
    progressbarleft:smallint;
    progressbartop:smallint;
    progressbarheight:smallint;
    progressbarfonshow:byte;
    progressbarshow:byte;
    progressbarvir:smallint;
    sp1peekcolor:integer;
    sp1barcolor:integer;
    sp1poscolor:integer;
    playlisttextr:smallint;
    playlisttextstr:string;
    chbsetpole:integer;
    bitratetrackleft:string;
    bitratetrackcolor:integer;
    bitratetracktop:smallint;
    bitratetracksize:byte;
    playlistkolltrack:smallint;
    plskolltrackinfocolor:integer;
    plskolltrackinfosize:byte;
    plskolltrackinfoleft:string;
    plskolltrackinfotop:smallint;
    plspagesinfotop:smallint;
    plspagesinfoleft:string;
    plspagesinfocolor:integer;
    plspagesinfosize:byte;
    playlisttextleft:string;
    playlisttexttop:smallint;
    playlisttextcolor:integer;
    playlisttextsize:byte;
    playlisttextnleft:string;
    playlisttextntop:smallint;
    playlisttextncolor:integer;
    playlisttextnsize:byte;
    playlistcurplsleft:string;
    playlistcurplstop:smallint;
    playlistcurplscolor:integer;
    playlistcurplssize:byte;
    noticonpolerigth:smallint;
    noticonpoleleft:smallint;
    deldiskiconsm:smallint;
    deliconsm:smallint;
    faviconsm:smallint;
    downiconsm:smallint;
    upiconsm:smallint;
    trackvertsm:smallint;
    deldisktracktop:smallint;
    deltracktop:smallint;
    favtracktop:smallint;
    downtracktop:smallint;
    uptracktop:smallint;
    vidtracktop:smallint;
    vidtrackheight:smallint;
    vidpltracktop:smallint;
    vidpltrackheight:smallint;
    vidtrackleft:smallint;
    vidtrackwidth:smallint;
    vidpltrackleft:smallint;
    vidpltrackwidth:smallint;
    vidplcolor:integer;
    vidcolor:integer;
    statustextsize:byte;
    statustextleft:string;
    statustexttop:smallint;
    statustextcolor:integer;
    spectr1left:smallint;
    spectr1top:smallint;
    spectr1width:integer;
    spectr1height:byte;
    spectr1kolbar:byte;
    spectr1prbar:byte;
    spectr1widthbar:byte;
    trackp:byte;
    vizpage:string;
    skinspistop:smallint;
    skinspisleft:smallint;
    skinspisvertsm:smallint;
    skinspishorsm:smallint;
    skinspisbottom:smallint;
    scanfolderstrleft:string;
    scanfolderstrtop:smallint;
    scanfolderstrtextsize:byte;
    scanfolderstrtextcolor:integer;
    xkey:smallint;
    ykey:smallint;
    keywidth:smallint;
    keyheight:smallint;
    keyras:smallint;
    keyboardcolor:integer;
    keyboardbordercolor:integer;
    nextryad:smallint;
    keycolor:integer;
    keybordercolor:integer;
    maxkeysinryad:byte;
    maxkolryad:byte;
    wordleft:smallint;
    wordtop:smallint;
    tracksearchcolor:integer;
    tracksearchbordercolor:integer;
    tracksearchpoleleft:smallint;
    tracksearchpoletop:smallint;
    tracksearchpolewidth:smallint;
    tracksearchpoleheight:smallint;
    tracksearchtextcolor:integer;
    tracksearchtextsize:byte;
    tracksearchleft:smallint;
    tracksearchtop:smallint;
    topfind:smallint;
    bottomfind:smallint;
    leftfind:smallint;
    vertrasfind:smallint;
    searchrespoleleft:smallint;
    searchrespoleright:smallint;
    searchrespoletop:smallint;
    searchrespolebottom:smallint;
    searchresentertextcolor:integer;
    searchresentertextsize:byte;
    searchresenterpolecolor:integer;
    searchresenterpolebordercolor:integer;
    topochered:smallint;
    bottomochered:smallint;
    ocheredtextcolor:integer;
    ocheredcolor:integer;
    ocheredtextsize:byte;
    ocheredbordercolor:integer;
    maxrighttree:smallint;
    ocheredstrtextcolor:integer;
    ocheredstrtextsize:byte;
    ocheredstrleft:smallint;
    ocheredstrtop:smallint;
    srcstrtextcolor:integer;
    srcstrtextsize:byte;
    srcstrleft:smallint;
    srcstrtop:smallint;
    keyboardleft:smallint;
    keyboardtop:smallint;
    keyboardwidth:smallint;
    keyboardheight:smallint;
    keytextcolor:integer;
    keytextsize:byte;
    searchrestextcolor:integer;
    searchrestextsize:byte;
    searchresbordercolor:integer;
    searchrescolor:integer;
    mainformwidth:smallint;
    mainformheight:smallint;
    mainformleft:smallint;
    mainformtop:smallint;
    scanstatustextleft:smallint;
    scanstatustexttop:smallint;
    scanstatustextsize:byte;
    scanstatustextcolor:integer;
    effectlampleft:smallint;
    effectlamptop:smallint;
    effectlampwidth:smallint;
    effectlampheight:smallint;
    effectlampangleX:smallint;
    effectlampangleY:smallint;
    effectlampbordercoloroff:integer;
    effectlampcoloroff:integer;
    effectlampbordercoloron:integer;
    effectlampcoloron:integer;
    effectpagetextcolor:integer;
    effectpagetextsize:byte;
    eqwgeelsmX:smallint;
    eqwgeelsmY:smallint;
    bottomtree:smallint;
    bottomsetka:smallint;
    maxrightsetka:smallint;
    recttrackcolor:integer;
  end;

type
  typeicons = record
    left:smallint;
    top:smallint;
    width:smallint;
    height:smallint;
    caption:string;
    typeicon:string;
    exec:string;
    execopt:string;
    visible:string;
    text:string;
    textleft:string;
    texttop:smallint;
    textsize:byte;
    textcolor:integer;
    textcolorclick:integer;
    clickiconcaption:string;
    textautosize:string;
    maxright:smallint;
    minleft:smallint;
    textbold:string;
    textitalic:string;
    Zpriority:byte;
end;

type                         //поток сортировки
 sortingp = class(TThread)
 private
   { Private declarations }
 protected
   procedure Execute; override;
 end;

type                         //поток добавления трека в плейлсит
 addtrackp = class(TThread)
 private
   { Private declarations }
 protected
   procedure Execute; override;
 end;

type                        //поток добавления треков с подкаталогами в плейлсит
 addtrackfolderp = class(TThread)
 adir:string;
 private
   { Private declarations }
 protected
   procedure Execute; override;
 end;

 type                        //поток добавления треков из выбранных каталогов
 addmarkedp = class(TThread)
 private
   { Private declarations }
 protected
   procedure Execute; override;
 end;

 type                        //поток добавления треков из выбранных каталогов
 findmarkedp = class(TThread)
 findddir:string;
 private
   { Private declarations }
 protected
   procedure Execute; override;
 end;

type                    //поток записи параметров эквалайзера
 eqwritep = class(TThread)
 private
   { Private declarations }
 protected
   procedure Execute; override;
 end;

type
 loadcaverp = class(TThread)
 private
  { Private declarations }
 protected
 procedure Execute; override;
end;


 type
 connectradiop = class(TThread)
 radiourlp:string;
 private
  { Private declarations }
 protected
 procedure Execute; override;
end;


Procedure SetBeginPlayer;       //установка начальных значений переменных
Procedure LoadPlayerSettings;   //считываем настройки плеера
Procedure LoadPlayerSkin(mode:byte);       //считываем иконки и параметры скина
Procedure LogAndExitPlayer(str:string;showmess:byte;closeplayer:byte);  //записать ошибку в файл лога, показать сообщение об ошибку, закрыть плеер
Procedure WritePlayerSettings;  //записать настройки плеера в ini файл
procedure playlistread(curpl:integer); //считываем плейлист
procedure LoadIconPlayer;  //загружаем иконки плеера
procedure BigLog(str:string);  //Подробный вывод информации
function myalign(alstr:string; strmarker:string; typestring:integer):integer; //выравнивание текста
function uprstr(str:string):string; //список динамических переменных
function paintstr(str:string):string;  //присваивание значений динамическим переменным
procedure paintplayericon(cpg:string);   //рисуем иконки плеера
procedure paintplayericonZprioryty(cpg:string); //рисуем иконки над текстом страниц
procedure PaintSwitchers; //рисуем переключатели в зависимотси от значения переключателя
function setvisfromexec(iconexec:string; vis:string):string;  //установка видимости иконки, по выполняемой команде
function getindexfromtext(texticon:string):integer;   //поиск номера иконки, по ее подписи
function getindexiconexecopt(iconexecopt:string):integer;    //поиск номера иконки, по параметру выполняемой команде
function getindexiconexec(iconexec:string):integer;     //поиск номера иконки, по выполняемой команде
function getindexicon(iconcaption:string):integer;  //поиск номера иконки, по названию файла
function RealToStr(X: Double; Digits: Integer): string; //переводим строку в вещественное число
procedure SinglePlayerStart; //запуск плеера
procedure PlayerExit;  //выход из плеера
function SearchString(const FindStr, SourceString: string; Num: Integer):Integer;  {поиск подстроки с указанием количества позиций}
procedure QsString(var item: array of string; count:integer);   {метод быстрой сортировки}
procedure saveplaylist; //сохранение плейлиста
function gettrackindexbuf(trackcaption:string):integer; //найти номер проигрываемого трека в буферном массиве треков
function gettrackindex(trackcaption:string):integer; //найти номер проигрываемого трека в массиве треков
function getgenreindex(genre:string):integer; //найти номер жанра по названию
function PosR2L(const FindS, SrcS: string): Integer; //обратный поиск по строке
procedure sortplaylistthead; //запуск потока сортировки плейлиста
procedure EnumFolders(aDir:string; const aArrExt:array of string; var filep:textfile; modeadd:byte);  //поиск каталогов
procedure EnumFiles(aDir:string; const aArrExt:array of string; var filep:textfile; modeadd:byte);    //поиск файлов
procedure startaddtrackfolder(curdir:string); //запуск потока добавления треков с подкаталогами
function delbadtext(textstr:string):string;
procedure playertimercode; //выполняется при проигрывании трека раз в секунду
procedure key8(klperorper:integer);
procedure speedplay; //запуск перемотки
procedure playnexttrack; //переключить на следующий трек
procedure playprevtrack;
procedure playnextfolder; //переключить на следующую папку (или +10 треков)
procedure playprevfolder;
procedure SendCopyData(hTargetWnd: HWND; ACopyDataStruct:TCopyDataStruct); //формируем строку для отправки окнам
procedure senderstr(strsnd:ansistring); //отправляем окнам сформированную строку
procedure setplaypos(progresspos:integer); //указать позицию воспроизведения
procedure delfromdisk(plstrack:string);  //удалить трек с диска
procedure favtopls(plstrack:string); //добавить трек в избранное
procedure delfrompls(plstrack:string); //удалить трек из плейлиста
procedure favtoplsandfolder(plstrack:string); //добавить трек в избранное и в отдельную папку
procedure MyFileCopy(Const SourceFileName, TargetFileName: string);  //копировать треки
procedure playusb(usbd:string; addmode:byte);  //играть найденный юсб накопитель {addmode 0 создать, 1 добавить плейлист}
procedure IRadioStart;    //страница интернет радио в плеере
procedure SingleStopPlay; //пауза плеера
procedure itelmastop; //остановить проигрывание трека
procedure itelmaplay(musictrack:string); //проиграть трек
procedure iradioplay(radiourl:string);   //проиграть url
procedure gettree(disk:string; nfindex:integer); //отобразить дерево каталогов и файлов
function strInArray(value:string) : Boolean;
procedure createTreeObjects(disk:string; bufName:string; index:integer; marked:integer); // создание объектов дерева (папок и файлов)
procedure saveeq; //сохраняем значения эквалайзера для всех пресетов
procedure exptree;    //отображать файлы и папки в виде списка
procedure expsetka;   //отображать файлы и папки в виде сетки
procedure sortabc;    //сортировать файлы и папки в алфавитном порядке
procedure sortdate;   //сортировать файлы и папки по дате (сначала старые)
procedure sortdateinv;   //сортировать файлы и папки по дате (сначала новые)
procedure nextpls;
procedure prevpls;
procedure timetracknap;
procedure volup;
procedure voldown;
procedure sysvolup;
procedure sysvoldown;
procedure folderaddon;
procedure folderaddoff;
procedure cicleplson;
procedure cicleplsoff;
procedure muteon;
procedure muteoff;
procedure plsclear;
procedure plsetread;
procedure plsetapply;
procedure playersettings;
procedure generalsetpl;
procedure playlistset;
procedure soundsetpl;
procedure plsetperf;
procedure playerfaceset;
procedure trackdown(plstrack:integer);
procedure trackup(plstrack:integer);
procedure msgdel;
procedure msgfav;
procedure eqclear;
procedure genrer;
procedure genrel;
procedure exponefolder;
procedure expmanyfolder;
procedure exponefile;
procedure eqvk;
procedure eqoff;
Procedure runprog(var progr:string; options:string);
procedure eqapply(chan:DWORD);
procedure ShowPicture(Index: Integer);
procedure eq;
procedure playlist;
procedure msgflashadd(usbstr:string);
procedure setautoeq(genrebyte:byte);
function delbanner(trackbanner:string):string;
procedure itelmaplayertext;
procedure itelmaprogressbar(itchan:DWORD);
function findrandom(trackn:integer):integer;
function setvisfromname(iconname:string; vis:string):string;
procedure spectrum(FFTData : TFFTData; X, Y : Integer);
procedure startvizual;
procedure reloadcfg;
procedure plsetskin;
procedure skinchangepaint;
procedure setskinmsg(workskin:string);
procedure setskin(skinname:string);
procedure wheeloneoff;
procedure wheeloneon;
procedure getkollstr;
procedure manyaddon;
procedure manyaddoff;
procedure manyaddstart;
procedure clearmanymass;
procedure keyboardtext;
procedure readallplstrack;
procedure addtonext(nexttrack:integer);
function gettagtofind(track:string): string;
procedure formtagmass(mode:byte);
function GetDate : string;
procedure setinitbass;
procedure setsystvol(sysvol:word);
procedure randomizepls;
function findrandompls:integer;
function findpls(nach:integer; nap:byte):integer;
procedure addtonextall;
procedure effectedit(eff:string);
procedure effecton(eff:string);
procedure effectoff(eff:string);
function setvisfromexecopt(iconexecopt:string; vis:string):string;
function coordfromfreq(freq:integer):integer;
function freqfromcoord(coord:integer):integer;
function map(val,x1,x2,y1,y2:integer):integer;
function RealToInt(X: Double; Digits: Integer): integer;
function znachfromcoord(coord,razr,x1,x2:integer):single;
function coordfromznach(bandw:single; razr,x1,x2:integer):integer;
procedure eqmove(x,y,i:integer);
procedure effectpagetext;
function findseleffect (x,y:integer; effstr:string):boolean;
function coordeqwheel(zyacheq:integer):integer;
function znacheqwgeel(coord:integer):integer;
function BASSGetBitRate(handle : Cardinal) : DWORD;
function getnettag:string;
procedure RadioStreamDisconnected;
procedure playm3upls(m3uplsstr:string);
procedure loadlang;
function getfromlangpack(langtext:string):string;
procedure SinglePlay;
{$IFDEF SP_STANDALONE}
procedure checkexplorer;
function CheckTask (ExeFileName: string): Integer;
function LoadBMP(Path: String): HBITMAP;
{$ENDIF}


var
  SinglePlayerGUI: TSinglePlayerGUI;
  TextStyle: TTextStyle;
  curentpage,SinglePlayerDir,curenttrack,curworkusb,playerversion,napr,curworktrack,oldpage,curentradio,curentdir,cpuinfo,artist,title,bitratestr,tstr,timetrack,
  strpos,curpldir,strcureq,strkolcurtr,curvol,scrolltitle,artisttitle,curworkskin,skinname,skinauthor,skinversion,timeinicon,scrolltitlestr,scrolltitle2,
  dateinicon,scanningstr,tracksearchstr,playerversionstr,effectstr,radioimage,conradiostr:string;
  SinglePlayerSettings:typesettings;  //переменные настроек плеера
  plset:playerskinsettings;               //переменные скина плеера
  seticons: array [1..allicons] of typeicons; //переменные настроек иконки скина
  flashword: array of array of string; //массив слов языкового пакета
  playericon,clickplayericon: array [1..allicons] of graphics.TBitmap;
  AllowStartPlayer,msgtap,playlistadd,startnextbut,schetperemotka,stopspeed,prblock,clicknext,clickprev,loadiconkl,plsett,playadded,
  errorplay,coverloaded,radiocoverloaded,saveeqkl,genreb,sk,powerup,mousestate,getkollpagekey,kolfilefolder,enumworked,keyboardmode,nextplayplsshow,kollraskl,lastpls,itfolder,
  wait,tempfreq,fileispls,findl:byte;
  genremass: array [1..100,1..kolleff+1] of string;
  bannermass: array [1..kollbanner] of string;
  skinmass: array [1..kollskins] of string;
  playerfreqmas: array [1..14] of longword;
  mmcdisks: array [1..kolldisk] of string[15];
  FFTPeacks  : array [0..50] of Integer;
  FFTFallOff : array [0..50] of Integer;
  progresscor: array [1..100,1..4] of smallint; //координаты прогрессбара
  track: array [1..kolfilesfolders] of string;      //массив с треками
  trackbuf: array [1..kolfilesfolders] of string;   //буферная копия массива треков
  startplaymass: array [1..kolfilesfolders] of string;
  playedtrack: array [1..kolfilesfolders] of word;
  temptrackmas: array [1..kolfilesfolders] of string;
  fdirmass: array [1..kolfilesfolders] of string;
  pospage: array [1..kolfilesfolders] of word;
  keysmass: array [1..maxkeys,1..maxraskl+4] of string;
  findtrackcor: array [1..kolfilesfolders,1..5] of integer;
  folders: array of array of ansistring;
  allplstrack: array of record Track: string; Playlist, Number: Integer end;
  tagmass: array of array of string;
  m3uplsmass: array of array of string;
  nextplaytrackmass: array of string;
  plsettingsznach: array [1..11,1..11] of string;
  plsettingsmass: array [1..11,1..11] of string;
  eqfcor:array [1..kolleff,1..8] of smallint;
  plsettingscor: array [1..10,1..4] of smallint;
  skincor: array [1..kollskins,1..4] of smallint;
  plstrackcor: array [1..kolfilesfolders,1..24] of smallint;
  plscurtrackpos: array [1..kollpls,1..2] of longint;
  shuffmass: array [1..kollshuff] of word;
  bn,threadkoltrack,allkolltrack,clickedicon,nextpageindex,pageindex,kollpage,playlistferstopen,nachpls,konpls,ee,itsicon,pr,pr2,pr3,pr4,
  curentgenre,npltr,curposfp,shuffindex,tempY,tempX,moveexit,tempallkolltrack,exityes,fdir,entertrack,finded,nachfind,finded2,top1,top2,top3,top4,top5,top6,
  radioerror,connecting:smallint;
  statusplaylist:byte; // ключ состояния операций с плейлистом 0 - свободен, 6 - чтение,7 - сортировка, 2 - запись,1-добавить трек
  mode:TPlayerMode; //статус состояния плеера
  sorting:sortingp;
  addtrack:addtrackp;
  eqwrite:eqwritep;
  loadcaver:loadcaverp;
  addtrackfolder:addtrackfolderp;
  addmarked:addmarkedp;
  findmarked:findmarkedp;
  connectradio:connectradiop;
  WM_IMCOMMAND:dword;
  msgfavX,msgfavX2,msgfavX3,msgfavX4,msgfavY,msgfavY2,msgfavY3,msgfavY4,msgdelX,msgdelY,msgdelX2,msgdelY2,msgaddflashstrleftX,msgaddflashstrleftX2,
  msgaddflashstrleftY,msgaddflashstrleftY2,msgaddflashstrrgX,msgaddflashstrrgX2,msgaddflashstrrgY,msgaddflashstrrgY2,msgaddflashbt1X,msgaddflashbt1X2,
  msgaddflashbt1Y,msgaddflashbt1Y2,msgaddflashbt2X,msgaddflashbt2X2,msgaddflashbt2Y,msgaddflashbt2Y2,
  msgskinchangeleftX,msgskinchangeleftY,msgskinchangeleftX2,msgskinchangeleftY2: smallint;
  tempmutevol,tempvol:single;
  tagm:^TAG_ID3;
  thisTagV2: TID3v2Tag;
  PictureFrames: TObjectList;
  coverimg,coverimgot: TJPEGImage;
  PI: TProcessInformation;
  fx: array[1..13] of integer;
  TrackPos,ValPos: double;
  curplspage,kolplspage,allsearchedtrack,kollnexttrack,timestartplay:integer;
  AfterSwipe:byte;
  chinfo: BASS_CHANNELINFO;
  Progress:DWORD;
  lastradiourl:string;
  prewskin,coverimgRadio,coverimgotRadio:graphics.TBitmap;
  Channel,RadioChannel,fxbqflow,fxbqfhigh,fxbqfPEAKINGEQ,fxbqfBANDPASS,fxreverb,fxecho,fxchorus,fxflanger,fxcompressor,fxdistortion,fxphaser,fxFREEVERB,fxautowah,fxbqfnotch: DWORD;
  bqflowparam,bqfhighparam,bqfPEAKINGEQparam,bqfBANDPASSparam,bqfnotchparam:BASS_BFX_BQF;
  reverbparam:BASS_DX8_REVERB;
  echoparam:BASS_DX8_ECHO;
  chorusparam:BASS_DX8_CHORUS;
  compressorparam:BASS_BFX_COMPRESSOR2;
  phaserparam:BASS_BFX_phaser;
  FREEVERBparam:BASS_BFX_FREEVERB;
  autowahparam:BASS_BFX_autowah;
  flangerparam:BASS_DX8_flanger;
  distortionparam:BASS_DX8_distortion;
  p: array [1..13] of BASS_DX8_PARAMEQ;
  SkinSettingsIniMas:array of String;
  SP_SettIniMas: TIniMas;
  SP_SkinIniMas: array[0..allicons] of TIniMas;
  PlayerSettingsINI:TIniFile;

implementation

{$R *.lfm}

{ TSinglePlayerGUI }

procedure TSinglePlayerGUI.FormCreate(Sender: TObject);

begin
 LoadingGUI.LabelText.Caption:='Загрузка SinglePlayer: Создание формы плеера';
 LoadingGUI.LabelText.Refresh;
 SinglePlayerGUI.BorderIcons:=SinglePlayerGUI.BorderIcons+[biMinimize,biMaximize];
 SinglePlayerGUI.BorderStyle:=bsNone;      //убираем рамку с формы
 SinglePlayerGUI.Caption:='SinglePlayer';  //заголовок формы плеера
 {$IFDEF WInCE}
 SinglePlayerGUI.Cursor:=crnone;     //убираем курсор с формы плеера
 {$ENDIF}
 SinglePlayerGUI.DoubleBuffered:=true;  //включаем двойную буфферизацию для плавного отображения картинок
 SinglePlayerGUI.KeyPreview:=true;   //включает ловушку нажатий клавиш
 SinglePlayerGUI.Invalidate;   //перерисовываем форму
 SinglePlayerGUI.Color:=$FFFFFF; //задаем цвет формы
 SinglePlayerGUI.Font.Quality:=fqClearType; //включаем сглаживание шрифтов
 LoadingGUI.LabelText.Caption:='Загрузка SinglePlayer: Обнуление переменных';
 LoadingGUI.LabelText.Refresh;
 SetBeginPlayer;              //установка начальных значений переменных
 LoadingGUI.LabelText.Caption:='Загрузка SinglePlayer: Чтение настроек плеера';
 LoadingGUI.LabelText.Refresh;
 PlayerSettingsINI:=TIniFile.Create(SinglePlayerDir+'playersettings.ini');  // инициализируем объект для работы с сохранениями
 PlayerSettingsINI.CacheUpdates:=True;
 LoadPlayerSettings;          //считываем настройки плеера
 LoadingGUI.LabelText.Caption:='Загрузка SinglePlayer: Загрузка языкового пакета';
 LoadingGUI.LabelText.Refresh;
 Loadlang;              //считываем иконки и параметры скина
 LoadingGUI.LabelText.Caption:=getfromlangpack('loadspskin');
 LoadingGUI.LabelText.Refresh;
 LoadPlayerSkin(0);              //считываем иконки и параметры скина
 SinglePlayerGUI.Width:=plset.mainformwidth;      //ширина формы плеера
 SinglePlayerGUI.Height:=plset.mainformheight;  //высота формы плеера
 SinglePlayerGUI.Left:=plset.mainformleft;      //положение слева формы плеера
 SinglePlayerGUI.Top:=plset.mainformtop;       //положение сверху формы плеера
 LoadingGUI.LabelText.Caption:=getfromlangpack('loadicons');
 LoadingGUI.LabelText.Refresh;
 LoadIconPlayer; //загружаем иконки плеера
end;

procedure TSinglePlayerGUI.FormShow(Sender: TObject);    //показать окно плеера
begin
 if AllowStartPlayer=0 then begin showmessage('Ошибка запуска плеера. Подробности в файле лога плеера'); PlayerExit; exit; end else
  begin
   if mode=closed then SinglePlayerStart;
  end;
  //{$IFDEF SP_STANDALONE}
  //setforegroundwindow(SinglePlayerGUI.Handle);
  //BringWindowToTop(SinglePlayerGUI.Handle);
  //SetWindowPos(SinglePlayerGUI.Handle,HWND_TOPMOST,0,0,0,0,SWP_NOMOVE+SWP_NOSIZE);
  //SinglePlayerGUI.SetFocus;
  //{$endif}
  senderstr('show');
end;

procedure LoadSP_SkinIniMas(Path: String);
var F: Text;
    CounterG, CounterL, Index: Integer;
    S, S1: String;
    SubMas, NoRead: Boolean;
begin
  try
    SubMas:=False;
    NoRead:=False;
    AssignFile(F,Path);
    Reset(F);
    CounterG:=0;
    index:=0;
    CounterL:=0;
    while not EOF(F) do
    begin
      if SubMas then
      begin
        Inc(CounterL);
        SetLength(SP_SkinIniMas[Index],CounterL);
        ReadLn(F,S);
        if Length(S)>0 then
        begin
          if (S[1]<>'[') then SP_SkinIniMas[Index][CounterL-1]:=S
          else
          begin
            SubMas:=False;
            NoRead:=True;
          end;
        end;
      end;
      if not SubMas then
      begin
        if not NoRead then
        begin
          Inc(CounterG);
          SetLength(SP_SkinIniMas[0],CounterG+1);
          ReadLn(F,S);
        end;
        NoRead:=False;
        if (Pos(';',S)=1) then
        begin
          Dec(CounterG);
          Continue;
        end;
        if (Pos('[icon',S)=0) then SP_SkinIniMas[0][CounterG-1]:=S
        else
        begin
          S1:=S;
          Delete(S1,1,5);
          Delete(S1,Length(S1),1);
          Index:=StrToInt(S1);
          CounterL:=1;
          SetLength(SP_SkinIniMas[Index],CounterL+1);
          SP_SkinIniMas[Index][0]:=S;
          SubMas:=True;
        end;
      end;
    end;
    CloseFile(F);
  except
  end;
end;


procedure setinitbass;
begin
   if (singleplayersettings.playerfreq<1) or (singleplayersettings.playerfreq>14) then tempfreq:=8 else tempfreq:=singleplayersettings.playerfreq;
   BASS_SetConfig(BASS_CONFIG_NET_PLAYLIST,2);
   BASS_SetConfig(BASS_CONFIG_FLOATDSP,singleplayersettings.floatdsp);    //включить обработку 32 бит;
   BASS_SetConfig(BASS_CONFIG_NET_PREBUF,0);
   if singleplayersettings.changenettimeout=1 then BASS_SetConfig(BASS_CONFIG_NET_TIMEOUT,singleplayersettings.nettimeout) else BASS_SetConfig(BASS_CONFIG_NET_TIMEOUT,10000);
   if singleplayersettings.changenetbuffer=1 then BASS_SetConfig(BASS_CONFIG_NET_BUFFER,singleplayersettings.netbuffer) else BASS_SetConfig(BASS_CONFIG_NET_BUFFER,10000);
   if singleplayersettings.changenetreadtimeout=1 then BASS_SetConfig(BASS_CONFIG_NET_READTIMEOUT,singleplayersettings.netreadtimeout) else BASS_SetConfig(BASS_CONFIG_NET_READTIMEOUT,0);
   if singleplayersettings.changeplayerbuffer=1 then BASS_SetConfig(BASS_CONFIG_BUFFER,singleplayersettings.playerbuffer) else BASS_SetConfig(BASS_CONFIG_BUFFER,200);
   if singleplayersettings.changeplayupdateperiod=1 then BASS_SetConfig(BASS_CONFIG_UPDATEPERIOD,singleplayersettings.playupdateperiod) else BASS_SetConfig(BASS_CONFIG_UPDATEPERIOD,100);
   BASS_SetConfigPtr( BASS_CONFIG_NET_AGENT, Pointer(singleplayersettings.netagent));
   if not BASS_Init(-1,playerfreqmas[tempfreq],BASS_DEVICE_FREQ,{$IFDEF WInCE}nil{$ELSE}0{$ENDIF},nil) then exit;
   BASS_PluginLoad ('bass_aac.dll', 0);
   BASS_PluginLoad ('bassflac.dll', 0);
   BASS_PluginLoad ('bass_fx.dll', 0);
   BASS_PluginLoad ('tags.dll', 0);
   BASS_PluginLoad ('bassalac.dll', 0);
   BASS_PluginLoad ('bass_mpc.dll', 0);
end;

procedure SinglePlayerStart;

begin
 {инициализация плеера}
 SinglePlayerGUI.PolSecondTimer.Enabled:=true;
 thisTagv2 := TID3v2Tag.Create;
 coverimg := TJPEGImage.Create;
 coverimg.Width:=0;
 coverimg.Height:=0;
 coverimgot := TJPEGImage.Create;
 coverimgot.Width:=0;
 coverimgot.Height:=0;
 coverimgRadio := graphics.tbitmap.Create;
 coverimgRadio.Width:=0;
 coverimgRadio.Height:=0;
 coverimgotRadio := graphics.tbitmap.Create;
 coverimgotRadio.Width:=0;
 coverimgotRadio.Height:=0;
 randomize;
 setinitbass;
 mode:=Started;
 if SinglePlayerSettings.startautoplay=1 then singlestopplay;
 SinglePlayerGUI.PlayerTimer.Enabled:=true;



end;

procedure TSinglePlayerGUI.FormKeyPress(Sender: TObject; var Key: char);
begin
  if (key=#114) or (key=#49) then reloadcfg;//R и 1
end;


Procedure SetBeginPlayer;     //установка начальных значений переменных

begin
 curentpage:='singleplayer';  //текущая страница для отрисовки на форме
 oldpage:='singleplayer';
 playerversion:='2.8.3'; {with mpc}
 SinglePlayerDir:=ExtractFilePath(ParamStr(0))+'SinglePlayer\';    //каталог с плеером
 AllowStartPlayer:=1;      //ключ отвечающий за возможность запуска плеера. 0 - запрещено, 1 - разрешено
 statusplaylist:=0; // разрешаем операции с плейлистами
 curenttrack:='';  // очищаем переменную проигрываемого трека
 curworkusb:='';   //очищаем переменную найденных дисков
 msgtap:=0; // убираем все всплывающие сообщения
 mode:=closed; //выставляем статус состояния плеера - выключен
 powerup:=0;
 curplspage:=0;
 kolplspage:=0;
 threadkoltrack:=1;
 AfterSwipe:=0;
 playlistferstopen:=0;
 loadiconkl:=0;
 plsett:=0;
 itsicon:=0;
 errorplay:=0;
 kollpage:=1;
 tempY:=0;
 tempX:=0;
 moveexit:=0;
 getkollpagekey:=0;
 mousestate:=0;
 itfolder:=0;
 fileispls:=0;
 artist:='';
 title:='';
 radioerror:=1;
 connecting:=0;
 timestartplay:=0;
 timeinicon:='';
 dateinicon:='';
 playerversionstr:='';
 radioimage:='';
 msgdelX:=-1;
 msgdelY:=-1;
 msgfavX:=-1;
 msgfavY:=-1;
 msgfavX3:=-1;
 msgfavY3:=-1;
 msgaddflashbt1X:=-1;
 msgaddflashbt1Y:=-1;
 msgaddflashbt2X:=-1;
 msgaddflashbt2Y:=-1;
 msgaddflashstrleftX:=-1;
 msgaddflashstrleftY:=-1;
 msgaddflashstrrgX:=-1;
 msgaddflashstrrgY:=-1;
 msgskinchangeleftX:=-1;
 coverloaded:=0;
 radiocoverloaded:=0;
 progresscor[1,1]:=0;
 SetLength(folders,10,7);
 tempallkolltrack:=0;
 exityes:=0;
 fdir:=0;
 pr:=1;  {pr pr2 обнуление прокрутки трека}
 pr2:=0;
 pr3:=1;
 pr4:=0;
 wait:=0;
 lastpls:=1;
 enumworked:=0;
 progress:=0;
 keyboardmode:=1;
 tracksearchstr:='';
 entertrack:=0;
 finded:=1;
 finded2:=1;
 nachfind:=1;
 allsearchedtrack:=0;
 nextplaytrackmass:=nil;
 kollnexttrack:=0;
 nextplayplsshow:=0;
 top1:=100;
 top2:=160;
 top3:=220;
 top4:=280;
 top5:=340;
 top6:=400;
 playerfreqmas[1]:=8000;
 playerfreqmas[2]:=11025;
 playerfreqmas[3]:=16000;
 playerfreqmas[4]:=22050;
 playerfreqmas[5]:=32000;
 playerfreqmas[6]:=37800;
 playerfreqmas[7]:=44056;
 playerfreqmas[8]:=44100;
 playerfreqmas[9]:=47250;
 playerfreqmas[10]:=48000;
 playerfreqmas[11]:=50000;
 playerfreqmas[12]:=50400;
 playerfreqmas[13]:=60000;
 playerfreqmas[14]:=65000;


 {---------------------- создаем секундный таймер -----------------------------}
 SinglePlayerGUI.PolSecondTimer:=TTimer.Create(SinglePlayerGUI);
 SinglePlayerGUI.PolSecondTimer.Enabled:=false;
 SinglePlayerGUI.PolSecondTimer.interval:=500;
 SinglePlayerGUI.PolSecondTimer.OnTimer:=@SinglePlayerGUI.PolSecondTimerTimer;
 {-----------------------------------------------------------------------------}
 {---------------------- создаем таймер плеера в режиме проигрывания-----------}
 SinglePlayerGUI.PlayerTimer:=TTimer.Create(SinglePlayerGUI);
 SinglePlayerGUI.PlayerTimer.Enabled:=false;
 SinglePlayerGUI.PlayerTimer.interval:=1000;
 SinglePlayerGUI.PlayerTimer.OnTimer:=@SinglePlayerGUI.PlayerTimerTimer;
 {-----------------------------------------------------------------------------}
 {---------------------- создаем таймер для перемотки трека -------------------}
 SinglePlayerGUI.PeremotkaTimer:=TTimer.Create(SinglePlayerGUI);
 SinglePlayerGUI.PeremotkaTimer.Enabled:=false;
 SinglePlayerGUI.PeremotkaTimer.interval:=500;
 SinglePlayerGUI.PeremotkaTimer.OnTimer:=@SinglePlayerGUI.PeremotkaTimerTimer;
 {-----------------------------------------------------------------------------}
  {---------------------- создаем таймер для визуализации   -------------------}
 SinglePlayerGUI.vizualizationTimer:=TTimer.Create(SinglePlayerGUI);
 SinglePlayerGUI.vizualizationTimer.Enabled:=false;
 SinglePlayerGUI.vizualizationTimer.interval:={$IFDEF WInCE}150{$ELSE}20{$ENDIF};
 SinglePlayerGUI.vizualizationTimer.OnTimer:=@SinglePlayerGUI.vizualizationTimerTimer;
 {-----------------------------------------------------------------------------}
 {---------------------- создаем таймер для прокрутки трека -------------------}
SinglePlayerGUI.scrollTimer:=TTimer.Create(SinglePlayerGUI);
SinglePlayerGUI.scrollTimer.Enabled:=false;
SinglePlayerGUI.scrollTimer.interval:=300;
SinglePlayerGUI.scrollTimer.OnTimer:=@SinglePlayerGUI.scrollTimerTimer;
{-----------------------------------------------------------------------------}
TextStyle.Clipping:=True;
TextStyle.Wordbreak:=False;
TextStyle.EndEllipsis:=True;


end;

Procedure LoadPlayerSettings;    //считываем настройки плеера
var
  eqfile,bannerfile:textfile;
  str:string;
  ngen,i,j,ll:integer;
  searchskin  : TSearchRec;
begin
{--------------------- читаем настройки плеера --------------------------------}
    LoadIni(SinglePlayerDir+'playersettings.ini',SP_SettIniMas);   //заводим ini переменную для хранения настроек плеера
    SinglePlayerSettings.skin:=IniReadString(SP_SettIniMas,'SinglePlayer','skin','default');
    SinglePlayerSettings.skindir:=IniReadString(SP_SettIniMas,'SinglePlayer','skindir','Skins\');
    SinglePlayerSettings.favoritfolder:=IniReadString(SP_SettIniMas,'SinglePlayer','favoritfolder','');
    SinglePlayerSettings.curentgenre:=IniReadInteger(SP_SettIniMas,'SinglePlayer','curentgenre',1);
    curentgenre:=SinglePlayerSettings.curentgenre;
    SinglePlayerSettings.curentplaylist:=IniReadInteger(SP_SettIniMas,'SinglePlayer','curentplaylist',1);
    SinglePlayerSettings.kolltrack:=IniReadInteger(SP_SettIniMas,'SinglePlayer','kolltrack',0);
    SinglePlayerSettings.playedtrack:=IniReadInteger(SP_SettIniMas,'SinglePlayer','playedtrack',1);
    SinglePlayerSettings.logmode:=IniReadInteger(SP_SettIniMas,'SinglePlayer','logmode',0);
    SinglePlayerSettings.shufflekey:=IniReadInteger(SP_SettIniMas,'SinglePlayer','shufflekey',0);
    SinglePlayerSettings.timerrevkey:=IniReadInteger(SP_SettIniMas,'SinglePlayer','timerrevkey',0);
    SinglePlayerSettings.curentvol:=IniReadInteger(SP_SettIniMas,'SinglePlayer','curentvol',10);
    SinglePlayerSettings.sorttrue:=IniReadInteger(SP_SettIniMas,'SinglePlayer','sorttrue',1);
    SinglePlayerSettings.showcpu:=IniReadInteger(SP_SettIniMas,'SinglePlayer','showcpu',0);
    SinglePlayerSettings.savepos:=IniReadInteger(SP_SettIniMas,'SinglePlayer','savepos',1);
    SinglePlayerSettings.curpos:=IniReadInteger(SP_SettIniMas,'SinglePlayer','curpos',-1);
    SinglePlayerSettings.playone:=IniReadInteger(SP_SettIniMas,'SinglePlayer','playone',0);
    SinglePlayerSettings.ciclepls:=IniReadInteger(SP_SettIniMas,'SinglePlayer','ciclepls',1);
    SinglePlayerSettings.repaintplayergui:=IniReadInteger(SP_SettIniMas,'SinglePlayer','repaintplayergui',0);
    SinglePlayerSettings.kolltrackbuf:=IniReadInteger(SP_SettIniMas,'SinglePlayer','kolltrackbuf',0);
    SinglePlayerSettings.showcoverpl:=IniReadInteger(SP_SettIniMas,'SinglePlayer','showcoverpl',1);
    SinglePlayerSettings.eqon:=IniReadInteger(SP_SettIniMas,'SinglePlayer','eqon',1);
    SinglePlayerSettings.playfromgenre:=IniReadInteger(SP_SettIniMas,'SinglePlayer','playfromgenre',0);
    SinglePlayerSettings.recadd:=IniReadInteger(SP_SettIniMas,'SinglePlayer','recadd',1);
    SinglePlayerSettings.perfeqexit:=IniReadInteger(SP_SettIniMas,'SinglePlayer','perfeqexit',0);
    SinglePlayerSettings.znachcpueq:=IniReadInteger(SP_SettIniMas,'SinglePlayer','znachcpueq',0);
    SinglePlayerSettings.znachcpueqmin:=IniReadInteger(SP_SettIniMas,'SinglePlayer','znachcpueqmin',0);
    SinglePlayerSettings.perfeqon:=IniReadInteger(SP_SettIniMas,'SinglePlayer','perfeqon',0);
    SinglePlayerSettings.recone:=IniReadInteger(SP_SettIniMas,'SinglePlayer','recone',0);
    SinglePlayerSettings.plavzvuk:=IniReadInteger(SP_SettIniMas,'SinglePlayer','plavzvuk',0);
    SinglePlayerSettings.backzero:=IniReadInteger(SP_SettIniMas,'SinglePlayer','backzero',1);
    SinglePlayerSettings.startautoplay:=IniReadInteger(SP_SettIniMas,'SinglePlayer','startautoplay',1);
    SinglePlayerSettings.eqsetnow:=IniReadInteger(SP_SettIniMas,'SinglePlayer','eqsetnow',1);
    SinglePlayerSettings.peremotka:=IniReadInteger(SP_SettIniMas,'SinglePlayer','peremotka',0);
    SinglePlayerSettings.mute:=IniReadInteger(SP_SettIniMas,'SinglePlayer','mute',0);
    SinglePlayerSettings.scrollsmalltrack:=IniReadInteger(SP_SettIniMas,'SinglePlayer','scrollsmalltrack',0);
    SinglePlayerSettings.scrolltrack:=IniReadInteger(SP_SettIniMas,'SinglePlayer','scrolltrack',0);
    SinglePlayerSettings.removebanner:=IniReadInteger(SP_SettIniMas,'SinglePlayer','removebanner',1);
    SinglePlayerSettings.folderadd:=IniReadInteger(SP_SettIniMas,'SinglePlayer','folderadd',1);
    SinglePlayerSettings.tracknomkol:=IniReadInteger(SP_SettIniMas,'SinglePlayer','playttracknomkolempo',0);
    SinglePlayerSettings.autousb:=IniReadInteger(SP_SettIniMas,'SinglePlayer','autousb',0);
    SinglePlayerSettings.activatemode:=IniReadInteger(SP_SettIniMas,'SinglePlayer','activatemode',0);
    SinglePlayerSettings.vizon:=IniReadInteger(SP_SettIniMas,'SinglePlayer','vizon',0);
    SinglePlayerSettings.vizintensivitu:=IniReadInteger(SP_SettIniMas,'SinglePlayer','vizintensivitu',500);
    SinglePlayerSettings.track2str:=IniReadInteger(SP_SettIniMas,'SinglePlayer','track2str',1);
    SinglePlayerSettings.wheelone:=IniReadInteger(SP_SettIniMas,'SinglePlayer','wheelone',0);
    SinglePlayerSettings.swipeon:=IniReadInteger(SP_SettIniMas,'SinglePlayer','swipeon',0);
    SinglePlayerSettings.manyadd:=IniReadInteger(SP_SettIniMas,'SinglePlayer','manyadd',0);
    SinglePlayerSettings.playaftchangepls:=IniReadInteger(SP_SettIniMas,'SinglePlayer','playaftchangepls',0);
    SinglePlayerSettings.SwipeAmount:=IniReadInteger(SP_SettIniMas,'SinglePlayer','SwipeAmount',2);
    SinglePlayerSettings.changevizint:=IniReadInteger(SP_SettIniMas,'SinglePlayer','changevizint',0);
    SinglePlayerSettings.changenetbuffer:=IniReadInteger(SP_SettIniMas,'SinglePlayer','changenetbuffer',0);
    SinglePlayerSettings.floatdsp:=IniReadInteger(SP_SettIniMas,'SinglePlayer','floatdsp',1);
    SinglePlayerSettings.netagent:=IniReadString(SP_SettIniMas,'SinglePlayer','netagent','SinglePlayer '+playerversion);
    SinglePlayerSettings.playerfreq:=IniReadInteger(SP_SettIniMas,'SinglePlayer','playerfreq',8);
    SinglePlayerSettings.inallpls:=IniReadInteger(SP_SettIniMas,'SinglePlayer','inallpls',0);
    SinglePlayerSettings.closeaftadd:=IniReadInteger(SP_SettIniMas,'SinglePlayer','closeaftadd',1);
    SinglePlayerSettings.searchintag:=IniReadInteger(SP_SettIniMas,'SinglePlayer','searchintag',0);
    SinglePlayerSettings.altmenu:=IniReadString(SP_SettIniMas,'SinglePlayer','altmenu','');
    SinglePlayerSettings.sortingallpls:=IniReadInteger(SP_SettIniMas,'SinglePlayer','sortingallpls',0);
    SinglePlayerSettings.sysvolchange:=IniReadInteger(SP_SettIniMas,'SinglePlayer','sysvolchange',0);
    SinglePlayerSettings.curentsysvol:=IniReadInteger(SP_SettIniMas,'SinglePlayer','curentsysvol',100);
    SinglePlayerSettings.playallpls:=IniReadInteger(SP_SettIniMas,'SinglePlayer','playallpls',0);
    SinglePlayerSettings.readtags:=IniReadInteger(SP_SettIniMas,'SinglePlayer','readtags',1);
    SinglePlayerSettings.netbuffer:=IniReadInteger(SP_SettIniMas,'SinglePlayer','netbuffer',10000);       {1..**}
    SinglePlayerSettings.netprebuffer:=IniReadInteger(SP_SettIniMas,'SinglePlayer','netprebuffer',75);   {1..100}
    SinglePlayerSettings.nettimeout:=IniReadInteger(SP_SettIniMas,'SinglePlayer','nettimeout',10000);     {1..**}
    SinglePlayerSettings.netreadtimeout:=IniReadInteger(SP_SettIniMas,'SinglePlayer','netreadtimeout',0); {1..**}
    SinglePlayerSettings.playerbuffer:=IniReadInteger(SP_SettIniMas,'SinglePlayer','playerbuffer',200);    {10..5000}
    SinglePlayerSettings.playupdateperiod:=IniReadInteger(SP_SettIniMas,'SinglePlayer','playupdateperiod',100); {5..100}
    SinglePlayerSettings.changenetprebuffer:=IniReadInteger(SP_SettIniMas,'SinglePlayer','changenetprebuffer',0);
    SinglePlayerSettings.changenettimeout:=IniReadInteger(SP_SettIniMas,'SinglePlayer','changenettimeout',0);
    SinglePlayerSettings.changenetreadtimeout:=IniReadInteger(SP_SettIniMas,'SinglePlayer','changenetreadtimeout',0);
    SinglePlayerSettings.changeplayerbuffer:=IniReadInteger(SP_SettIniMas,'SinglePlayer','changeplayerbuffer',0);
    SinglePlayerSettings.changeplayupdateperiod:=IniReadInteger(SP_SettIniMas,'SinglePlayer','changeplayupdateperiod',0);
    SinglePlayerSettings.changeplayerfreq:=IniReadInteger(SP_SettIniMas,'SinglePlayer','changeplayerfreq',0);
    SinglePlayerSettings.nomlang:=IniReadInteger(SP_SettIniMas,'SinglePlayer','nomlang',1);
    SinglePlayerSettings.changelang:=IniReadInteger(SP_SettIniMas,'SinglePlayer','changelang',0);
    curentdir:=IniReadString(SP_SettIniMas,'SinglePlayer','curentdir','');
    if singleplayersettings.startautoplay=1 then SinglePlayerSettings.lasturl:=IniReadString(SP_SettIniMas,'SinglePlayer','lasturl','') else SinglePlayerSettings.lasturl:='';

    if singleplayersettings.savepos=1 then
      begin
      for i:=1 to kollpls do
       begin
       if fileexists(SinglePlayerDir+'playlist_'+inttostr(i)+'.pls') then
        begin
          plscurtrackpos[i,1]:=IniReadInteger(SP_SettIniMas,'playlist_'+inttostr(i),'curtrack',1);
          plscurtrackpos[i,2]:=IniReadInteger(SP_SettIniMas,'playlist_'+inttostr(i),'curpos',-1);
        end;
       end;
      end;

{------------------------------------------------------------------------------}

   if SinglePlayerSettings.sysvolchange<>0 then setsystvol(SinglePlayerSettings.curentsysvol);

{------------------------ читаем настройки эквалайзера-------------------------}
  if fileexists(SinglePlayerDir+'eq.conf')=true then
    begin
     try
     assignfile(eqfile,SinglePlayerDir+'eq.conf');
     reset(eqfile);
     while not eof(eqfile) do
      begin
      readln(eqfile,str);
      if pos('eqgenre_',str)<>0 then
       begin
        ngen:=strtointdef(copy(str,pos('_',str)+1,pos(':',str)-pos('_',str)-1),1);
        genremass[ngen,1]:=copy(str,pos(':',str)+1,pos(';',str)-pos(':',str)-1);
        for i:=2 to kolleff+1 do
         begin
          delete(str,1,pos(';',str));
          genremass[ngen,i]:=copy(str,1,pos(';',str)-1)+'/';

          if SinglePlayerSettings.curentgenre = ngen then
            begin
            for j:=1 to kolleff do
              begin
                 ll:=1;
                 while pos('/',genremass[ngen,j+1])<>0 do
                  begin
                   SinglePlayerSettings.ezf[j,ll]:=copy(genremass[ngen,j+1],1,pos('/',genremass[ngen,j+1])-1);
                   delete(genremass[ngen,j+1],1,pos('/',genremass[ngen,j+1]));
                   inc(ll);
                end;
              end;
            end;

         end;
       end;
      end;
     closefile(eqfile);

 reset(eqfile);
  ll:=0;
  while not eof(eqfile) do
   begin
    readln(eqfile,str);
    inc(ll);
    genremass[ll,1]:=copy(str,pos(':',str)+1,length(str)-pos(':',str));
   end;
  closefile(eqfile);

     for i:=1 to 13 do
       begin
        p[i].fGain:=strtointdef(SinglePlayerSettings.ezf[i,1],0);
        p[i].fBandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[i,2],0);
        p[i].fCenter:=strtointdef(SinglePlayerSettings.ezf[i,3],0);
       end;
     bqflowparam.fCenter:=strtointdef(SinglePlayerSettings.ezf[20,1],0);
     bqfhighparam.fCenter:=strtointdef(SinglePlayerSettings.ezf[21,1],0);
     bqfPEAKINGEQparam.fCenter:=strtointdef(SinglePlayerSettings.ezf[22,1],0);
     bqfBANDPASSparam.fCenter:=strtointdef(SinglePlayerSettings.ezf[23,1],0);
     bqfnotchparam.fCenter:=strtointdef(SinglePlayerSettings.ezf[29,1],0);
     reverbparam.fInGain:=strtointdef(SinglePlayerSettings.ezf[14,1],0);
     echoparam.fWetDryMix:=StrToFloatdef(SinglePlayerSettings.ezf[15,1],0);
     chorusparam.fWetDryMix:=StrToFloatdef(SinglePlayerSettings.ezf[16,1],0);
     flangerparam.fWetDryMix:=StrToFloatdef(SinglePlayerSettings.ezf[17,1],0);
     compressorparam.fGain:=StrToFloatdef(SinglePlayerSettings.ezf[24,1],0);
     distortionparam.fGain:=StrToFloatdef(SinglePlayerSettings.ezf[25,1],0);
     phaserparam.fDryMix:=StrToFloatdef(SinglePlayerSettings.ezf[26,1],0);
     FREEVERBparam.fDryMix:=StrToFloatdef(SinglePlayerSettings.ezf[27,1],0);
     autowahparam.fDryMix:=StrToFloatdef(SinglePlayerSettings.ezf[28,1],0);

     bqflowparam.fgain:=strtointdef(SinglePlayerSettings.ezf[20,2],0);
     bqfhighparam.fgain:=strtointdef(SinglePlayerSettings.ezf[21,2],0);
     bqfPEAKINGEQparam.fgain:=strtointdef(SinglePlayerSettings.ezf[22,2],0);
     bqfBANDPASSparam.fgain:=strtointdef(SinglePlayerSettings.ezf[23,2],0);
     bqfnotchparam.fgain:=strtointdef(SinglePlayerSettings.ezf[29,2],0);
     reverbparam.fReverbMix:=strtofloatdef(SinglePlayerSettings.ezf[14,2],0);
     echoparam.fFeedback:=StrToFloatdef(SinglePlayerSettings.ezf[15,2],0);
     chorusparam.fDepth:=StrToFloatdef(SinglePlayerSettings.ezf[16,2],0);
     flangerparam.fDepth:=StrToFloatdef(SinglePlayerSettings.ezf[17,2],0);
     compressorparam.fAttack:=StrToFloatdef(SinglePlayerSettings.ezf[24,2],0);
     distortionparam.fEdge:=StrToFloatdef(SinglePlayerSettings.ezf[25,2],0);
     phaserparam.fWetMix:=StrToFloatdef(SinglePlayerSettings.ezf[26,2],0);
     FREEVERBparam.fWetMix:=StrToFloatdef(SinglePlayerSettings.ezf[27,2],0);
     autowahparam.fWetMix:=StrToFloatdef(SinglePlayerSettings.ezf[28,2],0);

     bqflowparam.fbandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[20,3],0);
     bqfhighparam.fbandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[21,3],0);
     bqfPEAKINGEQparam.fbandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[22,3],0);
     bqfBANDPASSparam.fbandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[23,3],0);
     bqfnotchparam.fbandwidth:=strtointdef(SinglePlayerSettings.ezf[29,3],0);
     reverbparam.fReverbTime:=StrTointdef(SinglePlayerSettings.ezf[14,3],0);
     echoparam.fLeftDelay:=StrToFloatdef(SinglePlayerSettings.ezf[15,3],0);
     chorusparam.fFeedback:=StrToFloatdef(SinglePlayerSettings.ezf[16,3],0);
     flangerparam.fFeedback:=StrToFloatdef(SinglePlayerSettings.ezf[17,3],0);
     compressorparam.fRelease:=StrToFloatdef(SinglePlayerSettings.ezf[24,3],0);
     distortionparam.fPostEQCenterFrequency:=StrToFloatdef(SinglePlayerSettings.ezf[25,3],0);
     phaserparam.fFeedback:=StrToFloatdef(SinglePlayerSettings.ezf[26,3],0);
     FREEVERBparam.fRoomSize:=StrToFloatdef(SinglePlayerSettings.ezf[27,3],0);
     autowahparam.fFeedback:=StrToFloatdef(SinglePlayerSettings.ezf[28,3],0);

     bqflowparam.fq:=StrToFloatdef(SinglePlayerSettings.ezf[20,4],0);
     bqfhighparam.fq:=StrToFloatdef(SinglePlayerSettings.ezf[21,4],0);
     bqfPEAKINGEQparam.fq:=StrToFloatdef(SinglePlayerSettings.ezf[22,4],0);
     bqfBANDPASSparam.fq:=StrToFloatdef(SinglePlayerSettings.ezf[23,4],0);
     bqfnotchparam.fq:=strtointdef(SinglePlayerSettings.ezf[29,4],0);
     reverbparam.fHighFreqRTRatio:=StrToFloatdef(SinglePlayerSettings.ezf[14,4],0);
     echoparam.fRightDelay:=StrToFloatdef(SinglePlayerSettings.ezf[15,4],0);
     chorusparam.fFrequency:=StrToFloatdef(SinglePlayerSettings.ezf[16,4],0);
     flangerparam.fFrequency:=StrToFloatdef(SinglePlayerSettings.ezf[17,4],0);
     compressorparam.fThreshold:=StrToFloatdef(SinglePlayerSettings.ezf[24,4],0);
     distortionparam.fPostEQBandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[25,4],0);
     phaserparam.fRate:=StrToFloatdef(SinglePlayerSettings.ezf[26,4],0);
     FREEVERBparam.fDamp:=StrToFloatdef(SinglePlayerSettings.ezf[27,4],0);
     autowahparam.fRate:=StrToFloatdef(SinglePlayerSettings.ezf[28,4],0);

     chorusparam.fDelay:=StrToFloatdef(SinglePlayerSettings.ezf[16,5],0);
     flangerparam.fDelay:=StrToFloatdef(SinglePlayerSettings.ezf[17,5],0);
     compressorparam.fRatio:=StrToFloatdef(SinglePlayerSettings.ezf[24,5],0);
     distortionparam.fPreLowpassCutoff:=StrToFloatdef(SinglePlayerSettings.ezf[25,5],0);
     phaserparam.fRange:=StrToFloatdef(SinglePlayerSettings.ezf[26,5],0);
     FREEVERBparam.fWidth:=StrToFloatdef(SinglePlayerSettings.ezf[27,5],0);
     autowahparam.fRange:=StrToFloatdef(SinglePlayerSettings.ezf[28,5],0);

     phaserparam.fFreq:=StrToFloatdef(SinglePlayerSettings.ezf[26,6],0);
     autowahparam.fFreq:=StrToFloatdef(SinglePlayerSettings.ezf[28,6],0);


     SinglePlayerSettings.distortion:=strtointdef(SinglePlayerSettings.ezf[30,1],0);
     SinglePlayerSettings.phaser:=strtointdef(SinglePlayerSettings.ezf[30,2],0);
     SinglePlayerSettings.FREEVERB:=strtointdef(SinglePlayerSettings.ezf[30,3],0);
     SinglePlayerSettings.autowah:=strtointdef(SinglePlayerSettings.ezf[30,4],0);
     SinglePlayerSettings.echo:=strtointdef(SinglePlayerSettings.ezf[30,5],0);
     SinglePlayerSettings.chorus:=strtointdef(SinglePlayerSettings.ezf[30,6],0);
     SinglePlayerSettings.flanger:=strtointdef(SinglePlayerSettings.ezf[30,7],0);
     SinglePlayerSettings.tempo:=strtointdef(SinglePlayerSettings.ezf[30,8],0);
     SinglePlayerSettings.compressor:=strtointdef(SinglePlayerSettings.ezf[30,9],0);
     SinglePlayerSettings.reverb:=strtointdef(SinglePlayerSettings.ezf[30,10],0);
     SinglePlayerSettings.pitch:=strtointdef(SinglePlayerSettings.ezf[30,11],0);
     SinglePlayerSettings.bqfhigh:=strtointdef(SinglePlayerSettings.ezf[30,12],0);
     SinglePlayerSettings.bqflow:=strtointdef(SinglePlayerSettings.ezf[30,13],0);
     SinglePlayerSettings.bqfBANDPASS:=strtointdef(SinglePlayerSettings.ezf[30,14],0);
     SinglePlayerSettings.bqfPEAKINGEQ:=strtointdef(SinglePlayerSettings.ezf[30,15],0);
     SinglePlayerSettings.bqfnotch:=strtointdef(SinglePlayerSettings.ezf[30,16],0);


     except
      LogAndExitPlayer('Ошибка считывания параметров эквалайзера',1,0);
      closefile(eqfile);
     end;
    end else
    begin

     for i:=1 to kollgenre do
      begin
       for j:=1 to kolleff+1 do genremass[i,j]:='';
      end;

    end;
{------------------------------------------------------------------------------}

{  ----------------- формируем массив банерорезки  --------------------------  }
try
if fileexists(SinglePlayerDir+'nobanner.txt')=true then
 begin
  bn:=1;      //сбрасываем счетчик строк баннеров
  assignfile(bannerfile,SinglePlayerDir+'nobanner.txt');
  reset(bannerfile);
  while not eof(bannerfile) do
   begin
    readln(bannerfile,bannermass[bn]);
    inc(bn);
   end;
  closefile(bannerfile);
 end;
except
 LogAndExitPlayer('Ошибка считывания файла баннеров',1,0);
 closefile(bannerfile);
end;
{------------------------------------------------------------------------------}
{------------------------ считываем досиупные скины ---------------------------}
  sk:=0; //сбрасываем счетчик найденых скинов
  if FindFirst(SinglePlayerDir+SinglePlayerSettings.skindir+'*', faDirectory, searchskin) = 0 then
   begin
    repeat
     if ((searchskin.attr and faDirectory) = faDirectory) and (searchskin.Name<>'.')  and (searchskin.Name<>'..')  and (searchskin.Name<>'') then
      begin
       inc(sk);
       skinmass[sk]:=searchskin.Name;
      end;
    until FindNext(searchskin) <> 0;
    SysUtils.FindClose(searchskin);
    if directoryexists(SinglePlayerDir+SinglePlayerSettings.skindir+singleplayersettings.skin) = false then singleplayersettings.skin:=skinmass[1];
   end;
{------------------------------------------------------------------------------}

{---------------------------- считываем плейлист-------------------------------}
 if SinglePlayerSettings.curentplaylist>0 then playlistread(SinglePlayerSettings.curentplaylist);
 curenttrack:=track[SinglePlayerSettings.playedtrack];
{------------------------------------------------------------------------------}

{------------------------------- поиск дисков ---------------------------------}
 if directoryexists('\StaticStore') then mmcdisks[1]:='\StaticStore' else mmcdisks[1]:='none';
 if directoryexists('\SDMMC') then mmcdisks[2]:='\SDMMC' else mmcdisks[2]:='none';
 if directoryexists('\Usb Disk') then mmcdisks[3]:='\Usb Disk' else mmcdisks[3]:='none';
 if directoryexists('\Usb Disk2') then mmcdisks[4]:='\Usb Disk2' else mmcdisks[4]:='none';
 if directoryexists('\Usb Disk3') then mmcdisks[5]:='\Usb Disk3' else mmcdisks[5]:='none';
 if directoryexists('\Usb Disk4') then mmcdisks[6]:='\Usb Disk4' else mmcdisks[6]:='none';
 if directoryexists('\Usb Disk5') then mmcdisks[7]:='\Usb Disk5' else mmcdisks[7]:='none';
 if directoryexists('\SDMMC2') then mmcdisks[8]:='\SDMMC2' else mmcdisks[8]:='none';
 if directoryexists('\SDMMC3') then mmcdisks[9]:='\SDMMC3' else mmcdisks[9]:='none';
 if directoryexists('\SDMMC4') then mmcdisks[10]:='\SDMMC4' else mmcdisks[10]:='none';
 if directoryexists('\UsbDisk') then mmcdisks[11]:='\UsbDisk' else mmcdisks[11]:='none';
 if directoryexists('\UsbDisk2') then mmcdisks[11]:='\UsbDisk2' else mmcdisks[12]:='none';
 if directoryexists('\UsbDisk3') then mmcdisks[11]:='\UsbDisk3' else mmcdisks[13]:='none';
{------------------------------------------------------------------------------}

{--------------------- проверяем возможность запуска плеера--------------------}
 if directoryexists(SinglePlayerDir) = false then
  begin
   LogAndExitPlayer('Каталог с плеером не найден',0,0);
   AllowStartPlayer:=0;
   exit;
  end;
 if directoryexists(SinglePlayerDir+SinglePlayerSettings.skindir)=false then
  begin
   LogAndExitPlayer('Каталог со скинами плеера не найден',0,0);
   AllowStartPlayer:=0;
   exit;
  end;
 if sk=0 then
  begin
   LogAndExitPlayer('Скины плеера не найдены',0,0);
   AllowStartPlayer:=0;
   exit;
  end;
 if AllowStartPlayer=0 then exit;    //если была ошибка, запретить запуск плеера
{------------------------------------------------------------------------------}
end;

Procedure WritePlayerSettings;    //записываем настройки плеера в ini файл
var
  i:integer;
begin
   PlayerSettingsINI.WriteString('SinglePlayer','skin',SinglePlayerSettings.skin);
   PlayerSettingsINI.WriteString('SinglePlayer','skindir',SinglePlayerSettings.skindir);
   PlayerSettingsINI.WriteString('SinglePlayer','lang',SinglePlayerSettings.langg);
   PlayerSettingsINI.WriteString('SinglePlayer','favoritfolder',SinglePlayerSettings.favoritfolder);
   PlayerSettingsINI.WriteInteger('SinglePlayer','curentplaylist',SinglePlayerSettings.curentplaylist);
   PlayerSettingsINI.WriteInteger('SinglePlayer','curentgenre',SinglePlayerSettings.curentgenre);
   PlayerSettingsINI.WriteInteger('SinglePlayer','kolltrack',SinglePlayerSettings.kolltrack);
   PlayerSettingsINI.WriteInteger('SinglePlayer','playedtrack',SinglePlayerSettings.playedtrack);
   PlayerSettingsINI.WriteInteger('SinglePlayer','logmode',SinglePlayerSettings.logmode);
   PlayerSettingsINI.WriteInteger('SinglePlayer','shufflekey',SinglePlayerSettings.shufflekey);
   PlayerSettingsINI.WriteInteger('SinglePlayer','timerrevkey',SinglePlayerSettings.timerrevkey);
   if SinglePlayerSettings.curentvol=0 then PlayerSettingsINI.Writefloat('SinglePlayer','curentvol',tempvol) else PlayerSettingsINI.Writefloat('SinglePlayer','curentvol',SinglePlayerSettings.curentvol);
   PlayerSettingsINI.WriteInteger('SinglePlayer','sorttrue',SinglePlayerSettings.sorttrue);
   PlayerSettingsINI.WriteInteger('SinglePlayer','showcpu',SinglePlayerSettings.showcpu);
   PlayerSettingsINI.WriteInteger('SinglePlayer','savepos',SinglePlayerSettings.savepos);
   PlayerSettingsINI.WriteInteger('SinglePlayer','curpos',SinglePlayerSettings.curpos);
   PlayerSettingsINI.WriteInteger('SinglePlayer','playone',SinglePlayerSettings.playone);
   PlayerSettingsINI.WriteInteger('SinglePlayer','ciclepls',SinglePlayerSettings.ciclepls);
   PlayerSettingsINI.WriteInteger('SinglePlayer','repaintplayergui',SinglePlayerSettings.repaintplayergui);
   PlayerSettingsINI.WriteInteger('SinglePlayer','kolltrackbuf',SinglePlayerSettings.kolltrackbuf);
   PlayerSettingsINI.WriteInteger('SinglePlayer','showcoverpl',SinglePlayerSettings.showcoverpl);
   PlayerSettingsINI.WriteInteger('SinglePlayer','eqon',SinglePlayerSettings.eqon);
   PlayerSettingsINI.WriteInteger('SinglePlayer','playfromgenre',SinglePlayerSettings.playfromgenre);
   PlayerSettingsINI.WriteInteger('SinglePlayer','recadd',SinglePlayerSettings.recadd);
   PlayerSettingsINI.WriteInteger('SinglePlayer','perfeqexit',SinglePlayerSettings.perfeqexit);
   PlayerSettingsINI.WriteInteger('SinglePlayer','znachcpueq',SinglePlayerSettings.znachcpueq);
   PlayerSettingsINI.WriteInteger('SinglePlayer','znachcpueqmin',SinglePlayerSettings.znachcpueqmin);
   PlayerSettingsINI.WriteInteger('SinglePlayer','perfeqon',SinglePlayerSettings.perfeqon);
   PlayerSettingsINI.WriteInteger('SinglePlayer','recone',SinglePlayerSettings.recone);
   PlayerSettingsINI.WriteInteger('SinglePlayer','plavzvuk',SinglePlayerSettings.plavzvuk);
   PlayerSettingsINI.WriteInteger('SinglePlayer','backzero',SinglePlayerSettings.backzero);
   PlayerSettingsINI.WriteInteger('SinglePlayer','startautoplay',SinglePlayerSettings.startautoplay);
   PlayerSettingsINI.WriteInteger('SinglePlayer','eqsetnow',SinglePlayerSettings.eqsetnow);
   PlayerSettingsINI.WriteInteger('SinglePlayer','peremotka',SinglePlayerSettings.peremotka);
   PlayerSettingsINI.WriteInteger('SinglePlayer','mute',SinglePlayerSettings.mute);
   PlayerSettingsINI.WriteInteger('SinglePlayer','scrollsmalltrack',SinglePlayerSettings.scrollsmalltrack);
   PlayerSettingsINI.WriteInteger('SinglePlayer','scrolltrack',SinglePlayerSettings.scrolltrack);
   PlayerSettingsINI.WriteInteger('SinglePlayer','removebanner',SinglePlayerSettings.removebanner);
   PlayerSettingsINI.WriteInteger('SinglePlayer','folderadd',SinglePlayerSettings.folderadd);
   PlayerSettingsINI.WriteInteger('SinglePlayer','tracknomkol',SinglePlayerSettings.tracknomkol);
   PlayerSettingsINI.WriteInteger('SinglePlayer','autousb',SinglePlayerSettings.autousb);
   PlayerSettingsINI.WriteInteger('SinglePlayer','activatemode',SinglePlayerSettings.activatemode);
   PlayerSettingsINI.WriteInteger('SinglePlayer','vizon',SinglePlayerSettings.vizon);
   PlayerSettingsINI.WriteInteger('SinglePlayer','vizintensivitu',SinglePlayerSettings.vizintensivitu);
   PlayerSettingsINI.WriteInteger('SinglePlayer','track2str',SinglePlayerSettings.track2str);
   PlayerSettingsINI.WriteInteger('SinglePlayer','wheelone',SinglePlayerSettings.wheelone);
   PlayerSettingsINI.WriteInteger('SinglePlayer','swipeon',SinglePlayerSettings.swipeon);
   PlayerSettingsINI.WriteInteger('SinglePlayer','manyadd',SinglePlayerSettings.manyadd);
   PlayerSettingsINI.WriteInteger('SinglePlayer','playaftchangepls',SinglePlayerSettings.playaftchangepls);
   PlayerSettingsINI.WriteInteger('SinglePlayer','SwipeAmount',SinglePlayerSettings.SwipeAmount);
   PlayerSettingsINI.WriteInteger('SinglePlayer','changevizint',SinglePlayerSettings.changevizint);
   PlayerSettingsINI.WriteInteger('SinglePlayer','changenetbuffer',SinglePlayerSettings.changenetbuffer);
   PlayerSettingsINI.WriteInteger('SinglePlayer','inallpls',SinglePlayerSettings.inallpls);
   PlayerSettingsINI.WriteInteger('SinglePlayer','closeaftadd',SinglePlayerSettings.closeaftadd);
   PlayerSettingsINI.WriteInteger('SinglePlayer','searchintag',SinglePlayerSettings.searchintag);
   PlayerSettingsINI.WriteInteger('SinglePlayer','sortingallpls',SinglePlayerSettings.sortingallpls);
   PlayerSettingsINI.WriteInteger('SinglePlayer','sysvolchange',SinglePlayerSettings.sysvolchange);
   PlayerSettingsINI.WriteInteger('SinglePlayer','curentsysvol',SinglePlayerSettings.curentsysvol);
   PlayerSettingsINI.WriteInteger('SinglePlayer','playallpls',SinglePlayerSettings.playallpls);
   PlayerSettingsINI.WriteInteger('SinglePlayer','readtags',SinglePlayerSettings.readtags);
   PlayerSettingsINI.WriteInteger('SinglePlayer','netbuffer',SinglePlayerSettings.netbuffer);
   PlayerSettingsINI.WriteInteger('SinglePlayer','netprebuffer',SinglePlayerSettings.netprebuffer);
   PlayerSettingsINI.WriteInteger('SinglePlayer','nettimeout',SinglePlayerSettings.nettimeout);
   PlayerSettingsINI.WriteInteger('SinglePlayer','netreadtimeout',SinglePlayerSettings.netreadtimeout);
   PlayerSettingsINI.WriteInteger('SinglePlayer','playerbuffer',SinglePlayerSettings.playerbuffer);
   PlayerSettingsINI.WriteInteger('SinglePlayer','playupdateperiod',SinglePlayerSettings.playupdateperiod);
   PlayerSettingsINI.WriteInteger('SinglePlayer','changenetprebuffer',SinglePlayerSettings.changenetprebuffer);
   PlayerSettingsINI.WriteInteger('SinglePlayer','changenettimeout',SinglePlayerSettings.changenettimeout);
   PlayerSettingsINI.WriteInteger('SinglePlayer','changenetreadtimeout',SinglePlayerSettings.changenetreadtimeout);
   PlayerSettingsINI.WriteInteger('SinglePlayer','changeplayerbuffer',SinglePlayerSettings.changeplayerbuffer);
   PlayerSettingsINI.WriteInteger('SinglePlayer','changeplayupdateperiod',SinglePlayerSettings.changeplayupdateperiod);
   PlayerSettingsINI.WriteInteger('SinglePlayer','floatdsp',SinglePlayerSettings.floatdsp);
   PlayerSettingsINI.WriteInteger('SinglePlayer','playerfreq',SinglePlayerSettings.playerfreq);
   PlayerSettingsINI.WriteInteger('SinglePlayer','changeplayerfreq',SinglePlayerSettings.changeplayerfreq);
   PlayerSettingsINI.WriteInteger('SinglePlayer','nomlang',SinglePlayerSettings.nomlang);
   PlayerSettingsINI.WriteInteger('SinglePlayer','changelang',SinglePlayerSettings.changelang);
   PlayerSettingsINI.WriteString('SinglePlayer','altmenu',SinglePlayerSettings.altmenu);
   PlayerSettingsINI.WriteString('SinglePlayer','curentdir',curentdir);

   if singleplayersettings.savepos = 1 then
    begin
     for i:=1 to kollpls do
       begin
        if fileexists(SinglePlayerDir+'playlist_'+inttostr(i)+'.pls') then
         begin
          PlayerSettingsINI.WriteInteger('playlist_'+inttostr(i),'curtrack',plscurtrackpos[i,1]);
          PlayerSettingsINI.WriteInteger('playlist_'+inttostr(i),'curpos',plscurtrackpos[i,2]);
         end;
       end;
    end;

   PlayerSettingsINI.UpdateFile;
   //PlayerSettingsINI.Free;
end;


procedure TSinglePlayerGUI.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i,textformsize:integer;
  textformbold,textitalic:boolean;
begin
  ButtonTimeOld:=GetTickCount();
  try
  mousestate:=1;
  tempY:=Y;
  tempX:=X;
  clickedicon:=0;
  if msgtap<>0 then exit;

  for i:=1 to 100 do          {проигрывать позицию трека}
    begin
     if (x>=progresscor[i,1])
     and (x<=progresscor[i,3])
     and (y>=progresscor[i,2])
     and (y<=progresscor[i,4])
     and (curentpage='singleplayer')
     and (prblock=0) then
     begin
      setplaypos(i);
      exit;
     end;
    end;

  for i:=1 to allicons do
begin
  if (x>seticons[i].left)
  and (x<seticons[i].left+seticons[i].width)
  and (y>seticons[i].top)
  and (y<seticons[i].top+seticons[i].height) then
   begin
   if (pos(curentpage,seticons[i].typeicon)<>0) and (seticons[i].visible='true') then
    begin
    clickedicon:=i;
    PolSecondTimer.Enabled:=false;
    if seticons[i].clickiconcaption<>'' then SinglePlayerGUI.Canvas.Draw(seticons[i].left, seticons[i].top, clickplayericon[i]);
    if (seticons[i].text<>'') then
      begin
       textformsize:=SinglePlayerGUI.Canvas.Font.Size;
       textformbold:=SinglePlayerGUI.Canvas.Font.Bold;
       textitalic:=SinglePlayerGUI.Canvas.Font.Italic;
       SinglePlayerGUI.Canvas.Font.Italic:=strtobool(seticons[i].textitalic);
       SinglePlayerGUI.Canvas.Font.Size:=seticons[i].textsize;
       SinglePlayerGUI.Canvas.Font.bold:=strtobool(seticons[i].textbold);
       if seticons[i].textautosize='true' then while ((myalign(seticons[i].textleft,uprstr(seticons[i].text),1)+SinglePlayerGUI.Canvas.TextWidth(uprstr(seticons[i].text))>seticons[i].maxright) or (myalign(seticons[i].textleft,uprstr(seticons[i].text),1)<seticons[i].minleft)) and (SinglePlayerGUI.Canvas.Font.Size>8) do SinglePlayerGUI.Canvas.Font.Size:=SinglePlayerGUI.Canvas.Font.Size-1;
       SinglePlayerGUI.Canvas.Font.Color:=seticons[i].textcolorclick;
       SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(seticons[i].textleft,uprstr(seticons[i].text),1),seticons[i].texttop,uprstr(seticons[i].text));
       SinglePlayerGUI.Canvas.Font.Size:=textformsize;
       SinglePlayerGUI.Canvas.Font.bold:=textformbold;
       SinglePlayerGUI.Canvas.Font.Italic:=textitalic;
      end;
     case seticons[i].exec of
      'nexttrack': begin if SinglePlayerSettings.peremotka=1 then begin schetperemotka:=0; napr:='forw'; key8(1); end; exit;  end;
      'prevtrack': begin if SinglePlayerSettings.peremotka=1 then begin schetperemotka:=0; napr:='back'; key8(1); end; exit; end;
     end;
    end;
   end;
end;
 except
  LogAndExitPlayer('Ошибка в процедуре FormMouseDown',0,0);
 end;
end;

procedure TSinglePlayerGUI.FormMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  i:integer;
begin
 if msgtap<>0 then exit;
 if (curentpage='playlist') or (curentpage='disktree') then
 begin
 if {(moveexit>0) or} (singleplayersettings.swipeon=0) then exit;
 if (tempY<>Y) and (mousestate>0) then
   begin
    {---------------------------------------------------------------------------}
    if curentpage='playlist' then
     begin
     { if tempX<>X then begin tempX:=X; exit; end;  }
      if (x<plset.noticonpoleleft) or (x>plset.noticonpolerigth) or (y<plset.playlisttexttop) or (y>(plset.trackvertsm*plset.playlistkolltrack)+plset.vidtrackheight) then exit;
      for i:=nachpls to konpls do if (i=SinglePlayerSettings.playedtrack) and (x>=plstrackcor[i,1]) and (y>=plstrackcor[i,2]) and (x<=plstrackcor[i,3]) and (y<=plstrackcor[i,4]) then exit;
      mousestate:=2;
      playlistferstopen:=0;
      if SinglePlayerSettings.wheelone=1 then
       begin
        if tempY>Y then
         begin
          if (nachpls+ee-1+SinglePlayerSettings.SwipeAmount)>SinglePlayerSettings.kolltrack then exit;
          inc(nachpls,SinglePlayerSettings.SwipeAmount);
          end else
         begin
           if nachpls<2 then exit;
           dec(nachpls,SinglePlayerSettings.SwipeAmount);
         end;
        curplspage:=(nachpls+(ee-1)) div ee;
        AfterSwipe:=1;
       end else
       begin
       if tempY>Y then
         begin
          if (nachpls+ee-1+1)>SinglePlayerSettings.kolltrack then exit;
          inc(nachpls,1);
          end else
         begin
           if nachpls<2 then exit;
           dec(nachpls,1);
         end;
        curplspage:=(nachpls+(ee-1)) div ee;
        AfterSwipe:=1;
       end;
       tempY:=Y;
       SinglePlayerGUI.Invalidate;
       exit;
     end;
   {---------------------------------------------------------------------------------}
     if (curentpage='disktree') and (plset.treetype=1) then
     begin
  {    if tempX<>X then begin tempX:=X; exit; end; }
  if (x<plset.treeleftsp) or (x>plset.maxrighttree) or (y<plset.treetopsp) or (y>plset.bottomtree) then exit;
      mousestate:=2;
             if tempY>Y then
             begin
                     if nextpageindex<>0 then
                      begin
                       inc(pageindex);
                       pospage[pageindex]:=nextpageindex;
                      end;
             end
       else
        begin
         dec(pageindex);
         if pageindex=0 then pageindex:=1;
        end;
      tempY:=Y;
      SinglePlayerGUI.Invalidate;
      exit;
     end;

   end;

  if (tempX<>X) and (mousestate>0) then
   begin
     if (curentpage='disktree') and (plset.treetype=0) then
     begin
    {  if tempY<>Y then begin tempY:=Y; exit; end; }
      if (x<plset.treeleft) or (x>plset.maxrightsetka) or (y<plset.treetop) or (y>plset.bottomsetka) then exit;
      mousestate:=2;
             if tempX>X then
             begin
                     if nextpageindex<>0 then
                      begin
                       inc(pageindex);
                       pospage[pageindex]:=nextpageindex;
                      end;
             end
       else
        begin
         dec(pageindex);
         if pageindex=0 then pageindex:=1;
        end;
      tempX:=X;
      SinglePlayerGUI.Invalidate;
      exit;
     end;
   end;
 end;


 if (curentpage='effectedit') {$IFNDEF WInCE} and (ssLeft in Shift){$ENDIF} then
  begin
   case effectstr of
    'bqflow':begin
               if (x>10) and (x<795) then
                begin
                 if (y>top1-20) and (y<top1+22) then
                  begin
                   if (freqfromcoord(x-30)>18000) or (freqfromcoord(x-30)<1) then exit;
                   BASS_ChannelRemoveFX(channel,fxbqflow);
                   fxbqflow := BASS_ChannelSetFX(channel, BASS_FX_BFX_BQF, 1);
                   BASS_FXGetParameters(fxbqflow, @bqflowparam);
                   bqflowparam.lFilter:=BASS_BFX_BQF_LOWPASS;
                   bqflowparam.fCenter:=freqfromcoord(x-30); {10 - половина ширины тумблера}
                   bqflowparam.fQ:=StrToFloatdef(SinglePlayerSettings.ezf[20,4],0);
                   bqflowparam.fbandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[20,3],0);
                   if singleplayersettings.bqflow=1 then BASS_FXSetParameters(fxbqflow, @bqflowparam);
                   SinglePlayerSettings.ezf[20,1]:=realtostr(bqflowparam.fCenter,0);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                 if (y>top3-20) and (y<top3+22) then
                  begin
                   if (znachfromcoord(x-30,10,0,10)>11) or (znachfromcoord(x-30,10,0,10)<-1) then exit;
                   BASS_ChannelRemoveFX(channel,fxbqflow);
                   fxbqflow := BASS_ChannelSetFX(channel, BASS_FX_BFX_BQF, 1);
                   BASS_FXGetParameters(fxbqflow, @bqflowparam);
                   bqflowparam.lFilter:=BASS_BFX_BQF_LOWPASS;
                   bqflowparam.fq:=znachfromcoord(x-30,10,0,10); {10 - половина ширины тумблера}
                   bqflowparam.fCenter:=strtointdef(SinglePlayerSettings.ezf[20,1],0);
                   bqflowparam.fbandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[20,3],0);
                   if singleplayersettings.bqflow=1 then BASS_FXSetParameters(fxbqflow, @bqflowparam);
                   SinglePlayerSettings.ezf[20,4]:=realtostr(bqflowparam.fq,1);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                 if (y>top6-20) and (y<top6+22) then
                  begin
                   if (znachfromcoord(x-30,10,0,10)>11) or (znachfromcoord(x-30,10,0,10)<-1) then exit;
                   BASS_ChannelRemoveFX(channel,fxbqflow);
                   fxbqflow := BASS_ChannelSetFX(channel, BASS_FX_BFX_BQF, 1);
                   BASS_FXGetParameters(fxbqflow, @bqflowparam);
                   bqflowparam.lFilter:=BASS_BFX_BQF_LOWPASS;
                   bqflowparam.fbandwidth:=znachfromcoord(x-30,10,0,10); {10 - половина ширины тумблера}
                   bqflowparam.fCenter:=strtointdef(SinglePlayerSettings.ezf[20,1],0);
                   bqflowparam.fQ:=StrToFloatdef(SinglePlayerSettings.ezf[20,4],0);
                   if singleplayersettings.bqflow=1 then BASS_FXSetParameters(fxbqflow, @bqflowparam);
                   SinglePlayerSettings.ezf[20,3]:=realtostr(bqflowparam.fbandwidth,1);
                   SinglePlayerGUI.Invalidate;
                   exit;
                   end;
                 end;
              end;
    'bqfhigh': begin
               if (x>10) and (x<795) then
                begin
                 if (y>top1-20) and (y<top1+22) then
                  begin
                   if (freqfromcoord(x-30)>18000) or (freqfromcoord(x-30)<1) then exit;
                   BASS_ChannelRemoveFX(channel,fxbqfhigh);
                   fxbqfhigh := BASS_ChannelSetFX(channel, BASS_FX_BFX_BQF, 1);
                   BASS_FXGetParameters(fxbqfhigh, @bqfhighparam);
                   bqfhighparam.lFilter:=BASS_BFX_BQF_HIGHPASS;
                   bqfhighparam.fCenter:=freqfromcoord(x-30); {10 - половина ширины тумблера}
                   bqfhighparam.fQ:=StrToFloatdef(SinglePlayerSettings.ezf[21,4],0);
                   bqfhighparam.fbandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[21,3],0);
                   if singleplayersettings.bqfhigh=1 then BASS_FXSetParameters(fxbqfhigh, @bqfhighparam);
                   SinglePlayerSettings.ezf[21,1]:=realtostr(bqfhighparam.fCenter,0);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                 if (y>top3-20) and (y<top3+22) then
                  begin
                   if (znachfromcoord(x-30,10,0,10)>11) or (znachfromcoord(x-30,10,0,10)<-1) then exit;
                   BASS_ChannelRemoveFX(channel,fxbqfhigh);
                   fxbqfhigh := BASS_ChannelSetFX(channel, BASS_FX_BFX_BQF, 1);
                   BASS_FXGetParameters(fxbqfhigh, @bqfhighparam);
                   bqfhighparam.lFilter:=BASS_BFX_BQF_HIGHPASS;
                   bqfhighparam.fq:=znachfromcoord(x-30,10,0,10); {10 - половина ширины тумблера}
                   bqfhighparam.fCenter:=strtointdef(SinglePlayerSettings.ezf[21,1],0);
                   bqfhighparam.fbandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[21,3],0);
                   if singleplayersettings.bqfhigh=1 then BASS_FXSetParameters(fxbqfhigh, @bqfhighparam);
                   SinglePlayerSettings.ezf[21,4]:=realtostr(bqfhighparam.fq,1);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                 if (y>top6-20) and (y<top6+22) then
                  begin
                   if (znachfromcoord(x-30,10,0,10)>11) or (znachfromcoord(x-30,10,0,10)<-1) then exit;
                   BASS_ChannelRemoveFX(channel,fxbqfhigh);
                   fxbqfhigh := BASS_ChannelSetFX(channel, BASS_FX_BFX_BQF, 1);
                   BASS_FXGetParameters(fxbqfhigh, @bqfhighparam);
                   bqfhighparam.lFilter:=BASS_BFX_BQF_HIGHPASS;
                   bqfhighparam.fbandwidth:=znachfromcoord(x-30,10,0,10); {10 - половина ширины тумблера}
                   bqfhighparam.fCenter:=strtointdef(SinglePlayerSettings.ezf[21,1],0);
                   bqfhighparam.fQ:=StrToFloatdef(SinglePlayerSettings.ezf[21,4],0);
                   if singleplayersettings.bqfhigh=1 then BASS_FXSetParameters(fxbqfhigh, @bqfhighparam);
                   SinglePlayerSettings.ezf[21,3]:=realtostr(bqfhighparam.fbandwidth,1);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                 end;
              end;
    'bqfpeakingeq': begin
               if (x>10) and (x<795) then
                begin
                 if (y>top1-20) and (y<top1+22) then
                  begin
                   if (freqfromcoord(x-30)>18000) or (freqfromcoord(x-30)<1) then exit;
                   BASS_ChannelRemoveFX(channel,fxbqfPEAKINGEQ);
                   fxbqfPEAKINGEQ := BASS_ChannelSetFX(channel, BASS_FX_BFX_BQF, 1);
                   BASS_FXGetParameters(fxbqfPEAKINGEQ, @bqfPEAKINGEQparam);
                   bqfPEAKINGEQparam.lFilter:=BASS_BFX_BQF_PEAKINGEQ;
                   bqfPEAKINGEQparam.fCenter:=freqfromcoord(x-30);
                   bqfPEAKINGEQparam.fGain:=strtofloatdef(SinglePlayerSettings.ezf[22,2],0);
                   bqfPEAKINGEQparam.fbandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[22,3],0);
                   bqfPEAKINGEQparam.fq:=StrToFloatdef(SinglePlayerSettings.ezf[22,4],0);
                   if singleplayersettings.bqfPEAKINGEQ=1 then BASS_FXSetParameters(fxbqfPEAKINGEQ, @bqfPEAKINGEQparam);
                   SinglePlayerSettings.ezf[22,1]:=realtostr(bqfPEAKINGEQparam.fCenter,0);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                 if (y>top2-20) and (y<top2+22) then
                  begin
                   if (znachfromcoord(x-30,10,-60,60)>61) or (znachfromcoord(x-30,10,-60,60)<-61) then exit;
                   BASS_ChannelRemoveFX(channel,fxbqfPEAKINGEQ);
                   fxbqfPEAKINGEQ := BASS_ChannelSetFX(channel, BASS_FX_BFX_BQF, 1);
                   BASS_FXGetParameters(fxbqfPEAKINGEQ, @bqfPEAKINGEQparam);
                   bqfPEAKINGEQparam.lFilter:=BASS_BFX_BQF_PEAKINGEQ;
                   bqfPEAKINGEQparam.fGain:=znachfromcoord(x-30,10,-60,60);
                   bqfPEAKINGEQparam.fCenter:=strtointdef(SinglePlayerSettings.ezf[22,1],0);
                   bqfPEAKINGEQparam.fbandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[22,3],0);
                   bqfPEAKINGEQparam.fq:=StrToFloatdef(SinglePlayerSettings.ezf[22,4],0);
                   if singleplayersettings.bqfPEAKINGEQ=1 then BASS_FXSetParameters(fxbqfPEAKINGEQ, @bqfPEAKINGEQparam);
                   SinglePlayerSettings.ezf[22,2]:=realtostr(bqfPEAKINGEQparam.fGain,0);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                 if (y>top4-20) and (y<top4+22) then
                  begin
                   if (znachfromcoord(x-30,10,0,10)>11) or (znachfromcoord(x-30,10,0,10)<-1) then exit;
                   BASS_ChannelRemoveFX(channel,fxbqfPEAKINGEQ);
                   fxbqfPEAKINGEQ := BASS_ChannelSetFX(channel, BASS_FX_BFX_BQF, 1);
                   BASS_FXGetParameters(fxbqfPEAKINGEQ, @bqfPEAKINGEQparam);
                   bqfPEAKINGEQparam.lFilter:=BASS_BFX_BQF_PEAKINGEQ;
                   bqfPEAKINGEQparam.fbandwidth:=znachfromcoord(x-30,10,0,10);
                   bqfPEAKINGEQparam.fCenter:=strtointdef(SinglePlayerSettings.ezf[22,1],0);
                   bqfPEAKINGEQparam.fGain:=strtofloatdef(SinglePlayerSettings.ezf[22,2],0);
                   bqfPEAKINGEQparam.fq:=StrToFloatdef(SinglePlayerSettings.ezf[22,4],0);
                   if singleplayersettings.bqfPEAKINGEQ=1 then BASS_FXSetParameters(fxbqfPEAKINGEQ, @bqfPEAKINGEQparam);
                   SinglePlayerSettings.ezf[22,3]:=realtostr(bqfPEAKINGEQparam.fbandwidth,1);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                 if (y>top6-20) and (y<top6+22) then
                  begin
                   if (znachfromcoord(x-30,10,0,10)>11) or (znachfromcoord(x-30,10,0,10)<-1) then exit;
                   BASS_ChannelRemoveFX(channel,fxbqfPEAKINGEQ);
                   fxbqfPEAKINGEQ := BASS_ChannelSetFX(channel, BASS_FX_BFX_BQF, 1);
                   BASS_FXGetParameters(fxbqfPEAKINGEQ, @bqfPEAKINGEQparam);
                   bqfPEAKINGEQparam.lFilter:=BASS_BFX_BQF_PEAKINGEQ;
                   bqfPEAKINGEQparam.fq:=znachfromcoord(x-30,10,0,10);
                   bqfPEAKINGEQparam.fCenter:=strtointdef(SinglePlayerSettings.ezf[22,1],0);
                   bqfPEAKINGEQparam.fGain:=strtofloatdef(SinglePlayerSettings.ezf[22,2],0);
                   bqfPEAKINGEQparam.fbandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[22,3],0);
                   if singleplayersettings.bqfPEAKINGEQ=1 then BASS_FXSetParameters(fxbqfPEAKINGEQ, @bqfPEAKINGEQparam);
                   SinglePlayerSettings.ezf[22,4]:=realtostr(bqfPEAKINGEQparam.fq,1);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                end;
              end;
    'bqfbandpass': begin
               if (x>10) and (x<795) then
                begin
                 if (y>top1-20) and (y<top1+22) then
                  begin
                   if (freqfromcoord(x-30)>18000) or (freqfromcoord(x-30)<1) then exit;
                   BASS_ChannelRemoveFX(channel,fxbqfBANDPASS);
                   fxbqfBANDPASS := BASS_ChannelSetFX(channel, BASS_FX_BFX_BQF, 1);
                   BASS_FXGetParameters(fxbqfBANDPASS, @bqfBANDPASSparam);
                   bqfBANDPASSparam.lFilter:=BASS_BFX_BQF_BANDPASS;
                   bqfBANDPASSparam.fCenter:=freqfromcoord(x-30);
                   bqfBANDPASSparam.fbandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[23,3],0);
                   bqfBANDPASSparam.fq:=StrToFloatdef(SinglePlayerSettings.ezf[23,4],0);
                   if singleplayersettings.bqfBANDPASS=1 then BASS_FXSetParameters(fxbqfBANDPASS, @bqfBANDPASSparam);
                   SinglePlayerSettings.ezf[23,1]:=realtostr(bqfBANDPASSparam.fCenter,0);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                 if (y>top6-20) and (y<top6+22) then
                  begin
                   if (znachfromcoord(x-30,10,0,10)>11) or (znachfromcoord(x-30,10,0,10)<-1) then exit;
                   BASS_ChannelRemoveFX(channel,fxbqfBANDPASS);
                   fxbqfBANDPASS := BASS_ChannelSetFX(channel, BASS_FX_BFX_BQF, 1);
                   BASS_FXGetParameters(fxbqfBANDPASS, @bqfBANDPASSparam);
                   bqfBANDPASSparam.lFilter:=BASS_BFX_BQF_BANDPASS;
                   bqfBANDPASSparam.fbandwidth:=znachfromcoord(x-30,10,0,10);
                   bqfBANDPASSparam.fCenter:=StrToIntdef(SinglePlayerSettings.ezf[23,1],0);
                   bqfBANDPASSparam.fq:=StrToFloatdef(SinglePlayerSettings.ezf[23,4],0);
                   if singleplayersettings.bqfBANDPASS=1 then BASS_FXSetParameters(fxbqfBANDPASS, @bqfBANDPASSparam);
                   SinglePlayerSettings.ezf[23,3]:=realtostr(bqfBANDPASSparam.fbandwidth,1);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                 if (y>top3-20) and (y<top3+22) then
                  begin
                   if (znachfromcoord(x-30,10,0,10)>11) or (znachfromcoord(x-30,10,0,10)<-1) then exit;
                   BASS_ChannelRemoveFX(channel,fxbqfBANDPASS);
                   fxbqfBANDPASS := BASS_ChannelSetFX(channel, BASS_FX_BFX_BQF, 1);
                   BASS_FXGetParameters(fxbqfBANDPASS, @bqfBANDPASSparam);
                   bqfBANDPASSparam.lFilter:=BASS_BFX_BQF_BANDPASS;
                   bqfBANDPASSparam.fq:=znachfromcoord(x-30,10,0,10);
                   bqfBANDPASSparam.fCenter:=StrToIntdef(SinglePlayerSettings.ezf[23,1],0);
                   bqfBANDPASSparam.fbandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[23,3],0);
                   if singleplayersettings.bqfBANDPASS=1 then BASS_FXSetParameters(fxbqfBANDPASS, @bqfBANDPASSparam);
                   SinglePlayerSettings.ezf[23,4]:=realtostr(bqfBANDPASSparam.fq,1);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                end;
              end;
    'bqfnotch': begin
               if (x>10) and (x<795) then
                begin
                 if (y>top1-20) and (y<top1+22) then
                  begin
                   if (freqfromcoord(x-30)>18000) or (freqfromcoord(x-30)<1) then exit;
                   BASS_ChannelRemoveFX(channel,fxbqfnotch);
                   fxbqfnotch := BASS_ChannelSetFX(channel, BASS_FX_BFX_BQF, 1);
                   BASS_FXGetParameters(fxbqfnotch, @bqfnotchparam);
                   bqfnotchparam.lFilter:=BASS_BFX_BQF_notch;
                   bqfnotchparam.fCenter:=freqfromcoord(x-30);
                   bqfnotchparam.fbandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[29,3],0);
                   bqfnotchparam.fq:=StrToFloatdef(SinglePlayerSettings.ezf[29,4],0);
                   if singleplayersettings.bqfnotch=1 then BASS_FXSetParameters(fxbqfnotch, @bqfnotchparam);
                   SinglePlayerSettings.ezf[29,1]:=realtostr(bqfnotchparam.fCenter,0);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                 if (y>top6-20) and (y<top6+22) then
                  begin
                   if (znachfromcoord(x-30,10,0,10)>11) or (znachfromcoord(x-30,10,0,10)<-1) then exit;
                   BASS_ChannelRemoveFX(channel,fxbqfnotch);
                   fxbqfnotch := BASS_ChannelSetFX(channel, BASS_FX_BFX_BQF, 1);
                   BASS_FXGetParameters(fxbqfnotch, @bqfnotchparam);
                   bqfnotchparam.lFilter:=BASS_BFX_BQF_notch;
                   bqfnotchparam.fbandwidth:=znachfromcoord(x-30,10,0,10);
                   bqfnotchparam.fCenter:=StrToIntdef(SinglePlayerSettings.ezf[29,1],0);
                   bqfnotchparam.fq:=StrToFloatdef(SinglePlayerSettings.ezf[29,4],0);
                   if singleplayersettings.bqfnotch=1 then BASS_FXSetParameters(fxbqfnotch, @bqfnotchparam);
                   SinglePlayerSettings.ezf[29,3]:=realtostr(bqfnotchparam.fbandwidth,1);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                 if (y>top3-20) and (y<top3+22) then
                  begin
                   if (znachfromcoord(x-30,10,0,10)>11) or (znachfromcoord(x-30,10,0,10)<-1) then exit;
                   BASS_ChannelRemoveFX(channel,fxbqfnotch);
                   fxbqfnotch := BASS_ChannelSetFX(channel, BASS_FX_BFX_BQF, 1);
                   BASS_FXGetParameters(fxbqfnotch, @bqfnotchparam);
                   bqfnotchparam.lFilter:=BASS_BFX_BQF_notch;
                   bqfnotchparam.fq:=znachfromcoord(x-30,10,0,10);
                   bqfnotchparam.fCenter:=StrToIntdef(SinglePlayerSettings.ezf[29,1],0);
                   bqfnotchparam.fbandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[29,3],0);
                   if singleplayersettings.bqfnotch=1 then BASS_FXSetParameters(fxbqfnotch, @bqfnotchparam);
                   SinglePlayerSettings.ezf[29,4]:=realtostr(bqfnotchparam.fq,1);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                end;
              end;
    'reverb': begin
               if (x>10) and (x<795) then
                begin
                  if (y>top1-20) and (y<top1+22) then
                   begin
                    if (znachfromcoord(x-30,10,-96,0)>1) or (znachfromcoord(x-30,10,-96,0)<-96) then exit;
                    BASS_ChannelRemoveFX(channel,fxreverb);
                    fxreverb := BASS_ChannelSetFX(channel,  BASS_FX_DX8_REVERB, 1);
                    BASS_FXGetParameters(fxreverb, @reverbparam);
                    reverbparam.fInGain:=znachfromcoord(x-30,10,-96,0);
                    reverbparam.fReverbMix:=StrTofloatdef(SinglePlayerSettings.ezf[14,2],0);
                    reverbparam.fReverbTime:=StrTofloatdef(SinglePlayerSettings.ezf[14,3],0);
                    reverbparam.fHighFreqRTRatio:=StrToFloatdef(SinglePlayerSettings.ezf[14,4],0);
                    if singleplayersettings.reverb=1 then BASS_FXSetParameters(fxreverb, @reverbparam);
                    SinglePlayerSettings.ezf[14,1]:=realtostr(reverbparam.fInGain,0);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                 if (y>top2-20) and (y<top2+22) then
                  begin
                   if (znachfromcoord(x-30,10,-96,0)>1) or (znachfromcoord(x-30,10,-96,0)<-96) then exit;
                   BASS_ChannelRemoveFX(channel,fxreverb);
                   fxreverb := BASS_ChannelSetFX(channel,  BASS_FX_DX8_REVERB, 1);
                   BASS_FXGetParameters(fxreverb, @reverbparam);
                   reverbparam.fReverbMix:=znachfromcoord(x-30,10,-96,0);
                   reverbparam.fInGain:=StrTofloatdef(SinglePlayerSettings.ezf[14,1],0);
                   reverbparam.fReverbTime:=StrTofloatdef(SinglePlayerSettings.ezf[14,3],0);
                   reverbparam.fHighFreqRTRatio:=StrToFloatdef(SinglePlayerSettings.ezf[14,4],0);
                   if singleplayersettings.reverb=1 then BASS_FXSetParameters(fxreverb, @reverbparam);
                   SinglePlayerSettings.ezf[14,2]:=realtostr(reverbparam.fReverbMix,0);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                 if (y>top4-20) and (y<top4+22) then
                  begin
                   if (znachfromcoord(x-30,10,1,3000)>3001) or (znachfromcoord(x-30,10,1,3000)<0) then exit;
                   BASS_ChannelRemoveFX(channel,fxreverb);
                   fxreverb := BASS_ChannelSetFX(channel,  BASS_FX_DX8_REVERB, 1);
                   BASS_FXGetParameters(fxreverb, @reverbparam);
                   reverbparam.fReverbMix:=StrToFloatdef(SinglePlayerSettings.ezf[14,2],0);
                   reverbparam.fInGain:=StrTofloatdef(SinglePlayerSettings.ezf[14,1],0);
                   reverbparam.fReverbTime:=znachfromcoord(x-30,10,1,3000);
                   reverbparam.fHighFreqRTRatio:=StrToFloatdef(SinglePlayerSettings.ezf[14,4],0);
                   if singleplayersettings.reverb=1 then BASS_FXSetParameters(fxreverb, @reverbparam);
                   SinglePlayerSettings.ezf[14,3]:=realtostr(reverbparam.fReverbTime,0);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                 if (y>top6-20) and (y<top6+22) then
                  begin
                   if (znachfromcoord(x-30,10000,1,999)>1000) or (znachfromcoord(x-30,10000,1,999)<0) then exit;
                   BASS_ChannelRemoveFX(channel,fxreverb);
                   fxreverb := BASS_ChannelSetFX(channel,  BASS_FX_DX8_REVERB, 1);
                   BASS_FXGetParameters(fxreverb, @reverbparam);
                   reverbparam.fReverbMix:=StrTofloatdef(SinglePlayerSettings.ezf[14,2],0);
                   reverbparam.fInGain:=StrTofloatdef(SinglePlayerSettings.ezf[14,1],0);
                   reverbparam.fReverbTime:=StrTofloatdef(SinglePlayerSettings.ezf[14,3],0);
                   reverbparam.fHighFreqRTRatio:=znachfromcoord(x-30,10000,1,999);
                   if singleplayersettings.reverb=1 then BASS_FXSetParameters(fxreverb, @reverbparam);
                   SinglePlayerSettings.ezf[14,4]:=realtostr(reverbparam.fHighFreqRTRatio,3);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                end;
              end;
    'echo': begin
               if (x>10) and (x<795) then
                begin
                  if (y>top1-20) and (y<top1+22) then
                   begin
                    if (znachfromcoord(x-30,10,0,100)>101) or (znachfromcoord(x-30,10,0,100)<0) then exit;
                    BASS_ChannelRemoveFX(channel,fxecho);
                    fxecho := BASS_ChannelSetFX(channel,  BASS_FX_DX8_ECHO, 1);
                    BASS_FXGetParameters(fxecho, @echoparam);
                    echoparam.fWetDryMix:=znachfromcoord(x-30,10,0,100);
                    echoparam.fFeedback:=StrTofloatdef(SinglePlayerSettings.ezf[15,2],0);
                    echoparam.fLeftDelay:=StrTofloatdef(SinglePlayerSettings.ezf[15,3],0);
                    echoparam.fRightDelay:=StrToFloatdef(SinglePlayerSettings.ezf[15,4],0);
                    if singleplayersettings.echo=1 then BASS_FXSetParameters(fxecho, @echoparam);
                    SinglePlayerSettings.ezf[15,1]:=realtostr(echoparam.fWetDryMix,0);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                 if (y>top2-20) and (y<top2+22) then
                  begin
                   if (znachfromcoord(x-30,10,0,100)>101) or (znachfromcoord(x-30,10,0,100)<0) then exit;
                   BASS_ChannelRemoveFX(channel,fxecho);
                   fxecho := BASS_ChannelSetFX(channel,  BASS_FX_DX8_ECHO, 1);
                   BASS_FXGetParameters(fxecho, @echoparam);
                   echoparam.fWetDryMix:=StrTofloatdef(SinglePlayerSettings.ezf[15,1],0);
                   echoparam.fFeedback:=znachfromcoord(x-30,10,0,100);
                   echoparam.fLeftDelay:=StrTofloatdef(SinglePlayerSettings.ezf[15,3],0);
                   echoparam.fRightDelay:=StrToFloatdef(SinglePlayerSettings.ezf[15,4],0);
                   if singleplayersettings.echo=1 then BASS_FXSetParameters(fxecho, @echoparam);
                   SinglePlayerSettings.ezf[15,2]:=realtostr(echoparam.fFeedback,0);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                 if (y>top4-20) and (y<top4+22) then
                  begin
                   if (znachfromcoord(x-30,10,1,2000)>2001) or (znachfromcoord(x-30,10,1,2000)<1) then exit;
                   BASS_ChannelRemoveFX(channel,fxecho);
                   fxecho := BASS_ChannelSetFX(channel,  BASS_FX_DX8_ECHO, 1);
                   BASS_FXGetParameters(fxecho, @echoparam);
                   echoparam.fWetDryMix:=StrTofloatdef(SinglePlayerSettings.ezf[15,1],0);
                   echoparam.fFeedback:=StrTofloatdef(SinglePlayerSettings.ezf[15,2],0);
                   echoparam.fLeftDelay:=znachfromcoord(x-30,10,1,2000);
                   echoparam.fRightDelay:=StrToFloatdef(SinglePlayerSettings.ezf[15,4],0);
                   if singleplayersettings.echo=1 then BASS_FXSetParameters(fxecho, @echoparam);
                   SinglePlayerSettings.ezf[15,3]:=realtostr(echoparam.fLeftDelay,0);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                 if (y>top6-20) and (y<top6+22) then
                  begin
                   if (znachfromcoord(x-30,10,1,2000)>2001) or (znachfromcoord(x-30,10,1,2000)<1) then exit;
                   BASS_ChannelRemoveFX(channel,fxecho);
                   fxecho := BASS_ChannelSetFX(channel,  BASS_FX_DX8_ECHO, 1);
                   BASS_FXGetParameters(fxecho, @echoparam);
                   echoparam.fWetDryMix:=StrTofloatdef(SinglePlayerSettings.ezf[15,1],0);
                   echoparam.fFeedback:=StrTofloatdef(SinglePlayerSettings.ezf[15,2],0);
                   echoparam.fLeftDelay:=StrToFloatdef(SinglePlayerSettings.ezf[15,3],0);
                   echoparam.fRightDelay:=znachfromcoord(x-30,10,1,2000);
                   if singleplayersettings.echo=1 then BASS_FXSetParameters(fxecho, @echoparam);
                   SinglePlayerSettings.ezf[15,4]:=realtostr(echoparam.fRightDelay,0);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                end;
              end;
    'chorus': begin
               if (x>10) and (x<795) then
                begin
                  if (y>top1-20) and (y<top1+22) then
                   begin
                    if (znachfromcoord(x-30,10,0,100)>101) or (znachfromcoord(x-30,10,0,100)<0) then exit;
                    BASS_ChannelRemoveFX(channel,fxchorus);
                    fxchorus := BASS_ChannelSetFX(channel,  BASS_FX_DX8_chorus, 1);
                    BASS_FXGetParameters(fxchorus, @chorusparam);
                    chorusparam.fWetDryMix:=znachfromcoord(x-30,10,0,100);
                    chorusparam.fDepth:=StrTofloatdef(SinglePlayerSettings.ezf[16,2],0);
                    chorusparam.fFeedback:=StrTofloatdef(SinglePlayerSettings.ezf[16,3],0);
                    chorusparam.fFrequency:=StrToFloatdef(SinglePlayerSettings.ezf[16,4],0);
                    chorusparam.fDelay:=StrToFloatdef(SinglePlayerSettings.ezf[16,5],0);
                    if singleplayersettings.chorus=1 then BASS_FXSetParameters(fxchorus, @chorusparam);
                    SinglePlayerSettings.ezf[16,1]:=realtostr(chorusparam.fWetDryMix,0);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                 if (y>top3-20) and (y<top3+22) then
                  begin
                   if (znachfromcoord(x-30,10,0,100)>101) or (znachfromcoord(x-30,10,0,100)<0) then exit;
                   BASS_ChannelRemoveFX(channel,fxchorus);
                   fxchorus := BASS_ChannelSetFX(channel,  BASS_FX_DX8_chorus, 1);
                   BASS_FXGetParameters(fxchorus, @chorusparam);
                   chorusparam.fWetDryMix:=StrTofloatdef(SinglePlayerSettings.ezf[16,1],0);
                   chorusparam.fDepth:=znachfromcoord(x-30,10,0,100);
                   chorusparam.fFeedback:=StrTofloatdef(SinglePlayerSettings.ezf[16,3],0);
                   chorusparam.fFrequency:=StrToFloatdef(SinglePlayerSettings.ezf[16,4],0);
                   chorusparam.fDelay:=StrToFloatdef(SinglePlayerSettings.ezf[16,5],0);
                   if singleplayersettings.chorus=1 then BASS_FXSetParameters(fxchorus, @chorusparam);
                   SinglePlayerSettings.ezf[16,2]:=realtostr(chorusparam.fDepth,0);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                 if (y>top4-20) and (y<top4+22) then
                  begin
                   if (znachfromcoord(x-30,10,-99,99)>100) or (znachfromcoord(x-30,10,-99,99)<-99) then exit;
                   BASS_ChannelRemoveFX(channel,fxchorus);
                   fxchorus := BASS_ChannelSetFX(channel,  BASS_FX_DX8_chorus, 1);
                   BASS_FXGetParameters(fxchorus, @chorusparam);
                   chorusparam.fWetDryMix:=StrTofloatdef(SinglePlayerSettings.ezf[16,1],0);
                   chorusparam.fDepth:=StrTofloatdef(SinglePlayerSettings.ezf[16,2],0);
                   chorusparam.fFeedback:=znachfromcoord(x-30,10,-99,99);
                   chorusparam.fFrequency:=StrToFloatdef(SinglePlayerSettings.ezf[16,4],0);
                   chorusparam.fDelay:=StrToFloatdef(SinglePlayerSettings.ezf[16,5],0);
                   if singleplayersettings.chorus=1 then BASS_FXSetParameters(fxchorus, @chorusparam);
                   SinglePlayerSettings.ezf[16,3]:=realtostr(chorusparam.fFeedback,0);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                 if (y>top5-20) and (y<top5+22) then
                  begin
                   if (znachfromcoord(x-30,10,0,10)>11) or (znachfromcoord(x-30,10,0,10)<0) then exit;
                   BASS_ChannelRemoveFX(channel,fxchorus);
                   fxchorus := BASS_ChannelSetFX(channel,  BASS_FX_DX8_chorus, 1);
                   BASS_FXGetParameters(fxchorus, @chorusparam);
                   chorusparam.fWetDryMix:=StrToFloatdef(SinglePlayerSettings.ezf[16,1],0);
                   chorusparam.fDepth:=StrTofloatdef(SinglePlayerSettings.ezf[16,2],0);
                   chorusparam.fFeedback:=StrTofloatdef(SinglePlayerSettings.ezf[16,3],0);
                   chorusparam.fFrequency:=znachfromcoord(x-30,10,0,10);
                   chorusparam.fDelay:=StrToFloatdef(SinglePlayerSettings.ezf[16,5],0);
                   if singleplayersettings.chorus=1 then BASS_FXSetParameters(fxchorus, @chorusparam);
                   SinglePlayerSettings.ezf[16,4]:=realtostr(chorusparam.fFrequency,1);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                 if (y>top6-20) and (y<top6+22) then
                  begin
                   if (znachfromcoord(x-30,10,0,20)>21) or (znachfromcoord(x-30,10,0,20)<0) then exit;
                   BASS_ChannelRemoveFX(channel,fxchorus);
                   fxchorus := BASS_ChannelSetFX(channel,  BASS_FX_DX8_chorus, 1);
                   BASS_FXGetParameters(fxchorus, @chorusparam);
                   chorusparam.fWetDryMix:=StrToFloatdef(SinglePlayerSettings.ezf[16,1],0);
                   chorusparam.fDepth:=StrTofloatdef(SinglePlayerSettings.ezf[16,2],0);
                   chorusparam.fFeedback:=StrTofloatdef(SinglePlayerSettings.ezf[16,3],0);
                   chorusparam.fFrequency:=StrToFloatdef(SinglePlayerSettings.ezf[16,4],0);
                   chorusparam.fDelay:=znachfromcoord(x-30,10,0,20);
                   if singleplayersettings.chorus=1 then BASS_FXSetParameters(fxchorus, @chorusparam);
                   SinglePlayerSettings.ezf[16,5]:=realtostr(chorusparam.fDelay,0);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                end;
              end;
    'flanger': begin
               if (x>10) and (x<795) then
                begin
                  if (y>top1-20) and (y<top1+22) then
                   begin
                    if (znachfromcoord(x-30,10,0,100)>101) or (znachfromcoord(x-30,10,0,100)<0) then exit;
                    BASS_ChannelRemoveFX(channel,fxflanger);
                    fxflanger := BASS_ChannelSetFX(channel,  BASS_FX_DX8_flanger, 1);
                    BASS_FXGetParameters(fxflanger, @flangerparam);
                    flangerparam.fWetDryMix:=znachfromcoord(x-30,10,0,100);
                    flangerparam.fDepth:=StrTofloatdef(SinglePlayerSettings.ezf[17,2],0);
                    flangerparam.fFeedback:=StrTofloatdef(SinglePlayerSettings.ezf[17,3],0);
                    flangerparam.fFrequency:=StrToFloatdef(SinglePlayerSettings.ezf[17,4],0);
                    flangerparam.fDelay:=StrToFloatdef(SinglePlayerSettings.ezf[17,5],0);
                    if singleplayersettings.flanger=1 then BASS_FXSetParameters(fxflanger, @flangerparam);
                    SinglePlayerSettings.ezf[17,1]:=realtostr(flangerparam.fWetDryMix,0);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                 if (y>top3-20) and (y<top3+22) then
                  begin
                   if (znachfromcoord(x-30,10,0,100)>101) or (znachfromcoord(x-30,10,0,100)<0) then exit;
                   BASS_ChannelRemoveFX(channel,fxflanger);
                   fxflanger := BASS_ChannelSetFX(channel,  BASS_FX_DX8_flanger, 1);
                   BASS_FXGetParameters(fxflanger, @flangerparam);
                   flangerparam.fWetDryMix:=StrTofloatdef(SinglePlayerSettings.ezf[17,1],0);
                   flangerparam.fDepth:=znachfromcoord(x-30,10,0,100);
                   flangerparam.fFeedback:=StrTofloatdef(SinglePlayerSettings.ezf[17,3],0);
                   flangerparam.fFrequency:=StrToFloatdef(SinglePlayerSettings.ezf[17,4],0);
                   flangerparam.fDelay:=StrToFloatdef(SinglePlayerSettings.ezf[17,5],0);
                   if singleplayersettings.flanger=1 then BASS_FXSetParameters(fxflanger, @flangerparam);
                   SinglePlayerSettings.ezf[17,2]:=realtostr(flangerparam.fDepth,0);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                 if (y>top4-20) and (y<top4+22) then
                  begin
                   if (znachfromcoord(x-30,10,-99,99)>100) or (znachfromcoord(x-30,10,-99,99)<-99) then exit;
                   BASS_ChannelRemoveFX(channel,fxflanger);
                   fxflanger := BASS_ChannelSetFX(channel,  BASS_FX_DX8_flanger, 1);
                   BASS_FXGetParameters(fxflanger, @flangerparam);
                   flangerparam.fWetDryMix:=StrTofloatdef(SinglePlayerSettings.ezf[17,1],0);
                   flangerparam.fDepth:=StrTofloatdef(SinglePlayerSettings.ezf[17,2],0);
                   flangerparam.fFeedback:=znachfromcoord(x-30,10,-99,99);
                   flangerparam.fFrequency:=StrToFloatdef(SinglePlayerSettings.ezf[17,4],0);
                   flangerparam.fDelay:=StrToFloatdef(SinglePlayerSettings.ezf[17,5],0);
                   if singleplayersettings.flanger=1 then BASS_FXSetParameters(fxflanger, @flangerparam);
                   SinglePlayerSettings.ezf[17,3]:=realtostr(flangerparam.fFeedback,0);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                 if (y>top5-20) and (y<top5+22) then
                  begin
                   if (znachfromcoord(x-30,10,0,10)>11) or (znachfromcoord(x-30,10,0,10)<0) then exit;
                   BASS_ChannelRemoveFX(channel,fxflanger);
                   fxflanger := BASS_ChannelSetFX(channel,  BASS_FX_DX8_flanger, 1);
                   BASS_FXGetParameters(fxflanger, @flangerparam);
                   flangerparam.fWetDryMix:=StrToFloatdef(SinglePlayerSettings.ezf[17,1],0);
                   flangerparam.fDepth:=StrTofloatdef(SinglePlayerSettings.ezf[17,2],0);
                   flangerparam.fFeedback:=StrTofloatdef(SinglePlayerSettings.ezf[17,3],0);
                   flangerparam.fFrequency:=znachfromcoord(x-30,10,0,10);
                   flangerparam.fDelay:=StrToFloatdef(SinglePlayerSettings.ezf[17,5],0);
                   if singleplayersettings.flanger=1 then BASS_FXSetParameters(fxflanger, @flangerparam);
                   SinglePlayerSettings.ezf[17,4]:=realtostr(flangerparam.fFrequency,1);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                 if (y>top6-20) and (y<top6+22) then
                  begin
                   if (znachfromcoord(x-30,10,0,4)>21) or (znachfromcoord(x-30,10,0,4)<0) then exit;
                   BASS_ChannelRemoveFX(channel,fxflanger);
                   fxflanger := BASS_ChannelSetFX(channel,  BASS_FX_DX8_flanger, 1);
                   BASS_FXGetParameters(fxflanger, @flangerparam);
                   flangerparam.fWetDryMix:=StrToFloatdef(SinglePlayerSettings.ezf[17,1],0);
                   flangerparam.fDepth:=StrTofloatdef(SinglePlayerSettings.ezf[17,2],0);
                   flangerparam.fFeedback:=StrTofloatdef(SinglePlayerSettings.ezf[17,3],0);
                   flangerparam.fFrequency:=StrToFloatdef(SinglePlayerSettings.ezf[17,4],0);
                   flangerparam.fDelay:=znachfromcoord(x-30,10,0,4);
                   if singleplayersettings.flanger=1 then BASS_FXSetParameters(fxflanger, @flangerparam);
                   SinglePlayerSettings.ezf[17,5]:=realtostr(flangerparam.fDelay,0);
                   SinglePlayerGUI.Invalidate;
                   exit;
                  end;
                end;
              end;
    'tempo': begin
                   if (x>10) and (x<795) then
                    begin
                      if (y>top1-20) and (y<top1+22) then
                       begin
                        if (znachfromcoord(x-30,10,-50,50)>101) or (znachfromcoord(x-30,10,-100,100)<-100) then exit;
                        SinglePlayerSettings.ezf[18,1]:=realtostr(znachfromcoord(x-30,10,-100,100),0);
                        if singleplayersettings.tempo=1 then BASS_ChannelSetAttribute(channel, BASS_ATTRIB_TEMPO,strtointdef(SinglePlayerSettings.ezf[18,1],0));
                        SinglePlayerGUI.Invalidate;
                        exit;
                       end;
                  end;
             end;
    'pitch': begin
                   if (x>10) and (x<795) then
                    begin
                      if (y>top1-20) and (y<top1+22) then
                       begin
                        if (znachfromcoord(x-30,10,-20,20)>51) or (znachfromcoord(x-30,10,-20,20)<-20) then exit;
                        SinglePlayerSettings.ezf[19,1]:=realtostr(znachfromcoord(x-30,10,-20,20),0);
                        if singleplayersettings.pitch=1 then BASS_ChannelSetAttribute(channel, BASS_ATTRIB_TEMPO_PITCH,strtointdef(SinglePlayerSettings.ezf[19,1],0));
                        SinglePlayerGUI.Invalidate;
                         exit;
                       end;
                  end;
             end;
    'compressor': begin
               if (x>10) and (x<795) then
                begin
                  if (y>top1-20) and (y<top1+22) then
                   begin
                    if (znachfromcoord(x-30,10,-60,60)>61) or (znachfromcoord(x-30,10,-60,60)<-60) then exit;
                    BASS_ChannelRemoveFX(channel,fxcompressor);
                    fxcompressor := BASS_ChannelSetFX(channel,  BASS_FX_BFX_COMPRESSOR2, 1);
                    BASS_FXGetParameters(fxcompressor, @compressorparam);
                    compressorparam.fGain:=znachfromcoord(x-30,10,-60,60);
                    compressorparam.fAttack:=StrTofloatdef(SinglePlayerSettings.ezf[24,2],0);
                    compressorparam.fRelease:=StrTofloatdef(SinglePlayerSettings.ezf[24,3],0);
                    compressorparam.fThreshold:=StrToFloatdef(SinglePlayerSettings.ezf[24,4],0);
                    compressorparam.fRatio:=StrToFloatdef(SinglePlayerSettings.ezf[24,5],0);
                    if singleplayersettings.compressor=1 then BASS_FXSetParameters(fxcompressor, @compressorparam);
                    SinglePlayerSettings.ezf[24,1]:=realtostr(compressorparam.fGain,0);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                  if (y>top2-20) and (y<top2+22) then
                   begin
                    if (znachfromcoord(x-30,10,1,1000)>1001) or (znachfromcoord(x-30,10,1,1000)<1) then exit;
                    BASS_ChannelRemoveFX(channel,fxcompressor);
                    fxcompressor := BASS_ChannelSetFX(channel,  BASS_FX_BFX_COMPRESSOR2, 1);
                    BASS_FXGetParameters(fxcompressor, @compressorparam);
                    compressorparam.fGain:=StrTofloatdef(SinglePlayerSettings.ezf[24,1],0);
                    compressorparam.fAttack:=znachfromcoord(x-30,10,1,1000);
                    compressorparam.fRelease:=StrTofloatdef(SinglePlayerSettings.ezf[24,3],0);
                    compressorparam.fThreshold:=StrToFloatdef(SinglePlayerSettings.ezf[24,4],0);
                    compressorparam.fRatio:=StrToFloatdef(SinglePlayerSettings.ezf[24,5],0);
                    if singleplayersettings.compressor=1 then BASS_FXSetParameters(fxcompressor, @compressorparam);
                    SinglePlayerSettings.ezf[24,2]:=realtostr(compressorparam.fAttack,0);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                  if (y>top3-20) and (y<top3+22) then
                   begin
                    if (znachfromcoord(x-30,10,1,5000)>5001) or (znachfromcoord(x-30,10,1,5000)<1) then exit;
                    BASS_ChannelRemoveFX(channel,fxcompressor);
                    fxcompressor := BASS_ChannelSetFX(channel,  BASS_FX_BFX_COMPRESSOR2, 1);
                    BASS_FXGetParameters(fxcompressor, @compressorparam);
                    compressorparam.fGain:=StrTofloatdef(SinglePlayerSettings.ezf[24,1],0);
                    compressorparam.fAttack:=StrTofloatdef(SinglePlayerSettings.ezf[24,2],0);
                    compressorparam.fRelease:=znachfromcoord(x-30,10,1,5000);
                    compressorparam.fThreshold:=StrToFloatdef(SinglePlayerSettings.ezf[24,4],0);
                    compressorparam.fRatio:=StrToFloatdef(SinglePlayerSettings.ezf[24,5],0);
                    if singleplayersettings.compressor=1 then BASS_FXSetParameters(fxcompressor, @compressorparam);
                    SinglePlayerSettings.ezf[24,3]:=realtostr(compressorparam.fRelease,0);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                  if (y>top4-20) and (y<top4+22) then
                   begin
                    if (znachfromcoord(x-30,10,-60,0)>1) or (znachfromcoord(x-30,10,-60,0)<-60) then exit;
                    BASS_ChannelRemoveFX(channel,fxcompressor);
                    fxcompressor := BASS_ChannelSetFX(channel,  BASS_FX_BFX_COMPRESSOR2, 1);
                    BASS_FXGetParameters(fxcompressor, @compressorparam);
                    compressorparam.fGain:=StrToFloatdef(SinglePlayerSettings.ezf[24,1],0);
                    compressorparam.fAttack:=StrTofloatdef(SinglePlayerSettings.ezf[24,2],0);
                    compressorparam.fRelease:=StrTofloatdef(SinglePlayerSettings.ezf[24,3],0);
                    compressorparam.fThreshold:=znachfromcoord(x-30,10,-60,0);
                    compressorparam.fRatio:=StrToFloatdef(SinglePlayerSettings.ezf[24,5],0);
                    if singleplayersettings.compressor=1 then BASS_FXSetParameters(fxcompressor, @compressorparam);
                    SinglePlayerSettings.ezf[24,4]:=realtostr(compressorparam.fThreshold,0);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                  if (y>top5-20) and (y<top5+22) then
                   begin
                    if (znachfromcoord(x-30,10,1,5)>6) or (znachfromcoord(x-30,10,1,5)<1) then exit;
                    BASS_ChannelRemoveFX(channel,fxcompressor);
                    fxcompressor := BASS_ChannelSetFX(channel,  BASS_FX_BFX_COMPRESSOR2, 1);
                    BASS_FXGetParameters(fxcompressor, @compressorparam);
                    compressorparam.fGain:=StrToFloatdef(SinglePlayerSettings.ezf[24,1],0);
                    compressorparam.fAttack:=StrTofloatdef(SinglePlayerSettings.ezf[24,2],0);
                    compressorparam.fRelease:=StrTofloatdef(SinglePlayerSettings.ezf[24,3],0);
                    compressorparam.fThreshold:=StrToFloatdef(SinglePlayerSettings.ezf[24,4],0);
                    compressorparam.fRatio:=znachfromcoord(x-30,10,1,5);
                    if singleplayersettings.compressor=1 then BASS_FXSetParameters(fxcompressor, @compressorparam);
                    SinglePlayerSettings.ezf[24,5]:=realtostr(compressorparam.fRatio,0);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                end;
               end;
    'distortion': begin
               if (x>10) and (x<795) then
                begin
                  if (y>top1-20) and (y<top1+22) then
                   begin
                    if (znachfromcoord(x-30,10,-60,0)>1) or (znachfromcoord(x-30,10,-60,0)<-60) then exit;
                    BASS_ChannelRemoveFX(channel,fxdistortion);
                    fxdistortion := BASS_ChannelSetFX(channel,  BASS_FX_DX8_distortion, 1);
                    BASS_FXGetParameters(fxdistortion, @distortionparam);
                    distortionparam.fGain:=znachfromcoord(x-30,10,-60,0);
                    distortionparam.fEdge:=StrTofloatdef(SinglePlayerSettings.ezf[25,2],0);
                    distortionparam.fPostEQCenterFrequency:=StrTofloatdef(SinglePlayerSettings.ezf[25,3],0);
                    distortionparam.fPostEQBandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[25,4],0);
                    distortionparam.fPreLowpassCutoff:=StrToFloatdef(SinglePlayerSettings.ezf[25,5],0);
                    if singleplayersettings.distortion=1 then BASS_FXSetParameters(fxdistortion, @distortionparam);
                    SinglePlayerSettings.ezf[25,1]:=realtostr(distortionparam.fGain,0);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                  if (y>top2-20) and (y<top2+22) then
                   begin
                    if (znachfromcoord(x-30,10,0,100)>101) or (znachfromcoord(x-30,10,0,100)<0) then exit;
                    BASS_ChannelRemoveFX(channel,fxdistortion);
                    fxdistortion := BASS_ChannelSetFX(channel,  BASS_FX_DX8_distortion, 1);
                    BASS_FXGetParameters(fxdistortion, @distortionparam);
                    distortionparam.fGain:=StrTofloatdef(SinglePlayerSettings.ezf[25,1],0);
                    distortionparam.fEdge:=znachfromcoord(x-30,10,0,100);
                    distortionparam.fPostEQCenterFrequency:=StrTofloatdef(SinglePlayerSettings.ezf[25,3],0);
                    distortionparam.fPostEQBandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[25,4],0);
                    distortionparam.fPreLowpassCutoff:=StrToFloatdef(SinglePlayerSettings.ezf[25,5],0);
                    if singleplayersettings.distortion=1 then BASS_FXSetParameters(fxdistortion, @distortionparam);
                    SinglePlayerSettings.ezf[25,2]:=realtostr(distortionparam.fEdge,0);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                  if (y>top3-20) and (y<top3+22) then
                   begin
                    if (znachfromcoord(x-30,10,100,8000)>8001) or (znachfromcoord(x-30,10,100,8000)<100) then exit;
                    BASS_ChannelRemoveFX(channel,fxdistortion);
                    fxdistortion := BASS_ChannelSetFX(channel,  BASS_FX_DX8_distortion, 1);
                    BASS_FXGetParameters(fxdistortion, @distortionparam);
                    distortionparam.fGain:=StrTofloatdef(SinglePlayerSettings.ezf[25,1],0);
                    distortionparam.fEdge:=StrTofloatdef(SinglePlayerSettings.ezf[25,2],0);
                    distortionparam.fPostEQCenterFrequency:=znachfromcoord(x-30,10,100,8000);
                    distortionparam.fPostEQBandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[25,4],0);
                    distortionparam.fPreLowpassCutoff:=StrToFloatdef(SinglePlayerSettings.ezf[25,5],0);
                    if singleplayersettings.distortion=1 then BASS_FXSetParameters(fxdistortion, @distortionparam);
                    SinglePlayerSettings.ezf[25,3]:=realtostr(distortionparam.fPostEQCenterFrequency,0);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                  if (y>top4-20) and (y<top4+22) then
                   begin
                    if (znachfromcoord(x-30,10,100,8000)>8001) or (znachfromcoord(x-30,10,100,8000)<100) then exit;
                    BASS_ChannelRemoveFX(channel,fxdistortion);
                    fxdistortion := BASS_ChannelSetFX(channel,  BASS_FX_DX8_distortion, 1);
                    BASS_FXGetParameters(fxdistortion, @distortionparam);
                    distortionparam.fGain:=StrToFloatdef(SinglePlayerSettings.ezf[25,1],0);
                    distortionparam.fEdge:=StrTofloatdef(SinglePlayerSettings.ezf[25,2],0);
                    distortionparam.fPostEQCenterFrequency:=StrTofloatdef(SinglePlayerSettings.ezf[25,3],0);
                    distortionparam.fPostEQBandwidth:=znachfromcoord(x-30,10,100,8000);
                    distortionparam.fPreLowpassCutoff:=StrToFloatdef(SinglePlayerSettings.ezf[25,5],0);
                    if singleplayersettings.distortion=1 then BASS_FXSetParameters(fxdistortion, @distortionparam);
                    SinglePlayerSettings.ezf[25,4]:=realtostr(distortionparam.fPostEQBandwidth,0);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                  if (y>top5-20) and (y<top5+22) then
                   begin
                    if (znachfromcoord(x-30,10,100,8000)>8001) or (znachfromcoord(x-30,10,100,8000)<100) then exit;
                    BASS_ChannelRemoveFX(channel,fxdistortion);
                    fxdistortion := BASS_ChannelSetFX(channel,  BASS_FX_DX8_distortion, 1);
                    BASS_FXGetParameters(fxdistortion, @distortionparam);
                    distortionparam.fGain:=StrToFloatdef(SinglePlayerSettings.ezf[25,1],0);
                    distortionparam.fEdge:=StrTofloatdef(SinglePlayerSettings.ezf[25,2],0);
                    distortionparam.fPostEQCenterFrequency:=StrTofloatdef(SinglePlayerSettings.ezf[25,3],0);
                    distortionparam.fPostEQBandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[25,4],0);
                    distortionparam.fPreLowpassCutoff:=znachfromcoord(x-30,10,100,8000);
                    if singleplayersettings.distortion=1 then BASS_FXSetParameters(fxdistortion, @distortionparam);
                    SinglePlayerSettings.ezf[25,5]:=realtostr(distortionparam.fPreLowpassCutoff,0);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;

                end;
              end;
    'phaser': begin
               if (x>10) and (x<795) then
                begin
                  if (y>top1-20) and (y<top1+22) then
                   begin
                    if (znachfromcoord(x-30,10000,-2000,2000)>2001) or (znachfromcoord(x-30,10000,-2000,2000)<-2000) then exit;
                    BASS_ChannelRemoveFX(channel,fxphaser);
                    fxphaser := BASS_ChannelSetFX(channel,  BASS_FX_BFX_phaser, 1);
                    BASS_FXGetParameters(fxphaser, @phaserparam);
                    phaserparam.fDryMix:=znachfromcoord(x-30,10000,-2000,2000);
                    phaserparam.fWetMix:=StrTofloatdef(SinglePlayerSettings.ezf[26,2],0);
                    phaserparam.fFeedback:=StrTofloatdef(SinglePlayerSettings.ezf[26,3],0);
                    phaserparam.fRate:=StrToFloatdef(SinglePlayerSettings.ezf[26,4],0);
                    phaserparam.fRange:=StrToFloatdef(SinglePlayerSettings.ezf[26,5],0);
                    phaserparam.fFreq:=StrToFloatdef(SinglePlayerSettings.ezf[26,6],0);
                    if singleplayersettings.phaser=1 then BASS_FXSetParameters(fxphaser, @phaserparam);
                    SinglePlayerSettings.ezf[26,1]:=realtostr(phaserparam.fDryMix,3);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                  if (y>top2-20) and (y<top2+22) then
                   begin
                    if (znachfromcoord(x-30,10000,-2000,2000)>2001) or (znachfromcoord(x-30,10000,-2000,2000)<-2000) then exit;
                    BASS_ChannelRemoveFX(channel,fxphaser);
                    fxphaser := BASS_ChannelSetFX(channel,  BASS_FX_BFX_phaser, 1);
                    BASS_FXGetParameters(fxphaser, @phaserparam);
                    phaserparam.fDryMix:=StrTofloatdef(SinglePlayerSettings.ezf[26,1],0);
                    phaserparam.fWetMix:=znachfromcoord(x-30,10000,-2000,2000);
                    phaserparam.fFeedback:=StrTofloatdef(SinglePlayerSettings.ezf[26,3],0);
                    phaserparam.fRate:=StrToFloatdef(SinglePlayerSettings.ezf[26,4],0);
                    phaserparam.fRange:=StrToFloatdef(SinglePlayerSettings.ezf[26,5],0);
                    phaserparam.fFreq:=StrToFloatdef(SinglePlayerSettings.ezf[26,6],0);
                    if singleplayersettings.phaser=1 then BASS_FXSetParameters(fxphaser, @phaserparam);
                    SinglePlayerSettings.ezf[26,2]:=realtostr(phaserparam.fWetMix,3);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                  if (y>top3-20) and (y<top3+22) then
                   begin
                    if (znachfromcoord(x-30,100,-10,10)>11) or (znachfromcoord(x-30,100,-10,10)<-10) then exit;
                    BASS_ChannelRemoveFX(channel,fxphaser);
                    fxphaser := BASS_ChannelSetFX(channel,  BASS_FX_BFX_phaser, 1);
                    BASS_FXGetParameters(fxphaser, @phaserparam);
                    phaserparam.fDryMix:=StrTofloatdef(SinglePlayerSettings.ezf[26,1],0);
                    phaserparam.fWetMix:=StrTofloatdef(SinglePlayerSettings.ezf[26,2],0);
                    phaserparam.fFeedback:=znachfromcoord(x-30,100,-10,10);
                    phaserparam.fRate:=StrToFloatdef(SinglePlayerSettings.ezf[26,4],0);
                    phaserparam.fRange:=StrToFloatdef(SinglePlayerSettings.ezf[26,5],0);
                    phaserparam.fFreq:=StrToFloatdef(SinglePlayerSettings.ezf[26,6],0);
                    if singleplayersettings.phaser=1 then BASS_FXSetParameters(fxphaser, @phaserparam);
                    SinglePlayerSettings.ezf[26,3]:=realtostr(phaserparam.fFeedback,1);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                  if (y>top4-20) and (y<top4+22) then
                   begin
                    if (znachfromcoord(x-30,10,0,10)>11) or (znachfromcoord(x-30,10,0,10)<0) then exit;
                    BASS_ChannelRemoveFX(channel,fxphaser);
                    fxphaser := BASS_ChannelSetFX(channel,  BASS_FX_BFX_phaser, 1);
                    BASS_FXGetParameters(fxphaser, @phaserparam);
                    phaserparam.fDryMix:=StrToFloatdef(SinglePlayerSettings.ezf[26,1],0);
                    phaserparam.fWetMix:=StrTofloatdef(SinglePlayerSettings.ezf[26,2],0);
                    phaserparam.fFeedback:=StrTofloatdef(SinglePlayerSettings.ezf[26,3],0);
                    phaserparam.fRate:=znachfromcoord(x-30,10,0,10);
                    phaserparam.fRange:=StrToFloatdef(SinglePlayerSettings.ezf[26,5],0);
                    phaserparam.fFreq:=StrToFloatdef(SinglePlayerSettings.ezf[26,6],0);
                    if singleplayersettings.phaser=1 then BASS_FXSetParameters(fxphaser, @phaserparam);
                    SinglePlayerSettings.ezf[26,4]:=realtostr(phaserparam.fRate,1);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                  if (y>top5-20) and (y<top5+22) then
                   begin
                    if (znachfromcoord(x-30,10,0,10)>11) or (znachfromcoord(x-30,10,0,10)<0) then exit;
                    BASS_ChannelRemoveFX(channel,fxphaser);
                    fxphaser := BASS_ChannelSetFX(channel,  BASS_FX_BFX_phaser, 1);
                    BASS_FXGetParameters(fxphaser, @phaserparam);
                    phaserparam.fDryMix:=StrToFloatdef(SinglePlayerSettings.ezf[26,1],0);
                    phaserparam.fWetMix:=StrTofloatdef(SinglePlayerSettings.ezf[26,2],0);
                    phaserparam.fFeedback:=StrTofloatdef(SinglePlayerSettings.ezf[26,3],0);
                    phaserparam.fRate:=StrToFloatdef(SinglePlayerSettings.ezf[26,4],0);
                    phaserparam.fRange:=znachfromcoord(x-30,10,0,10);
                    phaserparam.fFreq:=StrToFloatdef(SinglePlayerSettings.ezf[26,6],0);
                    if singleplayersettings.phaser=1 then BASS_FXSetParameters(fxphaser, @phaserparam);
                    SinglePlayerSettings.ezf[26,5]:=realtostr(phaserparam.fRange,1);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                  if (y>top6-20) and (y<top6+22) then
                   begin
                    if (znachfromcoord(x-30,10,0,1000)>1001) or (znachfromcoord(x-30,10,0,1000)<0) then exit;
                    BASS_ChannelRemoveFX(channel,fxphaser);
                    fxphaser := BASS_ChannelSetFX(channel,  BASS_FX_BFX_phaser, 1);
                    BASS_FXGetParameters(fxphaser, @phaserparam);
                    phaserparam.fDryMix:=StrToFloatdef(SinglePlayerSettings.ezf[26,1],0);
                    phaserparam.fWetMix:=StrTofloatdef(SinglePlayerSettings.ezf[26,2],0);
                    phaserparam.fFeedback:=StrTofloatdef(SinglePlayerSettings.ezf[26,3],0);
                    phaserparam.fRate:=StrToFloatdef(SinglePlayerSettings.ezf[26,4],0);
                    phaserparam.fRange:=StrToFloatdef(SinglePlayerSettings.ezf[26,5],0);
                    phaserparam.fFreq:=znachfromcoord(x-30,10,0,1000);
                    if singleplayersettings.phaser=1 then BASS_FXSetParameters(fxphaser, @phaserparam);
                    SinglePlayerSettings.ezf[26,6]:=realtostr(phaserparam.fFreq,0);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;

                  end;
                 end;
    'freeverb': begin
               if (x>10) and (x<795) then
                begin
                  if (y>top1-20) and (y<top1+22) then
                   begin
                    if (znachfromcoord(x-30,100,0,10)>11) or (znachfromcoord(x-30,100,0,10)<0) then exit;
                    BASS_ChannelRemoveFX(channel,fxFREEVERB);
                    fxFREEVERB := BASS_ChannelSetFX(channel,  BASS_FX_BFX_FREEVERB, 1);
                    BASS_FXGetParameters(fxFREEVERB, @FREEVERBparam);
                    FREEVERBparam.fDryMix:=znachfromcoord(x-30,100,0,10);
                    FREEVERBparam.fWetMix:=StrTofloatdef(SinglePlayerSettings.ezf[27,2],0);
                    FREEVERBparam.fRoomSize:=StrTofloatdef(SinglePlayerSettings.ezf[27,3],0);
                    FREEVERBparam.fDamp:=StrToFloatdef(SinglePlayerSettings.ezf[27,4],0);
                    FREEVERBparam.fWidth:=StrToFloatdef(SinglePlayerSettings.ezf[27,5],0);
                    if SinglePlayerSettings.FREEVERB=1 then BASS_FXSetParameters(fxFREEVERB, @FREEVERBparam);
                    SinglePlayerSettings.ezf[27,1]:=realtostr(FREEVERBparam.fDryMix,1);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                  if (y>top2-20) and (y<top2+22) then
                   begin
                    if (znachfromcoord(x-30,100,0,30)>31) or (znachfromcoord(x-30,100,0,30)<0) then exit;
                    BASS_ChannelRemoveFX(channel,fxFREEVERB);
                    fxFREEVERB := BASS_ChannelSetFX(channel,  BASS_FX_BFX_FREEVERB, 1);
                    BASS_FXGetParameters(fxFREEVERB, @FREEVERBparam);
                    FREEVERBparam.fDryMix:=StrTofloatdef(SinglePlayerSettings.ezf[27,1],0);
                    FREEVERBparam.fWetMix:=znachfromcoord(x-30,100,0,30);
                    FREEVERBparam.fRoomSize:=StrTofloatdef(SinglePlayerSettings.ezf[27,3],0);
                    FREEVERBparam.fDamp:=StrToFloatdef(SinglePlayerSettings.ezf[27,4],0);
                    FREEVERBparam.fWidth:=StrToFloatdef(SinglePlayerSettings.ezf[27,5],0);
                    if SinglePlayerSettings.FREEVERB=1 then BASS_FXSetParameters(fxFREEVERB, @FREEVERBparam);
                    SinglePlayerSettings.ezf[27,2]:=realtostr(FREEVERBparam.fWetMix,1);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                  if (y>top3-20) and (y<top3+22) then
                   begin
                    if (znachfromcoord(x-30,100,0,10)>11) or (znachfromcoord(x-30,100,0,10)<0) then exit;
                    BASS_ChannelRemoveFX(channel,fxFREEVERB);
                    fxFREEVERB := BASS_ChannelSetFX(channel,  BASS_FX_BFX_FREEVERB, 1);
                    BASS_FXGetParameters(fxFREEVERB, @FREEVERBparam);
                    FREEVERBparam.fDryMix:=StrTofloatdef(SinglePlayerSettings.ezf[27,1],0);
                    FREEVERBparam.fWetMix:=StrTofloatdef(SinglePlayerSettings.ezf[27,2],0);
                    FREEVERBparam.fRoomSize:=znachfromcoord(x-30,100,0,10);
                    FREEVERBparam.fDamp:=StrToFloatdef(SinglePlayerSettings.ezf[27,4],0);
                    FREEVERBparam.fWidth:=StrToFloatdef(SinglePlayerSettings.ezf[27,5],0);
                    if SinglePlayerSettings.FREEVERB=1 then BASS_FXSetParameters(fxFREEVERB, @FREEVERBparam);
                    SinglePlayerSettings.ezf[27,3]:=realtostr(FREEVERBparam.fRoomSize,1);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                  if (y>top4-20) and (y<top4+22) then
                   begin
                    if (znachfromcoord(x-30,100,0,10)>11) or (znachfromcoord(x-30,100,0,10)<0) then exit;
                    BASS_ChannelRemoveFX(channel,fxFREEVERB);
                    fxFREEVERB := BASS_ChannelSetFX(channel,  BASS_FX_BFX_FREEVERB, 1);
                    BASS_FXGetParameters(fxFREEVERB, @FREEVERBparam);
                    FREEVERBparam.fDryMix:=StrToFloatdef(SinglePlayerSettings.ezf[27,1],0);
                    FREEVERBparam.fWetMix:=StrTofloatdef(SinglePlayerSettings.ezf[27,2],0);
                    FREEVERBparam.fRoomSize:=StrTofloatdef(SinglePlayerSettings.ezf[27,3],0);
                    FREEVERBparam.fDamp:=znachfromcoord(x-30,100,0,10);
                    FREEVERBparam.fWidth:=StrToFloatdef(SinglePlayerSettings.ezf[27,5],0);
                    if SinglePlayerSettings.FREEVERB=1 then BASS_FXSetParameters(fxFREEVERB, @FREEVERBparam);
                    SinglePlayerSettings.ezf[27,4]:=realtostr(FREEVERBparam.fDamp,1);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                  if (y>top5-20) and (y<top5+22) then
                   begin
                    if (znachfromcoord(x-30,100,0,10)>11) or (znachfromcoord(x-30,100,0,10)<0) then exit;
                    BASS_ChannelRemoveFX(channel,fxFREEVERB);
                    fxFREEVERB := BASS_ChannelSetFX(channel,  BASS_FX_BFX_FREEVERB, 1);
                    BASS_FXGetParameters(fxFREEVERB, @FREEVERBparam);
                    FREEVERBparam.fDryMix:=StrToFloatdef(SinglePlayerSettings.ezf[27,1],0);
                    FREEVERBparam.fWetMix:=StrTofloatdef(SinglePlayerSettings.ezf[27,2],0);
                    FREEVERBparam.fRoomSize:=StrTofloatdef(SinglePlayerSettings.ezf[27,3],0);
                    FREEVERBparam.fDamp:=StrToFloatdef(SinglePlayerSettings.ezf[27,4],0);
                    FREEVERBparam.fWidth:=znachfromcoord(x-30,100,0,10);
                    if SinglePlayerSettings.FREEVERB=1 then BASS_FXSetParameters(fxFREEVERB, @FREEVERBparam);
                    SinglePlayerSettings.ezf[27,5]:=realtostr(FREEVERBparam.fWidth,1);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                end;
               end;
    'autowah': begin
               if (x>10) and (x<795) then
                begin
                  if (y>top1-20) and (y<top1+22) then
                   begin
                    if (znachfromcoord(x-30,10000,-2000,2000)>2001) or (znachfromcoord(x-30,10000,-2000,2000)<-2000) then exit;
                    BASS_ChannelRemoveFX(channel,fxautowah);
                    fxautowah := BASS_ChannelSetFX(channel,  BASS_FX_BFX_autowah, 1);
                    BASS_FXGetParameters(fxautowah, @autowahparam);
                    autowahparam.fDryMix:=znachfromcoord(x-30,10000,-2000,2000);
                    autowahparam.fWetMix:=StrTofloatdef(SinglePlayerSettings.ezf[28,2],0);
                    autowahparam.fFeedback:=StrTofloatdef(SinglePlayerSettings.ezf[28,3],0);
                    autowahparam.fRate:=StrToFloatdef(SinglePlayerSettings.ezf[28,4],0);
                    autowahparam.fRange:=StrToFloatdef(SinglePlayerSettings.ezf[28,5],0);
                    autowahparam.fFreq:=StrToFloatdef(SinglePlayerSettings.ezf[28,6],0);
                    if singleplayersettings.autowah=1 then BASS_FXSetParameters(fxautowah, @autowahparam);
                    SinglePlayerSettings.ezf[28,1]:=realtostr(autowahparam.fDryMix,3);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                  if (y>top2-20) and (y<top2+22) then
                   begin
                    if (znachfromcoord(x-30,10000,-2000,2000)>2001) or (znachfromcoord(x-30,10000,-2000,2000)<-2000) then exit;
                    BASS_ChannelRemoveFX(channel,fxautowah);
                    fxautowah := BASS_ChannelSetFX(channel,  BASS_FX_BFX_autowah, 1);
                    BASS_FXGetParameters(fxautowah, @autowahparam);
                    autowahparam.fDryMix:=StrTofloatdef(SinglePlayerSettings.ezf[28,1],0);
                    autowahparam.fWetMix:=znachfromcoord(x-30,10000,-2000,2000);
                    autowahparam.fFeedback:=StrTofloatdef(SinglePlayerSettings.ezf[28,3],0);
                    autowahparam.fRate:=StrToFloatdef(SinglePlayerSettings.ezf[28,4],0);
                    autowahparam.fRange:=StrToFloatdef(SinglePlayerSettings.ezf[28,5],0);
                    autowahparam.fFreq:=StrToFloatdef(SinglePlayerSettings.ezf[28,6],0);
                    if singleplayersettings.autowah=1 then BASS_FXSetParameters(fxautowah, @autowahparam);
                    SinglePlayerSettings.ezf[28,2]:=realtostr(autowahparam.fWetMix,3);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                  if (y>top3-20) and (y<top3+22) then
                   begin
                    if (znachfromcoord(x-30,100,-10,10)>11) or (znachfromcoord(x-30,100,-10,10)<-10) then exit;
                    BASS_ChannelRemoveFX(channel,fxautowah);
                    fxautowah := BASS_ChannelSetFX(channel,  BASS_FX_BFX_autowah, 1);
                    BASS_FXGetParameters(fxautowah, @autowahparam);
                    autowahparam.fDryMix:=StrTofloatdef(SinglePlayerSettings.ezf[28,1],0);
                    autowahparam.fWetMix:=StrTofloatdef(SinglePlayerSettings.ezf[28,2],0);
                    autowahparam.fFeedback:=znachfromcoord(x-30,100,-10,10);
                    autowahparam.fRate:=StrToFloatdef(SinglePlayerSettings.ezf[28,4],0);
                    autowahparam.fRange:=StrToFloatdef(SinglePlayerSettings.ezf[28,5],0);
                    autowahparam.fFreq:=StrToFloatdef(SinglePlayerSettings.ezf[28,6],0);
                    if singleplayersettings.autowah=1 then BASS_FXSetParameters(fxautowah, @autowahparam);
                    SinglePlayerSettings.ezf[28,3]:=realtostr(autowahparam.fFeedback,1);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                  if (y>top4-20) and (y<top4+22) then
                   begin
                    if (znachfromcoord(x-30,10,0,10)>11) or (znachfromcoord(x-30,10,0,10)<0) then exit;
                    BASS_ChannelRemoveFX(channel,fxautowah);
                    fxautowah := BASS_ChannelSetFX(channel,  BASS_FX_BFX_autowah, 1);
                    BASS_FXGetParameters(fxautowah, @autowahparam);
                    autowahparam.fDryMix:=StrToFloatdef(SinglePlayerSettings.ezf[28,1],0);
                    autowahparam.fWetMix:=StrTofloatdef(SinglePlayerSettings.ezf[28,2],0);
                    autowahparam.fFeedback:=StrTofloatdef(SinglePlayerSettings.ezf[28,3],0);
                    autowahparam.fRate:=znachfromcoord(x-30,10,0,10);
                    autowahparam.fRange:=StrToFloatdef(SinglePlayerSettings.ezf[28,5],0);
                    autowahparam.fFreq:=StrToFloatdef(SinglePlayerSettings.ezf[28,6],0);
                    if singleplayersettings.autowah=1 then BASS_FXSetParameters(fxautowah, @autowahparam);
                    SinglePlayerSettings.ezf[28,4]:=realtostr(autowahparam.fRate,1);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                  if (y>top5-20) and (y<top5+22) then
                   begin
                    if (znachfromcoord(x-30,10,0,10)>11) or (znachfromcoord(x-30,10,0,10)<0) then exit;
                    BASS_ChannelRemoveFX(channel,fxautowah);
                    fxautowah := BASS_ChannelSetFX(channel,  BASS_FX_BFX_autowah, 1);
                    BASS_FXGetParameters(fxautowah, @autowahparam);
                    autowahparam.fDryMix:=StrToFloatdef(SinglePlayerSettings.ezf[28,1],0);
                    autowahparam.fWetMix:=StrTofloatdef(SinglePlayerSettings.ezf[28,2],0);
                    autowahparam.fFeedback:=StrTofloatdef(SinglePlayerSettings.ezf[28,3],0);
                    autowahparam.fRate:=StrToFloatdef(SinglePlayerSettings.ezf[28,4],0);
                    autowahparam.fRange:=znachfromcoord(x-30,10,0,10);
                    autowahparam.fFreq:=StrToFloatdef(SinglePlayerSettings.ezf[28,6],0);
                    if singleplayersettings.autowah=1 then BASS_FXSetParameters(fxautowah, @autowahparam);
                    SinglePlayerSettings.ezf[28,5]:=realtostr(autowahparam.fRange,1);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;
                  if (y>top6-20) and (y<top6+22) then
                   begin
                    if (znachfromcoord(x-30,10,0,1000)>1001) or (znachfromcoord(x-30,10,0,1000)<0) then exit;
                    BASS_ChannelRemoveFX(channel,fxautowah);
                    fxautowah := BASS_ChannelSetFX(channel,  BASS_FX_BFX_autowah, 1);
                    BASS_FXGetParameters(fxautowah, @autowahparam);
                    autowahparam.fDryMix:=StrToFloatdef(SinglePlayerSettings.ezf[28,1],0);
                    autowahparam.fWetMix:=StrTofloatdef(SinglePlayerSettings.ezf[28,2],0);
                    autowahparam.fFeedback:=StrTofloatdef(SinglePlayerSettings.ezf[28,3],0);
                    autowahparam.fRate:=StrToFloatdef(SinglePlayerSettings.ezf[28,4],0);
                    autowahparam.fRange:=StrToFloatdef(SinglePlayerSettings.ezf[28,5],0);
                    autowahparam.fFreq:=znachfromcoord(x-30,10,0,1000);
                    if singleplayersettings.autowah=1 then BASS_FXSetParameters(fxautowah, @autowahparam);
                    SinglePlayerSettings.ezf[28,6]:=realtostr(autowahparam.fFreq,0);
                    SinglePlayerGUI.Invalidate;
                    exit;
                   end;

                  end;
                 end;

    'p1': begin eqmove(x,y,1); SinglePlayerGUI.Invalidate; exit; end;
    'p2': begin eqmove(x,y,2); SinglePlayerGUI.Invalidate; exit; end;
    'p3': begin eqmove(x,y,3); SinglePlayerGUI.Invalidate; exit; end;
    'p4': begin eqmove(x,y,4); SinglePlayerGUI.Invalidate; exit; end;
    'p5': begin eqmove(x,y,5); SinglePlayerGUI.Invalidate; exit; end;
    'p6': begin eqmove(x,y,6); SinglePlayerGUI.Invalidate; exit; end;
    'p7': begin eqmove(x,y,7); SinglePlayerGUI.Invalidate; exit; end;
    'p8': begin eqmove(x,y,8); SinglePlayerGUI.Invalidate; exit; end;
    'p9': begin eqmove(x,y,9); SinglePlayerGUI.Invalidate; exit; end;
    'p10': begin eqmove(x,y,10); SinglePlayerGUI.Invalidate; exit; end;
    'p11': begin eqmove(x,y,11); SinglePlayerGUI.Invalidate; exit; end;
    'p12': begin eqmove(x,y,12); SinglePlayerGUI.Invalidate; exit; end;
    'p13': begin eqmove(x,y,13); SinglePlayerGUI.Invalidate; exit; end;

    else exit;
   end;
   SinglePlayerGUI.Invalidate;
  end;

 if (curentpage='eq'){$IFNDEF WInCE} and (ssLeft in Shift){$ENDIF} then
  begin
   for i:=1 to 13 do
     begin
      if (x>=eqfcor[i,1]) and (x<=eqfcor[i,1]+seticons[getindexiconexec('equp')].width) and (y>=eqfcor[i,2]+seticons[getindexiconexec('equp')].height) and (y<eqfcor[i,4]) then
       begin
        SinglePlayerSettings.ezf[i,1]:=inttostr(znacheqwgeel(y));
        SinglePlayerGUI.Invalidate;
        if SinglePlayerSettings.eqsetnow=1 then
         begin
          if mode=play then eqapply(channel);
          if mode=radioplay then eqapply(radiochannel);
         end;
       end;
     end;
    SinglePlayerGUI.Invalidate;
    exit;
  end;

end;


procedure eqmove(x,y,i:integer);
begin
               if (x>10) and (x<795) then
                begin
                 if (y>top1-20) and (y<top1+22) then
                  begin
                   if (freqfromcoord(x-30)>18000) or (freqfromcoord(x-30)<1) then exit;
                     BASS_ChannelRemoveFX(channel,fx[i]);
                     fx[i] := BASS_ChannelSetFX(channel, BASS_FX_DX8_PARAMEQ, 1);
                     BASS_FXGetParameters(fx[i], @p[i]);
                     p[i].fGain:=strtofloatdef(SinglePlayerSettings.ezf[i,1],0);
                     p[i].fBandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[i,2],0);
                     p[i].fCenter:=freqfromcoord(x-30);
                     if singleplayersettings.eqon=1 then BASS_FXSetParameters(fx[i], @p[i]);
                     SinglePlayerSettings.ezf[i,3]:=realtostr(p[i].fCenter,0);
                     SinglePlayerGUI.Invalidate;
                  end;
                 if (y>top3-20) and (y<top3+22) then
                  begin
                   if (znachfromcoord(x-30,10,-15,15)>16) or (znachfromcoord(x-30,10,-15,15)<-16) then exit;
                     BASS_ChannelRemoveFX(channel,fx[i]);
                     fx[i] := BASS_ChannelSetFX(channel, BASS_FX_DX8_PARAMEQ, 1);
                     BASS_FXGetParameters(fx[i], @p[i]);
                     p[i].fGain:=znachfromcoord(x-30,10,-15,15);
                     p[i].fBandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[i,2],0);
                     p[i].fCenter:=strtointdef(SinglePlayerSettings.ezf[i,3],0);
                     if singleplayersettings.eqon=1 then BASS_FXSetParameters(fx[i], @p[i]);
                     SinglePlayerSettings.ezf[i,1]:=realtostr(p[i].fgain,0);
                     SinglePlayerGUI.Invalidate;
                  end;
                 if (y>top6-20) and (y<top6+22) then
                  begin
                   if (znachfromcoord(x-30,10,1,36)>37) or (znachfromcoord(x-30,10,1,36)<0) then exit;
                     BASS_ChannelRemoveFX(channel,fx[i]);
                     fx[i] := BASS_ChannelSetFX(channel, BASS_FX_DX8_PARAMEQ, 1);
                     BASS_FXGetParameters(fx[i], @p[i]);
                     p[i].fGain:=strtofloatdef(SinglePlayerSettings.ezf[i,1],0);
                     p[i].fBandwidth:=znachfromcoord(x-30,10,1,36);
                     p[i].fCenter:=strtointdef(SinglePlayerSettings.ezf[i,3],0);
                     if singleplayersettings.eqon=1 then BASS_FXSetParameters(fx[i], @p[i]);
                     SinglePlayerSettings.ezf[i,2]:=realtostr(p[i].fBandwidth,1);
                     SinglePlayerGUI.Invalidate;
                  end;
                end;
end;



procedure TSinglePlayerGUI.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i,k,k2,notfdir:integer;
  exec,execopt,itdir:string;
  curworkskinini:tinifile;
begin
 try
  moveexit:=2;
  itdir:='';
  if mousestate=2 then begin mousestate:=0; exit; end else mousestate:=0;
  {---------------------- выключение перемотки--------------------}
 if SinglePlayerSettings.peremotka=1 then
  begin
   startnextbut:=0;
   napr:='';
   SinglePlayerGUI.Peremotkatimer.Enabled:=false;
   stopspeed:=1;
  end;
 {---------------------------------------------------------------------}
 PolSecondTimer.Enabled:=true;
 SinglePlayerGUI.Invalidate;
 if button=mbLeft then
  begin
 {-----------------------------------------------------------------------------}
   if msgtap<>0 then
    begin
   if (msgdelX<>-1) and (msgdelY<>-1) and (curworktrack<>'') then    {отработка сообщения об удалении трека в плейлисте}
    begin
     if (x>msgdelX) and (x<msgdelX2) and (y>msgdelY) and (y<msgdelY2) then
      begin
       delfromdisk(curworktrack);
       SinglePlayerGUI.invalidate;
       exit;
      end;
    end;

   if msgtap=1 then begin msgtap:=0; SinglePlayerGUI.invalidate; exit; end;
   {отработка сообщения об копировании трека в плейлист фаворитов}
{-------------------------------------------------------------------------------------------}
   if (msgfavX<>-1) and (msgfavY<>-1) and (curworktrack<>'') then
    begin
     if (x>msgfavX) and (x<msgfavX2) and (y>msgfavY) and (y<msgfavY2) then
      begin
       favtopls(curworktrack);
       SinglePlayerGUI.invalidate;
       exit;
      end;
    end;

   if (msgfavX3<>-1) and (msgfavY3<>-1) and (curworktrack<>'') then     {отработка сообщения об копировании трека в отдельную папку и плейлист фаворитов}
    begin
     if (x>msgfavX3) and (x<msgfavX4) and (y>msgfavY3) and (y<msgfavY4) then
      begin
       favtoplsandfolder(curworktrack);
       SinglePlayerGUI.canvas.Font.Color:=$00FFFF;
       SinglePlayerGUI.Canvas.Font.Size:=18;
       SinglePlayerGUI.Canvas.Font.Bold:=true;
       SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),330,180,'Готово!');
       SinglePlayerGUI.Canvas.Font.Bold:=false;
       sleep(1000);
       SinglePlayerGUI.invalidate;
       exit;
      end;
    end;
   if msgtap=2 then begin msgtap:=0; SinglePlayerGUI.invalidate; exit; end;
 {-----------------------------------------------------------------------------------------------------}
   if (msgaddflashbt1X<>-1) and (msgaddflashbt1Y<>-1) and (curworkusb<>'') then
    begin
     if (x>msgaddflashbt1X) and (x<msgaddflashbt1X2) and (y>msgaddflashbt1Y) and (y<msgaddflashbt1Y2) then
      begin
       playusb(curworkusb,1);       {0 - создать, 1 - добавить}
       msgaddflashbt1X:=-1;
       msgaddflashbt1Y:=-1;
       msgtap:=0;
       SinglePlayerGUI.invalidate;
       exit;
      end;
    end;
   if (msgaddflashbt2X<>-1) and (msgaddflashbt2Y<>-1) and (curworkusb<>'') then
    begin
     if (x>msgaddflashbt2X) and (x<msgaddflashbt2X2) and (y>msgaddflashbt2Y) and (y<msgaddflashbt2Y2) then
      begin
       playusb(curworkusb,0);       {0 - создать, 1 - добавить}
       msgaddflashbt2X:=-1;
       msgaddflashbt2Y:=-1;
       msgtap:=0;
       SinglePlayerGUI.invalidate;
       exit;
      end;
    end;

   if (msgaddflashstrleftX<>-1) and (msgaddflashstrleftY<>-1) and (curworkusb<>'') then
    begin
     if (x>msgaddflashstrleftX) and (x<msgaddflashstrleftX2) and (y>msgaddflashstrleftY) and (y<msgaddflashstrleftY2) then
      begin
       dec(SinglePlayerSettings.curentplaylist);
       if SinglePlayerSettings.curentplaylist<1 then SinglePlayerSettings.curentplaylist:=kollpls-1;
       SinglePlayerGUI.invalidate;
       exit;
      end;
    end;
   if (msgaddflashstrrgX<>-1) and (msgaddflashstrrgY<>-1) and (curworkusb<>'') then
    begin
     if (x>msgaddflashstrrgX) and (x<msgaddflashstrrgX2) and (y>msgaddflashstrrgY) and (y<msgaddflashstrrgY2) then
      begin
       inc(SinglePlayerSettings.curentplaylist);
       if SinglePlayerSettings.curentplaylist>kollpls-1 then SinglePlayerSettings.curentplaylist:=1;
       SinglePlayerGUI.invalidate;
       exit;
      end;
    end;
    if msgtap=3 then begin msgtap:=0; SinglePlayerGUI.invalidate; exit; end;
{----------------- сообщение смены скина -------------------------------------}
    if (msgskinchangeleftX<>-1) and (msgskinchangeleftY<>-1) then
     begin
       if (x>msgskinchangeleftX) and (x<msgskinchangeleftX2) and (y>msgskinchangeleftY) and (y<msgskinchangeleftY2) then
        begin
         {вставить процедуру смены выбранного кина}
         setskin(curworkskin);
         SinglePlayerGUI.invalidate;
         exit;
        end;
     end;
    if msgtap=4 then
     begin
      msgtap:=0;
      if prewskin.Handle<>0 then prewskin.Free;
      SinglePlayerGUI.invalidate;
      exit;
     end;
{-----------------------------------------------------------------------------}
   end;

{-------------------------------------------------------------------------------------}
    for i:=1 to allicons do
     begin
       if (x>seticons[i].left)
       and (x<seticons[i].left+seticons[i].width)
       and (y>seticons[i].top)
       and (y<seticons[i].top+seticons[i].height) and (clickedicon=i) then
        begin
         if (pos(curentpage,seticons[i].typeicon)<>0) and (seticons[i].visible='true') then
          begin
           case seticons[i].exec of
            'halt': PlayerExit;
            'playerexit': PlayerExit;
            'singleplayer': begin if curentpage<>'singleplayer' then begin oldpage:=curentpage; curentpage:='singleplayer'; SinglePlayerGUI.invalidate; if mode=closed then SinglePlayerStart; exit; end; end;
            'iradio': begin if curentpage<>'iradio' then begin oldpage:=curentpage; curentpage:='iradio'; SinglePlayerGUI.invalidate; if mode<>closed then IRadioStart; exit; end; end;
            'singlestopplay': begin SingleStopPlay; SinglePlayerGUI.Invalidate; exit; end;
            'minimize':
              begin
              SinglePlayerGUI.Hide;
              {$IFDEF SP_STANDALONE}
              senderstr('minimize');
              checkexplorer;
              {$ENDIF}
              end;
            'iradioexit': begin
                           connecting:=0;
                           radioerror:=1;
                           curentpage:='singleplayer';
                           if mode=radioplay then
                            begin
                             bass_free();
                             setinitbass;
                            end;
                           SinglePlayerGUI.invalidate;
                           exit;
                          end;
            'iradiomin': begin curentpage:=oldpage; SinglePlayerGUI.invalidate; exit; end;
            'playurl': begin
                 connecting:=0;
                 radioerror:=1;
                 conradiostr:='"'+seticons[i].text+'"';
                 curentradio:=seticons[i].text;
                 radioimage:=seticons[i].caption;
                 IRadioPlay(seticons[i].execopt);
                 curenttrack:=seticons[i].execopt;
                 SinglePlayerGUI.Invalidate;
                 exit;
                      end;
            'explorer': begin
              if curentpage<>'explorer' then
               begin
                SinglePlayerSettings.folderadd:=0;
                playlistadd:=0;
                if (curentdir<>'') and (directoryexists(curentdir)) then
                 begin
                  curentpage:='disktree';
                  if pageindex=0 then pageindex:=1;
                  getkollpagekey:=1;
                  SinglePlayerGUI.invalidate;
                  exit;
                 end else
                 begin
                  curentpage:='explorer';
                  SinglePlayerGUI.invalidate;
                  exit;
                 end;
               end;
              end;
            'exploreradd': begin
              if curentpage<>'explorer' then
               begin
                SinglePlayerSettings.folderadd:=0;
                playlistadd:=1;
                if (curentdir<>'') and (directoryexists(curentdir)) then
                 begin
                  curentpage:='disktree';
                  if pageindex=0 then pageindex:=1;
                  getkollpagekey:=1;
                  SinglePlayerGUI.invalidate;
                  exit;
                 end else
                 begin
                 curentpage:='explorer';
                 SinglePlayerGUI.invalidate;
                 exit;
                end;

               end;
                          end;
            'dirback':
             begin
              if pos('\',curentdir)=0 then begin if curentpage<>'explorer' then
               begin
                folders:=nil;
                pageindex:=1;
                kollpage:=1;
                curentpage:='explorer';
                SinglePlayerGUI.invalidate;
                exit;
               end;
              end;
              if curentdir<>'' then
               begin
                paintplayericon(curentpage);
                kollpage:=1;
                pageindex:=1;
                curentdir:=copy(curentdir,0,PosR2L('\',curentdir)-1);
                getkollpagekey:=1;
               end;
              SinglePlayerGUI.Invalidate;
              exit;
             end;
            'explorerexit': begin curentpage:='singleplayer'; clearmanymass; SinglePlayerGUI.invalidate; exit; end;
            'disktree':
              begin
               GetTap;
               curentdir:=copy(seticons[i].caption,0,pos('.',seticons[i].caption)-1);
               if not ShortTap then
               begin
                if enumworked=0 then
                 begin
                  itfolder:=1;
                  enumworked:=1;     //закоментировать строку если нужно ограничить количество одновременных потоков сканирования до 1
                  expmanyfolder;
                  scanningstr:=getfromlangpack('scanfolder');
                  Application.ProcessMessages;
                  findmarked:=findmarkedp.Create(true);
                  findmarked.freeonterminate := true;
                  findmarked.priority := tpHigher;   {tpIdle tpLowest tpLower tpNormal tpHigher tpHighest tpTimeCritical}
                  findmarked.findddir:='\'+curentdir;
                  SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.statustextleft,getfromlangpack('saveplaylist'),1),plset.statustexttop,getfromlangpack('saveplaylist'));
                  curentpage:='singleplayer';
                  curentdir:='';
                  statusplaylist:=1;
                  SinglePlayerGUI.Refresh;
                  Sleep(200);
                  statusplaylist:=0;
                  curenttrack:='';
                  playlistadd:=0;
                  findmarked.Start;
                  exit;
                 end;
               end;
               curentpage:='disktree';
               if pageindex=0 then pageindex:=1;
               paintplayericon(curentpage);
               getkollpagekey:=1;
               SinglePlayerGUI.Invalidate;
               exit;
              end;
            'nexttrack': begin
              if SinglePlayerSettings.peremotka=1 then
               begin
                startnextbut:=0;
                napr:='forw';
                key8(0);
               end else
               begin
                playnexttrack;
               end;
               SinglePlayerGUI.Invalidate;
               exit;
                        end;
            'prevtrack':begin
                          if SinglePlayerSettings.peremotka=1 then
                           begin
                            startnextbut:=0;
                            napr:='back';
                            key8(0);
                           end else
                           begin
                            playprevtrack;
                           end;
                           SinglePlayerGUI.Invalidate;
                           exit;
                        end;
            'nextfolder': begin playnextfolder; exit; end;
            'prevfolder': begin playprevfolder; exit; end;
            'exptree': begin exptree; SinglePlayerGUI.Invalidate; exit; end;
            'expsetka': begin expsetka; SinglePlayerGUI.Invalidate; exit; end;
            'sortabc': begin sortabc; gettree(curentdir,pospage[pageindex]); SinglePlayerGUI.Invalidate; exit; end;
            'sortdate': begin sortdate; gettree(curentdir,pospage[pageindex]); SinglePlayerGUI.Invalidate; exit; end;
            'sortdateinv': begin sortdateinv; gettree(curentdir,pospage[pageindex]); SinglePlayerGUI.Invalidate; exit; end;
            'nextpls': begin AfterSwipe:=0; nextpls;  SinglePlayerGUI.Invalidate; exit; end;
            'prevpls': begin AfterSwipe:=0; prevpls;  SinglePlayerGUI.Invalidate; exit; end;
            'shuffle': begin SinglePlayerSettings.shufflekey:=1; SinglePlayerSettings.playone:=0; plsettingsznach[2,3]:='0'; SinglePlayerGUI.invalidate; exit; end;
            'playone': begin SinglePlayerSettings.playone:=1; plsettingsznach[2,3]:='1'; SinglePlayerGUI.invalidate; exit; end;
            'nonerej': begin SinglePlayerSettings.shufflekey:=0; SinglePlayerSettings.playone:=0; plsettingsznach[2,3]:='0'; SinglePlayerGUI.invalidate; exit; end;
            'timetracknap': begin timetracknap; SinglePlayerGUI.Invalidate; exit; end;
            'volup': begin volup; SinglePlayerGUI.Invalidate; exit; end;
            'voldown': begin voldown; SinglePlayerGUI.Invalidate; exit; end;
            'sysvolup': begin sysvolup; SinglePlayerGUI.Invalidate; exit; end;
            'sysvoldown': begin sysvoldown; SinglePlayerGUI.Invalidate; exit; end;
            'muteon': begin muteon; SinglePlayerGUI.Invalidate; exit; end;
            'muteoff': begin muteoff; SinglePlayerGUI.Invalidate; exit; end;
            'randomizepls': begin randomizepls; SinglePlayerGUI.Invalidate; exit; end;
            'cicleplson': begin cicleplson; SinglePlayerGUI.Invalidate; exit; end;
            'cicleplsoff': begin cicleplsoff; SinglePlayerGUI.Invalidate; exit; end;
            'folderaddon': begin folderaddon; SinglePlayerGUI.Invalidate; exit; end;
            'folderaddoff': begin folderaddoff; SinglePlayerGUI.Invalidate; exit; end;
            'sysvolchangeon': begin singleplayersettings.sysvolchange:=1; SinglePlayerGUI.Invalidate; exit; end;
            'sysvolchangeoff': begin singleplayersettings.sysvolchange:=0; SinglePlayerGUI.Invalidate; exit; end;
            'wheeloneon': begin wheeloneon; SinglePlayerGUI.Invalidate; exit; end;
            'wheeloneoff': begin wheeloneoff; SinglePlayerGUI.Invalidate; exit; end;
            'manyaddon': begin manyaddon; SinglePlayerGUI.Invalidate; exit; end;
            'manyaddoff': begin manyaddoff; SinglePlayerGUI.Invalidate; exit; end;
            'manyaddstart': begin manyaddstart; SinglePlayerGUI.Invalidate; exit; end;
            'plssort': begin statusplaylist:=0; sortplaylistthead;  SinglePlayerGUI.Invalidate; exit; end;
            'plsclear': begin plsclear; SinglePlayerGUI.invalidate; exit; end;
            'addtonextall': begin addtonextall; exit; end;
            'stopconnecting':begin connecting:=0; radioerror:=1; SinglePlayerGUI.Invalidate; exit; end;
            'keyboardmodesw': begin  if keyboardmode<kollraskl then inc(keyboardmode) else keyboardmode:=1; SinglePlayerGUI.invalidate; exit; end;
            'eq': begin if curentpage<>'eq' then begin curentpage:='eq'; SinglePlayerGUI.invalidate; exit; end; end;
            'playlistexit': begin {$IFDEF SP_STANDALONE}SendMessage{$ELSE}PostMessage{$ENDIF}(MMCCore.Handle,wm_IMCommand,0,0); curentpage:='singleplayer'; SinglePlayerSettings.playedtrack:=gettrackindex(curenttrack); SinglePlayerGUI.invalidate; exit; end;
            'plsnextpage': begin
             inc(curplspage);
             AfterSwipe:=0;
             playlistferstopen:=0;
             SinglePlayerGUI.Invalidate;
             exit;
                           end;
            'plsforwpage': begin
              dec(curplspage);
              AfterSwipe:=0;
              playlistferstopen:=0;
              SinglePlayerGUI.Invalidate;
              exit;
                           end;
            'playlist': begin
             if curentpage<>'playlist' then
              begin
               playlistferstopen:=1;
               curentpage:='playlist';
               {$IFDEF SP_STANDALONE}SendMessage{$ELSE}PostMessage{$ENDIF}(MMCCore.Handle,wm_IMCommand,1,0);
               SinglePlayerGUI.invalidate;
               exit;
              end;
                       end;
            'playersettings': begin
              if curentpage<>'playersettings' then
               begin
                if loadiconkl=1 then plsett:=0 else plsett:=1; itsicon:=getindexicon('generalsetpl.bmp');
                plsetread;
                curentpage:='playersettings';
                SinglePlayerGUI.invalidate;
                exit;
               end;
                              end;
            'keyboard': begin
              if curentpage<>'keyboard' then
               begin
                oldpage:=curentpage;
                curentpage:='keyboard';
                entertrack:=0;
                nextplayplsshow:=0;
                tracksearchstr:='';
                nachfind:=1;

                if singleplayersettings.searchintag=0 then
                 begin
                  if (SinglePlayerSettings.inallpls=1) and (length(allplstrack)=0) then readallplstrack;
                 end else if (tagmass=nil) or (length(tagmass)=0) then
                 begin
                 if SinglePlayerSettings.inallpls=0 then formtagmass(0) else formtagmass(1);
                 end;
                SinglePlayerGUI.Invalidate;
                exit;
               end;
                        end;
            'keyboardexit': begin
              nextplayplsshow:=0;
              entertrack:=0;
              tracksearchstr:='';
              nachfind:=1;
              if oldpage<>'' then curentpage:=oldpage else curentpage:='singleplayer';
              SinglePlayerGUI.Invalidate;
              exit;
                           end;
            'effectedit': begin
                oldpage:=curentpage;
                curentpage:='effectedit';
                effectstr:=seticons[i].execopt;
                SinglePlayerGUI.Invalidate;
                exit;
                         end;
            'effectpage': begin
                           oldpage:=curentpage;
                           curentpage:='effectpage';
                           SinglePlayerGUI.Invalidate;
                           exit;
                          end;
            'effecteditexit': begin
              effectstr:='';
              if oldpage='eq' then curentpage:=oldpage else curentpage:='effectpage';
              SinglePlayerGUI.Invalidate;
              exit;
                           end;
            'effectpageexit': begin
              curentpage:='eq';
              SinglePlayerGUI.Invalidate;
              exit;
                           end;
            'effecton':begin effecton(effectstr); SinglePlayerGUI.Invalidate; exit; end;
            'effectoff':begin effectoff(effectstr); SinglePlayerGUI.Invalidate; exit; end;
            'keydel': begin entertrack:=0; nachfind:=1; if ord(char(tracksearchstr[length(tracksearchstr)])) = 150 then delete(tracksearchstr,length(tracksearchstr)-1,2) else if ord(char(tracksearchstr[length(tracksearchstr)]))>127  then delete(tracksearchstr,length(tracksearchstr)-1,2) else delete(tracksearchstr,length(tracksearchstr),1);  SinglePlayerGUI.Invalidate; exit; end;
            'searchclear': begin entertrack:=0; nachfind:=1; tracksearchstr:=''; SinglePlayerGUI.Invalidate; exit; end;
            'probel': begin entertrack:=0; tracksearchstr:=tracksearchstr+' '; SinglePlayerGUI.Invalidate; exit; end;
            'searchalltrack': begin if singleplayersettings.searchintag=0 then readallplstrack else begin if SinglePlayerSettings.inallpls=0 then formtagmass(0) else formtagmass(1); end; exit; end;
            'searchinallpls': begin entertrack:=0; nachfind:=1; SinglePlayerSettings.inallpls:=1; if singleplayersettings.searchintag=0 then readallplstrack else begin if SinglePlayerSettings.inallpls=0 then formtagmass(0) else formtagmass(1); end; SinglePlayerGUI.Invalidate; exit; end;
            'searchinonepls': begin entertrack:=0; nachfind:=1; SinglePlayerSettings.inallpls:=0; if singleplayersettings.searchintag=1 then formtagmass(0); SinglePlayerGUI.Invalidate; exit; end;
            'addtonext': begin addtonext(entertrack); entertrack:=0; SinglePlayerGUI.Invalidate; exit; end;
            'tagsearchon': begin
              entertrack:=0;
              nachfind:=1;
              singleplayersettings.searchintag:=1;
              if SinglePlayerSettings.inallpls=0 then formtagmass(0) else formtagmass(1);
              SinglePlayerGUI.Invalidate;
              exit;
                           end;
            'tagsearchoff': begin
               entertrack:=0;
               nachfind:=1;
               if SinglePlayerSettings.inallpls=1 then readallplstrack;
               singleplayersettings.searchintag:=0;
               SinglePlayerGUI.Invalidate;
               exit;
                            end;
            'shownexttrackpls': begin
              if curentpage<>'keyboard' then
               begin
                oldpage:=curentpage;
                curentpage:='keyboard';
               end;
              entertrack:=0;
              nachfind:=1;
              nextplayplsshow:=1;
              SinglePlayerGUI.Invalidate;
              exit;
                                end;
            'closenexttrackpls': begin nextplayplsshow:=0; nachfind:=1; entertrack:=0; SinglePlayerGUI.Invalidate; exit; end;
            'clearnexttrackpls': begin entertrack:=0; nachfind:=1; kollnexttrack:=0; nextplaytrackmass:=nil; SinglePlayerGUI.Invalidate; exit; end;
            'generalsetpl': begin generalsetpl; SinglePlayerGUI.Invalidate; exit; end;
            'playlistset': begin playlistset; SinglePlayerGUI.Invalidate; exit; end;
            'soundsetpl': begin soundsetpl; SinglePlayerGUI.Invalidate; exit; end;
            'plsetperf': begin plsetperf; SinglePlayerGUI.Invalidate; exit; end;
            'plsetskin': begin plsetskin; SinglePlayerGUI.Invalidate; exit; end;
            'playerfaceset': begin playerfaceset; SinglePlayerGUI.Invalidate; exit; end;
            'curplsup': begin trackup(SinglePlayerSettings.playedtrack); SinglePlayerGUI.Invalidate; exit; end;
            'curplsdown': begin  trackdown(SinglePlayerSettings.playedtrack); SinglePlayerGUI.Invalidate; exit; end;

            'findspup': begin if nachfind<finded2 then inc(nachfind); entertrack:=0; SinglePlayerGUI.Invalidate; exit; end;
            'findspdown': begin if nachfind>1 then dec(nachfind); entertrack:=0; SinglePlayerGUI.Invalidate; exit; end;

            'curplsdel': begin AfterSwipe:=0; delfrompls(track[SinglePlayerSettings.playedtrack]); SinglePlayerGUI.Invalidate; exit; end;
            'curplsdeldisk': begin AfterSwipe:=0; msgtap:=1; curworktrack:=track[SinglePlayerSettings.playedtrack]; msgdel; exit; end;
            'curplsfav': begin msgtap:=2; curworktrack:=track[SinglePlayerSettings.playedtrack]; msgfav; exit; end;
            'playersettingsexit': begin plsett:=0; curentpage:='singleplayer'; SinglePlayerGUI.invalidate; exit; end;
            'eqexit': begin curentpage:='singleplayer'; SinglePlayerGUI.invalidate; exit; end;
            'eqapply': begin    if mode=play then eqapply(channel); if mode=radioplay then eqapply(radiochannel); SinglePlayerGUI.Invalidate; exit; end;
            'genrel': begin genrel; SinglePlayerGUI.invalidate; exit; end;
            'genrer': begin genrer;  SinglePlayerGUI.invalidate; exit; end;
            'eqsave': begin
             curentpage:='singleplayer';
             SinglePlayerGUI.invalidate;
             eqwrite:=eqwritep.Create(true);
             eqwrite.freeonterminate := true;
             eqwrite.priority := tplowest;
             eqwrite.Start;
             exit;
            end;
            'exponefolder':begin exponefolder; SinglePlayerGUI.Invalidate; exit; end;
            'eqvk': begin eqvk; exit; end;
            'eqoff': begin eqoff; exit; end;
            'expmanyfolder':begin expmanyfolder; SinglePlayerGUI.Invalidate; exit; end;
            'exponefile':begin exponefile; SinglePlayerGUI.Invalidate; exit; end;
            'plsetapply': begin plsetapply; SinglePlayerGUI.Invalidate; exit; end;
            'plsetwrite': begin curentpage:='singleplayer'; SinglePlayerGUI.invalidate; plsetapply; WritePlayerSettings; exit; end;
            'startsaver':begin RunSaver; exit; end;
            'nextpage':
              begin
               if nextpageindex<>0 then
                begin
                 inc(pageindex);
                 pospage[pageindex]:=nextpageindex;
                 SinglePlayerGUI.invalidate;
                 exit;
                end;
              end;
            'forwpage':
              begin
               dec(pageindex);
               if pageindex=0 then pageindex:=1;
               exit;
              end;
            'virtualpage': begin oldpage:=curentpage; curentpage:=seticons[i].execopt; SinglePlayerGUI.Invalidate; exit; end;
            'playallplson': begin SinglePlayerSettings.playallpls:=1; SinglePlayerGUI.Invalidate; exit; end;
            'playallplsoff': begin SinglePlayerSettings.playallpls:=0; SinglePlayerGUI.Invalidate; exit; end;
           end;
           exec:=seticons[i].exec;
           execopt:=seticons[i].execopt;
          if fileexists(SinglePlayerDir+seticons[i].exec) then exec:=SinglePlayerDir+seticons[i].exec else
             if fileexists(seticons[i].exec) then exec:=seticons[i].exec;
           if fileexists(SinglePlayerDir+seticons[i].execopt) then execopt:=SinglePlayerDir+seticons[i].execopt else
             if fileexists(seticons[i].execopt) then execopt:=seticons[i].execopt;

           if execopt=SinglePlayerDir then execopt:='';
           if exec<>SinglePlayerDir then runprog(exec,execopt);
          end;

        end;
     end;

  if curentpage='disktree' then begin
   for i:=1 to length(folders)-1 do
   begin
     if folders[i,1]<>'' then
      begin

       if (x>strtoint(folders[i,3])) and (x<strtoint(folders[i,5])) and (y>strtoint(folders[i,4]))  and (y<strtoint(folders[i,6])) then
        begin
             fileispls:=0;   //выбранный файл не плейлист
             itdir:=folders[i,1];
             {$IFNDEF WInCE}
             itdir:='\'+itdir;
             {$ENDIF}
             if (itdir<>'\') or (itdir<>'') then
              begin
                      if
                      (length(itdir)-pos('.mp3',itdir)=3) and (pos('.mp3',itdir)<>0) or
                      (length(itdir)-pos('.wav',itdir)=3) and (pos('.wav',itdir)<>0) or
                      (length(itdir)-pos('.ogg',itdir)=3) and (pos('.ogg',itdir)<>0) or
                      (length(itdir)-pos('.flac',itdir)=4) and (pos('.flac',itdir)<>0) or
                      (length(itdir)-pos('.m4a',itdir)=3) and (pos('.m4a',itdir)<>0) or
                      (length(itdir)-pos('.mpc',itdir)=3) and (pos('.mpc',itdir)<>0) or
                      (length(itdir)-pos('.aiff',itdir)=4) and (pos('.aiff',itdir)<>0) or
                      (length(itdir)-pos('.MP3',itdir)=3) and (pos('.MP3',itdir)<>0) or
                      (length(itdir)-pos('.WAV',itdir)=3) and (pos('.WAV',itdir)<>0) or
                      (length(itdir)-pos('.OGG',itdir)=3) and (pos('.OGG',itdir)<>0) or
                      (length(itdir)-pos('.FLAC',itdir)=4) and (pos('.FLAC',itdir)<>0) or
                      (length(itdir)-pos('.M4A',itdir)=3) and (pos('.M4A',itdir)<>0) or
                      (length(itdir)-pos('.MPC',itdir)=3) and (pos('.MPC',itdir)<>0) or
                      (length(itdir)-pos('.m3u',itdir)=3) and (pos('.m3u',itdir)<>0) or
                      (length(itdir)-pos('.M3U',itdir)=3) and (pos('.M3U',itdir)<>0) or
                      (length(itdir)-pos('.pls',itdir)=3) and (pos('.pls',itdir)<>0) or
                      (length(itdir)-pos('.PLS',itdir)=3) and (pos('.PLS',itdir)<>0) or
                      (length(itdir)-pos('.cue',itdir)=3) and (pos('.cue',itdir)<>0) or
                      (length(itdir)-pos('.CUE',itdir)=3) and (pos('.CUE',itdir)<>0) or
                      (length(itdir)-pos('.AIFF',itdir)=4) and (pos('.AIFF',itdir)<>0) then
                           begin
                           if (length(itdir)-pos('.m3u',itdir)=3) and (pos('.m3u',itdir)<>0) or    //если это файл плейлиста
                            (length(itdir)-pos('.M3U',itdir)=3) and (pos('.M3U',itdir)<>0) or
                            (length(itdir)-pos('.pls',itdir)=3) and (pos('.pls',itdir)<>0) or
                            (length(itdir)-pos('.PLS',itdir)=3) and (pos('.PLS',itdir)<>0) or
                            (length(itdir)-pos('.cue',itdir)=3) and (pos('.cue',itdir)<>0) or
                            (length(itdir)-pos('.CUE',itdir)=3) and (pos('.CUE',itdir)<>0) then
                             begin
                              fileispls:=1; //выбранный файл это  плейлист
                              playm3upls(itdir);      // добавить треки из файла плейлиста в плейлист плеера
                              SinglePlayerGUI.Invalidate;
                              exit;
                             end;
                           itfolder:=0;
                             if singleplayersettings.manyadd=1 then
                              begin
                              for k:=1 to tempallkolltrack do if itdir = temptrackmas[k] then
                                begin
                                 for k2:=k to tempallkolltrack-1 do temptrackmas[k2]:=temptrackmas[k2+1];
                                 temptrackmas[tempallkolltrack]:='';
                                 dec(tempallkolltrack);
                                 SinglePlayerGUI.Invalidate;
                                 exit;
                               end;
                              inc(tempallkolltrack);
                              temptrackmas[tempallkolltrack]:=itdir;
                              notfdir:=0;
                              for k:=1 to fdir do if ExtractFilePath(itdir)=fdirmass[k] then notfdir:=1;
                              if notfdir=0 then begin inc(fdir); fdirmass[fdir]:=ExtractFilePath(itdir); end;
                              SinglePlayerGUI.Invalidate;
                              exit;
                              end else
                              begin     //---------------------------------------- режим добавления каталогов и треков при нажатии на ТРЕК, не множ выбор ------------------
                              if playlistadd=0 then curenttrack:=itdir;
                                if SinglePlayerSettings.recone=1 then
                                begin
                                 inc(tempallkolltrack);
                                 temptrackmas[tempallkolltrack]:=itdir;
                                 manyaddstart;
                                 SinglePlayerGUI.Invalidate;
                                 exit;
                                end else
                                begin
                                 itdir:=ExtractFilePath(itdir);
                                   if enumworked=0 then
                                    begin
                                     enumworked:=1;     //закоментировать строку если нужно ограничить количество одновременных потоков сканирования до 1
                                     scanningstr:=getfromlangpack('scanfolder');
                                     Application.ProcessMessages;
                                     findmarked:=findmarkedp.Create(true);
                                     findmarked.freeonterminate := true;
                                     findmarked.priority := tpHighest;   {tpIdle tpLowest tpLower tpNormal tpHigher tpHighest tpTimeCritical}
                                     findmarked.findddir:=itdir;
                                     findmarked.Start;
                                     SinglePlayerGUI.Invalidate;
                                     exit;
                                    end else
                                    begin
                                     scanningstr:='';
                                     SinglePlayerGUI.Invalidate;
                                     exit;
                                    end;
                                end;
                              end;  //-------------------------------------------------------------------------------------------------------------------------------------
                           end else
                           begin
                           GetTap;
                           if directoryexists(itdir) then
                             begin
                           if (SinglePlayerSettings.folderadd=1) or (not ShortTap) then
                            begin
                             if enumworked=0 then
                              begin
                               itfolder:=1;
                               enumworked:=1;     //закоментировать строку если нужно ограничить количество одновременных потоков сканирования до 1
                               scanningstr:=getfromlangpack('scanfolder');
                               if not ShortTap then expmanyfolder;
                               Application.ProcessMessages;
                               findmarked:=findmarkedp.Create(true);
                               findmarked.freeonterminate := true;
                               findmarked.priority := tpHighest;   {tpIdle tpLowest tpLower tpNormal tpHigher tpHighest tpTimeCritical}
                               findmarked.findddir:=itdir;
                               findmarked.Start;
                               SinglePlayerGUI.Invalidate;
                               exit;
                              end else
                              begin
                               scanningstr:='';
                               SinglePlayerGUI.Invalidate;
                               exit;
                              end;
                            end else
                            begin
                             pageindex:=1;
                             kollpage:=1;
                             curentdir:=folders[i,1];
                             getkollpagekey:=1;
                             SinglePlayerGUI.Invalidate;
                             exit;
                            end;
                            end;

                          end;

              end;

             SinglePlayerGUI.Invalidate;
             exit;
        end;
      end;
   end;
   SinglePlayerGUI.Invalidate;
   exit;
   end;



  if curentpage='eq' then
   begin
    for i:=1 to 13 do
     begin
       if (x>eqfcor[i,1]) and (x<eqfcor[i,1]+playericon[getindexiconexec('equp')].width) and (y>eqfcor[i,2])  and (y<eqfcor[i,2]+playericon[getindexiconexec('equp')].height) then
        begin
          if strtointdef(SinglePlayerSettings.ezf[i,1],0)<15 then SinglePlayerSettings.ezf[i,1]:=inttostr(strtointdef(SinglePlayerSettings.ezf[i,1],0)+1);
          p[i].fGain:=strtointdef(SinglePlayerSettings.ezf[i,1],0);
          SinglePlayerGUI.invalidate;
        end;
       if (x>=eqfcor[i,5]) and (x<=eqfcor[i,5]+eqfcor[i,7]) and (y>=eqfcor[i,6])  and (y<=eqfcor[i,6]+eqfcor[i,8]) then
        begin
          oldpage:=curentpage;
          curentpage:='effectedit';
          effectstr:='p'+inttostr(i);
          SinglePlayerGUI.invalidate;
          exit;
        end;
       if (x>eqfcor[i,3]) and (x<eqfcor[i,3]+playericon[getindexiconexec('eqdown')].width) and (y>eqfcor[i,4])  and (y<eqfcor[i,4]+playericon[getindexiconexec('eqdown')].height) then
        begin
         if strtointdef(SinglePlayerSettings.ezf[i,1],0)>-15 then SinglePlayerSettings.ezf[i,1]:=inttostr(strtointdef(SinglePlayerSettings.ezf[i,1],0)-1);
         p[i].fGain:=strtointdef(SinglePlayerSettings.ezf[i,1],0);
         SinglePlayerGUI.invalidate;
        end;
     end;

    if SinglePlayerSettings.eqsetnow=1 then
     begin
      if mode=play then eqapply(channel);
      if mode=radioplay then eqapply(radiochannel);
     end;
   end;

   if curentpage='playersettings' then
      begin
       SinglePlayerGUI.Invalidate;

       if plsett=6 then
        begin
         for i:=1 to sk do
          begin
           if (x>skincor[i,1]) and (x<skincor[i,2]) and (y>skincor[i,3])  and (y<skincor[i,4]) then
            begin
             msgtap:=4;
             curworkskin:=skinmass[i];
             if fileexists(SinglePlayerDir+SinglePlayerSettings.skindir+skinmass[i]+'\skcfg.cfg') then
              begin
               curworkskinini := TINIFile.Create(SinglePlayerDir+SinglePlayerSettings.skindir+skinmass[i]+'\skcfg.cfg');
               skinname:=curworkskinini.ReadString('mainform','name','noname');
               skinauthor:=curworkskinini.ReadString('mainform','author','noname');
               skinversion:=curworkskinini.ReadString('mainform','version','noname');
               playerversionstr:=curworkskinini.ReadString('mainform','singleplayerversion','');
               if pos(playerversion+';',playerversionstr)=0 then skinversion:=skinversion+': Не подходит!' else skinversion:=skinversion+': Подходит!';
               curworkskinini.Free;
               if fileexists((SinglePlayerDir+SinglePlayerSettings.skindir+skinmass[i])+'\icons\preview.bmp')then
                begin
                 prewskin:= graphics.tbitmap.Create;
                 prewskin.Width  := 400;
                 prewskin.Height := 240;
                 prewskin.Handle:=loadbmp(UTF8Encode(SinglePlayerDir+SinglePlayerSettings.skindir+skinmass[i])+'\icons\preview.bmp');
                end;
               end;
            end;
          end;
         exit;
        end;

       for i:=1 to 10 do
        begin
          if (x>plsettingscor[i,1]) and (x<plsettingscor[i,3]) and (y>plsettingscor[i,2])  and (y<plsettingscor[i,4]) then
            begin
               if plsett=2 then
                 begin
                  if i=8 then
                   begin
                    if (x>plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)) and
                       (x<plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)+playericon[getindexicon('equp.bmp')].Width)  and (SinglePlayerSettings.SwipeAmount<10)
                    then begin inc(SinglePlayerSettings.SwipeAmount); exit; end;
                    if (x>plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)+playericon[getindexicon('equp.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(inttostr(SinglePlayerSettings.SwipeAmount))+10) and
                       (x<plsettingscor[i,3]) and (SinglePlayerSettings.SwipeAmount>2)
                    then begin dec(SinglePlayerSettings.SwipeAmount); exit; end;
                    if (x>plsettingscor[i,1]) and (x<plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)) then
                    if plsettingsznach[plsett,i]='0' then plsettingsznach[plsett,i]:='1' else plsettingsznach[plsett,i]:='0';
                   end else if plsettingsznach[plsett,i]='0' then plsettingsznach[plsett,i]:='1' else plsettingsznach[plsett,i]:='0';
                 end else
             if plsett=4 then
               begin
                 if i=1 then
                  begin
                   if (x>plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)) and
                      (x<plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)+playericon[getindexicon('equp.bmp')].Width)  and (SinglePlayerSettings.znachcpueq<100)
                   then begin inc(SinglePlayerSettings.znachcpueq); exit; end;
                   if (x>plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)+playericon[getindexicon('equp.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(inttostr(SinglePlayerSettings.znachcpueq))+10) and
                      (x<plsettingscor[i,3]) and (SinglePlayerSettings.znachcpueq>SinglePlayerSettings.znachcpueqmin)
                   then begin dec(SinglePlayerSettings.znachcpueq); exit; end;
                   if (x>plsettingscor[i,1]) and (x<plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)) then
                   if plsettingsznach[plsett,i]='0' then plsettingsznach[plsett,i]:='1' else plsettingsznach[plsett,i]:='0';
                  end else
                 if i=2 then
                  begin
                   if (x>plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)) and
                      (x<plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)+playericon[getindexicon('equp.bmp')].Width)  and (SinglePlayerSettings.znachcpueqmin<SinglePlayerSettings.znachcpueq)
                   then begin inc(SinglePlayerSettings.znachcpueqmin); exit; end;
                   if (x>plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)+playericon[getindexicon('equp.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(inttostr(SinglePlayerSettings.znachcpueqmin))+10) and
                      (x<plsettingscor[i,3]) and (SinglePlayerSettings.znachcpueqmin>1)
                   then begin dec(SinglePlayerSettings.znachcpueqmin); exit; end;
                   if (x>plsettingscor[i,1]) and (x<plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)) then
                   if plsettingsznach[plsett,i]='0' then plsettingsznach[plsett,i]:='1' else plsettingsznach[plsett,i]:='0';
                  end else
                if i=3 then
                 begin
                  if (x>plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)) and
                     (x<plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)+playericon[getindexicon('equp.bmp')].Width)  and (SinglePlayerSettings.vizintensivitu<2000)
                  then begin inc(SinglePlayerSettings.vizintensivitu,100); exit; end;
                  if (x>plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)+playericon[getindexicon('equp.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(inttostr(SinglePlayerSettings.vizintensivitu))+10) and
                     (x<plsettingscor[i,3]) and (SinglePlayerSettings.vizintensivitu>100)
                  then begin dec(SinglePlayerSettings.vizintensivitu,100); exit; end;
                  if (x>plsettingscor[i,1]) and (x<plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)) then
                  if plsettingsznach[plsett,i]='0' then plsettingsznach[plsett,i]:='1' else plsettingsznach[plsett,i]:='0';
                 end else
                if i=4 then
                 begin
                  if (x>plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)) and
                     (x<plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)+playericon[getindexicon('equp.bmp')].Width)  and (SinglePlayerSettings.netbuffer<180000)
                  then begin inc(SinglePlayerSettings.netbuffer,500); exit; end;
                  if (x>plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)+playericon[getindexicon('equp.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(inttostr(SinglePlayerSettings.netbuffer))+10) and
                     (x<plsettingscor[i,3]) and (SinglePlayerSettings.netbuffer>0)
                  then begin dec(SinglePlayerSettings.netbuffer,500); exit; end;
                  if (x>plsettingscor[i,1]) and (x<plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)) then
                  if plsettingsznach[plsett,i]='0' then plsettingsznach[plsett,i]:='1' else plsettingsznach[plsett,i]:='0';
                  end else
                 if i=5 then
                  begin
                   if (x>plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)) and
                      (x<plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)+playericon[getindexicon('equp.bmp')].Width)  and (SinglePlayerSettings.netprebuffer<100)
                   then begin inc(SinglePlayerSettings.netprebuffer,5); exit; end;
                   if (x>plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)+playericon[getindexicon('equp.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(inttostr(SinglePlayerSettings.netprebuffer))+10) and
                      (x<plsettingscor[i,3]) and (SinglePlayerSettings.netprebuffer>0)
                   then begin dec(SinglePlayerSettings.netprebuffer,5); exit; end;
                   if (x>plsettingscor[i,1]) and (x<plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)) then
                   if plsettingsznach[plsett,i]='0' then plsettingsznach[plsett,i]:='1' else plsettingsznach[plsett,i]:='0';
                  end else
                  if i=6 then
                   begin
                    if (x>plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)) and
                       (x<plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)+playericon[getindexicon('equp.bmp')].Width)  and (SinglePlayerSettings.nettimeout<60000)
                    then begin inc(SinglePlayerSettings.nettimeout,500); exit; end;
                    if (x>plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)+playericon[getindexicon('equp.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(inttostr(SinglePlayerSettings.nettimeout))+10) and
                       (x<plsettingscor[i,3]) and (SinglePlayerSettings.nettimeout>500)
                    then begin dec(SinglePlayerSettings.nettimeout,500); exit; end;
                    if (x>plsettingscor[i,1]) and (x<plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)) then
                    if plsettingsznach[plsett,i]='0' then plsettingsznach[plsett,i]:='1' else plsettingsznach[plsett,i]:='0';
                   end else
                   if i=7 then
                    begin
                     if (x>plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)) and
                        (x<plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)+playericon[getindexicon('equp.bmp')].Width)  and (SinglePlayerSettings.netreadtimeout<3600000)
                     then begin inc(SinglePlayerSettings.netreadtimeout,60000); exit; end;
                     if (x>plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)+playericon[getindexicon('equp.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(inttostr(SinglePlayerSettings.netreadtimeout))+10) and
                        (x<plsettingscor[i,3]) and (SinglePlayerSettings.netreadtimeout>60000)
                     then begin dec(SinglePlayerSettings.netreadtimeout,60000); exit; end;
                     if (x>plsettingscor[i,1]) and (x<plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)) then
                     if plsettingsznach[plsett,i]='0' then plsettingsznach[plsett,i]:='1' else plsettingsznach[plsett,i]:='0';
                    end else
                    if i=8 then
                     begin
                      if (x>plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)) and
                         (x<plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)+playericon[getindexicon('equp.bmp')].Width)  and (SinglePlayerSettings.playerbuffer<5000)
                      then begin inc(SinglePlayerSettings.playerbuffer,50); exit; end;
                      if (x>plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)+playericon[getindexicon('equp.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(inttostr(SinglePlayerSettings.playerbuffer))+10) and
                         (x<plsettingscor[i,3]) and (SinglePlayerSettings.playerbuffer>50)
                      then begin dec(SinglePlayerSettings.playerbuffer,50); exit; end;
                      if (x>plsettingscor[i,1]) and (x<plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)) then
                      if plsettingsznach[plsett,i]='0' then plsettingsznach[plsett,i]:='1' else plsettingsznach[plsett,i]:='0';
                     end else
                     if i=9 then
                      begin
                       if (x>plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)) and
                          (x<plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)+playericon[getindexicon('equp.bmp')].Width)  and (SinglePlayerSettings.playupdateperiod<100)
                       then begin inc(SinglePlayerSettings.playupdateperiod,1); exit; end;
                       if (x>plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)+playericon[getindexicon('equp.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(inttostr(SinglePlayerSettings.playupdateperiod))+10) and
                          (x<plsettingscor[i,3]) and (SinglePlayerSettings.playupdateperiod>1)
                       then begin dec(SinglePlayerSettings.playupdateperiod,1); exit; end;
                       if (x>plsettingscor[i,1]) and (x<plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)) then
                       if plsettingsznach[plsett,i]='0' then plsettingsznach[plsett,i]:='1' else plsettingsznach[plsett,i]:='0';
                      end else
                if i=10 then
                 begin
                  if (x>plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)) and
                     (x<plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)+playericon[getindexicon('equp.bmp')].Width)  and (SinglePlayerSettings.playerfreq<14)
                  then begin inc(SinglePlayerSettings.playerfreq,1); exit; end;
                  if (x>plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)+playericon[getindexicon('equp.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(inttostr(playerfreqmas[SinglePlayerSettings.playerfreq]))+10) and
                     (x<plsettingscor[i,3]) and (SinglePlayerSettings.playerfreq>1)
                  then begin dec(SinglePlayerSettings.playerfreq,1); exit; end;
                  if (x>plsettingscor[i,1]) and (x<plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)) then
                  if plsettingsznach[plsett,i]='0' then plsettingsznach[plsett,i]:='1' else plsettingsznach[plsett,i]:='0';
                 end else if plsettingsznach[plsett,i]='0' then plsettingsznach[plsett,i]:='1' else plsettingsznach[plsett,i]:='0';
               end else
              if plsett=5 then
               begin
                if i=10 then
                 begin
                  if (x>plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)) and
                     (x<plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)+playericon[getindexicon('equp.bmp')].Width)  and (SinglePlayerSettings.nomlang<100) and (plsettingsznach[plsett,i]='1')
                  then begin inc(SinglePlayerSettings.nomlang); loadlang; LoadPlayerSkin(1); exit; end;
                  if (x>plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)+playericon[getindexicon('equp.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(singleplayersettings.langg)+10) and
                     (x<plsettingscor[i,3]) and (SinglePlayerSettings.nomlang>1) and (plsettingsznach[plsett,i]='1')
                  then begin dec(SinglePlayerSettings.nomlang); loadlang; LoadPlayerSkin(1); exit; end;
                  if (x>plsettingscor[i,1]) and (x<plsettingscor[i,1]+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2)) then
                  if plsettingsznach[plsett,i]='0' then plsettingsznach[plsett,i]:='1' else plsettingsznach[plsett,i]:='0';
                 end else if plsettingsznach[plsett,i]='0' then plsettingsznach[plsett,i]:='1' else plsettingsznach[plsett,i]:='0';
               end  else


             if plsettingsznach[plsett,i]='0' then plsettingsznach[plsett,i]:='1' else plsettingsznach[plsett,i]:='0';
            end;
        end;

       exit;
      end;

 if curentpage='playlist' then
   begin
    for i:=nachpls to konpls do
     begin
      if (x>plstrackcor[i,1]) and (x<plstrackcor[i,3]) and (y>plstrackcor[i,2])  and (y<plstrackcor[i,4]) then
        begin
         if SinglePlayerSettings.playedtrack=i then
          begin
           curenttrack:=track[i];
           npltr:=0;
           if pos('http',curenttrack)<>1 then
           begin
           SinglePlayerSettings.curpos:=-1;
           curenttrack:=track[i];
           timestartplay:=0;
            if pos('#ts',curenttrack)<>0 then
             begin
              timestartplay:=(strtointdef(copy(curenttrack,pos('#ts',curenttrack)+3, pos('st#',curenttrack)-pos('#ts',curenttrack)-9),0)*60)+strtointdef(copy(curenttrack,pos('#ts',curenttrack)+6, pos('st#',curenttrack)-pos('#ts',curenttrack)-9),0);
              curenttrack:=copy(curenttrack,pos('st#',curenttrack)+3,length(curenttrack)-pos('st#',curenttrack)-2);
             end;
           if (tempvol<>0) and (SinglePlayerSettings.plavzvuk=1) and (SinglePlayerSettings.curentvol=0) and (SinglePlayerSettings.mute=0) then
             begin
              SinglePlayerSettings.curentvol:=SinglePlayerSettings.curentvol+1;
              BASS_ChannelSetAttribute(channel,BASS_ATTRIB_VOL,SinglePlayerSettings.curentvol/10);
             end;
           if fileexists(curenttrack) then itelmaplay(curenttrack) else exit;
           if (tempvol<>0) and (SinglePlayerSettings.plavzvuk=1) and (SinglePlayerSettings.mute=0) then
             begin
              while SinglePlayerSettings.curentvol<tempvol do
               begin
                SinglePlayerSettings.curentvol:=SinglePlayerSettings.curentvol+1;
                BASS_ChannelSetAttribute(channel,BASS_ATTRIB_VOL,SinglePlayerSettings.curentvol/10);
                sleep(15);
               end;
              tempvol:=0;
             end;
           mode:=play;
          end else
          begin
           curenttrack:=track[i];
           if pos('http',curenttrack)=1 then iradioplay(curenttrack) else exit;
           mode:=radioplay;
          end;
         end else
         begin
          SinglePlayerSettings.playedtrack:=i;
         end;
        end;
      if (x>plstrackcor[i,5]) and (x<plstrackcor[i,7]) and (y>plstrackcor[i,6])  and (y<plstrackcor[i,8]) and (getindexicon('plsdeldisk.bmp')<>0) then begin msgtap:=1; curworktrack:=track[i]; msgdel; end;
      if (x>plstrackcor[i,9]) and (x<plstrackcor[i,11]) and (y>plstrackcor[i,10])  and (y<plstrackcor[i,12]) and (getindexicon('plsdel.bmp')<>0) then delfrompls(track[i]);
      if (x>plstrackcor[i,13]) and (x<plstrackcor[i,15]) and (y>plstrackcor[i,14])  and (y<plstrackcor[i,16]) and ((curenttrack=track[i]) or (i = SinglePlayerSettings.playedtrack)) and (getindexicon('plsdown.bmp')<>0) then trackdown(i);
      if (x>plstrackcor[i,17]) and (x<plstrackcor[i,19]) and (y>plstrackcor[i,18])  and (y<plstrackcor[i,20]) and ((curenttrack=track[i]) or (i = SinglePlayerSettings.playedtrack)) and (getindexicon('plsup.bmp')<>0) then trackup(i);
      if (x>plstrackcor[i,21]) and (x<plstrackcor[i,23]) and (y>plstrackcor[i,22])  and (y<plstrackcor[i,24]) and (getindexicon('plsfav.bmp')<>0) then begin msgtap:=2; curworktrack:=track[i]; msgfav; end;
     end;
    SinglePlayerGUI.Invalidate;
    exit;
   end;

 if curentpage='keyboard' then
  begin
   for i:=1 to maxkeys do
   begin
    if (x>strtointdef(keysmass[i,maxraskl+1],0)) and (y>strtointdef(keysmass[i,maxraskl+2],0)) and (x<strtointdef(keysmass[i,maxraskl+3],0)) and (y<strtointdef(keysmass[i,maxraskl+4],0)) then
     begin
      entertrack:=0;
      nachfind:=1;
      tracksearchstr:=tracksearchstr+keysmass[i,keyboardmode];
      exit;
     end;
   end;
   for i:=nachfind to finded2-1 do
    begin
     if (x>findtrackcor[i,2]) and (y>findtrackcor[i,3]) and (x<findtrackcor[i,4]) and (y<findtrackcor[i,5]) then
      begin
       if entertrack<>i then entertrack:=i else
          begin
           SinglePlayerSettings.playedtrack:=findtrackcor[i,1];
           if nextplayplsshow=0 then
            begin
             if singleplayersettings.searchintag =0 then
              begin
               if singleplayersettings.inallpls=0 then curenttrack:=track[SinglePlayerSettings.playedtrack] else
               begin
                curenttrack:=allplstrack[SinglePlayerSettings.playedtrack].Track;
                SinglePlayerSettings.curentplaylist:=allplstrack[SinglePlayerSettings.playedtrack].Playlist;
                SinglePlayerSettings.playedtrack:=allplstrack[SinglePlayerSettings.playedtrack].Number;
                playlistferstopen:=1;
                playlistread(SinglePlayerSettings.curentplaylist);
               end
              end
              else
              begin
                curenttrack:=tagmass[SinglePlayerSettings.playedtrack,2];
                SinglePlayerSettings.curentplaylist:=StrToIntDef(tagmass[SinglePlayerSettings.playedtrack,3],1);
                SinglePlayerSettings.playedtrack:=StrToIntDef(tagmass[SinglePlayerSettings.playedtrack,4],1);
              end
            end else curenttrack:=nextplaytrackmass[SinglePlayerSettings.playedtrack];
           SinglePlayerSettings.curpos:=-1;
           itelmaplay(curenttrack);
           if (tempvol<>0) and (SinglePlayerSettings.plavzvuk=1) and (SinglePlayerSettings.mute=0) then
             begin
              while SinglePlayerSettings.curentvol<tempvol do
               begin
                SinglePlayerSettings.curentvol:=SinglePlayerSettings.curentvol+1;
                BASS_ChannelSetAttribute(channel,BASS_ATTRIB_VOL,SinglePlayerSettings.curentvol/10);
                sleep(15);
               end;
              tempvol:=0;
             end;
          end;
       break;
      end;
    end;

   SinglePlayerGUI.Invalidate;
   exit;
  end;

 if curentpage='effectpage' then
  begin
  if findseleffect(x,y,'distortion') then begin if singleplayersettings.distortion=1 then effectoff('distortion') else effecton('distortion'); SinglePlayerGUI.Invalidate; exit; end;
  if findseleffect(x,y,'phaser') then begin if singleplayersettings.phaser=1 then effectoff('phaser') else effecton('phaser'); SinglePlayerGUI.Invalidate; exit; end;
  if findseleffect(x,y,'freeverb') then begin if singleplayersettings.freeverb=1 then effectoff('freeverb') else effecton('freeverb'); SinglePlayerGUI.Invalidate; exit; end;
  if findseleffect(x,y,'autowah') then begin if singleplayersettings.autowah=1 then effectoff('autowah') else effecton('autowah'); SinglePlayerGUI.Invalidate; exit; end;
  if findseleffect(x,y,'echo') then begin if singleplayersettings.echo=1 then effectoff('echo') else effecton('echo'); SinglePlayerGUI.Invalidate; exit; end;
  if findseleffect(x,y,'chorus') then begin if singleplayersettings.chorus=1 then effectoff('chorus') else effecton('chorus'); SinglePlayerGUI.Invalidate; exit; end;
  if findseleffect(x,y,'flanger') then begin if singleplayersettings.flanger=1 then effectoff('flanger') else effecton('flanger'); SinglePlayerGUI.Invalidate; exit; end;
  if findseleffect(x,y,'tempo') then begin if singleplayersettings.tempo=1 then effectoff('tempo') else effecton('tempo'); SinglePlayerGUI.Invalidate; exit; end;
  if findseleffect(x,y,'compressor') then begin if singleplayersettings.compressor=1 then effectoff('compressor') else effecton('compressor'); SinglePlayerGUI.Invalidate; exit; end;
  if findseleffect(x,y,'reverb') then begin if singleplayersettings.reverb=1 then effectoff('reverb') else effecton('reverb'); SinglePlayerGUI.Invalidate; exit; end;
  if findseleffect(x,y,'pitch') then begin if singleplayersettings.pitch=1 then effectoff('pitch') else effecton('pitch'); SinglePlayerGUI.Invalidate; exit; end;
  if findseleffect(x,y,'bqfhigh') then begin if singleplayersettings.bqfhigh=1 then effectoff('bqfhigh') else effecton('bqfhigh'); SinglePlayerGUI.Invalidate; exit; end;
  if findseleffect(x,y,'bqflow') then begin if singleplayersettings.bqflow=1 then effectoff('bqflow') else effecton('bqflow'); SinglePlayerGUI.Invalidate; exit; end;
  if findseleffect(x,y,'bqfbandpass') then begin if singleplayersettings.bqfbandpass=1 then effectoff('bqfbandpass') else effecton('bqfbandpass'); SinglePlayerGUI.Invalidate; exit; end;
  if findseleffect(x,y,'bqfpeakingeq') then begin if singleplayersettings.bqfpeakingeq=1 then effectoff('bqfpeakingeq') else effecton('bqfpeakingeq'); SinglePlayerGUI.Invalidate; exit; end;
  if findseleffect(x,y,'bqfnotch') then begin if singleplayersettings.bqfnotch=1 then effectoff('bqfnotch') else effecton('bqfnotch'); SinglePlayerGUI.Invalidate; exit; end;
  SinglePlayerGUI.Invalidate;
  exit;
  end;

  end;
 except
  LogAndExitPlayer('Ошибка в процедуре FormMouseUp',0,0);
 end;

end;

function findseleffect (x,y:integer; effstr:string):boolean;
begin
 result:=false;
 if (x>=seticons[getindexiconexecopt(effstr)].left+plset.effectlampleft) and
  (y>=seticons[getindexiconexecopt(effstr)].top+plset.effectlamptop) and
  (x<=seticons[getindexiconexecopt(effstr)].left+plset.effectlampleft+plset.effectlampwidth) and
  (y<=seticons[getindexiconexecopt(effstr)].top+plset.effectlamptop+plset.effectlampheight) then result:=true else result:=false;
end;

procedure playlistread(curpl:integer);
var
 plfile:textfile;
 i:integer;
begin
 try
 if statusplaylist=0 then
  begin
 if fileexists(SinglePlayerDir+'playlist_'+inttostr(curpl)+'.pls')=true then
  begin
   try
   statusplaylist:=6; {read}
   SinglePlayerGUI.Invalidate;
   SinglePlayerSettings.kolltrack:=0;
   assignfile(plfile,SinglePlayerDir+'playlist_'+inttostr(curpl)+'.pls');
   reset(plfile);

   while not eof(plfile) do
    begin
     inc(SinglePlayerSettings.kolltrack);
     readln(plfile,track[SinglePlayerSettings.kolltrack]);
     if pos ('http://',track[SinglePlayerSettings.kolltrack])<>1 then track[SinglePlayerSettings.kolltrack]:=ChangeFileExt(track[SinglePlayerSettings.kolltrack],lowercase(ExtractFileExt(track[SinglePlayerSettings.kolltrack])));
    end;
  if SinglePlayerSettings.playedtrack>SinglePlayerSettings.kolltrack then SinglePlayerSettings.playedtrack:=1;
 { if curenttrack='' then curenttrack:=track[SinglePlayerSettings.playedtrack]; }
   close(plfile);
   for i:=1 to SinglePlayerSettings.kolltrack do playedtrack[i]:=0;
   statusplaylist:=0;
   except
     LogAndExitPlayer('Ошибка считывания плейлиста',0,0);
     SinglePlayerSettings.playedtrack:=gettrackindex(curenttrack);
     statusplaylist:=0;
   end;
  end else
  begin
   SinglePlayerSettings.kolltrack:=0;
   statusplaylist:=0;
  end;
  end;
 except
  LogAndExitPlayer('Ошибка в процедуре playlistread',0,0);
 end;
end;

procedure loadlang;
var
 i:integer;
 langfile:textfile;
 langstr:string;
begin
 try
 flashword:=nil;
 if fileexists(SinglePlayerDir+'\langs.cfg') then
  begin
  assignfile(langfile,SinglePlayerDir+'\langs.cfg');
  i:=0;
  findl:=0;
  if singleplayersettings.nomlang=0 then singleplayersettings.nomlang:=1;
  reset(langfile);
  while not eof(langfile) do
   begin
    readln(langfile,langstr);
    langstr:=langstr;
    if (langstr='[words'+inttostr(singleplayersettings.nomlang)+']') and (findl=0) then begin findl:=1; continue; end;
    if findl=1 then
     begin
      if (pos('[words',langstr)=1) or (langstr='') then break;
      if pos('lang=',langstr)=1 then singleplayersettings.langg:=copy(langstr,6,length(langstr)-5) else
       begin
        inc(i);
        setlength(flashword,i+1,3);
        flashword[i,1]:=copy(langstr,1,pos('=',langstr)-1);
        flashword[i,2]:=copy(langstr,pos('=',langstr)+1,length(langstr)-pos('=',langstr));
       end;
     end;
   end;
  closefile(langfile);
  end else
  begin

  end;

 if (findl=0) and (singleplayersettings.nomlang<>1) then begin singleplayersettings.nomlang:=1; loadlang; LoadPlayerSkin(1); end;

  except
   LogAndExitPlayer('Ошибка при загрузке языкового пакета ' + SinglePlayerDir+'\langs.cfg',0,0);
   AllowStartPlayer:=0;
  end;
end;

function getfromlangpack(langtext:string):string;
var
 i:integer;
begin
 result:='';
  if pos('#~',langtext)<>0 then langtext:=copy(langtext,pos('#~',langtext)+2,pos('~#',langtext)-pos('#~',langtext)-2);
  for i:=1 to length(flashword)-1 do
   begin
      if langtext=flashword[i,1] then
       begin
        result:=flashword[i,2];
        exit;
       end;
   end;
end;

Procedure LoadPlayerSkin(mode:byte);
  var
    i,j,ist,iend:integer;
  begin
   ist:=0;
   iend:=0;
  try
   if fileexists(SinglePlayerDir+SinglePlayerSettings.skindir+SinglePlayerSettings.skin+'\skcfg.cfg') then
    begin
     LoadSP_SkinIniMas(SinglePlayerDir+SinglePlayerSettings.skindir+SinglePlayerSettings.skin+'\skcfg.cfg');

{-------------------------- параметры скина -----------------------------------}
 if mode=0 then
  begin
    plset.mainformwidth:=IniReadInteger(SP_SkinIniMas[0],'mainform','width',800);
    plset.mainformheight:=IniReadInteger(SP_SkinIniMas[0],'mainform','height',480);
    plset.mainformleft:=IniReadInteger(SP_SkinIniMas[0],'mainform','left',0);
    plset.mainformtop:=IniReadInteger(SP_SkinIniMas[0],'mainform','top',0);
    plset.treeleft:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','treeleft',50);
    plset.treetop:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','treetop',50);
    plset.treeleftsp:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','treeleftsp',30);
    plset.treetopsp:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','treetopsp',30);
    plset.treetextsize:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','treetextsize',10);
    plset.treetextsizetree:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','treetextsizetree',16);
    plset.treeintervalhorz:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','treeintervalhorz',20);
    plset.treeintervalvert:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','treeintervalvert',20);
    plset.maxrighttree:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','maxrighttree',780);
    plset.textinterval:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','textinterval',2);
    plset.treetype:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','treetype',0);
    plset.sortmode:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','sortmode',0);
    plset.treetextX:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','treetextX',0);
    plset.treetextY:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','treetextY',0);
    plset.treeintervalverttree:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','treeintervalverttree',0);
    plset.explorertextfolder:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','explorertextfolder',$FFFFFF);
    plset.explorertextfiles:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','explorertextfiles',$FFFFFF);
    plset.tracktimeleft:=IniReadString(SP_SkinIniMas[0],'singleplayer','tracktimeleft','0');
    plset.tracktimetop:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','tracktimetop',0);
    plset.tracktimecolor:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','tracktimecolor',$FFFFFF);
    plset.tracktimesize:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','tracktimesize',16);
    plset.timetrackleft:=IniReadString(SP_SkinIniMas[0],'singleplayer','timetrackleft','0');
    plset.timetracktop:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','timetracktop',0);
    plset.timetrackcolor:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','timetrackcolor',$FFFFFF);
    plset.timetracksize:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','timetracksize',12);
    plset.tracktitleleft:=IniReadString(SP_SkinIniMas[0],'singleplayer','tracktitleleft','0');
    plset.tracktitlewidth:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','tracktitlewidth',0);
    plset.tracktitletop:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','tracktitletop',0);
    plset.trackartisttitletop:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','trackartisttitletop',0);
    plset.tracktitlesize:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','tracktitlesize',0);
    plset.tracktitlecolor:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','tracktitlecolor',$FFFFFF);
    plset.statustextleft:=IniReadString(SP_SkinIniMas[0],'singleplayer','statustextleft','0');
    plset.statustexttop:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','statustexttop',0);
    plset.statustextcolor:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','statustextcolor',$FFFFFF);
    plset.statustextsize:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','statustextsize',16);
    plset.playedtrackleft:=IniReadString(SP_SkinIniMas[0],'singleplayer','playedtrackleft','0');
    plset.playedtracktop:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','playedtracktop',0);
    plset.playedtrackcolor:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','playedtrackcolor',0);
    plset.playedtracksize:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','playedtracksize',0);
    plset.cureqleft:=IniReadString(SP_SkinIniMas[0],'singleplayer','cureqleft','0');
    plset.cureqtop:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','cureqtop',0);
    plset.cureqcolor:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','cureqcolor',0);
    plset.cureqsize:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','cureqsize',0);
    plset.curvolleft:=IniReadString(SP_SkinIniMas[0],'eq','curvolleft','0');
    plset.curvoltop:=IniReadInteger(SP_SkinIniMas[0],'eq','curvoltop',0);
    plset.curvolcolor:=IniReadInteger(SP_SkinIniMas[0],'eq','curvolcolor',0);
    plset.curvolsize:=IniReadInteger(SP_SkinIniMas[0],'eq','curvolsize',0);
    plset.curplsleft:=IniReadString(SP_SkinIniMas[0],'singleplayer','curplsleft','0');
    plset.curplstop:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','curplstop',0);
    plset.curplscolor:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','curplscolor',0);
    plset.curplssize:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','curplssize',0);
    plset.playerdatetimecolor:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','playerdatetimecolor',$FFFFFF);
    plset.playerdatetimesize:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','playerdatetimesize',16);
    plset.playerdatetimeleft:=IniReadString(SP_SkinIniMas[0],'singleplayer','playerdatetimeleft','0');
    plset.playerdatetimetop:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','playerdatetimetop',0);
    plset.curentdircolor:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','curentdircolor',$FFFFFF);
    plset.curentdirsize:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','curentdirsize',24);
    plset.curentdirleft:=IniReadString(SP_SkinIniMas[0],'singleplayer','curentdirleft','0');
    plset.curentdirtop:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','curentdirtop',0);
    plset.curentdirplcolor:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','curentdirplcolor',$FFFFFF);
    plset.curentdirplsize:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','curentdirplsize',24);
    plset.curentdirplleft:=IniReadString(SP_SkinIniMas[0],'singleplayer','curentdirplleft','0');
    plset.curentdirpltop:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','curentdirpltop',0);
    plset.playlisttextr:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','playlisttextr',0);
    plset.playlisttextstr:=IniReadString(SP_SkinIniMas[0],'singleplayer','playlisttextstr','1');
    plset.equpleft:=IniReadInteger(SP_SkinIniMas[0],'eq','equpleft',0);
    plset.equptop:=IniReadInteger(SP_SkinIniMas[0],'eq','equptop',0);
    plset.eqdownleft:=IniReadInteger(SP_SkinIniMas[0],'eq','eqdownleft',0);
    plset.eqdowntop:=IniReadInteger(SP_SkinIniMas[0],'eq','eqdowntop',0);
    plset.eqftextleft:=IniReadInteger(SP_SkinIniMas[0],'eq','eqftextleft',0);
    plset.eqftexttop:=IniReadInteger(SP_SkinIniMas[0],'eq','eqftexttop',0);
    plset.eqztextleft:=IniReadInteger(SP_SkinIniMas[0],'eq','eqztextleft',0);
    plset.eqztexttop:=IniReadInteger(SP_SkinIniMas[0],'eq','eqztexttop',0);
    plset.eqsmeshX1:=IniReadInteger(SP_SkinIniMas[0],'eq','eqsmeshX1',0);
    plset.eqsmeshX2:=IniReadInteger(SP_SkinIniMas[0],'eq','eqsmeshX2',0);
    plset.eqsmeshY1:=IniReadInteger(SP_SkinIniMas[0],'eq','eqsmeshY1',0);
    plset.efsmeshX1:=IniReadInteger(SP_SkinIniMas[0],'eq','efsmeshX1',0);
    plset.efsmeshY1:=IniReadInteger(SP_SkinIniMas[0],'eq','efsmeshY1',0);
    plset.eqcurgenleft:=IniReadString(SP_SkinIniMas[0],'eq','eqcurgenleft','0');
    plset.eqcurgentop:=IniReadInteger(SP_SkinIniMas[0],'eq','eqcurgentop',0);
    plset.eqftextcolor:=IniReadInteger(SP_SkinIniMas[0],'eq','eqftextcolor',$FFFFFF);
    plset.eqftextsize:=IniReadInteger(SP_SkinIniMas[0],'eq','eqftextsize',12);
    plset.eqztextcolor:=IniReadInteger(SP_SkinIniMas[0],'eq','eqztextcolor',$FFFFFF);
    plset.eqztextsize:=IniReadInteger(SP_SkinIniMas[0],'eq','eqztextsize',12);
    plset.eqcurgencolor:=IniReadInteger(SP_SkinIniMas[0],'eq','eqcurgencolor',$FFFFFF);
    plset.eqcurgensize:=IniReadInteger(SP_SkinIniMas[0],'eq','eqcurgensize',12);
    plset.effectlampleft:=IniReadInteger(SP_SkinIniMas[0],'eq','effectlampleft',12);
    plset.effectlamptop:=IniReadInteger(SP_SkinIniMas[0],'eq','effectlamptop',12);
    plset.effectlampwidth:=IniReadInteger(SP_SkinIniMas[0],'eq','effectlampwidth',12);
    plset.effectlampheight:=IniReadInteger(SP_SkinIniMas[0],'eq','effectlampheight',12);
    plset.effectlampangleX:=IniReadInteger(SP_SkinIniMas[0],'eq','effectlampangleX',12);
    plset.effectlampangleY:=IniReadInteger(SP_SkinIniMas[0],'eq','effectlampangleY',12);
    plset.effectlampbordercoloroff:=IniReadInteger(SP_SkinIniMas[0],'eq','effectlampbordercoloroff',$FFFFFF);
    plset.effectlampcoloroff:=IniReadInteger(SP_SkinIniMas[0],'eq','effectlampcoloroff',$FFFFFF);
    plset.effectlampbordercoloron:=IniReadInteger(SP_SkinIniMas[0],'eq','effectlampbordercoloron',$FFFFFF);
    plset.effectlampcoloron:=IniReadInteger(SP_SkinIniMas[0],'eq','effectlampcoloron',$FFFFFF);
    plset.effectpagetextcolor:=IniReadInteger(SP_SkinIniMas[0],'eq','effectpagetextcolor',$FFFFFF);
    plset.effectpagetextsize:=IniReadInteger(SP_SkinIniMas[0],'eq','effectpagetextsize',12);
    plset.eqwgeelsmX:=IniReadInteger(SP_SkinIniMas[0],'eq','eqwgeelsmX',0);
    plset.eqwgeelsmY:=IniReadInteger(SP_SkinIniMas[0],'eq','eqwgeelsmY',0);
    plset.plsettextcolor:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','plsettextcolor',$FFFFFF);
    plset.plsetfillcolor:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','plsetfillcolor',$FFFFFF);
    plset.plsettextsize:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','plsettextsize',16);
    plset.plsettextleft:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','plsettextleft',0);
    plset.plsettexttop:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','plsettexttop',0);
    plset.plsettextsmw:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','plsettextsmw',0);
    plset.plsettextsmh:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','plsettextsmh',0);
    plset.plseticonsm:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','plseticonsm',0);
    plset.setchbsmh:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','setchbsmh',0);
    plset.bottomtree:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','bottomtree',0);
    plset.bottomsetka:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','bottomsetka',0);
    plset.maxrightsetka:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','maxrightsetka',0);
    plset.coverinplayerleft:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','coverinplayerleft',0);
    plset.coverinplayertop:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','coverinplayertop',0);
    plset.coverinzasleft:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','coverinzasleft',0);
    plset.coverinzastop:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','coverinzastop',0);
    plset.coverwidth:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','coverwidth',0);
    plset.coverheight:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','coverheight',0);
    plset.coverscrwidth:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','coverscrwidth',0);
    plset.coverscrheight:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','coverscrheight',0);
    plset.progressbarcolor:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','progressbarcolor',0);
    plset.progressbarfoncolor:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','progressbarfoncolor',0);
    plset.progressbarwidth:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','progressbarwidth',0);
    plset.progressbarleft:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','progressbarleft',0);
    plset.progressbartop:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','progressbartop',0);
    plset.progressbarheight:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','progressbarheight',0);
    plset.progressbarfonshow:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','progressbarfonshow',1);
    plset.progressbarshow:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','progressbarshow',1);
    plset.progressbarvir:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','progressbarvir',0);
    plset.sp1peekcolor:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','sp1peekcolor',$00FF00);
    plset.sp1barcolor:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','sp1barcolor',$0000FF);
    plset.sp1poscolor:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','sp1poscolor',$FF0000);
    plset.chbsetpole:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','chbsetpole',450);
    plset.bitratetrackcolor:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','bitratetrackcolor',$FFFFFF);
    plset.bitratetracksize:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','bitratetracksize',12);
    plset.bitratetrackleft:=IniReadString(SP_SkinIniMas[0],'singleplayer','bitratetrackleft','0');
    plset.bitratetracktop:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','bitratetracktop',0);
    plset.playlistkolltrack:=IniReadInteger(SP_SkinIniMas[0],'playlist','playlistkolltrack',9);
    plset.plskolltrackinfoleft:=IniReadString(SP_SkinIniMas[0],'playlist','plskolltrackinfoleft','0');
    plset.plskolltrackinfotop:=IniReadInteger(SP_SkinIniMas[0],'playlist','plskolltrackinfotop',0);
    plset.plskolltrackinfocolor:=IniReadInteger(SP_SkinIniMas[0],'playlist','plskolltrackinfocolor',$FFFFFF);
    plset.plskolltrackinfosize:=IniReadInteger(SP_SkinIniMas[0],'playlist','plskolltrackinfosize',12);
    plset.plspagesinfoleft:=IniReadString(SP_SkinIniMas[0],'playlist','plspagesinfoleft','0');
    plset.plspagesinfotop:=IniReadInteger(SP_SkinIniMas[0],'playlist','plspagesinfotop',0);
    plset.plspagesinfocolor:=IniReadInteger(SP_SkinIniMas[0],'playlist','plspagesinfocolor',$FFFFFF);
    plset.plspagesinfosize:=IniReadInteger(SP_SkinIniMas[0],'playlist','plspagesinfosize',12);
    plset.playlisttextcolor:=IniReadInteger(SP_SkinIniMas[0],'playlist','playlisttextcolor',$FFFFFF);
    plset.playlisttextsize:=IniReadInteger(SP_SkinIniMas[0],'playlist','playlisttextsize',16);
    plset.playlisttextleft:=IniReadString(SP_SkinIniMas[0],'playlist','playlisttextleft','0');
    plset.playlisttexttop:=IniReadInteger(SP_SkinIniMas[0],'playlist','playlisttexttop',0);
    plset.playlisttextncolor:=IniReadInteger(SP_SkinIniMas[0],'playlist','playlisttextncolor',$FFFFFF);
    plset.playlisttextnsize:=IniReadInteger(SP_SkinIniMas[0],'playlist','playlisttextnsize',24);
    plset.playlisttextnleft:=IniReadString(SP_SkinIniMas[0],'playlist','playlisttextnleft','0');
    plset.playlisttextntop:=IniReadInteger(SP_SkinIniMas[0],'playlist','playlisttextntop',0);
    plset.playlistcurplscolor:=IniReadInteger(SP_SkinIniMas[0],'playlist','playlistcurplscolor',$FFFFFF);
    plset.playlistcurplssize:=IniReadInteger(SP_SkinIniMas[0],'playlist','playlistcurplssize',16);
    plset.playlistcurplsleft:=IniReadString(SP_SkinIniMas[0],'playlist','playlistcurplsleft','0');
    plset.playlistcurplstop:=IniReadInteger(SP_SkinIniMas[0],'playlist','playlistcurplstop',0);
    plset.noticonpoleleft:=IniReadInteger(SP_SkinIniMas[0],'playlist','noticonpoleleft',1);
    plset.noticonpolerigth:=IniReadInteger(SP_SkinIniMas[0],'playlist','noticonpolerigth',555);
    plset.deldiskiconsm:=IniReadInteger(SP_SkinIniMas[0],'playlist','deldiskiconsm',0);
    plset.deliconsm:=IniReadInteger(SP_SkinIniMas[0],'playlist','deliconsm',0);
    plset.faviconsm:=IniReadInteger(SP_SkinIniMas[0],'playlist','faviconsm',0);
    plset.downiconsm:=IniReadInteger(SP_SkinIniMas[0],'playlist','downiconsm',0);
    plset.upiconsm:=IniReadInteger(SP_SkinIniMas[0],'playlist','upiconsm',0);
    plset.trackvertsm:=IniReadInteger(SP_SkinIniMas[0],'playlist','trackvertsm',40);
    plset.deldisktracktop:=IniReadInteger(SP_SkinIniMas[0],'playlist','deldisktracktop',-8);
    plset.recttrackcolor:=IniReadInteger(SP_SkinIniMas[0],'playlist','recttrackcolor',$FFFFFF);
    plset.deltracktop:=IniReadInteger(SP_SkinIniMas[0],'playlist','deltracktop',-8);
    plset.favtracktop:=IniReadInteger(SP_SkinIniMas[0],'playlist','favtracktop',-8);
    plset.downtracktop:=IniReadInteger(SP_SkinIniMas[0],'playlist','downtracktop',-8);
    plset.uptracktop:=IniReadInteger(SP_SkinIniMas[0],'playlist','uptracktop',-8);
    plset.vidtrackheight:=IniReadInteger(SP_SkinIniMas[0],'playlist','vidtrackheight',-6);
    plset.vidtracktop:=IniReadInteger(SP_SkinIniMas[0],'playlist','vidtracktop',36);
    plset.vidpltrackheight:=IniReadInteger(SP_SkinIniMas[0],'playlist','vidpltrackheight',-6);
    plset.vidpltracktop:=IniReadInteger(SP_SkinIniMas[0],'playlist','vidpltracktop',36);
    plset.vidpltrackleft:=IniReadInteger(SP_SkinIniMas[0],'playlist','vidpltrackleft',1);
    plset.vidpltrackwidth:=IniReadInteger(SP_SkinIniMas[0],'playlist','vidpltrackwidth',799);
    plset.vidtrackleft:=IniReadInteger(SP_SkinIniMas[0],'playlist','vidtrackleft',1);
    plset.vidtrackwidth:=IniReadInteger(SP_SkinIniMas[0],'playlist','vidtrackwidth',799);
    plset.vidplcolor:=IniReadInteger(SP_SkinIniMas[0],'playlist','vidplcolor',$0000FF);
    plset.vidcolor:=IniReadInteger(SP_SkinIniMas[0],'playlist','vidcolor',$FFA500);
    plset.spectr1left:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','spectr1left',1);
    plset.spectr1top:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','spectr1top',1);
    plset.spectr1width:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','spectr1width',1);
    plset.spectr1height:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','spectr1height',1);
    plset.spectr1kolbar:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','spectr1kolbar',1);
    plset.spectr1prbar:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','spectr1prbar',1);
    plset.spectr1widthbar:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','spectr1widthbar',1);
    plset.trackp:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','trackp',1);
    plset.vizpage:=IniReadString(SP_SkinIniMas[0],'singleplayer','vizpage','');
    plset.skinspistop:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','skinspistop',1);
    plset.skinspisleft:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','skinspisleft',1);
    plset.skinspisvertsm:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','skinspisvertsm',1);
    plset.skinspishorsm:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','skinspishorsm',1);
    plset.skinspisbottom:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','skinspisbottom',800);
    plset.scanfolderstrtextcolor:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','scanfolderstrtextcolor',$FFFFFF);
    plset.scanfolderstrtextsize:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','scanfolderstrtextsize',16);
    plset.scanfolderstrleft:=IniReadString(SP_SkinIniMas[0],'singleplayer','scanfolderstrleft','0');
    plset.scanfolderstrtop:=IniReadInteger(SP_SkinIniMas[0],'singleplayer','scanfolderstrtop',0);

    plset.xkey:=IniReadInteger(SP_SkinIniMas[0],'keyboard','xkey',0);
    plset.ykey:=IniReadInteger(SP_SkinIniMas[0],'keyboard','ykey',0);
    plset.keywidth:=IniReadInteger(SP_SkinIniMas[0],'keyboard','keywidth',0);
    plset.keyheight:=IniReadInteger(SP_SkinIniMas[0],'keyboard','keyheight',0);
    plset.keyras:=IniReadInteger(SP_SkinIniMas[0],'keyboard','keyras',0);
    plset.nextryad:=IniReadInteger(SP_SkinIniMas[0],'keyboard','nextryad',0);
    plset.keyboardcolor:=IniReadInteger(SP_SkinIniMas[0],'keyboard','keyboardcolor',$000000);
    plset.keyboardbordercolor:=IniReadInteger(SP_SkinIniMas[0],'keyboard','keyboardbordercolor',$0000FF);
    plset.keycolor:=IniReadInteger(SP_SkinIniMas[0],'keyboard','keycolor',$000000);
    plset.keybordercolor:=IniReadInteger(SP_SkinIniMas[0],'keyboard','keybordercolor',$0000FF);
    plset.maxkeysinryad:=IniReadInteger(SP_SkinIniMas[0],'keyboard','maxkeysinryad',10);
    plset.maxkolryad:=IniReadInteger(SP_SkinIniMas[0],'keyboard','maxkolryad',3);
    plset.wordleft:=IniReadInteger(SP_SkinIniMas[0],'keyboard','wordleft',15);
    plset.wordtop:=IniReadInteger(SP_SkinIniMas[0],'keyboard','wordtop',10);
    plset.tracksearchbordercolor:=IniReadInteger(SP_SkinIniMas[0],'keyboard','tracksearchbordercolor',$FFFFFF);
    plset.tracksearchcolor:=IniReadInteger(SP_SkinIniMas[0],'keyboard','tracksearchcolor',$FFFFFF);
    plset.tracksearchtextcolor:=IniReadInteger(SP_SkinIniMas[0],'keyboard','tracksearchtextcolor',$FFFFFF);
    plset.tracksearchleft:=IniReadInteger(SP_SkinIniMas[0],'keyboard','tracksearchleft',0);
    plset.tracksearchpoleheight:=IniReadInteger(SP_SkinIniMas[0],'keyboard','tracksearchpoleheight',0);
    plset.tracksearchpoleleft:=IniReadInteger(SP_SkinIniMas[0],'keyboard','tracksearchpoleleft',0);
    plset.tracksearchpoletop:=IniReadInteger(SP_SkinIniMas[0],'keyboard','tracksearchpoletop',0);
    plset.tracksearchpolewidth:=IniReadInteger(SP_SkinIniMas[0],'keyboard','tracksearchpolewidth',0);
    plset.tracksearchtextsize:=IniReadInteger(SP_SkinIniMas[0],'keyboard','tracksearchtextsize',0);
    plset.tracksearchtop:=IniReadInteger(SP_SkinIniMas[0],'keyboard','tracksearchtop',0);
    plset.topfind:=IniReadInteger(SP_SkinIniMas[0],'keyboard','topfind',0);
    plset.bottomfind:=IniReadInteger(SP_SkinIniMas[0],'keyboard','bottomfind',0);
    plset.leftfind:=IniReadInteger(SP_SkinIniMas[0],'keyboard','leftfind',0);
    plset.vertrasfind:=IniReadInteger(SP_SkinIniMas[0],'keyboard','vertrasfind',0);
    plset.searchrespolebottom:=IniReadInteger(SP_SkinIniMas[0],'keyboard','searchrespolebottom',0);
    plset.searchrespoletop:=IniReadInteger(SP_SkinIniMas[0],'keyboard','searchrespoletop',0);
    plset.searchrespoleleft:=IniReadInteger(SP_SkinIniMas[0],'keyboard','searchrespoleleft',0);
    plset.searchrespoleright:=IniReadInteger(SP_SkinIniMas[0],'keyboard','searchrespoleright',0);
    plset.searchresenterpolebordercolor:=IniReadInteger(SP_SkinIniMas[0],'keyboard','searchresenterpolebordercolor',0);
    plset.searchresenterpolecolor:=IniReadInteger(SP_SkinIniMas[0],'keyboard','searchresenterpolecolor',0);
    plset.searchresentertextcolor:=IniReadInteger(SP_SkinIniMas[0],'keyboard','searchresentertextcolor',0);
    plset.searchresentertextsize:=IniReadInteger(SP_SkinIniMas[0],'keyboard','searchresentertextsize',0);
    plset.topochered:=IniReadInteger(SP_SkinIniMas[0],'keyboard','topochered',0);
    plset.bottomochered:=IniReadInteger(SP_SkinIniMas[0],'keyboard','bottomochered',0);
    plset.ocheredbordercolor:=IniReadInteger(SP_SkinIniMas[0],'keyboard','ocheredbordercolor',$0000FF);
    plset.ocheredcolor:=IniReadInteger(SP_SkinIniMas[0],'keyboard','ocheredcolor',$000000);
    plset.ocheredtextcolor:=IniReadInteger(SP_SkinIniMas[0],'keyboard','ocheredtextcolor',$FFFFFF);
    plset.ocheredtextsize:=IniReadInteger(SP_SkinIniMas[0],'keyboard','ocheredtextsize',15);
    plset.ocheredstrtextsize:=IniReadInteger(SP_SkinIniMas[0],'keyboard','ocheredstrtextsize',15);
    plset.ocheredstrtextcolor:=IniReadInteger(SP_SkinIniMas[0],'keyboard','ocheredstrtextcolor',$FFFFFF);
    plset.ocheredstrleft:=IniReadInteger(SP_SkinIniMas[0],'keyboard','ocheredstrleft',0);
    plset.ocheredstrtop:=IniReadInteger(SP_SkinIniMas[0],'keyboard','ocheredstrtop',0);
    plset.srcstrtextsize:=IniReadInteger(SP_SkinIniMas[0],'keyboard','srcstrtextsize',15);
    plset.srcstrtextcolor:=IniReadInteger(SP_SkinIniMas[0],'keyboard','srcstrtextcolor',$FFFFFF);
    plset.srcstrleft:=IniReadInteger(SP_SkinIniMas[0],'keyboard','srcstrleft',0);
    plset.srcstrtop:=IniReadInteger(SP_SkinIniMas[0],'keyboard','srcstrtop',0);
    plset.keyboardleft:=IniReadInteger(SP_SkinIniMas[0],'keyboard','keyboardleft',0);
    plset.keyboardtop:=IniReadInteger(SP_SkinIniMas[0],'keyboard','keyboardtop',0);
    plset.keyboardwidth:=IniReadInteger(SP_SkinIniMas[0],'keyboard','keyboardwidth',0);
    plset.keyboardheight:=IniReadInteger(SP_SkinIniMas[0],'keyboard','keyboardheight',0);
    plset.keytextcolor:=IniReadInteger(SP_SkinIniMas[0],'keyboard','keytextcolor',$FFFFFF);
    plset.keytextsize:=IniReadInteger(SP_SkinIniMas[0],'keyboard','keytextsize',0);
    plset.searchresbordercolor:=IniReadInteger(SP_SkinIniMas[0],'keyboard','searchresbordercolor',$0000FF);
    plset.searchrescolor:=IniReadInteger(SP_SkinIniMas[0],'keyboard','searchrescolor',$000000);
    plset.searchrestextcolor:=IniReadInteger(SP_SkinIniMas[0],'keyboard','searchrestextcolor',$FFFFFF);
    plset.searchrestextsize:=IniReadInteger(SP_SkinIniMas[0],'keyboard','searchrestextsize',0);
    plset.scanstatustextcolor:=IniReadInteger(SP_SkinIniMas[0],'keyboard','scanstatustextcolor',$FFFFFF);
    plset.scanstatustextleft:=IniReadInteger(SP_SkinIniMas[0],'keyboard','scanstatustextleft',0);
    plset.scanstatustextsize:=IniReadInteger(SP_SkinIniMas[0],'keyboard','scanstatustextsize',15);
    plset.scanstatustexttop:=IniReadInteger(SP_SkinIniMas[0],'keyboard','scanstatustexttop',0);

{------------------------------------------------------------------------------}

{-------------------------------- параметры иконок скина ----------------------}
    for i:=1 to allicons do
     begin
      seticons[i].caption:=IniReadString(SP_SkinIniMas[i],'icon'+inttostr(i),'caption','');

        if pos('#~',IniReadString(SP_SkinIniMas[i],'icon'+inttostr(i),'text',''))=0 then
        seticons[i].text:=IniReadString(SP_SkinIniMas[i],'icon'+inttostr(i),'text','') else
         begin
          seticons[i].text:=IniReadString(SP_SkinIniMas[i],'icon'+inttostr(i),'text','');
          while pos('#~',seticons[i].text)<>0 do seticons[i].text:=replacestr(seticons[i].text,copy(seticons[i].text,pos('#~',seticons[i].text),pos('~#',seticons[i].text)+2-pos('#~',seticons[i].text)),getfromlangpack(copy(seticons[i].text,pos('#~',seticons[i].text),pos('~#',seticons[i].text)+2-pos('#~',seticons[i].text))));
         end;

      seticons[i].textleft:=IniReadString(SP_SkinIniMas[i],'icon'+inttostr(i),'textleft','0');
      seticons[i].texttop:=IniReadInteger(SP_SkinIniMas[i],'icon'+inttostr(i),'texttop',0);
      seticons[i].textsize:=IniReadInteger(SP_SkinIniMas[i],'icon'+inttostr(i),'textsize',0);
      seticons[i].textcolor:=IniReadInteger(SP_SkinIniMas[i],'icon'+inttostr(i),'textcolor',$FFFFFF);
      seticons[i].textcolorclick:=IniReadInteger(SP_SkinIniMas[i],'icon'+inttostr(i),'textcolorclick',$FFFF00);
      seticons[i].textautosize:=lowercase(IniReadString(SP_SkinIniMas[i],'icon'+inttostr(i),'textautosize','false'));
      seticons[i].maxright:=IniReadInteger(SP_SkinIniMas[i],'icon'+inttostr(i),'maxright',800);
      seticons[i].minleft:=IniReadInteger(SP_SkinIniMas[i],'icon'+inttostr(i),'minleft',0);
      seticons[i].width:=IniReadInteger(SP_SkinIniMas[i],'icon'+inttostr(i),'width',134);
      seticons[i].height:=IniReadInteger(SP_SkinIniMas[i],'icon'+inttostr(i),'height',134);
      seticons[i].left:=IniReadInteger(SP_SkinIniMas[i],'icon'+inttostr(i),'left',16);
      seticons[i].top:=IniReadInteger(SP_SkinIniMas[i],'icon'+inttostr(i),'top',16);
      seticons[i].typeicon:=lowercase(IniReadString(SP_SkinIniMas[i],'icon'+inttostr(i),'typeicon','buffer'));
      seticons[i].exec:=lowercase(IniReadString(SP_SkinIniMas[i],'icon'+inttostr(i),'exec',''));
      seticons[i].execopt:=lowercase(IniReadString(SP_SkinIniMas[i],'icon'+inttostr(i),'execopt',''));
      seticons[i].visible:=lowercase(IniReadString(SP_SkinIniMas[i],'icon'+inttostr(i),'visible','false'));
      seticons[i].clickiconcaption:=lowercase(IniReadString(SP_SkinIniMas[i],'icon'+inttostr(i),'clickiconcaption',''));
      seticons[i].textbold:=lowercase(IniReadString(SP_SkinIniMas[i],'icon'+inttostr(i),'textbold','false'));
      seticons[i].textitalic:=lowercase(IniReadString(SP_SkinIniMas[i],'icon'+inttostr(i),'textitalic','false'));
      seticons[i].Zpriority:=IniReadInteger(SP_SkinIniMas[i],'icon'+inttostr(i),'Zpriority',0);
     end;
{------------------------------------------------------------------------------}
    kollraskl:=0;
    for i:=1 to maxraskl do
     begin
      IniSelectSection(SP_SkinIniMas[0],'keymode'+inttostr(i),ISt,IEnd);
      if (ISt>0) then
      begin
        inc(kollraskl);
        for j:=1 to maxkeys do keysmass[j,i]:=IniReadString(SP_SkinIniMas[0],'keymode'+inttostr(i),inttostr(j),'',ISt,IEnd);
      end;
     end;

    end else
    begin
    for i:=1 to allicons do
     begin
      if pos('#~',IniReadString(SP_SkinIniMas[i],'icon'+inttostr(i),'text',''))=0 then
      seticons[i].text:=IniReadString(SP_SkinIniMas[i],'icon'+inttostr(i),'text','') else
       begin
        seticons[i].text:=IniReadString(SP_SkinIniMas[i],'icon'+inttostr(i),'text','');
        while pos('#~',seticons[i].text)<>0 do seticons[i].text:=replacestr(seticons[i].text,copy(seticons[i].text,pos('#~',seticons[i].text),pos('~#',seticons[i].text)+2-pos('#~',seticons[i].text)),getfromlangpack(copy(seticons[i].text,pos('#~',seticons[i].text),pos('~#',seticons[i].text)+2-pos('#~',seticons[i].text))));
       end;

     end;
    end;

    end else
    begin
     LogAndExitPlayer('Каталог скина имеет неверную структуру' + SinglePlayerDir+SinglePlayerSettings.skindir+SinglePlayerSettings.skin+'\skcfg.cfg',0,0);
     AllowStartPlayer:=0;
    end;
  except
    LogAndExitPlayer('Ошибка при загрузке скина ' + SinglePlayerDir+SinglePlayerSettings.skindir+SinglePlayerSettings.skin+'\skcfg.cfg',0,0);
    AllowStartPlayer:=0;
  end;
  for i:=1 to allicons do SetLength(SP_SkinIniMas[i],0);
  end;

procedure LoadIconPlayer;
var
 i:integer;
begin
try
loadiconkl:=1;

for i:=1 to allicons do
 begin
    if (seticons[i].caption<>'') and (pos('.bmp',seticons[i].caption)<>0)  then
     begin
     {  Загрузка картинок с диска}
        playericon[i]:= graphics.tbitmap.Create;

        playericon[i].Width  := seticons[i].width;
        playericon[i].Height := seticons[i].height;
        playericon[i].handle:=LoadBMP(UTF8Encode(SinglePlayerDir+SinglePlayerSettings.skindir+SinglePlayerSettings.skin)+'\Icons\'+seticons[i].caption);

     end;
    if seticons[i].clickiconcaption<>'' then
     begin
      clickplayericon[i]:= graphics.tbitmap.Create;

      clickplayericon[i].Width  := seticons[i].width;
      clickplayericon[i].Height := seticons[i].height;
      clickplayericon[i].handle:=LoadBMP(UTF8Encode(SinglePlayerDir+SinglePlayerSettings.skindir+SinglePlayerSettings.skin)+'\Icons\'+seticons[i].clickiconcaption);

     end;

    if (SinglePlayerSettings.logmode=1) and (seticons[i].caption<>'') then BigLog('Иконка '+seticons[i].caption+' секции '+inttostr(i)+' успешно загружена');
 end;
loadiconkl:=0;
except
  LogAndExitPlayer('Ошибка в процедуре loadiconplayer при загрузке иконки '+seticons[i].caption,0,0);
  loadiconkl:=0;
  AllowStartPlayer:=0;
  exit;
end;

end;

procedure paintplayericon(cpg:string);
var
 i,textformsize:integer;
 textformbold,textitalic:boolean;
begin
try
 textformbold:=false;
 textitalic:=false;
 if cpg='' then cpg:='singleplayer';

 PaintSwitchers;    //рисуем переключатели в зависимости от значений переключателей

 try
 for i:=1 to allicons do
  begin
     if (pos(cpg,seticons[i].typeicon)<>0) and (seticons[i].Zpriority=0) then
      begin

       {----------------------- рисуем флешки и карты в проводнике -------------------}
        if seticons[i].exec='disktree' then
         begin
          if directoryexists('\'+copy(seticons[i].caption,0,pos('.',seticons[i].caption)-1)) then seticons[i].visible:='true' else seticons[i].visible:='false';
         end;
       {------------------------------------------------------------------------------}

       if seticons[i].visible='true' then
        begin
         if (seticons[i].caption<>'') and (pos('.bmp',seticons[i].caption)<>0) then SinglePlayerGUI.Canvas.Draw(seticons[i].left, seticons[i].top, playericon[i]);
         if seticons[i].text<>'' then
          begin
           textformsize:=SinglePlayerGUI.Canvas.Font.Size;
           textformbold:=SinglePlayerGUI.Canvas.Font.Bold;
           textitalic:=SinglePlayerGUI.Canvas.Font.Italic;
           SinglePlayerGUI.Canvas.Font.Italic:=strtobool(seticons[i].textitalic);
           SinglePlayerGUI.Canvas.Font.Size:=seticons[i].textsize;
           SinglePlayerGUI.Canvas.Font.bold:=strtobool(seticons[i].textbold);
           if seticons[i].textautosize='true' then
            begin
             while ((myalign(seticons[i].textleft,uprstr(seticons[i].text),1)+SinglePlayerGUI.Canvas.TextWidth(uprstr(seticons[i].text))>seticons[i].maxright) or (myalign(seticons[i].textleft,uprstr(seticons[i].text),1)<seticons[i].minleft)) and (SinglePlayerGUI.Canvas.Font.Size>8) do SinglePlayerGUI.Canvas.Font.Size:=SinglePlayerGUI.Canvas.Font.Size-1;
            end;
           SinglePlayerGUI.Canvas.Font.Color:=seticons[i].textcolor;
           SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(seticons[i].textleft,uprstr(seticons[i].text),1),seticons[i].texttop,uprstr(seticons[i].text));
           SinglePlayerGUI.Canvas.Font.Size:=textformsize;
           SinglePlayerGUI.Canvas.Font.bold:=textformbold;
           SinglePlayerGUI.Canvas.Font.Italic:=textitalic;
          end;
        end;

    end;
  end;
 except
   LogAndExitPlayer('painticon icon error '+ seticons[i].caption,0,0);
 end;
except
  LogAndExitPlayer('Ошибка в процедуре painmenuicon '+seticons[i].caption,0,0);
end;
end;

procedure paintplayericonZprioryty(cpg:string);
var
 i,textformsize:integer;
 textformbold,textitalic:boolean;
begin
try
 textformbold:=false;
 textitalic:=false;
 if cpg='' then cpg:='singleplayer';

 try
 for i:=1 to allicons do
  begin
     if (pos(cpg,seticons[i].typeicon)<>0) and (seticons[i].Zpriority=1) then
      begin

       {----------------------- рисуем флешки и карты в проводнике -------------------}
        if seticons[i].exec='disktree' then
         begin
          if directoryexists('\'+copy(seticons[i].caption,0,pos('.',seticons[i].caption)-1)) then seticons[i].visible:='true' else seticons[i].visible:='false';
         end;
       {------------------------------------------------------------------------------}

       if seticons[i].visible='true' then
        begin
         if (seticons[i].caption<>'') and (pos('.bmp',seticons[i].caption)<>0) then SinglePlayerGUI.Canvas.Draw(seticons[i].left, seticons[i].top, playericon[i]);
         if seticons[i].text<>'' then
          begin
           textformsize:=SinglePlayerGUI.Canvas.Font.Size;
           textformbold:=SinglePlayerGUI.Canvas.Font.Bold;
           textitalic:=SinglePlayerGUI.Canvas.Font.Italic;
           SinglePlayerGUI.Canvas.Font.Italic:=strtobool(seticons[i].textitalic);
           SinglePlayerGUI.Canvas.Font.Size:=seticons[i].textsize;
           SinglePlayerGUI.Canvas.Font.bold:=strtobool(seticons[i].textbold);
           if seticons[i].textautosize='true' then
            begin
             while ((myalign(seticons[i].textleft,uprstr(seticons[i].text),1)+SinglePlayerGUI.Canvas.TextWidth(uprstr(seticons[i].text))>seticons[i].maxright) or (myalign(seticons[i].textleft,uprstr(seticons[i].text),1)<seticons[i].minleft)) and (SinglePlayerGUI.Canvas.Font.Size>8) do SinglePlayerGUI.Canvas.Font.Size:=SinglePlayerGUI.Canvas.Font.Size-1;
            end;
           SinglePlayerGUI.Canvas.Font.Color:=seticons[i].textcolor;
           SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(seticons[i].textleft,uprstr(seticons[i].text),1),seticons[i].texttop,uprstr(seticons[i].text));
           SinglePlayerGUI.Canvas.Font.Size:=textformsize;
           SinglePlayerGUI.Canvas.Font.bold:=textformbold;
           SinglePlayerGUI.Canvas.Font.Italic:=textitalic;
          end;
        end;

    end;
  end;
 except
   LogAndExitPlayer('painticon icon error '+ seticons[i].caption,0,0);
 end;
except
  LogAndExitPlayer('Ошибка в процедуре painmenuicon '+seticons[i].caption,0,0);
end;
end;

procedure PaintSwitchers;
begin
try
  if SinglePlayerSettings.playone = 1 then
   begin
    setvisfromexec('playone','false');
    setvisfromexec('nonerej','true');
    setvisfromexec('shuffle','false');
   end else
   begin
    if SinglePlayerSettings.shufflekey=1 then
     begin
      setvisfromexec('playone','true');
      setvisfromexec('nonerej','false');
      setvisfromexec('shuffle','false');
     end else
     begin
      setvisfromexec('playone','false');
      setvisfromexec('nonerej','false');
      setvisfromexec('shuffle','true');
     end;
   end;

  if SinglePlayerSettings.recadd=1 then
   begin
    setvisfromexec('exponefile','true');
    setvisfromexec('expmanyfolder','false');
    setvisfromexec('exponefolder','false');
   end else
   begin
    if SinglePlayerSettings.recone=1 then
     begin
      setvisfromexec('exponefile','false');
      setvisfromexec('expmanyfolder','false');
      setvisfromexec('exponefolder','true');
     end else
     begin
      setvisfromexec('exponefile','false');
      setvisfromexec('expmanyfolder','true');
      setvisfromexec('exponefolder','false');
     end;
   end;

  if plset.treetype=0 then
   begin
    setvisfromexec('exptree','false');
    setvisfromexec('expsetka','true');
   end else
   begin
    setvisfromexec('exptree','true');
    setvisfromexec('expsetka','false');
   end;

   	if plset.sortmode=0 then begin
    	setvisfromexec('sortabc','true');
    	setvisfromexec('sortdate','false');
    	setvisfromexec('sortdateinv','false');
   	end else begin
    	if plset.sortmode=1 then begin
	    	setvisfromexec('sortabc','false');
	    	setvisfromexec('sortdate','true');
	    	setvisfromexec('sortdateinv','false');
        end else begin
            setvisfromexec('sortabc','false');
	    	setvisfromexec('sortdate','false');
	    	setvisfromexec('sortdateinv','true');
		end;
	end;

  if SinglePlayerSettings.eqon=1 then
   begin
    setvisfromexec('eqoff','true');
    setvisfromexec('eqvk','false');
   end else
   begin
    setvisfromexec('eqoff','false');
    setvisfromexec('eqvk','true');
   end;

  if SinglePlayerSettings.mute=0 then
   begin
    setvisfromexec('muteon','true');
    setvisfromexec('muteoff','false');
   end else
   begin
    setvisfromexec('muteon','false');
    setvisfromexec('muteoff','true');
   end;

  if SinglePlayerSettings.ciclepls=0 then
   begin
    setvisfromexec('cicleplson','true');
    setvisfromexec('cicleplsoff','false');
   end else
   begin
    setvisfromexec('cicleplson','false');
    setvisfromexec('cicleplsoff','true');
   end;

  if SinglePlayerSettings.folderadd=0 then
   begin
    setvisfromexec('folderaddon','true');
    setvisfromexec('folderaddoff','false');
   end else
   begin
    setvisfromexec('folderaddon','false');
    setvisfromexec('folderaddoff','true');
   end;

  if (connecting=1) then setvisfromexec('stopconnecting','true') else setvisfromexec('stopconnecting','false');

  if SinglePlayerSettings.manyadd=0 then
   begin
    setvisfromexec('manyaddon','true');
    setvisfromexec('manyaddoff','false');
   end else
   begin
    setvisfromexec('manyaddon','false');
    setvisfromexec('manyaddoff','true');
   end;

   if (tempallkolltrack=0) or (SinglePlayerSettings.manyadd=0) then setvisfromexec('manyaddstart','false') else setvisfromexec('manyaddstart','true');

  if SinglePlayerSettings.wheelone=0 then
   begin
    setvisfromexec('wheeloneon','true');
    setvisfromexec('wheeloneoff','false');
   end else
   begin
    setvisfromexec('wheeloneon','false');
    setvisfromexec('wheeloneoff','true');
   end;

  if (mode=play) or (mode=radioplay) then
   begin
    setvisfromname('btplay.bmp','false');
    setvisfromname('btstop.bmp','true');
    setvisfromname('plsplay.bmp','false');
    setvisfromname('plsstop.bmp','true');
   end else
   begin
    setvisfromname('btplay.bmp','true');
    setvisfromname('btstop.bmp','false');
    setvisfromname('plsplay.bmp','true');
    setvisfromname('plsstop.bmp','false');
   end;

  if singleplayersettings.playallpls=0 then
   begin
    setvisfromexec('playallplson','true');
    setvisfromexec('playallplsoff','false');
   end else
   begin
    setvisfromexec('playallplson','false');
    setvisfromexec('playallplsoff','true');
   end;

 if nextplayplsshow=0 then
  begin
  if SinglePlayerSettings.inallpls=0 then
   begin
    setvisfromexec('searchinallpls','true');
    setvisfromexec('searchinonepls','false');
   end else
   begin
    setvisfromexec('searchinallpls','false');
    setvisfromexec('searchinonepls','true');
   end;

  if singleplayersettings.searchintag=0 then
   begin
    setvisfromexec('tagsearchon','true');
    setvisfromexec('tagsearchoff','false');
   end else
   begin
   setvisfromexec('tagsearchon','false');
   setvisfromexec('tagsearchoff','true');
   end;

  if singleplayersettings.sysvolchange=0 then
   begin
    setvisfromexec('sysvolchangeon','true');
    setvisfromexec('sysvolchangeoff','false');
   end else
   begin
    setvisfromexec('sysvolchangeon','false');
    setvisfromexec('sysvolchangeoff','true');
   end;

   setvisfromexec('shownexttrackpls','true');
   if entertrack<>0 then setvisfromexec('addtonext','true') else setvisfromexec('addtonext','false');
   setvisfromexec('addtonextall','true');
   setvisfromexec('searchclear','true');
   setvisfromexec('keydel','true');
   setvisfromexec('probel','true');
   setvisfromexec('keyboardmodesw','true');
   setvisfromexec('clearnexttrackpls','false');
   setvisfromexec('closenexttrackpls','false');
   setvisfromexec('searchalltrack','true');
  end else
  begin
   setvisfromexec('closenexttrackpls','true');
   setvisfromexec('clearnexttrackpls','true');
   setvisfromexec('shownexttrackpls','false');
   setvisfromexec('addtonext','false');
   setvisfromexec('addtonextall','false');
   setvisfromexec('searchinallpls','false');
   setvisfromexec('searchinonepls','false');
   setvisfromexec('searchalltrack','false');
   setvisfromexec('searchclear','false');
   setvisfromexec('keydel','false');
   setvisfromexec('probel','false');
   setvisfromexec('keyboardmodesw','false');
   setvisfromexec('tagsearchon','false');
   setvisfromexec('tagsearchoff','false');
  end;

  case effectstr of
   'bqflow':begin
    if singleplayersettings.bqflow=1 then
       begin
        setvisfromexec('effecton','false');
        setvisfromexec('effectoff','true');
       end else
       begin
        setvisfromexec('effecton','true');
        setvisfromexec('effectoff','false');
       end;
         end;
   'bqfhigh':begin
    if singleplayersettings.bqfhigh=1 then
       begin
        setvisfromexec('effecton','false');
        setvisfromexec('effectoff','true');
       end else
       begin
        setvisfromexec('effecton','true');
        setvisfromexec('effectoff','false');
       end;
         end;
   'bqfpeakingeq':begin
    if singleplayersettings.bqfPEAKINGEQ=1 then
       begin
        setvisfromexec('effecton','false');
        setvisfromexec('effectoff','true');
       end else
       begin
        setvisfromexec('effecton','true');
        setvisfromexec('effectoff','false');
       end;
         end;
   'bqfbandpass':begin
    if singleplayersettings.bqfBANDPASS=1 then
       begin
        setvisfromexec('effecton','false');
        setvisfromexec('effectoff','true');
       end else
       begin
        setvisfromexec('effecton','true');
        setvisfromexec('effectoff','false');
       end;
         end;
   'reverb':begin
    if singleplayersettings.reverb=1 then
       begin
        setvisfromexec('effecton','false');
        setvisfromexec('effectoff','true');
       end else
       begin
        setvisfromexec('effecton','true');
        setvisfromexec('effectoff','false');
       end;
         end;
   'echo':begin
    if singleplayersettings.echo=1 then
       begin
        setvisfromexec('effecton','false');
        setvisfromexec('effectoff','true');
       end else
       begin
        setvisfromexec('effecton','true');
        setvisfromexec('effectoff','false');
       end;
         end;
   'chorus':begin
    if singleplayersettings.chorus=1 then
       begin
        setvisfromexec('effecton','false');
        setvisfromexec('effectoff','true');
       end else
       begin
        setvisfromexec('effecton','true');
        setvisfromexec('effectoff','false');
       end;
         end;
   'flanger':begin
    if singleplayersettings.flanger=1 then
       begin
        setvisfromexec('effecton','false');
        setvisfromexec('effectoff','true');
       end else
       begin
        setvisfromexec('effecton','true');
        setvisfromexec('effectoff','false');
       end;
         end;
   'tempo':begin
    if singleplayersettings.tempo=1 then
       begin
        setvisfromexec('effecton','false');
        setvisfromexec('effectoff','true');
       end else
       begin
        setvisfromexec('effecton','true');
        setvisfromexec('effectoff','false');
       end;
         end;
   'pitch':begin
    if singleplayersettings.pitch=1 then
       begin
        setvisfromexec('effecton','false');
        setvisfromexec('effectoff','true');
       end else
       begin
        setvisfromexec('effecton','true');
        setvisfromexec('effectoff','false');
       end;
         end;
   'compressor':begin
    if singleplayersettings.compressor=1 then
       begin
        setvisfromexec('effecton','false');
        setvisfromexec('effectoff','true');
       end else
       begin
        setvisfromexec('effecton','true');
        setvisfromexec('effectoff','false');
       end;
         end;
   'distortion':begin
    if singleplayersettings.distortion=1 then
       begin
        setvisfromexec('effecton','false');
        setvisfromexec('effectoff','true');
       end else
       begin
        setvisfromexec('effecton','true');
        setvisfromexec('effectoff','false');
       end;
         end;
   'phaser':begin
    if singleplayersettings.phaser=1 then
       begin
        setvisfromexec('effecton','false');
        setvisfromexec('effectoff','true');
       end else
       begin
        setvisfromexec('effecton','true');
        setvisfromexec('effectoff','false');
       end;
         end;
   'freeverb':begin
    if SinglePlayerSettings.FREEVERB=1 then
       begin
        setvisfromexec('effecton','false');
        setvisfromexec('effectoff','true');
       end else
       begin
        setvisfromexec('effecton','true');
        setvisfromexec('effectoff','false');
       end;
         end;
   'autowah':begin
    if singleplayersettings.autowah=1 then
       begin
        setvisfromexec('effecton','false');
        setvisfromexec('effectoff','true');
       end else
       begin
        setvisfromexec('effecton','true');
        setvisfromexec('effectoff','false');
       end;
         end;
   'bqfnotch':begin
    if singleplayersettings.bqfnotch=1 then
       begin
        setvisfromexec('effecton','false');
        setvisfromexec('effectoff','true');
       end else
       begin
        setvisfromexec('effecton','true');
        setvisfromexec('effectoff','false');
       end;
         end;

   else begin
         setvisfromexec('effecton','false');
         setvisfromexec('effectoff','false');
        end;
  end;

except
  LogAndExitPlayer('painticon error perekl',0,0);
end;
end;

function myalign(alstr:string; strmarker:string; typestring:integer):integer;
var
 aleft,aright:integer;
begin
 aleft:=0;
 aright:=0;
 result:=strtointdef(alstr,0);

      if pos(':center:',alstr)<>0 then
       begin
         aleft:=strtointdef(copy(alstr,1,pos(':center:',alstr)-1),0);
         if typestring=1 then
          begin
         aright:=strtointdef(copy(alstr,pos(':center:',alstr)+8,length(alstr)-pos(':center:',alstr)),0);
         if (aleft=0) and (aright=0) then exit;
         if aright<aleft+SinglePlayerGUI.Canvas.TextWidth(strmarker) then
          begin
           result:=aleft;
           exit;  {если правая часть меньше ширины строки то левый край уже найден}
          end else
          begin
           aleft:=aleft+((aright-aleft - SinglePlayerGUI.Canvas.TextWidth(strmarker)) div 2);
           result:=aleft;
           exit;
          end;
        exit;
          end else result:=aleft;
       end;

      if pos('right:',alstr)<>0 then
       begin
        aright:=strtointdef(copy(alstr,pos('right:',alstr)+6,length(alstr)-pos('right:',alstr)),0);
        if typestring=1 then
         begin
        if aright=0 then exit;
        result:=aright-SinglePlayerGUI.Canvas.TextWidth(strmarker);
        exit;
         end else result:=aright;
       end;

    exit;
end;

function uprstr(str:string):string;
begin
 result:=str;
 if pos('%track%',str) <> 0  then str:=replacestr(str,'%track%',paintstr('%track%'));
 if pos('%playervol%',str) <> 0 then str:=replacestr(str,'%playervol%',paintstr('%playervol%'));
 if pos('%playfolder%',str) <> 0 then str:=replacestr(str,'%playfolder%',paintstr('%playfolder%'));
 if pos('%curbitrate%',str) <> 0 then str:=replacestr(str,'%curbitrate%',paintstr('%curbitrate%'));
 if pos('%cureq%',str) <> 0 then str:=replacestr(str,'%cureq%',paintstr('%cureq%'));
 if pos('%curpos%',str) <> 0 then str:=replacestr(str,'%curpos%',paintstr('%curpos%'));
 if pos('%tracktime%',str) <> 0 then str:=replacestr(str,'%tracktime%',paintstr('%tracktime%'));
 if pos('%nomplaytrack%',str) <> 0 then str:=replacestr(str,'%nomplaytrack%',paintstr('%nomplaytrack%'));
 if pos('%curplaylist%',str) <> 0 then str:=replacestr(str,'%curplaylist%',paintstr('%curplaylist%'));
 if pos('%kolltrack%',str) <> 0 then str:=replacestr(str,'%kolltrack%',paintstr('%kolltrack%'));
 if pos(' / 0',str) <> 0 then str:='';
 if pos('%skinname%',str) <> 0 then str:=replacestr(str,'%skinname%',paintstr('%skinname%'));
 if pos('%curpage%',str) <> 0 then str:=replacestr(str,'%curpage%',paintstr('%curpage%'));
 if pos('%datetime%',str) <> 0 then str:=replacestr(str,'%datetime%',paintstr('%datetime%'));
 if pos('%date%',str) <> 0 then str:=replacestr(str,'%date%',paintstr('%date%'));
 if pos('%time%',str) <> 0 then str:=replacestr(str,'%time%',paintstr('%time%'));
 if pos('%artisttrack%',str) <> 0 then str:=replacestr(str,'%artisttrack%',paintstr('%artisttrack%'));
 if pos('%titletrack%',str) <> 0 then str:=replacestr(str,'%titletrack%',paintstr('%titletrack%'));
 if pos('%curentdir%',str) <> 0 then str:=replacestr(str,'%curentdir%',paintstr('%curentdir%'));
 if pos('%playfile%',str) <> 0 then str:=replacestr(str,'%playfile%',paintstr('%playfile%'));
 if pos('%curplaylistpage%',str) <> 0 then str:=replacestr(str,'%curplaylistpage%',paintstr('%curplaylistpage%'));
 if pos('%playlistpages%',str) <> 0 then str:=replacestr(str,'%playlistpages%',paintstr('%playlistpages%'));
 if pos('%SinglePlayerDir%',str) <> 0 then str:=replacestr(str,'%SinglePlayerDir%',paintstr('%SinglePlayerDir%'));
 if pos('%playerversion%',str) <> 0 then str:=replacestr(str,'%playerversion%',paintstr('%playerversion%'));
 if pos('%genreintrack%',str) <> 0 then str:=replacestr(str,'%genreintrack%',paintstr('%genreintrack%'));
 if pos('%albumintrack%',str) <> 0 then str:=replacestr(str,'%albumintrack%',paintstr('%albumintrack%'));
 if pos('%yearintrack%',str) <> 0 then str:=replacestr(str,'%yearintrack%',paintstr('%yearintrack%'));
 if pos('()',str) <> 0 then str:=replacestr(str,'()','');
 if pos('%commentintrack%',str) <> 0 then str:=replacestr(str,'%commentintrack%',paintstr('%commentintrack%'));
 if pos('%curentsysvol%',str) <> 0 then str:=replacestr(str,'%curentsysvol%',paintstr('%curentsysvol%'));
 if pos('%radioconnect%',str) <> 0 then str:=replacestr(str,'%radioconnect%',paintstr('%radioconnect%'));
 if pos('%effectpage%',str) <> 0 then str:=replacestr(str,'%effectpage%',paintstr('%effectpage%'));
 if pos('%radiobuffering%',str) <> 0 then str:=replacestr(str,'%radiobuffering%',paintstr('%radiobuffering%'));
 if pos('%conradiostr%',str) <> 0 then str:=replacestr(str,'%conradiostr%',paintstr('%conradiostr%'));
 result:=str;
 if pos('deltext',result)<>0 then result:='';
end;

function paintstr(str:string):string;
begin
result:=str;
if str<>'' then
 begin
  case str of
   '%track%': begin result:=delbanner(artist+' - '+title);  exit; end;
   '%radiobuffering%': begin if progress>0 then result:=getfromlangpack('buffering')+' '+UTF8Encode(inttostr(Progress)+'%') else result:='';  exit; end;
   '%playervol%': begin result:=realtostr(SinglePlayerSettings.curentvol,0); exit; end;
   '%playfolder%': begin result:=curpldir; exit; end;
   '%curbitrate%': begin result:=bitratestr; exit; end;
   '%cureq%': begin result:=strcureq; exit; end;
   '%curpos%': begin result:=strpos; exit; end;
   '%tracktime%': begin result:=timetrack; exit; end;
   '%nomplaytrack%': begin result:=inttostr(SinglePlayerSettings.playedtrack); exit; end;
   '%curplaylist%': begin result:=inttostr(SinglePlayerSettings.curentplaylist); exit; end;
   '%kolltrack%': begin result:=inttostr(SinglePlayerSettings.kolltrack); exit; end;
   '%skinname%': begin result:=SinglePlayerSettings.skin; exit; end;
   '%curpage%': begin result:=curentpage; exit; end;
   '%artisttrack%': begin result:=delbanner(artist); exit; end;
   '%titletrack%': begin result:=delbanner(title); exit; end;
   '%curentdir%': begin result:=curentdir; exit; end;
   '%playfile%': begin result:=curenttrack; exit; end;
   '%curplaylistpage%': begin result:=inttostr(pageindex); exit; end;
   '%playlistpages%': begin result:=inttostr(pospage[pageindex]); exit; end;
   '%SinglePlayerDir%': begin result:=SinglePlayerDir; exit; end;
   '%playerversion%': begin result:=playerversion; exit; end;
   '%time%': begin result:=timeinicon; exit; end;
   '%date%': begin result:=dateinicon; exit; end;
   '%conradiostr%': begin result:=conradiostr; exit; end;
   '%genreintrack%': begin result:=UTF8Encode(thisTagv2.Genre); exit; end;
   '%albumintrack%': begin result:=UTF8Encode(thisTagv2.Album); exit; end;
   '%yearintrack%': begin result:=UTF8Encode(thisTagv2.Year); exit; end;
   '%commentintrack%': begin result:=UTF8Encode(thisTagv2.Comment); exit; end;
   '%curentsysvol%': begin  result:=inttostr(SinglePlayerSettings.curentsysvol); exit; end;
   '%radioconnect%': begin  if (connecting<>0) and (progress<1) then result:=getfromlangpack('connectiradio')+' '+inttostr(radioerror) else result:=''; exit; end;
   '%effectpage%': begin
                    case effectstr of
                     'bqflow': result:=getfromlangpack('lowpass');
                     'bqfhigh': result:=getfromlangpack('highpass');
                     'bqfpeakingeq': result:=getfromlangpack('peakingeq');
                     'p1': result:=getfromlangpack('freqsettings')+' 1';
                     'p2': result:=getfromlangpack('freqsettings')+' 2';
                     'p3': result:=getfromlangpack('freqsettings')+' 3';
                     'p4': result:=getfromlangpack('freqsettings')+' 4';
                     'p5': result:=getfromlangpack('freqsettings')+' 5';
                     'p6': result:=getfromlangpack('freqsettings')+' 6';
                     'p7': result:=getfromlangpack('freqsettings')+' 7';
                     'p8': result:=getfromlangpack('freqsettings')+' 8';
                     'p9': result:=getfromlangpack('freqsettings')+' 9';
                     'p10': result:=getfromlangpack('freqsettings')+' 10';
                     'p11': result:=getfromlangpack('freqsettings')+' 11';
                     'p12': result:=getfromlangpack('freqsettings')+' 12';
                     'p13': result:=getfromlangpack('freqsettings')+' 13';
                     'bqfbandpass': result:=getfromlangpack('bandpass');
                     'reverb': result:=getfromlangpack('reverberation');
                     'echo': result:=getfromlangpack('echo');
                     'chorus': result:=getfromlangpack('chorus');
                     'flanger': result:=getfromlangpack('flanger');
                     'tempo': result:=getfromlangpack('tempo');
                     'pitch': result:=getfromlangpack('pitch');
                     'compressor': result:=getfromlangpack('compressor');
                     'distortion': result:=getfromlangpack('distortion');
                     'phaser': result:=getfromlangpack('phaser');
                     'freeverb': result:=getfromlangpack('freeverb');
                     'autowah': result:=getfromlangpack('autowah');
                     'bqfnotch': result:=getfromlangpack('notch');
                    end;
                    exit;
                   end;
   '':exit;
  end;
 end;
end;

procedure TSinglePlayerGUI.FormPaint(Sender: TObject);    //действия при перерисовке окна плеера
begin
if curentpage='singleplayer' then scrolltimer.Enabled:=true else scrolltimer.Enabled:=false;
//-----------------------------------------------------------------------
paintplayericon(curentpage);
if (curentpage=plset.vizpage) and (SinglePlayerSettings.vizon=1) and ((mode=play) or (mode=radioplay)) then
 begin
  vizualizationtimer.Enabled:=true;
  startvizual;
 end else vizualizationtimer.Enabled:=false;
strkolcurtr:=getfromlangpack('inplaylist')+' '+inttostr(SinglePlayerSettings.kolltrack)+' '+getfromlangpack('songs');
if mode=play then strkolcurtr:=getfromlangpack('played')+' '+inttostr(SinglePlayerSettings.playedtrack)+' '+getfromlangpack('of')+' '+inttostr(SinglePlayerSettings.kolltrack)+' '+getfromlangpack('song');
if mode=radioplay then strkolcurtr:=getfromlangpack('played')+' '+curentradio;
strcureq:=getfromlangpack('cureq')+' '+copy(genremass[curentgenre,1],1,pos(';',genremass[curentgenre,1])-1);
curvol:=getfromlangpack('volume')+' '+realtostr(SinglePlayerSettings.curentvol,0);
  case curentpage of   //если текущая страница:       рисуем иконки под текстом----------
   'singleplayer': begin itelmaplayertext; end;  //писать текст в окне плеера
   'eq':begin eq; end;
    'playlist':begin  playlist; end;
    'disktree':begin gettree(curentdir,pospage[pageindex]); exit; end;
    'explorer':begin end;
    'playersettings':begin  playersettings; end;
    'iradio': begin  end;
    'keyboard': begin keyboardtext; end;
    'effectedit': begin effectedit(effectstr); end;
    'effectpage': begin effectpagetext; end;

  end;
  paintplayericonZprioryty(curentpage); //рисуем иконки над текстом
//---------------------------------------------------------------------------------------
   if SinglePlayerSettings.showcpu=1 then SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),740,450,cpuinfo);
   if msgtap=1 then msgdel;
   if msgtap=2 then msgfav;
   if msgtap=3 then msgflashadd(curworkusb);
   if msgtap=4 then setskinmsg(curworkskin);
end;

procedure effectpagetext;
var
 painteffect:string;
begin
 SinglePlayerGUI.Canvas.Font.Color:=plset.effectpagetextcolor;
 SinglePlayerGUI.Canvas.Font.Size:=plset.effectpagetextsize;


  painteffect:='distortion';
   if SinglePlayerSettings.ezf[30,1]='1' then
    begin
     SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloron;
     SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloron;
    end else
    begin
     SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloroff;
     SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloroff;
    end;
   SinglePlayerGUI.canvas.RoundRect(seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop,seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft+plset.effectlampwidth,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop+plset.effectlampheight,plset.effectlampangleX,plset.effectlampangleY);

   painteffect:='phaser';
    if SinglePlayerSettings.ezf[30,2]='1' then
     begin
      SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloron;
      SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloron;
     end else
     begin
      SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloroff;
      SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloroff;
     end;
    SinglePlayerGUI.canvas.RoundRect(seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop,seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft+plset.effectlampwidth,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop+plset.effectlampheight,plset.effectlampangleX,plset.effectlampangleY);

    painteffect:='freeverb';
     if SinglePlayerSettings.ezf[30,3]='1' then
      begin
       SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloron;
       SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloron;
      end else
      begin
       SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloroff;
       SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloroff;
      end;
     SinglePlayerGUI.canvas.RoundRect(seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop,seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft+plset.effectlampwidth,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop+plset.effectlampheight,plset.effectlampangleX,plset.effectlampangleY);

     painteffect:='autowah';
      if SinglePlayerSettings.ezf[30,4]='1' then
       begin
        SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloron;
        SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloron;
       end else
       begin
        SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloroff;
        SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloroff;
       end;
      SinglePlayerGUI.canvas.RoundRect(seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop,seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft+plset.effectlampwidth,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop+plset.effectlampheight,plset.effectlampangleX,plset.effectlampangleY);

      painteffect:='echo';
       if SinglePlayerSettings.ezf[30,5]='1' then
        begin
         SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloron;
         SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloron;
        end else
        begin
         SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloroff;
         SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloroff;
        end;
       SinglePlayerGUI.canvas.RoundRect(seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop,seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft+plset.effectlampwidth,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop+plset.effectlampheight,plset.effectlampangleX,plset.effectlampangleY);

       painteffect:='chorus';
        if SinglePlayerSettings.ezf[30,6]='1' then
         begin
          SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloron;
          SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloron;
         end else
         begin
          SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloroff;
          SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloroff;
         end;
        SinglePlayerGUI.canvas.RoundRect(seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop,seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft+plset.effectlampwidth,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop+plset.effectlampheight,plset.effectlampangleX,plset.effectlampangleY);

        painteffect:='flanger';
         if SinglePlayerSettings.ezf[30,7]='1' then
          begin
           SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloron;
           SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloron;
          end else
          begin
           SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloroff;
           SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloroff;
          end;
         SinglePlayerGUI.canvas.RoundRect(seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop,seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft+plset.effectlampwidth,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop+plset.effectlampheight,plset.effectlampangleX,plset.effectlampangleY);

         painteffect:='tempo';
          if SinglePlayerSettings.ezf[30,8]='1' then
           begin
            SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloron;
            SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloron;
           end else
           begin
            SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloroff;
            SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloroff;
           end;
          SinglePlayerGUI.canvas.RoundRect(seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop,seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft+plset.effectlampwidth,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop+plset.effectlampheight,plset.effectlampangleX,plset.effectlampangleY);

          painteffect:='compressor';
           if SinglePlayerSettings.ezf[30,9]='1' then
            begin
             SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloron;
             SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloron;
            end else
            begin
             SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloroff;
             SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloroff;
            end;
           SinglePlayerGUI.canvas.RoundRect(seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop,seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft+plset.effectlampwidth,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop+plset.effectlampheight,plset.effectlampangleX,plset.effectlampangleY);

           painteffect:='reverb';
            if SinglePlayerSettings.ezf[30,10]='1' then
             begin
              SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloron;
              SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloron;
             end else
             begin
              SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloroff;
              SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloroff;
             end;
            SinglePlayerGUI.canvas.RoundRect(seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop,seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft+plset.effectlampwidth,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop+plset.effectlampheight,plset.effectlampangleX,plset.effectlampangleY);

            painteffect:='pitch';
             if SinglePlayerSettings.ezf[30,11]='1' then
              begin
               SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloron;
               SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloron;
              end else
              begin
               SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloroff;
               SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloroff;
              end;
             SinglePlayerGUI.canvas.RoundRect(seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop,seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft+plset.effectlampwidth,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop+plset.effectlampheight,plset.effectlampangleX,plset.effectlampangleY);

             painteffect:='bqfhigh';
              if SinglePlayerSettings.ezf[30,12]='1' then
               begin
                SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloron;
                SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloron;
               end else
               begin
                SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloroff;
                SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloroff;
               end;
              SinglePlayerGUI.canvas.RoundRect(seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop,seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft+plset.effectlampwidth,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop+plset.effectlampheight,plset.effectlampangleX,plset.effectlampangleY);

              painteffect:='bqflow';
               if SinglePlayerSettings.ezf[30,13]='1' then
                begin
                 SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloron;
                 SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloron;
                end else
                begin
                 SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloroff;
                 SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloroff;
                end;
               SinglePlayerGUI.canvas.RoundRect(seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop,seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft+plset.effectlampwidth,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop+plset.effectlampheight,plset.effectlampangleX,plset.effectlampangleY);

               painteffect:='bqfbandpass';
                if SinglePlayerSettings.ezf[30,14]='1' then
                 begin
                  SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloron;
                  SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloron;
                 end else
                 begin
                  SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloroff;
                  SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloroff;
                 end;
                SinglePlayerGUI.canvas.RoundRect(seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop,seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft+plset.effectlampwidth,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop+plset.effectlampheight,plset.effectlampangleX,plset.effectlampangleY);

                painteffect:='bqfpeakingeq';
                 if SinglePlayerSettings.ezf[30,15]='1' then
                  begin
                   SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloron;
                   SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloron;
                  end else
                  begin
                   SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloroff;
                   SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloroff;
                  end;
                 SinglePlayerGUI.canvas.RoundRect(seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop,seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft+plset.effectlampwidth,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop+plset.effectlampheight,plset.effectlampangleX,plset.effectlampangleY);

                 painteffect:='bqfnotch';
                  if SinglePlayerSettings.ezf[30,16]='1' then
                   begin
                    SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloron;
                    SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloron;
                   end else
                   begin
                    SinglePlayerGUI.Canvas.Pen.Color:=plset.effectlampbordercoloroff;
                    SinglePlayerGUI.Canvas.Brush.Color:=plset.effectlampcoloroff;
                   end;
                  SinglePlayerGUI.canvas.RoundRect(seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop,seticons[getindexiconexecopt(painteffect)].left+plset.effectlampleft+plset.effectlampwidth,seticons[getindexiconexecopt(painteffect)].top+plset.effectlamptop+plset.effectlampheight,plset.effectlampangleX,plset.effectlampangleY);


end;

function getindexicon(iconcaption:string):integer;  //поиск номера иконки, по названию файла
var
  i:integer;
begin
try
 result:=0;
 for i:=1 to allicons do
  begin
   if seticons[i].caption='' then continue;
   if seticons[i].caption=iconcaption then result:=i;
  end;
except
 result:=0;
 LogAndExitPlayer('Ошибка в процедуре getindexicon',0,0);
end;
end;


function getindexiconexec(iconexec:string):integer;     //поиск номера иконки, по выполняемой команде
var
  i:integer;
begin
try
 result:=0;
 for i:=1 to allicons do
  begin
   if seticons[i].exec='' then continue;
   if seticons[i].exec=iconexec then result:=i;
  end;
except
  result:=0;
  LogAndExitPlayer('Ошибка в процедуре getindexicon',0,0);
end;
end;

function getindexiconexecopt(iconexecopt:string):integer;    //поиск номера иконки, по параметру выполняемой команде
var
  i:integer;
begin
try
 result:=0;
 for i:=1 to allicons do
  begin
   if seticons[i].execopt='' then continue;
   if seticons[i].execopt=iconexecopt then result:=i;
  end;
except
 result:=0;
 LogAndExitPlayer('Ошибка в процедуре getindexiconopt',0,0);
end;
end;

function getindexfromtext(texticon:string):integer;   //поиск номера иконки, по ее подписи
var
  i:integer;
begin
try
 result:=0;
 for i:=1 to allicons do
  begin
   if seticons[i].text='' then continue;
   if seticons[i].text=texticon then result:=i;
  end;
except
  result:=0;
  LogAndExitPlayer('Ошибка в процедуре getindexfromtext',0,0);
end;
end;

function setvisfromexec(iconexec:string; vis:string):string;  //установка видимости иконки, по выполняемой команде
var
  i:integer;
begin
try
 result:='good';
 for i:=1 to allicons do
  begin
   if seticons[i].exec='' then continue;
   if seticons[i].exec=iconexec then seticons[i].visible:=vis;
  end;
except
 result:='error';
 LogAndExitPlayer('Ошибка в процедуре setvisfromexec',0,0);
end;
end;

function setvisfromexecopt(iconexecopt:string; vis:string):string;  //установка видимости иконки, по выполняемой опции команды
var
  i:integer;
begin
try
 result:='good';
 for i:=1 to allicons do
  begin
   if seticons[i].execopt='' then continue;
   if seticons[i].execopt=iconexecopt then seticons[i].visible:=vis;
  end;
except
 result:='error';
 LogAndExitPlayer('Ошибка в процедуре setvisfromexecopt',0,0);
end;
end;

function setvisfromname(iconname:string; vis:string):string;  //установка видимости иконки, по выполняемой команде
var
  i:integer;
begin
try
 result:='good';
 for i:=1 to allicons do
  begin
   if seticons[i].caption='' then continue;
   if seticons[i].caption=iconname then seticons[i].visible:=vis;
  end;
except
 result:='error';
 LogAndExitPlayer('Ошибка в процедуре getindexiconfromname',0,0);
end;
end;

function RealToStr(X: Double; Digits: Integer): string; //переводим строку в вещественное число
var Xa: String;
    A, I, Ln: Integer;
    FlagSmall: Boolean;
begin
  If (Digits<0) or (Digits>9) then
  begin
    Result:='NAN';
    Exit;
  end;
  A:=1;
  if (Digits>0) then for I:=1 to Digits do A:=A*10;
  FlagSmall:=False;
  if Abs(X)<1 then
  begin
    FlagSmall:=True;
    if X<0 then X:=X-1 else X:=X+1;
  end;
  Xa:=IntToStr(trunc(X*A));
  if (Digits>0) then
  begin
    Ln:=Length(XA)-(Digits-1);
    Insert(',', Xa, Ln);
  end;
  {if FlagSmall then if X>0 then Xa[1]:=Chr(Ord(Xa[1])-1) else Xa[2]:=Chr(Ord(Xa[2])-1);}
  if FlagSmall then if X>0 then
  begin
    if (Xa[1]='1') then Xa[1]:='0';
    if (Xa[1]='2') then Xa[1]:='1';
  end
  else
  begin
    if (Xa[2]='1') then Xa[2]:='0';
    if (Xa[2]='2') then Xa[2]:='1';
  end;
  Result:=Xa;
end;

function RealToInt(X: Double; Digits: Integer): integer; //переводим строку в вещественное число
var Xa: String;
    A, I, Ln: Integer;
    FlagSmall: Boolean;
begin
  If (Digits<0) or (Digits>9) then
  begin
    Result:=0;
    Exit;
  end;
  A:=1;
  if (Digits>0) then for I:=1 to Digits do A:=A*10;
  FlagSmall:=False;
  if Abs(X)<1 then
  begin
    FlagSmall:=True;
    if X<0 then X:=X-1 else X:=X+1;
  end;
  Xa:=IntToStr(trunc(X*A));
  if (Digits>0) then
  begin
    Ln:=Length(XA)-(Digits-1);
    Insert(',', Xa, Ln);
  end;
  {if FlagSmall then if X>0 then Xa[1]:=Chr(Ord(Xa[1])-1) else Xa[2]:=Chr(Ord(Xa[2])-1);}
  if FlagSmall then if X>0 then
  begin
    if (Xa[1]='1') then Xa[1]:='0';
    if (Xa[1]='2') then Xa[1]:='1';
  end
  else
  begin
    if (Xa[2]='1') then Xa[2]:='0';
    if (Xa[2]='2') then Xa[2]:='1';
  end;
  Result:=strtoint(Xa);
end;

procedure TSinglePlayerGUI.PolSecondTimerTimer(Sender: TObject);
var
  i:integer;
  SystemTime: TSystemTime;
begin
 if moveexit>0 then dec(moveexit);
 scanningstr:='';
 GetLocalTime(SystemTime{%H-});
 timeinicon:=FormatDateTime('hh', Now)+':'+FormatDateTime('nn', Now);
 dateinicon:=GetDate;
{---------------- если появился новый диск выдать сообщение -------------------}
  if SinglePlayerSettings.autousb=1 then
   begin
    if (directoryexists('\SDMMC')=true) and (mmcdisks[2]='none') then begin mmcdisks[2]:='\SDMMC'; curworkusb:='SDMMC'; msgtap:=3; end;
    if (directoryexists('\SDMMC')=false) and (mmcdisks[2]='\SDMMC') then begin mmcdisks[2]:='none'; end;
    if (directoryexists('\Usb Disk')=true) and (mmcdisks[3]='none') then begin mmcdisks[3]:='\Usb Disk'; curworkusb:='Usb Disk'; msgtap:=3; end;
    if (directoryexists('\Usb Disk')=false) and (mmcdisks[3]='\Usb Disk') then begin mmcdisks[3]:='none'; end;
    if (directoryexists('\Usb Disk2')=true) and (mmcdisks[4]='none') then begin mmcdisks[4]:='\Usb Disk2'; curworkusb:='Usb Disk2'; msgtap:=3; end;
    if (directoryexists('\Usb Disk2')=false) and (mmcdisks[4]='\Usb Disk2') then begin mmcdisks[4]:='none'; end;
    if (directoryexists('\Usb Disk3')=true) and (mmcdisks[5]='none') then begin mmcdisks[5]:='\Usb Disk3'; curworkusb:='Usb Disk3'; msgtap:=3; end;
    if (directoryexists('\Usb Disk3')=false) and (mmcdisks[5]='\Usb Disk3') then begin mmcdisks[5]:='none'; end;
    if (directoryexists('\Usb Disk4')=true) and (mmcdisks[6]='none') then begin mmcdisks[6]:='\Usb Disk4'; curworkusb:='Usb Disk4'; msgtap:=3; end;
    if (directoryexists('\Usb Disk4')=false) and (mmcdisks[6]='\Usb Disk4') then begin mmcdisks[6]:='none'; end;
    if (directoryexists('\Usb Disk5')=true) and (mmcdisks[7]='none') then begin mmcdisks[7]:='\Usb Disk5'; curworkusb:='Usb Disk5'; msgtap:=3; end;
    if (directoryexists('\Usb Disk5')=false) and (mmcdisks[7]='\Usb Disk5') then begin mmcdisks[7]:='none'; end;
    if (directoryexists('\SDMMC2')=true) and (mmcdisks[8]='none') then begin mmcdisks[8]:='\SDMMC2'; curworkusb:='SDMMC2'; msgtap:=3; end;
    if (directoryexists('\SDMMC2')=false) and (mmcdisks[8]='\SDMMC2') then begin mmcdisks[8]:='none'; end;
    if (directoryexists('\SDMMC3')=true) and (mmcdisks[9]='none') then begin mmcdisks[9]:='\SDMMC3'; curworkusb:='SDMMC3'; msgtap:=3; end;
    if (directoryexists('\SDMMC3')=false) and (mmcdisks[9]='\SDMMC3') then begin mmcdisks[9]:='none'; end;
    if (directoryexists('\SDMMC4')=true) and (mmcdisks[10]='none') then begin mmcdisks[10]:='\SDMMC4'; curworkusb:='SDMMC4'; msgtap:=3; end;
    if (directoryexists('\SDMMC4')=false) and (mmcdisks[10]='\SDMMC4') then begin mmcdisks[10]:='none'; end;
    if (directoryexists('\USBDisk')=true) and (mmcdisks[11]='none') then begin mmcdisks[11]:='\USBDisk'; curworkusb:='USBDisk'; msgtap:=3; end;
    if (directoryexists('\USBDisk')=false) and (mmcdisks[11]='\SDMMC4') then begin mmcdisks[11]:='none'; end;
    if (directoryexists('\USBDisk2')=true) and (mmcdisks[12]='none') then begin mmcdisks[12]:='\USBDisk2'; curworkusb:='USBDisk2'; msgtap:=3; end;
    if (directoryexists('\USBDisk2')=false) and (mmcdisks[12]='\SDMMC4') then begin mmcdisks[12]:='none'; end;
    if (directoryexists('\USBDisk3')=true) and (mmcdisks[13]='none') then begin mmcdisks[13]:='\USBDisk3'; curworkusb:='USBDisk3'; msgtap:=3; end;
    if (directoryexists('\USBDisk3')=false) and (mmcdisks[13]='\SDMMC4') then begin mmcdisks[13]:='none'; end;
   end;
{------------------------------------------------------------------------------}
  if SinglePlayerSettings.scrolltrack=1 then scrollTimer.Enabled:=true else
   begin
    pr2:=0;
    pr4:=0;
    if SinglePlayerGUI.Canvas.TextWidth(artisttitle)>plset.tracktitlewidth then
     begin
     if SinglePlayerSettings.track2str=0 then scrolltitle:=delbanner(artist+title) else scrolltitle:=delbanner(artist);
      artisttitle:='';
      for i:=1 to length(scrolltitle) do if SinglePlayerGUI.Canvas.TextWidth(artisttitle)<=plset.tracktitlewidth then artisttitle:=artisttitle+scrolltitle[i];
     end;

     if SinglePlayerSettings.track2str=1 then
      begin
       pr2:=0;
       pr4:=0;
        if SinglePlayerGUI.Canvas.TextWidth(UTF8Encode(scrolltitlestr))>plset.tracktitlewidth then
         begin
          scrolltitle2:=delbanner(title);
          scrolltitlestr:='';
          for i:=1 to length(scrolltitle2) do if SinglePlayerGUI.Canvas.TextWidth(UTF8Encode(scrolltitlestr))<=plset.tracktitlewidth then scrolltitlestr:=scrolltitlestr+scrolltitle2[i];
         end;
       end;
     end;

end;

procedure TSinglePlayerGUI.scrollTimerTimer(Sender: TObject);
var
  i:integer;
begin
if wait<>0 then begin dec(wait); exit; end;
if curentpage='singleplayer' then
 begin
 SinglePlayerGUI.Canvas.Font.Color:=plset.tracktitlecolor;
 SinglePlayerGUI.Canvas.Font.Size:=plset.tracktitlesize;

 if SinglePlayerSettings.track2str=0 then artisttitle:=delbanner(artist+title) else begin artisttitle:=delbanner(artist); scrolltitlestr:=delbanner(title); end;

{прокрутка трека}
if SinglePlayerSettings.scrolltrack=1 then
begin

if SinglePlayerGUI.Canvas.TextWidth(artisttitle)>plset.tracktitlewidth then
begin
scrolltitle:='';
pr2:=0;
for i:=pr to length(artisttitle) do scrolltitle:=scrolltitle+artisttitle[i];
inc(pr);
artisttitle:='';
for i:=1 to length(scrolltitle) do if SinglePlayerGUI.Canvas.TextWidth(artisttitle)<plset.tracktitlewidth then artisttitle:=artisttitle+scrolltitle[i];
if SinglePlayerGUI.Canvas.TextWidth(artisttitle)<=plset.tracktitlewidth then begin wait:=3; pr:=1; end;
if pr=2 then wait:=3;
end else
begin
if SinglePlayerSettings.scrollsmalltrack=1 then
begin
if myalign(plset.tracktitleleft,artisttitle,0)+SinglePlayerGUI.Canvas.TextWidth(artisttitle)+pr2<myalign(plset.tracktitleleft,artisttitle,0)+plset.tracktitlewidth then pr2:=pr2+15 else begin pr2:=0; pr4:=-15; end;
end else pr2:=0;
end;

if SinglePlayerGUI.Canvas.TextWidth(UTF8Encode(scrolltitlestr))>plset.tracktitlewidth then
begin
scrolltitle2:='';
pr4:=0;
for i:=pr3 to length(scrolltitlestr) do scrolltitle2:=scrolltitle2+scrolltitlestr[i];
inc(pr3);
scrolltitlestr:='';
for i:=1 to length(scrolltitle2) do if SinglePlayerGUI.Canvas.TextWidth(UTF8Encode(scrolltitlestr))<plset.tracktitlewidth then scrolltitlestr:=scrolltitlestr+scrolltitle2[i];
if SinglePlayerGUI.Canvas.TextWidth(UTF8Encode(scrolltitlestr))<=plset.tracktitlewidth then begin wait:=3;pr3:=1; end;
if pr3=2 then wait:=3;
end else
begin
if SinglePlayerSettings.scrollsmalltrack=1 then
begin
if myalign(plset.tracktitleleft,scrolltitlestr,0)+SinglePlayerGUI.Canvas.TextWidth(UTF8Encode(scrolltitlestr))+pr4<myalign(plset.tracktitleleft,scrolltitlestr,0)+plset.tracktitlewidth then pr4:=pr4+15 else begin pr4:=0; pr2:=0; end;
end else pr4:=0;
end;

end;

{---------------------------------------------}
SinglePlayerGUI.Invalidate;

 end;
end;

procedure TSinglePlayerGUI.PeremotkaTimerTimer(Sender: TObject);
begin
  startnextbut:=1;
  inc(schetperemotka);
  if schetperemotka>1 then
   begin
    SinglePlayerGUI.Invalidate;
    SinglePlayerGUI.PeremotkaTimer.Enabled:=false;
    speedplay;
   end;
end;

procedure key8(klperorper:integer);{88-0 ; 8-1}
begin
 if klperorper=1 then
  begin
   if startnextbut=0 then SinglePlayerGUI.PeremotkaTimer.Enabled:=true else exit;
  end;
 if klperorper=0 then
  begin
   SinglePlayerGUI.PeremotkaTimer.Enabled:=false;
   startnextbut:=0;
   if schetperemotka<1 then
    begin
     if napr='forw' then playnexttrack;
     if napr='back' then playprevtrack;
    end else stopspeed:=1;
  end;

end;

procedure speedplay;
var
 speedpos,i:integer;
begin
 SinglePlayerGUI.PeremotkaTimer.Enabled:=false;
speedpos:=bass_ChannelGetPosition(channel,0);
stopspeed:=0;
for i:=1 to 1000 do
 begin
 if stopspeed=1 then exit;
 if (napr<>'forw') and (napr<>'back') then exit;
 if napr='forw' then {%H-}bass_ChannelSetPosition(Channel, speedpos+(i*1000000), 0);
 if napr='back' then {%H-}bass_ChannelSetPosition(Channel, speedpos-(i*1000000), 0);
 sleep(50);
 SinglePlayerGUI.Invalidate;
 application.ProcessMessages;
 if (mode=play) and ((BASS_ChannelIsActive(channel)=BASS_ACTIVE_STOPPED) or (bass_ChannelGetPosition(channel,0)<=0)) then exit;
 end;
end;

function SearchString(const FindStr, SourceString: string; Num: Integer):Integer;  {поиск подстроки с указанием количества позиций}
var
  FirstSym: PChar;

  function MyPos(const FindStr, SourceString: PChar; Num: Integer): PChar;
  begin
    Result := AnsiStrPos(SourceString, FindStr);
    if (Result = nil) then Exit;
    Inc(Result);
    if Num = 1 then exit;
    if num > 1 then Result := MyPos(FindStr, Result, num - 1);
  end;

begin
  FirstSym := PChar(SourceString);
  Result := MyPos(PChar(FindStr), PChar(SourceString), Num) - FirstSym;
  if Result < 0 then Result := 0;
end;

procedure sortingp.Execute;
begin
 try
  statusplaylist:=7;
  SinglePlayerGUI.Invalidate;
  QsString(track,SinglePlayerSettings.kolltrack-1);
  statusplaylist:=0;
  saveplaylist;
  SinglePlayerSettings.playedtrack:=gettrackindex(curenttrack);
  SinglePlayerGUI.invalidate;
  sorting.Free;
 except
  LogAndExitPlayer('Ошибка в процедуре sorting.execute',0,0);
  statusplaylist:=0;
  SinglePlayerGUI.Invalidate;
  sorting.Free;
 end;
end;

procedure QsString(var item: array of string; count:integer);   {метод быстрой сортировки}
  procedure qs(l, r: integer; var it:array of string);
    var
    i, j: integer;
    x, y: string;
  begin
    i := l; j := r;
    if singleplayersettings.sortingallpls=1 then
     begin
      x := ExtractFileName(uppercase(it[(l+r) div 2]));
      repeat
       while ExtractFileName(uppercase(it[i])) < x do i := i+1;
       while x < ExtractFileName(uppercase(it[j])) do j := j-1;
        if i<=j then
        begin
          y := it[i];
          it[i] := it[j];
          it[j] := y;
          i := i+1; j := j-1;
        end;
      until i>j;
     end else
     begin
     x := uppercase(it[(l+r) div 2]);
     repeat
      while uppercase(it[i]) < x do i := i+1;
      while x < uppercase(it[j]) do j := j-1;
       if i<=j then
       begin
         y := it[i];
         it[i] := it[j];
         it[j] := y;
         i := i+1; j := j-1;
       end;
     until i>j;
     end;
    if l<j then qs(l, j, it);
    if l<r then qs(i, r, it);
  end;
begin
   qs(0, count-1, item);
end;

procedure saveplaylist;
var
plfile:textfile;
i:integer;
begin
 try
 if statusplaylist=0 then
  begin
 statusplaylist:=2;
 SinglePlayerGUI.Invalidate;
 assignfile(plfile,SinglePlayerDir+'playlist_'+inttostr(SinglePlayerSettings.curentplaylist)+'.pls');
 rewrite(plfile);
   for i:=1 to SinglePlayerSettings.kolltrack do begin writeln(plfile,track[i]); end;
   closefile(plfile);
   statusplaylist:=0;
 end;
 except
 end;
end;

function gettrackindexbuf(trackcaption:string):integer;
var
  i:integer;
  srtrack:string;
begin
  result:=0;
 try
 for i:=1 to SinglePlayerSettings.kolltrackbuf do
  begin
   if pos('st#',trackbuf[i])<>0 then srtrack:=copy(trackbuf[i],pos('st#',trackbuf[i])+3,length(trackbuf[i])-pos('st#',trackbuf[i])-2) else srtrack:=trackbuf[i];
   if trackcaption=srtrack then result:=i;
  end;
 except
  LogAndExitPlayer('Ошибка в процедуре gettrackindexbuf',0,0);
 end;
end;

function gettrackindex(trackcaption:string):integer;
var
  i:integer;
  srtrack:string;
begin
 result:=0;
 try
 for i:=1 to SinglePlayerSettings.kolltrack do
  begin
   if pos('st#',track[i])<>0 then srtrack:=copy(track[i],pos('st#',track[i])+3,length(track[i])-pos('st#',track[i])-2) else srtrack:=track[i];
   if trackcaption=srtrack then result:=i;
  end;
 except
  LogAndExitPlayer('Ошибка в процедуре gettrackindex',0,0);
 end;
end;

function getgenreindex(genre:string):integer;
var
  i:integer;
begin
 try
 result:=1;
 for i:=1 to kollgenre do
  begin
   if LowerCase(copy(genremass[i,1],1,pos(';',genremass[i,1])-1))=LowerCase(genre) then result:=i;
  end;
 except
  LogAndExitPlayer('Ошибка в процедуре getgenreindex',0,0);
 end;
end;

function PosR2L(const FindS, SrcS: string): Integer;
  function InvertS(const S: string): string;
  var
    i, Len: Integer;
  begin
    Len := Length(S);
    SetLength(Result, Len);
    for i := 1 to Len do
      Result[i] := S[Len - i + 1];
  end;
var
  ps: Integer;
begin
  ps := Pos(InvertS(FindS), InvertS(SrcS));
  if ps <> 0 then
    Result := Length(SrcS) - Length(FindS) - ps + 2
  else
    Result := 0;
end;

procedure addtrackfolderp.Execute;
var
curdir:string;
plfile:textfile;
const
  ArrExt : array[1..7] of ansistring = ( '.mp3', '.wav','.ogg','.flac','.aiff','.m4a','.mpc');
begin
 try
 if statusplaylist=0 then
   begin
 statusplaylist:=1;
 SinglePlayerGUI.Canvas.Font.Color:=plset.statustextcolor;
 SinglePlayerGUI.Canvas.Font.Size:=plset.statustextsize;
 SinglePlayerGUI.Invalidate;
 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.statustextleft,getfromlangpack('saveplaylist'),1),plset.statustexttop,getfromlangpack('saveplaylist'));
 assignfile(plfile,SinglePlayerDir+'playlist_'+inttostr(SinglePlayerSettings.curentplaylist)+'.pls');
 curdir:=addtrackfolder.adir;
 try
  if playlistadd=0 then rewrite(plfile); //очищаем плейлист и создаем новый
  if (playlistadd=1) and (SinglePlayerSettings.sorttrue=0) then //добавляем в существующий плейлист без сортировки
    begin
     if fileexists(SinglePlayerDir+'playlist_'+inttostr(SinglePlayerSettings.curentplaylist)+'.pls') then append(plfile) else rewrite(plfile);
    end;
  EnumFolders(curdir, ArrExt, plfile,0);    //записываем файлы с подкаталогами в плейлист
  if SinglePlayerSettings.sorttrue=1 then   //если включена сортировка
    begin
     statusplaylist:=0;
     sortplaylistthead;
    end;
   if curenttrack='' then
     begin
      SinglePlayerSettings.curpos:=-1;
      curenttrack:=track[1];
      SinglePlayerSettings.playedtrack:=gettrackindexbuf(curenttrack);
      if (track[1]<>'') and (SinglePlayerSettings.playedtrack=0) then SinglePlayerSettings.playedtrack:=1;
     end;
   if playlistadd=0 then
   begin
     curenttrack:=track[1];
     SingleplayerSettings.playedtrack:=1;
     mode:=play;
     SinglePlayerSettings.curpos:=-1;
     itelmaplay(curenttrack);
   end;
 except
  statusplaylist:=0;
  closefile(plfile);
  LogAndExitPlayer('Ошибка создания плейлиста с подкаталогами',0,0);
  addtrackfolder.Free;
 end;
 closefile(plfile);
 statusplaylist:=0;
   end;
 if playadded=1 then begin playadded:=0; playusb('',3); end;
 addtrackfolder.Free;
 except
  statusplaylist:=0;
  closefile(plfile);
  addtrackfolder.Free;
 end;
end;

procedure addtrackp.Execute;
var
  j:integer;
  plfile:textfile;
begin
 try
  if statusplaylist=0 then
    begin
    statusplaylist:=1;
    SinglePlayerGUI.Canvas.Font.Color:=plset.statustextcolor;
    SinglePlayerGUI.Canvas.Font.Size:=plset.statustextsize;
    SinglePlayerGUI.Invalidate;
    SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.statustextleft,getfromlangpack('saveplaylist'),1),plset.statustexttop,getfromlangpack('saveplaylist'));
    assignfile(plfile,SinglePlayerDir+'playlist_'+inttostr(SinglePlayerSettings.curentplaylist)+'.pls');
  if playlistadd=0 then   //создаем новый плейлист, удаляя прошлый треки.
   begin
    try
     rewrite(plfile);
     for j:=1 to SinglePlayerSettings.kolltrackbuf do writeln(plfile,trackbuf[j]);
     closefile(plfile);
    except
     statusplaylist:=0;
     closefile(plfile);
     LogAndExitPlayer('Ошибка создания плейлиста',0,0);
     addtrack.Free;
    end;
   end;
  if playlistadd=1 then  //добавляем треки к существующим в плейлисте
   begin
     if fileexists(SinglePlayerDir+'playlist_'+inttostr(SinglePlayerSettings.curentplaylist)+'.pls') = false then
        begin
         try
          rewrite(plfile);
          for j:=1 to SinglePlayerSettings.kolltrackbuf do writeln(plfile,trackbuf[j]);
          closefile(plfile);
         except
          statusplaylist:=0;
          closefile(plfile);
          LogAndExitPlayer('Ошибка создания плейлиста',0,0);
          addtrack.Free;
         end;
        end else
        begin
        if SinglePlayerSettings.sorttrue=0 then   //сортировка выключена
          begin
           try
           append(plfile);
           if SinglePlayerSettings.recone=0 then for j:=threadkoltrack+1 to SinglePlayerSettings.kolltrackbuf do writeln(plfile,trackbuf[j])
                                  else for j:=threadkoltrack to threadkoltrack do writeln(plfile,track[j]);
           closefile(plfile);
           except
            statusplaylist:=0;
            LogAndExitPlayer('Ошибка обновления плейлиста',0,0);
            addtrack.Free;
           end;
          end;
        if SinglePlayerSettings.sorttrue=1 then    //сортировка включена
          begin
           statusplaylist:=0;
           sortplaylistthead;
          end;
        end;
   end;
   statusplaylist:=0;
   end;
  addtrack.Free;
 except
  LogAndExitPlayer('Ошибка в процедуре iniwritep.execute',0,0);
  statusplaylist:=0;
  addtrack.Free;
 end;
end;

procedure sortplaylistthead;
begin
 try
  if statusplaylist=0 then
  begin
   sorting:=sortingp.Create(true);
   sorting.freeonterminate := true;
   sorting.priority := tplower;
   sorting.Start;
  end;
 except
   LogAndExitPlayer('Ошибка в процедуре sortplaylistthead',0,0);
 end;
end;

procedure EnumFiles(aDir:string; const aArrExt:array of string; var filep:textfile; modeadd:byte);
const
  FileAttr : Integer = faDirectory;
var
  Sr : TSearchRec;
  StrExt : string;
  ExtIs : Boolean;
  i,k,k2 : Integer;
begin
 try
  if FindFirst(aDir + '\*', FileAttr, Sr) <> 0 then
   begin
    SysUtils.FindClose(Sr);
    Exit;
  end;
  repeat
    if (Sr.Attr and FileAttr) = FileAttr then Continue;
    StrExt := AnsiUpperCase( ExtractFileExt(Sr.Name) );
    ExtIs := False;
    for i := 0 to High(aArrExt) do begin
      if StrExt = AnsiUpperCase( aArrExt[i] ) then
       begin
        ExtIs := True;
        Break;
      end;
    end;
    if ExtIs then
     begin
      if modeadd=0 then
       begin
        if ((SinglePlayerSettings.sorttrue=0) and (playlistadd=1)) or (playlistadd=0) then writeln(filep,ReplaceStr(aDir+ '\'+Sr.Name,'\\','\'));
        inc(allkolltrack);
        track[allkolltrack]:=ReplaceStr(aDir+ '\'+Sr.Name,'\\','\');
       end else
       begin
        if exityes=0 then
         begin
          inc(tempallkolltrack);
          temptrackmas[tempallkolltrack]:=ReplaceStr(aDir+ '\'+Sr.Name,'\\','\');
         end else
         begin
          for k:=1 to tempallkolltrack do
           begin
            if temptrackmas[k]=ReplaceStr(aDir+ '\'+Sr.Name,'\\','\') then
             begin
              for k2:=k to tempallkolltrack-1 do temptrackmas[k2]:=temptrackmas[k2+1];
              temptrackmas[tempallkolltrack]:='';
              dec(tempallkolltrack);
              break;
             end;
           end;
         end;
       end;
     end;
  until FindNext(Sr) <> 0;
  SysUtils.FindClose(Sr);
  if modeadd=0 then SinglePlayerSettings.kolltrack:=allkolltrack;
 except
  LogAndExitPlayer('Ошибка в процедуре EnumFiles',0,0);
 end;
end;

procedure EnumFolders(aDir:string; const aArrExt:array of string; var filep:textfile; modeadd:byte);
const
  FileAttr : Integer = faDirectory;
var
  Sr : TSearchRec;
  i,i2:integer;
begin
 try
  exityes:=0;
  if adir[length(adir)]<>'\' then adir:=adir+'\';
  if not DirectoryExists(aDir) then Exit;
  if modeadd = 0 then EnumFiles(aDir, aArrExt,filep,0) else
   begin
    for i:=1 to fdir do
     begin
      if fdirmass[i]=adir then
       begin
        exityes:=1;
        for i2:=i to fdir-1 do fdirmass[i2]:=fdirmass[i2+1];
        fdirmass[fdir]:='';
        dec(fdir);
       end;
     end;
    if exityes=0 then
     begin
      inc(fdir);
      fdirmass[fdir]:=adir;
     end;

    EnumFiles(aDir, aArrExt,filep,1);
   end;
  if FindFirst(aDir + '\*', FileAttr, Sr) <> 0 then
   begin
    SysUtils.FindClose(Sr);
    enumworked:=0;
    Exit;
  end;
  repeat
    if ((Sr.Attr and FileAttr) <> FileAttr ) or (( Sr.Name = '.' ) or ( Sr.Name = '..' )) then Continue;
    if Sr.Name[length(Sr.Name)]<>'\' then sr.Name:=sr.Name+'\';
    if modeadd = 0 then EnumFolders(aDir + Sr.Name, aArrExt,filep,0) else
    begin
     if (aDir+Sr.Name <> aDir) and (singleplayersettings.recadd=0) then continue;
     EnumFolders(aDir+Sr.Name, aArrExt,filep,1);
    end;
  until FindNext(Sr) <> 0;
  enumworked:=0;
  SysUtils.FindClose(Sr);
 except
  LogAndExitPlayer('Ошибка в процедуре EnumFolders',0,0);
  enumworked:=0;
 end;
end;

procedure startaddtrackfolder(curdir:string);
begin
 try
 if playlistadd=0 then allkolltrack:=0;
 if playlistadd=1 then
  begin
   allkolltrack:=SinglePlayerSettings.kolltrack;
   if ((SinglePlayerSettings.playedtrack>SinglePlayerSettings.kolltrack) or (curenttrack='')) and (SinglePlayerSettings.kolltrack<>0) then
    begin
     SinglePlayerSettings.curpos:=-1;
     curenttrack:=track[1];
     SinglePlayerSettings.playedtrack:=gettrackindexbuf(curenttrack);
     if (track[1]<>'') and (SinglePlayerSettings.playedtrack=0) then SinglePlayerSettings.playedtrack:=1;
    end;
  end;
 addtrackfolder:=addtrackfolderp.Create(true);
 addtrackfolder.freeonterminate := true;
 addtrackfolder.priority := tplowest;
 addtrackfolder.adir:=curdir;
 addtrackfolder.Start;
 except
  LogAndExitPlayer('Ошибка в процедуре startaddtrackfolder',0,0);
 end;
end;

procedure eqwritep.Execute;
begin
 try
 saveeq;
 except
  LogAndExitPlayer('Ошибка в процедуре eqwritep.execute',0,0);
  eqwrite.Free;
 end;
end;

function delbadtext(textstr:string):string;
begin
 try
 while pos('&amp;',textstr)<>0 do delete(textstr,pos('&amp;',textstr),5);
 result:=textstr;
 except
  LogAndExitPlayer('Ошибка в процедуре delbadtext',0,0);
 end;
end;

procedure TSinglePlayerGUI.PlayerTimerTimer(Sender: TObject);
begin
 SinglePlayerGUI.Invalidate;
 playertimercode;
end;

function GetDate : string;
var SYear, SDay, SMonth: string;
    IMonth : integer;
begin
  SYear:=FormatDateTime('yyyy', Now);
  SDay:=FormatDateTime('d', Now);
  IMonth:=StrToInt(FormatDateTime('m', Now));
  If (IMonth=1) then SMonth:=getfromlangpack('january');
  If (IMonth=2) then SMonth:=getfromlangpack('february');
  If (IMonth=3) then SMonth:=getfromlangpack('march');
  If (IMonth=4) then SMonth:=getfromlangpack('april');
  If (IMonth=5) then SMonth:=getfromlangpack('may');
  If (IMonth=6) then SMonth:=getfromlangpack('june');
  If (IMonth=7) then SMonth:=getfromlangpack('july');
  If (IMonth=8) then SMonth:=getfromlangpack('august');
  If (IMonth=9) then SMonth:=getfromlangpack('september');
  If (IMonth=10) then SMonth:=getfromlangpack('october');
  If (IMonth=11) then SMonth:=getfromlangpack('november');
  If (IMonth=12) then SMonth:=getfromlangpack('december');
  Result:=SDay+' '+SMonth+' '+SYear;
end;

procedure playertimercode;
var
  	Timetrstr:single;
  	i:integer;
begin
	try
	if singleplayersettings.savepos = 1 then
	begin
		PlayerSettingsINI.WriteInteger('SinglePlayer','playedtrack',SinglePlayerSettings.playedtrack);
		PlayerSettingsINI.WriteInteger('SinglePlayer','curpos',bass_ChannelGetPosition(channel,0));
		PlayerSettingsINI.WriteInteger('SinglePlayer','curentplaylist',SinglePlayerSettings.curentplaylist);
		PlayerSettingsINI.WriteString('SinglePlayer','curentdir',curentdir);
		for i:=1 to kollpls do
		begin
			if fileexists(SinglePlayerDir+'playlist_'+inttostr(i)+'.pls') then
			begin
				plscurtrackpos[i,1]:=IniReadInteger(SP_SettIniMas,'playlist_'+inttostr(i),'curtrack',1);
				plscurtrackpos[i,2]:=IniReadInteger(SP_SettIniMas,'playlist_'+inttostr(i),'curpos',-1);
			end;
		end;
	end;
	PlayerSettingsINI.UpdateFile;

  if SinglePlayerSettings.showcpu=1 then cpuinfo:=realtostr(BASS_GetCPU,2);
  //if (mode=play) then if (BASS_ChannelIsActive(channel)=BASS_ACTIVE_STOPPED) then playnexttrack;
  if (mode=play) then if ((BASS_ChannelBytes2Seconds(channel, BASS_ChannelGetLength(channel,BASS_POS_BYTE))-BASS_ChannelBytes2Seconds(channel, BASS_ChannelGetPosition(channel,BASS_POS_BYTE)))<1) then playnexttrack;
  if (mode=radioplay) then if (BASS_ChannelIsActive(radiochannel)=BASS_ACTIVE_STALLED) then RadioStreamDisconnected; //Crazzy
  {---------------------------------------------------------------------}
  genreb:=0;
  Timetrstr:=BASS_ChannelBytes2Seconds(Channel,BASS_ChannelGetLength(Channel,BASS_POS_BYTE));
  if mode=play then bitratestr:=inttostr(Trunc(BASS_StreamGetFilePosition(Channel,BASS_FILEPOS_END)/(Timetrstr*125)))+' Kbps';
  if (mode=radioplay) and (connecting=0) then bitratestr:=inttostr(BASSGetBitRate(radiochannel));
  if (mode<>stop) then
  begin
   artist:='';
   title:='';
   try
    if singleplayersettings.readtags=1 then
     begin
      if mode=play then
       begin
        tagm:=BASS_ChannelGetTags(Channel,BASS_TAG_ID3);
        if tagm<>nil then
         begin
          artist:=tagm^.artist;
          title:=tagm^.title;
          genreb:=tagm^.genre;
         end;
       end;
     end;
   except
   end;
   if thisTagv2.Artist<>'' then artist:=UTF8Encode(thisTagv2.Artist);
   if thisTagv2.Title<>'' then title:=UTF8Encode(thisTagv2.Title);
   if (artist<>'') and (title<>'') and (SinglePlayerSettings.track2str=0) then title:=' - '+title;
   if (artist+title='') or (singleplayersettings.readtags=0) then
    begin
      if SinglePlayerSettings.autoeq=1 then setautoeq(0);
      artist:=extractfilename(ChangeFileExt(curenttrack,''));
      title:='';
     end;
   artist:=delbadtext(artist);
   title:=delbadtext(title);
   if SinglePlayerSettings.autoeq=1 then
    begin
     if thisTagv2.Genre<>'' then setautoeq(250) else setautoeq(genreb);
    end;
 {-----------------------------------------------------------------------------}
   if (mode<>radioplay) then
    begin                                                                           {время трека}
    TrackPos:=BASS_ChannelBytes2Seconds(Channel, BASS_ChannelGetLength(Channel,0));
    ValPos:=TrackPos / (24 * 3600);
    if TrackPos<3600 then timetrack:=FormatDateTime('nn:ss',Valpos) else timetrack:=FormatDateTime('hh:mm:ss',Valpos);        {время трека или оставшееся время}
   if SinglePlayerSettings.timerrevkey=0 then
     begin
      TrackPos:=BASS_ChannelBytes2Seconds(Channel, BASS_ChannelGetPosition(Channel,0));
      ValPos:=TrackPos / (24 * 3600);
      if TrackPos<3600 then strpos:=getfromlangpack('playtime')+' '+FormatDateTime('nn:ss',Valpos) else strpos:=getfromlangpack('playtime')+' '+FormatDateTime('hh:mm:ss',Valpos);
     end
   else
   begin
    TrackPos:=BASS_ChannelBytes2Seconds(Channel, BASS_ChannelGetLength(Channel,0))-BASS_ChannelBytes2Seconds(Channel, BASS_ChannelGetPosition(Channel,0));
    ValPos:=TrackPos / (24 * 3600);
    if TrackPos<3600 then strpos:=getfromlangpack('playtime')+' '+'- '+FormatDateTime('nn:ss',Valpos) else strpos:=getfromlangpack('playtime')+' '+'- '+FormatDateTime('hh:mm:ss',Valpos);
   end;
   if (mode=play) and (progresscor[1,1]=0) then
    begin
    for i:=1 to 100 do
      begin
       progresscor[i,1]:=plset.progressbarleft;
       progresscor[i,2]:=plset.progressbartop-10;
       progresscor[i,3]:=plset.progressbarleft  + (i*plset.progressbarwidth)+((i*plset.progressbarvir) div 10);
       progresscor[i,4]:=plset.progressbartop + plset.progressbarheight+10;
      end;
    end;
   end else
   begin
   if (connecting=0) then
    begin
      artist:=UTF8Decode(curentradio)+' ';
      title:=getnettag;
     end
     else
     begin
       artist:=UTF8Decode(curentradio)+' ';
       title:=getfromlangpack('connecting');
     end;
   end;
  end;
  if (BASS_GetCPU>SinglePlayerSettings.znachcpueq) and (SinglePlayerSettings.eqon=1) and (SinglePlayerSettings.perfeqexit=1) then begin SinglePlayerSettings.eqon:=0; eqclear; exit; end;
  if (BASS_GetCPU<SinglePlayerSettings.znachcpueqmin) and (SinglePlayerSettings.eqon=0) and (SinglePlayerSettings.perfeqon=1) then begin SinglePlayerSettings.eqon:=1; eqclear; exit; end;
 except
   LogAndExitPlayer('Ошибка в процедуре playertimerplay',0,0);
 end;
end;

procedure TSinglePlayerGUI.WndProc(var Msg: TMessage);
begin
 try
   if msg.msg= WM_IMCOMMAND then       {wparam = 0 - меню}  {wparam = 1 - Плеер}
    begin
     if (Msg.wParam=0) then
      begin
       if Msg.lParam=0 then begin SinglePlayerGUI.left:=0; SinglePlayerGUI.top:=0; SinglePlayerGUI.Height:=480; SinglePlayerGUI.Width:=800; exit; end; {поместить окно в left 0 top 0}
       if Msg.lParam=1 then begin PlayerExit; exit; end;
      end;

     if (Msg.wParam=1) and (mode<>closed) then {плеер-----------------------------------------------}
      begin
       if Msg.lParam=0 then {playerexit}
        begin
         curentpage:=oldpage;
         playerexit;
         SinglePlayerGUI.invalidate;
         exit;
        end;
       if Msg.lParam=1 then {player nexttrack}
        begin
         playnexttrack;
         SinglePlayerGUI.Invalidate;
         exit;
        end;
       if Msg.lParam=2 then {player prevtrack}
        begin
         playprevtrack;
         SinglePlayerGUI.Invalidate;
         exit;
        end;
       if Msg.lParam=3 then {player stopplay}
        begin
         singlestopplay;
         SinglePlayerGUI.Invalidate;
         exit;
        end;
       if Msg.lParam=4 then {player min}
        begin
          SinglePlayerGUI.Close;
        end;
       if Msg.lParam=5 then {player exit}
        begin
         playerexit;
         SinglePlayerGUI.Invalidate;
         exit;
        end;
       if Msg.lParam=6 then {player show}
        begin
         SinglePlayerGUI.Show;
        end;
       if Msg.lParam=7 then {nextpls}
        begin
         nextpls;
         SinglePlayerGUI.Invalidate;
         exit;
        end;
       if Msg.lParam=8 then {prevpls}
        begin
         prevpls;
         SinglePlayerGUI.Invalidate;
         exit;
        end;
       if Msg.lParam=9 then     {запросить общее время трека}
         begin
            senderstr('tracktime:'+RealToStr(BASS_ChannelBytes2Seconds(Channel, BASS_ChannelGetLength(Channel, BASS_POS_BYTE)),0));
         end;
       if Msg.lParam=10 then  {запросить текущее время трека}
         begin
            senderstr('trackpos:'+RealToStr(BASS_ChannelBytes2Seconds(Channel, BASS_ChannelGetPosition(Channel,0)),0));
         end;
       if Msg.lParam=11 then  {задать позицию проигрывания трека +5 сек}
         begin
            bass_ChannelSetPosition(Channel, BASS_ChannelSeconds2Bytes(Channel,BASS_ChannelBytes2Seconds(Channel, BASS_ChannelGetPosition(Channel,0))+5),0);
         end;
        if Msg.lParam=12 then  {задать позицию проигрывания трека -6 сек}
         begin
            bass_ChannelSetPosition(Channel, BASS_ChannelSeconds2Bytes(Channel,BASS_ChannelBytes2Seconds(Channel, BASS_ChannelGetPosition(Channel,0))-6),0);
         end;
        if Msg.lParam=13 then {player singlestop}
         begin
          itelmastop;
          SinglePlayerGUI.Invalidate;
          exit;
         end;
        if Msg.lParam=14 then {player singleplay}
         begin
          SinglePlay;
          SinglePlayerGUI.Invalidate;
          exit;
         end;


      end;{плеер конец-------------------------------------------------------------------------------------}

      if (Msg.wParam=3) and (mode<>closed) then {перемотка вперед с указанием числа секунды-------------------------}
       begin
        bass_ChannelSetPosition(Channel, BASS_ChannelSeconds2Bytes(Channel,BASS_ChannelBytes2Seconds(Channel, BASS_ChannelGetPosition(Channel,0))+Msg.lParam),0);
       end;
      if (Msg.wParam=4) and (mode<>closed) then {перемотка назад с указанием числа секунды-------------------------}
       begin
        bass_ChannelSetPosition(Channel, BASS_ChannelSeconds2Bytes(Channel,BASS_ChannelBytes2Seconds(Channel, BASS_ChannelGetPosition(Channel,0))-Msg.lParam),0);
       end;
    end;
 inherited WndProc(Msg);
 except
    LogAndExitPlayer('Ошибка в процедуре WndProc',0,0);
 end;
end;

procedure senderstr(strsnd:ansistring);
var
  MyCopyDataStruct: TCopyDataStruct;
begin
  with MyCopyDataStruct do
  begin
    cbData:= StrLen(PChar(strsnd)) + 1;
    lpData:= PChar(strsnd);
  end;
  SendCopyData(HWND_BROADCAST,MyCopyDataStruct);
end;

procedure SendCopyData(hTargetWnd: HWND; ACopyDataStruct:TCopyDataStruct);
begin
  if hTargetWnd<>0 then PostMessage(hTargetWnd, WM_COPYDATA, longint(SinglePlayerGUI.Handle), {%H-}Longint(@ACopyDataStruct));    //SendMessage
end;

procedure setplaypos(progresspos:integer);
begin
 try
 if (mode=play) and (curentpage='singleplayer') and (prblock=0) then bass_ChannelSetPosition(Channel, progresspos*BASS_ChannelGetLength(Channel,0) div 100, 0);
 except
   LogAndExitPlayer('Ошибка в процедуре setplaypos',0,0);
 end;
end;

procedure delfromdisk(plstrack:string);
var
 i,j:integer;
begin
 try
if (statusplaylist=0) and (plstrack<>'') then
 begin
 msgtap:=0;
 msgdelX:=-1;
 msgdelY:=-1;
  if plstrack=curenttrack then playnexttrack;
  if fileexists(plstrack) then sysutils.deletefile(plstrack);
 for i:=1 to SinglePlayerSettings.kolltrack do
   begin
    if plstrack=track[i] then
     begin
      if mode=play then
       begin
        npltr:=i;
        dec(SinglePlayerSettings.playedtrack);
       end;
      for j:=i to SinglePlayerSettings.kolltrack-1 do track[j]:=track[j+1];
      dec(SinglePlayerSettings.kolltrack);
      playlistferstopen:=0;
      SinglePlayerGUI.repaint;
      saveplaylist;
      exit;
     end;
   end;

 end;

 except
  LogAndExitPlayer('Ошибка в процедуре delfromdisk',0,0);
 end;
end;

procedure delfrompls(plstrack:string);
var
 i,j:integer;
begin
 try
 if (statusplaylist=0) and (plstrack<>'') then
  begin
 for i:=1 to SinglePlayerSettings.kolltrack do
   begin
    if plstrack=track[i] then
     begin
      for j:=i to SinglePlayerSettings.kolltrack-1 do track[j]:=track[j+1];
      dec(SinglePlayerSettings.kolltrack);
      npltr:=0;
      SinglePlayerGUI.repaint;
      saveplaylist;
      exit;
     end;
   end;
  end;

 except
  LogAndExitPlayer('Ошибка в процедуре delfrompls',0,0);
 end;
end;

procedure favtopls(plstrack:string);
var
plfile:textfile;
begin
 try
 msgtap:=0;
 msgfavX:=-1;
 msgfavY:=-1;
 if (statusplaylist=0) and (plstrack<>'') then
  begin
   if fileexists(SinglePlayerDir+'playlist_'+inttostr(kollpls)+'.pls') then
   begin
     statusplaylist:=2;
     SinglePlayerGUI.Invalidate;
     assignfile(plfile,SinglePlayerDir+'playlist_'+inttostr(kollpls)+'.pls');
     append(plfile);
     writeln(plfile,plstrack);
     closefile(plfile);
     statusplaylist:=0;
   end else
   begin
    statusplaylist:=2;
     SinglePlayerGUI.Invalidate;
    assignfile(plfile,SinglePlayerDir+'playlist_'+inttostr(kollpls)+'.pls');
    rewrite(plfile);
    writeln(plfile,plstrack);
    closefile(plfile);
    statusplaylist:=0;
   end;
  end;
 except
  LogAndExitPlayer('Ошибка в процедуре favtopls',0,0);
 end;
end;

procedure MyFileCopy(Const SourceFileName, TargetFileName: string);
var
 A,F : TFileStream;
begin
 A := TFileStream.Create(sourcefilename, fmOpenRead and fmShareDenyNone );
try
 F := TFileStream.Create(targetfilename, fmOpenReadWrite or fmCreate);
try
 F.CopyFrom(A, A.Size ) ;
 FileSetDate(F.Handle, FileGetDate(A.Handle));
finally
 F.Free;
end;
finally
 A.Free;
end;
 end;

procedure favtoplsandfolder(plstrack:string);
var
plfile:textfile;
begin
 try
 msgtap:=0;
 msgfavX3:=-1;
 msgfavY3:=-1;
  if (statusplaylist=0) and (plstrack<>'') then
   begin
    if directoryexists(SinglePlayerSettings.favoritfolder)=false then ForceDirectories(SinglePlayerSettings.favoritfolder);
    if (directoryexists(SinglePlayerSettings.favoritfolder)) and (SinglePlayerSettings.favoritfolder<>'') then
     begin
      if SinglePlayerSettings.favoritfolder[length(SinglePlayerSettings.favoritfolder)]<>'\' then SinglePlayerSettings.favoritfolder:=SinglePlayerSettings.favoritfolder+'\';
      if plstrack<>curenttrack then MyFileCopy(plstrack,SinglePlayerSettings.favoritfolder+ExtractFileName(plstrack)) else
       begin
        BASS_ChannelStop(channel);
        BASS_StreamFree(channel);
        MyFileCopy(plstrack,SinglePlayerSettings.favoritfolder+ExtractFileName(plstrack));
        if mode=play then itelmaplay(curenttrack);
       end;
     end;

    if fileexists(SinglePlayerDir+'playlist_'+inttostr(kollpls)+'.pls') then
    begin
      statusplaylist:=2;
       SinglePlayerGUI.Invalidate;
      assignfile(plfile,SinglePlayerDir+'playlist_'+inttostr(kollpls)+'.pls');
      append(plfile);
      writeln(plfile,SinglePlayerSettings.favoritfolder+ExtractFileName(plstrack));
      closefile(plfile);
      statusplaylist:=0;
    end else
    begin
     statusplaylist:=2;
      SinglePlayerGUI.Invalidate;
     assignfile(plfile,SinglePlayerDir+'playlist_'+inttostr(kollpls)+'.pls');
     rewrite(plfile);
     writeln(plfile,SinglePlayerSettings.favoritfolder+ExtractFileName(plstrack));
     closefile(plfile);
     statusplaylist:=0;
    end;

   end;
 except
  LogAndExitPlayer('Ошибка в процедуре favtoplsandfolder',0,0);
 end;
end;

procedure playusb(usbd:string; addmode:byte);   {addmode 0 создать, 1 добавить}
var
 stau,playno:byte;
begin
stau:=0;
playno:=0;
playadded:=0;
 if mode=closed then begin if SinglePlayerSettings.startautoplay=1 then stau:=1; SinglePlayerStart; if stau=1 then SinglePlayerSettings.startautoplay:=1; end;

 if addmode=0 then   {создать плейлист}
  begin
   playlistadd:=0;
   playadded:=1;
   playno:=0;
   startaddtrackfolder('\'+usbd+'\');
   SinglePlayerGUI.playertimer.Enabled:=true;
  end;

 if addmode=1 then   {добавить в плейлист}
  begin
   playlistadd:=1;
   playadded:=0;
   playno:=1;
   playlistread(SinglePlayerSettings.curentplaylist);
   startaddtrackfolder('\'+usbd+'\');
   if mode=play then SinglePlayerGUI.playertimer.Enabled:=true;
  end;

 if addmode=3 then
  begin
  playadded:=0;
  playlistread(SinglePlayerSettings.curentplaylist);
  if playno=0 then
   begin
    SinglePlayerSettings.curpos:=-1;
    curenttrack:=track[1];
    SinglePlayerSettings.playedtrack:=1;
    itelmaplay(curenttrack);
    mode:=play;
    SinglePlayerGUI.playertimer.Enabled:=true;
   end;
  end;
end;

procedure IRadioStart;
begin

end;

procedure itelmaplay(musictrack:string);
var
  errortrack:integer;
begin
 try
 coverimgot.Clear;
 coverimgot.SetSize(0,0);
 coverimg.Clear;
 coverimg.SetSize(0,0);
 coverimgotRadio.Clear;
 coverimgotRadio.SetSize(0,0);
 coverimgRadio.Clear;
 coverimgRadio.SetSize(0,0);
 progresscor[1,1]:=0;
 errortrack:=-1;
 musictrack:=ChangeFileExt(musictrack,lowercase(ExtractFileExt(musictrack)));
      BASS_ChannelStop(radiochannel);
      BASS_StreamFree(radiochannel);
      mode:=stop;
    try
    if musictrack<>'' then
     begin
      thisTagv2.Clear;
      while (not FileExists(musictrack)) and (SinglePlayerSettings.playedtrack<=SinglePlayerSettings.kolltrack) do
       begin
        inc(SinglePlayerSettings.playedtrack);
        musictrack:=track[SinglePlayerSettings.playedtrack];
       end;
    if (length(musictrack)-pos('.flac',musictrack)<>4) or (pos('.flac',musictrack)=0) or (length(musictrack)-pos('.m4a',musictrack)<>3) or (pos('.m4a',musictrack)=0) or (length(musictrack)-pos('.mpc',musictrack)<>3) or (pos('.mpc',musictrack)=0) then     {если не флак то выставляем автожанр}
     begin
    if singleplayersettings.readtags=1 then
     begin
    thisTagv2.ReadFromFile(musictrack);
    if SinglePlayerSettings.playfromgenre=1 then
     begin
      while (lowercase(thisTagv2.Genre)<>lowercase(copy(genremass[curentgenre,1],1,pos(';',genremass[curentgenre,1])-1))) and (FileExists(musictrack)) and (SinglePlayerSettings.playedtrack<SinglePlayerSettings.kolltrack) and (SinglePlayerSettings.playedtrack<>1) do
       begin
        if statusplaylist<>5 then
         begin
            statusplaylist:=5;
            SinglePlayerGUI.repaint;
         end;
        if clickprev=1 then dec(SinglePlayerSettings.playedtrack) else inc(SinglePlayerSettings.playedtrack);
        musictrack:=track[SinglePlayerSettings.playedtrack];
        thisTagv2.ReadFromFile(musictrack);
       end;
     end;
     end;
    end;
      if not FileExists(musictrack) then
       begin
        BASS_ChannelStop(radiochannel);
        BASS_StreamFree(radiochannel);
        mode:=stop;
        SinglePlayerGUI.Invalidate;
        playnexttrack;
       end;
      BASS_ChannelStop(Channel);
      BASS_StreamFree(Channel);
      if ((length(musictrack)-pos('.flac',musictrack)=4) and (pos('.flac',musictrack)<>0)) or ((length(musictrack)-pos('.m4a',musictrack)=3) and (pos('.m4a',musictrack)<>0)) or ((length(musictrack)-pos('.mpc',musictrack)=3) and (pos('.mpc',musictrack)<>0))  then   {если флак то считываем теги}
       begin
        if (length(musictrack)-pos('.flac',musictrack)=4) and (pos('.flac',musictrack)<>0) then Channel := BASS_FLAC_StreamCreateFile(false, PChar(musictrack), 0, 0,BASS_SAMPLE_FX and BASS_STREAM_AUTOFREE);
        if (length(musictrack)-pos('.m4a',musictrack)=3) and (pos('.m4a',musictrack)<>0) then
         begin
          Channel := BASS_ALAC_StreamCreateFile(false, PChar(musictrack), 0, 0,BASS_SAMPLE_FX and BASS_STREAM_AUTOFREE);
          BASS_ChannelGetInfo (channel,chinfo);
          if chinfo.ctype <> BASS_CTYPE_STREAM_ALAC then Channel := BASS_MP4_StreamCreateFile(false, PChar(musictrack), 0, 0,BASS_SAMPLE_FX and BASS_STREAM_AUTOFREE);
         end;
        if (length(musictrack)-pos('.mpc',musictrack)=3) and (pos('.mpc',musictrack)<>0) then Channel := BASS_MPC_StreamCreateFile(false, PChar(musictrack), 0, 0,BASS_SAMPLE_FX and BASS_STREAM_AUTOFREE);
     if singleplayersettings.readtags=1 then
       begin
        thisTagv2.Genre:=UTF8Encode(TAGS_Read(Channel, '%GNRE'));
        thisTagv2.Artist:=UTF8Encode(TAGS_Read(Channel, '%ARTI'));
        thisTagv2.Title:=UTF8Encode(TAGS_Read(Channel, '%TITL'));
     if SinglePlayerSettings.playfromgenre=1 then                                   {если автоэквалайзер то выставляем экв по значению флак тега}
     begin
      while (lowercase(thisTagv2.Genre)<>lowercase(copy(genremass[curentgenre,1],1,pos(';',genremass[curentgenre,1])-1))) and (FileExists(musictrack)) and (SinglePlayerSettings.playedtrack<SinglePlayerSettings.kolltrack) and (SinglePlayerSettings.playedtrack<>1) do
       begin
        if statusplaylist<>5 then
         begin
            statusplaylist:=5;
            SinglePlayerGUI.repaint;
         end;
        if clickprev=1 then dec(SinglePlayerSettings.playedtrack) else inc(SinglePlayerSettings.playedtrack);
        musictrack:=track[SinglePlayerSettings.playedtrack];
        if ((length(musictrack)-pos('.flac',musictrack)=4) and (pos('.flac',musictrack)<>0)) or ((length(musictrack)-pos('.m4a',musictrack)=3) and (pos('.m4a',musictrack)<>0)) or ((length(musictrack)-pos('.mpc',musictrack)=3) and (pos('.mpc',musictrack)<>0))  then
         begin
          if (length(musictrack)-pos('.flac',musictrack)=4) then
          begin
            if (SinglePlayerSettings.tempo<>0) or (SinglePlayerSettings.pitch<>0) then
             begin
              Channel := BASS_FLAC_StreamCreateFile(false, PChar(musictrack), 0, 0, BASS_STREAM_DECODE);
              channel := BASS_FX_TempoCreate(channel, BASS_FX_FREESOURCE);
             end else Channel := BASS_FLAC_StreamCreateFile(false, PChar(musictrack), 0, 0, BASS_SAMPLE_FX and BASS_STREAM_AUTOFREE);
           end;
          if (length(musictrack)-pos('.m4a',musictrack)=3) then
          begin
           if (SinglePlayerSettings.tempo<>0) or (SinglePlayerSettings.pitch<>0) then
            begin
             Channel :=  BASS_ALAC_StreamCreateFile(false, PChar(musictrack), 0, 0, BASS_STREAM_DECODE);
             BASS_ChannelGetInfo (channel,chinfo);
             if chinfo.ctype <> BASS_CTYPE_STREAM_ALAC then Channel := BASS_MP4_StreamCreateFile(false, PChar(musictrack), 0, 0, BASS_STREAM_DECODE);
             channel := BASS_FX_TempoCreate(channel, BASS_FX_FREESOURCE);
            end else
            begin
             Channel :=  BASS_ALAC_StreamCreateFile(false, PChar(musictrack), 0, 0, BASS_SAMPLE_FX and BASS_STREAM_AUTOFREE);
             BASS_ChannelGetInfo (channel,chinfo);
             if chinfo.ctype <> BASS_CTYPE_STREAM_ALAC then Channel := BASS_MP4_StreamCreateFile(false, PChar(musictrack), 0, 0, BASS_SAMPLE_FX and BASS_STREAM_AUTOFREE);
            end;
           end;
          if (length(musictrack)-pos('.mpc',musictrack)=3) then
          begin
            if (SinglePlayerSettings.tempo<>0) or (SinglePlayerSettings.pitch<>0) then
             begin
              Channel := BASS_MPC_StreamCreateFile(false, PChar(musictrack), 0, 0, BASS_STREAM_DECODE);
              channel := BASS_FX_TempoCreate(channel, BASS_FX_FREESOURCE);
             end else Channel := BASS_MPC_StreamCreateFile(false, PChar(musictrack), 0, 0, BASS_SAMPLE_FX and BASS_STREAM_AUTOFREE);
           end;
        thisTagv2.Genre:=UTF8Encode(TAGS_Read(Channel, '%GNRE'));
        thisTagv2.Artist:=UTF8Encode(TAGS_Read(Channel, '%ARTI'));
        thisTagv2.Title:=UTF8Encode(TAGS_Read(Channel, '%TITL'));
         end else thisTagv2.ReadFromFile(musictrack);
       end;
     end;
     end;
       end else
       begin
          if (SinglePlayerSettings.tempo<>0) or (SinglePlayerSettings.pitch<>0) then
           begin
            Channel := BASS_StreamCreateFile(false, PChar(musictrack), 0, 0, BASS_STREAM_DECODE);
            channel := BASS_FX_TempoCreate(channel, BASS_FX_FREESOURCE );
           end else Channel := BASS_StreamCreateFile(false, PChar(musictrack), 0, 0, BASS_SAMPLE_FX and BASS_STREAM_AUTOFREE);
       end;

      if SinglePlayerSettings.curpos<>-1  then
       begin
        bass_ChannelSetPosition(channel,SinglePlayerSettings.curpos,0);
        SinglePlayerSettings.curpos:=-1;
       end;

     {звпуск проигрывания}
     if timestartplay<>0 then bass_ChannelSetPosition(channel,BASS_ChannelSeconds2Bytes(channel,timestartplay),0);   //1set
     eqapply(channel);
     if SinglePlayerSettings.mute=0 then BASS_ChannelSetAttribute(channel,BASS_ATTRIB_VOL,SinglePlayerSettings.curentvol/10) else BASS_ChannelSetAttribute(channel,BASS_ATTRIB_VOL,0);
     if not BASS_ChannelPlay(Channel, False) then
      begin
      errortrack:=SinglePlayerSettings.playedtrack;
      inc(SinglePlayerSettings.playedtrack);
      while (not BASS_ChannelPlay(Channel, False)) and (SinglePlayerSettings.playedtrack<>errortrack) do
       begin
        musictrack:=track[SinglePlayerSettings.playedtrack];
        if ((length(musictrack)-pos('.flac',musictrack)=4) and (pos('.flac',musictrack)<>0)) or ((length(musictrack)-pos('.m4a',musictrack)=3) and (pos('.m4a',musictrack)<>0)) or ((length(musictrack)-pos('.mpc',musictrack)=3) and (pos('.mpc',musictrack)<>0))  then
         begin
           if (length(musictrack)-pos('.flac',musictrack)=4) and (pos('.flac',musictrack)<>0) then
            begin
           if (SinglePlayerSettings.tempo<>0) or (SinglePlayerSettings.pitch<>0) then
            begin
             Channel := BASS_FLAC_StreamCreateFile(false, PChar(musictrack), 0, 0,  BASS_STREAM_DECODE);
             channel := BASS_FX_TempoCreate(channel, BASS_FX_FREESOURCE);
            end else Channel := BASS_FLAC_StreamCreateFile(false, PChar(musictrack), 0, 0,BASS_SAMPLE_FX and BASS_STREAM_AUTOFREE);
            end;
           if (length(musictrack)-pos('.m4a',musictrack)=3) and (pos('.m4a',musictrack)<>0) then
            begin
              if (SinglePlayerSettings.tempo<>0) or (SinglePlayerSettings.pitch<>0) then
               begin
                Channel :=  BASS_ALAC_StreamCreateFile(false, PChar(musictrack), 0, 0, BASS_STREAM_DECODE);
                BASS_ChannelGetInfo (channel,chinfo);
                if chinfo.ctype <> BASS_CTYPE_STREAM_ALAC then Channel := BASS_MP4_StreamCreateFile(false, PChar(musictrack), 0, 0, BASS_STREAM_DECODE);
                channel := BASS_FX_TempoCreate(channel, BASS_FX_FREESOURCE);
               end else
               begin
                Channel :=  BASS_ALAC_StreamCreateFile(false, PChar(musictrack), 0, 0, BASS_SAMPLE_FX and BASS_STREAM_AUTOFREE);
                BASS_ChannelGetInfo (channel,chinfo);
                if chinfo.ctype <> BASS_CTYPE_STREAM_ALAC then Channel := BASS_MP4_StreamCreateFile(false, PChar(musictrack), 0, 0, BASS_SAMPLE_FX and BASS_STREAM_AUTOFREE);
               end;
           end;
          if (length(musictrack)-pos('.mpc',musictrack)=3) and (pos('.mpc',musictrack)<>0) then
           begin
          if (SinglePlayerSettings.tempo<>0) or (SinglePlayerSettings.pitch<>0) then
           begin
            Channel := BASS_MPC_StreamCreateFile(false, PChar(musictrack), 0, 0,  BASS_STREAM_DECODE);
            channel := BASS_FX_TempoCreate(channel, BASS_FX_FREESOURCE);
           end else Channel := BASS_MPC_StreamCreateFile(false, PChar(musictrack), 0, 0,BASS_SAMPLE_FX and BASS_STREAM_AUTOFREE);
           end;
          if singleplayersettings.readtags=1 then
           begin
            thisTagv2.Genre:=UTF8Encode(TAGS_Read(Channel, '%GNRE'));
            thisTagv2.Artist:=UTF8Encode(TAGS_Read(Channel, '%ARTI'));
            thisTagv2.Title:=UTF8Encode(TAGS_Read(Channel, '%TITL'));
           end;
         end else
         begin
           if (SinglePlayerSettings.tempo<>0) or (SinglePlayerSettings.pitch<>0) then
            begin
             Channel := BASS_StreamCreateFile(false, PChar(musictrack), 0, 0,  BASS_STREAM_DECODE);
             channel := BASS_FX_TempoCreate(channel, BASS_FX_FREESOURCE);
            end else Channel := BASS_StreamCreateFile(false, PChar(musictrack), 0, 0,  BASS_SAMPLE_FX and BASS_STREAM_AUTOFREE);
         end;
        inc(SinglePlayerSettings.playedtrack);
        if SinglePlayerSettings.playedtrack>SinglePlayerSettings.kolltrack then SinglePlayerSettings.playedtrack:=1;
       end;
      if errortrack=SinglePlayerSettings.playedtrack then
       begin
        BASS_ChannelStop(radiochannel);
        BASS_StreamFree(radiochannel);
        mode:=stop;
        SinglePlayerGUI.Invalidate;
        playnexttrack;
       end else
       begin
        if statusplaylist=5 then statusplaylist:=0;
        curenttrack:=musictrack;
        npltr:=SinglePlayerSettings.playedtrack;
        pr:=1;    {pr pr2 обнуление прокрутки трека}
        pr2:=0;
        pr3:=1;
        pr4:=0;
        mode:=play;
        if SinglePlayerSettings.mute=0 then BASS_ChannelSetAttribute(channel,BASS_ATTRIB_VOL,SinglePlayerSettings.curentvol/10) else BASS_ChannelSetAttribute(channel,BASS_ATTRIB_VOL,0);
        SinglePlayerGUI.playertimer.Enabled:=true;
        playedtrack[SinglePlayerSettings.playedtrack]:=SinglePlayerSettings.playedtrack;
        if (length(musictrack)-pos('.flac',musictrack)<>4) or (pos('.flac',musictrack)=0) or (length(musictrack)-pos('.m4a',musictrack)<>3) or (pos('.m4a',musictrack)=0) or (length(musictrack)-pos('.mpc',musictrack)<>3) or (pos('.mpc',musictrack)=0)  then thisTagv2.ReadFromFile(musictrack) else
        begin
         if singleplayersettings.readtags=1 then
          begin
           thisTagv2.Genre:=UTF8Encode(TAGS_Read(Channel, '%GNRE'));
           thisTagv2.Artist:=UTF8Encode(TAGS_Read(Channel, '%ARTI'));
           thisTagv2.Title:=UTF8Encode(TAGS_Read(Channel, '%TITL'));
          end;
        end;
        if SinglePlayerSettings.showcoverpl=1 then
         begin
           loadcaver:=loadcaverp.Create(true);
           loadcaver.freeonterminate := true;
           loadcaver.priority := tpIdle;
           loadcaver.Start;
         end;
       end;
      end else
      begin
      if statusplaylist=5 then statusplaylist:=0;
       curenttrack:=musictrack;
       pr:=1;    {pr pr2 обнуление прокрутки трека}
       pr2:=0;
       pr3:=1;
       pr4:=0;
       mode:=play;
       npltr:=SinglePlayerSettings.playedtrack;
       if SinglePlayerSettings.mute=0 then BASS_ChannelSetAttribute(channel,BASS_ATTRIB_VOL,SinglePlayerSettings.curentvol/10) else BASS_ChannelSetAttribute(channel,BASS_ATTRIB_VOL,0);
       playedtrack[SinglePlayerSettings.playedtrack]:=SinglePlayerSettings.playedtrack;
       SinglePlayerGUI.playertimer.Enabled:=true;
       if SinglePlayerSettings.showcoverpl=1 then
        begin
         loadcaver:=loadcaverp.Create(true);
         loadcaver.freeonterminate := true;
         loadcaver.priority := tpnormal;
         loadcaver.Start;
        end;
      end;
     end else playnexttrack;
 except
   playnexttrack;
 end;
 clicknext:=0;
 clickprev:=0;

 except
   LogAndExitPlayer('Ошибка в процедуре itelmaplay',0,0);
 end;
end;

procedure iradioplay(radiourl:string);
begin
 lastradiourl:=radiourl;
 try
 mode:=stop;
 BASS_ChannelStop(radiochannel);
 BASS_StreamFree(radiochannel);
 BASS_ChannelStop(channel);
 BASS_StreamFree(channel);
 bass_free();
 setinitbass;
 if connecting<>1 then
   begin
    radioerror:=1;
    radiochannel:=0;
    progress:=0;
    connecting:=1;
    connectradio:=connectradiop.Create(true);
    connectradio.freeonterminate := true;
    connectradio.radiourlp:=radiourl;
    connectradio.priority := tpLowest;   {tpIdle tpLowest tpLower tpNormal tpHigher tpHighest tpTimeCritical}
    connectradio.Start;
   end;
  SinglePlayerGUI.Invalidate;
 except
  SinglePlayerGUI.repaint;
  if curentpage='iradio' then SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.tracktitleleft,getfromlangpack('errorconnect'),1),plset.tracktitletop,getfromlangpack('errorconnect'));
  sleep(1500);
  radioerror:=1;
  connecting:=0;
  conradiostr:='';
  curentpage:='singleplayer';
  playnexttrack;
  LogAndExitPlayer('Ошибка в процедуре iradioplay',0,0);
 end;
end;

procedure RadioStreamDisconnected;
begin
  artist:=UTF8Decode(curentradio)+' ';
  title:=UTF8Decode(getfromlangpack('connecting'));
  iradioplay(lastradiourl);
end;

procedure connectradiop.Execute;
var
  Len:DWORD;
begin
 try
 BASS_ChannelStop(radiochannel);
 BASS_StreamFree(radiochannel);
 radiochannel:=BASS_StreamCreateURL(Pansichar(radiourlp),0,{BASS_STREAM_RESTRATE and }BASS_STREAM_STATUS,nil,nil);
   while (BASS_ErrorGetCode<>0) and (radioerror<1000) and (connecting<>0) do
  begin
    inc(radioerror);
    BASS_ChannelStop(radiochannel);
    BASS_StreamFree(radiochannel);
    radiochannel:=BASS_StreamCreateURL(Pansichar(radiourlp),0,{BASS_STREAM_RESTRATE and }BASS_STREAM_STATUS,nil,nil);
    application.ProcessMessages;
    SinglePlayerGUI.Repaint;
  end;

 if connecting=0 then
  begin
   BASS_ChannelStop(radiochannel);
   BASS_StreamFree(radiochannel);
   radioerror:=1;
   conradiostr:='';
   SinglePlayerGUI.Invalidate;
   connectradio.Free;
  end;
 if (radioerror>=1000) or (connecting=0) then
  begin
   BASS_ChannelStop(radiochannel);
   BASS_StreamFree(radiochannel);
   SinglePlayerGUI.repaint;
   sleep(500);
  end else
  begin
  repeat
   len := BASS_StreamGetFilePosition(radiochannel, BASS_FILEPOS_END);
   if (len = DW_Error) then break;
   progress := (BASS_StreamGetFilePosition(radiochannel, BASS_FILEPOS_DOWNLOAD) - BASS_StreamGetFilePosition(radiochannel, BASS_FILEPOS_CURRENT)) * 100 div len;
   application.ProcessMessages;
   SinglePlayerGUI.Invalidate;
  until progress > singleplayersettings.netprebuffer;
  progress:=0;
   BASS_ChannelStop(Channel);
   BASS_ChannelStop(radiochannel);
   BASS_ChannelPlay(radiochannel,true);
   mode:=radioplay;
   eqapply(radiochannel);
   curenttrack:=radiourlp;
   curentpage:='singleplayer';
   if SinglePlayerSettings.showcoverpl=1 then
    begin
      loadcaver:=loadcaverp.Create(true);
      loadcaver.freeonterminate := true;
      loadcaver.priority := tpnormal;
      loadcaver.Start;
    end;
  end;
 radioerror:=1;
 connecting:=0;
 conradiostr:='';
 SinglePlayerGUI.Invalidate;
 connectradio.Free;
 except
  radioerror:=1;
  connecting:=0;
  conradiostr:='';
  SinglePlayerGUI.Invalidate;
  LogAndExitPlayer('Ошибка в процедуре connectradiop',0,0);
  connectradio.Free;
 end;
end;

function getnettag:string;
var
  meta: PAnsiChar;
  p: Integer;
begin
result:='';
meta:=BASS_ChannelGetTags(radiochannel,BASS_TAG_META);
if (meta<>nil) then
begin
  p:=Pos('StreamTitle=',String(AnsiString(meta)));
  if (p=0) then Exit;
  p:=p+13;
  meta:=PAnsiChar(AnsiString(Copy(meta,p,Pos(';',String(meta))-p-1)));
  result:=UTF8Decode(meta);
end;
end;

function BASSGetBitRate(handle: Cardinal): DWORD;
var
  Lenght1, Lenght2, Lenght3: Integer;
begin
  Lenght1:=BASS_StreamGetFilePosition(handle,BASS_FILEPOS_END);
  Lenght2:=Round(BASS_ChannelBytes2Seconds(handle,Lenght1));
  Lenght3:=Round(BASS_StreamGetFilePosition(handle,BASS_FILEPOS_END)*8/Lenght2/10000);
  Result:=Lenght3;
end;

procedure getkollstr;
var
  i:integer;
  searchtrack: TSearchRec;
begin
 i:=0;
 getkollpagekey:=0;
 kollpage:=0;
 if FindFirst('\'+curentdir+'\*', faDirectory, searchtrack) = 0 then
    begin
     repeat
     if ((searchtrack.attr and faDirectory) = faDirectory) or
             (length(searchtrack.Name)-pos('.mp3',searchtrack.Name)=3) and (pos('.mp3',searchtrack.Name)<>0) or
             (length(searchtrack.Name)-pos('.wav',searchtrack.Name)=3) and (pos('.wav',searchtrack.Name)<>0) or
             (length(searchtrack.Name)-pos('.ogg',searchtrack.Name)=3) and (pos('.ogg',searchtrack.Name)<>0) or
             (length(searchtrack.Name)-pos('.flac',searchtrack.Name)=4) and (pos('.flac',searchtrack.Name)<>0) or
             (length(searchtrack.Name)-pos('.m4a',searchtrack.Name)=3) and (pos('.m4a',searchtrack.Name)<>0) or
             (length(searchtrack.Name)-pos('.mpc',searchtrack.Name)=3) and (pos('.mpc',searchtrack.Name)<>0) or
             (length(searchtrack.Name)-pos('.aiff',searchtrack.Name)=4) and (pos('.aiff',searchtrack.Name)<>0) or
             (length(searchtrack.Name)-pos('.MP3',searchtrack.Name)=3) and (pos('.MP3',searchtrack.Name)<>0) or
             (length(searchtrack.Name)-pos('.WAV',searchtrack.Name)=3) and (pos('.WAV',searchtrack.Name)<>0) or
             (length(searchtrack.Name)-pos('.OGG',searchtrack.Name)=3) and (pos('.OGG',searchtrack.Name)<>0) or
             (length(searchtrack.Name)-pos('.FLAC',searchtrack.Name)=4) and (pos('.FLAC',searchtrack.Name)<>0) or
             (length(searchtrack.Name)-pos('.M4A',searchtrack.Name)=3) and (pos('.M4A',searchtrack.Name)<>0) or
             (length(searchtrack.Name)-pos('.MPC',searchtrack.Name)=3) and (pos('.MPC',searchtrack.Name)<>0) or
             (length(searchtrack.Name)-pos('.m3u',searchtrack.Name)=3) and (pos('.m3u',searchtrack.Name)<>0) or
             (length(searchtrack.Name)-pos('.M3U',searchtrack.Name)=3) and (pos('.M3U',searchtrack.Name)<>0) or
             (length(searchtrack.Name)-pos('.pls',searchtrack.Name)=3) and (pos('.pls',searchtrack.Name)<>0) or
             (length(searchtrack.Name)-pos('.PLS',searchtrack.Name)=3) and (pos('.PLS',searchtrack.Name)<>0) or
             (length(searchtrack.Name)-pos('.cue',searchtrack.Name)=3) and (pos('.cue',searchtrack.Name)<>0) or
             (length(searchtrack.Name)-pos('.CUE',searchtrack.Name)=3) and (pos('.CUE',searchtrack.Name)<>0) or
             (length(searchtrack.Name)-pos('.AIFF',searchtrack.Name)=4) and (pos('.AIFF',searchtrack.Name)<>0) then
        begin
         inc(i);
        end;
    until FindNext(searchtrack) <> 0;
    SysUtils.FindClose(searchtrack);
    end;
if kolfilefolder<>0 then kollpage:=(i div kolfilefolder)+1 else kollpage:=1;
if (kollpage=2) and (i<=kolfilefolder) then dec(kollpage);
SinglePlayerGUI.Invalidate;
end;

procedure gettree(disk:string; nfindex:integer);
var
	searchtrack : TSearchRec;
	X1,Y1,X2,Y2,i,j,oneStringLen, bottomMargine, folderIconIndex, folderMarkedIconIndex, fileIconIndex, fileMarkedIconIndex : integer;
	indexmass,n,kolstrok,sm,marked,k,latinLen,compensationFlag,firstSymbol : integer;
	mass : array [1..10] of string;
	bufName : string;

    FileList : array of string;
  	DateList : array of TDateTime;
    tmp,tmp2 : String;
    TempDate: TDateTime;
    done: Boolean;
begin
	try
		kolfilefolder:=0;
		SinglePlayerGUI.Canvas.Font.Color:=plset.curentdircolor;
		SinglePlayerGUI.Canvas.Font.Size:=plset.curentdirsize;
		SinglePlayerGUI.canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.curentdirleft,ExtractFileName(curentdir),1),plset.curentdirtop,ExtractFileName(UTF8Encode(curentdir)));
		SinglePlayerGUI.Canvas.Font.Color:=plset.playlisttextncolor;
		SinglePlayerGUI.Canvas.Font.Size:=plset.playlisttextnsize;
		SinglePlayerGUI.canvas.TextRect(classes.Rect(0,0,800,480), myalign(plset.playlisttextnleft,getfromlangpack('page')+' '+inttostr(pageindex)+'/'+inttostr(kollpage),1),plset.playlisttextntop,getfromlangpack('page')+' '+inttostr(pageindex)+'/'+inttostr(kollpage));
		SinglePlayerGUI.Canvas.Font.Color:=plset.scanfolderstrtextcolor;
		SinglePlayerGUI.Canvas.Font.Size:=plset.scanfolderstrtextsize;
		SinglePlayerGUI.canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.scanfolderstrleft,scanningstr,1),plset.scanfolderstrtop,scanningstr);
		folders := nil;
		if playlistadd=0 then
        	SinglePlayerSettings.kolltrackbuf := 0
        else
        	SinglePlayerSettings.kolltrackbuf := SinglePlayerSettings.kolltrack;
		//i:=0;
		pospage[pageindex] := nfindex;
		nextpageindex := 0;
		if plset.treetype=0 then begin
			X1 := plset.treeleft;
			Y1 := plset.treetop;
		end else begin
			X1 := plset.treeleftsp;
			Y1 := plset.treetopsp;
		end;
		SinglePlayerGUI.Canvas.Font.Color := plset.explorertextfolder;
		if plset.treetype=0 then
        	SinglePlayerGUI.Canvas.Font.Size := plset.treetextsize
		else
        	SinglePlayerGUI.Canvas.Font.Size := plset.treetextsizetree;

        // считываем все папки из директории
		if FindFirst('\'+disk+'\*', faDirectory, searchtrack) = 0 then begin repeat // поиск по папкам
			if ((searchtrack.attr and faDirectory)=faDirectory){$IFNDEF WInCE} and (searchtrack.Name<>'.') and (searchtrack.Name<>'..'){$ENDIF} then begin
                Setlength(FileList, Length(FileList) + 1);
    			Setlength(DateList, Length(DateList) + 1);
    			FileList[High(FileList)]:= searchtrack.Name;
                DateList[High(DateList)]:= FileDateToDateTime(searchtrack.Time);
			end;
			until FindNext(searchtrack) <> 0;
			SysUtils.FindClose(searchtrack);
		end;

        // делаем сортировку по названиям
        j:=0;
        //plset.sortmode:=0;
        if (High(FileList)>0) then begin
         	if (plset.sortmode=0) then begin repeat // по названию
				tmp:=UpperCase(FileList[j]);
				tmp2:=UpperCase(FileList[j+1]);
				if tmp[1]>tmp2[1] then begin
				    tmp:=FileList[j];
				    FileList[j]:=FileList[j+1];
				    FileList[j+1]:=tmp;
				    j:=-1;
				end;
				Inc(j);
				until j=High(FileList) -1;
	        end	else begin repeat // по дате
               	done:= True;
		    	for j:= 0 to High(FileList) - 1 do begin
                    if (plset.sortMode=1) then begin // если начала старые
				      	if (DateList[j] > DateList[j + 1]) then begin
					        done:= False;
					        tmp:= FileList[j];
					        FileList[j]:= FileList[j + 1];
					        FileList[j + 1]:= tmp;

					        TempDate:= DateList[j];
					        DateList[j]:= DateList[j + 1];
					        DateList[j + 1]:= TempDate;
				      	end;
                    end else begin // если начала новые
                        if (DateList[j] < DateList[j + 1]) then begin
					        done:= False;
					        tmp:= FileList[j];
					        FileList[j]:= FileList[j + 1];
					        FileList[j + 1]:= tmp;

					        TempDate:= DateList[j];
					        DateList[j]:= DateList[j + 1];
					        DateList[j + 1]:= TempDate;
				      	end;
					end;
				end;
		  		until done;
        	end;
		end;


        // выводим папки на экран
        for i:= 1 to High(FileList)+1 do begin
            marked:=0;
			//inc(i);
			if (i>nfindex) then begin
				SetLength(folders,i+1,7);
				X2 := SinglePlayerGUI.Canvas.TextWidth(FileList[i-1]);
				Y2 := SinglePlayerGUI.Canvas.TextHeight(FileList[i-1]);

				if singleplayersettings.manyadd=1 then
                	for k:=1 to tempallkolltrack do
                    	if pos(disk+'\'+FileList[i-1],temptrackmas[k])<>0 then begin
                         	marked := 1;
                            break;
                        end;

				if plset.treetype=0 then begin
                	folderIconIndex := getindexicon('folder.bmp');
                    folderMarkedIconIndex := getindexicon('foldermarked.bmp');
                    bottomMargine := plset.bottomsetka;

					if X1+seticons[folderIconIndex].width>plset.maxrightsetka then begin
                     	Y1 += Y2 + seticons[folderIconIndex].height + plset.treeintervalvert;
                     	X1 := plset.treeleft;
                    end;
				end else begin
                	folderIconIndex := getindexicon('foldertree.bmp');
                    folderMarkedIconIndex := getindexicon('foldertreemarked.bmp');
                    bottomMargine := plset.bottomtree;

					if X1+seticons[folderIconIndex].width>plset.maxrighttree then begin
                    	Y1 += seticons[folderIconIndex].height + plset.treeintervalverttree;
                        X1 := plset.treeleftsp;
                    end;
				end;

                if Y1+Y2+seticons[folderIconIndex].height<bottomMargine then begin
					inc(kolfilefolder);
                    bufName := UTF8Encode(FileList[i-1]); // конвертируем строку

					if marked=0 then // выбираем иконку по маркировке и рисуем ее
                    	SinglePlayerGUI.Canvas.Draw(X1, Y1, playericon[folderIconIndex])
                    else
                    	SinglePlayerGUI.Canvas.Draw(X1, Y1, playericon[folderMarkedIconIndex]);

                    if plset.treetype=0 then begin // если файлы сеткой
						indexmass := 1;
						kolstrok := 1;


						for n:=1 to 10 do // обнуляем массив
                        	mass[n] := '';

						if SinglePlayerGUI.Canvas.TextWidth(bufName)>seticons[folderIconIndex].width then begin // если название папки больше ширины папки
							kolstrok := (SinglePlayerGUI.Canvas.TextWidth(bufName) div seticons[folderIconIndex].width)+1; // то считаем количество строк
							oneStringLen := length(bufName) div kolstrok; // определяем длину строки

							latinLen := 0;
                            compensationFlag := 0;
                            firstSymbol := 1;
							for n:=1 to length(bufName) do begin // для каждого символа строки
								if (length(mass[indexmass])>=(oneStringLen+plset.playlisttextr)) then begin// если вышли за строку
                                	if strInArray(bufName[n]) then // считаем количество латиницы, цифр и знаков препинания
                                    	inc(latinLen);
                                    if latinLen<(oneStringLen+plset.playlisttextr+1) then begin
                                    	compensationFlag := oneStringLen+plset.playlisttextr+1 - latinLen;
                                        if (compensationFlag mod 2 <> 0) then
                                        	compensationFlag := 1
                                        else
                                        	compensationFlag := 0;
									end;
                                    mass[indexmass] += bufName[n]; //заполняем массив
                                    if compensationFlag=1 then
										mass[indexmass] += bufName[n+1]; //заполняем массив
                                	inc(indexmass); // то делаем инкремент
                                    latinLen := 0;
                                    firstSymbol :=1;
								end else begin
                                	if compensationFlag=0 then begin
                                        if strInArray(bufName[n]) then inc(latinLen);
                                        if (firstSymbol=1) then begin
                                        	if ((bufName[n]<>' ')) then
                                        		mass[indexmass] += bufName[n]; //заполняем массив
                                        firstSymbol := 0;
										end else
                                            mass[indexmass] += bufName[n]; //заполняем массив
									end else
                                    	compensationFlag := 0;
								end;
							end;
						end else // если нет
							mass[1] := bufName; // то просто перезаписываем название

						if mass[1]<>'' then
                        	X2 := SinglePlayerGUI.Canvas.TextWidth(mass[1]);

						if (plset.playlisttextstr<>'max') and (strtointdef(plset.playlisttextstr,0)<>0) and (indexmass>strtointdef(plset.playlisttextstr,0)) then
                        	indexmass := strtointdef(plset.playlisttextstr,1);

						if indexmass>0 then for n:=1 to indexmass do begin
							if n=1 then
                            	sm := 0
                            else
                            	sm := SinglePlayerGUI.Canvas.TextHeight(bufName);

							SinglePlayerGUI.canvas.TextRect(classes.Rect(0,0,800,480), X1+(((X2 div 2)-(seticons[folderIconIndex].width div 2))*-1),Y1+plset.textinterval+sm*(n-1), mass[n]);
						end;
                    end else begin
                        SinglePlayerGUI.canvas.TextRect(classes.Rect(0,0,800,480), X1+seticons[folderIconIndex].width+plset.treetextX ,Y1+plset.treetextY,bufName,textstyle);
                    end;

                    folders[i,1] := disk + '\' + FileList[i-1];
					folders[i,2] := 'folder';
					folders[i,3] := inttostr(X1);
					folders[i,4] := inttostr(Y1);
                    folders[i,6] := inttostr(Y1+seticons[folderIconIndex].height);

                    if plset.treetype=0 then begin
						folders[i,5] := inttostr(X1+seticons[folderIconIndex].width);
						X1 += seticons[folderIconIndex].width + plset.treeintervalhorz;
                    end else begin
						folders[i,5] := inttostr(X1+seticons[folderIconIndex].width+SinglePlayerGUI.Canvas.TextWidth(bufName)+plset.treetextX);
						X1 += seticons[folderIconIndex].width + plset.maxrighttree;
                    end;
				end else begin
                    if nextpageindex=0 then
                    	nextpageindex := i - 1;
                    break;
                end;
			end;
		end;

        if FindFirst('\'+disk+'\*', faDirectory, searchtrack) = 0 then begin repeat
            marked:=0;
            if (length(searchtrack.Name)-pos('.mp3',searchtrack.Name)=3) and (pos('.mp3',searchtrack.Name)<>0) or
				(length(searchtrack.Name)-pos('.wav',searchtrack.Name)=3) and (pos('.wav',searchtrack.Name)<>0) or
				(length(searchtrack.Name)-pos('.ogg',searchtrack.Name)=3) and (pos('.ogg',searchtrack.Name)<>0) or
				(length(searchtrack.Name)-pos('.flac',searchtrack.Name)=4) and (pos('.flac',searchtrack.Name)<>0) or
				(length(searchtrack.Name)-pos('.m4a',searchtrack.Name)=3) and (pos('.m4a',searchtrack.Name)<>0) or
                (length(searchtrack.Name)-pos('.mpc',searchtrack.Name)=3) and (pos('.mpc',searchtrack.Name)<>0) or
				(length(searchtrack.Name)-pos('.aiff',searchtrack.Name)=4) and (pos('.aiff',searchtrack.Name)<>0) or
				(length(searchtrack.Name)-pos('.MP3',searchtrack.Name)=3) and (pos('.MP3',searchtrack.Name)<>0) or
				(length(searchtrack.Name)-pos('.WAV',searchtrack.Name)=3) and (pos('.WAV',searchtrack.Name)<>0) or
				(length(searchtrack.Name)-pos('.OGG',searchtrack.Name)=3) and (pos('.OGG',searchtrack.Name)<>0) or
				(length(searchtrack.Name)-pos('.FLAC',searchtrack.Name)=4) and (pos('.FLAC',searchtrack.Name)<>0) or
				(length(searchtrack.Name)-pos('.M4A',searchtrack.Name)=3) and (pos('.M4A',searchtrack.Name)<>0) or
                (length(searchtrack.Name)-pos('.MPC',searchtrack.Name)=3) and (pos('.MPC',searchtrack.Name)<>0) or
				(length(searchtrack.Name)-pos('.m3u',searchtrack.Name)=3) and (pos('.m3u',searchtrack.Name)<>0) or
				(length(searchtrack.Name)-pos('.M3U',searchtrack.Name)=3) and (pos('.M3U',searchtrack.Name)<>0) or
				(length(searchtrack.Name)-pos('.pls',searchtrack.Name)=3) and (pos('.pls',searchtrack.Name)<>0) or
				(length(searchtrack.Name)-pos('.PLS',searchtrack.Name)=3) and (pos('.PLS',searchtrack.Name)<>0) or
				(length(searchtrack.Name)-pos('.cue',searchtrack.Name)=3) and (pos('.cue',searchtrack.Name)<>0) or
				(length(searchtrack.Name)-pos('.CUE',searchtrack.Name)=3) and (pos('.CUE',searchtrack.Name)<>0) or
				(length(searchtrack.Name)-pos('.AIFF',searchtrack.Name)=4) and (pos('.AIFF',searchtrack.Name)<>0) then begin
					inc(SinglePlayerSettings.kolltrackbuf);
					trackbuf[SinglePlayerSettings.kolltrackbuf]:=disk+'\'+searchtrack.Name;
					inc(i);

					if (i>nfindex) then  begin
						SetLength(folders,i+1,7);
						X2:=SinglePlayerGUI.Canvas.TextWidth(searchtrack.Name);
						Y2:=SinglePlayerGUI.Canvas.TextHeight(searchtrack.Name);

						if singleplayersettings.manyadd=1 then
                        	for k:=1 to tempallkolltrack do
                                if pos(disk+'\'+searchtrack.name,temptrackmas[k])<>0 then begin
                                	marked:=1;
                                 	break;
                                end;

                        if plset.treetype=0 then begin
                        	fileIconIndex := getindexicon('musicfile.bmp');
                        	fileMarkedIconIndex := getindexicon('musicfilemarked.bmp');
                            bottomMargine := plset.bottomsetka;

							if X1+seticons[fileIconIndex].width>plset.maxrightsetka then begin
                            	Y1:=Y1+Y2+seticons[fileIconIndex].height+plset.treeintervalvert;
                                X1:=plset.treeleft;
                            end;
						end else begin
                        	fileIconIndex := getindexicon('musicfiletree.bmp');
                        	fileMarkedIconIndex := getindexicon('musicfiletreemarked.bmp');
                            bottomMargine := plset.bottomtree;

							if X1+seticons[fileIconIndex].width>plset.maxrighttree then begin
                            	Y1:=Y1+seticons[fileIconIndex].height+plset.treeintervalverttree;
                                X1:=plset.treeleftsp;
                            end;
						end;

                        if Y1+Y2+seticons[fileIconIndex].height<bottomMargine then begin
							inc(kolfilefolder);
                            bufName := UTF8Encode(searchtrack.Name); // конвертируем строку

							if marked=0 then
                            	SinglePlayerGUI.Canvas.Draw(X1, Y1, playericon[fileIconIndex])
                            else
                            	SinglePlayerGUI.Canvas.Draw(X1, Y1, playericon[fileMarkedIconIndex]);

                            if plset.treetype=0 then begin
								indexmass:=1;
								kolstrok:=1;
								for n:=1 to 10 do
                                	mass[n]:='';

                                if SinglePlayerGUI.Canvas.TextWidth(bufName)>seticons[fileIconIndex].width then begin // если название папки больше ширины папки
									kolstrok := (SinglePlayerGUI.Canvas.TextWidth(bufName) div seticons[fileIconIndex].width)+1; // то считаем количество строк
									oneStringLen := length(bufName) div kolstrok; // определяем длину строки

                                    latinLen := 0;
                                    compensationFlag := 0;
                                    firstSymbol := 1;
									for n:=1 to length(bufName) do begin // для каждого символа строки
										if (length(mass[indexmass])>=(oneStringLen+plset.playlisttextr)) then begin// если вышли за строку
                                        	if strInArray(bufName[n]) then // считаем количество латиницы, цифр и знаков препинания
                                            	inc(latinLen);
                                            if latinLen<(oneStringLen+plset.playlisttextr) then begin // сравниваем с общей длительностью
                                            	compensationFlag := oneStringLen+plset.playlisttextr+1 - latinLen; // и подсчитываем количество символов под кириллицу
                                                if (compensationFlag mod 2 <> 0) then // если нечетное число
                                                	compensationFlag := 1 // то надо сделать компенсацию, т.к. для кириллицы надо 2 байта
                                                else
                                                	compensationFlag := 0;
											end;
                                            mass[indexmass] += bufName[n]; //заполняем массив
                                            if compensationFlag=1 then // если нужна компенсация
												mass[indexmass] += bufName[n+1]; //то заполняем массив еще раз  + IntToStr(compensationFlag)
		                                	inc(indexmass); // то делаем инкремент
                                            latinLen := 0;
                                            firstSymbol :=1;
										end else begin
                                        	if compensationFlag=0 then begin // если компенсация не проводилась
	                                            if strInArray(bufName[n]) then inc(latinLen); // то работаем штатно
                                                if (firstSymbol=1) then begin
		                                        	if ((bufName[n]<>' ')) then
                                                		mass[indexmass] += bufName[n]; //заполняем массив
                                                firstSymbol := 0;
												end else
                                                    mass[indexmass] += bufName[n]; //заполняем массив
											end else // если проводилась
                                            	compensationFlag := 0; // то пропускаем итерацию и обнуляем компенсацию
										end;
									end;
								end else // если нет
									mass[1] := bufName; // то просто перезаписываем название

								if mass[1]<>'' then
                                	X2:=SinglePlayerGUI.Canvas.TextWidth(mass[1]);
								if (plset.playlisttextstr<>'max') and (strtointdef(plset.playlisttextstr,0)<>0) and (indexmass>strtointdef(plset.playlisttextstr,0)) then
                                	indexmass:=strtointdef(plset.playlisttextstr,1);
								if indexmass>0 then for n:=1 to indexmass do begin
									if n=1 then
                                    	sm:=0
                                    else
                                    	sm:=SinglePlayerGUI.Canvas.TextHeight(bufName);
									SinglePlayerGUI.canvas.TextRect(classes.Rect(0,0,800,480), X1+(((X2 div 2)-(seticons[fileIconIndex].width div 2))*-1),Y1+plset.textinterval+sm*(n-1), mass[n]);
								end;
                            end else begin
                                SinglePlayerGUI.canvas.TextRect(classes.Rect(0,0,800,480), X1+seticons[fileIconIndex].width+plset.treetextX ,Y1+plset.treetextY,bufName,textstyle);
                            end;

							folders[i,1]:=disk+'\'+searchtrack.Name;
							folders[i,2]:='files';
							folders[i,3]:=inttostr(X1);
							folders[i,4]:=inttostr(Y1);
                            folders[i,6]:=inttostr(Y1+seticons[fileIconIndex].height);

                            if plset.treetype=0 then begin
								folders[i,5]:=inttostr(X1+seticons[fileIconIndex].width);

								X1:=X1+seticons[fileIconIndex].width+plset.treeintervalhorz;
                            end else begin
								folders[i,5]:=inttostr(X1+seticons[fileIconIndex].width+SinglePlayerGUI.Canvas.TextWidth(searchtrack.Name)+plset.treetextX);
								X1:=X1+seticons[fileIconIndex].width+plset.maxrighttree;
                            end;
						end else begin
	                        	if nextpageindex=0 then
	                            nextpageindex:=i-1;
	                            break;
	                        end;
						end;
					end;
			until FindNext(searchtrack) <> 0;
			SysUtils.FindClose(searchtrack);
		end;

		if getkollpagekey=1 then
        	getkollstr;
		for i:=Singleplayersettings.kolltrackbuf+1 to singleplayersettings.kolltrack do
            if trackbuf[i]<>'' then
            	trackbuf[i]:='';
	except
  		LogAndExitPlayer('Ошибка в процедуре gettree',0,0);
	end;
end;

function strInArray(value : string) : Boolean;
var
	loop : String;
	arrayOfDigits : array [1..17] of string = (' ', '.', ',', '-', '_', ':', ';', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9');
	arrayOfLatters : array [1..26] of string = ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z');
begin
	for loop in arrayOfDigits do begin
		if value = loop then
			Exit(true);
	end;
    for loop in arrayOfLatters do begin
		if value = loop then
			Exit(true);
	end;
	result := false;
end;

procedure createTreeObjects(disk:string; bufName:string; index:integer; marked:integer);
var
    X1,Y1,X2,Y2,oneStringLen, bottomMargine, folderIconIndex, folderMarkedIconIndex : integer;
	indexmass,n,kolstrok,sm : integer;
	mass: array [1..10] of string;
begin
	try
    	if plset.treetype=0 then begin
			X1 := plset.treeleft;
			Y1 := plset.treetop;
		end else begin
			X1 := plset.treeleftsp;
			Y1 := plset.treetopsp;
		end;

        X2 := SinglePlayerGUI.Canvas.TextWidth(bufName);
		Y2 := SinglePlayerGUI.Canvas.TextHeight(bufName);

        if plset.treetype=0 then begin
        	folderIconIndex := getindexicon('folder.bmp');
            folderMarkedIconIndex := getindexicon('foldermarked.bmp');
            bottomMargine := plset.bottomsetka;

			{if X1+seticons[folderIconIndex].width>plset.maxrightsetka then begin
             	Y1 += Y2 + seticons[folderIconIndex].height + plset.treeintervalvert;
             	X1 := plset.treeleft;
            end;}
		end else begin
        	folderIconIndex := getindexicon('foldertree.bmp');
            folderMarkedIconIndex := getindexicon('foldertreemarked.bmp');
            bottomMargine := plset.bottomtree;

			{if X1+seticons[folderIconIndex].width>plset.maxrighttree then begin
            	Y1 += seticons[folderIconIndex].height + plset.treeintervalverttree;
                X1 := plset.treeleftsp;
            end; }
		end;

		inc(kolfilefolder);
        //bufName := UTF8Encode(searchtrack.Name); // конвертируем строку

		if marked=0 then // выбираем иконку по маркировке и рисуем ее
        	SinglePlayerGUI.Canvas.Draw(X1, Y1, playericon[folderIconIndex])
        else
        	SinglePlayerGUI.Canvas.Draw(X1, Y1, playericon[folderMarkedIconIndex]);

        if plset.treetype=0 then begin // если файлы сеткой
			indexmass := 1;
			kolstrok := 1;


			for n:=1 to 10 do // обнуляем массив
            	mass[n] := '';

			if SinglePlayerGUI.Canvas.TextWidth(bufName)>seticons[folderIconIndex].width then begin // если название папки больше ширины папки
				kolstrok := (SinglePlayerGUI.Canvas.TextWidth(bufName) div seticons[folderIconIndex].width)+1; // то считаем количество строк
				oneStringLen := length(bufName) div kolstrok; // определяем длину строки

				if (oneStringLen mod 2 <> 0) then // и делаем компенсацию в случае четности, т.к. русские буквы задаются двумя символами
                	inc(oneStringLen);

				for n:=1 to length(bufName) do begin // для каждого символа строки
					if (length(mass[indexmass])>=(oneStringLen+plset.playlisttextr)) then begin// если вышли за строку
                    	if (bufName[n]<>' ') then mass[indexmass] += bufName[n]; //заполняем массив
                    	inc(indexmass); // то делаем инкремент
					end else
                        mass[indexmass] += bufName[n]; //заполняем массив
				end;
			end else // если нет
				mass[1] := bufName; // то просто перезаписываем название

			if mass[1]<>'' then
            	X2 := SinglePlayerGUI.Canvas.TextWidth(mass[1]);

			if (plset.playlisttextstr<>'max') and (strtointdef(plset.playlisttextstr,0)<>0) and (indexmass>strtointdef(plset.playlisttextstr,0)) then
            	indexmass := strtointdef(plset.playlisttextstr,1);

			if indexmass>0 then for n:=1 to indexmass do begin
				if n=1 then
                	sm := 0
                else
                	sm := SinglePlayerGUI.Canvas.TextHeight(bufName);

				SinglePlayerGUI.canvas.TextRect(classes.Rect(0,0,800,480), X1+(((X2 div 2)-(seticons[folderIconIndex].width div 2))*-1),Y1+plset.textinterval+sm*(n-1), mass[n]);
			end;
        end else begin
            SinglePlayerGUI.canvas.TextRect(classes.Rect(0,0,800,480), X1+seticons[folderIconIndex].width+plset.treetextX ,Y1+plset.treetextY,bufName,textstyle);
        end;

        folders[index,1] := disk + '\' + UTF8Decode(bufName);
		folders[index,2] := 'folder';
		folders[index,3] := inttostr(X1);
		folders[index,4] := inttostr(Y1);
        folders[index,6] := inttostr(Y1+seticons[folderIconIndex].height);

        if plset.treetype=0 then begin
			folders[index,5] := inttostr(X1+seticons[folderIconIndex].width);
			X1 += seticons[folderIconIndex].width + plset.treeintervalhorz;
        end else begin
			folders[index,5] := inttostr(X1+seticons[folderIconIndex].width+SinglePlayerGUI.Canvas.TextWidth(bufName)+plset.treetextX);
			X1 += seticons[folderIconIndex].width + plset.maxrighttree;
        end;
	except
        LogAndExitPlayer('Ошибка в процедуре createTreeObjects',0,0);
	end;
end;


procedure saveeq;
var
i,j,k:integer;
eqstr:string;
eqfile:textfile;
begin
 try
 if saveeqkl=0 then
  begin
  saveeqkl:=1;
  assignfile(eqfile,SinglePlayerDir+'eq.conf');

    eqstr:=copy(genremass[curentgenre,1],1,pos(';',genremass[curentgenre,1]));
     for k:=1 to kolleff do
      begin
       for j:=1 to 20 do
        begin
         if SinglePlayerSettings.ezf[k,j]='' then begin eqstr:=eqstr+';'; break; end else if j<>1 then eqstr:=eqstr+'/';
         eqstr:=eqstr+SinglePlayerSettings.ezf[k,j];
        end;
      end;
    genremass[curentgenre,1]:=eqstr;

  rewrite(eqfile);
   for i:=1 to kollgenre do writeln(eqfile,'eqgenre_'+inttostr(i)+':'+genremass[i,1]);
  closefile(eqfile);
  saveeqkl:=0;
  SinglePlayerSettings.curentgenre:=curentgenre;
  end;

 except
   saveeqkl:=0;
   LogAndExitPlayer('Ошибка в процедуре saveeq',0,0);
 end;
end;

procedure exptree;
begin
 plset.treetype:=0;
 plsettingsznach[2,1]:=inttostr(plset.treetype);
end;

procedure expsetka;
begin
 plset.treetype:=1;
 plsettingsznach[2,1]:=inttostr(plset.treetype);
end;


procedure sortabc;   //!!!
begin
 plset.sortmode:=1;
 plsettingsznach[2,11]:=inttostr(plset.sortmode);
end;

procedure sortdate;
begin
 plset.sortmode:=2;
 plsettingsznach[2,11]:=inttostr(plset.sortmode);
end;

procedure sortdateinv;
begin
 plset.sortmode:=0;
 plsettingsznach[2,11]:=inttostr(plset.sortmode);
end;

function findpls(nach:integer; nap:byte):integer;
var
 i:integer;
begin
result:=nach;
 if nap=0 then
  begin
   for i:=nach+1 to kollpls do if fileexists(SinglePlayerDir+'playlist_'+inttostr(i)+'.pls') then begin result:=i; exit; end;
   if i=kollpls then result:=nach;
  end else
  begin
   for i:=nach-1 downto 1 do if fileexists(SinglePlayerDir+'playlist_'+inttostr(i)+'.pls') then begin result:=i; exit; end;
  end;
end;

procedure nextpls;
begin
 try
 if statusplaylist=0 then
  begin

   if fileexists(SinglePlayerDir+'playlist_'+inttostr(SinglePlayerSettings.curentplaylist)+'.pls')=false then
    begin
     plscurtrackpos[SinglePlayerSettings.curentplaylist,1]:=gettrackindex(curenttrack);
     if curentpage<>'playlist' then SinglePlayerSettings.curentplaylist:=findpls(SinglePlayerSettings.curentplaylist,0) else inc(SinglePlayerSettings.curentplaylist);
     if SinglePlayerSettings.curentplaylist>kollpls then SinglePlayerSettings.curentplaylist:=1;
     playlistread(SinglePlayerSettings.curentplaylist);
     if plscurtrackpos[SinglePlayerSettings.curentplaylist,1]<>0 then SinglePlayerSettings.playedtrack:=plscurtrackpos[SinglePlayerSettings.curentplaylist,1] else SinglePlayerSettings.playedtrack:=1;
     curenttrack:=track[SinglePlayerSettings.playedtrack];
     if lastpls<>SinglePlayerSettings.curentplaylist then
      begin
       if plscurtrackpos[SinglePlayerSettings.curentplaylist,2]>0 then SinglePlayerSettings.curpos:=plscurtrackpos[SinglePlayerSettings.curentplaylist,2] else SinglePlayerSettings.curpos:=-1;
       if SinglePlayerSettings.playaftchangepls=0 then SinglePlayerSettings.playedtrack:=gettrackindex(curenttrack) else if fileexists(SinglePlayerDir+'playlist_'+inttostr(SinglePlayerSettings.curentplaylist)+'.pls') then itelmaplay(curenttrack);
      end;
     playlistferstopen:=1;
     exit;
    end;


  if singleplayersettings.savepos=1 then SinglePlayerSettings.curpos:=bass_ChannelGetPosition(channel,0) else SinglePlayerSettings.curpos:=-1;
   plscurtrackpos[SinglePlayerSettings.curentplaylist,1]:=gettrackindex(curenttrack);
   plscurtrackpos[SinglePlayerSettings.curentplaylist,2]:=SinglePlayerSettings.curpos;
   lastpls:=SinglePlayerSettings.curentplaylist;
   if curentpage<>'playlist' then SinglePlayerSettings.curentplaylist:=findpls(SinglePlayerSettings.curentplaylist,0) else inc(SinglePlayerSettings.curentplaylist);
   if SinglePlayerSettings.curentplaylist>kollpls then SinglePlayerSettings.curentplaylist:=1;
   playlistread(SinglePlayerSettings.curentplaylist);
   if singleplayersettings.savepos=1 then
    begin
     if plscurtrackpos[SinglePlayerSettings.curentplaylist,1]<>0 then SinglePlayerSettings.playedtrack:=plscurtrackpos[SinglePlayerSettings.curentplaylist,1] else SinglePlayerSettings.playedtrack:=1;
     if plscurtrackpos[SinglePlayerSettings.curentplaylist,2]>0 then SinglePlayerSettings.curpos:=plscurtrackpos[SinglePlayerSettings.curentplaylist,2] else SinglePlayerSettings.curpos:=-1;
    end;
   curenttrack:=track[SinglePlayerSettings.playedtrack];
   if SinglePlayerSettings.playaftchangepls=0 then SinglePlayerSettings.playedtrack:=gettrackindex(curenttrack) else if fileexists(SinglePlayerDir+'playlist_'+inttostr(SinglePlayerSettings.curentplaylist)+'.pls') then itelmaplay(curenttrack);
   playlistferstopen:=1;
  end;
 except
  LogAndExitPlayer('Ошибка в процедуре nextpls',0,0);
 end;
end;

procedure prevpls;
begin
 try
 if statusplaylist=0 then
  begin
   if fileexists(SinglePlayerDir+'playlist_'+inttostr(SinglePlayerSettings.curentplaylist)+'.pls')=false then
    begin
     plscurtrackpos[SinglePlayerSettings.curentplaylist,1]:=gettrackindex(curenttrack);
     if curentpage<>'playlist' then SinglePlayerSettings.curentplaylist:=findpls(SinglePlayerSettings.curentplaylist,1) else dec(SinglePlayerSettings.curentplaylist);
     if SinglePlayerSettings.curentplaylist<1 then SinglePlayerSettings.curentplaylist:=kollpls;
     playlistread(SinglePlayerSettings.curentplaylist);
     if plscurtrackpos[SinglePlayerSettings.curentplaylist,1]<>0 then SinglePlayerSettings.playedtrack:=plscurtrackpos[SinglePlayerSettings.curentplaylist,1] else SinglePlayerSettings.playedtrack:=1;
     curenttrack:=track[SinglePlayerSettings.playedtrack];
     if lastpls<>SinglePlayerSettings.curentplaylist then
      begin
       if plscurtrackpos[SinglePlayerSettings.curentplaylist,2]>0 then SinglePlayerSettings.curpos:=plscurtrackpos[SinglePlayerSettings.curentplaylist,2] else SinglePlayerSettings.curpos:=-1;
       if SinglePlayerSettings.playaftchangepls=0 then SinglePlayerSettings.playedtrack:=gettrackindex(curenttrack) else if fileexists(SinglePlayerDir+'playlist_'+inttostr(SinglePlayerSettings.curentplaylist)+'.pls') then itelmaplay(curenttrack);
      end;
     playlistferstopen:=1;
     exit;
    end;
   if singleplayersettings.savepos=1 then SinglePlayerSettings.curpos:=bass_ChannelGetPosition(channel,0) else SinglePlayerSettings.curpos:=-1;
   plscurtrackpos[SinglePlayerSettings.curentplaylist,1]:=gettrackindex(curenttrack);
   plscurtrackpos[SinglePlayerSettings.curentplaylist,2]:=SinglePlayerSettings.curpos;
   lastpls:=SinglePlayerSettings.curentplaylist;
   if curentpage<>'playlist' then SinglePlayerSettings.curentplaylist:=findpls(SinglePlayerSettings.curentplaylist,1) else dec(SinglePlayerSettings.curentplaylist);
   if SinglePlayerSettings.curentplaylist<1 then SinglePlayerSettings.curentplaylist:=kollpls;
   playlistread(SinglePlayerSettings.curentplaylist);
   if singleplayersettings.savepos=1 then
    begin
     if plscurtrackpos[SinglePlayerSettings.curentplaylist,1]<>0 then SinglePlayerSettings.playedtrack:=plscurtrackpos[SinglePlayerSettings.curentplaylist,1] else SinglePlayerSettings.playedtrack:=1;
     if plscurtrackpos[SinglePlayerSettings.curentplaylist,2]>0 then SinglePlayerSettings.curpos:=plscurtrackpos[SinglePlayerSettings.curentplaylist,2] else SinglePlayerSettings.curpos:=-1;
    end;
   curenttrack:=track[SinglePlayerSettings.playedtrack];
   if SinglePlayerSettings.playaftchangepls=0 then SinglePlayerSettings.playedtrack:=gettrackindex(curenttrack) else if fileexists(SinglePlayerDir+'playlist_'+inttostr(SinglePlayerSettings.curentplaylist)+'.pls') then itelmaplay(curenttrack);
   playlistferstopen:=1;
  end;
 except
  LogAndExitPlayer('Ошибка в процедуре prevpls',0,0);
 end;
end;

procedure timetracknap;
begin
 try
 if SinglePlayerSettings.timerrevkey=1 then SinglePlayerSettings.timerrevkey:=0 else SinglePlayerSettings.timerrevkey:=1;
 playertimercode;
 SinglePlayerGUI.Invalidate;
 except
   LogAndExitPlayer('Ошибка в процедуре timetracknap',0,0);
 end;
end;

procedure volup;
begin
 try
 if SinglePlayerSettings.mute=0 then
  begin
 if SinglePlayerSettings.curentvol<10 then SinglePlayerSettings.curentvol:=SinglePlayerSettings.curentvol+1 else SinglePlayerSettings.curentvol:=10;
 BASS_ChannelSetAttribute(channel,BASS_ATTRIB_VOL,SinglePlayerSettings.curentvol/10);
 playertimercode;
 SinglePlayerGUI.Invalidate;
  end;
 except
   LogAndExitPlayer('Ошибка в процедуре volup',0,0);
 end;
end;

procedure voldown;
begin
 try
 if SinglePlayerSettings.mute=0 then
  begin
 if SinglePlayerSettings.curentvol>0 then SinglePlayerSettings.curentvol:=SinglePlayerSettings.curentvol-1 else SinglePlayerSettings.curentvol:=0;
 BASS_ChannelSetAttribute(channel,BASS_ATTRIB_VOL,SinglePlayerSettings.curentvol/10);
 playertimercode;
 SinglePlayerGUI.Invalidate;
  end;
 except
   LogAndExitPlayer('Ошибка в процедуре voldown',0,0);
 end;
end;

procedure sysvolup;
begin
 try
  if singleplayersettings.sysvolchange=1 then
   begin
    if singleplayersettings.curentsysvol<=90 then inc(singleplayersettings.curentsysvol,10);
    setsystvol(singleplayersettings.curentsysvol);
    SinglePlayerGUI.Invalidate;
   end;
 except
   LogAndExitPlayer('Ошибка в процедуре sysvolup',0,0);
 end;
end;

procedure sysvoldown;
begin
 try
  if singleplayersettings.sysvolchange=1 then
   begin
    if singleplayersettings.curentsysvol>=10 then dec(singleplayersettings.curentsysvol,10);
    setsystvol(singleplayersettings.curentsysvol);
    SinglePlayerGUI.Invalidate;
   end;
 except
   LogAndExitPlayer('Ошибка в процедуре sysvoldown',0,0);
 end;
end;

procedure setsystvol(sysvol:word);
begin
  try
   sysvol:=sysvol*655;
   waveOutSetVolume(0,(sysvol shl 16)+sysvol);
  except
   LogAndExitPlayer('Ошибка в процедуре setsystvol',0,0);
 end;
end;

procedure cicleplson;
begin
    plsettingsznach[2,4]:='1';
    SinglePlayerSettings.ciclepls:=1;
    SinglePlayerGUI.Invalidate;
end;

procedure cicleplsoff;
begin
    plsettingsznach[2,4]:='0';
    SinglePlayerSettings.ciclepls:=0;
    SinglePlayerGUI.Invalidate;
end;

procedure folderaddon;
begin
    SinglePlayerSettings.folderadd:=1;
    SinglePlayerGUI.Invalidate;
end;
procedure folderaddoff;
begin
    SinglePlayerSettings.folderadd:=0;
    SinglePlayerGUI.Invalidate;
end;

procedure wheeloneon;
begin
    SinglePlayerSettings.wheelone:=1;
    SinglePlayerGUI.Invalidate;
end;

procedure wheeloneoff;
begin
    SinglePlayerSettings.wheelone:=0;
    SinglePlayerGUI.Invalidate;
end;

procedure muteoff;
begin
 try
  if tempvol<>0 then SinglePlayerSettings.curentvol:=tempvol else SinglePlayerSettings.curentvol:=tempmutevol;
  BASS_ChannelSetAttribute(channel,BASS_ATTRIB_VOL,SinglePlayerSettings.curentvol / 10);
  SinglePlayerSettings.mute:=0;
 except
   LogAndExitPlayer('Ошибка в процедуре muteoff',0,0);
 end;
end;

procedure muteon;
begin
 try
 tempmutevol:=SinglePlayerSettings.curentvol;
 BASS_ChannelSetAttribute(channel,BASS_ATTRIB_VOL,0);
 SinglePlayerSettings.mute:=1;
 except
   LogAndExitPlayer('Ошибка в процедуре muteon',0,0);
 end;
end;

procedure plsclear;
var
i:integer;
begin
 try
if statusplaylist=0 then
  begin
 for i:=1 to SinglePlayerSettings.kolltrack do track[i]:='';
 SinglePlayerSettings.kolltrack:=0;
 SinglePlayerSettings.playedtrack:=0;
 curenttrack:='';
 plscurtrackpos[singleplayersettings.curentplaylist,1]:=1;
 plscurtrackpos[singleplayersettings.curentplaylist,2]:=-1;
 if fileexists(SinglePlayerDir+'playlist_'+inttostr(SinglePlayerSettings.curentplaylist)+'.pls') then sysutils.deletefile(SinglePlayerDir+'playlist_'+inttostr(SinglePlayerSettings.curentplaylist)+'.pls');
  end;
 except
  LogAndExitPlayer('Ошибка в процедуре plsclear',0,0);
 end;
end;

procedure plsetread;
begin
 try
 {------------------------------------- основные ------------------------------}
   plsettingsmass[1,1]:=getfromlangpack('savetrackpos'); //'Сохранять позицию трека'
   plsettingsznach[1,1]:=inttostr(SinglePlayerSettings.savepos);
   plsettingsmass[1,2]:=getfromlangpack('smoothsatt');//'Плавное затухание звука';
   plsettingsznach[1,2]:=inttostr(SinglePlayerSettings.plavzvuk);
   plsettingsmass[1,3]:=getfromlangpack('playallpls');//'Играть все плейлисты';
   plsettingsznach[1,3]:=inttostr(SinglePlayerSettings.playallpls);
   plsettingsmass[1,4]:=getfromlangpack('upto10s');//'Возврат к началу после 10с';
   plsettingsznach[1,4]:=inttostr(SinglePlayerSettings.backzero);
   plsettingsmass[1,5]:=getfromlangpack('exploreroff');//'Закрывать проводник';
   plsettingsznach[1,5]:=inttostr(SinglePlayerSettings.closeaftadd);
   plsettingsmass[1,6]:=getfromlangpack('rewindon');//'Включить перемотку трека';
   plsettingsznach[1,6]:=inttostr(SinglePlayerSettings.peremotka);
   plsettingsmass[1,7]:=getfromlangpack('startplay');//'Воспроизведение при старте';
   plsettingsznach[1,7]:=inttostr(SinglePlayerSettings.startautoplay);
   plsettingsmass[1,8]:=getfromlangpack('searchandaskusb');//'Диалог для USB';
   plsettingsznach[1,8]:=inttostr(SinglePlayerSettings.autousb);
   plsettingsmass[1,9]:=getfromlangpack('swipeon');//'Включить свайпы';
   plsettingsznach[1,9]:=inttostr(SinglePlayerSettings.swipeon);
   plsettingsmass[1,10]:=getfromlangpack('sysvoluse');//'Управлять громкостью системы';
   plsettingsznach[1,10]:=inttostr(SinglePlayerSettings.sysvolchange);

 {------------------------------------- Плейлист ------------------------------}
   plsettingsmass[2,1]:=getfromlangpack('listfiles');//'Отображать файлы списком';
   plsettingsznach[2,1]:=inttostr(plset.treetype);
   plsettingsmass[2,2]:=getfromlangpack('sorting');//'Сортировка по алфавиту';
   plsettingsznach[2,2]:=inttostr(SinglePlayerSettings.sorttrue);
   plsettingsmass[2,3]:=getfromlangpack('playonetrack');//'Играть один текущий трек';
   plsettingsznach[2,3]:=inttostr(SinglePlayerSettings.playone);
   plsettingsmass[2,4]:=getfromlangpack('playtrackspread');//'Играть треки в разброс';
   plsettingsznach[2,4]:=inttostr(SinglePlayerSettings.shufflekey);
   plsettingsmass[2,5]:=getfromlangpack('subfolderson');//'Добавлять подкаталоги';
   plsettingsznach[2,5]:=inttostr(SinglePlayerSettings.recadd);
   plsettingsmass[2,6]:=getfromlangpack('playfromgenre');//'Играть треки согласно жанру';
   plsettingsznach[2,6]:=inttostr(SinglePlayerSettings.playfromgenre);
   plsettingsmass[2,7]:=getfromlangpack('cyclicpls');//'Цикличный плейлист';
   plsettingsznach[2,7]:=inttostr(SinglePlayerSettings.ciclepls);
   plsettingsmass[2,8]:=getfromlangpack('tomoveon');//'Двигать по ';
   plsettingsznach[2,8]:=inttostr(SinglePlayerSettings.wheelone);
   plsettingsmass[2,9]:=getfromlangpack('playplsch');//'Играть трек при смене плейлиста';
   plsettingsznach[2,9]:=inttostr(SinglePlayerSettings.playaftchangepls);
   plsettingsmass[2,10]:=getfromlangpack('sortallpls');//'Сортировать весь плейлист';
   plsettingsznach[2,10]:=inttostr(SinglePlayerSettings.sortingallpls);
   plsettingsmass[2,11]:=getfromlangpack('sortmode');//'Сортировать весь плейлист';
   plsettingsznach[2,11]:=inttostr(plset.sortmode);

 {------------------------------------- Звук ----------------------------------}
   plsettingsmass[3,1]:=getfromlangpack('eqon2');//'Включить эквалайзер';
   plsettingsznach[3,1]:=inttostr(SinglePlayerSettings.eqon);
   plsettingsmass[3,2]:=getfromlangpack('autoeq');//'Авто жанр эквалайзера';
   plsettingsznach[3,2]:=inttostr(SinglePlayerSettings.autoeq);
   plsettingsmass[3,3]:=getfromlangpack('eqapply');//'Применять значения eq сразу';
   plsettingsznach[3,3]:=inttostr(SinglePlayerSettings.eqsetnow);
   plsettingsmass[3,4]:=getfromlangpack('32biton');//'Вывод звука 32 bit';
   plsettingsznach[3,4]:=inttostr(SinglePlayerSettings.floatdsp);


{----------------------------------- Нагрузка  --------------------------------}
   plsettingsmass[4,1]:=getfromlangpack('eqoff');//'Eq Off';
   plsettingsznach[4,1]:=inttostr(SinglePlayerSettings.perfeqexit);
   plsettingsmass[4,2]:=getfromlangpack('eqon');//'Eq On';
   plsettingsznach[4,2]:=inttostr(SinglePlayerSettings.perfeqon);
   plsettingsmass[4,3]:=getfromlangpack('visintensiv');//'VisIntensiv';
   plsettingsznach[4,3]:=inttostr(SinglePlayerSettings.changevizint);
   plsettingsmass[4,4]:=getfromlangpack('radiobuffer');//'RadioBuffer';
   plsettingsznach[4,4]:=inttostr(SinglePlayerSettings.changenetbuffer);
   plsettingsmass[4,5]:=getfromlangpack('radioprebuffer');//'RadioPreBuffer';
   plsettingsznach[4,5]:=inttostr(SinglePlayerSettings.changenetprebuffer);
   plsettingsmass[4,6]:=getfromlangpack('radiotimeout');//'RadioTimeOut';
   plsettingsznach[4,6]:=inttostr(SinglePlayerSettings.changenettimeout);
   plsettingsmass[4,7]:=getfromlangpack('radiotimeread');//'RadioTimeRead';
   plsettingsznach[4,7]:=inttostr(SinglePlayerSettings.changenetreadtimeout);
   plsettingsmass[4,8]:=getfromlangpack('playerbuffer');//'PlayerBuffer';
   plsettingsznach[4,8]:=inttostr(SinglePlayerSettings.changeplayerbuffer);
   plsettingsmass[4,9]:=getfromlangpack('playerupdate');//'PlayerUpdate';
   plsettingsznach[4,9]:=inttostr(SinglePlayerSettings.changeplayupdateperiod);
   plsettingsmass[4,10]:=getfromlangpack('playerfreq');//'PlayerFreq';
   plsettingsznach[4,10]:=inttostr(SinglePlayerSettings.changeplayerfreq);

   {------------------------------ Внешний вид --------------------------------}
   plsettingsmass[5,1]:=getfromlangpack('revtracktime');//'Обратное время трека';
   plsettingsznach[5,1]:=inttostr(SinglePlayerSettings.timerrevkey);
   plsettingsmass[5,2]:=getfromlangpack('scrolltrname');//'Прокрутка названия трека';
   plsettingsznach[5,2]:=inttostr(SinglePlayerSettings.scrolltrack);
   plsettingsmass[5,3]:=getfromlangpack('scrollshortn');//'Прокрутка коротких названий';
   plsettingsznach[5,3]:=inttostr(SinglePlayerSettings.scrollsmalltrack);
   plsettingsmass[5,4]:=getfromlangpack('antibanner');//'Антибаннер-корректор';
   plsettingsznach[5,4]:=inttostr(SinglePlayerSettings.removebanner);
   plsettingsmass[5,5]:=getfromlangpack('coveron');//'Считывать обложку альбома';
   plsettingsznach[5,5]:=inttostr(SinglePlayerSettings.showcoverpl);
   plsettingsmass[5,6]:=getfromlangpack('vison');//'Включить визуализацию';
   plsettingsznach[5,6]:=inttostr(SinglePlayerSettings.vizon);
   plsettingsmass[5,7]:=getfromlangpack('2linetrack');//'Название трека в 2 строки';
   plsettingsznach[5,7]:=inttostr(SinglePlayerSettings.track2str);
   plsettingsmass[5,8]:=getfromlangpack('cpuon');//'Отображать загрузку ЦП';
   plsettingsznach[5,8]:=inttostr(SinglePlayerSettings.showcpu);
   plsettingsmass[5,9]:=getfromlangpack('readtag');//'Считывать теги с треков';
   plsettingsznach[5,9]:=inttostr(SinglePlayerSettings.readtags);
   plsettingsmass[5,10]:=getfromlangpack('changelang');//'Менять язык';
   plsettingsznach[5,10]:=inttostr(SinglePlayerSettings.changelang);
 except
  LogAndExitPlayer('Ошибка в процедуре plsetread',0,0);
 end;
end;

procedure plsetapply;
begin
 try
  SinglePlayerSettings.savepos:=strtoint(plsettingsznach[1,1]);
  {-----}
  SinglePlayerSettings.plavzvuk:=strtoint(plsettingsznach[1,2]);
  {-----}
  SinglePlayerSettings.playallpls:=strtoint(plsettingsznach[1,3]);
  {-----}
  SinglePlayerSettings.backzero:=strtoint(plsettingsznach[1,4]);
  {-----}
  SinglePlayerSettings.closeaftadd:=strtoint(plsettingsznach[1,5]);
  {-----}
  SinglePlayerSettings.peremotka:=strtoint(plsettingsznach[1,6]);
  {-----}
  SinglePlayerSettings.startautoplay:=strtoint(plsettingsznach[1,7]);
  {-----}
  SinglePlayerSettings.autousb:=strtoint(plsettingsznach[1,8]);
  {-----}
  SinglePlayerSettings.swipeon:=strtoint(plsettingsznach[1,9]);
  {-----}
  SinglePlayerSettings.sysvolchange:=strtoint(plsettingsznach[1,10]);
  {------------------------------------------------------------}
  plset.treetype:=strtoint(plsettingsznach[2,1]);
  {-----}
  if SinglePlayerSettings.sorttrue<>strtoint(plsettingsznach[2,2]) then
   begin
    SinglePlayerSettings.sorttrue:=strtoint(plsettingsznach[2,2]);
    if SinglePlayerSettings.sorttrue=1 then sortplaylistthead;
   end;
  {-----}
  SinglePlayerSettings.playone:=strtoint(plsettingsznach[2,3]);
  {-----}
  SinglePlayerSettings.shufflekey:=strtoint(plsettingsznach[2,4]);
  {-----}
  SinglePlayerSettings.recadd:=strtoint(plsettingsznach[2,5]);
  {-----}
  if SinglePlayerSettings.playfromgenre<>strtoint(plsettingsznach[2,6]) then
   begin
    SinglePlayerSettings.playfromgenre:=strtoint(plsettingsznach[2,6]);
    if SinglePlayerSettings.playfromgenre=1 then begin SinglePlayerSettings.autoeq:=0; plsettingsznach[3,2]:='0'; end;
   end;
  {-----}
  SinglePlayerSettings.ciclepls:=strtoint(plsettingsznach[2,7]);
  {-----}
  SinglePlayerSettings.wheelone:=strtoint(plsettingsznach[2,8]);
  {-----}
  SinglePlayerSettings.playaftchangepls:=strtoint(plsettingsznach[2,9]);
  {-----}
  SinglePlayerSettings.sortingallpls:=strtoint(plsettingsznach[2,10]);
  {--------------------------------------------------------------}
  if SinglePlayerSettings.eqon<>strtoint(plsettingsznach[3,1]) then
   begin
    SinglePlayerSettings.eqon:=strtoint(plsettingsznach[3,1]);
    eqclear;
   end;
  {-----}
  if SinglePlayerSettings.autoeq<>strtoint(plsettingsznach[3,2]) then
   begin
    SinglePlayerSettings.autoeq:=strtoint(plsettingsznach[3,2]);
    if SinglePlayerSettings.autoeq=1 then begin SinglePlayerSettings.playfromgenre:=0; plsettingsznach[2,6]:='0'; end;
   end;
  {-----}
  SinglePlayerSettings.eqsetnow:=strtoint(plsettingsznach[3,3]);
  {-----}
  SinglePlayerSettings.floatdsp:=strtoint(plsettingsznach[3,4]);
  {--------------------------------------------------------------}

  {--------------------------------------------------------------}

  {--------------------------------------------------------------}
  SinglePlayerSettings.perfeqexit:=strtoint(plsettingsznach[4,1]);
  {-----}
  SinglePlayerSettings.perfeqon:=strtoint(plsettingsznach[4,2]);
  {-----}
  SinglePlayerSettings.changevizint:=strtoint(plsettingsznach[4,3]);
  {-----}
  SinglePlayerSettings.changenetbuffer:=strtoint(plsettingsznach[4,4]);
  if SinglePlayerSettings.changenetbuffer=0 then singleplayersettings.netbuffer:=10000;
  {-----}
  SinglePlayerSettings.changenetprebuffer:=strtoint(plsettingsznach[4,5]);
  if SinglePlayerSettings.changenetprebuffer=0 then singleplayersettings.netprebuffer:=75;
  {-----}
  SinglePlayerSettings.changenettimeout:=strtoint(plsettingsznach[4,6]);
  if SinglePlayerSettings.changenettimeout=0 then singleplayersettings.nettimeout:=10000;
  {-----}
  SinglePlayerSettings.changenetreadtimeout:=strtoint(plsettingsznach[4,7]);
  if SinglePlayerSettings.changenetreadtimeout=0 then singleplayersettings.netreadtimeout:=0;
  {-----}
  SinglePlayerSettings.changeplayerbuffer:=strtoint(plsettingsznach[4,8]);
  if SinglePlayerSettings.changeplayerbuffer=0 then singleplayersettings.playerbuffer:=200;
  {-----}
  SinglePlayerSettings.changeplayupdateperiod:=strtoint(plsettingsznach[4,9]);
  if SinglePlayerSettings.changeplayupdateperiod=0 then singleplayersettings.playupdateperiod:=100;
  {-----}
  SinglePlayerSettings.changeplayerfreq:=strtoint(plsettingsznach[4,10]);
  if SinglePlayerSettings.changeplayerfreq=0 then singleplayersettings.playerfreq:=8;

  if (BASS_GetConfig(BASS_CONFIG_NET_BUFFER) <> singleplayersettings.netbuffer) or
     (BASS_GetConfig(BASS_CONFIG_NET_TIMEOUT) <> singleplayersettings.nettimeout) or
     (BASS_GetConfig(BASS_CONFIG_NET_READTIMEOUT) <> singleplayersettings.netreadtimeout) or
     (BASS_GetConfig(BASS_CONFIG_BUFFER) <> singleplayersettings.playerbuffer) or
     (BASS_GetConfig(BASS_CONFIG_UPDATEPERIOD) <> singleplayersettings.playupdateperiod) or
     (BASS_GetConfig(BASS_CONFIG_FLOATDSP) <> singleplayersettings.floatdsp) or
     (tempfreq <> singleplayersettings.playerfreq) then
   begin
    mode:=stop;
    BASS_ChannelStop(radiochannel);
    BASS_StreamFree(radiochannel);
    BASS_ChannelStop(channel);
    BASS_StreamFree(channel);
    bass_free();
    setinitbass;
   end;
  {--------------------------------------------------------------}
  SinglePlayerSettings.timerrevkey:=strtoint(plsettingsznach[5,1]);
  {-----}
  SinglePlayerSettings.scrolltrack:=strtoint(plsettingsznach[5,2]);
  {-----}
  SinglePlayerSettings.scrollsmalltrack:=strtoint(plsettingsznach[5,3]);
  {-----}
  SinglePlayerSettings.removebanner:=strtoint(plsettingsznach[5,4]);
  {-----}
  SinglePlayerSettings.showcoverpl:=strtoint(plsettingsznach[5,5]);
  {-----}
  SinglePlayerSettings.vizon:=strtoint(plsettingsznach[5,6]);
  {-----}
  SinglePlayerSettings.track2str:=strtoint(plsettingsznach[5,7]);
  {-----}
  SinglePlayerSettings.showcpu:=strtoint(plsettingsznach[5,8]);
  {-----}
  SinglePlayerSettings.readtags:=strtoint(plsettingsznach[5,9]);
  {-----}
  SinglePlayerSettings.changelang:=strtoint(plsettingsznach[5,10]);
  {-----}
 except
  LogAndExitPlayer('Ошибка в процедуре plsetapply',0,0);
 end;
end;

procedure playersettings;
var
  i,X1,Y1,X2,X3:integer;
begin
 try
 if plsett<>0 then
  begin
  SinglePlayerGUI.Canvas.brush.Color:=plset.plsetfillcolor;
  SinglePlayerGUI.Canvas.font.Color:=plset.plsettextcolor;
  SinglePlayerGUI.Canvas.Font.Size:=plset.plsettextsize;
  SinglePlayerGUI.Canvas.FillRect(seticons[itsicon].left,seticons[itsicon].top-5,seticons[itsicon].left+seticons[itsicon].width,seticons[itsicon].top-2);
  X1:=plset.plsettextleft;
  Y1:=plset.plsettexttop;

 for i:=1 to 10 do
   begin
    if plsettingsmass[plsett,i]<>'' then
      begin
      if Y1+playericon[getindexicon('chboff.bmp')].Height+plset.plseticonsm>plset.chbsetpole then begin Y1:=plset.plsettexttop; X1:=X1+plset.setchbsmh; end;
      SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),X1+playericon[getindexicon('chboff.bmp')].Width+plset.plsettextsmw,Y1+plset.plsettextsmh,plsettingsmass[plsett,i]);
          if plsettingsznach[plsett,i]='1' then SinglePlayerGUI.Canvas.Draw(X1, Y1, playericon[getindexicon('chbon.bmp')]) else SinglePlayerGUI.Canvas.Draw(X1, Y1, playericon[getindexicon('chboff.bmp')]);
          plsettingscor[i,1]:=X1;
          plsettingscor[i,2]:=Y1;
          plsettingscor[i,3]:=X1+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+plset.plsettextsmw;
          plsettingscor[i,4]:=Y1+playericon[getindexicon('chboff.bmp')].Height;
          if (plsett=2) and (i=8) then       {рисуем spinedit для вкл режима выбора количества треков для свайпа}
            begin
            X2:=X1+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2);
            X3:=X2+SinglePlayerGUI.Canvas.TextWidth(inttostr(SinglePlayerSettings.SwipeAmount))+playericon[getindexicon('equp.bmp')].Width+10;
            SinglePlayerGUI.Canvas.Draw(X2, Y1, playericon[getindexicon('equp.bmp')]);
            SinglePlayerGUI.Canvas.Draw(X3, Y1, playericon[getindexicon('eqdown.bmp')]);
            SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),X2+playericon[getindexicon('equp.bmp')].Width+5,Y1+plset.plsettextsmh,inttostr(SinglePlayerSettings.SwipeAmount));
            plsettingscor[i,3]:=X3+playericon[getindexicon('eqdown.bmp')].Width;
            SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),X3+playericon[getindexicon('eqdown.bmp')].Width+plset.plsettextsmw,Y1+plset.plsettextsmh,getfromlangpack('tracks'));
            end;
       if (plsett=4) and (i=1) then       {рисуем spinedit для выклю эквалайзера при нагрузке}
         begin
         X2:=X1+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2);
         X3:=X2+SinglePlayerGUI.Canvas.TextWidth(inttostr(SinglePlayerSettings.znachcpueq))+playericon[getindexicon('equp.bmp')].Width+10;
         SinglePlayerGUI.Canvas.Draw(X2, Y1, playericon[getindexicon('equp.bmp')]);
         SinglePlayerGUI.Canvas.Draw(X3, Y1, playericon[getindexicon('eqdown.bmp')]);
         SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),X2+playericon[getindexicon('equp.bmp')].Width+5,Y1+plset.plsettextsmh,inttostr(SinglePlayerSettings.znachcpueq));
         plsettingscor[i,3]:=X3+playericon[getindexicon('eqdown.bmp')].Width;
         end;
       if (plsett=4) and (i=2) then       {рисуем spinedit для вкл эквалайзера при нагрузке}
         begin
         X2:=X1+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2);
         X3:=X2+SinglePlayerGUI.Canvas.TextWidth(inttostr(SinglePlayerSettings.znachcpueqmin))+playericon[getindexicon('equp.bmp')].Width+10;
         SinglePlayerGUI.Canvas.Draw(X2, Y1, playericon[getindexicon('equp.bmp')]);
         SinglePlayerGUI.Canvas.Draw(X3, Y1, playericon[getindexicon('eqdown.bmp')]);
         SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),X2+playericon[getindexicon('equp.bmp')].Width+5,Y1+plset.plsettextsmh,inttostr(SinglePlayerSettings.znachcpueqmin));
         plsettingscor[i,3]:=X3+playericon[getindexicon('eqdown.bmp')].Width;
         end;
       if (plsett=4) and (i=3) then       {рисуем spinedit для выбора интенсивности визуализации}
         begin
         X2:=X1+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2);
         X3:=X2+SinglePlayerGUI.Canvas.TextWidth(inttostr(SinglePlayerSettings.vizintensivitu))+playericon[getindexicon('equp.bmp')].Width+10;
         SinglePlayerGUI.Canvas.Draw(X2, Y1, playericon[getindexicon('equp.bmp')]);
         SinglePlayerGUI.Canvas.Draw(X3, Y1, playericon[getindexicon('eqdown.bmp')]);
         SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),X2+playericon[getindexicon('equp.bmp')].Width+5,Y1+plset.plsettextsmh,inttostr(SinglePlayerSettings.vizintensivitu));
         plsettingscor[i,3]:=X3+playericon[getindexicon('eqdown.bmp')].Width;
         end;
       if (plsett=4) and (i=4) then       {рисуем spinedit для выбора интенсивности визуализации}
         begin
         X2:=X1+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2);
         X3:=X2+SinglePlayerGUI.Canvas.TextWidth(inttostr(SinglePlayerSettings.netbuffer))+playericon[getindexicon('equp.bmp')].Width+10;
         SinglePlayerGUI.Canvas.Draw(X2, Y1, playericon[getindexicon('equp.bmp')]);
         SinglePlayerGUI.Canvas.Draw(X3, Y1, playericon[getindexicon('eqdown.bmp')]);
         SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),X2+playericon[getindexicon('equp.bmp')].Width+5,Y1+plset.plsettextsmh,inttostr(SinglePlayerSettings.netbuffer));
         plsettingscor[i,3]:=X3+playericon[getindexicon('eqdown.bmp')].Width;
         end;
       if (plsett=4) and (i=5) then       {рисуем spinedit для выбора интенсивности визуализации}
         begin
         X2:=X1+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2);
         X3:=X2+SinglePlayerGUI.Canvas.TextWidth(inttostr(SinglePlayerSettings.netprebuffer))+playericon[getindexicon('equp.bmp')].Width+10;
         SinglePlayerGUI.Canvas.Draw(X2, Y1, playericon[getindexicon('equp.bmp')]);
         SinglePlayerGUI.Canvas.Draw(X3, Y1, playericon[getindexicon('eqdown.bmp')]);
         SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),X2+playericon[getindexicon('equp.bmp')].Width+5,Y1+plset.plsettextsmh,inttostr(SinglePlayerSettings.netprebuffer));
         plsettingscor[i,3]:=X3+playericon[getindexicon('eqdown.bmp')].Width;
         end;
       if (plsett=4) and (i=6) then       {рисуем spinedit для выбора интенсивности визуализации}
         begin
         X2:=X1+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2);
         X3:=X2+SinglePlayerGUI.Canvas.TextWidth(inttostr(SinglePlayerSettings.nettimeout))+playericon[getindexicon('equp.bmp')].Width+10;
         SinglePlayerGUI.Canvas.Draw(X2, Y1, playericon[getindexicon('equp.bmp')]);
         SinglePlayerGUI.Canvas.Draw(X3, Y1, playericon[getindexicon('eqdown.bmp')]);
         SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),X2+playericon[getindexicon('equp.bmp')].Width+5,Y1+plset.plsettextsmh,inttostr(SinglePlayerSettings.nettimeout));
         plsettingscor[i,3]:=X3+playericon[getindexicon('eqdown.bmp')].Width;
         end;
       if (plsett=4) and (i=7) then       {рисуем spinedit для выбора интенсивности визуализации}
         begin
         X2:=X1+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2);
         X3:=X2+SinglePlayerGUI.Canvas.TextWidth(inttostr(SinglePlayerSettings.netreadtimeout))+playericon[getindexicon('equp.bmp')].Width+10;
         SinglePlayerGUI.Canvas.Draw(X2, Y1, playericon[getindexicon('equp.bmp')]);
         SinglePlayerGUI.Canvas.Draw(X3, Y1, playericon[getindexicon('eqdown.bmp')]);
         SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),X2+playericon[getindexicon('equp.bmp')].Width+5,Y1+plset.plsettextsmh,inttostr(SinglePlayerSettings.netreadtimeout));
         plsettingscor[i,3]:=X3+playericon[getindexicon('eqdown.bmp')].Width;
         end;
       if (plsett=4) and (i=8) then       {рисуем spinedit для выбора интенсивности визуализации}
         begin
         X2:=X1+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2);
         X3:=X2+SinglePlayerGUI.Canvas.TextWidth(inttostr(SinglePlayerSettings.playerbuffer))+playericon[getindexicon('equp.bmp')].Width+10;
         SinglePlayerGUI.Canvas.Draw(X2, Y1, playericon[getindexicon('equp.bmp')]);
         SinglePlayerGUI.Canvas.Draw(X3, Y1, playericon[getindexicon('eqdown.bmp')]);
         SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),X2+playericon[getindexicon('equp.bmp')].Width+5,Y1+plset.plsettextsmh,inttostr(SinglePlayerSettings.playerbuffer));
         plsettingscor[i,3]:=X3+playericon[getindexicon('eqdown.bmp')].Width;
         end;
       if (plsett=4) and (i=9) then       {рисуем spinedit для выбора интенсивности визуализации}
         begin
         X2:=X1+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2);
         X3:=X2+SinglePlayerGUI.Canvas.TextWidth(inttostr(SinglePlayerSettings.playupdateperiod))+playericon[getindexicon('equp.bmp')].Width+10;
         SinglePlayerGUI.Canvas.Draw(X2, Y1, playericon[getindexicon('equp.bmp')]);
         SinglePlayerGUI.Canvas.Draw(X3, Y1, playericon[getindexicon('eqdown.bmp')]);
         SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),X2+playericon[getindexicon('equp.bmp')].Width+5,Y1+plset.plsettextsmh,inttostr(SinglePlayerSettings.playupdateperiod));
         plsettingscor[i,3]:=X3+playericon[getindexicon('eqdown.bmp')].Width;
         end;
       if (plsett=4) and (i=10) then       {рисуем spinedit для выбора интенсивности визуализации}
         begin
         X2:=X1+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2);
         X3:=X2+SinglePlayerGUI.Canvas.TextWidth(inttostr(playerfreqmas[SinglePlayerSettings.playerfreq]))+playericon[getindexicon('equp.bmp')].Width+10;
         SinglePlayerGUI.Canvas.Draw(X2, Y1, playericon[getindexicon('equp.bmp')]);
         SinglePlayerGUI.Canvas.Draw(X3, Y1, playericon[getindexicon('eqdown.bmp')]);
         SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),X2+playericon[getindexicon('equp.bmp')].Width+5,Y1+plset.plsettextsmh,inttostr(playerfreqmas[SinglePlayerSettings.playerfreq]));
         plsettingscor[i,3]:=X3+playericon[getindexicon('eqdown.bmp')].Width;
         end;
       if (plsett=5) and (i=10) then       {рисуем spinedit для выбора языка}
         begin
          X2:=X1+playericon[getindexicon('chboff.bmp')].Width+SinglePlayerGUI.Canvas.TextWidth(plsettingsmass[plsett,i])+(plset.plsettextsmw*2);
          X3:=X2+SinglePlayerGUI.Canvas.TextWidth(singleplayersettings.langg)+playericon[getindexicon('equp.bmp')].Width+10;
          SinglePlayerGUI.Canvas.Draw(X2, Y1, playericon[getindexicon('equp.bmp')]);
          SinglePlayerGUI.Canvas.Draw(X3, Y1, playericon[getindexicon('eqdown.bmp')]);
          SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),X2+playericon[getindexicon('equp.bmp')].Width+5,Y1+plset.plsettextsmh,singleplayersettings.langg);
          plsettingscor[i,3]:=X3+playericon[getindexicon('eqdown.bmp')].Width;
         end;
      Y1:=Y1+playericon[getindexicon('chboff.bmp')].Height+plset.plseticonsm;
      end;
   end;

  if plsett=6 then skinchangepaint;       //рисуем страницу выбора скина

  end;
 except
  LogAndExitPlayer('Ошибка в процедуре playersettings',0,0);
 end;
end;

procedure generalsetpl;

begin
 plsett:=1;
 itsicon:=getindexicon('generalsetpl.bmp');
end;

procedure playlistset;
begin
 plsett:=2;
 itsicon:=getindexicon('playlistset.bmp');
end;

procedure soundsetpl;
begin
 plsett:=3;
 itsicon:=getindexicon('soundsetpl.bmp');
end;

procedure plsetperf;
begin
 plsett:=4;
 itsicon:=getindexicon('plsetperf.bmp');
end;

procedure playerfaceset;
begin
 plsett:=5;
 itsicon:=getindexicon('playerfaceset.bmp');
end;

procedure plsetskin;
begin
 plsett:=6;
 itsicon:=getindexicon('plsetskin.bmp');
end;

procedure trackdown(plstrack:integer);
var
 tmpstr:string;
begin
 try
 if (statusplaylist=0) and (plstrack<>0) then
  begin
 if plstrack<SinglePlayerSettings.kolltrack then
  begin
   tmpstr:=track[plstrack];
   track[plstrack]:=track[plstrack+1];
   track[plstrack+1]:=tmpstr;
   SinglePlayerSettings.playedtrack:=plstrack+1;
   SinglePlayerGUI.repaint;
   saveplaylist;
  end;
  end;
 except
  LogAndExitPlayer('Ошибка в процедуре trackdown',0,0);
 end;
end;

procedure trackup(plstrack:integer);
var
 tmpstr:string;
begin
 try
  if (statusplaylist=0) and (plstrack<>0) then
  begin
 if plstrack>2 then
  begin
   tmpstr:=track[plstrack];
   track[plstrack]:=track[plstrack-1];
   track[plstrack-1]:=tmpstr;
   SinglePlayerSettings.playedtrack:=plstrack-1;
   SinglePlayerGUI.repaint;
   saveplaylist;
  end;
  end;
 except
  LogAndExitPlayer('Ошибка в процедуре trackup',0,0);
 end;
end;

procedure msgdel;
begin
 try
 SinglePlayerGUI.canvas.pen.Color:=$0000FF;
 SinglePlayerGUI.canvas.Brush.Color:=$000000;
 SinglePlayerGUI.canvas.RoundRect(30,130,770,300,30,20);
 SinglePlayerGUI.canvas.Brush.Color:=$FFA500;
 SinglePlayerGUI.canvas.RoundRect(260,230,360,280,30,20);
 SinglePlayerGUI.canvas.RoundRect(430,230,530,280,30,20);
 SinglePlayerGUI.canvas.Font.Color:=$00FFFF;
 SinglePlayerGUI.Canvas.Font.Size:=16;
 SinglePlayerGUI.Canvas.Font.Bold:=true;
 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign('1:center:800',UTF8Encode(extractfilename(curworktrack)),1),180,UTF8Encode(extractfilename(curworktrack)));
 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),150,150,getfromlangpack('youwant'));
 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),450,150,getfromlangpack('delfromdisk'));
 SinglePlayerGUI.canvas.Font.Color:=$000000;
 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),299,240,getfromlangpack('yes'));
 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),460,240,getfromlangpack('no'));
 SinglePlayerGUI.Canvas.Font.Bold:=false;
 msgdelX:=260;
 msgdelY:=230;
 msgdelX2:=360;
 msgdelY2:=280;

 except
  LogAndExitPlayer('Ошибка в процедуре msgdel',0,0);
 end;
end;

procedure msgfav;
begin
 try
 SinglePlayerGUI.canvas.pen.Color:=$0000FF;
 SinglePlayerGUI.canvas.Brush.Color:=$000000;
 SinglePlayerGUI.canvas.RoundRect(30,130,770,320,30,20);
 SinglePlayerGUI.canvas.Brush.Color:=$FFA500;
 SinglePlayerGUI.canvas.RoundRect(240,230,400,300,30,20);
 SinglePlayerGUI.canvas.RoundRect(420,230,570,300,30,20);
 SinglePlayerGUI.canvas.Font.Color:=$00FFFF;
 SinglePlayerGUI.Canvas.Font.Size:=16;
 SinglePlayerGUI.Canvas.Font.Bold:=true;
 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),255,150,getfromlangpack('addtrack'));
 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign('1:center:800',UTF8Encode(extractfilename(curworktrack)),1),180,UTF8Encode(extractfilename(curworktrack)));
 SinglePlayerGUI.canvas.Font.Color:=$000000;
 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),270,250,getfromlangpack('playlist'));
 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),445,240,getfromlangpack('playlist'));
 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),455,265,getfromlangpack('and')+' '+getfromlangpack('folder'));
 SinglePlayerGUI.Canvas.Font.Bold:=false;
 msgfavX:=240;
 msgfavY:=230;
 msgfavX2:=400;
 msgfavY2:=300;

 msgfavX3:=420;
 msgfavY3:=230;
 msgfavX4:=570;
 msgfavY4:=300;

 except
  LogAndExitPlayer('Ошибка в процедуре msgdel',0,0);
 end;
end;

procedure eqclear;
begin
 try
 if mode=play then
  begin
   try
     SinglePlayerSettings.curpos:=bass_ChannelGetPosition(channel,0);
     SinglePlayerGUI.playertimer.Enabled:=false;
     BASS_ChannelStop(Channel);
     BASS_StreamFree(Channel);
     thisTagv2.Clear;

     curenttrack:=ChangeFileExt(curenttrack,lowercase(ExtractFileExt(curenttrack)));
     if ((length(curenttrack)-pos('.flac',curenttrack)=4) and (pos('.flac',curenttrack)<>0)) or ((length(curenttrack)-pos('.m4a',curenttrack)=3) and (pos('.m4a',curenttrack)<>0)) or ((length(curenttrack)-pos('.mpc',curenttrack)=3) and (pos('.mpc',curenttrack)<>0)) then
      begin
         if (length(curenttrack)-pos('.flac',curenttrack)=4) and (pos('.flac',curenttrack)<>0) then
          begin
        if (SinglePlayerSettings.tempo<>0) or (SinglePlayerSettings.pitch<>0) then
         begin
          Channel := BASS_FLAC_StreamCreateFile(false, PChar(string(curenttrack)), 0, 0,  BASS_STREAM_DECODE);
          channel := BASS_FX_TempoCreate(channel, BASS_FX_FREESOURCE);
         end else  Channel := BASS_FLAC_StreamCreateFile(false, PChar(string(curenttrack)), 0, 0,BASS_SAMPLE_FX and BASS_STREAM_AUTOFREE);
         end;
      if (length(curenttrack)-pos('.m4a',curenttrack)=3) and (pos('.m4a',curenttrack)<>0) then
       begin
       if (SinglePlayerSettings.tempo<>0) or (SinglePlayerSettings.pitch<>0) then
        begin
         Channel :=  BASS_ALAC_StreamCreateFile(false, PChar(string(curenttrack)), 0, 0, BASS_STREAM_DECODE);
         BASS_ChannelGetInfo (channel,chinfo);
         if chinfo.ctype <> BASS_CTYPE_STREAM_ALAC then Channel := BASS_MP4_StreamCreateFile(false, PChar(string(curenttrack)), 0, 0, BASS_STREAM_DECODE);
         channel := BASS_FX_TempoCreate(channel, BASS_FX_FREESOURCE);
        end else
        begin
         Channel :=  BASS_ALAC_StreamCreateFile(false, PChar(string(curenttrack)), 0, 0, BASS_SAMPLE_FX and BASS_STREAM_AUTOFREE);
         BASS_ChannelGetInfo (channel,chinfo);
         if chinfo.ctype <> BASS_CTYPE_STREAM_ALAC then Channel := BASS_MP4_StreamCreateFile(false, PChar(string(curenttrack)), 0, 0, BASS_SAMPLE_FX and BASS_STREAM_AUTOFREE);
        end;
      end;
       if (length(curenttrack)-pos('.mpc',curenttrack)=3) and (pos('.mpc',curenttrack)<>0) then
        begin
      if (SinglePlayerSettings.tempo<>0) or (SinglePlayerSettings.pitch<>0) then
       begin
        Channel := BASS_MPC_StreamCreateFile(false, PChar(string(curenttrack)), 0, 0,  BASS_STREAM_DECODE);
        channel := BASS_FX_TempoCreate(channel, BASS_FX_FREESOURCE);
       end else  Channel := BASS_MPC_StreamCreateFile(false, PChar(string(curenttrack)), 0, 0,BASS_SAMPLE_FX and BASS_STREAM_AUTOFREE);
       end;
      if singleplayersettings.readtags=1 then
       begin
        thisTagv2.Genre:=UTF8Encode(TAGS_Read(Channel, '%GNRE'));
        thisTagv2.Artist:=UTF8Encode(TAGS_Read(Channel, '%ARTI'));
        thisTagv2.Title:=UTF8Encode(TAGS_Read(Channel, '%TITL'));
       end;
      end else
      begin

          if (SinglePlayerSettings.tempo<>0) or (SinglePlayerSettings.pitch<>0) then
           begin
            Channel := BASS_StreamCreateFile(false, PChar(string(curenttrack)), 0, 0,BASS_STREAM_DECODE);
            channel := BASS_FX_TempoCreate(channel, BASS_FX_FREESOURCE);
           end else Channel := BASS_StreamCreateFile(false, PChar(string(curenttrack)), 0, 0,BASS_SAMPLE_FX and BASS_STREAM_AUTOFREE);
      end;

     bass_ChannelSetPosition(channel,SinglePlayerSettings.curpos,0);
     if Channel=0 then begin inc(errorplay); playnexttrack; end;
     eqapply(channel);
     if not BASS_ChannelPlay(Channel, False) then begin inc(errorplay); playnexttrack; end else
     begin
      errorplay:=0;
      pr:=1;       {pr pr2 обнуление прокрутки трека}
      pr2:=0;
      pr3:=1;
      pr4:=0;
      mode:=play;
      if SinglePlayerSettings.mute=0 then BASS_ChannelSetAttribute(channel,BASS_ATTRIB_VOL,SinglePlayerSettings.curentvol/10);
      SinglePlayerGUI.playertimer.Enabled:=true;
      if ((length(curenttrack)-pos('.flac',curenttrack)<>4) or (pos('.flac',curenttrack)=0) or (length(curenttrack)-pos('.m4a',curenttrack)<>3) or (pos('.m4a',curenttrack)=0) or (length(curenttrack)-pos('.mpc',curenttrack)<>3) or (pos('.mpc',curenttrack)=0)) and (singleplayersettings.readtags=1) then thisTagv2.ReadFromFile(curenttrack);

      if SinglePlayerSettings.showcoverpl=1 then
       begin
        loadcaver:=loadcaverp.Create(true);
        loadcaver.freeonterminate := true;
        loadcaver.priority := tpnormal;
        loadcaver.Start;
       end;
     end;
   except
    playnexttrack;
    inc(errorplay);
   end;
  end;
 if mode=radioplay then
  begin
     try
      SinglePlayerGUI.playertimer.Enabled:=false;
      eqapply(radiochannel);
     except
        playnexttrack;
     end;

  end;

 except
   LogAndExitPlayer('Ошибка в процедуре eqclear',0,0);
 end;
end;

procedure genrel;
var
newgenre:string;
j,ll,j2:integer;
begin
 try
   if curentgenre>1 then dec(curentgenre) else curentgenre:=kollgenre;
    for j:=1 to kolleff do
      for j2:=1 to 20 do
        begin
         SinglePlayerSettings.ezf[j,j2]:='';
        end;
    newgenre:=copy(genremass[curentgenre,1],pos(';',genremass[curentgenre,1])+1,length(genremass[curentgenre,1])-pos(';',genremass[curentgenre,1]));
    for j:=1 to kolleff do
      begin
       ll:=1;
         while (pos('/',newgenre)<pos(';',newgenre)) and (pos('/',newgenre)<>0) do
          begin
           SinglePlayerSettings.ezf[j,ll]:=copy(newgenre,1,pos('/',newgenre)-1);
           delete(newgenre,1,pos('/',newgenre));
           inc(ll);
           end;
         SinglePlayerSettings.ezf[j,ll]:=copy(newgenre,1,pos(';',newgenre)-1);
         delete(newgenre,1,pos(';',newgenre));
      end;
    SinglePlayerSettings.distortion:=strtointdef(SinglePlayerSettings.ezf[30,1],0);
    SinglePlayerSettings.phaser:=strtointdef(SinglePlayerSettings.ezf[30,2],0);
    SinglePlayerSettings.FREEVERB:=strtointdef(SinglePlayerSettings.ezf[30,3],0);
    SinglePlayerSettings.autowah:=strtointdef(SinglePlayerSettings.ezf[30,4],0);
    SinglePlayerSettings.echo:=strtointdef(SinglePlayerSettings.ezf[30,5],0);
    SinglePlayerSettings.chorus:=strtointdef(SinglePlayerSettings.ezf[30,6],0);
    SinglePlayerSettings.flanger:=strtointdef(SinglePlayerSettings.ezf[30,7],0);
    SinglePlayerSettings.tempo:=strtointdef(SinglePlayerSettings.ezf[30,8],0);
    SinglePlayerSettings.compressor:=strtointdef(SinglePlayerSettings.ezf[30,9],0);
    SinglePlayerSettings.reverb:=strtointdef(SinglePlayerSettings.ezf[30,10],0);
    SinglePlayerSettings.pitch:=strtointdef(SinglePlayerSettings.ezf[30,11],0);
    SinglePlayerSettings.bqfhigh:=strtointdef(SinglePlayerSettings.ezf[30,12],0);
    SinglePlayerSettings.bqflow:=strtointdef(SinglePlayerSettings.ezf[30,13],0);
    SinglePlayerSettings.bqfBANDPASS:=strtointdef(SinglePlayerSettings.ezf[30,14],0);
    SinglePlayerSettings.bqfPEAKINGEQ:=strtointdef(SinglePlayerSettings.ezf[30,15],0);
    SinglePlayerSettings.bqfnotch:=strtointdef(SinglePlayerSettings.ezf[30,16],0);
   if mode=play then eqapply(channel);
   if mode=radioplay then eqapply(radiochannel);
 except
   LogAndExitPlayer('Ошибка в процедуре genrel',0,0);
 end;
end;

procedure genrer;
var
j,ll,j2:integer;
newgenre:string;
begin
 try
   if curentgenre<kollgenre then inc(curentgenre) else curentgenre:=1;
     for j:=1 to kolleff do
      for j2:=1 to 20 do
        begin
         SinglePlayerSettings.ezf[j,j2]:='';
        end;
    newgenre:=copy(genremass[curentgenre,1],pos(';',genremass[curentgenre,1])+1,length(genremass[curentgenre,1])-pos(';',genremass[curentgenre,1]));
    for j:=1 to kolleff do
      begin
       ll:=1;
         while (pos('/',newgenre)<pos(';',newgenre)) and (pos('/',newgenre)<>0) do
          begin
           SinglePlayerSettings.ezf[j,ll]:=copy(newgenre,1,pos('/',newgenre)-1);
           delete(newgenre,1,pos('/',newgenre));
           inc(ll);
           end;
         SinglePlayerSettings.ezf[j,ll]:=copy(newgenre,1,pos(';',newgenre)-1);
         delete(newgenre,1,pos(';',newgenre));
          end;
    SinglePlayerSettings.distortion:=strtointdef(SinglePlayerSettings.ezf[30,1],0);
    SinglePlayerSettings.phaser:=strtointdef(SinglePlayerSettings.ezf[30,2],0);
    SinglePlayerSettings.FREEVERB:=strtointdef(SinglePlayerSettings.ezf[30,3],0);
    SinglePlayerSettings.autowah:=strtointdef(SinglePlayerSettings.ezf[30,4],0);
    SinglePlayerSettings.echo:=strtointdef(SinglePlayerSettings.ezf[30,5],0);
    SinglePlayerSettings.chorus:=strtointdef(SinglePlayerSettings.ezf[30,6],0);
    SinglePlayerSettings.flanger:=strtointdef(SinglePlayerSettings.ezf[30,7],0);
    SinglePlayerSettings.tempo:=strtointdef(SinglePlayerSettings.ezf[30,8],0);
    SinglePlayerSettings.compressor:=strtointdef(SinglePlayerSettings.ezf[30,9],0);
    SinglePlayerSettings.reverb:=strtointdef(SinglePlayerSettings.ezf[30,10],0);
    SinglePlayerSettings.pitch:=strtointdef(SinglePlayerSettings.ezf[30,11],0);
    SinglePlayerSettings.bqfhigh:=strtointdef(SinglePlayerSettings.ezf[30,12],0);
    SinglePlayerSettings.bqflow:=strtointdef(SinglePlayerSettings.ezf[30,13],0);
    SinglePlayerSettings.bqfBANDPASS:=strtointdef(SinglePlayerSettings.ezf[30,14],0);
    SinglePlayerSettings.bqfPEAKINGEQ:=strtointdef(SinglePlayerSettings.ezf[30,15],0);
    SinglePlayerSettings.bqfnotch:=strtointdef(SinglePlayerSettings.ezf[30,16],0);
    if mode=play then eqapply(channel);
    if mode=radioplay then eqapply(radiochannel);
 except
   LogAndExitPlayer('Ошибка в процедуре genrer',0,0);
 end;
end;

procedure setautoeq(genrebyte:byte);
var
j,ll,j2:integer;
newgenre:string;
begin
 try
 case genrebyte of
  17: begin if curentgenre<>getgenreindex('rock') then curentgenre:=getgenreindex('rock') else exit; end;   //rock
   9: begin if curentgenre<>getgenreindex('rock') then curentgenre:=getgenreindex('rock') else exit; end;  //metal
   1: begin if curentgenre<>getgenreindex('rock') then curentgenre:=getgenreindex('rock') else exit; end;  //classic-rock
 141: begin if curentgenre<>getgenreindex('rock') then curentgenre:=getgenreindex('rock') else exit; end;  //christian-rock
 149: begin if curentgenre<>getgenreindex('rock') then curentgenre:=getgenreindex('rock') else exit; end;  //art-rock
 138: begin if curentgenre<>getgenreindex('rock') then curentgenre:=getgenreindex('rock') else exit; end;  //black-metal
  92: begin if curentgenre<>getgenreindex('rock') then curentgenre:=getgenreindex('rock') else exit; end;  //progressive-rock
   3: begin if curentgenre<>getgenreindex('dance') then curentgenre:=getgenreindex('dance') else exit; end;  //dance
 125: begin if curentgenre<>getgenreindex('dance') then curentgenre:=getgenreindex('dance') else exit; end;  //dance hall
  13: begin if curentgenre<>getgenreindex('pop') then curentgenre:=getgenreindex('pop') else exit; end;   //pop
  62: begin if curentgenre<>getgenreindex('pop') then curentgenre:=getgenreindex('pop') else exit; end; //pop/funk
  53: begin if curentgenre<>getgenreindex('pop') then curentgenre:=getgenreindex('pop') else exit; end; //pop/folk
 112: begin if curentgenre<>getgenreindex('club') then curentgenre:=getgenreindex('club') else exit; end;  //club
 128: begin if curentgenre<>getgenreindex('club') then curentgenre:=getgenreindex('club') else exit; end;  //club-house
  32: begin if curentgenre<>getgenreindex('classical') then curentgenre:=getgenreindex('classical') else exit; end;  //classic
  41: begin if curentgenre<>getgenreindex('bass') then curentgenre:=getgenreindex('bass') else exit; end;  //bass
 107: begin if curentgenre<>getgenreindex('bass') then curentgenre:=getgenreindex('bass') else exit; end;  //booty-bass
 250: begin if curentgenre<>getgenreindex(thisTagv2.Genre) then curentgenre:=getgenreindex(thisTagv2.Genre) else exit; end;   // genre id3v2
  else begin if curentgenre<>getgenreindex('rock') then curentgenre:=getgenreindex('rock') else exit; end;  //null
 end;

 for j:=1 to kolleff do
  for j2:=1 to 20 do
    begin
     SinglePlayerSettings.ezf[j,j2]:='';
    end;
newgenre:=copy(genremass[curentgenre,1],pos(';',genremass[curentgenre,1])+1,length(genremass[curentgenre,1])-pos(';',genremass[curentgenre,1]));
for j:=1 to kolleff do
  begin
   ll:=1;
     while (pos('/',newgenre)<pos(';',newgenre)) and (pos('/',newgenre)<>0) do
      begin
       SinglePlayerSettings.ezf[j,ll]:=copy(newgenre,1,pos('/',newgenre)-1);
       delete(newgenre,1,pos('/',newgenre));
       inc(ll);
       end;
     SinglePlayerSettings.ezf[j,ll]:=copy(newgenre,1,pos(';',newgenre)-1);
     delete(newgenre,1,pos(';',newgenre));
      end;
    if mode=play then eqapply(channel);
    if mode=radioplay then eqapply(radiochannel);

 except
  LogAndExitPlayer('Ошибка в процедуре setautoeq',0,0);
 end;
end;

procedure exponefolder;
begin
 plsettingsznach[2,7]:='0';
 SinglePlayerSettings.recadd:=0;
 SinglePlayerSettings.recone:=0;
end;

procedure expmanyfolder;
begin
 plsettingsznach[2,7]:='1';
 SinglePlayerSettings.recadd:=1;
 SinglePlayerSettings.recone:=0;
end;

procedure exponefile;
begin
 plsettingsznach[2,7]:='0';
 SinglePlayerSettings.recadd:=0;
 SinglePlayerSettings.recone:=1;
end;

procedure eqvk;
begin
   SinglePlayerSettings.eqon:=1;
   plsettingsznach[3,1]:='1';
   SinglePlayerGUI.Invalidate;
   eqclear;
   exit;
end;

procedure eqoff;
begin
SinglePlayerSettings.eqon:=0;
plsettingsznach[3,1]:='0';
SinglePlayerGUI.Invalidate;
eqclear;
exit;
end;

procedure runprog(var progr:string; options:string);
var si: TStartupInfo;
begin
 try
 si.lpTitle:='run';
 CreateProcessW(pwidechar(widestring(progr)),pwidechar(widestring(options)),Nil,Nil,false,0,Nil,Nil,si,pi);
 //WaitforSingleObject(pi.hProcess,INFINITE); - ожидать завершения работы запущенной программы
 closehandle(pi.hThread);
 closehandle(pi.hProcess);
 except
  LogAndExitPlayer('Ошибка в процедуре runprog',0,0);
 end;
end;

procedure eqapply(chan:DWORD);
var
i:integer;
begin
  try
     if singleplayersettings.eqon = 1 then
      begin
      for i:=1 to 13 do
        begin
        BASS_ChannelRemoveFX(chan,fx[i]);
        fx[i] := BASS_ChannelSetFX(chan, BASS_FX_DX8_PARAMEQ, 1);
        BASS_FXGetParameters(fx[i], @p[i]);
        p[i].fGain:=strtoFloatdef(SinglePlayerSettings.ezf[i,1],0);
        p[i].fBandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[i,2],0);
        p[i].fCenter:=strtointdef(SinglePlayerSettings.ezf[i,3],0);
        BASS_FXSetParameters(fx[i], @p[i]);
        end;
      end else
      begin
      for i:=1 to 13 do BASS_ChannelRemoveFX(chan,fx[i]);
      end;

      if singleplayersettings.bqflow = 1 then
       begin
        BASS_ChannelRemoveFX(chan,fxbqflow);
        fxbqflow := BASS_ChannelSetFX(chan, BASS_FX_BFX_BQF, 1);
        BASS_FXGetParameters(fxbqflow, @bqflowparam);
        bqflowparam.lFilter:=BASS_BFX_BQF_lowPASS;
        bqflowparam.fCenter:=strtointdef(SinglePlayerSettings.ezf[20,1],0); {10 - половина ширины тумблера}
        bqflowparam.fQ:=StrToFloatdef(SinglePlayerSettings.ezf[20,2],0);
        bqflowparam.fbandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[20,3],0);
        BASS_FXSetParameters(fxbqflow, @bqflowparam);
       end else BASS_ChannelRemoveFX(chan,fxbqflow);

      if singleplayersettings.bqfhigh = 1 then
       begin
        BASS_ChannelRemoveFX(chan,fxbqfhigh);
        fxbqfhigh := BASS_ChannelSetFX(chan, BASS_FX_BFX_BQF, 1);
        BASS_FXGetParameters(fxbqfhigh, @bqfhighparam);
        bqfhighparam.lFilter:=BASS_BFX_BQF_HIGHPASS;
        bqfhighparam.fCenter:=strtointdef(SinglePlayerSettings.ezf[21,1],0); {10 - половина ширины тумблера}
        bqfhighparam.fQ:=StrToFloatdef(SinglePlayerSettings.ezf[21,2],0);
        bqfhighparam.fbandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[21,3],0);
        BASS_FXSetParameters(fxbqfhigh, @bqfhighparam);
       end else BASS_ChannelRemoveFX(chan,fxbqfhigh);

        if singleplayersettings.bqfPEAKINGEQ = 1 then
         begin
          BASS_ChannelRemoveFX(chan,fxbqfPEAKINGEQ);
          fxbqfPEAKINGEQ := BASS_ChannelSetFX(chan, BASS_FX_BFX_BQF, 1);
          BASS_FXGetParameters(fxbqfPEAKINGEQ, @bqfPEAKINGEQparam);
          bqfPEAKINGEQparam.lFilter:=BASS_BFX_BQF_PEAKINGEQ;
          bqfPEAKINGEQparam.fCenter:=strtointdef(SinglePlayerSettings.ezf[22,1],0); {10 - половина ширины тумблера}
          bqfPEAKINGEQparam.fGain:=strtoFloatdef(SinglePlayerSettings.ezf[22,2],0);
          bqfPEAKINGEQparam.fbandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[22,3],0);
          bqfPEAKINGEQparam.fq:=StrToFloatdef(SinglePlayerSettings.ezf[22,4],0);
          BASS_FXSetParameters(fxbqfPEAKINGEQ, @bqfPEAKINGEQparam);
         end else BASS_ChannelRemoveFX(chan,fxbqfPEAKINGEQ);

        if singleplayersettings.bqfBANDPASS = 1 then
         begin
          BASS_ChannelRemoveFX(chan,fxbqfBANDPASS);
          fxbqfBANDPASS := BASS_ChannelSetFX(chan, BASS_FX_BFX_BQF, 1);
          BASS_FXGetParameters(fxbqfBANDPASS, @bqfBANDPASSparam);
          bqfBANDPASSparam.lFilter:=BASS_BFX_BQF_BANDPASS;
          bqfBANDPASSparam.fCenter:=strtointdef(SinglePlayerSettings.ezf[23,1],0); {10 - половина ширины тумблера}
          bqfBANDPASSparam.fbandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[23,3],0);
          bqfBANDPASSparam.fq:=StrToFloatdef(SinglePlayerSettings.ezf[23,4],0);
          BASS_FXSetParameters(fxbqfBANDPASS, @bqfBANDPASSparam);
         end else BASS_ChannelRemoveFX(chan,fxbqfBANDPASS);

        if singleplayersettings.bqfnotch = 1 then
         begin
          BASS_ChannelRemoveFX(chan,fxbqfnotch);
          fxbqfnotch := BASS_ChannelSetFX(chan, BASS_FX_BFX_BQF, 1);
          BASS_FXGetParameters(fxbqfnotch, @bqfnotchparam);
          bqfnotchparam.lFilter:=BASS_BFX_BQF_notch;
          bqfnotchparam.fCenter:=strtointdef(SinglePlayerSettings.ezf[29,1],0); {10 - половина ширины тумблера}
          bqfnotchparam.fbandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[29,3],0);
          bqfnotchparam.fq:=StrToFloatdef(SinglePlayerSettings.ezf[29,4],0);
          BASS_FXSetParameters(fxbqfnotch, @bqfnotchparam);
         end else BASS_ChannelRemoveFX(chan,fxbqfnotch);


        if singleplayersettings.reverb = 1 then
         begin
          BASS_ChannelRemoveFX(chan,fxreverb);
          fxreverb := BASS_ChannelSetFX(chan, BASS_FX_DX8_REVERB, 1);
          BASS_FXGetParameters(fxreverb, @reverbparam);
          reverbparam.fInGain:=strtoFloatdef(SinglePlayerSettings.ezf[14,1],0);
          reverbparam.fReverbMix:=strtoFloatdef(SinglePlayerSettings.ezf[14,2],0);
          reverbparam.fReverbTime:=StrToFloatdef(SinglePlayerSettings.ezf[14,3],0);
          reverbparam.fHighFreqRTRatio:=StrToFloatdef(SinglePlayerSettings.ezf[14,4],0);
          BASS_FXSetParameters(fxreverb, @reverbparam);
         end else BASS_ChannelRemoveFX(chan,fxreverb);

        if singleplayersettings.echo = 1 then
         begin
          BASS_ChannelRemoveFX(chan,fxecho);
          fxecho := BASS_ChannelSetFX(chan, BASS_FX_DX8_ECHO, 1);
          BASS_FXGetParameters(fxecho, @echoparam);
          echoparam.fWetDryMix:=strtoFloatdef(SinglePlayerSettings.ezf[15,1],0);
          echoparam.fFeedback :=strtoFloatdef(SinglePlayerSettings.ezf[15,2],0);
          echoparam.fLeftDelay :=StrToFloatdef(SinglePlayerSettings.ezf[15,3],0);
          echoparam.fRightDelay :=StrToFloatdef(SinglePlayerSettings.ezf[15,4],0);
          BASS_FXSetParameters(fxecho, @echoparam);
         end else BASS_ChannelRemoveFX(chan,fxecho);

        if singleplayersettings.chorus = 1 then
         begin
          BASS_ChannelRemoveFX(chan,fxchorus);
          fxchorus := BASS_ChannelSetFX(chan, BASS_FX_DX8_CHORUS, 1);
          BASS_FXGetParameters(fxchorus, @chorusparam);
          chorusparam.fWetDryMix:=strtoFloatdef(SinglePlayerSettings.ezf[16,1],0);
          chorusparam.fDepth :=strtoFloatdef(SinglePlayerSettings.ezf[16,2],0);
          chorusparam.fFeedback :=StrToFloatdef(SinglePlayerSettings.ezf[16,3],0);
          chorusparam.fFrequency :=StrToFloatdef(SinglePlayerSettings.ezf[16,4],0);
          chorusparam.fDelay :=StrToFloatdef(SinglePlayerSettings.ezf[16,5],0);
          BASS_FXSetParameters(fxchorus, @chorusparam);
         end else BASS_ChannelRemoveFX(chan,fxchorus);

        if singleplayersettings.flanger = 1 then
         begin
          BASS_ChannelRemoveFX(chan,fxflanger);
          fxflanger := BASS_ChannelSetFX(chan, BASS_FX_DX8_flanger, 1);
          BASS_FXGetParameters(fxflanger, @flangerparam);
          flangerparam.fWetDryMix:=strtoFloatdef(SinglePlayerSettings.ezf[17,1],0);
          flangerparam.fDepth :=strtoFloatdef(SinglePlayerSettings.ezf[17,2],0);
          flangerparam.fFeedback :=StrToFloatdef(SinglePlayerSettings.ezf[17,3],0);
          flangerparam.fFrequency :=StrToFloatdef(SinglePlayerSettings.ezf[17,4],0);
          flangerparam.fDelay :=StrToFloatdef(SinglePlayerSettings.ezf[17,5],0);
          BASS_FXSetParameters(fxflanger, @flangerparam);
         end else BASS_ChannelRemoveFX(chan,fxflanger);

        if singleplayersettings.compressor = 1 then
         begin
          BASS_ChannelRemoveFX(chan,fxcompressor);
          fxcompressor := BASS_ChannelSetFX(chan, BASS_FX_BFX_COMPRESSOR2, 1);
          BASS_FXGetParameters(fxcompressor, @compressorparam);
          compressorparam.fGain:=strtoFloatdef(SinglePlayerSettings.ezf[24,1],0);
          compressorparam.fAttack :=strtoFloatdef(SinglePlayerSettings.ezf[24,2],0);
          compressorparam.fRelease :=StrToFloatdef(SinglePlayerSettings.ezf[24,3],0);
          compressorparam.fThreshold :=StrToFloatdef(SinglePlayerSettings.ezf[24,4],0);
          compressorparam.fRatio :=StrToFloatdef(SinglePlayerSettings.ezf[24,5],0);
          BASS_FXSetParameters(fxcompressor, @compressorparam);
         end else BASS_ChannelRemoveFX(chan,fxcompressor);

        if singleplayersettings.distortion = 1 then
         begin
          BASS_ChannelRemoveFX(chan,fxdistortion);
          fxdistortion := BASS_ChannelSetFX(chan, BASS_FX_DX8_distortion, 1);
          BASS_FXGetParameters(fxdistortion, @distortionparam);
          distortionparam.fGain:=strtoFloatdef(SinglePlayerSettings.ezf[25,1],0);
          distortionparam.fEdge :=strtoFloatdef(SinglePlayerSettings.ezf[25,2],0);
          distortionparam.fPostEQCenterFrequency :=StrToFloatdef(SinglePlayerSettings.ezf[25,3],0);
          distortionparam.fPostEQBandwidth :=StrToFloatdef(SinglePlayerSettings.ezf[25,4],0);
          distortionparam.fPreLowpassCutoff :=StrToFloatdef(SinglePlayerSettings.ezf[25,5],0);
          BASS_FXSetParameters(fxdistortion, @distortionparam);
         end else BASS_ChannelRemoveFX(chan,fxdistortion);

         if singleplayersettings.phaser = 1 then
         begin
          BASS_ChannelRemoveFX(chan,fxphaser);
          fxphaser := BASS_ChannelSetFX(chan, BASS_FX_BFX_phaser, 1);
          BASS_FXGetParameters(fxphaser, @phaserparam);
          phaserparam.fDryMix:=strtoFloatdef(SinglePlayerSettings.ezf[26,1],0);
          phaserparam.fWetMix :=strtoFloatdef(SinglePlayerSettings.ezf[26,2],0);
          phaserparam.fFeedback :=StrToFloatdef(SinglePlayerSettings.ezf[26,3],0);
          phaserparam.fRate :=StrToFloatdef(SinglePlayerSettings.ezf[26,4],0);
          phaserparam.fRange :=StrToFloatdef(SinglePlayerSettings.ezf[26,5],0);
          phaserparam.fFreq :=StrToFloatdef(SinglePlayerSettings.ezf[26,6],0);
          BASS_FXSetParameters(fxphaser, @phaserparam);
         end else BASS_ChannelRemoveFX(chan,fxphaser);

         if SinglePlayerSettings.FREEVERB = 1 then
         begin
          BASS_ChannelRemoveFX(chan,fxFREEVERB);
          fxFREEVERB := BASS_ChannelSetFX(chan, BASS_FX_BFX_FREEVERB, 1);
          BASS_FXGetParameters(fxFREEVERB, @FREEVERBparam);
          FREEVERBparam.fDryMix:=strtoFloatdef(SinglePlayerSettings.ezf[27,1],0);
          FREEVERBparam.fWetMix :=strtoFloatdef(SinglePlayerSettings.ezf[27,2],0);
          FREEVERBparam.fRoomSize :=StrToFloatdef(SinglePlayerSettings.ezf[27,3],0);
          FREEVERBparam.fDamp :=StrToFloatdef(SinglePlayerSettings.ezf[27,4],0);
          FREEVERBparam.fWidth :=StrToFloatdef(SinglePlayerSettings.ezf[27,5],0);
          BASS_FXSetParameters(fxFREEVERB, @FREEVERBparam);
         end else BASS_ChannelRemoveFX(chan,fxFREEVERB);

         if singleplayersettings.autowah = 1 then
         begin
          BASS_ChannelRemoveFX(chan,fxautowah);
          fxautowah := BASS_ChannelSetFX(chan, BASS_FX_BFX_autowah, 1);
          BASS_FXGetParameters(fxautowah, @autowahparam);
          autowahparam.fDryMix:=strtoFloatdef(SinglePlayerSettings.ezf[28,1],0);
          autowahparam.fWetMix :=strtoFloatdef(SinglePlayerSettings.ezf[28,2],0);
          autowahparam.fFeedback :=StrToFloatdef(SinglePlayerSettings.ezf[28,3],0);
          autowahparam.fRate :=StrToFloatdef(SinglePlayerSettings.ezf[28,4],0);
          autowahparam.fRange :=StrToFloatdef(SinglePlayerSettings.ezf[28,5],0);
          autowahparam.fFreq :=StrToFloatdef(SinglePlayerSettings.ezf[28,6],0);
          BASS_FXSetParameters(fxautowah, @autowahparam);
         end else BASS_ChannelRemoveFX(chan,fxautowah);

        if SinglePlayerSettings.tempo<>0 then BASS_ChannelSetAttribute(chan, BASS_ATTRIB_TEMPO, strtointdef(SinglePlayerSettings.ezf[18,1],0)) else BASS_ChannelSetAttribute(chan, BASS_ATTRIB_TEMPO, 0);
        if SinglePlayerSettings.pitch<>0 then BASS_ChannelSetAttribute(chan, BASS_ATTRIB_TEMPO_PITCH, strtointdef(SinglePlayerSettings.ezf[19,1],0)) else BASS_ChannelSetAttribute(chan, BASS_ATTRIB_TEMPO_PITCH,0);
  except
         LogAndExitPlayer('Ошибка в процедуре eqapply',0,0);
  end;
end;

procedure loadcaverp.Execute;
begin
 try
 ShowPicture(0);
 loadcaver.Free;
 except
  LogAndExitPlayer('Ошибка в процедуре loadcaverp',0,0);
  loadcaver.Free;
 end;
end;


procedure ShowPicture(Index: Integer);
var PictureDescription: UnicodeString;
    PictureMime: ansistring;
    PictureData: TStream;
    PictureType: Byte;
    coverfolder:UnicodeString;
begin
 try
  coverloaded:=0;
  radiocoverloaded:=0;
  coverimg.SetSize(0, 0);
  coverimg.Clear;
  coverimgot.SetSize(0, 0);
  coverimgot.Clear;
  coverimgRadio.SetSize(0, 0);
  coverimgRadio.Clear;
  coverimgotRadio.SetSize(0, 0);
  coverimgotRadio.Clear;
  if mode=play then
   begin
  PictureFrames := thisTagv2.GetAllPictureFrames;
  if Index<PictureFrames.Count then begin
    PictureData := TMemoryStream.Create;
    TID3v2Frame(PictureFrames[Index]).GetPicture(PictureMime, PictureType, PictureDescription, PictureData);
    PictureData.Seek(0, soFromBeginning);
      try
        coverimg.LoadFromStream(PictureData);
      except
      end;
    PictureData.Free;
    coverloaded:=1;
  end else
  begin
   coverfolder:='\'+ExtractFilepath(curenttrack);
   if fileexists(UTF8Encode(coverfolder)+'cover.jpg') then begin coverimg.LoadFromFile(coverfolder+'cover.jpg');   coverloaded:=1; end else
    begin
     coverimg.SetSize(0, 0);
     coverimgot.SetSize(0, 0);
     coverloaded:=0;
    end;
  end;
   end else
   begin
   if mode=radioplay then
    begin
     if fileexists(SinglePlayerDir+SinglePlayerSettings.skindir+SinglePlayerSettings.skin+'\icons\'+radioimage) then
      begin
       coverimg.SetSize(0, 0);
       coverimgot.SetSize(0, 0);
       coverimgRadio.handle:=LoadBmp(UTF8Encode(SinglePlayerDir+SinglePlayerSettings.skindir+SinglePlayerSettings.skin+'\icons\'+radioimage));
       radiocoverloaded:=1;
      end else
      begin
       coverimgRadio.SetSize(0, 0);
       coverimgotRadio.SetSize(0, 0);
       radiocoverloaded:=0;
      end;
    end;
   end;
 loadcaver.Free;
 except
  LogAndExitPlayer('Ошибка в процедуре showpicture',0,0);
 end;
end;

procedure SingleStopPlay;
begin
 try
  if (mode=play) or (mode=radioplay) then
   begin
    SinglePlayerGUI.invalidate;
    itelmastop;
    exit;
   end;

 SinglePlay;

 except
  LogAndExitPlayer('Ошибка в процедуре itelmastopplay',0,0);
 end;
end;

procedure itelmastop;
begin
 try
  if SinglePlayerSettings.curentvol<>0 then tempvol:=SinglePlayerSettings.curentvol;
  if mode=radioplay then
    begin
     BASS_ChannelPause(radiochannel);
     mode:=paused;
     exit;
    end;
  if (SinglePlayerSettings.plavzvuk=1) and (SinglePlayerSettings.mute=0) then
    begin
      {$IFNDEF SP_STANDALONE} if (SinglePlayerUSB=1) then
      begin
        tempvol:=SinglePlayerSettings.curentvol;
        SinglePlayerSettings.curentvol:=0;
      end
      else
      {$ENDIF}
      begin
        while SinglePlayerSettings.curentvol>0 do
        begin
         SinglePlayerSettings.curentvol:=SinglePlayerSettings.curentvol-1;
         BASS_ChannelSetAttribute(channel,BASS_ATTRIB_VOL,SinglePlayerSettings.curentvol/10);
         sleep(30);
        end;
      end;
    end;
  if mode=play then
    begin
     SinglePlayerSettings.curpos:=bass_ChannelGetPosition(channel,0);
     if (SinglePlayerSettings.ciclepls=0) and (SinglePlayerSettings.playedtrack=SinglePlayerSettings.kolltrack) and
     (BASS_ChannelBytes2Seconds(Channel, BASS_ChannelGetLength(Channel,0))-BASS_ChannelBytes2Seconds(Channel, BASS_ChannelGetPosition(Channel,0))=0) then SinglePlayerSettings.curpos:=-1;
     BASS_ChannelStop(Channel);
     //BASS_StreamFree(Channel);
    end;
    SinglePlayerGUI.playertimer.Enabled:=false;
    mode:=Paused;
 except
  LogAndExitPlayer('Ошибка в процедуре itelmastop',0,0);
 end;
end;

procedure SinglePlay;
begin
 try
  if singleplayersettings.startautoplay=1 then
   begin
    if (mode=started) and (singleplayersettings.lasturl<>'') and (pos('http',singleplayersettings.lasturl)=1) then
     begin
      curenttrack:=singleplayersettings.lasturl;
      iradioplay(curenttrack);
      mode:=radioplay;
      exit;
     end;
   end;

  if (pos('http',curenttrack)<>1) then
   begin
    if (mode=stop) or (mode=started) or (mode=paused) then
      begin
       if curenttrack='' then curenttrack:=track[singleplayersettings.playedtrack];
       timestartplay:=0;
        if pos('#ts',curenttrack)<>0 then
         begin
          timestartplay:=(strtointdef(copy(curenttrack,pos('#ts',curenttrack)+3, pos('st#',curenttrack)-pos('#ts',curenttrack)-9),0)*60)+strtointdef(copy(curenttrack,pos('#ts',curenttrack)+6, pos('st#',curenttrack)-pos('#ts',curenttrack)-9),0);
          curenttrack:=copy(curenttrack,pos('st#',curenttrack)+3,length(curenttrack)-pos('st#',curenttrack)-2);
         end;
       SinglePlayerGUI.invalidate;
       if curentpage='playlist' then begin curenttrack:=track[SinglePlayerSettings.playedtrack]; SinglePlayerSettings.curpos:=-1; end;
       if (tempvol<>0) and (SinglePlayerSettings.plavzvuk=1) and (SinglePlayerSettings.curentvol=0) and (SinglePlayerSettings.mute=0) then
         begin
          SinglePlayerSettings.curentvol:=SinglePlayerSettings.curentvol+1;
          BASS_ChannelSetAttribute(channel,BASS_ATTRIB_VOL,SinglePlayerSettings.curentvol/10);
         end;
       if fileexists(curenttrack)=true then itelmaplay(curenttrack) else exit;
       if (tempvol<>0) and (SinglePlayerSettings.plavzvuk=1) and (SinglePlayerSettings.mute=0) then
         begin
          while SinglePlayerSettings.curentvol<tempvol do
           begin
            SinglePlayerSettings.curentvol:=SinglePlayerSettings.curentvol+1;
            BASS_ChannelSetAttribute(channel,BASS_ATTRIB_VOL,SinglePlayerSettings.curentvol/10);
            sleep(15);
           end;
          tempvol:=0;
         end;
      exit;
      end;
   end else
   begin
    if mode=paused then
      begin
       SinglePlayerGUI.invalidate;
       if pos('http',curenttrack)=1 then BASS_ChannelPlay(radiochannel,false) else exit;
       mode:=radioplay;
       exit;
      end;
   end;

 except
  LogAndExitPlayer('Ошибка в процедуре itelmastopplay',0,0);
 end;
end;

procedure eq;
var
  X1,X2,Y1,Y2,i,TFX,TFY,TZX,TZY,eqgenX,eqgenY:integer;
begin
 try
 SinglePlayerGUI.Canvas.Font.Color:=plset.curvolcolor;
 SinglePlayerGUI.Canvas.Font.Size:=plset.curvolsize;
 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.curvolleft,curvol,1),plset.curvoltop,curvol);
 X1:=plset.equpleft;
 Y1:=plset.equptop;
 X2:=plset.eqdownleft;
 Y2:=plset.eqdowntop;
 TFX:=plset.eqftextleft;
 TFY:=plset.eqftexttop;
 TZX:=plset.eqztextleft;
 TZY:=plset.eqztexttop;
 eqgenX:=myalign(plset.eqcurgenleft,copy(genremass[curentgenre,1],1,pos(';',genremass[curentgenre,1])-1),1);
 eqgenY:=plset.eqcurgentop;
 for i:=1 to 13 do
  begin
 SinglePlayerGUI.Canvas.Draw(X1, Y1, playericon[getindexiconexec('equp')]);
 SinglePlayerGUI.Canvas.Draw(X2, Y2, playericon[getindexiconexec('eqdown')]);
 SinglePlayerGUI.Canvas.Draw(X1+plset.eqwgeelsmX, coordeqwheel(strtointdef(SinglePlayerSettings.ezf[i,1],0))+plset.eqwgeelsmY, playericon[getindexiconexec('eqwheel')]);
 SinglePlayerGUI.Canvas.Font.Color:=plset.eqftextcolor;
 SinglePlayerGUI.Canvas.Font.Size:=plset.eqftextsize;
 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),TFX,TFY,SinglePlayerSettings.ezf[i,3]);
 SinglePlayerGUI.Canvas.Font.Color:=plset.eqztextcolor;
 SinglePlayerGUI.Canvas.Font.Size:=plset.eqztextsize;
 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),TZX,TZY,SinglePlayerSettings.ezf[i,1]);
 eqfcor[i,1]:=X1;
 eqfcor[i,2]:=Y1;
 eqfcor[i,3]:=X2;
 eqfcor[i,4]:=Y2;
 eqfcor[i,5]:=TZX-10;
 eqfcor[i,6]:=TZY;
 eqfcor[i,7]:=SinglePlayerGUI.Canvas.TextWidth(SinglePlayerSettings.ezf[i,1])+20;
 eqfcor[i,8]:=SinglePlayerGUI.Canvas.Textheight(SinglePlayerSettings.ezf[i,1]);

 if X1+plset.eqsmeshX1 > SinglePlayerGUI.Width-20 then
   begin
    X1:=plset.equpleft;
    Y1:=Y1+plset.eqsmeshY1;
    X2:=plset.eqdownleft;
    Y2:=Y2+plset.eqsmeshY1;
    TFY:=TFY+plset.eqsmeshY1;
    TZY:=TZY+plset.eqsmeshY1;
    TFX:=plset.eqftextleft;
    TZX:=plset.eqztextleft;
   end;

 X1:=X1+plset.eqsmeshX1;
 X2:=X2+plset.eqsmeshX2;
 TFX:=TFX+plset.eqsmeshX1;
 TZX:=TZX+plset.eqsmeshX1;
  end;
 SinglePlayerGUI.Canvas.Font.Color:=plset.eqcurgencolor;
 SinglePlayerGUI.Canvas.Font.Size:=plset.eqcurgensize;
 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),eqgenX,eqgenY,copy(genremass[curentgenre,1],1,pos(';',genremass[curentgenre,1])-1));

 except
  LogAndExitPlayer('Ошибка в процедуре eq',0,0);
 end;
end;

function coordeqwheel(zyacheq:integer):integer;
begin
result:=100;

case zyacheq of
15: begin result:=125; exit; end;
14: begin result:=130; exit; end;
13: begin result:=135; exit; end;
12: begin result:=140; exit; end;
11: begin result:=145; exit; end;
10: begin result:=150; exit; end;
9: begin result:=155; exit; end;
8: begin result:=160; exit; end;
7: begin result:=165; exit; end;
6: begin result:=170; exit; end;
5: begin result:=175; exit; end;
4: begin result:=180; exit; end;
3: begin result:=185; exit; end;
2: begin result:=190; exit; end;
1: begin result:=195; exit; end;
0: begin result:=200; exit; end;
-1: begin result:=205; exit; end;
-2: begin result:=210; exit; end;
-3: begin result:=215; exit; end;
-4: begin result:=220; exit; end;
-5: begin result:=225; exit; end;
-6: begin result:=230; exit; end;
-7: begin result:=235; exit; end;
-8: begin result:=240; exit; end;
-9: begin result:=245; exit; end;
-10: begin result:=250; exit; end;
-11: begin result:=255; exit; end;
-12: begin result:=260; exit; end;
-13: begin result:=265; exit; end;
-14: begin result:=270; exit; end;
-15: begin result:=275; exit; end;
end;
end;

function znacheqwgeel(coord:integer):integer;
begin
 result:=0;
 if coord<=129 then begin result:=15; exit; end;
 if (coord>=130) and (coord<=134) then begin result:=14; exit; end;
 if (coord>=135) and (coord<=139) then begin result:=13; exit; end;
 if (coord>=140) and (coord<=144) then begin result:=12; exit; end;
 if (coord>=145) and (coord<=149) then begin result:=11; exit; end;
 if (coord>=150) and (coord<=154) then begin result:=10; exit; end;
 if (coord>=155) and (coord<=159) then begin result:=9; exit; end;
 if (coord>=160) and (coord<=164) then begin result:=8; exit; end;
 if (coord>=165) and (coord<=169) then begin result:=7; exit; end;
 if (coord>=170) and (coord<=174) then begin result:=6; exit; end;
 if (coord>=175) and (coord<=179) then begin result:=5; exit; end;
 if (coord>=180) and (coord<=184) then begin result:=4; exit; end;
 if (coord>=185) and (coord<=189) then begin result:=3; exit; end;
 if (coord>=190) and (coord<=194) then begin result:=2; exit; end;
 if (coord>=195) and (coord<=199) then begin result:=1; exit; end;
 if (coord>=200) and (coord<=204) then begin result:=0; exit; end;
 if (coord>=205) and (coord<=209) then begin result:=-1; exit; end;
 if (coord>=210) and (coord<=214) then begin result:=-2; exit; end;
 if (coord>=215) and (coord<=219) then begin result:=-3; exit; end;
 if (coord>=220) and (coord<=224) then begin result:=-4; exit; end;
 if (coord>=225) and (coord<=229) then begin result:=-5; exit; end;
 if (coord>=230) and (coord<=234) then begin result:=-6; exit; end;
 if (coord>=235) and (coord<=239) then begin result:=-7; exit; end;
 if (coord>=240) and (coord<=244) then begin result:=-8; exit; end;
 if (coord>=245) and (coord<=249) then begin result:=-9; exit; end;
 if (coord>=250) and (coord<=254) then begin result:=-10; exit; end;
 if (coord>=255) and (coord<=259) then begin result:=-11; exit; end;
 if (coord>=260) and (coord<=264) then begin result:=-12; exit; end;
 if (coord>=265) and (coord<=269) then begin result:=-13; exit; end;
 if (coord>=270) and (coord<=274) then begin result:=-14; exit; end;
 if coord>=275 then begin result:=-15; exit; end;
end;

procedure playlist;
var
 i,Ystr,xtrack:integer;
 srtrack:string;
begin
 try
Ystr:=plset.playlisttexttop;
SinglePlayerGUI.canvas.pen.Color:=plset.recttrackcolor;
 SinglePlayerGUI.Canvas.Font.Color:=plset.playlistcurplscolor;
 SinglePlayerGUI.Canvas.Font.Size:=plset.playlistcurplssize;
 if SinglePlayerSettings.curentplaylist<>kollpls then SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.playlistcurplsleft,getfromlangpack('playlist')+' '+inttostr(SinglePlayerSettings.curentplaylist),1),plset.playlistcurplstop,getfromlangpack('playlist')+' '+inttostr(SinglePlayerSettings.curentplaylist)) else
 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.playlistcurplsleft,getfromlangpack('favorites'),1),plset.playlistcurplstop,getfromlangpack('favorites'));
 SinglePlayerGUI.Canvas.Font.Color:=plset.playlisttextcolor;
 SinglePlayerGUI.Canvas.Font.Size:=plset.playlisttextsize;
  if (playlistferstopen=1) and (SinglePlayerSettings.kolltrack<>0) then        {определяем текущую страницу плейлиста в зависимости от текущего трека}
  begin
  ee:=plset.playlistkolltrack;
  if SinglePlayerSettings.playedtrack>SinglePlayerSettings.kolltrack then SinglePlayerSettings.playedtrack:=SinglePlayerSettings.kolltrack;
  playlistferstopen:=0;
  curplspage:=SinglePlayerSettings.playedtrack div ee;
  if curplspage*ee<SinglePlayerSettings.playedtrack then inc(curplspage);
  if curplspage<1 then curplspage:=1;
  end;
if SinglePlayerSettings.kolltrack<>0 then
 begin
  SinglePlayerGUI.Canvas.Font.Color:=plset.plskolltrackinfocolor;
  SinglePlayerGUI.Canvas.Font.Size:=plset.plskolltrackinfosize;
  SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.plskolltrackinfoleft,inttostr(SinglePlayerSettings.kolltrack)+' '+getfromlangpack('songs'),1),plset.plskolltrackinfotop,inttostr(SinglePlayerSettings.kolltrack)+' '+getfromlangpack('songs'));
  kolplspage:=SinglePlayerSettings.kolltrack div ee;
  if kolplspage*ee<SinglePlayerSettings.kolltrack then inc(kolplspage);
  if kolplspage<1 then kolplspage:=1;
  if curplspage<1 then curplspage:=kolplspage;
  if curplspage>kolplspage then curplspage:=1;
  if (AfterSwipe=0) then if mousestate=0 then nachpls:=curplspage*ee-(ee-1) else if SinglePlayerSettings.wheelone=1 then nachpls:=curplspage*ee-(ee-1);
  konpls:=nachpls+ee-1;
  if konpls>SinglePlayerSettings.kolltrack then konpls:=SinglePlayerSettings.kolltrack;
  SinglePlayerGUI.Canvas.Font.Color:=plset.plspagesinfocolor;
  SinglePlayerGUI.Canvas.Font.Size:=plset.plspagesinfosize;
  SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.plspagesinfoleft,getfromlangpack('page')+inttostr(curplspage)+' '+getfromlangpack('of')+' '+inttostr(kolplspage),1),plset.plspagesinfotop,getfromlangpack('page')+inttostr(curplspage)+' '+getfromlangpack('of')+' '+inttostr(kolplspage));
  SinglePlayerGUI.Canvas.Font.Color:=plset.playlisttextcolor;
  SinglePlayerGUI.Canvas.Font.Size:=plset.playlisttextsize;
  for i:=nachpls to konpls do
    begin
     SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.playlisttextleft,inttostr(i),1),Ystr,inttostr(i));
     SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.playlisttextleft,extractfilename(ChangeFileExt(UTF8Encode(track[i]),'')),1)+SinglePlayerGUI.Canvas.Textwidth(inttostr(i))+30,Ystr,extractfilename(ChangeFileExt(UTF8Encode(track[i]),'')),textstyle );
     plstrackcor[i,1]:=plset.noticonpoleleft;
     plstrackcor[i,2]:=Ystr-(SinglePlayerGUI.Canvas.Textheight(inttostr(i))div 2);
     plstrackcor[i,3]:=plset.noticonpolerigth;
     plstrackcor[i,4]:=Ystr+SinglePlayerGUI.Canvas.Textheight(inttostr(i))+(SinglePlayerGUI.Canvas.Textheight(inttostr(i))div 2);
     if getindexicon('plsdeldisk.bmp')<>0 then
     begin
     xtrack:=SinglePlayerGUI.Width-seticons[getindexicon('plsdeldisk.bmp')].width-plset.deldiskiconsm;      {кнопка удалить трек с диска}
     plstrackcor[i,5]:=xtrack;
     plstrackcor[i,6]:=Ystr+plset.deldisktracktop;
     plstrackcor[i,7]:=xtrack+seticons[getindexicon('plsdeldisk.bmp')].width;
     plstrackcor[i,8]:=Ystr+seticons[getindexicon('plsdeldisk.bmp')].height+plset.deldisktracktop;
     SinglePlayerGUI.Canvas.Draw(xtrack,Ystr+plset.deldisktracktop,playericon[getindexicon('plsdeldisk.bmp')]);
     end;
      if getindexicon('plsdel.bmp')<>0 then
      begin
     xtrack:=xtrack-seticons[getindexicon('plsdel.bmp')].width-plset.deliconsm;                   {кнопка удалить трек с плейлиста}
     plstrackcor[i,9]:=xtrack;
     plstrackcor[i,10]:=Ystr+plset.deltracktop;
     plstrackcor[i,11]:=xtrack+seticons[getindexicon('plsdel.bmp')].width;
     plstrackcor[i,12]:=Ystr+seticons[getindexicon('plsdel.bmp')].height+plset.deltracktop;
     SinglePlayerGUI.Canvas.Draw(xtrack,Ystr+plset.deltracktop,playericon[getindexicon('plsdel.bmp')]);
     end;
       if getindexicon('plsfav.bmp')<>0 then
       begin
     xtrack:=xtrack-seticons[getindexicon('plsfav.bmp')].width-plset.faviconsm;                   {добавить трек в фовариты}
     plstrackcor[i,21]:=xtrack;
     plstrackcor[i,22]:=Ystr+plset.favtracktop;
     plstrackcor[i,23]:=xtrack+seticons[getindexicon('plsfav.bmp')].width;
     plstrackcor[i,24]:=Ystr+seticons[getindexicon('plsfav.bmp')].height+plset.favtracktop;
     SinglePlayerGUI.Canvas.Draw(xtrack,Ystr+plset.favtracktop,playericon[getindexicon('plsfav.bmp')]);
       end;
     if pos('st#',track[i])<>0 then srtrack:=copy(track[i],pos('st#',track[i])+3,length(track[i])-pos('st#',track[i])-2) else srtrack:=track[i];
      if (srtrack=curenttrack) and (i=npltr) and (mode=play) then
       begin
       SinglePlayerGUI.Canvas.Brush.Color:=plset.vidplcolor;   {проигрываемый}
       SinglePlayerGUI.Canvas.rectangle(classes.Rect(plset.vidpltrackleft,Ystr+plset.vidpltracktop,plset.vidpltrackwidth,Ystr+plset.vidpltrackheight+plset.vidpltracktop));
       SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.playlisttextleft,inttostr(i),1),Ystr,inttostr(i));
       SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.playlisttextleft,extractfilename(ChangeFileExt(UTF8Encode(track[i]),'')),1)+SinglePlayerGUI.Canvas.Textwidth(inttostr(i))+30,Ystr,extractfilename(ChangeFileExt(UTF8Encode(track[i]),'')),textstyle );
       plstrackcor[i,1]:=plset.noticonpoleleft;
       plstrackcor[i,2]:=Ystr-(SinglePlayerGUI.Canvas.Textheight(inttostr(i))div 2);
       plstrackcor[i,3]:=plset.noticonpolerigth;
       plstrackcor[i,4]:=Ystr+SinglePlayerGUI.Canvas.Textheight(inttostr(i))+(SinglePlayerGUI.Canvas.Textheight(inttostr(i))div 2);
        if getindexicon('plsdeldisk.bmp')<>0 then
       begin
       xtrack:=SinglePlayerGUI.Width-seticons[getindexicon('plsdeldisk.bmp')].width-plset.deldiskiconsm;
       plstrackcor[i,5]:=xtrack;
       plstrackcor[i,6]:=Ystr+plset.deldisktracktop;
       plstrackcor[i,7]:=xtrack+seticons[getindexicon('plsdeldisk.bmp')].width;
       plstrackcor[i,8]:=Ystr+seticons[getindexicon('plsdeldisk.bmp')].height+plset.deldisktracktop;
       SinglePlayerGUI.Canvas.Draw(xtrack,Ystr+plset.deldisktracktop,playericon[getindexicon('plsdeldisk.bmp')]);
       end;
         if getindexicon('plsdel.bmp')<>0 then
        begin
       xtrack:=xtrack-seticons[getindexicon('plsdel.bmp')].width-plset.deliconsm;
       plstrackcor[i,9]:=xtrack;
       plstrackcor[i,10]:=Ystr+plset.deltracktop;
       plstrackcor[i,11]:=xtrack+seticons[getindexicon('plsdel.bmp')].width;
       plstrackcor[i,12]:=Ystr+seticons[getindexicon('plsdel.bmp')].height+plset.deltracktop;
       SinglePlayerGUI.Canvas.Draw(xtrack,Ystr+plset.deltracktop,playericon[getindexicon('plsdel.bmp')]);

        end;
        if getindexicon('plsfav.bmp')<>0 then
        begin
       xtrack:=xtrack-seticons[getindexicon('plsfav.bmp')].width-plset.faviconsm;                   {добавить трек в фовариты}
       plstrackcor[i,21]:=xtrack;
       plstrackcor[i,22]:=Ystr+plset.favtracktop;
       plstrackcor[i,23]:=xtrack+seticons[getindexicon('plsfav.bmp')].width;
       plstrackcor[i,24]:=Ystr+seticons[getindexicon('plsfav.bmp')].height+plset.favtracktop;
       SinglePlayerGUI.Canvas.Draw(xtrack,Ystr+plset.favtracktop,playericon[getindexicon('plsfav.bmp')]);
        end;
        if getindexicon('plsdown.bmp')<>0 then
        begin
       xtrack:=xtrack-seticons[getindexicon('plsdown.bmp')].width-plset.downiconsm;
       plstrackcor[i,13]:=xtrack;
       plstrackcor[i,14]:=Ystr+plset.downtracktop;
       plstrackcor[i,15]:=xtrack+seticons[getindexicon('plsdown.bmp')].width;
       plstrackcor[i,16]:=Ystr+seticons[getindexicon('plsdown.bmp')].height+plset.downtracktop;
       SinglePlayerGUI.Canvas.Draw(xtrack,Ystr+plset.downtracktop,playericon[getindexicon('plsdown.bmp')]);
       end;
        if getindexicon('plsup.bmp')<>0 then
        begin
       xtrack:=xtrack-seticons[getindexicon('plsup.bmp')].width-plset.upiconsm;
       plstrackcor[i,17]:=xtrack;
       plstrackcor[i,18]:=Ystr+plset.uptracktop;
       plstrackcor[i,19]:=xtrack+seticons[getindexicon('plsup.bmp')].width;
       plstrackcor[i,20]:=Ystr+seticons[getindexicon('plsup.bmp')].height+plset.uptracktop;
       SinglePlayerGUI.Canvas.Draw(xtrack,Ystr+plset.uptracktop,playericon[getindexicon('plsup.bmp')]);
        end;
       end;

      if (i = SinglePlayerSettings.playedtrack) and (i<>npltr) then
       begin
        SinglePlayerGUI.Canvas.Brush.Color:=plset.vidcolor;    {выбранный}
        SinglePlayerGUI.Canvas.rectangle(classes.Rect(plset.vidtrackleft,Ystr+plset.vidtracktop,plset.vidtrackwidth,Ystr+plset.vidtrackheight+plset.vidtracktop));
        SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.playlisttextleft,inttostr(i),1),Ystr,inttostr(i));
        SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.playlisttextleft,extractfilename(ChangeFileExt(UTF8Encode(track[i]),'')),1)+SinglePlayerGUI.Canvas.Textwidth(inttostr(i))+30,Ystr,extractfilename(ChangeFileExt( UTF8Encode(track[i]),'')),textstyle );
        plstrackcor[i,1]:=plset.noticonpoleleft;
        plstrackcor[i,2]:=Ystr-(SinglePlayerGUI.Canvas.Textheight(inttostr(i))div 2);
        plstrackcor[i,3]:=plset.noticonpolerigth;
        plstrackcor[i,4]:=Ystr+SinglePlayerGUI.Canvas.Textheight(inttostr(i))+(SinglePlayerGUI.Canvas.Textheight(inttostr(i))div 2);
        if getindexicon('plsdeldisk.bmp')<>0 then
        begin
        xtrack:=SinglePlayerGUI.Width-seticons[getindexicon('plsdeldisk.bmp')].width-plset.deldiskiconsm;
        plstrackcor[i,5]:=xtrack;
        plstrackcor[i,6]:=Ystr+plset.deldisktracktop;
        plstrackcor[i,7]:=xtrack+seticons[getindexicon('plsdeldisk.bmp')].width;
        plstrackcor[i,8]:=Ystr+seticons[getindexicon('plsdeldisk.bmp')].height+plset.deldisktracktop;
        SinglePlayerGUI.Canvas.Draw(xtrack,Ystr+plset.deldisktracktop,playericon[getindexicon('plsdeldisk.bmp')]);
        end;
        if getindexicon('plsdel.bmp')<>0 then
        begin
        xtrack:=xtrack-seticons[getindexicon('plsdel.bmp')].width-plset.deliconsm;
        plstrackcor[i,9]:=xtrack;
        plstrackcor[i,10]:=Ystr+plset.deltracktop;
        plstrackcor[i,11]:=xtrack+seticons[getindexicon('plsdel.bmp')].width;
        plstrackcor[i,12]:=Ystr+seticons[getindexicon('plsdel.bmp')].height+plset.deltracktop;
        SinglePlayerGUI.Canvas.Draw(xtrack,Ystr+plset.deltracktop,playericon[getindexicon('plsdel.bmp')]);
        end;
        if getindexicon('plsfav.bmp')<>0 then
        begin
        xtrack:=xtrack-seticons[getindexicon('plsfav.bmp')].width-plset.faviconsm;                   {добавить трек в фовариты}
        plstrackcor[i,21]:=xtrack;
        plstrackcor[i,22]:=Ystr+plset.favtracktop;
        plstrackcor[i,23]:=xtrack+seticons[getindexicon('plsfav.bmp')].width;
        plstrackcor[i,24]:=Ystr+seticons[getindexicon('plsfav.bmp')].height+plset.favtracktop;
        SinglePlayerGUI.Canvas.Draw(xtrack,Ystr+plset.favtracktop,playericon[getindexicon('plsfav.bmp')]);
        end;
        if getindexicon('plsdown.bmp')<>0 then
        begin
        xtrack:=xtrack-seticons[getindexicon('plsdown.bmp')].width-plset.downiconsm;
        plstrackcor[i,13]:=xtrack;
        plstrackcor[i,14]:=Ystr+plset.downtracktop;
        plstrackcor[i,15]:=xtrack+seticons[getindexicon('plsdown.bmp')].width;
        plstrackcor[i,16]:=Ystr+seticons[getindexicon('plsdown.bmp')].height+plset.downtracktop;
        SinglePlayerGUI.Canvas.Draw(xtrack,Ystr+plset.downtracktop,playericon[getindexicon('plsdown.bmp')]);
        end;
        if getindexicon('plsup.bmp')<>0 then
        begin
        xtrack:=xtrack-seticons[getindexicon('plsup.bmp')].width-plset.upiconsm;
        plstrackcor[i,17]:=xtrack;
        plstrackcor[i,18]:=Ystr+plset.uptracktop;
        plstrackcor[i,19]:=xtrack+seticons[getindexicon('plsup.bmp')].width;
        plstrackcor[i,20]:=Ystr+seticons[getindexicon('plsup.bmp')].height+plset.uptracktop;
        SinglePlayerGUI.Canvas.Draw(xtrack,Ystr+plset.uptracktop,playericon[getindexicon('plsup.bmp')]);
        end;
       end;
     Ystr:=Ystr+plset.trackvertsm;
    end;
 end;
 except
  LogAndExitPlayer('Ошибка в процедуре playlist',0,0);
 end;
end;

procedure msgflashadd(usbstr:string);
begin
 try
 SinglePlayerGUI.canvas.pen.Color:=$0000FF;
 SinglePlayerGUI.canvas.Brush.Color:=$000000;
 SinglePlayerGUI.canvas.RoundRect(30,130,770,350,30,20);
 SinglePlayerGUI.canvas.Brush.Color:=$FFA500;
 SinglePlayerGUI.canvas.RoundRect(50,200,290,250,30,20);
 SinglePlayerGUI.canvas.RoundRect(310,200,550,250,30,20);
 SinglePlayerGUI.canvas.RoundRect(570,200,750,250,30,20);
 SinglePlayerGUI.canvas.Font.Color:=$00FFFF;
 SinglePlayerGUI.Canvas.Font.Size:=16;
 SinglePlayerGUI.Canvas.Font.Bold:=true;
 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign('1:center:800',getfromlangpack('drivecon')+usbstr,1),150,getfromlangpack('drivecon')+usbstr);
 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign('1:center:800','<<  '+getfromlangpack('playlist')+' '+inttostr(SinglePlayerSettings.curentplaylist)+'  >>',1),280,'<<  '+getfromlangpack('playlist')+' '+inttostr(SinglePlayerSettings.curentplaylist)+'  >>');
 msgaddflashstrleftX:=myalign('1:center:800','<<  '+getfromlangpack('playlist')+' '+inttostr(SinglePlayerSettings.curentplaylist)+'  >>',1);
 msgaddflashstrleftX2:=myalign('1:center:800','<<  '+getfromlangpack('playlist')+' '+inttostr(SinglePlayerSettings.curentplaylist)+'  >>',1)+SinglePlayerGUI.Canvas.TextWidth('<<  ');
 msgaddflashstrleftY:=280;
 msgaddflashstrleftY2:=300;

 msgaddflashstrrgX:=myalign('1:center:800','<<  '+getfromlangpack('playlist')+' '+inttostr(SinglePlayerSettings.curentplaylist)+'  >>',1)+SinglePlayerGUI.Canvas.TextWidth('<<  '+getfromlangpack('playlist')+' '+inttostr(SinglePlayerSettings.curentplaylist)+'  >>')-SinglePlayerGUI.Canvas.TextWidth('  >>');
 msgaddflashstrrgX2:=myalign('1:center:800','<<  '+getfromlangpack('playlist')+' '+inttostr(SinglePlayerSettings.curentplaylist)+'  >>',1)+SinglePlayerGUI.Canvas.TextWidth('<<  '+getfromlangpack('playlist')+' '+inttostr(SinglePlayerSettings.curentplaylist)+'  >>');
 msgaddflashstrrgY:=280;
 msgaddflashstrrgY2:=300;
 SinglePlayerGUI.Canvas.Font.Bold:=false;

 SinglePlayerGUI.canvas.Font.Color:=$000000;
 SinglePlayerGUI.Canvas.Font.Size:=15;
 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign('50:center:290',getfromlangpack('addtopls'),1),210,getfromlangpack('addtopls'));
 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign('310:center:550',getfromlangpack('createpls'),1),210,getfromlangpack('createpls'));
 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign('570:center:750',getfromlangpack('cancel'),1),210,getfromlangpack('cancel'));

 msgaddflashbt1X:=50;
 msgaddflashbt1X2:=290;
 msgaddflashbt1Y:=200;
 msgaddflashbt1Y2:=250;

 msgaddflashbt2X:=310;
 msgaddflashbt2X2:=550;
 msgaddflashbt2Y:=200;
 msgaddflashbt2Y2:=250;

 except
  LogAndExitPlayer('Ошибка в процедуре msgflashadd',0,0);
 end;
end;

function delbanner(trackbanner:string):string;
var
 i:integer;
begin
 if SinglePlayerSettings.removebanner=1 then
  begin
   for i:=1 to kollbanner do if bannermass[i]<>'' then
       begin
        if pos(bannermass[i],trackbanner)<>0 then while pos(bannermass[i],trackbanner)<>0 do delete(trackbanner,pos(bannermass[i],trackbanner),length(bannermass[i]));
       end;
 {---------------- поиск адесов сайтов ----------------------}
 while (pos('http://',trackbanner)<>0) and (pos('.ru/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('http://',trackbanner),pos('.ru/',trackbanner)-pos('http://',trackbanner)+length('.ru/')))=0) do
 delete(trackbanner,pos('http://',trackbanner),pos('.ru/',trackbanner)-pos('http://',trackbanner)+length('.ru/'));
 while (pos('http://',trackbanner)<>0) and (pos('.ru',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('http://',trackbanner),pos('.ru',trackbanner)-pos('http://',trackbanner)+length('.ru')))=0) do
 delete(trackbanner,pos('http://',trackbanner),pos('.ru',trackbanner)-pos('http://',trackbanner)+length('.ru'));
 while (pos('https://',trackbanner)<>0) and (pos('.ru/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('https://',trackbanner),pos('.ru/',trackbanner)-pos('https://',trackbanner)+length('.ru/')))=0) do
 delete(trackbanner,pos('https://',trackbanner),pos('.ru/',trackbanner)-pos('https://',trackbanner)+length('.ru/'));
 while (pos('https://',trackbanner)<>0) and (pos('.ru',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('https://',trackbanner),pos('.ru',trackbanner)-pos('https://',trackbanner)+length('.ru')))=0) do
 delete(trackbanner,pos('https://',trackbanner),pos('.ru',trackbanner)-pos('https://',trackbanner)+length('.ru'));
 while (pos('www',trackbanner)<>0) and (pos('.ru/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('www',trackbanner),pos('.ru/',trackbanner)-pos('www',trackbanner)+length('.ru/')))=0) do
 delete(trackbanner,pos('www',trackbanner),pos('.ru/',trackbanner)-pos('www',trackbanner)+length('.ru/'));
 while (pos('www',trackbanner)<>0) and (pos('.ru',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('www',trackbanner),pos('.ru',trackbanner)-pos('www',trackbanner)+length('.ru')))=0) do
 delete(trackbanner,pos('www',trackbanner),pos('.ru',trackbanner)-pos('www',trackbanner)+length('.ru'));

 while (pos('http://',trackbanner)<>0) and (pos('.com/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('http://',trackbanner),pos('.com/',trackbanner)-pos('http://',trackbanner)+length('.com/')))=0) do
 delete(trackbanner,pos('http://',trackbanner),pos('.com/',trackbanner)-pos('http://',trackbanner)+length('.com/'));
 while (pos('http://',trackbanner)<>0) and (pos('.com',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('http://',trackbanner),pos('.com',trackbanner)-pos('http://',trackbanner)+length('.com')))=0) do
 delete(trackbanner,pos('http://',trackbanner),pos('.com',trackbanner)-pos('http://',trackbanner)+length('.com'));
 while (pos('https://',trackbanner)<>0) and (pos('.com/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('https://',trackbanner),pos('.com/',trackbanner)-pos('https://',trackbanner)+length('.com/')))=0) do
 delete(trackbanner,pos('https://',trackbanner),pos('.com/',trackbanner)-pos('https://',trackbanner)+length('.com/'));
 while (pos('https://',trackbanner)<>0) and (pos('.com',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('https://',trackbanner),pos('.com',trackbanner)-pos('https://',trackbanner)+length('.com')))=0) do
 delete(trackbanner,pos('https://',trackbanner),pos('.com',trackbanner)-pos('https://',trackbanner)+length('.com'));
 while (pos('www',trackbanner)<>0) and (pos('.com/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('www',trackbanner),pos('.com/',trackbanner)-pos('www',trackbanner)+length('.com/')))=0) do
 delete(trackbanner,pos('www',trackbanner),pos('.com/',trackbanner)-pos('www',trackbanner)+length('.com/'));
 while (pos('www',trackbanner)<>0) and (pos('.com',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('www',trackbanner),pos('.com',trackbanner)-pos('www',trackbanner)+length('.com')))=0) do
 delete(trackbanner,pos('www',trackbanner),pos('.com',trackbanner)-pos('www',trackbanner)+length('.com'));

 while (pos('http://',trackbanner)<>0) and (pos('.net/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('http://',trackbanner),pos('.net/',trackbanner)-pos('http://',trackbanner)+length('.net/')))=0) do
 delete(trackbanner,pos('http://',trackbanner),pos('.net/',trackbanner)-pos('http://',trackbanner)+length('.net/'));
 while (pos('http://',trackbanner)<>0) and (pos('.net',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('http://',trackbanner),pos('.net',trackbanner)-pos('http://',trackbanner)+length('.net')))=0) do
 delete(trackbanner,pos('http://',trackbanner),pos('.net',trackbanner)-pos('http://',trackbanner)+length('.net'));
 while (pos('https://',trackbanner)<>0) and (pos('.net/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('https://',trackbanner),pos('.net/',trackbanner)-pos('https://',trackbanner)+length('.net/')))=0) do
 delete(trackbanner,pos('https://',trackbanner),pos('.net/',trackbanner)-pos('https://',trackbanner)+length('.net/'));
 while (pos('https://',trackbanner)<>0) and (pos('.net',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('https://',trackbanner),pos('.net',trackbanner)-pos('https://',trackbanner)+length('.net')))=0) do
 delete(trackbanner,pos('https://',trackbanner),pos('.net',trackbanner)-pos('https://',trackbanner)+length('.net'));
 while (pos('www',trackbanner)<>0) and (pos('.net/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('www',trackbanner),pos('.net/',trackbanner)-pos('www',trackbanner)+length('.net/')))=0) do
 delete(trackbanner,pos('www',trackbanner),pos('.net/',trackbanner)-pos('www',trackbanner)+length('.net/'));
 while (pos('www',trackbanner)<>0) and (pos('.net',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('www',trackbanner),pos('.net',trackbanner)-pos('www',trackbanner)+length('.net')))=0) do
 delete(trackbanner,pos('www',trackbanner),pos('.net',trackbanner)-pos('www',trackbanner)+length('.net'));

 while (pos('http://',trackbanner)<>0) and (pos('.рф/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('http://',trackbanner),pos('.рф/',trackbanner)-pos('http://',trackbanner)+length('.рф/')))=0) do
 delete(trackbanner,pos('http://',trackbanner),pos('.рф/',trackbanner)-pos('http://',trackbanner)+length('.рф/'));
 while (pos('http://',trackbanner)<>0) and (pos('.рф',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('http://',trackbanner),pos('.рф',trackbanner)-pos('http://',trackbanner)+length('.рф')))=0) do
 delete(trackbanner,pos('http://',trackbanner),pos('.рф',trackbanner)-pos('http://',trackbanner)+length('.рф'));
 while (pos('https://',trackbanner)<>0) and (pos('.рф/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('https://',trackbanner),pos('.рф/',trackbanner)-pos('https://',trackbanner)+length('.рф/')))=0) do
 delete(trackbanner,pos('https://',trackbanner),pos('.рф/',trackbanner)-pos('https://',trackbanner)+length('.рф/'));
 while (pos('https://',trackbanner)<>0) and (pos('.рф',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('https://',trackbanner),pos('.рф',trackbanner)-pos('https://',trackbanner)+length('.рф')))=0) do
 delete(trackbanner,pos('https://',trackbanner),pos('.рф',trackbanner)-pos('https://',trackbanner)+length('.рф'));
 while (pos('www',trackbanner)<>0) and (pos('.рф/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('www',trackbanner),pos('.рф/',trackbanner)-pos('www',trackbanner)+length('.рф/')))=0) do
 delete(trackbanner,pos('www',trackbanner),pos('.рф/',trackbanner)-pos('www',trackbanner)+length('.рф/'));
 while (pos('www',trackbanner)<>0) and (pos('.рф',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('www',trackbanner),pos('.рф',trackbanner)-pos('www',trackbanner)+length('.рф')))=0) do
 delete(trackbanner,pos('www',trackbanner),pos('.рф',trackbanner)-pos('www',trackbanner)+length('.рф'));

 while (pos('http://',trackbanner)<>0) and (pos('.ua/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('http://',trackbanner),pos('.ua/',trackbanner)-pos('http://',trackbanner)+length('.ua/')))=0) do
 delete(trackbanner,pos('http://',trackbanner),pos('.ua/',trackbanner)-pos('http://',trackbanner)+length('.ua/'));
 while (pos('http://',trackbanner)<>0) and (pos('.ua',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('http://',trackbanner),pos('.ua',trackbanner)-pos('http://',trackbanner)+length('.ua')))=0) do
 delete(trackbanner,pos('http://',trackbanner),pos('.ua',trackbanner)-pos('http://',trackbanner)+length('.ua'));
 while (pos('https://',trackbanner)<>0) and (pos('.ua/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('https://',trackbanner),pos('.ua/',trackbanner)-pos('https://',trackbanner)+length('.ua/')))=0) do
 delete(trackbanner,pos('https://',trackbanner),pos('.ua/',trackbanner)-pos('https://',trackbanner)+length('.ua/'));
 while (pos('https://',trackbanner)<>0) and (pos('.ua',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('https://',trackbanner),pos('.ua',trackbanner)-pos('https://',trackbanner)+length('.ua')))=0) do
 delete(trackbanner,pos('https://',trackbanner),pos('.ua',trackbanner)-pos('https://',trackbanner)+length('.ua'));
 while (pos('www',trackbanner)<>0) and (pos('.ua/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('www',trackbanner),pos('.ua/',trackbanner)-pos('www',trackbanner)+length('.ua/')))=0) do
 delete(trackbanner,pos('www',trackbanner),pos('.ua/',trackbanner)-pos('www',trackbanner)+length('.ua/'));
 while (pos('www',trackbanner)<>0) and (pos('.ua',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('www',trackbanner),pos('.ua',trackbanner)-pos('www',trackbanner)+length('.ua')))=0) do
 delete(trackbanner,pos('www',trackbanner),pos('.ua',trackbanner)-pos('www',trackbanner)+length('.ua'));

 while (pos('http://',trackbanner)<>0) and (pos('.biz/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('http://',trackbanner),pos('.biz/',trackbanner)-pos('http://',trackbanner)+length('.biz/')))=0) do
 delete(trackbanner,pos('http://',trackbanner),pos('.biz/',trackbanner)-pos('http://',trackbanner)+length('.biz/'));
 while (pos('http://',trackbanner)<>0) and (pos('.biz',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('http://',trackbanner),pos('.biz',trackbanner)-pos('http://',trackbanner)+length('.biz')))=0) do
 delete(trackbanner,pos('http://',trackbanner),pos('.biz',trackbanner)-pos('http://',trackbanner)+length('.biz'));
 while (pos('https://',trackbanner)<>0) and (pos('.biz/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('https://',trackbanner),pos('.biz/',trackbanner)-pos('https://',trackbanner)+length('.biz/')))=0) do
 delete(trackbanner,pos('https://',trackbanner),pos('.biz/',trackbanner)-pos('https://',trackbanner)+length('.biz/'));
 while (pos('https://',trackbanner)<>0) and (pos('.biz',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('https://',trackbanner),pos('.biz',trackbanner)-pos('https://',trackbanner)+length('.biz')))=0) do
 delete(trackbanner,pos('https://',trackbanner),pos('.biz',trackbanner)-pos('https://',trackbanner)+length('.biz'));
 while (pos('www',trackbanner)<>0) and (pos('.biz/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('www',trackbanner),pos('.biz/',trackbanner)-pos('www',trackbanner)+length('.biz/')))=0) do
 delete(trackbanner,pos('www',trackbanner),pos('.biz/',trackbanner)-pos('www',trackbanner)+length('.biz/'));
 while (pos('www',trackbanner)<>0) and (pos('.biz',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('www',trackbanner),pos('.biz',trackbanner)-pos('www',trackbanner)+length('.biz')))=0) do
 delete(trackbanner,pos('www',trackbanner),pos('.biz',trackbanner)-pos('www',trackbanner)+length('.biz'));

 while (pos('http://',trackbanner)<>0) and (pos('.fm/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('http://',trackbanner),pos('.fm/',trackbanner)-pos('http://',trackbanner)+length('.fm/')))=0) do
 delete(trackbanner,pos('http://',trackbanner),pos('.fm/',trackbanner)-pos('http://',trackbanner)+length('.fm/'));
 while (pos('http://',trackbanner)<>0) and (pos('.fm',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('http://',trackbanner),pos('.fm',trackbanner)-pos('http://',trackbanner)+length('.fm')))=0) do
 delete(trackbanner,pos('http://',trackbanner),pos('.fm',trackbanner)-pos('http://',trackbanner)+length('.fm'));
 while (pos('https://',trackbanner)<>0) and (pos('.fm/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('https://',trackbanner),pos('.fm/',trackbanner)-pos('https://',trackbanner)+length('.fm/')))=0) do
 delete(trackbanner,pos('https://',trackbanner),pos('.fm/',trackbanner)-pos('https://',trackbanner)+length('.fm/'));
 while (pos('https://',trackbanner)<>0) and (pos('.fm',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('https://',trackbanner),pos('.fm',trackbanner)-pos('https://',trackbanner)+length('.fm')))=0) do
 delete(trackbanner,pos('https://',trackbanner),pos('.fm',trackbanner)-pos('https://',trackbanner)+length('.fm'));
 while (pos('www',trackbanner)<>0) and (pos('.fm/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('www',trackbanner),pos('.fm/',trackbanner)-pos('www',trackbanner)+length('.fm/')))=0) do
 delete(trackbanner,pos('www',trackbanner),pos('.fm/',trackbanner)-pos('www',trackbanner)+length('.fm/'));
 while (pos('www',trackbanner)<>0) and (pos('.fm',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('www',trackbanner),pos('.fm',trackbanner)-pos('www',trackbanner)+length('.fm')))=0) do
 delete(trackbanner,pos('www',trackbanner),pos('.fm',trackbanner)-pos('www',trackbanner)+length('.fm'));

 while (pos('http://',trackbanner)<>0) and (pos('.pl/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('http://',trackbanner),pos('.pl/',trackbanner)-pos('http://',trackbanner)+length('.pl/')))=0) do
 delete(trackbanner,pos('http://',trackbanner),pos('.pl/',trackbanner)-pos('http://',trackbanner)+length('.pl/'));
 while (pos('http://',trackbanner)<>0) and (pos('.pl',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('http://',trackbanner),pos('.pl',trackbanner)-pos('http://',trackbanner)+length('.pl')))=0) do
 delete(trackbanner,pos('http://',trackbanner),pos('.pl',trackbanner)-pos('http://',trackbanner)+length('.pl'));
 while (pos('https://',trackbanner)<>0) and (pos('.pl/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('https://',trackbanner),pos('.pl/',trackbanner)-pos('https://',trackbanner)+length('.pl/')))=0) do
 delete(trackbanner,pos('https://',trackbanner),pos('.pl/',trackbanner)-pos('https://',trackbanner)+length('.pl/'));
 while (pos('https://',trackbanner)<>0) and (pos('.pl',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('https://',trackbanner),pos('.pl',trackbanner)-pos('https://',trackbanner)+length('.pl')))=0) do
 delete(trackbanner,pos('https://',trackbanner),pos('.pl',trackbanner)-pos('https://',trackbanner)+length('.pl'));
 while (pos('www',trackbanner)<>0) and (pos('.pl/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('www',trackbanner),pos('.pl/',trackbanner)-pos('www',trackbanner)+length('.pl/')))=0) do
 delete(trackbanner,pos('www',trackbanner),pos('.pl/',trackbanner)-pos('www',trackbanner)+length('.pl/'));
 while (pos('www',trackbanner)<>0) and (pos('.pl',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('www',trackbanner),pos('.pl',trackbanner)-pos('www',trackbanner)+length('.pl')))=0) do
 delete(trackbanner,pos('www',trackbanner),pos('.pl',trackbanner)-pos('www',trackbanner)+length('.pl'));

  while (pos('http://',trackbanner)<>0) and (pos('.tk/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('http://',trackbanner),pos('.tk/',trackbanner)-pos('http://',trackbanner)+length('.tk/')))=0) do
 delete(trackbanner,pos('http://',trackbanner),pos('.tk/',trackbanner)-pos('http://',trackbanner)+length('.tk/'));
 while (pos('http://',trackbanner)<>0) and (pos('.tk',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('http://',trackbanner),pos('.tk',trackbanner)-pos('http://',trackbanner)+length('.tk')))=0) do
 delete(trackbanner,pos('http://',trackbanner),pos('.tk',trackbanner)-pos('http://',trackbanner)+length('.tk'));
 while (pos('https://',trackbanner)<>0) and (pos('.tk/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('https://',trackbanner),pos('.tk/',trackbanner)-pos('https://',trackbanner)+length('.tk/')))=0) do
 delete(trackbanner,pos('https://',trackbanner),pos('.tk/',trackbanner)-pos('https://',trackbanner)+length('.tk/'));
 while (pos('https://',trackbanner)<>0) and (pos('.tk',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('https://',trackbanner),pos('.tk',trackbanner)-pos('https://',trackbanner)+length('.tk')))=0) do
 delete(trackbanner,pos('https://',trackbanner),pos('.tk',trackbanner)-pos('https://',trackbanner)+length('.tk'));
 while (pos('www',trackbanner)<>0) and (pos('.tk/',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('www',trackbanner),pos('.tk/',trackbanner)-pos('www',trackbanner)+length('.tk/')))=0) do
 delete(trackbanner,pos('www',trackbanner),pos('.tk/',trackbanner)-pos('www',trackbanner)+length('.tk/'));
 while (pos('www',trackbanner)<>0) and (pos('.tk',trackbanner)<>0) and (pos(' ',copy(trackbanner,pos('www',trackbanner),pos('.tk',trackbanner)-pos('www',trackbanner)+length('.tk')))=0) do
 delete(trackbanner,pos('www',trackbanner),pos('.tk',trackbanner)-pos('www',trackbanner)+length('.tk'));
 {----------------  поиск доменов, алиасов-------------------}
 if pos('http://',trackbanner)<>0 then while pos('http://',trackbanner)<>0 do delete(trackbanner,pos('http://',trackbanner),length('http://'));
 if pos('https://',trackbanner)<>0 then while pos('https://',trackbanner)<>0 do delete(trackbanner,pos('https://',trackbanner),length('https://'));
 if pos('www.',trackbanner)<>0 then while pos('www.',trackbanner)<>0 do delete(trackbanner,pos('www.',trackbanner),length('www.'));
 if pos('.ru',trackbanner)<>0 then while pos('.ru',trackbanner)<>0 do delete(trackbanner,pos('.ru',trackbanner),length('.ru'));
 if pos('.com',trackbanner)<>0 then while pos('.com',trackbanner)<>0 do delete(trackbanner,pos('.com',trackbanner),length('.com'));
 if pos('.net',trackbanner)<>0 then while pos('.net',trackbanner)<>0 do delete(trackbanner,pos('.net',trackbanner),length('.net'));
 if pos('.рф',trackbanner)<>0 then while pos('.рф',trackbanner)<>0 do delete(trackbanner,pos('.рф',trackbanner),length('.рф'));
 if pos('.ua',trackbanner)<>0 then while pos('.ua',trackbanner)<>0 do delete(trackbanner,pos('.ua',trackbanner),length('.ua'));
 if pos('.biz',trackbanner)<>0 then while pos('.biz',trackbanner)<>0 do delete(trackbanner,pos('.biz',trackbanner),length('.biz'));
 if pos('.fm',trackbanner)<>0 then while pos('.fm',trackbanner)<>0 do delete(trackbanner,pos('.fm',trackbanner),length('.fm'));
 if pos('.pl',trackbanner)<>0 then while pos('.pl',trackbanner)<>0 do delete(trackbanner,pos('.pl',trackbanner),length('.pl'));
 {-----------------  корректировка --------------------------}
 if (pos('-',trackbanner)<>0) then trackbanner:=replacestr(trackbanner,'-',' -');
 if (pos('-',trackbanner)<>0) then trackbanner:=replacestr(trackbanner,'-','- ');
 if (pos('__',trackbanner)<>0) then trackbanner:=replacestr(trackbanner,'__',' ');
 if (pos('--',trackbanner)<>0) then trackbanner:=replacestr(trackbanner,'--',' ');
 if (pos(',,',trackbanner)<>0) then trackbanner:=replacestr(trackbanner,',,',' ');
 if (pos('..',trackbanner)<>0) then trackbanner:=replacestr(trackbanner,'..',' ');
 if (pos(']]',trackbanner)<>0) then trackbanner:=replacestr(trackbanner,']]',']');
 if (pos('[[',trackbanner)<>0) then trackbanner:=replacestr(trackbanner,'[[','[');
 if (pos('))',trackbanner)<>0) then trackbanner:=replacestr(trackbanner,'))',')');
 if (pos('((',trackbanner)<>0) then trackbanner:=replacestr(trackbanner,'((','(');
 {----------------  поиск и удаление двойных символов ------------------}
 if pos('  ',trackbanner)<>0 then while pos('  ',trackbanner)<>0 do delete(trackbanner,pos('  ',trackbanner),1);
 if pos('()',trackbanner)<>0 then while pos('()',trackbanner)<>0 do delete(trackbanner,pos('()',trackbanner),length('()'));
 if pos('<>',trackbanner)<>0 then while pos('<>',trackbanner)<>0 do delete(trackbanner,pos('<>',trackbanner),length('<>'));
 if pos('><',trackbanner)<>0 then while pos('><',trackbanner)<>0 do delete(trackbanner,pos('><',trackbanner),length('><'));
 if pos('> <',trackbanner)<>0 then while pos('> <',trackbanner)<>0 do delete(trackbanner,pos('> <',trackbanner),length('> <'));
 if pos('< >',trackbanner)<>0 then while pos('< >',trackbanner)<>0 do delete(trackbanner,pos('< >',trackbanner),length('< >'));
 if pos('//',trackbanner)<>0 then while pos('//',trackbanner)<>0 do delete(trackbanner,pos('//',trackbanner),length('//'));
 if pos('\\',trackbanner)<>0 then while pos('\\',trackbanner)<>0 do delete(trackbanner,pos('\\',trackbanner),length('\\'));
 if pos('»«',trackbanner)<>0 then while pos('»«',trackbanner)<>0 do delete(trackbanner,pos('»«',trackbanner),length('»«'));
 if pos('«»',trackbanner)<>0 then while pos('«»',trackbanner)<>0 do delete(trackbanner,pos('«»',trackbanner),length('«»'));
 if pos('« »',trackbanner)<>0 then while pos('« »',trackbanner)<>0 do delete(trackbanner,pos('« »',trackbanner),length('« »'));
 if pos('[]',trackbanner)<>0 then while pos('[]',trackbanner)<>0 do delete(trackbanner,pos('[]',trackbanner),length('[]'));
 if pos('[ ]',trackbanner)<>0 then while pos('[ ]',trackbanner)<>0 do delete(trackbanner,pos('[ ]',trackbanner),length('[ ]'));
 if pos('..',trackbanner)<>0 then while pos('..',trackbanner)<>0 do delete(trackbanner,pos('..',trackbanner),length('..'));
 if pos(',,',trackbanner)<>0 then while pos(',,',trackbanner)<>0 do delete(trackbanner,pos(',,',trackbanner),length(',,'));
 if pos('( )',trackbanner)<>0 then while pos('( )',trackbanner)<>0 do delete(trackbanner,pos('( )',trackbanner),length('( )'));
 if pos('__',trackbanner)<>0 then while pos('__',trackbanner)<>0 do delete(trackbanner,pos('__',trackbanner),1);
 if pos('--',trackbanner)<>0 then while pos('--',trackbanner)<>0 do delete(trackbanner,pos('--',trackbanner),1);
 if pos('  ',trackbanner)<>0 then while pos('  ',trackbanner)<>0 do delete(trackbanner,pos('  ',trackbanner),1);
 {---------------  чистка начала и конца ------------------------------}
 if (pos(' - ',trackbanner)=1) or (pos(' - ',trackbanner)=length(trackbanner)-length(' - ')) then Replacestr(trackbanner,' - ','');
 if (pos('- ',trackbanner)=1) or (pos('- ',trackbanner)=length(trackbanner)-length('- ')) then Replacestr(trackbanner,'- ','');
 if (pos(' -',trackbanner)=1) or (pos(' -',trackbanner)=length(trackbanner)-length(' -')) then Replacestr(trackbanner,' -','');
 if (pos(' _ ',trackbanner)=1) or (pos(' _ ',trackbanner)=length(trackbanner)-length(' _ ')) then Replacestr(trackbanner,' _ ','');
 if (pos('_ ',trackbanner)=1) or (pos('_ ',trackbanner)=length(trackbanner)-length('_ ')) then Replacestr(trackbanner,'_ ','');
 if (pos(' _',trackbanner)=1) or (pos(' _',trackbanner)=length(trackbanner)-length(' _')) then Replacestr(trackbanner,' _','');
 if (pos(' ',trackbanner)=1) or (pos(' ',trackbanner)=length(trackbanner)-length(' ')) then Replacestr(trackbanner,' ','');
 {-----------------------------------------------------------}
  end;
 result:=trackbanner;
end;

procedure itelmaplayertext;
begin
if (mode<>radioplay) and (mode<>Stop) then
begin
  itelmaprogressbar(channel);
  if (timetrack<>'00:01') and (timetrack<>'00:00') then
  begin
	  SinglePlayerGUI.Canvas.Font.Color:=plset.timetrackcolor;
	  SinglePlayerGUI.Canvas.Font.Size:=plset.timetracksize;
	  SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.timetrackleft,timetrack,1),plset.timetracktop,timetrack);
	  SinglePlayerGUI.Canvas.Font.Color:=plset.tracktimecolor;
	  SinglePlayerGUI.Canvas.Font.Size:=plset.tracktimesize;
	  SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.tracktimeleft,strpos,1),plset.tracktimetop,strpos);
	  SinglePlayerGUI.Canvas.Font.Color:=plset.playedtrackcolor;
	  SinglePlayerGUI.Canvas.Font.Size:=plset.playedtracksize;
	  SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.playedtrackleft,strkolcurtr,1),plset.playedtracktop,strkolcurtr);
  end;
end;
SinglePlayerGUI.Canvas.Font.Color:=plset.cureqcolor;
SinglePlayerGUI.Canvas.Font.Size:=plset.cureqsize;
SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.cureqleft,strcureq,1),plset.cureqtop,strcureq);
SinglePlayerGUI.Canvas.Font.Color:=plset.curplscolor;
SinglePlayerGUI.Canvas.Font.Size:=plset.curplssize;
if SinglePlayerSettings.curentplaylist<>kollpls then SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.curplsleft,getfromlangpack('playlist')+' '+inttostr(SinglePlayerSettings.curentplaylist),1),plset.curplstop,getfromlangpack('playlist')+' '+inttostr(SinglePlayerSettings.curentplaylist)) else
SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.curplsleft,getfromlangpack('playlist')+' '+getfromlangpack('favorites'),1),plset.curplstop,getfromlangpack('playlist')+' '+getfromlangpack('favorites'));
SinglePlayerGUI.Canvas.Font.Color:=plset.bitratetrackcolor;
SinglePlayerGUI.Canvas.Font.Size:=plset.bitratetracksize;
SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.bitratetrackleft,bitratestr,1),plset.bitratetracktop,bitratestr);
SinglePlayerGUI.Canvas.Font.Color:=plset.curentdirplcolor;
SinglePlayerGUI.Canvas.Font.Size:=plset.curentdirplsize;
if fileexists(curenttrack) then
 begin
  curpldir:=ExtractFilepath(UTF8Encode(curenttrack));
  if curpldir[length(curpldir)]='\' then delete(curpldir,length(curpldir),1);
  curpldir:=ExtractFileName(curpldir);
 end;
SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.curentdirplleft,curpldir,1),plset.curentdirpltop,curpldir);

if statusplaylist=0 then            {название трека, исполнитель}
begin

 SinglePlayerGUI.Canvas.Font.Color:=plset.tracktitlecolor;
 SinglePlayerGUI.Canvas.Font.Size:=plset.tracktitlesize;
 if SinglePlayerSettings.scrolltrack=0 then
 	SinglePlayerGUI.Canvas.TextRect(classes.Rect(myalign(plset.tracktitleleft,artisttitle,1)+pr2,plset.trackartisttitletop,StrToInt(plset.tracktitleleft)+plset.tracktitlewidth,plset.trackartisttitletop+SinglePlayerGUI.Canvas.TextHeight(artisttitle)),myalign(plset.tracktitleleft,artisttitle,1)+pr2,plset.trackartisttitletop,artisttitle,TextStyle)
 else
 	SinglePlayerGUI.Canvas.TextRect(classes.Rect(myalign(plset.tracktitleleft,artisttitle,0)+pr2,plset.trackartisttitletop,StrToInt(plset.tracktitleleft)+plset.tracktitlewidth,plset.trackartisttitletop+SinglePlayerGUI.Canvas.TextHeight(artisttitle)),myalign(plset.tracktitleleft,artisttitle,0)+pr2,plset.trackartisttitletop,artisttitle);

 if SinglePlayerSettings.track2str=1 then
  begin
	if SinglePlayerSettings.scrolltrack=0 then
   		SinglePlayerGUI.Canvas.TextRect(classes.Rect(myalign(plset.tracktitleleft,scrolltitlestr,1)+pr4,plset.tracktitletop,StrToInt(plset.tracktitleleft)+plset.tracktitlewidth,plset.tracktitletop+SinglePlayerGUI.Canvas.TextHeight(scrolltitlestr)),myalign(plset.tracktitleleft,scrolltitlestr,1)+pr4,plset.tracktitletop,scrolltitlestr,TextStyle)
    else
   		SinglePlayerGUI.Canvas.TextRect(classes.Rect(myalign(plset.tracktitleleft,scrolltitlestr,0)+pr4,plset.tracktitletop,StrToInt(plset.tracktitleleft)+plset.tracktitlewidth,plset.tracktitletop+SinglePlayerGUI.Canvas.TextHeight(scrolltitlestr)),myalign(plset.tracktitleleft,scrolltitlestr,0)+pr4,plset.tracktitletop,scrolltitlestr);
  end;

end;
if statusplaylist=1 then             {пожалуйста, подождите}
begin
 SinglePlayerGUI.Canvas.Font.Color:=plset.statustextcolor;
 SinglePlayerGUI.Canvas.Font.Size:=plset.statustextsize;
 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.statustextleft,getfromlangpack('saveplaylist'),1),plset.statustexttop,getfromlangpack('saveplaylist'));
end;
if statusplaylist=2 then              {сортировка плейлиста}
begin
SinglePlayerGUI.Canvas.Font.Color:=plset.statustextcolor;
SinglePlayerGUI.Canvas.Font.Size:=plset.statustextsize;
 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.statustextleft,getfromlangpack('sortlist'),1),plset.statustexttop,getfromlangpack('sortlist'));
end;
if statusplaylist=5 then   {поиск трека}
begin
SinglePlayerGUI.Canvas.Font.Color:=plset.statustextcolor;
SinglePlayerGUI.Canvas.Font.Size:=plset.statustextsize;
 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.statustextleft,getfromlangpack('searchtrack'),1),plset.statustexttop,getfromlangpack('searchtrack'));
end;
if (coverimg<>nil) and (SinglePlayerSettings.showcoverpl=1) and (coverloaded=1) and ((mode=play) or (mode=Paused)) {and (PictureFrames.Count<>0)} then
begin
 coverimgot.Canvas.StretchDraw(classes.Rect(0, 0, plset.coverwidth, plset.coverheight),coverimg);
 coverimgot.SetSize(plset.coverwidth, plset.coverheight);
 SinglePlayerGUI.Canvas.Draw(plset.coverinplayerleft,plset.coverinplayertop,coverimgot);
end;
if (coverimgRadio<>nil) and (SinglePlayerSettings.showcoverpl=1) and (radiocoverloaded=1) and ((mode=radioplay) or (mode=Paused)) {and (PictureFrames.Count<>0)} then
begin
 coverimgotRadio.Canvas.StretchDraw(classes.Rect(0, 0, plset.coverwidth, plset.coverheight),coverimgRadio);
 coverimgotRadio.SetSize(plset.coverwidth, plset.coverheight);
 SinglePlayerGUI.Canvas.Draw(plset.coverinplayerleft,plset.coverinplayertop,coverimgotRadio);
end;
end;

procedure itelmaprogressbar(itchan:DWORD);
var
 x,y,i:integer;
begin
 x:=plset.progressbarleft;
 y:=plset.progressbartop;
 if mode = play then curposfp:=100*BASS_ChannelGetPosition(itchan,0) div BASS_ChannelGetLength(itchan,0);
  if plset.progressbarfonshow = 1 then
   begin
    SinglePlayerGUI.Canvas.Pen.Color :=plset.progressbarfoncolor;
    SinglePlayerGUI.Canvas.Brush.Color := plset.progressbarfoncolor;
    SinglePlayerGUI.Canvas.Rectangle(x, Y, x+(plset.progressbarwidth*100)+((100*plset.progressbarvir) div 10), Y + plset.progressbarheight);
   end;
  if (mode<>closed) and (mode<>radioplay) and (plset.progressbarshow=1) then
   begin
  for i:=0 to 100 do
    begin
     if i<=curposfp then
      begin
       SinglePlayerGUI.Canvas.Pen.Color :=plset.progressbarcolor;
       SinglePlayerGUI.Canvas.Brush.Color := plset.progressbarcolor;
       SinglePlayerGUI.Canvas.Rectangle(x+1 , Y+1, X + (i*plset.progressbarwidth)+((i*plset.progressbarvir) div 10)-1, Y + plset.progressbarheight-1);
      end;
    end;
   end;
end;

procedure playprevfolder;
var temptrack,i:word;
    TrackFound, Flag2: boolean;
begin                                                     {и не идет поиск трека}
 try
 if (SinglePlayerSettings.kolltrack<>0) and (mode=play) and (statusplaylist<>5) then
  begin
  TrackFound:=False;
  temptrack:=SinglePlayerSettings.playedtrack;
  for i:=temptrack-1 downto 1 do
   if ExtractFilePath(track[i])<>ExtractFilePath(track[temptrack]) then
   begin
     TrackFound:=True;
     temptrack:=i;
     Break;
   end;
  if TrackFound then
  begin
   Flag2:=False;
   for i:=temptrack downto 1 do if ExtractFilePath(track[i])<>ExtractFilePath(track[temptrack]) then
   begin
    Flag2:=True;
    break;
   end;
   if Flag2 then temptrack:=i+1 else temptrack:=1;
  end;
  if (not TrackFound) and (SinglePlayerSettings.ciclepls=1) then
  begin
  for i:=SinglePlayerSettings.kolltrack downto temptrack+1 do
   if ExtractFilePath(track[i])<>ExtractFilePath(track[temptrack]) then
   begin
     TrackFound:=True;
     temptrack:=i;
     Break;
   end;
  if TrackFound then
  begin
   Flag2:=False;
   for i:=temptrack downto 1 do if ExtractFilePath(track[i])<>ExtractFilePath(track[temptrack]) then
   begin
    Flag2:=True;
    break;
   end;
   if Flag2 then temptrack:=i+1 else temptrack:=1;
  end;
  end;
  if not TrackFound then if (temptrack>10) then
  begin
   TrackFound:=True;
   Dec(temptrack,10);
  end;
  if TrackFound then
  begin
   thisTagv2.clear;
   SinglePlayerSettings.curpos:=-1;
   curenttrack:=track[temptrack];
   if singleplayersettings.readtags=1 then thisTagv2.ReadFromFile(curenttrack);
   SinglePlayerSettings.playedtrack:=temptrack;
   itelmaplay(curenttrack);
   playertimercode;
   SinglePlayerGUI.Invalidate;
  end;
 end;
 except
   LogAndExitPlayer('Ошибка в процедуре playprevfolder',0,0);
 end;
end;

procedure playnextfolder;
var temptrack,i:word;
    TrackFound: boolean;
begin                                                     {и не идет поиск трека}
 try
 if (SinglePlayerSettings.kolltrack<>0) and (mode=play) and (statusplaylist<>5) then
  begin
  TrackFound:=False;
  temptrack:=SinglePlayerSettings.playedtrack;
  for i:=temptrack+1 to SinglePlayerSettings.kolltrack do
   if ExtractFilePath(track[i])<>ExtractFilePath(track[temptrack]) then
   begin
     TrackFound:=True;
     temptrack:=i;
     Break;
   end;
  if (not TrackFound) and (SinglePlayerSettings.ciclepls=1) then
  begin
   for i:=1 to temptrack-1 do
   if ExtractFilePath(track[i])<>ExtractFilePath(track[temptrack]) then
   begin
    TrackFound:=True;
    temptrack:=i;
    Break;
   end;
  end;
  if not TrackFound then if (temptrack+10)<=SinglePlayerSettings.kolltrack then
  begin
   TrackFound:=True;
   Inc(temptrack,10);
  end;
  if TrackFound then
  begin
   thisTagv2.clear;
   SinglePlayerSettings.curpos:=-1;
   curenttrack:=track[temptrack];
   if singleplayersettings.readtags=1 then thisTagv2.ReadFromFile(curenttrack);
   SinglePlayerSettings.playedtrack:=temptrack;
   itelmaplay(curenttrack);
   playertimercode;
   SinglePlayerGUI.Invalidate;
  end;
 end;
 except
   LogAndExitPlayer('Ошибка в процедуре playnextfolder',0,0);
 end;
end;

procedure playnexttrack;
var
 i:integer;
begin                                                     {и не идет поиск трека}
 try

   if (nextplaytrackmass<>nil) and (length(nextplaytrackmass)<>0) then
     begin
      curenttrack:=nextplaytrackmass[1];
      for i:=1 to length(nextplaytrackmass)-2 do nextplaytrackmass[i]:=nextplaytrackmass[i+1];
      setlength(nextplaytrackmass,length(nextplaytrackmass)-1);
      if kollnexttrack>0 then dec(kollnexttrack);
      if kollnexttrack=0 then nextplaytrackmass:=nil;
      thisTagv2.clear;
      if ((mode=play) or (mode=radioplay)) then
        begin
         if singleplayersettings.readtags=1 then thisTagv2.ReadFromFile(curenttrack);
         itelmaplay(curenttrack);
        end;
      playertimercode;
      SinglePlayerGUI.Invalidate;
      exit;
     end;

 if (SinglePlayerSettings.kolltrack<>0) and (mode<>started) and (statusplaylist<>5) then
  begin
  thisTagv2.clear;
 if curentpage='playlist' then begin SinglePlayerSettings.playedtrack:=npltr; playlistferstopen:=1; {playlist;} end;
 clicknext:=1;
 SinglePlayerSettings.curpos:=-1;
 if SinglePlayerSettings.playone=0 then
     begin
 if SinglePlayerSettings.shufflekey=0 then
   begin
    inc(SinglePlayerSettings.playedtrack);
    if SinglePlayerSettings.ciclepls=1 then
      begin
       if SinglePlayerSettings.playedtrack>SinglePlayerSettings.kolltrack then SinglePlayerSettings.playedtrack:=1;
      end else
      begin
       if SinglePlayerSettings.playedtrack>SinglePlayerSettings.kolltrack then
         begin
          if singleplayersettings.playallpls=1 then
           begin
            if statusplaylist=0 then
             begin
              SinglePlayerSettings.curentplaylist:=findrandompls;
              if SinglePlayerSettings.curentplaylist>kollpls then SinglePlayerSettings.curentplaylist:=1;
              playlistread(SinglePlayerSettings.curentplaylist);
              playlistferstopen:=1;
              SinglePlayerSettings.playedtrack:=1;
             end;
           end
           else
           begin
            SinglePlayerSettings.playedtrack:=SinglePlayerSettings.kolltrack;
            singlestopplay;
            exit;
           end;
         end;
      end;
   end else
   begin
    if singleplayersettings.playallpls=1 then
     begin
      if statusplaylist=0 then
       begin
        SinglePlayerSettings.curentplaylist:=findrandompls;
        if SinglePlayerSettings.curentplaylist>kollpls then SinglePlayerSettings.curentplaylist:=1;
        playlistread(SinglePlayerSettings.curentplaylist);
        playlistferstopen:=1;
       end;
     end;

    if shuffindex>kollshuff-1 then shuffindex:=1 else inc(shuffindex);
    SinglePlayerSettings.playedtrack:=random(SinglePlayerSettings.kolltrack+1);
    if SinglePlayerSettings.playedtrack<1 then SinglePlayerSettings.playedtrack:=1;
    if SinglePlayerSettings.playedtrack>SinglePlayerSettings.kolltrack then SinglePlayerSettings.playedtrack:=SinglePlayerSettings.kolltrack;
    while ((shuffmass[shuffindex-1]=SinglePlayerSettings.playedtrack) and (SinglePlayerSettings.kolltrack>1)) or (findrandom(SinglePlayerSettings.playedtrack)=1) do
     begin
      SinglePlayerSettings.playedtrack:=random(SinglePlayerSettings.kolltrack+1);
      if SinglePlayerSettings.playedtrack<1 then SinglePlayerSettings.playedtrack:=1;
      if SinglePlayerSettings.playedtrack>SinglePlayerSettings.kolltrack then SinglePlayerSettings.playedtrack:=SinglePlayerSettings.kolltrack;
     end;
    shuffmass[shuffindex]:=SinglePlayerSettings.playedtrack;
    if SinglePlayerSettings.playedtrack<1 then SinglePlayerSettings.playedtrack:=SinglePlayerSettings.kolltrack;
    if SinglePlayerSettings.playedtrack>SinglePlayerSettings.kolltrack then SinglePlayerSettings.playedtrack:=1;

   end;
 curenttrack:=track[SinglePlayerSettings.playedtrack];
 timestartplay:=0;
  if pos('#ts',curenttrack)<>0 then
   begin
    timestartplay:=(strtointdef(copy(curenttrack,pos('#ts',curenttrack)+3, pos('st#',curenttrack)-pos('#ts',curenttrack)-9),0)*60)+strtointdef(copy(curenttrack,pos('#ts',curenttrack)+6, pos('st#',curenttrack)-pos('#ts',curenttrack)-9),0);
    curenttrack:=copy(curenttrack,pos('st#',curenttrack)+3,length(curenttrack)-pos('st#',curenttrack)-2);
   end;
    end;

 if ((mode=play) or (mode=radioplay)) then
  begin
   if singleplayersettings.readtags=1 then thisTagv2.ReadFromFile(curenttrack);
   itelmaplay(curenttrack);
  end;
 playertimercode;
 SinglePlayerGUI.Invalidate;

  end else exit;

 except
   LogAndExitPlayer('Ошибка в процедуре playnexttrack',0,0);
 end;
end;

function findrandompls:integer;
var
i:integer;
begin
 result:=SinglePlayerSettings.curentplaylist;
 for i:=1 to kollpls do
  begin
   if SinglePlayerSettings.shufflekey=1 then result:=random(kollpls-1) else inc(result);
   if fileexists(SinglePlayerDir+'playlist_'+inttostr(result)+'.pls') then exit;
  end;
 if SinglePlayerSettings.shufflekey=1 then result:=SinglePlayerSettings.curentplaylist else result:=1;
end;

function findrandom(trackn:integer):integer;
var
  i,est:integer;
begin
 result:=0;
 est:=0;
 for i:=1 to SinglePlayerSettings.kolltrack do
   begin
    if trackn=playedtrack[i] then result:=1;
    if playedtrack[i]=0 then est:=1;
   end;
 if est=0 then for i:=1 to SinglePlayerSettings.kolltrack do playedtrack[i]:=0;
end;

procedure playprevtrack;
begin
 try
 if (SinglePlayerSettings.kolltrack<>0) and (mode<>started) and (statusplaylist<>5) then
  begin
 if (SinglePlayerSettings.backzero=1) and (bass_ChannelGetPosition(channel,0)>2057124) then begin itelmaplay(curenttrack); exit; end;
 if curentpage='playlist' then begin SinglePlayerSettings.playedtrack:=npltr; playlistferstopen:=1; {playlist;} end;
 clickprev:=1;
 SinglePlayerSettings.curpos:=-1;
  if SinglePlayerSettings.playone=0 then
     begin
 if SinglePlayerSettings.shufflekey=0 then
   begin
    dec(SinglePlayerSettings.playedtrack);
    if SinglePlayerSettings.ciclepls=1 then
     begin
      if SinglePlayerSettings.playedtrack<1 then SinglePlayerSettings.playedtrack:=SinglePlayerSettings.kolltrack;
     end else
     begin
      if SinglePlayerSettings.playedtrack<1 then begin  SinglePlayerSettings.playedtrack:=1; exit; end;
     end;
   end else
   begin
   dec(shuffindex);
   if shuffindex<>0 then
    begin
     SinglePlayerSettings.playedtrack:=shuffmass[shuffindex];
    end else
    begin
       shuffindex:=1;
       SinglePlayerSettings.playedtrack:=random(SinglePlayerSettings.kolltrack+1);
       if SinglePlayerSettings.playedtrack<1 then SinglePlayerSettings.playedtrack:=random(SinglePlayerSettings.kolltrack+1);
       if SinglePlayerSettings.playedtrack>SinglePlayerSettings.kolltrack then SinglePlayerSettings.playedtrack:=SinglePlayerSettings.kolltrack-1;
    end;
     if SinglePlayerSettings.playedtrack<1 then SinglePlayerSettings.playedtrack:=random(SinglePlayerSettings.kolltrack+1);
     if SinglePlayerSettings.playedtrack>SinglePlayerSettings.kolltrack then SinglePlayerSettings.playedtrack:=1;
    end;
 curenttrack:=track[SinglePlayerSettings.playedtrack];
 timestartplay:=0;
  if pos('#ts',curenttrack)<>0 then
   begin
    timestartplay:=(strtointdef(copy(curenttrack,pos('#ts',curenttrack)+3, pos('st#',curenttrack)-pos('#ts',curenttrack)-9),0)*60)+strtointdef(copy(curenttrack,pos('#ts',curenttrack)+6, pos('st#',curenttrack)-pos('#ts',curenttrack)-9),0);
    curenttrack:=copy(curenttrack,pos('st#',curenttrack)+3,length(curenttrack)-pos('st#',curenttrack)-2);
   end;
     end;
 if ((mode=play) or (mode=radioplay)) then
  begin
   if singleplayersettings.readtags=1 then thisTagv2.ReadFromFile(curenttrack);
   itelmaplay(curenttrack);
  end;
 playertimercode;
 SinglePlayerGUI.Invalidate;
  end else exit;

 except
   LogAndExitPlayer('Ошибка в процедуре playprevtrack',0,0);
 end;
end;

procedure spectrum(FFTData : TFFTData; X, Y : Integer);
var i, YPos : LongInt; YVal : Single;H1,trackp:integer;
begin
 try
         trackp:=plset.trackp;
         X:=plset.spectr1left;
         Y:=plset.spectr1top;
         H1:=plset.spectr1height;
         for i := 0 to plset.spectr1kolbar do begin
           YVal := Abs(FFTData[i]);
           try
           if SinglePlayerSettings.changevizint=0 then YPos := trunc((YVal) * 500) else YPos := trunc((YVal) * SinglePlayerSettings.vizintensivitu);
           except
           end;
          if YPos > H1 then YPos := H1;
           if YPos >= FFTPeacks[i] then FFTPeacks[i] := YPos
             else FFTPeacks[i] := FFTPeacks[i] - 1;
           if YPos >= FFTFallOff[i] then FFTFallOff[i] := YPos
              else FFTFallOff[i] := FFTFallOff[i] - 5;
                     SinglePlayerGUI.Canvas.Pen.Color := plset.sp1peekcolor;
                     SinglePlayerGUI.Canvas.MoveTo(X + i*plset.spectr1prbar, Y + H1 - FFTPeacks[i]);
                     SinglePlayerGUI.Canvas.LineTo(X + i*plset.spectr1prbar + plset.spectr1widthbar, Y + H1 - FFTPeacks[i]);
                     SinglePlayerGUI.Canvas.Pen.Color := plset.sp1barcolor;
                     SinglePlayerGUI.Canvas.Brush.Color := plset.sp1barcolor;
                     SinglePlayerGUI.Canvas.Rectangle(X + i*plset.spectr1prbar, Y + H1 - FFTFallOff[i], X + i*plset.spectr1prbar + plset.spectr1widthbar, Y + H1);
                     if i<=((plset.spectr1kolbar*BASS_ChannelGetPosition(Channel,0)) div BASS_ChannelGetLength(Channel,0)) then      {положение трека}
                      begin
                      if FFTFallOff[i]< trackp then trackp:=FFTFallOff[i] else trackp:=plset.trackp;
                       SinglePlayerGUI.Canvas.Pen.Color := plset.sp1poscolor;
                       SinglePlayerGUI.Canvas.Brush.Color := plset.sp1poscolor;
                       SinglePlayerGUI.Canvas.Rectangle(X + i*plset.spectr1prbar -1, Y + H1 - trackp, X + i*plset.spectr1prbar + plset.spectr1widthbar, Y + H1);
                     end;
              end;
 except
  LogAndExitPlayer('Ошибка в процедуре spectrum',0,0);
 end;
end;

procedure startvizual;
var
  FFTFata : TFFTData;
begin
 try
  if mode=play then BASS_ChannelGetData(Channel, @FFTFata, BASS_DATA_FFT1024);
  if mode=radioplay then BASS_ChannelGetData(radioChannel, @FFTFata, BASS_DATA_FFT1024);
  spectrum(FFTFata, 0,-5);
 except
  LogAndExitPlayer('Ошибка в процедуре startvizual',0,0);
 end;
end;

procedure TSinglePlayerGUI.vizualizationTimerTimer(Sender: TObject);
begin
   if powerup=0 then SinglePlayerGUI.invalidate;
end;

procedure reloadcfg;
begin
SinglePlayerGUI.canvas.pen.Color:=$0000FF;
SinglePlayerGUI.canvas.Brush.Color:=$000000;
SinglePlayerGUI.canvas.RoundRect(330,230,480,270,30,20);
SinglePlayerGUI.canvas.Font.Color:=$00FFFF;
SinglePlayerGUI.Canvas.Font.Size:=12;
SinglePlayerGUI.Canvas.Font.Bold:=true;
SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),360,240,'Reloading...');
SinglePlayerGUI.Canvas.Font.Bold:=false;
SinglePlayerGUI.Left:=0;
SinglePlayerGUI.Top:=0;
 LoadPlayerSettings;
 Loadlang;
 LoadPlayerSkin(0);
 progresscor[1,1]:=0;    {перечитываем координаты прогрессбара}
end;

procedure skinchangepaint; //!!!
var
  i:byte;
  lft,top,vertsm,horsm:integer;
  bufskin:graphics.TBitmap;
begin
 SinglePlayerGUI.Canvas.Font.Color:=$FFFFFF;
 SinglePlayerGUI.Canvas.Font.Size:=18;
 lft:=plset.skinspisleft;    //50
 top:=plset.skinspistop;                    //80
 vertsm:=plset.skinspisvertsm;                 //20
 horsm:=plset.skinspishorsm;                 //200
 for i:=1 to sk do
  begin
 // 	bufskin:= graphics.tbitmap.Create;
	//bufskin.Width  := 185;
	//bufskin.Height := 111;
	//bufskin.Handle:=loadbmp(UTF8Encode(SinglePlayerDir+SinglePlayerSettings.skindir+skinmass[i])+'\icons\preview_mini.bmp');
 //   SinglePlayerGUI.Canvas.Draw(lft,top,bufskin);

    SinglePlayerGUI.Canvas.TextRect(classes.rect(0,0,800,480),lft,top,skinmass[i]);
    skincor[i,1]:=lft;
    skincor[i,2]:=lft+SinglePlayerGUI.Canvas.TextWidth(skinmass[i]);
    skincor[i,3]:=top;
    skincor[i,4]:=top+SinglePlayerGUI.Canvas.TextHeight(skinmass[i]);  //340

    if top+SinglePlayerGUI.Canvas.TextHeight('test')<plset.skinspisbottom then top:=top+SinglePlayerGUI.Canvas.TextHeight('test')+vertsm else
     begin
      top:=plset.skinspistop;
      lft:=lft+horsm;
      if lft>800-horsm then exit;
     end;
  end;
end;

procedure setskinmsg(workskin:string);     //!!!
begin
 SinglePlayerGUI.canvas.pen.Color:=$999999;
 SinglePlayerGUI.canvas.Brush.Color:=$000000;
 SinglePlayerGUI.canvas.RoundRect(30,55,770,375,5,5);
 SinglePlayerGUI.canvas.Brush.Color:=$111111;
 SinglePlayerGUI.canvas.RoundRect(500,270,700,310,5,5);
 SinglePlayerGUI.canvas.RoundRect(500,320,700,360,5,5);
 SinglePlayerGUI.canvas.Font.Color:=$F0F0F0;
 SinglePlayerGUI.Canvas.Font.Size:=16;
 SinglePlayerGUI.Canvas.Font.Bold:=true;
 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),555,278,getfromlangpack('select'));
 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),560,328,getfromlangpack('cancel'));


 msgskinchangeleftX:=500;
 msgskinchangeleftX2:=700;
 msgskinchangeleftY:=270;
 msgskinchangeleftY2:=310;
 if fileexists(SinglePlayerDir+SinglePlayerSettings.skindir+workskin+'\icons\preview.bmp') then SinglePlayerGUI.Canvas.Draw(50,95,prewskin);
 if fileexists(SinglePlayerDir+SinglePlayerSettings.skindir+workskin+'\skcfg.cfg') then
  begin
   SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),470,100,getfromlangpack('name')+skinname,textstyle);
   SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),470,150,getfromlangpack('author')+skinauthor,textstyle);
   SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),470,200,getfromlangpack('version')+skinversion,textstyle);
  end;
 SinglePlayerGUI.Canvas.Font.Bold:=False;
end;

procedure setskin(skinname:string);
var
  i:integer;
begin
if pos(playerversion+';',playerversionstr)=0 then
 begin
  showmessage(getfromlangpack('skinversfiled'));
  msgtap:=0;
  SinglePlayerGUI.Invalidate;
  exit;
 end;

SinglePlayerGUI.Canvas.Clear;
curentpage:='loader';
SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),150,340,getfromlangpack('skinload'));
SinglePlayerGUI.Invalidate;
for i:=1 to allicons do
 begin
 try
  if (assigned(playericon[i])) or (playericon[i]<>nil)  then playericon[i].Free;
 except
  LogAndExitPlayer(getfromlangpack('cleariconerr')+seticons[i].caption,0,0);
 end;
 try
  if (assigned(clickplayericon[i])) or (clickplayericon[i]<>nil) then clickplayericon[i].Free;
 except
  LogAndExitPlayer(getfromlangpack('cleariconerr')+seticons[i].clickiconcaption,0,0);
 end;
  playericon[i]:=nil;
  clickplayericon[i]:=nil;
  seticons[i].caption:='';
  seticons[i].clickiconcaption:='';
  seticons[i].exec:='';
  seticons[i].text:='';
  seticons[i].typeicon:='';
  seticons[i].width:=0;
  seticons[i].height:=0;
 end;
SinglePlayerSettings.skin:=skinname;
//if IniReadString(SettIniMas,'SinglePlayer','skin','-')<>SinglePlayerSettings.skin then PlayerSettingsINI.WriteString('SinglePlayer','skin',SinglePlayerSettings.skin);
LoadPlayerSkin(0);
LoadIconPlayer;
msgtap:=0;
curentpage:='singleplayer';
progresscor[1,1]:=0; {перечитывание координат прогрессбара}
SinglePlayerGUI.Invalidate;
end;


Procedure BigLog(str:string);
var
logfile:textfile;
begin
assignfile(logfile,ExtractFilePath(Application.ExeName)+'BigLog.txt');
 if fileexists(ExtractFilePath(Application.ExeName)+'BigLog.txt') = false then
  begin
   try
    rewrite(logfile);
    writeln(logfile,datetimetostr(now)+'    '+str);
    closefile(logfile);
   except
    LogAndExitPlayer('biglog file not created, run this programm as administarator!1',0,0);
   end;
  end else
  begin
   try
    append(logfile);
    writeln(logfile,datetimetostr(now)+'    '+str);
    closefile(logfile);
   except
    LogAndExitPlayer('biglog file not created, run this programm as administarator!2',0,0);
   end;
  end;
end;

Procedure LogAndExitPlayer(str:string;showmess:byte;closeplayer:byte);
var
  logfile:textfile;
begin
 if showmess=1 then showmessage(str);     //показать сообщение об ошибке
 {-------------------- записать ошибку в файл лога ---------------------------}
 assignfile(logfile,ExtractFilePath(ParamStr(0))+'playerlog.txt');
 try
  if fileexists(ExtractFilePath(ParamStr(0))+'playerlog.txt') then append(logfile) else rewrite(logfile);
  writeln(logfile,datetimetostr(now)+'    '+UTF8Decode(str));
  closefile(logfile);
 except
  showmessage('log file not created, run this programm as administrator!');
  PlayerExit;
 end;
{------------------------------------------------------------------------------}
 if closeplayer=1 then PlayerExit;          //закрыть плеер
end;

procedure manyaddon;
begin
 plsettingsznach[1,9]:='1';
 SinglePlayerSettings.manyadd:=1;
end;

procedure manyaddoff;
begin
plsettingsznach[1,9]:='0';
SinglePlayerSettings.manyadd:=0;
clearmanymass;
end;

procedure manyaddstart;
begin
if tempallkolltrack<>0 then
 begin
  addmarked:=addmarkedp.Create(true);
  addmarked.freeonterminate := true;
  addmarked.priority := tpnormal;    {tpIdle tpLowest tpLower tpNormal tpHigher tpHighest tpTimeCritical}
  addmarked.Start;
 end;
end;

procedure addmarkedp.Execute;
var
plfile:textfile;
i:integer;
begin
try
if statusplaylist=0 then
  begin
   statusplaylist:=1;
   SinglePlayerGUI.Canvas.Font.Color:=plset.statustextcolor;
   SinglePlayerGUI.Canvas.Font.Size:=plset.statustextsize;
   application.ProcessMessages;
   SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),myalign(plset.statustextleft,getfromlangpack('saveplaylist'),1),plset.statustexttop,getfromlangpack('saveplaylist'));
   assignfile(plfile,SinglePlayerDir+'playlist_'+inttostr(SinglePlayerSettings.curentplaylist)+'.pls');
   try
    if playlistadd=0 then rewrite(plfile); //очищаем плейлист и создаем новый
    if playlistadd=1 then //добавляем в существующий плейлист
      begin
       if fileexists(SinglePlayerDir+'playlist_'+inttostr(SinglePlayerSettings.curentplaylist)+'.pls') then append(plfile) else rewrite(plfile);
      end;
    if fileispls=0 then      //если выбранный файл не плейлист то
     begin
      for i:=1 to tempallkolltrack do if temptrackmas[i]<>'' then writeln(plfile,temptrackmas[i]);
     end else               //если выбранный файл это плейлист
     begin
     for i:=1 to length(m3uplsmass)-1 do if m3uplsmass[i,1]<>'' then writeln(plfile,m3uplsmass[i,1]);
     end;
    closefile(plfile);
    statusplaylist:=0;
    playlistread(SinglePlayerSettings.curentplaylist);

    if curenttrack='' then
      begin
       SinglePlayerSettings.curpos:=-1;
       curenttrack:=track[1];
       SinglePlayerSettings.playedtrack:=gettrackindexbuf(curenttrack);
       if (track[1]<>'') and (SinglePlayerSettings.playedtrack=0) then SinglePlayerSettings.playedtrack:=1;
      end;
    if playlistadd=0 then
    begin
      if itfolder=1 then SingleplayerSettings.playedtrack:=1 else SingleplayerSettings.playedtrack:=gettrackindex(curenttrack);     //если выбран каталог, то играть 1 трек, иначе играть выбранный трек
      mode:=play;
      SinglePlayerSettings.curpos:=-1;
      curenttrack:=track[SingleplayerSettings.playedtrack];
      itelmaplay(curenttrack);
    end;
   except
    statusplaylist:=0;
    closefile(plfile);
    clearmanymass;
    LogAndExitPlayer('Ошибка создания плейлиста с выбранными подкаталогами',0,0);
    application.ProcessMessages;
    addmarked.Free;
   end;
  end;

 if SinglePlayerSettings.sorttrue=1 then   //если включена сортировка
   begin
    statusplaylist:=0;
    sortplaylistthead;
   end;

 clearmanymass;
 if singleplayersettings.closeaftadd=1 then
  begin
   curentpage:='singleplayer';
   SinglePlayerGUI.Invalidate;
  end;
 application.ProcessMessages;
 addmarked.Free;
 except
  clearmanymass;
  statusplaylist:=0;
  LogAndExitPlayer('Ошибка добавления треков при множественном выборе. addmarkedp.Execute',0,0);
  application.ProcessMessages;
  addmarked.Free;
 end;
end;

procedure findmarkedp.Execute;
var
 plfile:textfile;
const
  ArrExt : array[1..7] of ansistring = ( '.mp3', '.wav','.ogg','.flac','.aiff','.m4a','.mpc');
begin
  EnumFolders(findmarked.findddir, ArrExt, plfile{%H-},1);
  scanningstr:='';
  application.ProcessMessages;
  if singleplayersettings.manyadd=0 then manyaddstart;
  findmarked.Free;
end;


procedure clearmanymass;
var
i:integer;
begin
 for i:=1 to tempallkolltrack do temptrackmas[i]:='';
 tempallkolltrack:=0;
 for i:=1 to fdir do fdirmass[i]:='';
 fdir:=0;
end;

procedure keyboardtext;
var
 i,j,xkey,ykey,keyheight,keywidth,keyras,nextryad,nomkl,topfind:smallint;
begin
xkey:=plset.xkey;   //начало клавиш
ykey:=plset.ykey;  //верх клавиш
keywidth:=plset.keywidth;   //ширина клавиш
keyheight:=plset.keyheight;  //высота клавиш
keyras:=plset.keyras;     //расстояние между клавишами
nextryad:=plset.nextryad;  //расстояние между рядами
finded:=1;
finded2:=1;
if nextplayplsshow=1 then         //отображать окно очереди треков
 begin
  topfind:=plset.topochered;
  SinglePlayerGUI.Canvas.Font.Color:=plset.ocheredstrtextcolor;
  SinglePlayerGUI.Canvas.Font.Size:=plset.ocheredstrtextsize;
  SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),plset.ocheredstrleft,plset.ocheredstrtop,getfromlangpack('queue'));
  SinglePlayerGUI.Canvas.Font.Color:=plset.ocheredtextcolor;
  SinglePlayerGUI.Canvas.Font.Size:=plset.ocheredtextsize;
  SinglePlayerGUI.canvas.pen.Color:=plset.ocheredbordercolor;   //цвет рамки
  SinglePlayerGUI.canvas.Brush.Color:=plset.ocheredcolor;  //цвет фона

  for i:=1 to length(nextplaytrackmass)-1 do
   begin
    if topfind<plset.bottomochered then
     begin
        if nachfind<>finded then
          begin
           if nachfind>finded then inc(finded) else dec(finded);
           finded2:=finded;
           continue;
          end;
        findtrackcor[finded2,1]:=i;
        findtrackcor[finded2,2]:=plset.searchrespoleleft;
        findtrackcor[finded2,3]:=topfind+plset.searchrespoletop;
        findtrackcor[finded2,4]:=plset.searchrespoleright;
        findtrackcor[finded2,5]:=topfind+plset.vertrasfind+plset.searchrespolebottom;
        SinglePlayerGUI.canvas.RoundRect(findtrackcor[finded2,2],findtrackcor[finded2,3],findtrackcor[finded2,4],findtrackcor[finded2,5],0,0);
        SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),plset.leftfind,topfind,inttostr(i));
        SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),plset.leftfind+50,topfind,UTF8Encode(ExtractFileName(nextplaytrackmass[i])),textstyle);
        inc(finded2);
        inc(topfind,plset.vertrasfind);
     end else break;  //если строки не вмещаются, остановить  поиск
   end;

 end else
 begin                                  //отображать окно поиска треков
topfind:=plset.topfind;
SinglePlayerGUI.Canvas.Font.Color:=plset.srcstrtextcolor;
SinglePlayerGUI.Canvas.Font.Size:=plset.srcstrtextsize;
SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),plset.srcstrleft,plset.srcstrtop,getfromlangpack('searchtrackinpls'));

SinglePlayerGUI.canvas.pen.Color:=plset.tracksearchbordercolor;   //цвет рамки
SinglePlayerGUI.canvas.Brush.Color:=plset.tracksearchcolor;  //цвет фона
SinglePlayerGUI.canvas.RoundRect(plset.tracksearchpoleleft,plset.tracksearchpoletop,plset.tracksearchpoleleft+plset.tracksearchpolewidth,plset.tracksearchpoletop+plset.tracksearchpoleheight,30,20);
SinglePlayerGUI.Canvas.Font.Color:=plset.tracksearchtextcolor;
SinglePlayerGUI.Canvas.Font.Size:=plset.tracksearchtextsize;
SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),plset.tracksearchleft,plset.tracksearchtop,tracksearchstr);
{----------------------- клавиатура ----------------------------}
SinglePlayerGUI.canvas.pen.Color:=plset.keyboardbordercolor;   //цвет рамки
SinglePlayerGUI.canvas.Brush.Color:=plset.keyboardcolor;  //цвет фона
SinglePlayerGUI.canvas.RoundRect(plset.keyboardleft,plset.keyboardtop,plset.keyboardleft+plset.keyboardwidth,plset.keyboardtop+plset.keyboardheight,30,20);
{---------------------------------------------------------------}
{----------------------- клавиши букв --------------------------}
SinglePlayerGUI.canvas.pen.Color:=plset.keybordercolor;   //цвет рамки
SinglePlayerGUI.canvas.Brush.Color:=plset.keycolor;  //цвет фона
SinglePlayerGUI.Canvas.Font.Color:=plset.keytextcolor;
SinglePlayerGUI.Canvas.Font.Size:=plset.keytextsize;
nomkl:=0;
for j:=1 to plset.maxkolryad do
 begin
  for i:=1 to plset.maxkeysinryad do
   begin
    inc(nomkl);
    SinglePlayerGUI.canvas.RoundRect(xkey,ykey,xkey+keywidth,ykey+keyheight,20,20);
    SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),xkey+plset.wordleft,ykey+plset.wordtop,keysmass[nomkl,keyboardmode]);
    keysmass[nomkl,maxraskl+1]:=inttostr(xkey);
    keysmass[nomkl,maxraskl+2]:=inttostr(ykey);
    keysmass[nomkl,maxraskl+3]:=inttostr(xkey+keywidth);
    keysmass[nomkl,maxraskl+4]:=inttostr(ykey+keyheight);
    xkey:=xkey+keywidth+keyras;
   end;
  xkey:=plset.xkey;
  ykey:=ykey+keyheight+nextryad;
 end;
{---------------------------------------------------------------}
SinglePlayerGUI.Canvas.Font.Color:=plset.searchrestextcolor;
SinglePlayerGUI.Canvas.Font.Size:=plset.searchrestextsize;
SinglePlayerGUI.canvas.pen.Color:=plset.searchresbordercolor;   //цвет рамки
SinglePlayerGUI.canvas.Brush.Color:=plset.searchrescolor;  //цвет фона

if singleplayersettings.searchintag=0 then
 begin
if singleplayersettings.inallpls=0 then //искать в текущем плейлисте
 begin
  for i:=1 to singleplayersettings.kolltrack do
   begin
    if pos(trim(tracksearchstr),UTF8Encode(ansiUpperCase(changefileext(ExtractFileName(track[i]),''))))<>0 then
     begin
      if nachfind<>finded then
        begin
         if nachfind>finded then inc(finded) else dec(finded);
         finded2:=finded;
         continue;
        end;
      findtrackcor[finded2,1]:=i;
      findtrackcor[finded2,2]:=plset.searchrespoleleft;
      findtrackcor[finded2,3]:=topfind+plset.searchrespoletop;
      findtrackcor[finded2,4]:=plset.searchrespoleright;
      findtrackcor[finded2,5]:=topfind+plset.vertrasfind+plset.searchrespolebottom;
      if topfind<plset.bottomfind then
       begin
        SinglePlayerGUI.canvas.RoundRect(findtrackcor[finded2,2],findtrackcor[finded2,3],findtrackcor[finded2,4],findtrackcor[finded2,5],0,0);
        SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),plset.leftfind,topfind,inttostr(i));
        SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),plset.leftfind+50,topfind,UTF8Encode(ExtractFileName(track[i])),textstyle);
       end;
      inc(finded2);
      inc(topfind,plset.vertrasfind);
     end;
   end;
  end else
  begin
  for i:=1 to length(allplstrack)-1 do
   begin
      if pos(trim(tracksearchstr),UTF8Encode(ansiUpperCase(changefileext(ExtractFileName(allplstrack[i].Track),''))))<>0 then
       begin
        if nachfind<>finded then
          begin
           if nachfind>finded then inc(finded) else dec(finded);
           finded2:=finded;
           continue;
          end;
        findtrackcor[finded2,1]:=i;
        findtrackcor[finded2,2]:=plset.searchrespoleleft;
        findtrackcor[finded2,3]:=topfind+plset.searchrespoletop;
        findtrackcor[finded2,4]:=plset.searchrespoleright;
        findtrackcor[finded2,5]:=topfind+plset.vertrasfind+plset.searchrespolebottom;
        if topfind<plset.bottomfind then
         begin
          SinglePlayerGUI.canvas.RoundRect(findtrackcor[finded2,2],findtrackcor[finded2,3],findtrackcor[finded2,4],findtrackcor[finded2,5],0,0);
          SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),plset.leftfind,topfind,inttostr(allplstrack[i].Playlist)+' '+inttostr(allplstrack[i].Number));
          SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),plset.leftfind+70,topfind,UTF8Encode(ExtractFileName(allplstrack[i].Track)),textstyle);
         end;
        inc(finded2);
        inc(topfind,plset.vertrasfind);
       end;
   end;
 end; //если искать во всех плейлистах
  end else
  begin
     for i:=1 to length(tagmass)-1 do
      begin
         if pos(trim(tracksearchstr),UTF8Encode(ansiUpperCase(tagmass[i,1])))<>0 then
          begin
         if nachfind<>finded then
           begin
            if nachfind>finded then inc(finded) else dec(finded);
            finded2:=finded;
            continue;
           end;
         findtrackcor[finded2,1]:=i;
         findtrackcor[finded2,2]:=plset.searchrespoleleft;
         findtrackcor[finded2,3]:=topfind+plset.searchrespoletop;
         findtrackcor[finded2,4]:=plset.searchrespoleright;
         findtrackcor[finded2,5]:=topfind+plset.vertrasfind+plset.searchrespolebottom;
         if topfind<plset.bottomfind then
          begin
           SinglePlayerGUI.canvas.RoundRect(findtrackcor[finded2,2],findtrackcor[finded2,3],findtrackcor[finded2,4],findtrackcor[finded2,5],0,0);
           if singleplayersettings.inallpls=0 then
             SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),plset.leftfind,topfind,inttostr(i))
           else
             SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),plset.leftfind,topfind,tagmass[i,3]+' '+tagmass[i,4]);
           SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),plset.leftfind+70,topfind,UTF8Encode(tagmass[i,1]),textstyle);
          end;
         inc(finded2);
         inc(topfind,plset.vertrasfind);
        end;
      end;
  end;

end;  // если отключен режим  списка очереди

{-------- выбранный трек ------------------------}
if entertrack<>0 then
 begin
  SinglePlayerGUI.Canvas.Font.Color:=plset.searchresentertextcolor;
  SinglePlayerGUI.Canvas.Font.Size:=plset.searchresentertextsize;
  SinglePlayerGUI.canvas.pen.Color:=plset.searchresenterpolebordercolor;   //цвет рамки
  SinglePlayerGUI.canvas.Brush.Color:=plset.searchresenterpolecolor;  //цвет фона
  SinglePlayerGUI.canvas.RoundRect(findtrackcor[entertrack,2],findtrackcor[entertrack,3],findtrackcor[entertrack,4],findtrackcor[entertrack,5],0,0);
  if (nextplayplsshow=1) or (singleplayersettings.inallpls=0) then
    SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),plset.leftfind,findtrackcor[entertrack,3]-plset.searchrespoletop,inttostr(findtrackcor[entertrack,1]))
  else
  if singleplayersettings.searchintag=0 then
    SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),plset.leftfind,findtrackcor[entertrack,3]-plset.searchrespoletop,inttostr(allplstrack[findtrackcor[entertrack,1]].Playlist)+' '+inttostr(allplstrack[findtrackcor[entertrack,1]].Number))
  else
    SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),plset.leftfind,findtrackcor[entertrack,3]-plset.searchrespoletop,tagmass[findtrackcor[entertrack,1],3]+' '+tagmass[findtrackcor[entertrack,1],4]);
  if nextplayplsshow=0 then
   begin
    if singleplayersettings.searchintag=0 then
     begin
      if singleplayersettings.inallpls=0 then SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),plset.leftfind+50,findtrackcor[entertrack,3]-plset.searchrespoletop,UTF8Encode(ExtractFileName(track[findtrackcor[entertrack,1]])),textstyle) else
      SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),plset.leftfind+70,findtrackcor[entertrack,3]-plset.searchrespoletop,UTF8Encode(ExtractFileName(allplstrack[findtrackcor[entertrack,1]].Track)),textstyle);
     end else SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),plset.leftfind+70,findtrackcor[entertrack,3]-plset.searchrespoletop,UTF8Encode(ExtractFileName(tagmass[findtrackcor[entertrack,1],2])),textstyle);
   end else SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),plset.leftfind+50,findtrackcor[entertrack,3]-plset.searchrespoletop,UTF8Encode(ExtractFileName(nextplaytrackmass[findtrackcor[entertrack,1]])),textstyle);
end;
SinglePlayerGUI.Canvas.Font.Color:=plset.scanstatustextcolor;
SinglePlayerGUI.Canvas.Font.Size:=plset.scanstatustextsize;
SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),plset.scanstatustextleft,plset.scanstatustexttop,scanningstr);
{------------------------------------------------}
end;

function gettagtofind(track:string): string;
begin
 track:=lowercase(track);
 result:=changefileext(ExtractFileName(track),'');
 thisTagv2.Clear;
 if ((length(track)-pos('.flac',track)=4) and (pos('.flac',track)<>0)) or ((length(track)-pos('.m4a',track)=3) and (pos('.m4a',track)<>0)) or ((length(track)-pos('.mpc',track)=3) and (pos('.mpc',track)<>0)) then exit else thisTagv2.ReadFromFile(track);
 if (thisTagv2.Title='') and (thisTagv2.artist='') then exit;
 result:=UTF8Encode(thisTagv2.Artist)+' - '+UTF8Encode(thisTagv2.Title);
end;

procedure formtagmass(mode:byte);
var
 i,stk,TrkNum:integer;
 allplsfile:textfile;
 searchstr:string;
begin
 stk:=0;
 tagmass:=nil;
 scanningstr:=getfromlangpack('scantags');
 Application.ProcessMessages;
 if mode=0 then
  begin
   for i:=1 to singleplayersettings.kolltrack do
    begin
     setlength(tagmass,i+1,5);
     tagmass[i,1]:=gettagtofind(track[i]);
     tagmass[i,2]:=track[i];
    end;
  end else
  begin
  for i:=1 to kollpls do
   begin
    if fileexists(SinglePlayerDir+'playlist_'+inttostr(i)+'.pls') then
     begin
      assignfile(allplsfile,SinglePlayerDir+'playlist_'+inttostr(i)+'.pls');
      reset(allplsfile);
      TrkNum:=0;
      while not eof(allplsfile) do
        begin
         readln(allplsfile,searchstr);
         inc(stk);
         Inc(TrkNum);
         setlength(tagmass,stk+1,5);
         tagmass[stk,1]:=gettagtofind(searchstr);
         tagmass[stk,2]:=searchstr;
         tagmass[stk,3]:=IntToStr(i);
         tagmass[stk,4]:=IntToStr(TrkNum);
        end;
       closefile(allplsfile);
    end;
   end;
  end;
  scanningstr:='';
  SinglePlayerGUI.Invalidate;
  application.ProcessMessages;
end;

procedure readallplstrack;
var
 i,stk,CurTrack:integer;
 allplsfile:textfile;
 searchstr:string;
begin
allplstrack:=nil;
stk:=0;
scanningstr:=getfromlangpack('scanfiles');
Application.ProcessMessages;
for i:=1 to kollpls do
 begin
  if fileexists(SinglePlayerDir+'playlist_'+inttostr(i)+'.pls') then
   begin
    assignfile(allplsfile,SinglePlayerDir+'playlist_'+inttostr(i)+'.pls');
    reset(allplsfile);
    CurTrack:=0;
    while not eof(allplsfile) do
      begin
       readln(allplsfile,searchstr);
       inc(stk);
       inc(CurTrack);
       setlength(allplstrack,stk+1);
       allplstrack[stk].Track:=searchstr;
       allplstrack[stk].Playlist:=i;
       allplstrack[stk].Number:=CurTrack;
      end;
     closefile(allplsfile);
  end;
 end;
scanningstr:='';
SinglePlayerGUI.Invalidate;
Application.ProcessMessages;
end;

procedure addtonext(nexttrack:integer);
begin
if singleplayersettings.searchintag = 0 then
 begin
 if singleplayersettings.inallpls=0 then
  begin
   if (track[findtrackcor[nexttrack,1]]<>'') and (entertrack<>0) then
    begin
     inc(kollnexttrack);
     setlength(nextplaytrackmass,kollnexttrack+1);
     nextplaytrackmass[kollnexttrack]:=track[findtrackcor[nexttrack,1]];
     exit;
    end;
  end else
  begin
   if (allplstrack[findtrackcor[nexttrack,1]].Track<>'') and (entertrack<>0) then
    begin
     inc(kollnexttrack);
     setlength(nextplaytrackmass,kollnexttrack+1);
     nextplaytrackmass[kollnexttrack]:=allplstrack[findtrackcor[nexttrack,1]].Track;
     exit;
    end;
  end;
 end else
 begin
  if (tagmass[findtrackcor[nexttrack,1],2]<>'') and (entertrack<>0) then
   begin
    inc(kollnexttrack);
    setlength(nextplaytrackmass,kollnexttrack+1);
    nextplaytrackmass[kollnexttrack]:=tagmass[findtrackcor[nexttrack,1],2];
    exit;
   end;
 end;
end;

procedure addtonextall;
var
 i:integer;
begin
 for i:=1 to finded2-1 do
  begin
   if singleplayersettings.searchintag = 0 then
    begin
     if singleplayersettings.inallpls=0 then
      begin
       if track[findtrackcor[i,1]]<>'' then
        begin
         inc(kollnexttrack);
         setlength(nextplaytrackmass,kollnexttrack+1);
         nextplaytrackmass[kollnexttrack]:=track[findtrackcor[i,1]];
        end;
        end else
        begin
         if allplstrack[findtrackcor[i,1]].Track<>'' then
          begin
           inc(kollnexttrack);
           setlength(nextplaytrackmass,kollnexttrack+1);
           nextplaytrackmass[kollnexttrack]:=allplstrack[findtrackcor[i,1]].Track;
          end;
        end;
    end else
    begin
     if tagmass[findtrackcor[i,1],2]<>'' then
      begin
       inc(kollnexttrack);
       setlength(nextplaytrackmass,kollnexttrack+1);
       nextplaytrackmass[kollnexttrack]:=tagmass[findtrackcor[i,1],2];
      end;
    end;
  end;
end;

procedure randomizepls;
var
 i,nom:integer;
 str:string;
begin
 try
 for i:=singleplayersettings.kolltrack downto 2 do
  begin
   nom := random(i)+1;
   str:=track[i];
   track[i]:=track[nom];
   track[nom]:=str;
  end;
 SinglePlayerSettings.playedtrack:=gettrackindex(curenttrack);
 saveplaylist;
 SinglePlayerGUI.Invalidate;
  except
   LogAndExitPlayer('Ошибка в продедуре randomizepls',0,0);
  end;
end;

procedure effectedit(eff:string);
var
 eqpage:byte;
begin
 try
  SinglePlayerGUI.Canvas.Font.Color:=plset.srcstrtextcolor;
  SinglePlayerGUI.Canvas.Font.Size:=12;
  SinglePlayerGUI.canvas.pen.Color:=plset.searchresenterpolebordercolor;   //цвет рамки
  SinglePlayerGUI.canvas.Brush.Color:=plset.searchresenterpolecolor;  //цвет фона

  eqpage:=0;

  case eff of
  'p1': begin eqpage:=1; end;
  'p2': begin eqpage:=2; end;
  'p3': begin eqpage:=3; end;
  'p4': begin eqpage:=4; end;
  'p5': begin eqpage:=5; end;
  'p6': begin eqpage:=6; end;
  'p7': begin eqpage:=7; end;
  'p8': begin eqpage:=8; end;
  'p9': begin eqpage:=9; end;
  'p10': begin eqpage:=10; end;
  'p11': begin eqpage:=11; end;
  'p12': begin eqpage:=12; end;
  'p13': begin eqpage:=13; end;

  'bqflow': begin
             SinglePlayerGUI.canvas.RoundRect(10,top1,790,top1+2,0,0);
             SinglePlayerGUI.canvas.RoundRect(coordfromfreq(RealToInt(bqflowparam.fCenter,0)),top1-10,coordfromfreq(RealToInt(bqflowparam.fCenter,0))+60,top1+12,0,0);
             SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top1-40,getfromlangpack('frequency'));
             SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromfreq(RealToInt(bqflowparam.fCenter,0))-(SinglePlayerGUI.Canvas.TextWidth(realtostr(bqflowparam.fCenter,0)) div 2)+30,top1-9,realtostr(bqflowparam.fCenter,0));

             SinglePlayerGUI.canvas.RoundRect(10,top3,790,top3+2,0,0);
             SinglePlayerGUI.canvas.RoundRect(coordfromznach(bqflowparam.fq,10,0,10),top3-10,coordfromznach(bqflowparam.fq,10,0,10)+60,top3+12,0,0);
             SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top3-40,getfromlangpack('freqresonance'));
             SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(bqflowparam.fq,10,0,10)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(bqflowparam.fq,1)) div 2)+30,top3-9,realtostr(bqflowparam.fq,1));

             SinglePlayerGUI.canvas.RoundRect(10,top6,790,top6+2,0,0);
             SinglePlayerGUI.canvas.RoundRect(coordfromznach(bqflowparam.fbandwidth,10,0,10),top6-10,coordfromznach(bqflowparam.fbandwidth,10,0,10)+60,top6+12,0,0);
             SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top6-40,getfromlangpack('bandpassfilter'));
             SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(bqflowparam.fbandwidth,10,0,10)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(bqflowparam.fbandwidth,1)) div 2)+30,top6-9,realtostr(bqflowparam.fbandwidth,1));
             exit;
            end;
 'bqfhigh': begin
             SinglePlayerGUI.canvas.RoundRect(10,top1,790,top1+2,0,0);
             SinglePlayerGUI.canvas.RoundRect(coordfromfreq(RealToInt(bqfhighparam.fCenter,0)),top1-10,coordfromfreq(RealToInt(bqfhighparam.fCenter,0))+60,top1+12,0,0);
             SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top1-40,getfromlangpack('freqlow'));
             SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromfreq(RealToInt(bqfhighparam.fCenter,0))-(SinglePlayerGUI.Canvas.TextWidth(realtostr(bqfhighparam.fCenter,0)) div 2)+30,top1-9,realtostr(bqfhighparam.fCenter,0));

             SinglePlayerGUI.canvas.RoundRect(10,top3,790,top3+2,0,0);
             SinglePlayerGUI.canvas.RoundRect(coordfromznach(bqfhighparam.fq,10,0,10),top3-10,coordfromznach(bqfhighparam.fq,10,0,10)+60,top3+12,0,0);
             SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top3-40,getfromlangpack('freqresonance'));
             SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(bqfhighparam.fq,10,0,10)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(bqfhighparam.fq,1)) div 2)+30,top3-9,realtostr(bqfhighparam.fq,1));

             SinglePlayerGUI.canvas.RoundRect(10,top6,790,top6+2,0,0);
             SinglePlayerGUI.canvas.RoundRect(coordfromznach(bqfhighparam.fbandwidth,10,0,10),top6-10,coordfromznach(bqfhighparam.fbandwidth,10,0,10)+60,top6+12,0,0);
             SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top6-40,getfromlangpack('bandpassfilter'));
             SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(bqfhighparam.fbandwidth,10,0,10)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(bqfhighparam.fbandwidth,1)) div 2)+30,top6-9,realtostr(bqfhighparam.fbandwidth,1));
             exit;
            end;
 'bqfpeakingeq': begin
                  SinglePlayerGUI.canvas.RoundRect(10,top1,790,top1+2,0,0);
                  SinglePlayerGUI.canvas.RoundRect(coordfromfreq(RealToInt(bqfPEAKINGEQparam.fCenter,0)),top1-10,coordfromfreq(RealToInt(bqfPEAKINGEQparam.fCenter,0))+60,top1+12,0,0);
                  SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top1-40,getfromlangpack('freqbellshaped'));
                  SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromfreq(RealToInt(bqfPEAKINGEQparam.fCenter,0))-(SinglePlayerGUI.Canvas.TextWidth(realtostr(bqfPEAKINGEQparam.fCenter,0)) div 2)+30,top1-9,realtostr(bqfPEAKINGEQparam.fCenter,0));

                  SinglePlayerGUI.canvas.RoundRect(10,top2,790,top2+2,0,0);
                  SinglePlayerGUI.canvas.RoundRect(coordfromznach(bqfPEAKINGEQparam.fgain,10,-60,60),top2-10,coordfromznach(bqfPEAKINGEQparam.fgain,10,-60,60)+60,top2+12,0,0);
                  SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top2-40,getfromlangpack('gainbellshaped'));
                  SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(bqfPEAKINGEQparam.fgain,10,-60,60)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(bqfPEAKINGEQparam.fgain,0)) div 2)+30,top2-9,realtostr(bqfPEAKINGEQparam.fgain,0));


                  SinglePlayerGUI.canvas.RoundRect(10,top4,790,top4+2,0,0);
                  SinglePlayerGUI.canvas.RoundRect(coordfromznach(bqfPEAKINGEQparam.fbandwidth,10,0,10),top4-10,coordfromznach(bqfPEAKINGEQparam.fbandwidth,10,0,10)+60,top4+12,0,0);
                  SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top4-40,getfromlangpack('bandpassfilter'));
                  SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(bqfPEAKINGEQparam.fbandwidth,10,0,10)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(bqfPEAKINGEQparam.fbandwidth,1)) div 2)+30,top4-9,realtostr(bqfPEAKINGEQparam.fbandwidth,1));

                  SinglePlayerGUI.canvas.RoundRect(10,top6,790,top6+2,0,0);
                  SinglePlayerGUI.canvas.RoundRect(coordfromznach(bqfPEAKINGEQparam.fq,10,0,10),top6-10,coordfromznach(bqfPEAKINGEQparam.fq,10,0,10)+60,top6+12,0,0);
                  SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top6-40,getfromlangpack('bandwidthbsh'));
                  SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(bqfPEAKINGEQparam.fq,10,0,10)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(bqfPEAKINGEQparam.fq,1)) div 2)+30,top6-9,realtostr(bqfPEAKINGEQparam.fq,1));
                  exit;
                 end;
 'bqfbandpass': begin
                 SinglePlayerGUI.canvas.RoundRect(10,top1,790,top1+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromfreq(RealToInt(bqfBANDPASSparam.fCenter,0)),top1-10,coordfromfreq(RealToInt(bqfBANDPASSparam.fCenter,0))+60,top1+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top1-40,getfromlangpack('centerfreq'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromfreq(RealToInt(bqfBANDPASSparam.fCenter,0))-(SinglePlayerGUI.Canvas.TextWidth(realtostr(bqfBANDPASSparam.fCenter,0)) div 2)+30,top1-9,realtostr(bqfBANDPASSparam.fCenter,0));

                 SinglePlayerGUI.canvas.RoundRect(10,top3,790,top3+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(bqfBANDPASSparam.fq,10,0,10),top3-10,coordfromznach(bqfBANDPASSparam.fq,10,0,10)+60,top3+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top3-40,getfromlangpack('bandwidthfil'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(bqfBANDPASSparam.fq,10,0,10)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(bqfBANDPASSparam.fq,1)) div 2)+30,top3-9,realtostr(bqfBANDPASSparam.fq,1));

                 SinglePlayerGUI.canvas.RoundRect(10,top6,790,top6+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(bqfBANDPASSparam.fbandwidth,10,0,10),top6-10,coordfromznach(bqfBANDPASSparam.fbandwidth,10,0,10)+60,top6+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top6-40,getfromlangpack('bandpassfilter'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(bqfBANDPASSparam.fbandwidth,10,0,10)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(bqfBANDPASSparam.fbandwidth,1)) div 2)+30,top6-9,realtostr(bqfBANDPASSparam.fbandwidth,1));
                 exit;
                end;
 'bqfnotch': begin
                 SinglePlayerGUI.canvas.RoundRect(10,top1,790,top1+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromfreq(RealToInt(bqfnotchparam.fCenter,0)),top1-10,coordfromfreq(RealToInt(bqfnotchparam.fCenter,0))+60,top1+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top1-40,getfromlangpack('centerfreq'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromfreq(RealToInt(bqfnotchparam.fCenter,0))-(SinglePlayerGUI.Canvas.TextWidth(realtostr(bqfnotchparam.fCenter,0)) div 2)+30,top1-9,realtostr(bqfnotchparam.fCenter,0));

                 SinglePlayerGUI.canvas.RoundRect(10,top3,790,top3+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(bqfnotchparam.fq,10,0,10),top3-10,coordfromznach(bqfnotchparam.fq,10,0,10)+60,top3+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top3-40,getfromlangpack('bandwidthfil'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(bqfnotchparam.fq,10,0,10)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(bqfnotchparam.fq,1)) div 2)+30,top3-9,realtostr(bqfnotchparam.fq,1));

                 SinglePlayerGUI.canvas.RoundRect(10,top6,790,top6+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(bqfnotchparam.fbandwidth,10,0,10),top6-10,coordfromznach(bqfnotchparam.fbandwidth,10,0,10)+60,top6+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top6-40,getfromlangpack('bandpassfilter'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(bqfnotchparam.fbandwidth,10,0,10)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(bqfnotchparam.fbandwidth,1)) div 2)+30,top6-9,realtostr(bqfnotchparam.fbandwidth,1));
                 exit;
                end;
 'reverb': begin
                 SinglePlayerGUI.canvas.RoundRect(10,top1,790,top1+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(reverbparam.fInGain,10,-96,0),top1-10,coordfromznach(reverbparam.fInGain,10,-96,0)+60,top1+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top1-40,getfromlangpack('amplification'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(reverbparam.fInGain,10,-96,0)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(reverbparam.fInGain,0)) div 2)+30,top1-9,realtostr(reverbparam.fInGain,0));

                 SinglePlayerGUI.canvas.RoundRect(10,top2,790,top2+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(reverbparam.fReverbMix,10,-96,0),top2-10,coordfromznach(reverbparam.fReverbMix,10,-96,0)+60,top2+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top2-40,getfromlangpack('mix'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(reverbparam.fReverbMix,10,-96,0)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(reverbparam.fReverbMix,0)) div 2)+30,top2-9,realtostr(reverbparam.fReverbMix,0));

                 SinglePlayerGUI.canvas.RoundRect(10,top4,790,top4+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(reverbparam.fReverbTime,10,1,3000),top4-10,coordfromznach(reverbparam.fReverbTime,10,1,3000)+60,top4+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top4-40,getfromlangpack('reverbtime'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(reverbparam.fReverbTime,10,1,3000)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(reverbparam.fReverbTime,0)) div 2)+30,top4-9,realtostr(reverbparam.fReverbTime,0));

                 SinglePlayerGUI.canvas.RoundRect(10,top6,790,top6+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(reverbparam.fHighFreqRTRatio,10000,1,999),top6-10,coordfromznach(reverbparam.fHighFreqRTRatio,10000,1,999)+60,top6+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top6-40,getfromlangpack('reverbdur'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(reverbparam.fHighFreqRTRatio,10000,1,999)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(reverbparam.fHighFreqRTRatio,3)) div 2)+30,top6-9,realtostr(reverbparam.fHighFreqRTRatio,3));
                 exit;
                end;
  'echo': begin
                 SinglePlayerGUI.canvas.RoundRect(10,top1,790,top1+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(echoparam.fWetDryMix,10,0,100),top1-10,coordfromznach(echoparam.fWetDryMix,10,0,100)+60,top1+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top1-40,getfromlangpack('relsignal'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(echoparam.fWetDryMix,10,0,100)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(echoparam.fWetDryMix,0)) div 2)+30,top1-9,realtostr(echoparam.fWetDryMix,0));

                 SinglePlayerGUI.canvas.RoundRect(10,top2,790,top2+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(echoparam.fFeedback,10,0,100),top2-10,coordfromznach(echoparam.fFeedback,10,0,100)+60,top2+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top2-40,getfromlangpack('percentsignal'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(echoparam.fFeedback,10,0,100)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(echoparam.fFeedback,0)) div 2)+30,top2-9,realtostr(echoparam.fFeedback,0));

                 SinglePlayerGUI.canvas.RoundRect(10,top4,790,top4+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(echoparam.fLeftDelay,10,1,2000),top4-10,coordfromznach(echoparam.fLeftDelay,10,1,2000)+60,top4+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top4-40,getfromlangpack('leftdelay'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(echoparam.fLeftDelay,10,1,2000)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(echoparam.fLeftDelay,0)) div 2)+30,top4-9,realtostr(echoparam.fLeftDelay,0));

                 SinglePlayerGUI.canvas.RoundRect(10,top6,790,top6+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(echoparam.fRightDelay,10,1,2000),top6-10,coordfromznach(echoparam.fRightDelay,10,1,2000)+60,top6+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top6-40,getfromlangpack('rightdelay'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(echoparam.fRightDelay,10,1,2000)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(echoparam.fRightDelay,0)) div 2)+30,top6-9,realtostr(echoparam.fRightDelay,0));
                 exit;
                end;
  'chorus': begin
                 SinglePlayerGUI.canvas.RoundRect(10,top1,790,top1+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(chorusparam.fWetDryMix,10,0,100),top1-10,coordfromznach(chorusparam.fWetDryMix,10,0,100)+60,top1+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top1-40,getfromlangpack('relsignal'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(chorusparam.fWetDryMix,10,0,100)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(chorusparam.fWetDryMix,0)) div 2)+30,top1-9,realtostr(chorusparam.fWetDryMix,0));

                 SinglePlayerGUI.canvas.RoundRect(10,top3,790,top3+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(chorusparam.fDepth,10,0,100),top3-10,coordfromznach(chorusparam.fDepth,10,0,100)+60,top3+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top3-40,getfromlangpack('depthsignal'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(chorusparam.fDepth,10,0,100)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(chorusparam.fDepth,0)) div 2)+30,top3-9,realtostr(chorusparam.fDepth,0));

                 SinglePlayerGUI.canvas.RoundRect(10,top4,790,top4+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(chorusparam.fFeedback,10,-99,99),top4-10,coordfromznach(chorusparam.fFeedback,10,-99,99)+60,top4+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top4-40,getfromlangpack('percentsignal99'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(chorusparam.fFeedback,10,-99,99)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(chorusparam.fFeedback,0)) div 2)+30,top4-9,realtostr(chorusparam.fFeedback,0));

                 SinglePlayerGUI.canvas.RoundRect(10,top5,790,top5+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(chorusparam.fFrequency,10,0,10),top5-10,coordfromznach(chorusparam.fFrequency,10,0,10)+60,top5+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top5-40,getfromlangpack('lowfreq'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(chorusparam.fFrequency,10,0,10)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(chorusparam.fFrequency,1)) div 2)+30,top5-9,realtostr(chorusparam.fFrequency,1));

                 SinglePlayerGUI.canvas.RoundRect(10,top6,790,top6+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(chorusparam.fDelay,10,0,20),top6-10,coordfromznach(chorusparam.fDelay,10,0,20)+60,top6+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top6-40,getfromlangpack('delaysignal20'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(chorusparam.fDelay,10,0,20)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(chorusparam.fDelay,0)) div 2)+30,top6-9,realtostr(chorusparam.fDelay,0));
                 exit;
                end;
  'flanger': begin
                 SinglePlayerGUI.canvas.RoundRect(10,top1,790,top1+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(flangerparam.fWetDryMix,10,0,100),top1-10,coordfromznach(flangerparam.fWetDryMix,10,0,100)+60,top1+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top1-40,getfromlangpack('relsignal'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(flangerparam.fWetDryMix,10,0,100)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(flangerparam.fWetDryMix,0)) div 2)+30,top1-9,realtostr(flangerparam.fWetDryMix,0));

                 SinglePlayerGUI.canvas.RoundRect(10,top3,790,top3+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(flangerparam.fDepth,10,0,100),top3-10,coordfromznach(flangerparam.fDepth,10,0,100)+60,top3+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top3-40,getfromlangpack('depthsignal'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(flangerparam.fDepth,10,0,100)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(flangerparam.fDepth,0)) div 2)+30,top3-9,realtostr(flangerparam.fDepth,0));

                 SinglePlayerGUI.canvas.RoundRect(10,top4,790,top4+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(flangerparam.fFeedback,10,-99,99),top4-10,coordfromznach(flangerparam.fFeedback,10,-99,99)+60,top4+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top4-40,getfromlangpack('percentsignal99'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(flangerparam.fFeedback,10,-99,99)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(flangerparam.fFeedback,0)) div 2)+30,top4-9,realtostr(flangerparam.fFeedback,0));

                 SinglePlayerGUI.canvas.RoundRect(10,top5,790,top5+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(flangerparam.fFrequency,10,0,10),top5-10,coordfromznach(flangerparam.fFrequency,10,0,10)+60,top5+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top5-40,getfromlangpack('lowfreq'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(flangerparam.fFrequency,10,0,10)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(flangerparam.fFrequency,1)) div 2)+30,top5-9,realtostr(flangerparam.fFrequency,1));

                 SinglePlayerGUI.canvas.RoundRect(10,top6,790,top6+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(flangerparam.fDelay,10,0,4),top6-10,coordfromznach(flangerparam.fDelay,10,0,4)+60,top6+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top6-40,getfromlangpack('delaysignal4'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(flangerparam.fDelay,10,0,4)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(flangerparam.fDelay,0)) div 2)+30,top6-9,realtostr(flangerparam.fDelay,0));
                 exit;
                end;
  'tempo': begin
            SinglePlayerGUI.canvas.RoundRect(10,top1,790,top1+2,0,0);
            SinglePlayerGUI.canvas.RoundRect(coordfromznach(strtointdef(SinglePlayerSettings.ezf[18,1],0),10,-100,100),top1-10,coordfromznach(strtointdef(SinglePlayerSettings.ezf[18,1],0),10,-100,100)+60,top1+12,0,0);
            SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top1-40,getfromlangpack('speedstream'));
            SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(strtointdef(SinglePlayerSettings.ezf[18,1],0),10,-100,100)-(SinglePlayerGUI.Canvas.TextWidth(SinglePlayerSettings.ezf[18,1]) div 2)+30,top1-9,SinglePlayerSettings.ezf[18,1]);
            exit;
           end;
  'pitch': begin
            SinglePlayerGUI.canvas.RoundRect(10,top1,790,top1+2,0,0);
            SinglePlayerGUI.canvas.RoundRect(coordfromznach(strtointdef(SinglePlayerSettings.ezf[19,1],0),10,-20,20),top1-10,coordfromznach(strtointdef(SinglePlayerSettings.ezf[19,1],0),10,-20,20)+60,top1+12,0,0);
            SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top1-40,getfromlangpack('timbrestream'));
            SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(strtointdef(SinglePlayerSettings.ezf[19,1],0),10,-20,20)-(SinglePlayerGUI.Canvas.TextWidth(SinglePlayerSettings.ezf[19,1]) div 2)+30,top1-9,SinglePlayerSettings.ezf[19,1]);
            exit;
           end;
  'compressor': begin
              SinglePlayerGUI.canvas.RoundRect(10,top1,790,top1+2,0,0);
              SinglePlayerGUI.canvas.RoundRect(coordfromznach(compressorparam.fGain,10,-60,60),top1-10,coordfromznach(compressorparam.fGain,10,-60,60)+60,top1+12,0,0);
              SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top1-40,getfromlangpack('gain'));
              SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(compressorparam.fGain,10,-60,60)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(compressorparam.fGain,0)) div 2)+30,top1-9,realtostr(compressorparam.fGain,0));

              SinglePlayerGUI.canvas.RoundRect(10,top2,790,top2+2,0,0);
              SinglePlayerGUI.canvas.RoundRect(coordfromznach(compressorparam.fAttack,10,1,1000),top2-10,coordfromznach(compressorparam.fAttack,10,1,1000)+60,top2+12,0,0);
              SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top2-40,getfromlangpack('attack'));
              SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(compressorparam.fAttack,10,1,1000)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(compressorparam.fAttack,0)) div 2)+30,top2-9,realtostr(compressorparam.fAttack,0));

              SinglePlayerGUI.canvas.RoundRect(10,top3,790,top3+2,0,0);
              SinglePlayerGUI.canvas.RoundRect(coordfromznach(compressorparam.fRelease,10,1,5000),top3-10,coordfromznach(compressorparam.fRelease,10,1,5000)+60,top3+12,0,0);
              SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top3-40,getfromlangpack('release'));
              SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(compressorparam.fRelease,10,1,5000)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(compressorparam.fRelease,0)) div 2)+30,top3-9,realtostr(compressorparam.fRelease,0));

              SinglePlayerGUI.canvas.RoundRect(10,top4,790,top4+2,0,0);
              SinglePlayerGUI.canvas.RoundRect(coordfromznach(compressorparam.fThreshold,10,-60,0),top4-10,coordfromznach(compressorparam.fThreshold,10,-60,0)+60,top4+12,0,0);
              SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top4-40,getfromlangpack('threshold'));
              SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(compressorparam.fThreshold,10,-60,0)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(compressorparam.fThreshold,0)) div 2)+30,top4-9,realtostr(compressorparam.fThreshold,0));

              SinglePlayerGUI.canvas.RoundRect(10,top5,790,top5+2,0,0);
              SinglePlayerGUI.canvas.RoundRect(coordfromznach(compressorparam.fRatio,10,1,5),top5-10,coordfromznach(compressorparam.fRatio,10,1,5)+60,top5+12,0,0);
              SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top5-40,getfromlangpack('ratio'));
              SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(compressorparam.fRatio,10,1,5)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(compressorparam.fRatio,0)) div 2)+30,top5-9,realtostr(compressorparam.fRatio,0));

             exit;
             end;
  'distortion': begin
              SinglePlayerGUI.canvas.RoundRect(10,top1,790,top1+2,0,0);
              SinglePlayerGUI.canvas.RoundRect(coordfromznach(distortionparam.fGain,10,-60,0),top1-10,coordfromznach(distortionparam.fGain,10,-60,0)+60,top1+12,0,0);
              SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top1-40,getfromlangpack('gain'));
              SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(distortionparam.fGain,10,-60,0)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(distortionparam.fGain,0)) div 2)+30,top1-9,realtostr(distortionparam.fGain,0));

              SinglePlayerGUI.canvas.RoundRect(10,top2,790,top2+2,0,0);
              SinglePlayerGUI.canvas.RoundRect(coordfromznach(distortionparam.fEdge,10,0,100),top2-10,coordfromznach(distortionparam.fEdge,10,0,100)+60,top2+12,0,0);
              SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top2-40,getfromlangpack('edge'));
              SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(distortionparam.fEdge,10,0,100)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(distortionparam.fEdge,0)) div 2)+30,top2-9,realtostr(distortionparam.fEdge,0));

              SinglePlayerGUI.canvas.RoundRect(10,top3,790,top3+2,0,0);
              SinglePlayerGUI.canvas.RoundRect(coordfromznach(distortionparam.fPostEQCenterFrequency,10,100,8000),top3-10,coordfromznach(distortionparam.fPostEQCenterFrequency,10,100,8000)+60,top3+12,0,0);
              SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top3-40,getfromlangpack('ecf'));
              SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(distortionparam.fPostEQCenterFrequency,10,100,8000)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(distortionparam.fPostEQCenterFrequency,0)) div 2)+30,top3-9,realtostr(distortionparam.fPostEQCenterFrequency,0));

              SinglePlayerGUI.canvas.RoundRect(10,top4,790,top4+2,0,0);
              SinglePlayerGUI.canvas.RoundRect(coordfromznach(distortionparam.fPostEQBandwidth,10,100,8000),top4-10,coordfromznach(distortionparam.fPostEQBandwidth,10,100,8000)+60,top4+12,0,0);
              SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top4-40,getfromlangpack('bandwidth'));
              SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(distortionparam.fPostEQBandwidth,10,100,8000)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(distortionparam.fPostEQBandwidth,0)) div 2)+30,top4-9,realtostr(distortionparam.fPostEQBandwidth,0));

              SinglePlayerGUI.canvas.RoundRect(10,top5,790,top5+2,0,0);
              SinglePlayerGUI.canvas.RoundRect(coordfromznach(distortionparam.fPreLowpassCutoff,10,100,8000),top5-10,coordfromznach(distortionparam.fPreLowpassCutoff,10,100,8000)+60,top5+12,0,0);
              SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top5-40,getfromlangpack('lowpasstext'));
              SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(distortionparam.fPreLowpassCutoff,10,100,8000)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(distortionparam.fPreLowpassCutoff,0)) div 2)+30,top5-9,realtostr(distortionparam.fPreLowpassCutoff,0));

              exit;
              end;
  'phaser':     begin
                 SinglePlayerGUI.canvas.RoundRect(10,top1,790,top1+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(phaserparam.fDryMix,10000,-2000,2000),top1-10,coordfromznach(phaserparam.fDryMix,10000,-2000,2000)+60,top1+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top1-40,getfromlangpack('fdrymix'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(phaserparam.fDryMix,10000,-2000,2000)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(phaserparam.fDryMix,3)) div 2)+30,top1-9,realtostr(phaserparam.fDryMix,3));

                 SinglePlayerGUI.canvas.RoundRect(10,top2,790,top2+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(phaserparam.fWetMix,10000,-2000,2000),top2-10,coordfromznach(phaserparam.fWetMix,10000,-2000,2000)+60,top2+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top2-40,getfromlangpack('fwetmix'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(phaserparam.fWetMix,10000,-2000,2000)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(phaserparam.fWetMix,3)) div 2)+30,top2-9,realtostr(phaserparam.fWetMix,3));

                 SinglePlayerGUI.canvas.RoundRect(10,top3,790,top3+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(phaserparam.fFeedback,100,-10,10),top3-10,coordfromznach(phaserparam.fFeedback,100,-10,10)+60,top3+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top3-40,getfromlangpack('ffeedback'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(phaserparam.fFeedback,100,-10,10)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(phaserparam.fFeedback,1)) div 2)+30,top3-9,realtostr(phaserparam.fFeedback,1));

                 SinglePlayerGUI.canvas.RoundRect(10,top4,790,top4+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(phaserparam.fRate,10,0,10),top4-10,coordfromznach(phaserparam.fRate,10,0,10)+60,top4+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top4-40,getfromlangpack('frate'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(phaserparam.fRate,10,0,10)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(phaserparam.fRate,1)) div 2)+30,top4-9,realtostr(phaserparam.fRate,1));

                 SinglePlayerGUI.canvas.RoundRect(10,top5,790,top5+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(phaserparam.fRange,10,0,10),top5-10,coordfromznach(phaserparam.fRange,10,0,10)+60,top5+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top5-40,getfromlangpack('frange'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(phaserparam.fRange,10,0,10)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(phaserparam.fRange,1)) div 2)+30,top5-9,realtostr(phaserparam.fRange,1));

                 SinglePlayerGUI.canvas.RoundRect(10,top6,790,top6+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(phaserparam.fFreq,10,0,1000),top6-10,coordfromznach(phaserparam.fFreq,10,0,1000)+60,top6+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top6-40,getfromlangpack('ffreq'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(phaserparam.fFreq,10,0,1000)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(phaserparam.fFreq,0)) div 2)+30,top6-9,realtostr(phaserparam.fFreq,0));
                 exit;
                end;
  'freeverb':     begin
                 SinglePlayerGUI.canvas.RoundRect(10,top1,790,top1+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(FREEVERBparam.fDryMix,100,0,10),top1-10,coordfromznach(FREEVERBparam.fDryMix,100,0,10)+60,top1+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top1-40,getfromlangpack('fdrymix'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(FREEVERBparam.fDryMix,100,0,10)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(FREEVERBparam.fDryMix,1)) div 2)+30,top1-9,realtostr(FREEVERBparam.fDryMix,1));

                 SinglePlayerGUI.canvas.RoundRect(10,top2,790,top2+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(FREEVERBparam.fWetMix,100,0,30),top2-10,coordfromznach(FREEVERBparam.fWetMix,100,0,30)+60,top2+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top2-40,getfromlangpack('fwetmix'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(FREEVERBparam.fWetMix,100,0,30)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(FREEVERBparam.fWetMix,1)) div 2)+30,top2-9,realtostr(FREEVERBparam.fWetMix,1));

                 SinglePlayerGUI.canvas.RoundRect(10,top3,790,top3+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(FREEVERBparam.fRoomSize,100,0,10),top3-10,coordfromznach(FREEVERBparam.fRoomSize,100,0,10)+60,top3+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top3-40,getfromlangpack('froomsize'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(FREEVERBparam.fRoomSize,100,0,10)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(FREEVERBparam.fRoomSize,1)) div 2)+30,top3-9,realtostr(FREEVERBparam.fRoomSize,1));

                 SinglePlayerGUI.canvas.RoundRect(10,top4,790,top4+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(FREEVERBparam.fDamp,100,0,10),top4-10,coordfromznach(FREEVERBparam.fDamp,100,0,10)+60,top4+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top4-40,getfromlangpack('fdamp'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(FREEVERBparam.fDamp,100,0,10)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(FREEVERBparam.fDamp,1)) div 2)+30,top4-9,realtostr(FREEVERBparam.fDamp,1));

                 SinglePlayerGUI.canvas.RoundRect(10,top5,790,top5+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(FREEVERBparam.fWidth,100,0,10),top5-10,coordfromznach(FREEVERBparam.fWidth,100,0,10)+60,top5+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top5-40,getfromlangpack('fwidth'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(FREEVERBparam.fWidth,100,0,10)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(FREEVERBparam.fWidth,1)) div 2)+30,top5-9,realtostr(FREEVERBparam.fWidth,1));
                 exit;
                 end;
  'autowah':     begin
                 SinglePlayerGUI.canvas.RoundRect(10,top1,790,top1+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(autowahparam.fDryMix,10000,-2000,2000),top1-10,coordfromznach(autowahparam.fDryMix,10000,-2000,2000)+60,top1+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top1-40,getfromlangpack('fdrymix'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(autowahparam.fDryMix,10000,-2000,2000)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(autowahparam.fDryMix,3)) div 2)+30,top1-9,realtostr(autowahparam.fDryMix,3));

                 SinglePlayerGUI.canvas.RoundRect(10,top2,790,top2+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(autowahparam.fWetMix,10000,-2000,2000),top2-10,coordfromznach(autowahparam.fWetMix,10000,-2000,2000)+60,top2+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top2-40,getfromlangpack('fwetmix'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(autowahparam.fWetMix,10000,-2000,2000)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(autowahparam.fWetMix,3)) div 2)+30,top2-9,realtostr(autowahparam.fWetMix,3));

                 SinglePlayerGUI.canvas.RoundRect(10,top3,790,top3+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(autowahparam.fFeedback,100,-10,10),top3-10,coordfromznach(autowahparam.fFeedback,100,-10,10)+60,top3+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top3-40,getfromlangpack('ffeedback'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(autowahparam.fFeedback,100,-10,10)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(autowahparam.fFeedback,1)) div 2)+30,top3-9,realtostr(autowahparam.fFeedback,1));

                 SinglePlayerGUI.canvas.RoundRect(10,top4,790,top4+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(autowahparam.fRate,10,0,10),top4-10,coordfromznach(autowahparam.fRate,10,0,10)+60,top4+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top4-40,getfromlangpack('frate'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(autowahparam.fRate,10,0,10)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(autowahparam.fRate,1)) div 2)+30,top4-9,realtostr(autowahparam.fRate,1));

                 SinglePlayerGUI.canvas.RoundRect(10,top5,790,top5+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(autowahparam.fRange,10,0,10),top5-10,coordfromznach(autowahparam.fRange,10,0,10)+60,top5+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top5-40,getfromlangpack('frange'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(autowahparam.fRange,10,0,10)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(autowahparam.fRange,1)) div 2)+30,top5-9,realtostr(autowahparam.fRange,1));

                 SinglePlayerGUI.canvas.RoundRect(10,top6,790,top6+2,0,0);
                 SinglePlayerGUI.canvas.RoundRect(coordfromznach(autowahparam.fFreq,10,0,1000),top6-10,coordfromznach(autowahparam.fFreq,10,0,1000)+60,top6+12,0,0);
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top6-40,getfromlangpack('ffreq'));
                 SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(autowahparam.fFreq,10,0,1000)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(autowahparam.fFreq,0)) div 2)+30,top6-9,realtostr(autowahparam.fFreq,0));
                 exit;
                end;

  else begin if oldpage<>'' then curentpage:=oldpage else curentpage:='singleplayer'; exit; end;
  end;

  if eqpage<>0 then
   begin
    SinglePlayerGUI.canvas.RoundRect(10,top1,790,top1+2,0,0);
    SinglePlayerGUI.canvas.RoundRect(coordfromfreq(RealToInt(p[eqpage].fCenter,0)),top1-10,coordfromfreq(RealToInt(p[eqpage].fCenter,0))+60,top1+12,0,0);
    SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top1-40,getfromlangpack('customeq'));
    SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromfreq(RealToInt(p[eqpage].fCenter,0))-(SinglePlayerGUI.Canvas.TextWidth(realtostr(p[eqpage].fCenter,0)) div 2)+30,top1-9,realtostr(p[eqpage].fCenter,0));

    SinglePlayerGUI.canvas.RoundRect(10,top3,790,top3+2,0,0);
    SinglePlayerGUI.canvas.RoundRect(coordfromznach(p[eqpage].fgain,10,-15,15),top3-10,coordfromznach(p[eqpage].fgain,10,-15,15)+60,top3+12,0,0);
    SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top3-40,getfromlangpack('freqgain'));
    SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(p[eqpage].fgain,10,-15,15)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(p[eqpage].fgain,0)) div 2)+30,top3-9,realtostr(p[eqpage].fgain,0));

    SinglePlayerGUI.canvas.RoundRect(10,top6,790,top6+2,0,0);
    SinglePlayerGUI.canvas.RoundRect(coordfromznach(p[eqpage].fBandwidth,10,1,36),top6-10,coordfromznach(p[eqpage].fBandwidth,10,1,36)+60,top6+12,0,0);
    SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),10,top6-40,getfromlangpack('bandwidtheq'));
    SinglePlayerGUI.Canvas.TextRect(classes.Rect(0,0,800,480),coordfromznach(p[eqpage].fBandwidth,10,1,36)-(SinglePlayerGUI.Canvas.TextWidth(realtostr(p[eqpage].fBandwidth,1)) div 2)+30,top6-9,realtostr(p[eqpage].fBandwidth,1));
    exit;
   end else begin if oldpage<>'' then curentpage:=oldpage else curentpage:='singleplayer'; exit; end;
 except
  LogAndExitPlayer('Ошибка в продедуре effectedit',0,0);
 end;
end;

function map(val,x1,x2,y1,y2:integer):integer;
begin
 result:=0;
 result:=(val-x1)*(y2-y1) div (x2-x1)+y1;
end;

function coordfromfreq(freq:integer):integer;
var
 a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13:integer;
begin
 result:=10;
 a1:=30;
 a2:=65;
 a3:=80;
 a4:=170;
 a5:=310;
 a6:=600;
 a7:=1000;
 a8:=3000;
 a9:=6000;
 a10:=10000;
 a11:=12000;
 a12:=15000;
 a13:=18501;
 if (freq>a1) and (freq<a2+1) then begin result:=map(freq,a1,a2,10,74); exit; end;
 if (freq>a2) and (freq<a3+1) then begin result:=map(freq,a2+1,a3,75,140); exit; end;
 if (freq>a3) and (freq<a4+1) then begin result:=map(freq,a3+1,a4,141,205); exit; end;
 if (freq>a4) and (freq<a5+1) then begin result:=map(freq,a4+1,a5,206,270); exit; end;
 if (freq>a5) and (freq<a6+1) then begin result:=map(freq,a5+1,a6,271,335); exit; end;
 if (freq>a6) and (freq<a7+1) then begin result:=map(freq,a6+1,a7,336,400); exit; end;
 if (freq>a7) and (freq<a8+1) then begin result:=map(freq,a7+1,a8,401,465); exit; end;
 if (freq>a8) and (freq<a9+1) then begin result:=map(freq,a8+1,a9,466,530); exit; end;
 if (freq>a9) and (freq<a10+1) then begin result:=map(freq,a9+1,a10,531,595); exit; end;
 if (freq>a10) and (freq<a11+1) then begin result:=map(freq,a10+1,a11,596,660); exit; end;
 if (freq>a11) and (freq<a12+1) then begin result:=map(freq,a11+1,a12,661,725); exit; end;
 if (freq>a12) and (freq<a13+1) then begin result:=map(freq,a12+1,a13,726,760); exit; end;
end;

function freqfromcoord(coord:integer):integer;
var
 a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13:integer;
begin
 result:=30;
 a1:=30;
 a2:=65;
 a3:=80;
 a4:=170;
 a5:=310;
 a6:=600;
 a7:=1000;
 a8:=3000;
 a9:=6000;
 a10:=10000;
 a11:=12000;
 a12:=15000;
 a13:=18501;
 if (coord>9) and (coord<75) then begin result:=map(coord,10,74,a1,a2); exit; end;
 if (coord>74) and (coord<141) then begin result:=map(coord,75,140,a2+1,a3); exit; end;
 if (coord>140) and (coord<206) then begin result:=map(coord,141,205,a3+1,a4); exit; end;
 if (coord>205) and (coord<271) then begin result:=map(coord,206,270,a4+1,a5); exit; end;
 if (coord>270) and (coord<336) then begin result:=map(coord,271,335,a5+1,a6); exit; end;
 if (coord>335) and (coord<401) then begin result:=map(coord,336,400,a6+1,a7); exit; end;
 if (coord>400) and (coord<466) then begin result:=map(coord,401,465,a7+1,a8); exit; end;
 if (coord>465) and (coord<531) then begin result:=map(coord,466,530,a8+1,a9); exit; end;
 if (coord>530) and (coord<596) then begin result:=map(coord,531,595,a9+1,a10); exit; end;
 if (coord>595) and (coord<661) then begin result:=map(coord,596,660,a10+1,a11); exit; end;
 if (coord>660) and (coord<726) then begin result:=map(coord,661,720,a11+1,a12); exit; end;
 if (coord>725) and (coord<761) then begin result:=map(coord,726,760,a12+1,a13); exit; end;
end;

function coordfromznach(bandw:single; razr,x1,x2:integer):integer;
var
 a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,sm,bandwint:integer;
begin
 bandwint:=realtoint(bandw*razr,0);
 result:=10;
 a1:=x1*10;
 x2:=x2*10;
 if x1<0 then x1:=abs(x1)*10 else x1:=(x1*-10);
 sm:=(x1+x2) div 12;
 a2:=a1+sm;
 a3:=a2+sm;
 a4:=a3+sm;
 a5:=a4+sm;
 a6:=a5+sm;
 a7:=a6+sm;
 a8:=a7+sm;
 a9:=a8+sm;
 a10:=a9+sm;
 a11:=a10+sm;
 a12:=a11+sm;
 a13:=x2;
 if (bandwint>a1) and (bandwint<a2+1) then begin result:=map(bandwint,a1,a2,10,74); exit; end;
 if (bandwint>a2) and (bandwint<a3+1) then begin result:=map(bandwint,a2+1,a3,75,140); exit; end;
 if (bandwint>a3) and (bandwint<a4+1) then begin result:=map(bandwint,a3+1,a4,141,205); exit; end;
 if (bandwint>a4) and (bandwint<a5+1) then begin result:=map(bandwint,a4+1,a5,206,270); exit; end;
 if (bandwint>a5) and (bandwint<a6+1) then begin result:=map(bandwint,a5+1,a6,271,335); exit; end;
 if (bandwint>a6) and (bandwint<a7+1) then begin result:=map(bandwint,a6+1,a7,336,400); exit; end;
 if (bandwint>a7) and (bandwint<a8+1) then begin result:=map(bandwint,a7+1,a8,401,465); exit; end;
 if (bandwint>a8) and (bandwint<a9+1) then begin result:=map(bandwint,a8+1,a9,466,530); exit; end;
 if (bandwint>a9) and (bandwint<a10+1) then begin result:=map(bandwint,a9+1,a10,531,595); exit; end;
 if (bandwint>a10) and (bandwint<a11+1) then begin result:=map(bandwint,a10+1,a11,596,660); exit; end;
 if (bandwint>a11) and (bandwint<a12+1) then begin result:=map(bandwint,a11+1,a12,661,725); exit; end;
 if (bandwint>a12) and (bandwint<a13+1) then begin result:=map(bandwint,a12+1,a13,726,760); exit; end;
 if (bandwint>a13) then result:=790;
end;

function znachfromcoord(coord,razr,x1,x2:integer):single;
var
 a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,sm:integer;
begin
result:=x1/razr*10;
a1:=x1*10;
x2:=x2*10;
if x1<0 then x1:=abs(x1)*10 else x1:=(x1*-10);
sm:=(x1+x2) div 12;
a2:=a1+sm;
a3:=a2+sm;
a4:=a3+sm;
a5:=a4+sm;
a6:=a5+sm;
a7:=a6+sm;
a8:=a7+sm;
a9:=a8+sm;
a10:=a9+sm;
a11:=a10+sm;
a12:=a11+sm;
a13:=x2;
 if (coord>9) and (coord<75) then begin result:=map(coord,10,74,a1,a2)/razr; exit; end;
 if (coord>74) and (coord<141) then begin result:=map(coord,75,140,a2+1,a3)/razr; exit; end;
 if (coord>140) and (coord<206) then begin result:=map(coord,141,205,a3+1,a4)/razr; exit; end;
 if (coord>205) and (coord<271) then begin result:=map(coord,206,270,a4+1,a5)/razr; exit; end;
 if (coord>270) and (coord<336) then begin result:=map(coord,271,335,a5+1,a6)/razr; exit; end;
 if (coord>335) and (coord<401) then begin result:=map(coord,336,400,a6+1,a7)/razr; exit; end;
 if (coord>400) and (coord<466) then begin result:=map(coord,401,465,a7+1,a8)/razr; exit; end;
 if (coord>465) and (coord<531) then begin result:=map(coord,466,530,a8+1,a9)/razr; exit; end;
 if (coord>530) and (coord<596) then begin result:=map(coord,531,595,a9+1,a10)/razr; exit; end;
 if (coord>595) and (coord<661) then begin result:=map(coord,596,660,a10+1,a11)/razr; exit; end;
 if (coord>660) and (coord<726) then begin result:=map(coord,661,720,a11+1,a12)/razr; exit; end;
 if (coord>725) and (coord<761) then begin result:=map(coord,726,760,a12+1,a13)/razr; exit; end;
 if (coord>760) then result:=x2/razr;
end;





procedure effecton(eff:string);
begin
try
case eff of
 'bqflow': begin
            singleplayersettings.bqflow:=1;
            SinglePlayerSettings.ezf[30,13]:='1';
              BASS_ChannelRemoveFX(channel,fxbqflow);
              fxbqflow := BASS_ChannelSetFX(channel, BASS_FX_BFX_BQF, 1);
              BASS_FXGetParameters(fxbqflow, @bqflowparam);
              bqflowparam.lFilter:=BASS_BFX_BQF_lowPASS;
              bqflowparam.fCenter:=strtointdef(SinglePlayerSettings.ezf[20,1],0);
              bqflowparam.fQ:=StrToFloatdef(SinglePlayerSettings.ezf[20,4],0);
              bqflowparam.fbandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[20,3],0);
              BASS_FXSetParameters(fxbqflow, @bqflowparam);
           end;
 'bqfhigh': begin
             singleplayersettings.bqfhigh:=1;
             SinglePlayerSettings.ezf[30,12]:='1';
              BASS_ChannelRemoveFX(channel,fxbqfhigh);
              fxbqfhigh := BASS_ChannelSetFX(channel, BASS_FX_BFX_BQF, 1);
              BASS_FXGetParameters(fxbqfhigh, @bqfhighparam);
              bqfhighparam.lFilter:=BASS_BFX_BQF_highPASS;
              bqfhighparam.fCenter:=strtointdef(SinglePlayerSettings.ezf[21,1],0);
              bqfhighparam.fQ:=StrToFloatdef(SinglePlayerSettings.ezf[21,4],0);
              bqfhighparam.fbandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[21,3],0);
              BASS_FXSetParameters(fxbqfhigh, @bqfhighparam);
            end;
 'bqfpeakingeq': begin
                  singleplayersettings.bqfPEAKINGEQ:=1;
                  SinglePlayerSettings.ezf[30,15]:='1';
                    BASS_ChannelRemoveFX(channel,fxbqfPEAKINGEQ);
                    fxbqfPEAKINGEQ := BASS_ChannelSetFX(channel, BASS_FX_BFX_BQF, 1);
                    BASS_FXGetParameters(fxbqfPEAKINGEQ, @bqfPEAKINGEQparam);
                    bqfPEAKINGEQparam.lFilter:=BASS_BFX_BQF_PEAKINGEQ;
                    bqfPEAKINGEQparam.fCenter:=strtointdef(SinglePlayerSettings.ezf[22,1],0);
                    bqfPEAKINGEQparam.fGain:=strtofloatdef(SinglePlayerSettings.ezf[22,2],0);
                    bqfPEAKINGEQparam.fbandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[22,3],0);
                    bqfPEAKINGEQparam.fQ:=StrToFloatdef(SinglePlayerSettings.ezf[22,4],0);
                    BASS_FXSetParameters(fxbqfPEAKINGEQ, @bqfPEAKINGEQparam);
                  end;
  'bqfbandpass': begin
                  singleplayersettings.bqfBANDPASS:=1;
                    BASS_ChannelRemoveFX(channel,fxbqfBANDPASS);
                    SinglePlayerSettings.ezf[30,14]:='1';
                    fxbqfBANDPASS := BASS_ChannelSetFX(channel, BASS_FX_BFX_BQF, 1);
                    BASS_FXGetParameters(fxbqfBANDPASS, @bqfBANDPASSparam);
                    bqfBANDPASSparam.lFilter:=BASS_BFX_BQF_BANDPASS;
                    bqfBANDPASSparam.fCenter:=strtointdef(SinglePlayerSettings.ezf[23,1],0);
                    bqfBANDPASSparam.fbandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[23,3],0);
                    bqfBANDPASSparam.fQ:=StrToFloatdef(SinglePlayerSettings.ezf[23,4],0);
                    BASS_FXSetParameters(fxbqfBANDPASS, @bqfBANDPASSparam);
                  end;
  'bqfnotch': begin
                  singleplayersettings.bqfnotch:=1;
                  SinglePlayerSettings.ezf[30,16]:='1';
                    BASS_ChannelRemoveFX(channel,fxbqfnotch);
                    fxbqfnotch := BASS_ChannelSetFX(channel, BASS_FX_BFX_BQF, 1);
                    BASS_FXGetParameters(fxbqfnotch, @bqfnotchparam);
                    bqfnotchparam.lFilter:=BASS_BFX_BQF_notch;
                    bqfnotchparam.fCenter:=strtointdef(SinglePlayerSettings.ezf[29,1],0);
                    bqfnotchparam.fbandwidth:=StrToFloatdef(SinglePlayerSettings.ezf[29,3],0);
                    bqfnotchparam.fQ:=StrToFloatdef(SinglePlayerSettings.ezf[29,4],0);
                    BASS_FXSetParameters(fxbqfnotch, @bqfnotchparam);
                  end;

  'reverb': begin
               singleplayersettings.reverb:=1;
               SinglePlayerSettings.ezf[30,10]:='1';
                  BASS_ChannelRemoveFX(channel,fxreverb);
                  fxreverb := BASS_ChannelSetFX(channel,  BASS_FX_DX8_REVERB, 1);
                  BASS_FXGetParameters(fxreverb, @reverbparam);
                  reverbparam.fInGain:=StrToFloatdef(SinglePlayerSettings.ezf[14,1],0);
                  reverbparam.fReverbMix:=StrTofloatdef(SinglePlayerSettings.ezf[14,2],0);
                  reverbparam.fReverbTime:=StrToFloatdef(SinglePlayerSettings.ezf[14,3],0);
                  reverbparam.fHighFreqRTRatio:=StrToFloatdef(SinglePlayerSettings.ezf[14,4],0);
                  BASS_FXSetParameters(fxreverb, @reverbparam);
            end;
  'echo': begin
          singleplayersettings.echo:=1;
          SinglePlayerSettings.ezf[30,5]:='1';
            BASS_ChannelRemoveFX(channel,fxecho);
            fxecho := BASS_ChannelSetFX(channel, BASS_FX_DX8_ECHO, 1);
            BASS_FXGetParameters(fxecho, @echoparam);
            echoparam.fWetDryMix:=strtoFloatdef(SinglePlayerSettings.ezf[15,1],0);
            echoparam.fFeedback :=strtoFloatdef(SinglePlayerSettings.ezf[15,2],0);
            echoparam.fLeftDelay :=StrToFloatdef(SinglePlayerSettings.ezf[15,3],0);
            echoparam.fRightDelay :=StrToFloatdef(SinglePlayerSettings.ezf[15,4],0);
            BASS_FXSetParameters(fxecho, @echoparam);
          end;
  'chorus': begin
          singleplayersettings.chorus:=1;
          SinglePlayerSettings.ezf[30,6]:='1';
            BASS_ChannelRemoveFX(channel,fxchorus);
            fxchorus := BASS_ChannelSetFX(channel, BASS_FX_DX8_chorus, 1);
            BASS_FXGetParameters(fxchorus, @chorusparam);
            chorusparam.fWetDryMix:=strtoFloatdef(SinglePlayerSettings.ezf[16,1],0);
            chorusparam.fDepth :=strtoFloatdef(SinglePlayerSettings.ezf[16,2],0);
            chorusparam.fFeedback :=StrToFloatdef(SinglePlayerSettings.ezf[16,3],0);
            chorusparam.fFrequency :=StrToFloatdef(SinglePlayerSettings.ezf[16,4],0);
            chorusparam.fDelay :=StrToFloatdef(SinglePlayerSettings.ezf[16,5],0);
            BASS_FXSetParameters(fxchorus, @chorusparam);
          end;
  'flanger': begin
          singleplayersettings.flanger:=1;
          SinglePlayerSettings.ezf[30,7]:='1';
            BASS_ChannelRemoveFX(channel,fxflanger);
            fxflanger := BASS_ChannelSetFX(channel, BASS_FX_DX8_flanger, 1);
            BASS_FXGetParameters(fxflanger, @flangerparam);
            flangerparam.fWetDryMix:=strtoFloatdef(SinglePlayerSettings.ezf[17,1],0);
            flangerparam.fDepth :=strtoFloatdef(SinglePlayerSettings.ezf[17,2],0);
            flangerparam.fFeedback :=StrToFloatdef(SinglePlayerSettings.ezf[17,3],0);
            flangerparam.fFrequency :=StrToFloatdef(SinglePlayerSettings.ezf[17,4],0);
            flangerparam.fDelay :=StrToFloatdef(SinglePlayerSettings.ezf[17,5],0);
            BASS_FXSetParameters(fxflanger, @flangerparam);
          end;
  'tempo': begin
            singleplayersettings.tempo:=1;
            SinglePlayerSettings.ezf[30,8]:='1';
            BASS_ChannelSetAttribute(channel, BASS_ATTRIB_TEMPO,strtointdef(SinglePlayerSettings.ezf[18,1],0));
           end;
  'pitch': begin
            singleplayersettings.pitch:=1;
            SinglePlayerSettings.ezf[30,11]:='1';
            BASS_ChannelSetAttribute(channel, BASS_ATTRIB_TEMPO_PITCH,strtointdef(SinglePlayerSettings.ezf[19,1],0));
           end;
  'compressor': begin
            singleplayersettings.compressor:=1;
            SinglePlayerSettings.ezf[30,9]:='1';
              BASS_ChannelRemoveFX(channel,fxcompressor);
              fxcompressor := BASS_ChannelSetFX(channel, BASS_FX_BFX_COMPRESSOR2, 1);
              BASS_FXGetParameters(fxcompressor, @compressorparam);
              compressorparam.fGain:=strtoFloatdef(SinglePlayerSettings.ezf[24,1],0);
              compressorparam.fAttack :=strtoFloatdef(SinglePlayerSettings.ezf[24,2],0);
              compressorparam.fRelease :=StrToFloatdef(SinglePlayerSettings.ezf[24,3],0);
              compressorparam.fThreshold :=StrToFloatdef(SinglePlayerSettings.ezf[24,4],0);
              compressorparam.fRatio :=StrToFloatdef(SinglePlayerSettings.ezf[24,5],0);
              BASS_FXSetParameters(fxcompressor, @compressorparam);
                end;
  'distortion': begin
         singleplayersettings.distortion:=1;
         SinglePlayerSettings.ezf[30,1]:='1';
          BASS_ChannelRemoveFX(channel,fxdistortion);
          fxdistortion := BASS_ChannelSetFX(channel, BASS_FX_DX8_distortion, 1);
          BASS_FXGetParameters(fxdistortion, @distortionparam);
          distortionparam.fGain:=strtoFloatdef(SinglePlayerSettings.ezf[25,1],0);
          distortionparam.fEdge :=strtoFloatdef(SinglePlayerSettings.ezf[25,2],0);
          distortionparam.fPostEQCenterFrequency :=StrToFloatdef(SinglePlayerSettings.ezf[25,3],0);
          distortionparam.fPostEQBandwidth :=StrToFloatdef(SinglePlayerSettings.ezf[25,4],0);
          distortionparam.fPreLowpassCutoff :=StrToFloatdef(SinglePlayerSettings.ezf[25,5],0);
          BASS_FXSetParameters(fxdistortion, @distortionparam);
                end;
  'phaser': begin
        singleplayersettings.phaser:=1;
        SinglePlayerSettings.ezf[30,2]:='1';
          BASS_ChannelRemoveFX(channel,fxphaser);
          fxphaser := BASS_ChannelSetFX(channel, BASS_FX_BFX_phaser, 1);
          BASS_FXGetParameters(fxphaser, @phaserparam);
          phaserparam.fDryMix:=strtoFloatdef(SinglePlayerSettings.ezf[26,1],0);
          phaserparam.fWetMix :=strtoFloatdef(SinglePlayerSettings.ezf[26,2],0);
          phaserparam.fFeedback :=StrToFloatdef(SinglePlayerSettings.ezf[26,3],0);
          phaserparam.fRate :=StrToFloatdef(SinglePlayerSettings.ezf[26,4],0);
          phaserparam.fRange :=StrToFloatdef(SinglePlayerSettings.ezf[26,5],0);
          phaserparam.fFreq :=StrToFloatdef(SinglePlayerSettings.ezf[26,6],0);
          BASS_FXSetParameters(fxphaser, @phaserparam);
               end;
  'freeverb': begin
           SinglePlayerSettings.FREEVERB:=1;
           SinglePlayerSettings.ezf[30,3]:='1';
          BASS_ChannelRemoveFX(channel,fxFREEVERB);
          fxFREEVERB := BASS_ChannelSetFX(channel, BASS_FX_BFX_FREEVERB, 1);
          BASS_FXGetParameters(fxFREEVERB, @FREEVERBparam);
          FREEVERBparam.fDryMix:=strtoFloatdef(SinglePlayerSettings.ezf[27,1],0);
          FREEVERBparam.fWetMix :=strtoFloatdef(SinglePlayerSettings.ezf[27,2],0);
          FREEVERBparam.fRoomSize :=StrToFloatdef(SinglePlayerSettings.ezf[27,3],0);
          FREEVERBparam.fDamp :=StrToFloatdef(SinglePlayerSettings.ezf[27,4],0);
          FREEVERBparam.fWidth :=StrToFloatdef(SinglePlayerSettings.ezf[27,5],0);
          BASS_FXSetParameters(fxFREEVERB, @FREEVERBparam);
           end;
  'autowah': begin
        singleplayersettings.autowah:=1;
        SinglePlayerSettings.ezf[30,4]:='1';
          BASS_ChannelRemoveFX(channel,fxautowah);
          fxautowah := BASS_ChannelSetFX(channel, BASS_FX_BFX_autowah, 1);
          BASS_FXGetParameters(fxautowah, @autowahparam);
          autowahparam.fDryMix:=strtoFloatdef(SinglePlayerSettings.ezf[28,1],0);
          autowahparam.fWetMix :=strtoFloatdef(SinglePlayerSettings.ezf[28,2],0);
          autowahparam.fFeedback :=StrToFloatdef(SinglePlayerSettings.ezf[28,3],0);
          autowahparam.fRate :=StrToFloatdef(SinglePlayerSettings.ezf[28,4],0);
          autowahparam.fRange :=StrToFloatdef(SinglePlayerSettings.ezf[28,5],0);
          autowahparam.fFreq :=StrToFloatdef(SinglePlayerSettings.ezf[28,6],0);
          BASS_FXSetParameters(fxautowah, @autowahparam);
               end;

 else begin SinglePlayerGUI.Invalidate; exit; end;
end;
eqclear;
SinglePlayerGUI.Invalidate;
exit;
except
 LogAndExitPlayer('Ошибка в продедуре effecton',0,0);
end;
end;

procedure effectoff(eff:string);
begin
try

case eff of
 'bqflow': begin singleplayersettings.bqflow:=0; BASS_ChannelRemoveFX(channel,fxbqflow); SinglePlayerSettings.ezf[30,13]:='0'; end;
 'bqfhigh': begin singleplayersettings.bqfhigh:=0; BASS_ChannelRemoveFX(channel,fxbqfhigh); SinglePlayerSettings.ezf[30,12]:='0'; end;
 'bqfpeakingeq': begin singleplayersettings.bqfPEAKINGEQ:=0; BASS_ChannelRemoveFX(channel,fxbqfPEAKINGEQ); SinglePlayerSettings.ezf[30,15]:='0'; end;
 'bqfbandpass': begin singleplayersettings.bqfBANDPASS:=0; BASS_ChannelRemoveFX(channel,fxbqfBANDPASS); SinglePlayerSettings.ezf[30,14]:='0'; end;
 'reverb': begin singleplayersettings.reverb:=0; BASS_ChannelRemoveFX(channel,fxreverb); SinglePlayerSettings.ezf[30,10]:='0'; end;
 'echo': begin singleplayersettings.echo:=0; BASS_ChannelRemoveFX(channel,fxecho); SinglePlayerSettings.ezf[30,5]:='0'; end;
 'chorus': begin singleplayersettings.chorus:=0; BASS_ChannelRemoveFX(channel,fxchorus); SinglePlayerSettings.ezf[30,6]:='0'; end;
 'flanger': begin singleplayersettings.flanger:=0; BASS_ChannelRemoveFX(channel,fxflanger); SinglePlayerSettings.ezf[30,7]:='0'; end;
 'tempo': begin singleplayersettings.tempo:=0; BASS_ChannelSetAttribute(channel, BASS_ATTRIB_TEMPO,0); SinglePlayerSettings.ezf[30,8]:='0'; end;
 'pitch': begin singleplayersettings.pitch:=0; BASS_ChannelSetAttribute(channel, BASS_ATTRIB_TEMPO_PITCH,0); SinglePlayerSettings.ezf[30,11]:='0'; end;
 'compressor': begin singleplayersettings.compressor:=0; BASS_ChannelRemoveFX(channel,fxcompressor); SinglePlayerSettings.ezf[30,9]:='0'; end;
 'distortion': begin singleplayersettings.distortion:=0; BASS_ChannelRemoveFX(channel,fxdistortion); SinglePlayerSettings.ezf[30,1]:='0'; end;
 'phaser': begin singleplayersettings.phaser:=0; BASS_ChannelRemoveFX(channel,fxphaser); SinglePlayerSettings.ezf[30,2]:='0'; end;
 'freeverb': begin SinglePlayerSettings.FREEVERB:=0; BASS_ChannelRemoveFX(channel,fxFREEVERB); SinglePlayerSettings.ezf[30,3]:='0'; end;
 'autowah': begin singleplayersettings.autowah:=0; BASS_ChannelRemoveFX(channel,fxautowah); SinglePlayerSettings.ezf[30,4]:='0'; end;
 'bqfnotch': begin singleplayersettings.bqfnotch:=0; BASS_ChannelRemoveFX(channel,fxbqfnotch); SinglePlayerSettings.ezf[30,16]:='0'; end;
 else begin SinglePlayerGUI.Invalidate; exit; end;
end;
eqclear;
SinglePlayerGUI.Invalidate;
exit;
except
 LogAndExitPlayer('Ошибка в продедуре effectoff',0,0);
end;
end;

procedure playm3upls(m3uplsstr:string);
var
 tfpls:textfile;
 tfstr,cuetrack:string;
 i,kolstrcue,itrack,sindex:integer;
 tfstrmas: array of string;
begin
   m3uplsmass:=nil;
   tfstrmas:=nil;
   i:=0;
   kolstrcue:=0;
   itrack:=0;
   sindex:=0;
   cuetrack:='';
   assignfile(tfpls,m3uplsstr);
   reset(tfpls);

 if pos('.cue',m3uplsstr)<>0 then
  begin
   while not eof(tfpls) do
    begin
     inc(kolstrcue);
     setlength(tfstrmas,kolstrcue+1);
     readln(tfpls,tfstr);
     tfstrmas[kolstrcue]:=trim(tfstr);
    end;
   for i:=1 to kolstrcue do
    begin
     if cuetrack='' then
      begin
       if (pos('.mp3',ansilowercase(tfstrmas[i]))<>0)  or
       (pos('.ogg',ansilowercase(tfstrmas[i]))<>0) or
       (pos('.wav',ansilowercase(tfstrmas[i]))<>0)  or
       (pos('.flac',ansilowercase(tfstrmas[i]))<>0) or
       (pos('.m4a',ansilowercase(tfstrmas[i]))<>0)  or
       (pos('.mpc',ansilowercase(tfstrmas[i]))<>0)  or
       (pos('.aiff',ansilowercase(tfstrmas[i]))<>0) then cuetrack:=copy(tfstrmas[i], pos('FILE "',tfstrmas[i])+6, PosR2L('"',tfstrmas[i])-pos('FILE "',tfstrmas[i])-6);
      end;
     if pos('TRACK',tfstrmas[i])<>0 then
      begin
       inc(itrack);
       setlength(m3uplsmass,itrack+1,3);
       if fileexists(cuetrack) then m3uplsmass[itrack,1]:=cuetrack else m3uplsmass[itrack,1]:=ExtractFilePath(m3uplsstr)+cuetrack;
       sindex:=1;
       while (pos('INDEX 01',tfstrmas[i+sindex])=0) and (sindex<5) do inc(sindex);
       if sindex=5 then m3uplsmass[itrack,1]:='#ts00:00:00st#'+m3uplsmass[itrack,1] else m3uplsmass[itrack,1]:='#ts'+copy(tfstrmas[i+sindex],pos('INDEX 01 ',tfstrmas[i+sindex])+9,length(tfstrmas[i+sindex])-pos('INDEX 01 ',tfstrmas[i+sindex])-8)+'st#'+m3uplsmass[itrack,1];
      end;
     end;

  end else

  begin
   while not eof(tfpls) do
    begin
     readln(tfpls,tfstr);
     if ((pos('.mp3',ansilowercase(tfstr))<>0)  or
        (pos('.ogg',ansilowercase(tfstr))<>0) or
        (pos('.wav',ansilowercase(tfstr))<>0)  or
        (pos('.flac',ansilowercase(tfstr))<>0) or
        (pos('.m4a',ansilowercase(tfstr))<>0)  or
        (pos('.mpc',ansilowercase(tfstr))<>0)  or
        (pos('.aiff',ansilowercase(tfstr))<>0)) and
        (pos('http',ansilowercase(tfstr))=0) then
      begin
       inc(i);
       setlength(m3uplsmass,i+1,3);
       if pos('.m3u',m3uplsstr)<>0 then
        begin
         if tfstr[1]='\' then tfstr:=copy(tfstr,2,length(tfstr)-1);
         if fileexists(tfstr) then m3uplsmass[i,1]:=tfstr else m3uplsmass[i,1]:=ExtractFilePath(m3uplsstr)+tfstr;
        end;
       if pos('.pls',m3uplsstr)<>0 then
        begin
         tfstr:=copy(tfstr,pos('=',tfstr)+1,length(tfstr)-pos('=',tfstr));
         if tfstr[1]='\' then tfstr:=copy(tfstr,2,length(tfstr)-1);
         if fileexists(tfstr) then m3uplsmass[i,1]:=tfstr else m3uplsmass[i,1]:=ExtractFilePath(m3uplsstr)+tfstr;
        end;
      end;

     if pos('http',ansilowercase(tfstr))<>0 then
      begin
       inc(i);
       setlength(m3uplsmass,i+1,3);
       if pos('.m3u',m3uplsstr)<>0 then
        begin
         if pos('#',tfstr)=0 then m3uplsmass[i,1]:=tfstr;
        end;
       if pos('.pls',m3uplsstr)<>0 then
        begin
         if pos('file',ansilowercase(tfstr))=1 then
          begin
           tfstr:=copy(tfstr,pos('=',tfstr)+1,length(tfstr)-pos('=',tfstr));
           m3uplsmass[i,1]:=tfstr;
          end;
        end;
      end;

    end;
   end;

   closefile(tfpls);
   tempallkolltrack:=length(m3uplsmass)-1;
   manyaddstart;
   exit;
end;

procedure PlayerExit;                  //закрыть плеер
begin
 if SinglePlayerSettings.savepos=1 then
  begin
//   PlayerSettingsINI.WriteInteger('SinglePlayer','curpos',bass_ChannelGetPosition(channel,0));
   SinglePlayerSettings.curpos:=bass_ChannelGetPosition(channel,0);
  end;
{ if (SinglePlayerSettings.startautoplay=1) then
  begin
   if mode=radioplay then PlayerSettingsINI.Writestring('SinglePlayer','lasturl',curenttrack) else PlayerSettingsINI.Writestring('SinglePlayer','lasturl','');
  end;}
 if mode<>closed then
  begin
   mode:=closed;    //установить статус плеера - выключен
   Bass_Stop(); //останавливаем проигрывание
   BASS_StreamFree(channel); // освобождаем звуковой канал
   BASS_StreamFree(radiochannel);
   Bass_Free;// Освобождаем ресурсы используемые Bass
  end;
 if SinglePlayerSettings.curentvol=0 then SinglePlayerSettings.curentvol:=tempvol;
 SinglePlayerGUI.PolSecondTimer.Enabled:=false;
 SinglePlayerGUI.PlayerTimer.Enabled:=false;
 clearmanymass;
 artist:='';
 title:='';
 tracksearchstr:='';
 {$IFDEF SP_STANDALONE}
 WritePlayerSettings;
 LoadingGUI.Close;
 MMCCore.Close;
 {$ENDIF}
 SinglePlayerGUI.Close;
end;

procedure TSinglePlayerGUI.FormDestroy(Sender: TObject);
begin
 if mode<>closed then PlayerExit;
 senderstr('SP_Exit');
 {$IFDEF SP_STANDALONE}
 LoadingGUI.Close;
 MMCCore.Close;
 {$ENDIF}
end;



{$IFDEF SP_STANDALONE}
procedure checkexplorer;
begin
 if (checktask(SinglePlayerSettings.altmenu)=0) and (CheckTask('explorer.exe')=0) then LaunchProcess('explorer.exe');
 ShowWindow(SinglePlayerGUI.Handle, SW_HIDE);
 MMCCore.hide;
 LoadingGUI.hide;
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

function LoadBMP(Path: String): HBITMAP;
var WS: WideString;
begin
  WS:=Path;
  {$IFDEF WInCE}
  Result:=SHLoadDIBitmap(PWideChar(WS));
  {$ELSE}
  Result:=LoadImageW(0,PWideChar(WS),IMAGE_BITMAP,0,0,LR_LOADFROMFILE);
  {$ENDIF}
end;
{$ENDIF}


initialization

  WM_IMCOMMAND:= RegisterWindowMessage('WM_IMCOMMAND');


end.

