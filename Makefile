export ARCHS = armv7 arm64
export TARGET = iphone:clang:latest:10.0

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = SystemInfo
SystemInfo_FILES = main.m SIAppDelegate.m SIRootViewController.m
SystemInfo_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall \"SystemInfo\"" || true
	install.exec "uicache"

SUBPROJECTS += systeminfowidget

include $(THEOS_MAKE_PATH)/aggregate.mk