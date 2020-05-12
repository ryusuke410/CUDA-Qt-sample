#-------------------------------------------------------------------------------
# astaticlib (CUDA static library example with qmake)
#-------------------------------------------------------------------------------
# Assume Qt5 and msvc 15 or later

TARGET = astaticlib

TEMPLATE = lib
CONFIG += staticlib

CONFIG -= qt
CONFIG += c++11

#-------------------------------------------------------------------------------
# source code list
#-------------------------------------------------------------------------------

HEADERS += \
  $$PWD/src/astaticlib.h \
  $$PWD/src/vectadd.cuh

SOURCES += \
  $$PWD/src/astaticlib.cpp

CUDA_SOURCES += \
  $$PWD/src/vectadd.cu

# This is need, for instance, when your source codes are encoded in Shift-JIS
DEFINES -= UNICODE

#-------------------------------------------------------------------------------
# MSVCRT link option
# (static or dynamic, it must be the same with your Qt SDK link option)
#-------------------------------------------------------------------------------
CONFIG(debug, debug|release): MSVCRT_LINK_FLAG = /MDd
CONFIG(release, debug|release): MSVCRT_LINK_FLAG = /MD

#-------------------------------------------------------------------------------
# CUDA build options
#-------------------------------------------------------------------------------
#ASTATICLIB_CUDA_VER = 10.2
#ASTATICLIB_SYSTEM_NAME = x64
include(astaticlib.pri)

# Type of CUDA architecture
CUDA_GENCODE_GTX780 = -gencode=arch=compute_30,code=\\\"sm_30,compute_30\\\"
CUDA_GENCODE_GTX980 = -gencode=arch=compute_52,code=\\\"sm_52,compute_52\\\"
CUDA_GENCODE_GTX1080 = -gencode=arch=compute_61,code=\\\"sm_61,compute_61\\\"
CUDA_GENCODE_GTX2080 = -gencode=arch=compute_75,code=\\\"sm_75,compute_75\\\"

CUDA_GENCODE = \
  $$CUDA_GENCODE_GTX780 \
  $$CUDA_GENCODE_GTX980 \
  $$CUDA_GENCODE_GTX1080 \
  $$CUDA_GENCODE_GTX2080

NVCC_OPTIONS = # --use_fast_math

#-------------------------------------------------------------------------------
# prepare compile commands
#-------------------------------------------------------------------------------

# The following makes sure all path names
# (which often include spaces) are put between quotation marks
CUDA_INC = $$join(INCLUDEPATH,'" -I"','-I"','"')

CUDA_OBJECTS_DIR = OBJECTS_DIR/../cuda_obj

# Configuration of the Cuda compiler
CONFIG(debug, debug|release): CONFIGURATION_MACROS = -DWIN32 -D_MBCS -D_DEBUG
CONFIG(release, debug|release): CONFIGURATION_MACROS = -DWIN32 -D_MBCS

CONFIG(debug, debug|release): CUDA_GEN_DEBUG_INFO = -g -G
CONFIG(release, debug|release): CUDA_GEN_DEBUG_INFO =

CONFIG(debug, debug|release): CUDA_XC_OPT = \
  /wd4819,/EHsc,/W3,/nologo,/FS,/Zi,/Od,/RTC1,/Fd\\\"$${TARGET}.pdb\\\",$$MSVCRT_LINK_FLAG
CONFIG(release, debug|release): CUDA_XC_OPT = \
  /wd4819,/EHsc,/W3,/nologo,/FS,/Zi,/O2,$$MSVCRT_LINK_FLAG

nvcc_compile.input = CUDA_SOURCES
nvcc_compile.output = $$CUDA_OBJECTS_DIR/${QMAKE_FILE_BASE}.cu.obj
nvcc_compile.commands = \
  $$ASTATICLIB_CUDA_DIR/bin/nvcc.exe \
  $$NVCC_OPTIONS \
  $$CUDA_INC $$CUDA_LIBS \
  --machine $$ASTATICLIB_SYSTEM_TYPE \
  $$CUDA_GENCODE \
  -cudart static \
  $$CUDA_GEN_DEBUG_INFO \
  $$CONFIGURATION_MACROS \
  -Xcompiler "$$CUDA_XC_OPT" \
  -dc -o ${QMAKE_FILE_OUT} ${QMAKE_FILE_NAME}
nvcc_compile.dependency_type = TYPE_C
nvcc_compile.variable_out = CUDA_OBJECTS
QMAKE_EXTRA_COMPILERS += nvcc_compile

nvcc_obj_forward.input = CUDA_OBJECTS
nvcc_obj_forward.output = ${QMAKE_FILE_NAME}
QMAKE_EXTRA_COMPILERS += nvcc_obj_forward

# device-link
nvcc_device_link.input = CUDA_OBJECTS
nvcc_device_link.CONFIG = combine
nvcc_device_link.output = $$CUDA_OBJECTS_DIR/device-link.obj
nvcc_device_link.commands = \
  $$ASTATICLIB_CUDA_DIR/bin/nvcc.exe \
  $$NVCC_OPTIONS \
  $$CUDA_LIBS \
  --machine $$ASTATICLIB_SYSTEM_TYPE \
  $$CUDA_GENCODE \
  -cudart static \
  $$CUDA_GEN_DEBUG_INFO \
  $$CONFIGURATION_MACROS \
  -Xcompiler "$$CUDA_XC_OPT" \
  -dlink -o ${QMAKE_FILE_OUT} ${QMAKE_FILE_NAME}
QMAKE_EXTRA_COMPILERS += nvcc_device_link


#-------------------------------------------------------------------------------
# MISC
#-------------------------------------------------------------------------------

# copy include file necessary when using your library
PUB_HEADERS = \
  $$PWD/src/astaticlib.h

PUB_HEADERS_DIR = $$PWD/include
PUB_HEADERS_DIR~= s,/,\\,g

POST_TARGETDEPS += copy_pub_header
QMAKE_EXTRA_TARGETS += copy_pub_header

for(hdr, PUB_HEADERS) {
  hdr ~= s,/,\\,g
  copy_pub_header.commands += \
    for %%o in ($$hdr) \
    do echo F | xcopy /D /I /Y \"%%~o\" \"$$PUB_HEADERS_DIR\\%%~nxo\" \
    $$escape_expand(\n\t)
}

# specify where the library generated
CONFIG(debug, debug|release): DESTDIR = $$PWD/lib/debug
CONFIG(release, debug|release): DESTDIR = $$PWD/lib/release

!isEmpty(DESTDIR) {
  CONFIG(debug, debug|release) {
    PROFILE_DB_PATH = $$shadowed($$PWD)/debug/$${TARGET}.pdb
  }
  CONFIG(release, debug|release) {
     PROFILE_DB_PATH = $$shadowed($$PWD)/release/$${TARGET}.pdb
  }
  PROFILE_DB_PATH ~= s,/,\\,g

  !isEmpty (QMAKE_POST_LINK) {
    QMAKE_POST_LINK += $$escape_expand(\n\t)
  }
  QMAKE_POST_LINK += \
    for %%o in ($$PROFILE_DB_PATH) \
    do if exist \"%%~o\" \
    echo F | xcopy /D /I /Y \"%%~o\" \"$$replace(DESTDIR,/,\\)\\%%~nxo\"
}

# Default rules for deployment.
unix {
  target.path = /usr/lib
}
!isEmpty(target.path): INSTALLS += target
