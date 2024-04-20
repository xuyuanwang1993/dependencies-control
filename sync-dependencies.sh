#!/bin/bash  
if [ "$1" = "--help" ]; then
    echo "1:previous denpendencies config path"
    echo "2:git repos common root path"
    echo "3:denpendences cmake moudule path"
    exit 0
fi  
# 接收命令行参数  
OutPutPath=$1  
DenpendenciesDir=$2  
DenpendenciesCmakePath=$3  
script_dir=$(realpath $(dirname "${BASH_SOURCE[0]}")) 
echo "script_dir=${script_dir}"

# 如果未指定输出路径，则使用当前目录  
if [ -z "$OutPutPath" ]; then  
    OutPutPath=$(pwd)  
fi  
  
# 如果未指定依赖目录，则使用脚本所在目录的上级目录的上级目录  
if [ -z "$DenpendenciesDir" ]; then  
    DenpendenciesDir=$(dirname "$(dirname "$script_dir")")  
fi  
  
# 如果未指定依赖CMake路径，则使用脚本所在目录的NativeDenpendencies.cmake  
if [ -z "$DenpendenciesCmakePath" ]; then   
    DenpendenciesCmakePath="$script_dir//NativeDenpendencies.cmake"  
fi  
  
# 获取绝对路径
mkdir -p   $DenpendenciesDir
DenpendenciesCmakePath=$(realpath "$DenpendenciesCmakePath")  
OutPutPath=$(realpath "$OutPutPath")  
DenpendenciesDir=$(realpath "$DenpendenciesDir")  
  
# 输出路径信息  
echo "1:previous denpendencies config path-->\OutPutPath=$OutPutPath"   
echo "2:git repos common root path---------->\tDenpendenciesDir=$DenpendenciesDir"  
echo "3:denpendences cmake moudule path----->\tDenpendenciesCmakePath=$DenpendenciesCmakePath"
# 切换到输出路径  
pushd "$OutPutPath" 
  
# 执行cmake命令  
cmake -DAUTO_SYNC_DENPENDECIES=ON -DOUT_PUT_PATH="$OutPutPath" -DDependenciesRootDir="$DenpendenciesDir" -P "$DenpendenciesCmakePath"  
  
# 返回到原始目录  
popd