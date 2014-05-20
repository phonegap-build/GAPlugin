#import "GAPlugin.h"
#import "AppDelegate.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@implementation GAPlugin

- (void) initGA:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = command.callbackId;
    NSString* accountID = [command.arguments objectAtIndex:0];
    NSInteger dispatchPeriod = [[command.arguments objectAtIndex:1] intValue];

    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = dispatchPeriod;
    // Optional: set debug to YES for extra debugging information.
    //[GAI sharedInstance].debug = YES;
    // Create tracker instance.
    [[GAI sharedInstance] trackerWithTrackingId:accountID];
    inited = YES;

    [self successWithMessage:[NSString stringWithFormat:@"initGA: accountID = %@; Interval = %ld seconds",accountID, (long)dispatchPeriod] toID:callbackId];
}

- (void)addCustomDimensionsToTracker: (id<GAITracker>)tracker
{
    if (_customDimensions) {
        for (NSString* key in _customDimensions) {
            NSString* value = [_customDimensions objectForKey:key];
            
            /* NSLog(@"Setting tracker dimension slot %@: <%@>", key, value); */
            [tracker set:[GAIFields customDimensionForIndex:[key intValue]]
                   value:value];
        }
    }
}

- (void) setVariable:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* key = [command.arguments objectAtIndex:0];
    NSString* value = [command.arguments objectAtIndex:1];
    
    if ( ! _customDimensions) {
        _customDimensions = [[NSMutableDictionary alloc] init];
    }
    
    _customDimensions[key] = value;
    [self addCustomDimensionsToTracker:[[GAI sharedInstance] defaultTracker]];
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) exitGA:(CDVInvokedUrlCommand*)command
{
    if (inited) {
        [[GAI sharedInstance] dispatch];
    }

    [self successWithMessage:@"exitGA" toID:command.callbackId];
}

- (void) trackEvent:(CDVInvokedUrlCommand*)command
{
    @try  {
        NSString* category = [command.arguments objectAtIndex:0];
        NSString* eventAction = [command.arguments objectAtIndex:1];
        NSString* eventLabel = [command.arguments objectAtIndex:2];
        id        eventValueObject = [command.arguments objectAtIndex:3];
        NSNumber* eventValue = nil;
        
        if (eventValueObject != [NSNull null]) {
            eventValue = [NSNumber numberWithInteger:[eventValueObject integerValue]];
        }
        
        if (inited) {
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            
            [self addCustomDimensionsToTracker:tracker];
            
            [tracker send:[[GAIDictionaryBuilder
                            createEventWithCategory: category //required
                            action: eventAction //required
                            label: eventLabel
                            value: eventValueObject] build]];
            
            [self successWithMessage:[NSString stringWithFormat:@"trackEvent: category = %@; action = %@; label = %@; value = %d", category, eventAction, eventLabel, [eventValue intValue]] toID:command.callbackId];
            
        } else {
            [self failWithMessage:@"trackEvent failed - not initialized" toID:command.callbackId withError:nil];
        }
        
    } @catch (NSException* exception) {
        [self failWithMessage:[NSString stringWithFormat:@"trackEvent failed - exception name: %@, reason: %@", exception.name, exception.reason] toID:command.callbackId withError:nil];
    }
}

- (void) trackPage:(CDVInvokedUrlCommand*)command
{
    NSString* pageURL = [command.arguments objectAtIndex:0];

    if (inited) {
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

        [tracker set:kGAIScreenName value:pageURL];
        [tracker send:[[GAIDictionaryBuilder createAppView]  build]];

        [self successWithMessage:[NSString stringWithFormat:@"trackPage: url = %@", pageURL] toID:command.callbackId];
    } else {
        [self failWithMessage:@"trackPage failed - not initialized" toID:command.callbackId withError:nil];
    }
}

- (void) successWithMessage:(NSString *)message toID:(NSString *)callbackID
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

- (void) failWithMessage:(NSString *)message toID:(NSString *)callbackID withError:(NSError *)error
{
    NSString        *errorMessage = (error) ? [NSString stringWithFormat:@"%@ - %@", message, [error localizedDescription]] : message;
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];

    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

- (void)dealloc
{
    [[GAI sharedInstance] dispatch];
}

@end