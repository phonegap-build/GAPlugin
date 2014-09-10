#import "GAPlugin.h"
#import "AppDelegate.h"

@implementation GAPlugin
- (void) initGA:(CDVInvokedUrlCommand*)command
{
    @try {
        NSString    *callbackId = command.callbackId;
        NSString    *accountID = [command.arguments objectAtIndex:0];
        NSInteger   dispatchPeriod = [[command.arguments objectAtIndex:1] intValue];

        [GAI sharedInstance].trackUncaughtExceptions = YES;

        // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
        [GAI sharedInstance].dispatchInterval = dispatchPeriod;

        // Optional: set Logger to VERBOSE for debug information.
        // [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];

        // Create tracker instance.
        [[GAI sharedInstance] trackerWithTrackingId:accountID];


        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        if (tracker != nil) {
            // Set the appVersion equal to the CFBundleVersion
            [[[GAI sharedInstance] defaultTracker] set:kGAIAppVersion value:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];

            inited = YES;

            [self successWithMessage:[NSString stringWithFormat:@"initGA: accountID = %@; Interval = %d seconds",accountID, dispatchPeriod] toID:callbackId];

        } else {
            [self failWithMessage:@"initGA failed" toID:callbackId withError:nil];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"GAPlugin.initGA: %@", [exception reason]);
    }
    @finally {
    }
}

-(void) exitGA:(CDVInvokedUrlCommand*)command
{
    NSString *callbackId = command.callbackId;

//    if (inited) {
//        [[[GAI sharedInstance] defaultTracker] close];
//    }

    [self successWithMessage:@"exitGA" toID:callbackId];
}

- (void) trackEvent:(CDVInvokedUrlCommand*)command
{
    @try {
        NSString        *callbackId = command.callbackId;
        NSString        *category = [command.arguments objectAtIndex:0];
        NSString        *eventAction = [command.arguments objectAtIndex:1];
        NSString        *eventLabel = [command.arguments objectAtIndex:2];
        NSString        *eventValueString = [NSString stringWithFormat:@"%@", [command.arguments objectAtIndex:3] ];
        NSDictionary    *customDimension = [command.arguments objectAtIndex:4];
        
        // Check extra dimension value
        int intDimensionIndex = 0;
        NSNumber *dimensionIndex;
        NSString *dimensionValue;
        if (![customDimension isEqual: [NSNull null]]) {
            dimensionIndex = [customDimension objectForKey:@"index"];
            dimensionValue = [customDimension objectForKey:@"value"];
            if (dimensionIndex != nil && dimensionIndex != nil) {
                intDimensionIndex = [dimensionIndex intValue];
            }
        }
        
        // Check if the eventValueString is valid
        if ([eventValueString isEqual: [NSNull null]]) {
            eventValueString = @"";
        }

        if (inited) {
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            
            if (intDimensionIndex > 0) {
                [tracker set:[GAIFields customDimensionForIndex:intDimensionIndex] value:dimensionValue];
            }
            
            if ([eventValueString length] > 0) {
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                     action:eventAction
                                                     label:eventLabel
                                                     value:[NSNumber numberWithInt:[eventValueString intValue]]]
                               build]];
            } else {
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                     action:eventAction
                                                     label:eventLabel
                                                     value:nil]
                               build]];    // Event value
            }
            [self successWithMessage:[NSString stringWithFormat:@"trackEvent: category = %@; action = %@; label = %@; value = %@", category, eventAction, eventLabel, eventValueString] toID:callbackId];
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

        if (inited) {
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

            [tracker set:kGAIScreenName value:pageURL];

            [self successWithMessage:[NSString stringWithFormat:@"trackPage: url = %@", pageURL] toID:callbackId];
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

        if (inited) {
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

            [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:exDescription withFatal:[NSNumber numberWithBool:isFatal]] build]];

            [self successWithMessage:[NSString stringWithFormat:@"trackException: description = %@", exDescription] toID:callbackId];
        }
        else
            [self failWithMessage:@"trackException failed - not initialized" toID:callbackId withError:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"GAPlugin.trackException: %@", [exception reason]);
    }
    @finally {
    }
}

- (void) trackTransaction:(CDVInvokedUrlCommand*)command
{
    @try {
        NSString *callbackId = command.callbackId;
        NSString *transactionId = [command.arguments objectAtIndex:0];
        NSString *affiliation = [command.arguments objectAtIndex:1];
        NSString *name = [command.arguments objectAtIndex:2];
        NSString *sku = [command.arguments objectAtIndex:3];
        NSNumber *price = [NSNumber numberWithFloat:[[command.arguments objectAtIndex:4] floatValue]];
        NSNumber *quantity = [NSNumber numberWithInt:[[command.arguments objectAtIndex:5] intValue]];
        NSNumber *revenue = [NSNumber numberWithFloat:[[command.arguments objectAtIndex:6] floatValue]];
        NSString *currencyCode = [command.arguments objectAtIndex:7];

        if (inited) {
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

            [tracker send:[[GAIDictionaryBuilder createTransactionWithId:transactionId             // (NSString) Transaction ID
                                                             affiliation:affiliation         // (NSString) Affiliation
                                                                 revenue:revenue                  // (NSNumber) Order revenue (including tax and shipping)
                                                                     tax:@0.00F                  // (NSNumber) Tax
                                                                shipping:@0                      // (NSNumber) Shipping
                                                            currencyCode:currencyCode] build]];        // (NSString) Currency code

            [tracker send:[[GAIDictionaryBuilder createItemWithTransactionId:transactionId         // (NSString) Transaction ID
                                                                        name:name  // (NSString) Product Name
                                                                         sku:sku            // (NSString) Product SKU
                                                                    category:@"In-App-Purchase PEG"  // (NSString) Product category
                                                                       price:price               // (NSNumber)  Product price
                                                                    quantity:quantity                  // (NSInteger)  Product quantity
                                                                currencyCode:currencyCode] build]];    // (NSString) Currency code

            NSLog(@"Transaction tracked ok");

            [self successWithMessage:[NSString stringWithFormat:@"trackTransaction: transctionId = %@; item = %@", transactionId, name] toID:callbackId];
        }
        else
            [self failWithMessage:@"trackTransaction failed - not initialized" toID:callbackId withError:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"GAPlugin.trackTransaction: %@", [exception reason]);
    }
    @finally {
    }
}

- (void) setCustomDimension:(CDVInvokedUrlCommand*)command
{
    @try {
        NSString            *callbackId = command.callbackId;
        NSInteger           index = [[command.arguments objectAtIndex:0] intValue];
        NSString            *value = [command.arguments objectAtIndex:1];

        if (inited) {
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

            // Set the custom dimension value on the tracker using its index.
            [tracker set:[GAIFields customDimensionForIndex:index] value:value];

            [self successWithMessage:[NSString stringWithFormat:@"setVariable: index = %d, value = %@;", index, value] toID:callbackId];
        }
        else
            [self failWithMessage:@"setVariable failed - not initialized" toID:callbackId withError:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"GAPlugin.setVariable: %@", [exception reason]);
    }
    @finally {
    }
}

- (void) setCustomMetric:(CDVInvokedUrlCommand*)command
{
    @try {
        NSString            *callbackId = command.callbackId;
        NSInteger           index = [[command.arguments objectAtIndex:0] intValue];
        NSString            *value = [command.arguments objectAtIndex:1];
        
        if (inited) {
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            
            // Set the custom dimension value on the tracker using its index.
            [tracker set:[GAIFields customMetricForIndex:index] value:value];
            
            [self successWithMessage:[NSString stringWithFormat:@"setVariable: index = %d, value = %@;", index, value] toID:callbackId];
        }
        else
            [self failWithMessage:@"setVariable failed - not initialized" toID:callbackId withError:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"GAPlugin.setVariable: %@", [exception reason]);
    }
    @finally {
    }
}

- (void) setOptOut:(CDVInvokedUrlCommand*)command
{
    @try {
        NSString  *callbackId = command.callbackId;
        BOOL status = [[command.arguments objectAtIndex:1] boolValue];

        if (inited) {
            // Set the custom dimension value on the tracker using its index.
            [[GAI sharedInstance] setOptOut:status];

            [self successWithMessage:[NSString stringWithFormat:@"setOptOut: value = %d;", status] toID:callbackId];
        }
        else
            [self failWithMessage:@"setOptOut failed - not initialized" toID:callbackId withError:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"GAPlugin.setOptOut: %@", [exception reason]);
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


@end