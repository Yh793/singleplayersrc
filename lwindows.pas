unit lwindows;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  UINT = LongWord;
  LPCSTR = PAnsiChar;
  LPWSTR = PWideChar;
  LPSTR = PAnsiChar;
  PBOOL = ^BOOLEAN;



const

 CP_ACP          = 0;     //  ANSI code page
 CP_OEMCP        = 1;     //  OEM code page
 CP_MACCP        = 2;     //  MAC code page
 CP_THREAD_ACP   = 3;     //  ANSI code page only for current thread
 CP_SYMBOL       = 42;    //  SYMBOL code page
 CP_ISO8859_4    = 28594; //  baltic code page
 CP_ISO8859_15   = 28605; //  latin 9 code page
 CP_UTF7         = 65000; //  UTF-7 code page
 CP_UTF8         = 65001; //  UTF-8 code page


 MB_PRECOMPOSED       = $01; // precomposed chars
 MB_COMPOSITE         = $02; // composite chars
 MB_USEGLYPHCHARS     = $04; // glyph chars, not ctrl chars
 MB_ERR_INVALID_CHARS = $08; // error for invalid chars

function MultiByteToWideChar(CodePage: UINT; dwFlags: DWORD;
  const lpMultiByteStr: LPCSTR; cchMultiByte: Integer;
  lpWideCharStr: LPWSTR; cchWideChar: Integer): Integer;

function WideCharToMultiByte(CodePage: UINT; dwFlags: DWORD;
  lpWideCharStr: LPWSTR; cchWideChar: Integer; lpMultiByteStr: LPSTR;
  cchMultiByte: Integer; lpDefaultChar: LPCSTR; lpUsedDefaultChar: PBOOL): Integer;

implementation

function MultiByteToWideChar(CodePage: UINT; dwFlags: DWORD;
  const lpMultiByteStr: LPCSTR; cchMultiByte: Integer;
  lpWideCharStr: LPWSTR; cchWideChar: Integer): Integer;
begin
  result := 0;
end;

function WideCharToMultiByte(CodePage: UINT; dwFlags: DWORD;
  lpWideCharStr: LPWSTR; cchWideChar: Integer; lpMultiByteStr: LPSTR;
  cchMultiByte: Integer; lpDefaultChar: LPCSTR; lpUsedDefaultChar: PBOOL): Integer;
begin
  result := 0;
end;

end.

