CFLAGS += -I.. -include ../macros.h
export CFLAGS
include $(THEOS)/makefiles/common.mk
SUBPROJECTS += Tweak
include $(THEOS_MAKE_PATH)/aggregate.mk
