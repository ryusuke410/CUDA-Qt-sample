TARGET = test0
TEMPLATE = app
CONFIG += console c++11
CONFIG -= app_bundle
CONFIG -= qt

SOURCES += \
  $$PWD/test0.cpp

ASTATICLIB_TOP = $$top_srcdir

INCLUDEPATH += $$ASTATICLIB_TOP/include

CONFIG(debug, debug|release): ASTATICLIB_PATH = $$ASTATICLIB_TOP/lib/debug
CONFIG(release, debug|release): ASTATICLIB_PATH = $$ASTATICLIB_TOP/lib/release

LIBS += -L$$quote($$ASTATICLIB_PATH)
LIBS += -lastaticlib

include($$ASTATICLIB_TOP/astaticlib.pri)
