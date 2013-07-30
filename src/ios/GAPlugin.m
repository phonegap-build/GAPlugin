//
//  GAPlugin.m
//  GA
//
//  Created by Bob Easterday on 10/9/12.
//  Copyright (c) 2012 Adobe Systems, Inc. All rights reserved.
//

#import "GAPlugin.h"
#import "AppDelegate.h"

@implementation GAPlugin
- (void)initGA:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
    NSString *callbackId = [arguments pop];
    NSString *accountID = [arguments objectAtIndex:0];
    NSInteger dispatchPeriod = [[arguments objectAtIndex:1] intValue];

    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = dispatchPeriod;
    // Optional: set debug to YES for extra debugging information.
    // [GAI sharedInstance].debug = YES;
    // Create tracker instance.
    [[GAI sharedInstance] trackerWithTrackingId:accountID];
    // Set the appVersion equal to the CFBundleVersion
    [GAI sharedInstance].defaultTracker.appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    inited = YES;

    [self successWithMessage:[NSString stringWithFormat:@"initGA: accountID = %@; Interval = %d seconds", accountID, dispatchPeriod] toID:callbackId];
}

- (void)exitGA:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
    NSString *callbackId = [arguments pop];

    if (inited)
    {
        [[[GAI sharedInstance] defaultTracker] close];
    }

    [self successWithMessage:@"exitGA" toID:callbackId];
}

- (void)sendEvent:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
    NSString *callbackId = [arguments pop];
    NSString *category = [arguments objectAtIndex:0];
    NSString *eventAction = [arguments objectAtIndex:1];
    NSString *eventLabel = [arguments objectAtIndex:2];
    NSInteger eventValue = [[arguments objectAtIndex:3] intValue];
    NSError *error = nil;

    if (inited)
    {
        BOOL result = [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:category withAction:eventAction withLabel:eventLabel withValue:[NSNumber numberWithInt:eventValue]];
        if (result)
        {
            [self successWithMessage:[NSString stringWithFormat:@"sendEvent: category = %@; action = %@; label = %@; value = %d", category, eventAction, eventLabel, eventValue] toID:callbackId];
        }
        else
        {
            [self failWithMessage:@"sendEvent failed" toID:callbackId withError:error];
        }
    }
    else
    {
        [self failWithMessage:@"sendEvent failed - not initialized" toID:callbackId withError:nil];
    }
}

- (void)sendView:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
    NSString *callbackId = [arguments pop];
    NSString *pageURL = [arguments objectAtIndex:0];

    if (inited)
    {
        NSError *error = nil;
        BOOL result = [[[GAI sharedInstance] defaultTracker] sendView:pageURL];

        if (result)
        {
            [self successWithMessage:[NSString stringWithFormat:@"sendView: url = %@", pageURL] toID:callbackId];
        }
        else
        {
            [self failWithMessage:@"sendView failed" toID:callbackId withError:error];
        }
    }
    else
    {
        [self failWithMessage:@"sendView failed - not initialized" toID:callbackId withError:nil];
    }
}

- (void)setCustom:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
    NSString *callbackId = [arguments pop];
    NSInteger index = [[arguments objectAtIndex:0] intValue];
    NSString *value = [arguments objectAtIndex:1];

    if (inited)
    {
        NSError *error = nil;
        BOOL result = [[[GAI sharedInstance] defaultTracker] setCustom:index dimension:value];

        if (result)
        {
            [self successWithMessage:[NSString stringWithFormat:@"setCustom: index = %d, value = %@;", index, value] toID:callbackId];
        }
        else
        {
            [self failWithMessage:@"setCustom failed" toID:callbackId withError:error];
        }
    }
    else
    {
        [self failWithMessage:@"setCustom failed - not initialized" toID:callbackId withError:nil];
    }
}

- (void)sendTiming:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
    NSString *callbackId = [arguments pop];

    NSString *category = [arguments objectAtIndex:0];
    NSInteger time = [[arguments objectAtIndex:1] intValue];
    NSString *name = [arguments objectAtIndex:2];
    NSString *label = [arguments objectAtIndex:3];



    if (inited)
    {
        NSError *error = nil;
        BOOL result = [[[GAI sharedInstance] defaultTracker] sendTimingWithCategory:category withValue:time withName:name withLabel:label];

        if (result)
        {
            [self successWithMessage:[NSString stringWithFormat:@"sendTimingWithCategory: category = %@, time = %d, name = %@, label = %@;", category, time, name, label] toID:callbackId];
        }
        else
        {
            [self failWithMessage:@"sendTimingWithCategory failed" toID:callbackId withError:error];
        }
    }
    else
    {
        [self failWithMessage:@"sendTimingWithCategory failed - not initialized" toID:callbackId withError:nil];
    }
}

- (void)sendException:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
    NSString *callbackId = [arguments pop];

    NSString *message = [arguments objectAtIndex:0];
    Boolean fatal = [[arguments objectAtIndex:1] boolValue];




    if (inited)
    {
        NSError *error = nil;
        BOOL result = [[[GAI sharedInstance] defaultTracker] sendException:fatal withDescription:message];

        if (result)
        {
            [self successWithMessage:[NSString stringWithFormat:@"sendException: message = %@;", message] toID:callbackId];
        }
        else
        {
            [self failWithMessage:@"sendException failed" toID:callbackId withError:error];
        }
    }
    else
    {
        [self failWithMessage:@"sendException failed - not initialized" toID:callbackId withError:nil];
    }
}

- (void)successWithMessage:(NSString *)message toID:(NSString *)callbackID
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];

    [self writeJavascript:[commandResult toSuccessCallbackString:callbackID]];
}

- (void)failWithMessage:(NSString *)message toID:(NSString *)callbackID withError:(NSError *)error
{
    NSString *errorMessage = (error) ? [NSString stringWithFormat:@"%@ - %@", message, [error localizedDescription]] : message;
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];

    [self writeJavascript:[commandResult toErrorCallbackString:callbackID]];
}

- (void)dealloc
{
    [[[GAI sharedInstance] defaultTracker] close];
}

@end
