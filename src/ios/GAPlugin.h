//
//  GAPlugin.h
//  GoSocial
//
//  Created by Bob Easterday on 10/9/12.
//  Copyright (c) 2012 Adobe Systems, Inc. All rights reserved.
//

#import "CDVPlugin.h"
#import "GAI.h"

@interface GAPlugin : CDVPlugin
{
	BOOL inited;
}

- (void)initGA:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;
- (void)exitGA:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;
- (void)sendEvent:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;
- (void)sendView:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;
- (void)setCustom:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;
- (void)sendTiming:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;
- (void)sendException:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;

@end
