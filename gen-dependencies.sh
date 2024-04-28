#!/bin/bash
if [ "$1" = "--help" ]; then
    echo "1:output path for denpendencies"
    echo "2:previous denpendencies config path"
    echo "3:git repos common root path"
    echo "4:extra cmake config"
    exit 0
fi
OutPutPath="$1"  
ConfigItemPath="$2"  
DenpendenciesDir="$3"  
ExtraCmakeConfig="$4"  
script_dir=$(realpath $(dirname "${BASH_SOURCE[0]}")) 
echo "script_dir=${script_dir}"
if [ -z "$OutPutPath" ]; then  
    OutPutPath="$(pwd)"  
fi
  
if [ -z "$ConfigItemPath" ]; then  
    ConfigItemPath="$OutPutPath"  
fi

# 如果未指定依赖目录，则使用脚本所在目录的上级目录的上级目录  
if [ -z "$DenpendenciesDir" ]; then  
    DenpendenciesDir=$(dirname "$(dirname "$script_dir")")  
fi

mkdir -p   $OutPutPath
OutPutPath=$(realpath "$OutPutPath")  
ConfigItemPath=$(realpath "$ConfigItemPath")  
DenpendenciesDir=$(realpath "$DenpendenciesDir")
 

echo "1:output path for denpendencies------->\t OutPutPath=$OutPutPath" 
echo "2:previous denpendencies config path-->\tConfigItemPath=$ConfigItemPath"   
echo "3:git repos common root path---------->\tDenpendenciesDir=$DenpendenciesDir"  
echo "4:extra cmake config----->\tExtraCmakeConfig=$ExtraCmakeConfig" 
cmake -DAUTO_GENERATE_DENPENDECIES=ON -DOUT_PUT_PATH="$OutPutPath" -DCONFIG_ITEM_PATH="$ConfigItemPath" -DDependenciesRootDir="$DenpendenciesDir" $ExtraCmakeConfig -P  "$script_dir/NativeDenpendencies.cmake"
exit $?