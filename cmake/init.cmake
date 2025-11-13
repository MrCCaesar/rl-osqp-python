# cmake/init.cmake
# 自动检测 Python 和 Torch 路径

# 首先确保找到 Python 开发文件
find_package(Python COMPONENTS Interpreter Development REQUIRED)

# 设置 Python 相关变量，这些会被 OSQP 使用
set(Python_EXECUTABLE "${Python_EXECUTABLE}" CACHE FILEPATH "Python executable")
set(Python_INCLUDE_DIRS "${Python_INCLUDE_DIRS}" CACHE PATH "Python include directories")
set(Python_LIBRARIES "${Python_LIBRARIES}" CACHE FILEPATH "Python libraries")

message(STATUS "Python executable: ${Python_EXECUTABLE}")
message(STATUS "Python include dirs: ${Python_INCLUDE_DIRS}")
message(STATUS "Python libraries: ${Python_LIBRARIES}")

# 尝试从 Python 环境中获取 Torch 路径
execute_process(
    COMMAND "${Python_EXECUTABLE}" -c "import torch; print(torch.__file__)"
    OUTPUT_VARIABLE TORCH_PYTHON_FILE
    OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE TORCH_IMPORT_RESULT
)

if(TORCH_IMPORT_RESULT EQUAL 0)
    # 从 torch.__file__ 推导出 CMake 路径
    get_filename_component(TORCH_PYTHON_DIR "${TORCH_PYTHON_FILE}" DIRECTORY)
    get_filename_component(TORCH_PACKAGE_DIR "${TORCH_PYTHON_DIR}" DIRECTORY)
    
    # 查找 Torch CMake 配置目录
    find_path(TORCH_CMAKE_DIR
        NAMES TorchConfig.cmake
        PATHS
            "${TORCH_PACKAGE_DIR}/torch/share/cmake/Torch"
            "${TORCH_PACKAGE_DIR}/torch"
        NO_DEFAULT_PATH
    )
    
    if(TORCH_CMAKE_DIR)
        message(STATUS "Found Torch CMake directory: ${TORCH_CMAKE_DIR}")
        list(APPEND CMAKE_PREFIX_PATH "${TORCH_CMAKE_DIR}")
        set(Torch_DIR "${TORCH_CMAKE_DIR}" CACHE PATH "Torch CMake config directory")
    else()
        message(WARNING "Torch Python package found but could not locate Torch CMake configuration")
    endif()
else()
    message(WARNING "Torch not found in Python environment")
endif()