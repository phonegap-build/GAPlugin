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

- (void) initGA:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) exitGA: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) trackEvent:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) trackPage:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) setVariable:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) trackTransaction:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end
