{
Author of the code: alex208210.
SinglePlayer code is distributed under Mozilla Public Licence, which means, in short, that it is free for both freeware and commercial use.You can use it in products with closed or open-source freely. The only requirements are:
1) Acknowledge SinglePlayer code is used somewhere in your application (in an about box, credits page or printed manual, etc. with at least a link to http://singleplayer.coddism.com/)
2) Modifications made to SinglePlayer code must be made public (no need to publish the full code, only to state which parts were altered, and how), but feel welcome to open-source your code if you so wish.
}
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
  logoicon:TJPEGImage;

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
 if fileexists(ExtractFilePath(ParamStr(0))+'logo.jpg') then LoadingGUI.Canvas.Draw(0,0,logoicon);
 label1.Caption:='v'+singleplayer.playerversion;
end;

procedure TLoadingGUI.FormShow(Sender: TObject);
begin
 if fileexists(ExtractFilePath(ParamStr(0))+'logo.jpg') then image1.Visible:=false;
end;

end.

