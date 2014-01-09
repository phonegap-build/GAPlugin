#import "GAPlugin.h"
#import "AppDelegate.h"

@implementation GAPlugin
- (void) initGA:(CDVInvokedUrlCommand*)command
{
    @try {
        NSString    *callbackId = command.callbackId;
        NSString    *accountID = [command.arguments objectAtIndex:0];
        NSInteger   dispatchPeriod = [[command.arguments objectAtIndex:1] intValue];

        [GAI sharedInstance].trackUncaughtExceptions = NO;
        // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
        [GAI sharedInstance].dispatchInterval = dispatchPeriod;
        // Optional: set debug to YES for extra debugging information.
        //[GAI sharedInstance].debug = YES;
        // Create tracker instance.
        [[GAI sharedInstance] trackerWithTrackingId:accountID];
        // Set the appVersion equal to the CFBundleVersion
        [GAI sharedInstance].defaultTracker.appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        inited = YES;

        [self successWithMessage:[NSString stringWithFormat:@"initGA: accountID = %@; Interval = %d seconds",accountID, dispatchPeriod] toID:callbackId];    }
    @catch (NSException *exception) {
        NSLog(@"GAPlugin.initGA: %@", [exception reason]);
    }
    @finally {
    }
}

-(void) exitGA:(CDVInvokedUrlCommand*)command
{
    NSString *callbackId = command.callbackId;

    if (inited)
        [[[GAI sharedInstance] defaultTracker] close];

    [self successWithMessage:@"exitGA" toID:callbackId];
}

- (void) trackEvent:(CDVInvokedUrlCommand*)command
{
    @try {
        NSString        *callbackId = command.callbackId;
        NSString        *category = [command.arguments objectAtIndex:0];
        NSString        *eventAction = [command.arguments objectAtIndex:1];
        NSString        *eventLabel = [command.arguments objectAtIndex:2];
        NSString        *eventValueString = [command.arguments objectAtIndex:3];

        NSError         *error = nil;
        BOOL result;

        // Check if the eventValueString is valid
        if ([eventValueString isEqual: [NSNull null]]) {
            eventValueString = @"";
        }

        //NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        //[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        //NSNumber *eventValue = [formatter numberFromString:eventValueString];

        if (inited) {
            if ([eventValueString length] > 0) {
                result = [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:category withAction:eventAction withLabel:eventLabel withValue:[NSNumber numberWithInt:[eventValueString intValue]]];
            } else {
                result = [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:category withAction:eventAction withLabel:eventLabel withValue:nil];
            }
            if (result)
                [self successWithMessage:[NSString stringWithFormat:@"trackEvent: category = %@; action = %@; label = %@; value = %@", category, eventAction, eventLabel, eventValueString] toID:callbackId];
            else
                [self failWithMessage:@"trackEvent failed" toID:callbackId withError:error];
        }
        else
            [self failWithMessage:@"trackEvent failed - not initialized" toID:callbackId withError:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"GAPlugin.trackEvent: %@", [exception reason]);
    }
    @finally {
    }
}

- (void) trackPage:(CDVInvokedUrlCommand*)command
{
    @try {
        NSString            *callbackId = command.callbackId;
        NSString            *pageURL = [command.arguments objectAtIndex:0];

        if (inited)
        {
            NSError *error = nil;
            BOOL    result = [[[GAI sharedInstance] defaultTracker] sendView:pageURL];

            if (result)
                [self successWithMessage:[NSString stringWithFormat:@"trackPage: url = %@", pageURL] toID:callbackId];
            else
                [self failWithMessage:@"trackPage failed" toID:callbackId withError:error];
        }
        else
            [self failWithMessage:@"trackPage failed - not initialized" toID:callbackId withError:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"GAPlugin.trackPage: %@", [exception reason]);
    }
    @finally {
    }
}

- (void) trackException:(CDVInvokedUrlCommand *)command
{
    @try {
        NSString            *callbackId = command.callbackId;
        NSString            *exDescription = [command.arguments objectAtIndex:0];
        BOOL isFatal = [[command.arguments objectAtIndex:1] boolValue];

        if (inited)
        {
            NSError *error = nil;
            BOOL    result = [[[GAI sharedInstance] defaultTracker] sendException:isFatal withDescription:exDescription];

            if (result)
                [self successWithMessage:[NSString stringWithFormat:@"trackException: description = %@", exDescription] toID:callbackId];
            else
                [self failWithMessage:@"trackException failed" toID:callbackId withError:error];
        }
        else
            [self failWithMessage:@"trackException failed - not initialized" toID:callbackId withError:nil];    }
    @catch (NSException *exception) {
        NSLog(@"GAPlugin.trackException: %@", [exception reason]);
    }
    @finally {
    }
}

- (void) setVariable:(CDVInvokedUrlCommand*)command
{
    @try {
        NSString            *callbackId = command.callbackId;
        NSInteger           index = [[command.arguments objectAtIndex:0] intValue];
        NSString            *value = [command.arguments objectAtIndex:1];

        if (inited)
        {
            NSError *error = nil;
            BOOL    result = [[[GAI sharedInstance] defaultTracker] setCustom:index dimension:value];

            if (result)
                [self successWithMessage:[NSString stringWithFormat:@"setVariable: index = %d, value = %@;", index, value] toID:callbackId];
            else
                [self failWithMessage:@"setVariable failed" toID:callbackId withError:error];
        }
        else
            [self failWithMessage:@"setVariable failed - not initialized" toID:callbackId withError:nil];    }
    @catch (NSException *exception) {
        NSLog(@"GAPlugin.setVariable: %@", [exception reason]);
    }
    @finally {
    }
}

-(void)successWithMessage:(NSString *)message toID:(NSString *)callbackID
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];

    [self writeJavascript:[commandResult toSuccessCallbackString:callbackID]];
}

-(void)failWithMessage:(NSString *)message toID:(NSString *)callbackID withError:(NSError *)error
{
    NSString        *errorMessage = (error) ? [NSString stringWithFormat:@"%@ - %@", message, [error localizedDescription]] : message;
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];

    [self writeJavascript:[commandResult toErrorCallbackString:callbackID]];
}

-(void)dealloc
{
    [[[GAI sharedInstance] defaultTracker] close];
   // [super dealloc];
}

@end