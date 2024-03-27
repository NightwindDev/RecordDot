// Copyright (c) 2024 Nightwind. All rights reserved.

@import UIKit;

/* ------------------------ PREFS ------------------------ */

static BOOL tweakEnabled = false;
static CGFloat xPosition = -5.0f;
static CGFloat yPosition = 6.0f;
static CGFloat width = 8.0f;
static CGFloat height = 8.0f;

/* ------------------------ MACROS ----------------------- */

#define dotFrame CGRectMake(xPosition, yPosition, width, height)

/* ----------------------- HEADERS ----------------------- */

@interface NSDistributedNotificationCenter : NSNotificationCenter
+ (instancetype)defaultCenter;
@end

@interface _UIStatusBarPillView : UIView
@property (nonatomic, retain) UIVisualEffectView *visualEffectView;
@property (nonatomic, retain) CALayer *pulseLayer;
@property (nonatomic, retain) UIColor *pillColor;
@end

/* ----------------------- HOOKS ----------------------- */

%hook _UIStatusBarPillView

/* ------------------- LIFECYCLE HOOKS ------------------- */

- (void)didMoveToSuperview {
	%orig;

	self.visualEffectView.layer.cornerRadius = 4;
	self.visualEffectView.hidden = false;
	self.visualEffectView.backgroundColor = [self pillColor];
}

- (void)layoutSubviews {
	%orig;

	self.visualEffectView.frame = dotFrame;
	self.pulseLayer.frame = dotFrame;
}

/* ------------------ OVERRIDING GETTERS ------------------ */

- (UIColor *)backgroundColor {
	return tweakEnabled ? [UIColor clearColor] : %orig;
}

- (BOOL)clipsToBounds {
	return tweakEnabled ? false : %orig;
}

- (CGRect)frame {
	return tweakEnabled ? dotFrame : %orig;
}

/* ------------------ OVERRIDING SETTERS ------------------ */

- (void)setBackgroundColor:(UIColor *)backgroundColor {
	%orig(tweakEnabled ? [UIColor clearColor] : backgroundColor);
}

- (void)setClipsToBounds:(BOOL)clipsToBounds {
	%orig(tweakEnabled ? false : clipsToBounds);
}

- (void)setFrame:(CGRect)frame {
	%orig(tweakEnabled ? dotFrame : frame);
}

%end

/* --------------------- CONSTRUCTOR ---------------------- */

%ctor {
	NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.nightwind.recorddotprefs"];

	tweakEnabled = [prefs objectForKey:@"tweakEnabled"] ? [prefs boolForKey:@"tweakEnabled"] : true;
	xPosition = [prefs objectForKey:@"xPosition"] ? [prefs floatForKey:@"xPosition"] : -5.0f;
	yPosition = [prefs objectForKey:@"yPosition"] ? [prefs floatForKey:@"yPosition"] : 6.0f;
	width = [prefs objectForKey:@"width"] ? [prefs floatForKey:@"width"] : 8.0f;
	height = [prefs objectForKey:@"height"] ? [prefs floatForKey:@"height"] : -5.0f;

	if (tweakEnabled) {
		%init;
	}
}