//
//  GAPlugin.h
//  GoSocial
//
//  Created by Bob Easterday on 10/9/12.
//  Copyright (c) 2012 Adobe Systems, Inc. All rights reserved.
//

#import <Cordova/CDV.h>
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@interface GAPlugin : CDVPlugin
{
    BOOL    inited;
}

- (void) initGA:(CDVInvokedUrlCommand*)command;
- (void) exitGA:(CDVInvokedUrlCommand*)command;
- (void) trackEvent:(CDVInvokedUrlCommand*)command;
- (void) trackPage:(CDVInvokedUrlCommand*)command;
- (void) trackException:(CDVInvokedUrlCommand*)command;
- (void) trackTransaction:(CDVInvokedUrlCommand*)command;
- (void) setCustomDimension:(CDVInvokedUrlCommand*)command;
- (void) setCustomMetric:(CDVInvokedUrlCommand*)command;
- (void) setOptOut:(CDVInvokedUrlCommand*)command;

@end