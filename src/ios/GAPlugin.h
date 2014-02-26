//
//  GAPlugin.h
//  GoSocial
//
//  Created by Bob Easterday on 10/9/12.
//  Copyright (c) 2012 Adobe Systems, Inc. All rights reserved.
//

#import <Cordova/CDV.h>
#import "GAI.h"

@interface GAPlugin : CDVPlugin
{
    BOOL    inited;
}

- (void) initGA:(CDVInvokedUrlCommand*)command;
- (void) exitGA:(CDVInvokedUrlCommand*)command;
- (void) trackEvent:(CDVInvokedUrlCommand*)command;
- (void) trackPage:(CDVInvokedUrlCommand*)command;
- (void) trackTransaction:(CDVInvokedUrlCommand*)command;
- (void) trackCaughtException:(CDVInvokedUrlCommand*)command;
- (void) trackUncaughtException:(CDVInvokedUrlCommand*)command;
- (void) setMetric:(CDVInvokedUrlCommand*)command;
- (void) setDimension:(CDVInvokedUrlCommand*)command;

@end
