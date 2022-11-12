; Copyright ©2022 by Steve Garcia. All rights reserved.
;
; This file is part of the Paleo Packager project, inspired by the work of Grant Searle.
;
; The Paleo Packager is free software: you can redistribute it and/or modify it under the
; terms of the GNU General Public License as published by the Free Software Foundation,
; either version 3 of the License, or (at your option) any later version.
;
; The Paleo Packager project is distributed in the hope that it will be useful, but WITHOUT
; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
; PARTICULAR PURPOSE. See the GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License along with the Paleo
; Packager project. If not, see <https://www.gnu.org/licenses/>. }

#define PaleoPackagerAppName "Paleo Packager"
#define PaleoPackagerAppVersion "0.1.0"
#define PaleoPackagerAppPublisher "Steve García"
#define PaleoPackagerAppURL "https://homebrew.computer/"
#define PaleoPackagerAppExeName "..\bin\PaleoPackager32.exe"
#define PaleoPackagerReadMeName "..\doc\Readme.txt"
#define PaleoPackagerLocalName "PaleoPackager.exe"
#define PaleoPackagerAppFolder "Paleo\Packager"

[Setup]
AppId={{CA16E17F-B543-430E-B219-7890CDD6F1F4}
AppName={#PaleoPackagerAppName}
AppVersion={#PaleoPackagerAppVersion}
AppVerName={#PaleoPackagerAppName} {#PaleoPackagerAppVersion}
AppPublisher={#PaleoPackagerAppPublisher}
AppPublisherURL={#PaleoPackagerAppURL}
AppSupportURL={#PaleoPackagerAppURL}
AppUpdatesURL={#PaleoPackagerAppURL}
DefaultDirName={autopf}\{#PaleoPackagerAppFolder}
DefaultGroupName={#PaleoPackagerAppFolder}
AllowNoIcons=yes
LicenseFile=..\COPYING.txt
PrivilegesRequiredOverridesAllowed=dialog
OutputDir=..\bin
OutputBaseFilename=PaleoPackager_{#PaleoPackagerAppVersion}_Win32_Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
VersionInfoCompany=Steve García
VersionInfoCopyright=Copyright ©2022 Steve García
VersionInfoDescription=Paleo Package Maker Setup
VersionInfoProductName=Paleo Package Maker
VersionInfoVersion={#PaleoPackagerAppVersion}
VersionInfoProductVersion={#PaleoPackagerAppVersion}
VersionInfoProductTextVersion={#PaleoPackagerAppVersion} Pre-Release
ArchitecturesAllowed=x86 x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#PaleoPackagerAppExeName}"; DestDir: "{app}"; DestName: "{#PaleoPackagerLocalName}"; Flags: ignoreversion
Source: "{#PaleoPackagerReadMeName}"; DestDir: "{app}"; 

[Icons]
Name: "{group}\{#PaleoPackagerAppName}"; Filename: "{app}\{#PaleoPackagerLocalName}"
Name: "{group}\{cm:UninstallProgram,{#PaleoPackagerAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#PaleoPackagerAppName}"; Filename: "{app}\{#PaleoPackagerLocalName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#PaleoPackagerLocalName}"; Description: "{cm:LaunchProgram,{#StringChange(PaleoPackagerAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

