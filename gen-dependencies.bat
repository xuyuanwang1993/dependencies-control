@echo off
if "%~1"=="--help" (
    echo "1:output path for denpendencies"
    echo "2:previous denpendencies config path"
    echo "3:git repos common root path"
    echo "4:extra cmake config"
    exit 0
)
set OutPutPath=%~1
set ConfigItemPath=%~2
set DenpendenciesDir=%~3
set ExtraCmakeConfig=%~4
if "%OutPutPath%"=="" (
    for /f %%i in ('cd') do     set OutPutPath=%%i
)
if "%ConfigItemPath%"=="" (
    set ConfigItemPath=%OutPutPath%
)

if "%DenpendenciesDir%"=="" (
    set DenpendenciesDir=%~dp0/../../
)


for %%I in ("%OutPutPath%") do set "OutPutPath=%%~fI"
for %%I in ("%DenpendenciesDir%") do set "DenpendenciesDir=%%~fI"
for %%I in ("%ConfigItemPath%") do set "ConfigItemPath=%%~fI"


echo "1:output path for denpendencies------->OutPutPath=%OutPutPath%"
echo "2:previous denpendencies config path-->ConfigItemPath=%ConfigItemPath%"
echo "3:git repos common root path---------->DenpendenciesDir=%DenpendenciesDir%"
echo "4:extra cmake config----->ExtraCmakeConfig=%ExtraCmakeConfig%"

cmake -DAUTO_GENERATE_DENPENDECIES=ON -DOUT_PUT_PATH=%OutPutPath%  -DCONFIG_ITEM_PATH=%ConfigItemPath% -DDependenciesRootDir=%DenpendenciesDir% %ExtraCmakeConfig% -P  %~dp0/NativeDenpendencies.cmake