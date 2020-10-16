#import "FlexDebugging.h"
#import "FLEX/IMLEXManager.h"

@implementation FlexDebugging

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(showExplorer)
{
    [[FLEXManager sharedManager] showExplorer];
}

RCT_EXPORT_METHOD(hideExplorer)
{
    [[FLEXManager sharedManager] hideExplorer];
}

RCT_EXPORT_METHOD(toggleExplorer)
{
    [[FLEXManager sharedManager] toggleExplorer];
}

@end
