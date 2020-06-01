ifeq ($(MEADOW_USE_SIMULATOR),0)
include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = MeadowMail

MeadowMail_FILES = $(wildcard */*.m) $(wildcard *.m)
MeadowMail_FRAMEWORKS = UIKit CoreGraphics
MeadowMail_CODESIGN_FLAGS = -Sentitlements.xml
MeadowMail_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/application.mk
endif