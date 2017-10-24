@echo off
set curDir=%~dp0

set scaffoldsDestDir=%curDir%.\..\..\tlzyh.github.io\scaffolds
set sourceDestDir=%curDir%.\..\..\tlzyh.github.io\source
set themesDestDir=%curDir%.\..\..\tlzyh.github.io\themes
set configDest=%curDir%.\..\..\tlzyh.github.io\_config.yml

set scaffoldsSrcDir=%curDir%.\..\scaffolds
set sourceSrcDir=%curDir%.\..\source
set themesSrcDir=%curDir%.\..\themes
set configSrc=%curDir%.\..\_config.yml

mklink /D "%scaffoldsDestDir%" "%scaffoldsSrcDir%"
mklink /D "%sourceDestDir%" "%sourceSrcDir%"
mklink /D "%themesDestDir%" "%themesSrcDir%"
mklink "%configDest%" "%configSrc%"

pause
