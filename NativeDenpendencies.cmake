#
# @author lightning1993<469953258@qq.com> 2024
#

# Include guards
if(__NATIVE_DENPENDENCIES__)
  return()
endif()
set(__NATIVE_DENPENDENCIES__ TRUE)
if("${DependeciesFileName}" STREQUAL "")
  set(DependeciesFileName ".denpendencies.txt")
endif()

set(DependeciesTempFileNameSuffix ".tmp")
function(make_real_path INPUT_PATH)
  file(REAL_PATH ${${INPUT_PATH}} ACTUAL_PATH)
  set(${INPUT_PATH}
      "${ACTUAL_PATH}"
      PARENT_SCOPE)
endfunction()

if("${DependenciesRootDir}" STREQUAL "")
  set(DependenciesRootDir
      "${CMAKE_CURRENT_LIST_FILE}/../../../"
      CACHE STRING "denpdencies root dir")
else()
  set(DependenciesRootDir
      "${DependenciesRootDir}"
      CACHE STRING "denpdencies root dir")
endif()
make_real_path(DependenciesRootDir)

# enable return expression's param
cmake_policy(SET CMP0140 NEW)
cmake_policy(SET CMP0007 NEW)
find_package(Git QUIET)

option(AUTO_GENERATE_DENPENDECIES "auto generate denependenies" OFF)
option(AUTO_SYNC_DENPENDECIES "auto generate denependenies" OFF)
option(AUTO_SYNC_DENPENDECIES_ONLYCHECK "auto generate denependenies" OFF)
option(ENABLE_AUTO_CLEAN_REPO "auto clean repo" OFF)
option(ENABLE_FORCE_SYNC_NEWEST_BRANCH "force sync branch newest commit" OFF)
option(ENABLE_AUTO_PRUNE_ORIGIN_BRANCH "auto prune  deleted origin branch" OFF)
# get git repo's current version
function(get_package_version REPO_DIR RET_STR)
  set(TEMP_VERSION "")
  execute_process(
    COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
    WORKING_DIRECTORY "${REPO_DIR}"
    OUTPUT_VARIABLE TEMP_VERSION
    ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
  set(${RET_STR}_VERSION
      "${TEMP_VERSION}"
      PARENT_SCOPE)
endfunction()

function(get_package_url REPO_DIR RET_STR)
  set(TEMP_URL "")
  execute_process(
    COMMAND ${GIT_EXECUTABLE} config --get remote.origin.url
    WORKING_DIRECTORY "${REPO_DIR}"
    OUTPUT_VARIABLE TEMP_URL
    ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
  set(${RET_STR}_URL
      "${TEMP_URL}"
      PARENT_SCOPE)
endfunction()

function(get_package_branch_name REPO_DIR RET_STR COMMIT_ID)
  set(TEMP_BRANCH "")
  execute_process(
    COMMAND ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
    WORKING_DIRECTORY "${REPO_DIR}"
    OUTPUT_VARIABLE TEMP_BRANCH
    ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
  # check whether is a detached HEAD
  if("${TEMP_BRANCH}" STREQUAL "HEAD")
    set(TEMP_BRANCHS "")
    execute_process(
      COMMAND ${GIT_EXECUTABLE} branch --contains ${COMMIT_ID}
      WORKING_DIRECTORY "${REPO_DIR}"
      OUTPUT_VARIABLE TEMP_BRANCHS
      ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)

    string(REGEX REPLACE "\n" ";" TEMP_BRANCHS_LINES "${TEMP_BRANCHS}")
    list(LENGTH TEMP_BRANCHS_LINES LINES_NUM)
    # select the first branch which contains the commit
    if(LINES_NUM GREATER 1)
      list(GET TEMP_BRANCHS_LINES 1 TEMP_BRANCH)
    endif()
  endif()

  set(${RET_STR}_BRANCH
      "${TEMP_BRANCH}"
      PARENT_SCOPE)
endfunction()

function(check_repo_is_clean REPO_DIR RET)
  set(TEST_DIFF "")
  execute_process(
    COMMAND ${GIT_EXECUTABLE} diff --quiet
    WORKING_DIRECTORY "${REPO_DIR}"
    RESULT_VARIABLE TEST_DIFF
    ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(NOT TEST_DIFF EQUAL 0)
    set(${RET}
        FALSE
        PARENT_SCOPE)
    return()
  endif()

  set(TEST_FILE_TRACK "")
  execute_process(
    COMMAND ${GIT_EXECUTABLE} ls-files --others --exclude-standard
    WORKING_DIRECTORY "${REPO_DIR}"
    OUTPUT_VARIABLE TEST_FILE_TRACK
    ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(TEST_FILE_TRACK)
    set(${RET}
        FALSE
        PARENT_SCOPE)
    return()
  endif()

  set(${RET}
      TRUE
      PARENT_SCOPE)
endfunction()

function(make_repo_clean REPO_DIR)
  execute_process(
    COMMAND ${GIT_EXECUTABLE} reset --hard
    WORKING_DIRECTORY "${REPO_DIR}"
    ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)

  execute_process(
    COMMAND ${GIT_EXECUTABLE} clean -dxf
    WORKING_DIRECTORY "${REPO_DIR}"
    ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
endfunction()

function(check_sync_state REPO_NAME REPO_URL BRANCH_NAME COMMIT_INFO RET)
  get_package_version(${DependenciesRootDir}/${REPO_NAME} RET_STR)
  if("${RET_STR_VERSION}" STREQUAL "")
    message(FATAL_ERROR "${REPO_NAME} didn't has a version")
    return()
  else()
    if(NOT "${RET_STR_VERSION}" STREQUAL "${COMMIT_INFO}")
      return()
    endif()
  endif()
  get_package_branch_name(${DependenciesRootDir}/${REPO_NAME} RET_STR
                          ${RET_STR_VERSION})
  if("${RET_STR_BRANCH}" STREQUAL "")
    message(FATAL_ERROR "${REPO_NAME} didn't has a branch")
    return()
  else()
    if(NOT "${RET_STR_BRANCH}" STREQUAL "${BRANCH_NAME}")
      return()
    endif()
  endif()
  get_package_url(${DependenciesRootDir}/${REPO_NAME} RET_STR)
  if("${RET_STR_URL}" STREQUAL "")
    message(WARNING "${REPO_NAME} didn't has a url")
    return()
  else()
    if(NOT "${RET_STR_URL}" STREQUAL "${REPO_URL}")
      return()
    endif()
  endif()
  # sync submodule
  execute_process(
    COMMAND ${GIT_EXECUTABLE} submodule update --init -f --depth 1 --recursive
            --quiet
    WORKING_DIRECTORY "${DependenciesRootDir}/${REPO_NAME}"
    RESULT_VARIABLE RESULT
    ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
  set(RET
      TRUE
      PARENT_SCOPE)
endfunction()

function(switch_version REPO_NAME REPO_URL BRANCH_NAME COMMIT_INFO)
  set(RESULT "")

  # switch url ref
  execute_process(
    COMMAND ${GIT_EXECUTABLE} remote set-url origin ${REPO_URL}
    WORKING_DIRECTORY "${DependenciesRootDir}/${REPO_NAME}"
    ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
  # fetch origin
  execute_process(
    COMMAND ${GIT_EXECUTABLE} fetch origin ${BRANCH_NAME} --quiet
    WORKING_DIRECTORY "${DependenciesRootDir}/${REPO_NAME}"
    RESULT_VARIABLE RESULT
    ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
  # checkout branch
  execute_process(
    COMMAND ${GIT_EXECUTABLE} checkout ${BRANCH_NAME} --quiet
    WORKING_DIRECTORY "${DependenciesRootDir}/${REPO_NAME}"
    RESULT_VARIABLE RESULT
    ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
  # pull origin
  execute_process(
    COMMAND ${GIT_EXECUTABLE} pull origin ${BRANCH_NAME} --quiet
    WORKING_DIRECTORY "${DependenciesRootDir}/${REPO_NAME}"
    RESULT_VARIABLE RESULT
    ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(ENABLE_AUTO_PRUNE_ORIGIN_BRANCH)
    execute_process(
      COMMAND ${GIT_EXECUTABLE} remote prune origin
      WORKING_DIRECTORY "${DependenciesRootDir}/${REPO_NAME}"
      ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
  endif()
  # check version
  get_package_version(${DependenciesRootDir}/${REPO_NAME} RET_STR)

  if(NOT "${RET_STR_VERSION}" STREQUAL "${COMMIT_INFO}")
    if(NOT ENABLE_FORCE_SYNC_NEWEST_BRANCH)
      # switch commit
      execute_process(
        COMMAND ${GIT_EXECUTABLE} checkout ${COMMIT_INFO} --quiet
        WORKING_DIRECTORY "${DependenciesRootDir}/${REPO_NAME}"
        RESULT_VARIABLE RESULT
        ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
      if(NOT RESULT EQUAL 0)
        message(FATAL_ERROR "checkout cmmit to ${COMMIT_INFO}  failed")
        return()
      endif()
    else()
      message(
        WARNING
          "force switch  ${REPO_NAME} commit from ${COMMIT_INFO} to ${RET_STR_VERSION} "
      )
    endif()

  endif()

  # sync submodule
  execute_process(
    COMMAND ${GIT_EXECUTABLE} submodule sync
    WORKING_DIRECTORY "${DependenciesRootDir}/${REPO_NAME}"
    RESULT_VARIABLE RESULT
    ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(NOT RESULT EQUAL 0)
    message(FATAL_ERROR "submodule sync  failed")
    return()
  endif()

  execute_process(
    COMMAND ${GIT_EXECUTABLE} submodule update --init -f --depth 1 --recursive
            --quiet
    WORKING_DIRECTORY "${DependenciesRootDir}/${REPO_NAME}"
    RESULT_VARIABLE RESULT
    ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(NOT RESULT EQUAL 0)
    message(FATAL_ERROR "sync submodule  failed")
    return()
  endif()
endfunction()

function(sync_repo REPO_NAME REPO_URL BRANCH_NAME COMMIT_INFO)
  check_sync_state(${REPO_NAME} ${REPO_URL} ${BRANCH_NAME} ${COMMIT_INFO} RET)
  if(RET)
    return()
  endif()
  if(AUTO_SYNC_DENPENDECIES_ONLYCHECK)
    message(FATAL_ERROR "${REPO_NAME} is not synced")
  endif()
  switch_version(${REPO_NAME} ${REPO_URL} ${BRANCH_NAME} ${COMMIT_INFO})
endfunction()

function(filter_all_repo INPUT_LIST)
  set(TEMP_LIST "")
  foreach(item ${${INPUT_LIST}})
    if(EXISTS "${DependenciesRootDir}/${item}/.git")
      list(APPEND TEMP_LIST ${item})
    endif()
  endforeach()

  set(${INPUT_LIST}
      ${TEMP_LIST}
      PARENT_SCOPE)
endfunction()

function(init_repo REPO_NAME REPO_URL BRANCH_NAME COMMIT_INFO)
  if(AUTO_SYNC_DENPENDECIES_ONLYCHECK)
    message(FATAL_ERROR "miss ${REPO_NAME}")
  endif()
  set(RESULT "")
  execute_process(
    COMMAND ${GIT_EXECUTABLE} clone -b ${BRANCH_NAME} -- ${REPO_URL}
            ${REPO_NAME}
    WORKING_DIRECTORY "${DependenciesRootDir}"
    RESULT_VARIABLE RESULT
    ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(NOT RESULT EQUAL 0)
    message(WARNING "clone ${REPO_URL} to ${REPO_NAME} failed")
    return()
  endif()
  sync_repo(${REPO_NAME} ${REPO_URL} ${BRANCH_NAME} ${COMMIT_INFO})
endfunction()

function(
  write_repo_denpendency_info
  repo_parent_path
  repo_name
  out_path
  old_repo_branch
  old_repo_version
  old_repo_url)
  message("read ${repo_name} git state")
  check_repo_is_clean(${repo_parent_path}/${repo_name} IS_CLEAN)
  if(NOT IS_CLEAN)
    message(WARNING "${repo_name} is not clean! please check the repo state")
  endif()
  get_package_version(${repo_parent_path}/${repo_name} RET_STR)
  if("${RET_STR_VERSION}" STREQUAL "")
    message(FATAL_ERROR "${repo_name} didn't has a version")
    return()
  endif()
  get_package_branch_name(${repo_parent_path}/${repo_name} RET_STR
                          ${RET_STR_VERSION})
  if("${RET_STR_BRANCH}" STREQUAL "")
    message(FATAL_ERROR "${repo_name} didn't has a branch")
    return()
  endif()
  get_package_url(${repo_parent_path}/${repo_name} RET_STR)
  if("${RET_STR_URL}" STREQUAL "")
    message(FATAL_ERROR "${repo_name} didn't has a url")
    return()
  endif()
  if(NOT "${old_repo_version}" STREQUAL "${RET_STR_VERSION}")
    message(STATUS "${repo_name}\t${old_repo_version} -> ${RET_STR_VERSION}")
  endif()
  if(NOT "${old_repo_url}" STREQUAL "${RET_STR_URL}")
    message(STATUS "${repo_name}\t${old_repo_url} -> ${RET_STR_URL}")
  endif()
  if(NOT "${old_repo_branch}" STREQUAL "${RET_STR_BRANCH}")
    message(STATUS "${repo_name}\t${old_repo_branch} -> ${RET_STR_BRANCH}")
  endif()
  file(APPEND ${out_path}
       "${repo_name}\t${RET_STR_BRANCH}\t${RET_STR_VERSION}\t${RET_STR_URL}\n")
endfunction()

function(get_sub_directories DIR_NAME RET_DIR_LIST)
  file(
    GLOB children
    RELATIVE ${DIR_NAME}
    ${DIR_NAME}/*)
  foreach(child ${children})
    if(IS_DIRECTORY ${DIR_NAME}/${child})
      list(APPEND ${RET_DIR_LIST} ${child})
    endif()
  endforeach()
  set(${RET_DIR_LIST}
      ${${RET_DIR_LIST}}
      PARENT_SCOPE)
endfunction()

function(generate_denpendencies OUT_PATH_DIR CONFIG_PATH_DIR)
  if(GIT_NOTFOUND)
    message(WARNING "not found git package")
    return()
  endif()

  if(OUT_PATH_DIR)
    set(ITEM_PATH "${OUT_PATH_DIR}/${DependeciesFileName}")
  else()
    set(ITEM_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${DependeciesFileName}")
  endif()

  if(CONFIG_PATH_DIR)
    set(CONFIG_ITEM_PATH "${CONFIG_PATH_DIR}/${DependeciesFileName}")
  else()
    set(CONFIG_ITEM_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${DependeciesFileName}")
  endif()

  set(ITEM_PATH_TEMP ${ITEM_PATH}${DependeciesTempFileNameSuffix})
  if(EXISTS ${ITEM_PATH_TEMP})
    file(REMOVE "${ITEM_PATH_TEMP}")
  endif()

  set(UseDenpendenciesConfig OFF)
  if(EXISTS "${CONFIG_ITEM_PATH}")
    file(READ ${CONFIG_ITEM_PATH} FILE_CONTENT)
    string(REGEX REPLACE "\n" ";" LINES "${FILE_CONTENT}")
    list(LENGTH LINES LINES_NUM)
    if(LINES_NUM EQUAL 0)
      message(WARNING "file is empty")
    else()
      set(UseDenpendenciesConfig ON)
      foreach(LINE ${LINES})
        string(REGEX REPLACE "\t" ";" Items "${LINE}")
        list(LENGTH Items Items_NUM)
        if(Items_NUM GREATER 3)
          list(GET Items 0 repo_name)
          list(GET Items 1 repo_branch)
          list(GET Items 2 repo_version)
          list(GET Items 3 repo_url)
          write_repo_denpendency_info(
            "${DependenciesRootDir}" ${repo_name} ${ITEM_PATH_TEMP}
            "${repo_branch}" "${repo_version}" "${repo_url}")
        else()
          message(WARNING "invalid context ${Items}")
          return()
        endif()

      endforeach()
    endif()
  endif()

  if(NOT UseDenpendenciesConfig)
    get_sub_directories(${DependenciesRootDir} all_repo_dirs)
    filter_all_repo(all_repo_dirs)
    foreach(repo_name ${all_repo_dirs})
      write_repo_denpendency_info("${DependenciesRootDir}" ${repo_name}
                                  ${ITEM_PATH_TEMP} "" "" "")
    endforeach()
  endif()

  if(EXISTS ${ITEM_PATH_TEMP})
    file(RENAME ${ITEM_PATH_TEMP} ${ITEM_PATH})
  endif()

endfunction()

function(sync_denpendencies OUT_PATH_DIR)
  if(GIT_NOTFOUND)
    message(WARNING "not found git package")
    return()
  endif()
  set(ITEM_PATH "${OUT_PATH_DIR}/${DependeciesFileName}")
  if(NOT EXISTS "${ITEM_PATH}")
    message(WARNING "${ITEM_PATH} is not existed")
    return()
  endif()
  file(READ ${ITEM_PATH} FILE_CONTENT)
  string(REGEX REPLACE "\n" ";" LINES "${FILE_CONTENT}")
  list(LENGTH LINES LINES_NUM)
  if(LINES_NUM EQUAL 0)
    message(WARNING "${ITEM_PATH} is empty")
    return()
  endif()
  foreach(LINE ${LINES})
    string(REGEX REPLACE "\t" ";" Items "${LINE}")
    list(LENGTH Items Items_NUM)
    if(Items_NUM GREATER 3)
      list(GET Items 0 repo_name)
      list(GET Items 1 repo_branch)
      list(GET Items 2 repo_version)
      list(GET Items 3 repo_url)

      if(NOT IS_DIRECTORY "${DependenciesRootDir}/${repo_name}")
        message("init ${repo_name} ")
        init_repo(${repo_name} ${repo_url} ${repo_branch} ${repo_version})
      else()
        if(ENABLE_AUTO_CLEAN_REPO)
          make_repo_clean(${DependenciesRootDir}/${repo_name})
        endif()
        check_repo_is_clean(${DependenciesRootDir}/${repo_name} IS_CLEAN)
        if(NOT IS_CLEAN)
          message(
            WARNING "${repo_name} is not clean! please check the repo state")
          if(AUTO_SYNC_DENPENDECIES_ONLYCHECK)
            message(FATAL_ERROR " ${repo_name} need sync")
          endif()
          return()
        endif()
        message("sync ${repo_name} ${repo_url} ${repo_branch} ${repo_version}")
        sync_repo(${repo_name} ${repo_url} ${repo_branch} ${repo_version})
      endif()
    else()
      message(WARNING "invalid context ${Items}")
      return()
    endif()

  endforeach()

endfunction()

if(AUTO_GENERATE_DENPENDECIES)
  if("${OUT_PUT_PATH}" STREQUAL "")
    set(OUT_PUT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/")
  endif()
  make_real_path(OUT_PUT_PATH)
  if("${CONFIG_ITEM_PATH}" STREQUAL "")
    set(CONFIG_ITEM_PATH "${CMAKE_CURRENT_SOURCE_DIR}/")
  endif()
  make_real_path(CONFIG_ITEM_PATH)

  message(
    STATUS
      "OUT_PUT_PATH=${OUT_PUT_PATH} CONFIG_ITEM_PATH=${CONFIG_ITEM_PATH} DependenciesRootDir=${DependenciesRootDir}"
  )
  generate_denpendencies("${OUT_PUT_PATH}" "${CONFIG_ITEM_PATH}")
endif()

if(AUTO_SYNC_DENPENDECIES)
  if("${OUT_PUT_PATH}" STREQUAL "")
    set(OUT_PUT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/")
  endif()
  make_real_path(OUT_PUT_PATH)
  file(MAKE_DIRECTORY ${DependenciesRootDir})
  message(
    STATUS
      "OUT_PUT_PATH=${OUT_PUT_PATH} DependenciesRootDir=${DependenciesRootDir}")
  sync_denpendencies("${OUT_PUT_PATH}")
endif()

function(gen_target_denpendencies target_name script_path config_path)
  add_custom_command(
    TARGET ${target_name}
    PRE_BUILD
    COMMAND ${script_path} $<TARGET_FILE_DIR:${app_target_name}> ${config_path}
            $<IF:$<CONFIG:Release>,Release,Debug>
    COMMENT "Generating ${DependeciesFileName}"
    VERBATIM)

endfunction()

function(get_library_dependencies target_name all_deps visited_deps)
  set(_input_link_libraries LINK_LIBRARIES)
  get_target_property(_input_type ${target_name} TYPE)

  if(${_input_type} STREQUAL "INTERFACE_LIBRARY")
      set(_input_link_libraries INTERFACE_LINK_LIBRARIES)
  endif() 
  get_target_property(DIRECT_DEPS ${target_name}   ${_input_link_libraries}) 
  list(APPEND ${all_deps} ${DIRECT_DEPS})  
  foreach(DEP ${DIRECT_DEPS})  
      if(NOT "${DEP}" IN_LIST visited_deps)  
          list(APPEND visited_deps ${DEP})
          if(TARGET ${DEP})
          get_library_dependencies(${DEP} ${all_deps} "${visited_deps}")  
          else()
          message(STATUS "${target_name} DEP=${DEP} is not a target") 
            continue()
          endif()
          
      endif()  
  endforeach()
  list(REMOVE_DUPLICATES ${all_deps})
  list(REMOVE_ITEM ${all_deps} DIRECT_DEPS-NOTFOUND)
  set(${all_deps} ${${all_deps}} PARENT_SCOPE)   
endfunction()

function(write_library_dependencies target_name dst_file_path)
  get_library_dependencies(${target_name} LIBRARY_DEPS "DIRECT_DEPS-NOTFOUND")
  foreach(DEP ${LIBRARY_DEPS})
  file(APPEND ${dst_file_path}
       "${DEP}\n")
  endforeach()
endfunction()