# Include guards
if(__SOURCE_CODE_CONTROL__)
    return()
endif()
set(__SOURCE_CODE_CONTROL__ TRUE)


macro(option_add_subdirectory dir_name)
    set(Directory_Control_Option "_Enable_${dir_name}")  
    option(${Directory_Control_Option} "enable ${dir_name}" ON)
    if(${Directory_Control_Option})  
        add_subdirectory(${dir_name})
    endif()  
endmacro()

macro(option_add_named_subdirectory dir_name option_flag_name)
    option(${option_flag_name} "enable ${dir_name}" ON)
    if(${option_flag_name})  
        add_subdirectory(${dir_name})
    endif()  
endmacro() 

macro(declare_normal_denpendency denpendency_name state_flag description)
  option(_Enable_${denpendency_name} "${description}" ${state_flag})
endmacro()