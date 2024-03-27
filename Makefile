export TARGET := iphone:clang:latest:15.0
export ARCHS = arm64 arm64e
export SYSROOT = $(THEOS)/sdks/iPhoneOS14.4.sdk/

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = RecordDot

RecordDot_FILES = Tweak.x
RecordDot_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += recorddotprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
