@echo off
set curExe=Junction.exe
set curDir=%~dp0

set scaffoldsDestDir=%curDir%.\..\..\tlzyh\scaffolds
set sourceDestDir=%curDir%.\..\..\tlzyh\source
set themesDestDir=%curDir%.\..\..\tlzyh\themes
set configDest=%curDir%.\..\..\_config.yml

set scaffoldsSrcDir=%curDir%.\..\scaffolds
set sourceSrcDir=%curDir%.\..\source
set themesSrcDir=%curDir%.\..\themes
set configSrcDir=%curDir%.\..\_config.yml

%curDir%%curExe% -d "%scaffoldsDestDir%"
%curDir%%curExe% -d "%sourceSrcDir%"
%curDir%%curExe% -d "%themesSrcDir%"
%curDir%%curExe% -d "%configSrcDir%"

pause
