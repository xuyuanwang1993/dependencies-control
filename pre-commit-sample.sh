#!/bin/bash
script_dir=$(realpath $(dirname "${BASH_SOURCE[0]}"))
work_dir=$(realpath $(dirname "$script_dir"))
dependencies_file_name=".denpendencies.txt"
if [ ! -f ".denpendencies.txt" ]; then  
	echo "you need specify the repo's denpendencies by a file named ${work_dir}/\"${dependencies_file_name}\""
	exit 1
fi
bash -e ${script_dir}/gen-dependencies.sh > /dev/null 2>&1
ret=$?
if [ "$ret" != "0" ]; then  
	echo  -e "\033[31mcheck your workdir status,you should  ensure your workdir contains all needed repos!\033[0m"
	exit $ret
fi
