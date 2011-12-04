//
//  OSVersion.m
//  mogenerator Example http://github.com/apontious/mogenerator-Example
//
//  Created by Andrew Pontious on 11/13/11.
//  Most code in this file copied from http://www.cocoadev.com/index.pl?DeterminingOSVersion and falls under its copyright.
//  Rest copyright (c) 2011 Andrew Pontious.
//  For rest, some right reserved: http://opensource.org/licenses/mit-license.php
//

#import "OSVersion.h"

@implementation OSVersion

+ (void)getSystemVersionMajor:(NSUInteger *)major
                        minor:(NSUInteger *)minor
                       bugFix:(NSUInteger *)bugFix
{
    OSErr err;
    SInt32 systemVersion, versionMajor, versionMinor, versionBugFix;
    if ((err = Gestalt(gestaltSystemVersion, &systemVersion)) != noErr) goto fail;
    if (systemVersion < 0x1040)
    {
        if (major) *major = ((systemVersion & 0xF000) >> 12) * 10 +
            ((systemVersion & 0x0F00) >> 8);
        if (minor) *minor = (systemVersion & 0x00F0) >> 4;
        if (bugFix) *bugFix = (systemVersion & 0x000F);
    }
    else
    {
        if ((err = Gestalt(gestaltSystemVersionMajor, &versionMajor)) != noErr) goto fail;
        if ((err = Gestalt(gestaltSystemVersionMinor, &versionMinor)) != noErr) goto fail;
        if ((err = Gestalt(gestaltSystemVersionBugFix, &versionBugFix)) != noErr) goto fail;
        if (major) *major = versionMajor;
        if (minor) *minor = versionMinor;
        if (bugFix) *bugFix = versionBugFix;
    }
    
    return;
    
fail:
    NSLog(@"Unable to obtain system version: %ld", (long)err);
    if (major) *major = 10;
    if (minor) *minor = 0;
    if (bugFix) *bugFix = 0;
}

static BOOL sIsLionOrGreater = NO;

+ (BOOL)isLionOrGreater {
    // Use cached value; all _Entity.m files call it in their resolveInstanceMethod implementations, so it will be called over and over.
    return sIsLionOrGreater;
}

+ (void)initialize {
    NSUInteger minor = 0;
    
    [self getSystemVersionMajor:NULL minor:&minor bugFix:NULL];
    
    if (minor >= 7) {
        sIsLionOrGreater = YES;
    } 
}

@end
