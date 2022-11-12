program Packager;

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
{$WARN 5023 OFF}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Main, Abouts, ExtractionForms, ConfigUtils, PackageEngines
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='Paleo Packager';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

