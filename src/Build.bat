@REM  Copyright ©2022 by Steve Garcia. All rights reserved.
@REM
@REM  This file is part of the Paleo Packager project, inspired by the work of Grant Searle.
@REM
@REM  The Paleo Packager is free software: you can redistribute it and/or modify it under the
@REM  terms of the GNU General Public License as published by the Free Software Foundation,
@REM  either version 3 of the License, or (at your option) any later version.
@REM
@REM  The Paleo Packager project is distributed in the hope that it will be useful, but
@REM  without ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
@REM  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
@REM
@REM  You should have received a copy of the GNU General Public License along with the Paleo
@REM  Packager project. If not, see <https://www.gnu.org/licenses/>. }

@SET VER=0.1.0

@CALL :BUILD 32
@CALL :BUILD 64
@EXIT /B

:BUILD
@C:\lazarus\lazbuild.exe -B --build-mode="Release %1" --no-write-project Packager.lpi
@REM "..\tool\upx\upx.exe" -qk "..\bin\PaleoPackager%1.exe"
@COPY "..\bin\PaleoPackager%1.exe" ..\bin\PaleoPackager.exe
@..\tool\7zip\7zr a -bd ..\bin\PaleoPackager_%VER%_Win%1.7z ..\bin\PaleoPackager.exe
@"C:\Program Files (x86)\Inno Setup 6\iscc.exe" /Q "Packager%1.iss"
@DEL ..\bin\PaleoPackager.exe
@EXIT /B
