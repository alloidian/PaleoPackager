unit ExtractionForms;

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
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn,
  ActnList;

type

  { TExtractionForm }

  TExtractionForm = class(TForm)
    CloseAction: TAction;
    ExtractAction: TAction;
    Actions: TActionList;
    FileNameLabel: TLabel;
    FileNameEdit: TFileNameEdit;
    FolderNameEdit: TEditButton;
    FolderNameLabel: TLabel;
    OKButton: TButton;
    CancelButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ExtractActionExecute(Sender: TObject);
    procedure ExtractActionUpdate(Sender: TObject);
    procedure CloseActionExecute(Sender: TObject);
    procedure CloseActionUpdate(Sender: TObject);
    procedure FolderNameEditButtonClick(Sender: TObject);
  private
    FBusy: Boolean;
  protected
    function GetFileName: TFileName;
    procedure SetFileName(const Value: TFileName);
    function GetFolderName: TFileName;
    procedure SetFolderName(const Value: TFileName);
  public
    property FileName: TFileName read GetFileName write SetFileName;
    property FolderName: TFileName read GetFolderName write SetFolderName;
  end;

function ExtractPackage(var FileName: TFileName; var FolderName: TFileName): Boolean;

implementation

{$R *.lfm}

function ExtractPackage(var FileName: TFileName; var FolderName: TFileName): Boolean;
var
  Dialog: TExtractionForm;
begin
  Dialog := TExtractionForm.Create(nil);
  try
    Dialog.FileName := FileName;
    Dialog.FolderName := FolderName;
    Result := Dialog.ShowModal = mrOk;
    if Result then begin
      FileName := Dialog.FileName;
      FolderName := Dialog.FolderName;
    end;
  finally
    Dialog.Free;
  end;
end;

{ TExtractionForm }

procedure TExtractionForm.FormCreate(Sender: TObject);
begin
  FBusy := False;
end;

procedure TExtractionForm.ExtractActionExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TExtractionForm.ExtractActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := FileExists(FileName) and DirectoryExists(FolderName);
end;

procedure TExtractionForm.CloseActionExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TExtractionForm.CloseActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := not FBusy;
end;

procedure TExtractionForm.FolderNameEditButtonClick(Sender: TObject);
var
  Dialog: TSelectDirectoryDialog;
begin
  Dialog := TSelectDirectoryDialog .Create(Self);
  try
    Dialog.Title := 'Select Destination Folder';
    if Dialog.Execute then
      FolderName := Dialog.FileName;
  finally
    Dialog.Free;
  end;
end;

function TExtractionForm.GetFileName: TFileName;
begin
  Result := FileNameEdit.Text;
end;

procedure TExtractionForm.SetFileName(const Value: TFileName);
begin
  FileNameEdit.Text := Value;
end;

function TExtractionForm.GetFolderName: TFileName;
begin
  Result := FolderNameEdit.Text;
end;

procedure TExtractionForm.SetFolderName(const Value: TFileName);
begin
  FolderNameEdit.Text := Value;
end;

end.

