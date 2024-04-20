pushd %~dp0

@echo off

call cmake -DREPO_DENPENDENCIES_GEN_PATH=. -B ./build-win


pause
popd