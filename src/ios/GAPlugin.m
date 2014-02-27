#import "GAPlugin.h"
#import "AppDelegate.h"

@implementation GAPlugin
- (void) initGA:(CDVInvokedUrlCommand*)command
{
    NSString    *callbackId = command.callbackId;
    NSString    *accountID = [command.arguments objectAtIndex:0];
    NSInteger   dispatchPeriod = [[command.arguments objectAtIndex:1] intValue];

    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = dispatchPeriod;
    // Optional: set debug to YES for extra debugging information.
    //[GAI sharedInstance].debug = YES;
    // Create tracker instance.
    [[GAI sharedInstance] trackerWithTrackingId:accountID];
    // Set the appVersion equal to the CFBundleVersion
    [GAI sharedInstance].defaultTracker.appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    inited = YES;

    [self successWithMessage:[NSString stringWithFormat:@"initGA: accountID = %@; Interval = %d seconds",accountID, dispatchPeriod] toID:callbackId];
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
    NSString        *callbackId = command.callbackId;
    NSString        *category = [command.arguments objectAtIndex:0];
    NSString        *eventAction = [command.arguments objectAtIndex:1];
    NSString        *eventLabel = [command.arguments objectAtIndex:2];
    NSInteger       eventValue = [[command.arguments objectAtIndex:3] intValue];
    NSError         *error = nil;

    if (inited)
    {
        BOOL result = [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:category withAction:eventAction withLabel:eventLabel withValue:[NSNumber numberWithInt:eventValue]];
        if (result)
            [self successWithMessage:[NSString stringWithFormat:@"trackEvent: category = %@; action = %@; label = %@; value = %d", category, eventAction, eventLabel, eventValue] toID:callbackId];
        else
            [self failWithMessage:@"trackEvent failed" toID:callbackId withError:error];
    }
    else
        [self failWithMessage:@"trackEvent failed - not initialized" toID:callbackId withError:nil];
}

- (void) trackPage:(CDVInvokedUrlCommand*)command
{
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

- (void) trackTransaction:(CDVInvokedUrlCommand *)command
{
    NSString            *callbackId = command.callbackId;
    NSDictionary *jsonObj = [command.arguments objectAtIndex:0];
    
    if (inited)
    {
       NSError *error = nil;
        
        GAITransaction *transaction = [GAITransaction transactionWithId:[jsonObj objectForKey:@"transactionId"]            // (NSString) Transaction ID, should be unique.
            withAffiliation:[jsonObj objectForKey:@"affiliation"]];      // (NSString) Affiliation
        
        transaction.taxMicros = [[jsonObj objectForKey:@"totalTax"] longLongValue];           // (int64_t) Total tax (in micros)
        transaction.shippingMicros = [[jsonObj objectForKey:@"shippingCost"] longLongValue];                   // (int64_t) Total shipping (in micros)
        transaction.revenueMicros = [[jsonObj objectForKey:@"orderTotal"] longLongValue];       // (int64_t) Total revenue (in micros)
        
        NSArray *items = [jsonObj objectForKey:@"items"];
        for (NSDictionary *item in items) {
            [transaction addItemWithCode:[item objectForKey:@"sku"]                         // (NSString) Product SKU
                               name:[item objectForKey:@"name"]             // (NSString) Product name
                           category:[item objectForKey:@"category"]               // (NSString) Product category
                        priceMicros:[[item objectForKey:@"price"] longLongValue]        // (int64_t)  Product price (in micros)
                           quantity:[[item objectForKey:@"quantity"] longLongValue]];                              // (NSInteger)  Product quantity
        }
        BOOL result = [[[GAI sharedInstance] defaultTracker] sendTransaction:transaction];
        
        if (result)
            [self successWithMessage:[NSString stringWithFormat:@"trackTransaction: url = %@", jsonObj] toID:callbackId];
        else
            [self failWithMessage:@"trackTransaction failed" toID:callbackId withError:error];
    }
    else
        [self failWithMessage:@"trackTransaction failed - not initialized" toID:callbackId withError:nil];
}


- (void) trackCaughtException:(CDVInvokedUrlCommand *)command
{
    NSString            *callbackId = command.callbackId;
    NSString            *message = [command.arguments objectAtIndex:0];
    
    if (inited)
    {
        NSError *error = nil;
        BOOL    result = [[[GAI sharedInstance] defaultTracker] sendException:NO // Boolean indicates non-fatal exception.
                                                                    withDescription:message];
        
        if (result)
            [self successWithMessage:[NSString stringWithFormat:@"trackCaughtException: message = %@", message] toID:callbackId];
        else
            [self failWithMessage:@"trackCaughtException failed" toID:callbackId withError:error];
    }
    else
        [self failWithMessage:@"trackCaughtException failed - not initialized" toID:callbackId withError:nil];
}

- (void) trackUncaughtException:(CDVInvokedUrlCommand *)command
{
    NSString            *callbackId = command.callbackId;
    NSString            *message = [command.arguments objectAtIndex:0];
    
    if (inited)
    {
        NSError *error = nil;
        BOOL    result = [[[GAI sharedInstance] defaultTracker] sendException:YES // Boolean indicates fatal exception.
                                                                    withDescription:message];
        
        if (result)
            [self successWithMessage:[NSString stringWithFormat:@"trackUncaughtException: message = %@", message] toID:callbackId];
        else
            [self failWithMessage:@"trackUncaughtException failed" toID:callbackId withError:error];
    }
    else
        [self failWithMessage:@"trackUncaughtException failed - not initialized" toID:callbackId withError:nil];
}


- (void) setVariable:(CDVInvokedUrlCommand*)command
{
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
        [self failWithMessage:@"setVariable failed - not initialized" toID:callbackId withError:nil];
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