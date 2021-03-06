//
//  IMLEXNetworkSettingsController.m
//  IMLEXInjected
//
//  Created by Ryan Olson on 2/20/15.
//

#import "IMLEXNetworkSettingsController.h"
#import "IMLEXNetworkObserver.h"
#import "IMLEXNetworkRecorder.h"
#import "IMLEXUtility.h"
#import "IMLEXTableView.h"
#import "IMLEXColor.h"

@interface IMLEXNetworkSettingsController () <UIActionSheetDelegate>
@property (nonatomic) float cacheLimitValue;
@property (nonatomic, readonly) NSString *cacheLimitCellTitle;

@property (nonatomic, readonly) UISwitch *observerSwitch;
@property (nonatomic, readonly) UISwitch *cacheMediaSwitch;
@property (nonatomic, readonly) UISlider *cacheLimitSlider;
@property (nonatomic) UILabel *cacheLimitLabel;

@property (nonatomic) NSMutableArray<NSString *> *hostBlacklist;
@end

@implementation IMLEXNetworkSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self disableToolbar];
    self.hostBlacklist = IMLEXNetworkRecorder.defaultRecorder.hostBlacklist.mutableCopy;

    _observerSwitch = [UISwitch new];
    _cacheMediaSwitch = [UISwitch new];
    _cacheLimitSlider = [UISlider new];

    self.observerSwitch.on = IMLEXNetworkObserver.enabled;
    [self.observerSwitch addTarget:self
        action:@selector(networkDebuggingToggled:)
        forControlEvents:UIControlEventValueChanged
    ];

    self.cacheMediaSwitch.on = IMLEXNetworkRecorder.defaultRecorder.shouldCacheMediaResponses;
    [self.cacheMediaSwitch addTarget:self
        action:@selector(cacheMediaResponsesToggled:)
        forControlEvents:UIControlEventValueChanged
    ];

    [self.cacheLimitSlider addTarget:self
        action:@selector(cacheLimitAdjusted:)
        forControlEvents:UIControlEventValueChanged
    ];

    UISlider *slider = self.cacheLimitSlider;
    self.cacheLimitValue = IMLEXNetworkRecorder.defaultRecorder.responseCacheByteLimit;
    const NSUInteger fiftyMega = 50 * 1024 * 1024;
    slider.minimumValue = 0;
    slider.maximumValue = fiftyMega;
    slider.value = self.cacheLimitValue;
}

- (void)setCacheLimitValue:(float)cacheLimitValue {
    _cacheLimitValue = cacheLimitValue;
    self.cacheLimitLabel.text = self.cacheLimitCellTitle;
    [IMLEXNetworkRecorder.defaultRecorder setResponseCacheByteLimit:cacheLimitValue];
}

- (NSString *)cacheLimitCellTitle {
    NSInteger cacheLimit = self.cacheLimitValue;
    NSInteger limitInMB = round(cacheLimit / (1024 * 1024));
    return [NSString stringWithFormat:@"Cache Limit (%@ MB)", @(limitInMB)];
}


#pragma mark - Settings Actions

- (void)networkDebuggingToggled:(UISwitch *)sender {
    IMLEXNetworkObserver.enabled = sender.isOn;
}

- (void)cacheMediaResponsesToggled:(UISwitch *)sender {
    IMLEXNetworkRecorder.defaultRecorder.shouldCacheMediaResponses = sender.isOn;
}

- (void)cacheLimitAdjusted:(UISlider *)sender {
    self.cacheLimitValue = sender.value;
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.hostBlacklist.count ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 4;
        case 1: return self.hostBlacklist.count;
        default: return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return @"General";
        case 1: return @"Host Blacklist";
        default: return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    UITableViewCell *cell = [self.tableView
        dequeueReusableCellWithIdentifier:kIMLEXDefaultCell forIndexPath:indexPath
    ];

    cell.accessoryView = nil;
    cell.textLabel.textColor = IMLEXColor.primaryTextColor;

    switch (indexPath.section) {
        // Settings
        case 0: {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Network Debugging";
                    cell.accessoryView = self.observerSwitch;
                    break;
                case 1:
                    cell.textLabel.text = @"Cache Media Responses";
                    cell.accessoryView = self.cacheMediaSwitch;
                    break;
                case 2:
                    cell.textLabel.text = @"Reset Host Blacklist";
                    cell.textLabel.textColor = tableView.tintColor;
                    break;
                case 3:
                    cell.textLabel.text = self.cacheLimitCellTitle;
                    self.cacheLimitLabel = cell.textLabel;
                    [self.cacheLimitSlider removeFromSuperview];
                    [cell.contentView addSubview:self.cacheLimitSlider];

                    CGRect container = cell.contentView.frame;
                    UISlider *slider = self.cacheLimitSlider;
                    [slider sizeToFit];

                    CGFloat sliderWidth = 150.f;
                    CGFloat sliderOriginY = IMLEXFloor((container.size.height - slider.frame.size.height) / 2.0);
                    CGFloat sliderOriginX = CGRectGetMaxX(container) - sliderWidth - tableView.separatorInset.left;
                    self.cacheLimitSlider.frame = CGRectMake(
                        sliderOriginX, sliderOriginY, sliderWidth, slider.frame.size.height
                    );

                    // Make wider, keep in middle of cell, keep to trailing edge of cell
                    self.cacheLimitSlider.autoresizingMask = ({
                        UIViewAutoresizingFlexibleWidth |
                        UIViewAutoresizingFlexibleLeftMargin |
                        UIViewAutoresizingFlexibleTopMargin |
                        UIViewAutoresizingFlexibleBottomMargin;
                    });
                    break;
            }

            break;
        }

        // Blacklist entries
        case 1: {
            cell.textLabel.text = self.hostBlacklist[indexPath.row];
            break;
        }

        default:
            @throw NSInternalInconsistencyException;
            break;
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)ip {
    // Can only select the "Reset Host Blacklist" row
    return ip.section == 0 && ip.row == 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [IMLEXAlert makeAlert:^(IMLEXAlert *make) {
        make.title(@"Reset Host Blacklist");
        make.message(@"You cannot undo this action. Are you sure?");
        make.button(@"Reset").destructiveStyle().handler(^(NSArray<NSString *> *strings) {
            self.hostBlacklist = nil;
            [IMLEXNetworkRecorder.defaultRecorder.hostBlacklist removeAllObjects];
            [IMLEXNetworkRecorder.defaultRecorder synchronizeBlacklist];
            [self.tableView deleteSections:
                [NSIndexSet indexSetWithIndex:1]
            withRowAnimation:UITableViewRowAnimationAutomatic];
        });
        make.button(@"Cancel").cancelStyle();
    } showFrom:self];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 1;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)style
forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(style == UITableViewCellEditingStyleDelete);

    NSString *host = self.hostBlacklist[indexPath.row];
    [self.hostBlacklist removeObjectAtIndex:indexPath.row];
    [IMLEXNetworkRecorder.defaultRecorder.hostBlacklist removeObject:host];
    [IMLEXNetworkRecorder.defaultRecorder synchronizeBlacklist];

    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
