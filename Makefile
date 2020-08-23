ENABLE_MAIL_FUNCTIONALITY ?= 0
MEADOW_USE_SIMULATOR ?= 0
MEADOW_TESTER_BUILD ?= 0
ifneq ($(MEADOW_TESTER_BUILD),0)
MEADOW_TESTER_BUILD = 1
endif
ifneq ($(MEADOW_USE_SIMULATOR),0)
MEADOW_USE_SIMULATOR = 1
TARGET = simulator:clang::7.0
ARCHS = x86_64
else
MEADOW_USE_SIMULATOR = 0
TARGET = iphone:13.3:8.0
ARCHS = armv7 arm64 arm64e
endif
CFLAGS += -I.. -DMEADOW_TESTER_BUILD=$(MEADOW_TESTER_BUILD) -include macros.h -DENABLE_MAIL_FUNCTIONALITY=$(ENABLE_MAIL_FUNCTIONALITY) -Wno-unused-function -Wno-unused-variable
export CFLAGS TARGET ARCHS MEADOW_USE_SIMULATOR MEADOW_TESTER_BUILD
include $(THEOS)/makefiles/common.mk

ifeq ($(ENABLE_MAIL_FUNCTIONALITY),0)
after-stage::
	@	$(PRINT_FORMAT_GREEN) "Removing images related to mail functionality"; \
		dir="$(THEOS_STAGING_DIR)/Library/MobileMeadow/Assets"; \
		rm -v "$${dir}/"deliverybird_*.png; \
		rm -v "$${dir}/"mail*.png;
endif

SUBPROJECTS += Tweak
ifeq ($(MEADOW_USE_SIMULATOR),0)
ifneq ($(ENABLE_MAIL_FUNCTIONALITY),0)
SUBPROJECTS += Application
else
SUBPROJECTS += Preferences
endif
endif
include $(THEOS_MAKE_PATH)/aggregate.mk
