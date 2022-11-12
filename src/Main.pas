unit Main;

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
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ExtCtrls, ComCtrls,
  StdCtrls, ActnList, EditBtn, PackageEngines;

type

  { TMainForm }

  TMainForm = class(TForm)
    Actions: TActionList;
    Label1: TLabel;
    NewAction: TAction;
    OpenAction: TAction;
    SaveAction: TAction;
    SaveAsAction: TAction;
    AddAction: TAction;
    DeleteAction: TAction;
    GenerateAction: TAction;
    ExtractAction: TAction;
    ReviewAction: TAction;
    ExitAction: TAction;
    AboutAction: TAction;
    EnableImages: TImageList;
    DisableImage: TImageList;
    MainMenu: TMainMenu;
    FileMenu: TMenuItem;
    NewMenu: TMenuItem;
    OpenMenu: TMenuItem;
    SaveMenu: TMenuItem;
    SaveAsMenu: TMenuItem;
    FileSeparator: TMenuItem;
    AddMenu: TMenuItem;
    DeleteMenu: TMenuItem;
    GenerateSeparator: TMenuItem;
    GenerateMenu: TMenuItem;
    ExtractMenu: TMenuItem;
    ExitSeparator: TMenuItem;
    ReviewMenu: TMenuItem;
    ExitMenu: TMenuItem;
    HelpMenu: TMenuItem;
    AboutMenu: TMenuItem;
    ToolBar: TToolBar;
    NewButton: TToolButton;
    OpenButton: TToolButton;
    SaveButton: TToolButton;
    SaveAsButton: TToolButton;
    FileDivider: TToolButton;
    AddButton: TToolButton;
    DeleteButton: TToolButton;
    OperationDivider: TToolButton;
    GenerateButton: TToolButton;
    ExtractButton: TToolButton;
    ButtonPanel: TPanel;
    DriveLabel: TLabel;
    DriveEdit: TEdit;
    ReviewButton: TToolButton;
    UserLabel: TLabel;
    UserEdit: TEdit;
    UserHexLabel: TLabel;
    PadEdit: TCheckBox;
    PadCharEdit: TEdit;
    PadCharHexLabel: TLabel;
    PackageFileLabel: TLabel;
    PackageFileNameEdit: TFileNameEdit;
    ListView: TListView;
    StatusPanel: TPanel;
    StatusLabel: TLabel;
    ProgressBar: TProgressBar;
    StatusBar: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure NewActionExecute(Sender: TObject);
    procedure NewActionUpdate(Sender: TObject);
    procedure OpenActionExecute(Sender: TObject);
    procedure SaveActionExecute(Sender: TObject);
    procedure SaveActionUpdate(Sender: TObject);
    procedure SaveAsActionExecute(Sender: TObject);
    procedure SaveAsActionUpdate(Sender: TObject);
    procedure AddActionExecute(Sender: TObject);
    procedure DeleteActionExecute(Sender: TObject);
    procedure DeleteActionUpdate(Sender: TObject);
    procedure GenerateActionExecute(Sender: TObject);
    procedure GenerateActionUpdate(Sender: TObject);
    procedure ExtractActionExecute(Sender: TObject);
    procedure ReviewActionExecute(Sender: TObject);
    procedure ReviewActionUpdate(Sender: TObject);
    procedure ExitActionExecute(Sender: TObject);
    procedure ExitActionUpdate(Sender: TObject);
    procedure AboutActionExecute(Sender: TObject);
    procedure DriveEditKeyPress(Sender: TObject; var Key: char);
    procedure HexidecimalKeyPress(Sender: TObject; var Key: char);
    procedure PadEditChange(Sender: TObject);
    procedure ListViewDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ListViewDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of string);
    procedure HintEvent(Sender: TObject);
  private type
    TUser = 0..15;
  private
    FEngine: TPackageEngine;
    FIsBusy: Boolean;
    FIsModified: Boolean;
    FDrive: Char;
    FUser: TUser;
    FMayPad: Boolean;
    FPadChar: Char;
    FDocumentFileName: TFileName;
    procedure OpenFiles(const FileName: TFileName);
    procedure SaveFiles(const FileName: TFileName);
    procedure AddFile(const FileName: String);
    procedure GetFilesInDirs(const Path: String);
    function GetDocumentFileName: TFileName;
    procedure SetDocumentFileName(const Value: TFileName);
  protected
    procedure DoStart(Sender: TObject; Max: Integer; const Text: String);
    procedure DoStatus(Sender: TObject; Position: Integer; const Text: String);
    procedure DoEnd(Sender: TObject);
    procedure DoError(Sender: TObject; const Text: String);
    function GetIsModified: Boolean;
    function GetDrive: Char;
    procedure SetDrive(Value: Char);
    function GetUser: TUser;
    procedure SetUser(Value: TUser);
    function GetMayPad: Boolean;
    procedure SetMayPad(Value: Boolean);
    function GetPadChar: Char;
    procedure SetPadChar(Value: Char);
    function GetPackageFileName: TFileName;
    procedure SetPackageFileName(const Value: TFileName);
    property DocumentFileName: TFileName read GetDocumentFileName write SetDocumentFileName;
  public
    property IsModified: Boolean read GetIsModified;
    property Drive: Char read GetDrive write SetDrive;
    property User: TUser read GetUser write SetUser;
    property MayPad: Boolean read GetMayPad write SetMayPad;
    property PadChar: Char read GetPadChar write SetPadChar;
    property PackageFileName: TFileName read GetPackageFileName write SetPackageFileName;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

uses
  Windows, FileUtil, Math, FpJson, ConfigUtils, Abouts, ExtractionForms;

const
  CFG_DRIVE = 'Drive';
  CFG_USER = 'User';
  CFG_MAY_PAD = 'MayPad';
  CFG_PAD_CHAR = 'PadChar';
  CFG_FILE_NAME = 'FileName';
  CFG_FILES = 'Files';

function GetShortName(LongName: String): String;
var
  ShortName: String = '';
  Len: Integer = 0;
begin
  SetLength(ShortName, MAX_PATH);
  Len := GetShortPathName(PChar(LongName), PChar(ShortName), MAX_PATH - 1);
  SetLength(ShortName, Len);
  Result := ShortName;
end;

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
const
  MASK = 'V.%s %s %s';
begin
  Config.ReadConfig(Self);
  FEngine := TPackageEngine.Create(Self, ListView);
  FEngine.OnStart := DoStart;
  FEngine.OnStatus := DoStatus;
  FEngine.OnEnd := DoEnd;
  FEngine.OnError := DoError;
  FIsBusy := False;
  StatusBar.Panels[0].Text := Format(MASK, [Config.VersionText, Config.Platform, Config.PreRelease]).Trim;
  StatusBar.Panels[0].Width := StatusBar.Canvas.TextWidth(StatusBar.Panels[0].Text) + 10;
  Application.OnHint := HintEvent;
  NewAction.Execute;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
const
  TITLE = 'Exit Utility';
  PROMPT  = 'Do you want to save modified data?';
begin
  CanClose := not IsModified;
  if not CanClose then begin
    if MessageDlg(TITLE, PROMPT, mtConfirmation, [mbYes, mbNo], 0, mbNo) = mrYes then
      SaveAction.Execute;
    CanClose := True;
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  Config.WriteConfig(Self);
end;

procedure TMainForm.NewActionExecute(Sender: TObject);
var
  OldCursor: TCursor;
begin
  OldCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  try
    ListView.Items.Clear;
    DocumentFileName := EmptyStr;
    Drive := DEF_DRIVE;
    User := DEF_USER;
    MayPad := DEF_MAY_PAD;
    PadChar := DEF_PAD_CHAR;
    PackageFileName := EmptyStr;
    FIsModified := False;
  finally
    Screen.Cursor := OldCursor;
  end;
end;

procedure TMainForm.NewActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (ListView.Items.Count > 0) or IsModified;
end;

procedure TMainForm.OpenActionExecute(Sender: TObject);
const
  TITLE = 'Select Paleo Packager File to Open';
  DEAULT_EXT = 'ppf';
  FILTER = 'Paleo Packager Files (*.ppf)|*.ppf';
  OPTIONS = [ofFileMustExist, ofEnableSizing, ofViewDetail];
var
  Dialog: TOpenDialog;
begin
  FIsBusy := True;
  try
    Dialog := TOpenDialog.Create(nil);
    try
      Dialog.Title := TITLE;
      Dialog.DefaultExt := DEAULT_EXT;
      Dialog.Filter := FILTER;
      Dialog.FilterIndex := 0;
      Dialog.Options := OPTIONS;
      if Dialog.Execute then
        OpenFiles(Dialog.FileName);
    finally
      Dialog.Free;
    end;
  finally
    FIsBusy := False;
  end;
end;

procedure TMainForm.SaveActionExecute(Sender: TObject);
begin
  if FileExists(DocumentFileName) then
    SaveFiles(DocumentFileName)
  else
    SaveAsAction.Execute;
end;

procedure TMainForm.SaveActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := IsModified;
end;

procedure TMainForm.SaveAsActionExecute(Sender: TObject);
const
  TITLE = 'Save Paleo Packager File';
  DEAULT_EXT = 'ppf';
  FILTER = 'Paleo Packager Files (*.ppf)|*.ppf';
  OPTIONS = [ofEnableSizing, ofViewDetail];
var
  Dialog: TSaveDialog;
begin
  FIsBusy := True;
  try
    Dialog := TSaveDialog.Create(nil);
    try
      Dialog.Title := TITLE;
      Dialog.DefaultExt := DEAULT_EXT;
      Dialog.Filter := FILTER;
      Dialog.FilterIndex := 0;
      Dialog.Options := OPTIONS;
      if FileExists(DocumentFileName) then begin
        Dialog.InitialDir := ExtractFilePath(DocumentFileName);
        Dialog.FileName :=  DocumentFileName;
      end;
      if Dialog.Execute then
        SaveFiles(Dialog.FileName);
    finally
      Dialog.Free;
    end;
  finally
    FIsBusy := False;
  end;
end;

procedure TMainForm.SaveAsActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := ListView.Items.Count > 0;
end;

procedure TMainForm.AddActionExecute(Sender: TObject);
const
  TITLE = 'Add Files to Package';
  DEAULT_EXT = 'com';
  FILTER = 'COM Files (*.com)|*.com|Hex Files (*.hex)|*.hex|All Files (*.*)|*.*';
  OPTIONS = [ofAllowMultiSelect, ofFileMustExist, ofEnableSizing, ofDontAddToRecent, ofViewDetail];
var
  Dialog: TOpenDialog;
  FileName: TFileName;
begin
  FIsBusy := True;
  try
    Dialog := TOpenDialog.Create(nil);
    try
      Dialog.Title := TITLE;
      Dialog.DefaultExt := DEAULT_EXT;
      Dialog.Filter := FILTER;
      Dialog.FilterIndex := 1;
      Dialog.Options := OPTIONS;
      if Dialog.Execute then begin
        ListView.BeginUpdate;
        try
          for FileName in Dialog.Files do
            AddFile(FileName);
        finally
          ListView.EndUpdate;
        end;
      end;
    finally
      Dialog.Free;
    end;
  finally
    FIsBusy := False;
  end;
end;

procedure TMainForm.DeleteActionExecute(Sender: TObject);
const
  TITLE = 'Delete Files from Package';
  PROMPT  = 'Are you sure you want to delete the selected file?';
var
  I: Integer;
begin
  if MessageDlg(TITLE, PROMPT, mtConfirmation, [mbYes, mbNo], 0, mbNo) = mrYes then begin
    for I := ListView.Items.Count - 1 downto 0 do
      if ListView.Items[I].Selected then
        ListView.Items.Delete(I);
    FIsModified := True;
  end;
end;

procedure TMainForm.DeleteActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := ListView.SelCount > 0;
end;

procedure TMainForm.GenerateActionExecute(Sender: TObject);
var
  OldCursor: TCursor;
  Temp: TStringList;
begin
  FIsBusy := True;
  OldCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  try
    FEngine.Drive := Drive;
    FEngine.User := User;
    FEngine.MayPad := MayPad;
    FEngine.Padding := Ord(PadChar);
    Temp := FEngine.Generate;
    try
      if FileExists(PackageFileName) then
        SysUtils.DeleteFile(PackageFileName);
      Temp.SaveToFile(PackageFileName)
    finally
      Temp.Free;
    end;
  finally
    Screen.Cursor := OldCursor;
    FIsBusy := False;
  end;
end;

procedure TMainForm.GenerateActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (ListView.Items.Count > 0) and (PackageFileName <> EmptyStr)
end;

procedure TMainForm.ExtractActionExecute(Sender: TObject);
var
  FileName: TFileName = '';
  FolderName: TFileName = '';
begin
  FileName := PackageFileName;
  if ExtractPackage(FileName, FolderName) then begin
    FIsBusy := True;
    try
      FEngine.Extract(FileName, FolderName);
    finally
      FIsBusy := False;
    end;
  end;
end;

procedure TMainForm.ReviewActionExecute(Sender: TObject);
const
  SHELL = 'notepad.exe';
  MASK = '"%s"';
begin
  ShellExecute(0, nil, PChar(SHELL), PChar(Format(MASK, [PackageFileName])), nil, SW_NORMAL);
end;

procedure TMainForm.ReviewActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := FileExists(PackageFileName);
end;

procedure TMainForm.ExitActionExecute(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.ExitActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := not FIsBusy;
end;

procedure TMainForm.AboutActionExecute(Sender: TObject);
begin
  ShowAbout;
end;

procedure TMainForm.DriveEditKeyPress(Sender: TObject; var Key: char);
const
  VALID_CHAR = [#8, 'A'..'J', 'a'..'j'];
begin
  if not (Key in VALID_CHAR) then
    Key := #0;
end;

procedure TMainForm.HexidecimalKeyPress(Sender: TObject; var Key: char);
const
  VALID_CHAR = [#8, '0'..'9', 'A'..'F', 'a'..'f'];
begin
  if not (Key in VALID_CHAR) then
    Key := #0;
end;

procedure TMainForm.PadEditChange(Sender: TObject);
begin
  PadCharEdit.Enabled := (Sender as TCheckBox).Checked;
end;

procedure TMainForm.ListViewDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  CurrentItem: TListItem;
  NextItem: TListItem;
  DragItem: TListItem;
  DropItem : TListItem;
  I: integer;
begin
  if Sender = Source then
  begin
    with TListView(Sender) do begin
      DropItem := GetItemAt(X, Y);
      CurrentItem := Selected;
      while CurrentItem <> nil do begin
        NextItem := nil;
        for I := 0 to Items.Count - 1 do begin
         if Items[I].Selected and (CurrentItem.Index <> I) then begin
           NextItem := Items[I];
           Break;
         end;
        end;
        if Assigned(DropItem) then
          DragItem := Items.Insert(DropItem.Index)
        else
          DragItem := Items.Add;
        DragItem.Assign(CurrentItem);
        DragItem.Selected := True;
        CurrentItem.Free;
        CurrentItem := NextItem;
      end;
    end;
  end;
end;

procedure TMainForm.ListViewDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept := Source = Sender;
end;

procedure TMainForm.FormDropFiles(Sender: TObject; const FileNames: array of String);
var
  Counter: Integer;
  FileName: TFileName;
begin
  if (Length(FileNames) = 1) and AnsiSameText(ExtractFileExt(FileNames[0]), '.ppf') then
    OpenFiles(FileNames[0])
  else begin
    ListView.BeginUpdate;
    try
      for Counter := 0 to Length(FileNames) - 1 do begin
        FileName := FileNames[Counter];
        if DirectoryExists(FileName) then
          GetFilesInDirs(FileName)
        else
          AddFile(FileName);
      end;
    finally
      ListView.EndUpdate;
    end;
  end;
end;

procedure TMainForm.HintEvent(Sender: TObject);
begin
  StatusBar.Panels[1].Text := Application.Hint;
end;

procedure TMainForm.OpenFiles(const FileName: TFileName);
var
  OldCursor: TCursor;
  Config: TJSONObject;
  Data: TJSONdata;
  Files: TJSONarray;
  I: Integer;

  function LoadString(const FileName: TFileName): String;
  var
    Temp: TStringList;
  begin
    if not FileExists(FileName) then
      Result := EmptyStr
    else begin
      Temp := TStringList.Create;
      try
        Temp.LoadFromFile(FileName);
        Result := Temp.Text;
      finally
        Temp.Free;
      end;
    end;
  end;

begin
  OldCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  try
    if FileExists(FileName) then begin
      DocumentFileName := FileName;
      Config := GetJSON(LoadString(FileName)) as TJsonObject;
      if Assigned(Config) then
        try
          if Config.Find(CFG_DRIVE, Data) then
              Drive := Chr(Data.AsInteger)
            else
              Drive := DEF_DRIVE;
          if Config.Find(CFG_USER, Data) then
            User := Data.AsInteger
          else
            User := DEF_USER;
          if Config.Find(CFG_MAY_PAD, Data) then
            MayPad := Data.AsBoolean
          else
            MayPad := DEF_MAY_PAD;
          if Config.Find(CFG_PAD_CHAR, Data) then
            PadChar := Chr(Data.AsInteger)
          else
            PadChar := DEF_PAD_CHAR;
          if Config.Find(CFG_FILE_NAME, Data) then
            PackageFileName := Data.AsString
          else
            PackageFileName := EmptyStr;
          ListView.BeginUpdate;
          try
            ListView.Items.Clear;
            if Config.Find(CFG_FILES, Files) then begin
              for I := 0 to Files.Count - 1 do
                AddFile(Files[I].AsString);
          end;
          finally
            ListView.EndUpdate;
          end;
        finally
          Config.Free;
        end;
      FIsModified := False;
    end;
  finally
    Screen.Cursor := OldCursor;
  end;
end;

procedure TMainForm.SaveFiles(const FileName: TFileName);
var
  OldCursor: TCursor;
  Config: TJsonObject;
  Item: TListItem;

  procedure SaveString(const FileName: TFileName; Value: String);
  var
    Stream: TStringStream;
  begin
    if FileExists(FileName) then
      SysUtils.DeleteFile(FileName);
    Stream := TStringStream.Create(Value);
    try
      Stream.Position := 0;
      Stream.SaveToFile(FileName);
    finally
      Stream.Free;
    end;
  end;

begin
  OldCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  try
    if FileExists(FileName) then
      SysUtils.DeleteFile(FileName);
    Config := TJsonObject.Create;
    try
      Config.Add(CFG_DRIVE, Ord(Drive));
      Config.Add(CFG_USER, User);
      Config.Add(CFG_MAY_PAD, MayPad);
      Config.Add(CFG_PAD_CHAR, Ord(PadChar));
      Config.Add(CFG_FILE_NAME, PackageFileName);
      Config.Add(CFG_FILES, TJsonArray.Create);
      for Item in ListView.Items do
        Config.Arrays[CFG_FILES].Add(Item.Caption);
      SaveString(FileName, Config.FormatJSON);
    finally
      Config.Free;
    end;
    FIsModified := False;
    FDrive := Drive;
    FUser := User;
    FMayPad := MayPad;
    FPadChar := PaDcHAR;
  finally
    Screen.Cursor := OldCursor;
  end;
end;

procedure TMainForm.AddFile(const FileName: String);
const
  KILOBYTE = 1024.0;
  MASK = '%d KB';
var
  Item: TListItem;
  Size: Integer;
  ShortFileName: TFileName;

  function IsFound(FileName: TFileName): Boolean;
  const
    TITLE = 'Duplicate File';
    PROMPT = 'Cannot add duplicate file ''%s''.';
  var
    I: Integer;
  begin
    Result := False;
    FileName := GetShortName(FileName);
    FileName := ExtractFileName(FileName);
    for I := 0 to ListView.Items.Count - 1 do begin
      if AnsiSameText(FileName, ListView.Items[I].SubItems[IDX_SHORT_NAME]) then begin
        Result := True;
        Break;
      end;
    end;
    if Result then
      MessageDlg(TITLE, Format(PROMPT, [FileName]), mtError, [mbOK], 0, mbOK)
  end;

begin
  if FileExists(FileName) then begin
    if not IsFound(FileName) then begin
      Item := ListView.Items.Add;
      Item.Caption := FileName;
      Size := Ceil(FileSize(FileName) / KILOBYTE);
      Item.SubItems.Add(Format(MASK, [Size]));
      ShortFileName := GetShortName(FileName).ToUpper;
      Item.SubItems.Add(ShortFileName);
      Item.SubItems.Add(ExtractFileName(ShortFileName));
      Item.ImageIndex := 8;
    end;
  end;
  FIsModified := True;
end;

procedure TMainForm.GetFilesInDirs(const Path: String);
var
  DirInfo: TSearchRec;
begin
  if SysUtils.FindFirst(Path + DirectorySeparator + '*', faAnyFile and faDirectory, DirInfo) = 0 then begin
    repeat
      if (DirInfo.Attr and faDirectory) = faDirectory then begin
        if (DirInfo.Name <> '.') and (DirInfo.Name <> '..') then
          GetFilesInDirs(Path + DirectorySeparator + DirInfo.Name); end
      else
        AddFile(Path + DirectorySeparator + DirInfo.Name);
    until SysUtils.FindNext(DirInfo) <> 0;
    SysUtils.FindClose(DirInfo);
  end;
end;

function TMainForm.GetDocumentFileName: TFileName;
begin
  Result := FDocumentFileName;
end;

procedure TMainForm.SetDocumentFileName(const Value: TFileName);
const
  MASK: array[Boolean] of String =
   ('Paleo Packager - [%s]',
    'Paleo Packager');
begin
  FDocumentFileName := Value;
  Caption := Format(MASK[Value = EmptyStr], [Value]);
end;

procedure TMainForm.DoStart(Sender: TObject; Max: Integer; const Text: String);
begin
  StatusLabel.Caption := 'Generating Package File…';
  StatusLabel.Caption := Text;
  ProgressBar.Position := 0;
  ProgressBar.Max := Max;
  StatusPanel.Visible := True;
  Application.ProcessMessages;
end;

procedure TMainForm.DoStatus(Sender: TObject; Position: Integer; const Text: String);
begin
  StatusLabel.Caption := Text;
  ProgressBar.Position := Position;
  Application.ProcessMessages;
end;

procedure TMainForm.DoEnd(Sender: TObject);
begin
  StatusPanel.Visible := False;
  StatusLabel.Caption := EmptyStr;
  ProgressBar.Position := 0;
  ProgressBar.Max := 100;
  Application.ProcessMessages;
end;

procedure TMainForm.DoError(Sender: TObject; const Text: String);
const
  TITLE = 'Error';
begin
  MessageDlg(TITLE, Text, mtError, [mbOK], 0, mbOK);
end;

function TMainForm.GetIsModified: Boolean;
begin
  Result := FIsModified or (Drive <> FDrive) or (User <> FUser) or
    (MayPad <> FMayPad) or (PadChar <> FPadChar);
end;

function TMainForm.GetDrive: Char;
begin
  if Length(DriveEdit.Text) > 0 then
    Result := DriveEdit.Text[1]
  else
    Result := DEF_DRIVE;
end;

procedure TMainForm.SetDrive(Value: Char);
begin
  DriveEdit.Text := Value;
  FDrive := Value;
end;

function TMainForm.GetUser: TUser;
const
  MIN = 0;
  MAX = 15;
var
  Temp: Integer;
begin
  Temp := StrToIntDef(UserEdit.Text, DEF_USER);
  if Temp < MIN then
    Result := MIN
  else
    if Temp > MAX then
      Result := MAX
    else
      Result := Temp;
end;

procedure TMainForm.SetUser(Value: TUser);
begin
  UserEdit.Text := IntToHex(Value, 1);
  FUser := Value;
end;

function TMainForm.GetMayPad: Boolean;
begin
  Result := PadEdit.Checked;
end;

procedure TMainForm.SetMayPad(Value: Boolean);
begin
  PadEdit.Checked := Value;
  FMayPad := Value;
  PadCharEdit.Enabled := Value;
end;

function TMainForm.GetPadChar: Char;
begin
  Result := Char(StrToIntDef(PadCharEdit.Text, 0));
end;

procedure TMainForm.SetPadChar(Value: Char);
begin
  PadCharEdit.Text := IntToHex(Ord(Value), 2);
  FPadChar := Value;
end;

function TMainForm.GetPackageFileName: TFileName;
begin
  Result := ExcludeTrailingPathDelimiter(PackageFileNameEdit.FileName);
end;

procedure TMainForm.SetPackageFileName(const Value: TFileName);
begin
  PackageFileNameEdit.FileName := ExcludeTrailingPathDelimiter(Value);
end;

end.

