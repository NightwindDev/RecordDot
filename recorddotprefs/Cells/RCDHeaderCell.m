// Copyright (c) 2024 Nightwind. All rights reserved.

#import "RCDHeaderCell.h"

#define kTintColor [UIColor systemRedColor]

NSString *getVersion() {
    return PACKAGE_VERSION;
}

@implementation RCDHeaderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];

    if (self) {
        UILabel *tweakTitle = [UILabel new];
        tweakTitle.text = [specifier propertyForKey:@"tweakTitle"];
        tweakTitle.font = [UIFont boldSystemFontOfSize:30];
        tweakTitle.textAlignment = NSTextAlignmentCenter;
        tweakTitle.translatesAutoresizingMaskIntoConstraints = false;
        [self.contentView addSubview:tweakTitle];

        [NSLayoutConstraint activateConstraints:@[
            [tweakTitle.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor],
            [tweakTitle.bottomAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [tweakTitle.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        ]];

        UIImage *image = [UIImage imageNamed:@"pref_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];

        UIImageView *tweakIconImageView = [[UIImageView alloc] initWithImage:image];
        tweakIconImageView.layer.masksToBounds = true;
        tweakIconImageView.layer.cornerRadius = 15.0f;
        tweakIconImageView.translatesAutoresizingMaskIntoConstraints = false;
        [self.contentView addSubview: tweakIconImageView];

        [NSLayoutConstraint activateConstraints:@[
            [tweakIconImageView.widthAnchor constraintEqualToConstant: 60],
            [tweakIconImageView.heightAnchor constraintEqualToConstant: 60],
            [tweakIconImageView.bottomAnchor constraintEqualToAnchor:tweakTitle.topAnchor constant: -10],
            [tweakIconImageView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        ]];

        UILabel *versionSubtitle = [UILabel new];
        versionSubtitle.text = getVersion();
        versionSubtitle.textColor = UIColor.secondaryLabelColor;
        versionSubtitle.font = [UIFont boldSystemFontOfSize:25];
        versionSubtitle.textAlignment = NSTextAlignmentCenter;
        versionSubtitle.translatesAutoresizingMaskIntoConstraints = false;
        [self.contentView addSubview:versionSubtitle];

        [NSLayoutConstraint activateConstraints:@[
            [versionSubtitle.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor],
            [versionSubtitle.topAnchor constraintEqualToAnchor:self.contentView.centerYAnchor constant: 2],
            [versionSubtitle.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        ]];

        int on = [[[[NSUserDefaults alloc] initWithSuiteName:@"com.nightwind.recorddotprefs"] objectForKey:@"tweakEnabled"] intValue];

        UISwitch *switchCell = [[UISwitch alloc] initWithFrame: CGRectZero];
        switchCell.transform = CGAffineTransformMakeScale(1.3, 1.3);
        switchCell.translatesAutoresizingMaskIntoConstraints = false;
        switchCell.onTintColor = kTintColor;
        switchCell.on = on == 1 ? true : false;
        [switchCell addTarget: self action: @selector(switchTriggered) forControlEvents: UIControlEventValueChanged];
        [self.contentView addSubview: switchCell];

        [NSLayoutConstraint activateConstraints:@[
            [switchCell.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant: -10],
            [switchCell.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        ]];

        [self setControl:switchCell];

    }

    return self;
}

- (void)switchTriggered {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.nightwind.recorddotprefs"];

    [userDefaults setObject:@(((UISwitch *)(self.control)).on) forKey:@"tweakEnabled"];
    [userDefaults synchronize];
}

- (void)layoutSubviews {
    [super layoutSubviews];

	  self.backgroundColor = [UIColor clearColor];

    for (UIView *view in self.subviews) {
        if (view != self.contentView){
            [view removeFromSuperview];
        }
    }
}

@end