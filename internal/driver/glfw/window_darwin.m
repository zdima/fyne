#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

int getWindowIndex(const void* p)
{
    if( p == nil)
        return -1;
    NSWindow* w = (NSWindow*)p;
    int ret = [w orderedIndex];
    return ret;
}
