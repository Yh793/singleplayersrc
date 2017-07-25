unit loading;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

type

  { TLoadingGUI }

  TLoadingGUI = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    LabelText: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  LoadingGUI: TLoadingGUI;
  logoicon:graphics.tbitmap;
  logoiconP:Tpicture;

implementation

uses singleplayer;

{$R *.lfm}

{ TLoadingGUI }

procedure TLoadingGUI.FormCreate(Sender: TObject);
begin
  Left:=0;
  Top:=0;
  width:=800;
  height:=480;
  Color:=clBlack;
  labeltext.Font.Color:=$FFFFFF;
end;

procedure TLoadingGUI.FormPaint(Sender: TObject);
begin
 if fileexists(ExtractFilePath(ParamStr(0))+'logo.bmp') then LoadingGUI.Canvas.Draw(0,0,logoiconP.bitmap);
 label1.Caption:='v'+singleplayer.playerversion;
end;

procedure TLoadingGUI.FormShow(Sender: TObject);
begin
 if fileexists(ExtractFilePath(ParamStr(0))+'logo.bmp') then image1.Visible:=false;
end;

end.

