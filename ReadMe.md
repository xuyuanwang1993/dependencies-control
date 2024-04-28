# git相关
```
指定私钥
chmod 600 ${WORKDIR}/scripts/id_rsa
export GIT_SSH_COMMAND="ssh -i ${WORKDIR}/scripts/id_rsa"

切换分支后同步操作
git submodule sync
git submodule update --init --depth 1 -f
```

# 各脚本功能介绍
```
各脚本可通过 --help参数查看可传参数
gen-dependencies.sh 生成/更新项目依赖
sync-dependencies.sh 根据配置文件同步依赖
sync-dependencies-force.sh 根据配置文件同步依赖，目标目录未保存的状态会被丢弃
test-gen-linux-denpendencies-sample.sh  根据项目实际import过的repo生成依赖,可通过这个脚本初始化依赖项
```

# commit时依赖更新说明
```
$$linux
将当前pre-commit 拷贝至当前仓库的 .git/hooks/目录中
$$windows
利用gen-dependencies.bat手动更新依赖
```

# cmake可用option
```
DependeciesFileName 依赖文件文件名  默认值:.denpendencies.txt
AUTO_GENERATE_DENPENDECIES 是否自动生成依赖 默认值:OFF
AUTO_SYNC_DENPENDECIES 是否同步依赖 默认值:OFF
AUTO_SYNC_DENPENDECIES_ONLYCHECK 是否仅检查依赖不执行依赖同步 默认值:OFF
ENABLE_AUTO_CLEAN_REPO 是否自动清理repo dirty状态 默认值:OFF
ENABLE_FORCE_SYNC_NEWEST_BRANCH 是否强制同步分支最新提交 默认值:OFF
ENABLE_AUTO_PRUNE_ORIGIN_BRANCH 是否自动删除已经delete的远程分支 默认值:OFF
```
