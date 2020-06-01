ifneq ($(MEADOW_USE_SIMULATOR),0)
MEADOW_USE_SIMULATOR = 1
TARGET = simulator:clang::7.0
ARCHS = x86_64
else
MEADOW_USE_SIMULATOR = 0
TARGET = iphone:13.0:8.0
ARCHS = armv7 arm64 arm64e
endif
CFLAGS += -I.. -include macros.h #-Wno-deprecated-declarations
export CFLAGS TARGET ARCHS MEADOW_USE_SIMULATOR
include $(THEOS)/makefiles/common.mk
SUBPROJECTS += Tweak
ifeq ($(MEADOW_USE_SIMULATOR),0)
SUBPROJECTS += Application
endif
include $(THEOS_MAKE_PATH)/aggregate.mk