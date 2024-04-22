#!/bin/bash
if [ $# lt 4 ]; then
    echo "$0 source_repo_path dst_dir  output_name branch_name"
    exit -1
fi
source_repo=$(realpath $1)  
dst_dir=$(realpath $2) 
output_name=$3
branch_name=$4
mkdir -p ${dst_dir}
pushd ${source_repo}
commit_name=$(git rev-parse --short HEAD)
remote_url=$(git config --get remote.origin.url)
popd
echo "branch_name=${branch_name}"
echo  "commit_name=${commit_name}"
echo  "remote_url=${remote_url}"
pushd ${dst_dir}
git clone  -b ${branch_name} --depth 1 ${remote_url} ${output_name}
pushd ${output_name}
git checkout ${commit_name}
git submodule sync
git submodule update --init -f --depth 1 --recursive
popd
popd