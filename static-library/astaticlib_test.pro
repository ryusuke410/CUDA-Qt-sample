TEMPLATE = subdirs

SUBDIRS += \
  astaticlib \
  test0

astaticlib.file = $$PWD/astaticlib.pro

test0.subdir = $$PWD/test/test0
test0.depends = astaticlib
