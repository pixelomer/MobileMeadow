TARGET = iphone:13.0:13.0
ARCHS = arm64 arm64e
CFLAGS += -I.. -include macros.h -Wno-deprecated-declarations
export CFLAGS TARGET ARCHS
include $(THEOS)/makefiles/common.mk
SUBPROJECTS += Tweak Application
include $(THEOS_MAKE_PATH)/aggregate.mk
