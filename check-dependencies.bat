@echo off

set OutPutPath=%~1
set DenpendenciesDir=%~2
set DenpendenciesCmakePath=%~3
if "%OutPutPath%"=="" (
    for /f %%i in ('cd') do     set OutPutPath=%%i
)
if "%DenpendenciesDir%"=="" (
    set DenpendenciesDir=%~dp0/../../
)
if "%DenpendenciesCmakePath%"=="" (
    set DenpendenciesCmakePath=%~dp0/NativeDenpendencies.cmake
)
for %%I in ("%DenpendenciesCmakePath%") do set "DenpendenciesCmakePath=%%~fI"
for %%I in ("%OutPutPath%") do set "OutPutPath=%%~fI"
for %%I in ("%DenpendenciesDir%") do set "DenpendenciesDir=%%~fI"

echo DenpendenciesCmakePath=%DenpendenciesCmakePath%
echo OutPutPath=%OutPutPath%
echo DenpendenciesDir=%DenpendenciesDir%
pushd %OutPutPath%
cmake -DAUTO_SYNC_DENPENDECIES=ON -DAUTO_SYNC_DENPENDECIES_ONLYCHECK=ON -DOUT_PUT_PATH=%OutPutPath% -DDependenciesRootDir=%DenpendenciesDir% -P %DenpendenciesCmakePath% 
popd 