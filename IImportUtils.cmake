#
# @author Jason Huang<jasonhuang1988@gmail.com> 2022
#

# Include guards
if(__IMPORT_UTILS__)
  return()
endif()
set(__IMPORT_UTILS__ TRUE)
include(${CMAKE_CURRENT_LIST_DIR}/ICommonUtils.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/NativeDenpendencies.cmake)
message("Included Import Utils From: ${CMAKE_CURRENT_LIST_DIR}")

option(REPO_SEARCH_OVERLAY_PATH "overlay repo search path" "/app")
message("REPO_SEARCH_OVERLAY_PATH=${REPO_SEARCH_OVERLAY_PATH}")

option(REPO_DENPENDENCIES_GEN_PATH "gen denpendencies out dir" "")
message("REPO_DENPENDENCIES_GEN_PATH=${REPO_DENPENDENCIES_GEN_PATH}")
if(EXISTS "${REPO_DENPENDENCIES_GEN_PATH}")
  make_real_path(REPO_DENPENDENCIES_GEN_PATH)
  set(__ENABLE_GEN_DENPENDENCIES__ TRUE)
  set(__GEN_DENPENDENCIES_FILE_PATH__
      "${REPO_DENPENDENCIES_GEN_PATH}/${DependeciesFileName}")
  if(EXISTS ${__GEN_DENPENDENCIES_FILE_PATH__})
    file(REMOVE "${__GEN_DENPENDENCIES_FILE_PATH__}")
  endif()
endif()


set_property(GLOBAL PROPERTY IMPORTED_REPO_LIST_PROP)
function(import_repo repo_folder_name search_key_item_in_folder)

  get_property(imported_repo_list GLOBAL PROPERTY IMPORTED_REPO_LIST_PROP)

  # Early return if already imported
  if(${repo_folder_name} IN_LIST imported_repo_list)
    message("${repo_folder_name} is already imported!")
    return()
  endif()

  # Find parent_repo_dir that contains repo_folder_name
  set(search_key ${repo_folder_name}/${search_key_item_in_folder})
  # ci-cd IsImportLibraryFromCustomAppDir
  if(EXISTS "${REPO_SEARCH_OVERLAY_PATH}")
    find_path(
      parent_repo_dir
      NAMES ${search_key}
      PATHS "${REPO_SEARCH_OVERLAY_PATH}" REQUIRED
      DOC "Directory containing ${repo_folder_name}"
      NO_CMAKE_FIND_ROOT_PATH # this is needed for emscripten
    )
  else()
    find_path(
      parent_repo_dir
      NAMES ${search_key}
      PATHS ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/..
            ${CMAKE_CURRENT_SOURCE_DIR}/../.. REQUIRED
      DOC "Directory containing ${repo_folder_name}"
      NO_CMAKE_FIND_ROOT_PATH # this is needed for emscripten
    )
  endif()

  # Save imported repo
  set(imported_repo_list ${imported_repo_list} ${repo_folder_name})
  set_property(GLOBAL PROPERTY IMPORTED_REPO_LIST_PROP ${imported_repo_list})
  message("Imported repo: ${repo_folder_name}")
  # Add repo's root cmake list as sub directory
  add_subdirectory_with_folder(
    ${repo_folder_name} ${parent_repo_dir}/${repo_folder_name}
    ${CMAKE_CURRENT_BINARY_DIR}/${repo_folder_name})
  if(__ENABLE_GEN_DENPENDENCIES__)
    write_repo_denpendency_info("${parent_repo_dir}" ${repo_folder_name}
                                ${__GEN_DENPENDENCIES_FILE_PATH__} "" "" "")
  endif()
endfunction()
