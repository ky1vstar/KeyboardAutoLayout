#import <UIKit/UIKit.h>

@interface __KeyboardAutoLayoutLoader : NSObject
@end

@implementation __KeyboardAutoLayoutLoader

+ (void)load {
    [NSClassFromString(@"__KeyboardManager__") valueForKey:@"shared"];
}

@end
