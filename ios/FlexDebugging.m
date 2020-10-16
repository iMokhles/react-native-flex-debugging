#import "FlexDebugging.h"
#import "FLEX/IMLEXManager.h"

@implementation FlexDebugging

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(showExplorer)
{
    [[IMLEXManager sharedManager] showExplorer];
}

RCT_EXPORT_METHOD(hideExplorer)
{
    [[IMLEXManager sharedManager] hideExplorer];
}

RCT_EXPORT_METHOD(toggleExplorer)
{
    [[IMLEXManager sharedManager] toggleExplorer];
}

@end
