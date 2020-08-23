TARGET = iphone:11.2:8.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = MobileMeadowPreferences

MobileMeadowPreferences_FILES = PXMMPRootListController.m
MobileMeadowPreferences_FRAMEWORKS = UIKit
MobileMeadowPreferences_PRIVATE_FRAMEWORKS = Preferences
MobileMeadowPreferences_INSTALL_PATH = /Library/PreferenceBundles
MobileMeadowPreferences_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
