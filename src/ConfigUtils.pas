unit ConfigUtils;

{ Copyright ©2022 by Steve Garcia. All rights reserved.

  This file is part of the Paleo Packager project, inspired by the work of Grant Searle.

  The Paleo Packager is free software: you can redistribute it and/or modify it under the
  terms of the GNU General Public License as published by the Free Software Foundation,
  either version 3 of the License, or (at your option) any later version.

  The Paleo Packager project is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
  PARTICULAR PURPOSE. See the GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along with the Paleo
  Packager project. If not, see <https://www.gnu.org/licenses/>. }

{$MODE DELPHI}

interface

uses
  Classes, SysUtils, Forms;

type
  TConfig = class(TObject)
  private type
    TVersion = record
      Major: Word;
      Minor: Word;
      Release: Word;
      Build: Word;
      IsDebug: Boolean;
      IsPreRelease: Boolean;
      IsPatched: Boolean;
      IsPrivateBuild: Boolean;
      IsSpecialBuild: Boolean;
      CompanyName: String;
      InternalName: String;
      ProjectName: String;
      FileVersion: String;
    end;
  private
    FConfigFileName: TFileName;
    FVersion: TVersion;
  protected
    function IsMatch(const Value: String; const Masks: String): Boolean;
    function GetVersionText: String;
    function GetPlatform: String; overload;
    function GetDebug: String;
    function GetPreRelease: String;
    function GetPatched: String;
    function GetPrivateBuild: String;
    function GetSpecialBuild: String;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure ReadConfig(Form: TForm); overload;
    procedure WriteConfig(Form: TForm); overload;
    property ConfigFileName: TFileName read FConfigFileName;
    property Version: TVersion read FVersion;
    property VersionText: String read GetVersionText;
    property Platform: String read GetPlatform;
    property Debug: String read GetDebug;
    property PreRelease: String read GetPreRelease;
    property Patched: String read GetPatched;
    property PrivateBuild: String read GetPrivateBuild;
    property SpecialBuild: String read GetSpecialBuild;
  end;

var
  Config: TConfig;

implementation

{$WARN 05044 OFF}{$WARN 06058 OFF}

uses
  StrUtils, Types, Masks, FileInfo, VersionTypes, TypInfo, Dialogs, IniFiles;

const
  DELIMITER                = ';';
  INI_CONFIG               = '%s\Paleo\Packager.ini';
  INI_HEIGHT               = 'Height';
  INI_LEFT                 = 'Left';
  INI_LEFT_DEF             = 100;
  INI_TOP                  = 'Top';
  INI_TOP_DEF              = 100;
  INI_WIDTH                = 'Width';
  INI_WIN_STATE            = 'WindowsState';
  INI_WIN_STATE_DEF        = 'wsNormal';

{ TConfig }

constructor TConfig.Create;
const
  DEBUG_BIT         = $01;
  PRE_RELEASE_BIT   = $02;
  PATCHED_BIT       = $04;
  PRIVATE_BUILD_BIT = $08;
  SPECIAL_BUILD_BIT = $20;
var
  VersionInfo: TVersionInfo;

  function SearchValue(Info: TVersionStringFileInfo; const Value: string): string;
  var
    S: TVersionStringTable;
    I: integer;
    J: integer;
  begin
    Result := EmptyStr;
    for I := 0 to Info.Count - 1 do begin
      S := Info.Items[I];
      for J := 0 to S.Count - 1 do
        if S.Keys[J] = Value then begin
          Result := S.Values[J];
          Break;
        end;
    end;
  end;

begin
  inherited Create;
  FConfigFileName := GetEnvironmentVariable('APPDATA');
  FConfigFileName := Format(INI_CONFIG, [FConfigFileName]);
  VersionInfo := TVersionInfo.Create;
  try
    VersionInfo.Load(Application.Handle);
    FVersion.Major := VersionInfo.FixedInfo.FileVersion[0];
    FVersion.Minor := VersionInfo.FixedInfo.FileVersion[1];
    FVersion.Release := VersionInfo.FixedInfo.FileVersion[2];
    FVersion.Build := VersionInfo.FixedInfo.FileVersion[3];
    FVersion.IsDebug := VersionInfo.FixedInfo.FileFlags and DEBUG_BIT > 0;
    FVersion.IsPreRelease := VersionInfo.FixedInfo.FileFlags and PRE_RELEASE_BIT > 0;
    FVersion.IsPatched := VersionInfo.FixedInfo.FileFlags and PATCHED_BIT > 0;
    FVersion.IsPrivateBuild := VersionInfo.FixedInfo.FileFlags and PRIVATE_BUILD_BIT > 0;
    FVersion.IsSpecialBuild := VersionInfo.FixedInfo.FileFlags and SPECIAL_BUILD_BIT > 0;
    FVersion.CompanyName := SearchValue(VersionInfo.StringFileInfo, 'CompanyName');
    FVersion.InternalName := SearchValue(VersionInfo.StringFileInfo, 'InternalName');
    FVersion.ProjectName := SearchValue(VersionInfo.StringFileInfo, 'FileVersion');
    FVersion.FileVersion := SearchValue(VersionInfo.StringFileInfo, 'ProductName');
  finally
    VersionInfo.Free;
  end;
end;

destructor TConfig.Destroy;
begin
  inherited;
end;

function TConfig.IsMatch(const Value: String; const Masks: String): Boolean;
var
  List: TStringDynArray;
  Mask: String;
begin
  Result := False;
  List := SplitString(Masks, DELIMITER);
  for Mask in List do
    if MatchesMask(Value, Mask) then begin
      Result := True;
      Break;
    end;
end;

function TConfig.GetVersionText: String;
const
  MASK = '%d.%d.%d';
begin
  Result := Format(MASK, [Version.Major, Version.Minor, Version.Release]);
end;

function TConfig.GetPlatform: String;
const
{$if defined(Win32)}
  PLATFORM = 'Win32';
{$elseif defined(Win64)}
  PLATFORM = 'Win64';
{$else}
  PLATFORM = EmptyStr;
{$endif}
begin
  Result := PLATFORM;
end;

function TConfig.GetDebug: String;
const
  CAPTIONS: array[Boolean] of String = ('', 'Debug');
begin
  Result := CAPTIONS[Version.IsDebug];
end;

function TConfig.GetPreRelease: String;
const
  CAPTIONS: array[Boolean] of String = ('', 'Pre-Release');
begin
  Result := CAPTIONS[Version.IsPreRelease];
end;

function TConfig.GetPatched: String;
const
  CAPTIONS: array[Boolean] of String = ('', 'Patched');
begin
  Result := CAPTIONS[Version.IsPatched];
end;

function TConfig.GetPrivateBuild: String;
const
  CAPTIONS: array[Boolean] of String = ('', 'Private');
begin
  Result := CAPTIONS[Version.IsPrivateBuild];
end;

function TConfig.GetSpecialBuild: String;
const
  CAPTIONS: array[Boolean] of String = ('', 'Special');
begin
  Result := CAPTIONS[Version.IsSpecialBuild];
end;

procedure TConfig.ReadConfig(Form: TForm);
var
  Ini: TIniFile;
  Temp: String;
begin
  Ini := TIniFile.Create(ConfigFileName);
  try
    Form.Height := Ini.ReadInteger(Form.ClassName, INI_HEIGHT, Form.Constraints.MinHeight);
    Form.Left := Ini.ReadInteger(Form.ClassName, INI_LEFT, INI_LEFT_DEF);
    Form.Top := Ini.ReadInteger(Form.ClassName, INI_TOP, INI_TOP_DEF);
    Form.Width := Ini.ReadInteger(Form.ClassName, INI_WIDTH, Form.Constraints.MinWidth);
    Temp := Ini.ReadString(Form.ClassName, INI_WIN_STATE, INI_WIN_STATE_DEF);
    Form.WindowState := TWindowState(GetEnumValue(TypeInfo(TWindowState), Temp));
  finally
    Ini.Free;
  end;
end;

procedure TConfig.WriteConfig(Form: TForm);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(ConfigFileName);
  try
    Ini.WriteInteger(Form.ClassName, INI_HEIGHT, Form.Height);
    Ini.WriteInteger(Form.ClassName, INI_LEFT, Form.Left);
    Ini.WriteInteger(Form.ClassName, INI_TOP, Form.Top);
    Ini.WriteInteger(Form.ClassName, INI_WIDTH, Form.Width);
    Ini.WriteString(Form.ClassName, INI_WIN_STATE, GetEnumName(TypeInfo(TWindowState), Ord(Form.WindowState)));
  finally
    Ini.Free;
  end;
end;

initialization
  Config := TConfig.Create;
finalization
  Config.Free;
end.

