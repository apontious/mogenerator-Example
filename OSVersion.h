//
//  OSVersion.h
//  mogenerator Example http://github.com/apontious/mogenerator-Example
//
//  Created by Andrew Pontious on 11/13/11.
//  Copyright (c) 2011 Andrew Pontious.
//  Some right reserved: http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface OSVersion : NSObject

// TODO: add + (BOOL)isIOS5OrGreater; #ifdef'ed in only for iOS code, with Mac code in an #else clause. See http://stackoverflow.com/questions/3339722/check-iphone-ios-version for a potential implementation

+ (BOOL)isLionOrGreater;

@end
