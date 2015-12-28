@echo off
set curDir=%~dp0

set scaffoldsDestDir=%curDir%.\..\..\tlzyh\scaffolds
set sourceDestDir=%curDir%.\..\..\tlzyh\source
set themesDestDir=%curDir%.\..\..\tlzyh\themes
set configDest=%curDir%.\..\..\tlzyh\_config.yml

set scaffoldsSrcDir=%curDir%.\..\scaffolds
set sourceSrcDir=%curDir%.\..\source
set themesSrcDir=%curDir%.\..\themes
set configSrc=%curDir%.\..\_config.yml

mklink /D "%scaffoldsDestDir%" "%scaffoldsSrcDir%"
mklink /D "%sourceDestDir%" "%sourceSrcDir%"
mklink /D "%themesDestDir%" "%themesSrcDir%"
mklink "%configDest%" "%configSrc%"

pause
