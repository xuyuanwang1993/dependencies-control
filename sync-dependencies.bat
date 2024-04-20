@echo off
if "%~1"=="--help" (
    echo "1:previous denpendencies config path"
    echo "2:git repos common root path"
    echo "3:denpendences cmake moudule path"
    exit 0
)
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

echo "1:previous denpendencies config path-->OutPutPath=%OutPutPath%"
echo "2:git repos common root path---------->DenpendenciesDir=%DenpendenciesDir%"
echo "3:denpendences cmake moudule path----->DenpendenciesCmakePath=%DenpendenciesCmakePath%"  
pushd %OutPutPath%
cmake -DAUTO_SYNC_DENPENDECIES=ON -DOUT_PUT_PATH=%OutPutPath% -DDependenciesRootDir=%DenpendenciesDir% -P %DenpendenciesCmakePath% 
popd 