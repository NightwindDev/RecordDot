// Copyright (c) 2024 Nightwind. All rights reserved.

#import <Foundation/Foundation.h>
#import "RCDRootListController.h"
#import <rootless.h>
#import <spawn.h>

@interface NSDistributedNotificationCenter : NSNotificationCenter
+ (instancetype)defaultCenter;
@end

static void respring();
static void performRespringFromController(UIViewController *controller);
static void performResetPrefsFromController(UIViewController *controller);

UIBarButtonItem *topMenuButtonItem;

@implementation RCDRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)open:(PSSpecifier *)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[sender propertyForKey:@"url"]] options:@{} completionHandler:nil];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.nightwind.recorddotprefs"];
	[prefs setValue:value forKey:specifier.properties[@"key"]];

	[NSDistributedNotificationCenter.defaultCenter postNotificationName:@"rcd_frameAdjusted" object:nil];

	[super setPreferenceValue:value specifier:specifier];
}

- (void)initTopMenu {
	UIButton *topMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
	topMenuButton.frame = CGRectMake(0,0,26,26);
	topMenuButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
	topMenuButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
	[topMenuButton setImage:[[UIImage systemImageNamed:@"gearshape"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];

	UIAction *respring = [UIAction actionWithTitle:@"Respring"
													image:[UIImage systemImageNamed:@"arrow.counterclockwise"]
												identifier:nil
												handler:^(UIAction *action) {
		performRespringFromController(self);
	}];

	UIAction *resetPrefs = [UIAction actionWithTitle:@"Reset Preferences"
													image:[UIImage systemImageNamed:@"trash"]
												identifier:nil
													handler:^(UIAction *action) {
		performResetPrefsFromController(self);
	}];

	resetPrefs.attributes = UIMenuElementAttributesDestructive;

	NSArray *items = @[respring, resetPrefs];

	topMenuButton.menu = [UIMenu menuWithTitle:@"" children: items];
	topMenuButton.showsMenuAsPrimaryAction = true;

	topMenuButtonItem = [[UIBarButtonItem alloc] initWithCustomView:topMenuButton];

	self.navigationItem.rightBarButtonItem = topMenuButtonItem;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self initTopMenu];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	// Set navbar text tint color to `kTintColor` when the controller is opened
	self.navigationController.navigationBar.tintColor = [UIColor systemRedColor];
	self.navigationController.navigationController.navigationBar.tintColor = [UIColor systemRedColor];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillAppear:animated];

	// Reset the original navbar text tint color when the controller is closed
	self.navigationController.navigationBar.tintColor = [UIColor systemBlueColor];
	self.navigationController.navigationController.navigationBar.tintColor = [UIColor systemBlueColor];
}

- (PSTableCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	PSTableCell *cell = (PSTableCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];

	cell.tintColor = [UIColor systemRedColor];

	return cell;
}

@end

static void respring() {
    extern char **environ;
    pid_t pid;

	const char *sb_args[] = {"killall", "SpringBoard", NULL};
	posix_spawn(&pid, ROOT_PATH("/usr/bin/killall"), NULL, NULL, (char *const *)sb_args, environ);

	const char *pf_args[] = {"killall", "Preferences", NULL};
	posix_spawn(&pid, ROOT_PATH("/usr/bin/killall"), NULL, NULL, (char *const *)pf_args, environ);
}

static void performRespringFromController(UIViewController *controller) {
	UIWindow *window = UIApplication.sharedApplication.windows.firstObject;

	[UIView animateWithDuration:0.2 animations:^{
		window.alpha = 0;
		window.transform = CGAffineTransformMakeScale(0.9, 0.9);
	} completion:^(BOOL finished) {
		if (finished) {
			[controller.view endEditing:YES];
			respring();
		}
	}];
}

static void performResetPrefsFromController(UIViewController *controller) {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reset Preferences?" message:@"This cannot be undone" preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
	[alert addAction:cancelAction];

	[alert addAction:[UIAlertAction actionWithTitle:@"Reset" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
		[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:@"com.nightwind.recorddotprefs"];
		NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.nightwind.recorddotprefs"];

		[userDefaults setObject:@true forKey:@"tweakEnabled"];
		[userDefaults setObject:@(-5.0f) forKey:@"xPosition"];
		[userDefaults setObject:@(6.0f) forKey:@"yPosition"];
		[userDefaults setObject:@(8.0f) forKey:@"width"];
		[userDefaults setObject:@(8.0f) forKey:@"height"];

		[userDefaults synchronize];

		performRespringFromController(controller);
	}]];

	[controller presentViewController:alert animated:true completion:nil];
}