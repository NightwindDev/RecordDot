include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = RecordDotPrefs

RecordDotPrefs_FILES = RCDRootListController.m $(wildcard Cells/*.m)
RecordDotPrefs_FRAMEWORKS = UIKit
RecordDotPrefs_PRIVATE_FRAMEWORKS = Preferences
RecordDotPrefs_INSTALL_PATH = /Library/PreferenceBundles
RecordDotPrefs_CFLAGS = -fobjc-arc -DPACKAGE_VERSION='@"$(THEOS_PACKAGE_BASE_VERSION)"' -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/bundle.mk
