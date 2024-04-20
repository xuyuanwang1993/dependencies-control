#
# @author Jason Huang<jasonhuang1988@gmail.com> 2022
#

# Include guards
if(__COMMON_UTILS__)
    return()
endif()
set(__COMMON_UTILS__ TRUE)

function(get_all_targets var)
    set(targets)
    get_all_targets_recursive(targets ${CMAKE_CURRENT_SOURCE_DIR})
    set(${var} ${targets} PARENT_SCOPE)
endfunction()

macro(get_all_targets_recursive targets dir)
    get_property(subdirectories DIRECTORY ${dir} PROPERTY SUBDIRECTORIES)
    foreach(subdir ${subdirectories})
        get_all_targets_recursive(${targets} ${subdir})
    endforeach()

    get_property(current_targets DIRECTORY ${dir} PROPERTY BUILDSYSTEM_TARGETS)
    list(APPEND ${targets} ${current_targets})
endmacro()

function(append_target_ide_parent_folder TARGET PARENT_FOLDER_NAME)
    if(TARGET ${TARGET}) 
        get_target_property(_target_folder ${TARGET} FOLDER)
        if(${_target_folder} STREQUAL "_target_folder-NOTFOUND")
            set_target_properties(
                ${TARGET}
                PROPERTIES FOLDER "${PARENT_FOLDER_NAME}"
            )
        else()
            set_target_properties(
                ${TARGET}
                PROPERTIES FOLDER "${PARENT_FOLDER_NAME}/${_target_folder}"
            )
        endif()
    endif()
endfunction()

function(add_subdirectory_with_folder PARENT_FOLDER_NAME SUBFOLDER)
    add_subdirectory(${SUBFOLDER} ${ARGN})
    get_all_targets_recursive(_targets "${SUBFOLDER}")
    foreach(_target ${_targets})
        append_target_ide_parent_folder(${_target} "${PARENT_FOLDER_NAME}")
    endforeach()
endfunction()