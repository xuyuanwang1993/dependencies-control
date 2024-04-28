@echo off

set OutPutPath=%~1
set DenpendenciesDir=%~2
set ExtraCmakeConfig=%~3
if "%OutPutPath%"=="" (
    for /f %%i in ('cd') do     set OutPutPath=%%i
)
if "%DenpendenciesDir%"=="" (
    set DenpendenciesDir=%~dp0/../../
)


for %%I in ("%OutPutPath%") do set "OutPutPath=%%~fI"
for %%I in ("%DenpendenciesDir%") do set "DenpendenciesDir=%%~fI"

echo ExtraCmakeConfig=%ExtraCmakeConfig%
echo OutPutPath=%OutPutPath%
echo DenpendenciesDir=%DenpendenciesDir%
pushd %OutPutPath%
cmake -DAUTO_SYNC_DENPENDECIES=ON -DAUTO_SYNC_DENPENDECIES_ONLYCHECK=ON -DOUT_PUT_PATH=%OutPutPath% -DDependenciesRootDir=%DenpendenciesDir% %ExtraCmakeConfig% -P  %~dp0/NativeDenpendencies.cmake
popd 