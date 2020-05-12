#-------------------------------------------------------------------------------
# Usage
#-------------------------------------------------------------------------------
# Include this file in your .pro file:
#   include(path/to/astaticlib.pri)
# You can choose some options depending on your environment.
# - CUDA Toolkit
#   - By default, the value of environment variable CUDA_PATH is used as a path
#     to CUDA toolkit.
#   - Set your preferred version of CUDA to ASTATICLIB_CUDA_VER in x.y style
#     before include this file. Then the value of CUDA_PATH_Vx_y
#     will be used instead.
#   - You can also use ASTATICLIB_CUDA_DIR to directly specify the toolkit path.
# - Architecture
#   - x64 is assumed as default.
#   - Use ASTATICLIB_SYSTEM_NAME to specify your architecture.
#     - 'Win32', 'x64', or 'Win64' are available (???)

#-------------------------------------------------------------------------------
# CUDA common setting
#-------------------------------------------------------------------------------
# List up library your project depends
ASTATICLIB_CUDA_LIB_NAMES = cudart_static # cufft

!isEmpty(ASTATICLIB_CUDA_VER):versionAtLeast(QT_MAJOR_VERSION, 5): {
  ASTATICLIB_CUDA_MAJOR_VER = $$section(ASTATICLIB_CUDA_VER, ., 0, 0)
  ASTATICLIB_CUDA_MINOR_VER = $$section(ASTATICLIB_CUDA_VER, ., 1, 1)
  ASTATICLIB_CUDA_VER_VAR = \
    $$ASTATICLIB_CUDA_MAJOR_VER_$ASTATICLIB_CUDA_MINOR_VER
  ASTATICLIB_CUDA_DIR = $$getenv(CUDA_PATH_V$$ASTATICLIB_CUDA_VER_VAR)
}

# Path to cuda toolkit install
isEmpty(ASTATICLIB_CUDA_DIR): ASTATICLIB_CUDA_DIR = $$(CUDA_PATH)

isEmpty(ASTATICLIB_CUDA_DIR): error("CUDA Toolkit was not found...")

# Depending on your system either 'Win32', 'x64', or 'Win64'
isEmpty(ASTATICLIB_SYSTEM_NAME): ASTATICLIB_SYSTEM_NAME = x64

# '32' or '64', depending on your system
equals(ASTATICLIB_SYSTEM_NAME, Win32): ASTATICLIB_SYSTEM_TYPE = 32
else:equals(ASTATICLIB_SYSTEM_NAME, x64): ASTATICLIB_SYSTEM_TYPE = 64
else:equals(ASTATICLIB_SYSTEM_NAME, Win64): ASTATICLIB_SYSTEM_TYPE = 64

# include paths
INCLUDEPATH += $$ASTATICLIB_CUDA_DIR/include

# library directories
LIBS += -L"$$ASTATICLIB_CUDA_DIR/lib/$$ASTATICLIB_SYSTEM_NAME"

# Add the necessary libraries
for(lib, ASTATICLIB_CUDA_LIB_NAMES) {
  ASTATICLIB_CUDA_LIBS += -l$$lib
}
LIBS += $$ASTATICLIB_CUDA_LIBS
