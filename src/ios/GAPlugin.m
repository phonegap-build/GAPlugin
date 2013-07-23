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
- (void) initGA:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString    *callbackId = [arguments pop];
    NSString    *accountID = [arguments objectAtIndex:0];
    NSInteger   dispatchPeriod = [[arguments objectAtIndex:1] intValue];

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

-(void) exitGA: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString    *callbackId = [arguments pop];

    if (inited)
        [[[GAI sharedInstance] defaultTracker] close];
	
    [self successWithMessage:@"exitGA" toID:callbackId];
}

- (void) trackEvent:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString        *callbackId = [arguments pop];
    NSString        *category = [arguments objectAtIndex:0];
    NSString        *eventAction = [arguments objectAtIndex:1];
    NSString        *eventLabel = [arguments objectAtIndex:2];
    NSInteger       eventValue = [[arguments objectAtIndex:3] intValue];
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

- (void) trackPage:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString            *callbackId = [arguments pop];
    NSString            *pageURL = [arguments objectAtIndex:0];

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

- (void) setVariable:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString            *callbackId = [arguments pop];
    NSInteger           index = [[arguments objectAtIndex:0] intValue];
    NSString            *value = [arguments objectAtIndex:1];
    
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

- (void) setDimension:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString            *callbackId = [arguments pop];
    NSInteger           index = [[arguments objectAtIndex:0] intValue];
    NSString            *value = [arguments objectAtIndex:1];
    
    if (inited)
    {
        NSError *error = nil;
        BOOL    result = [[[GAI sharedInstance] defaultTracker] setCustom:index dimension:value];
        
        if (result)
    		[self successWithMessage:[NSString stringWithFormat:@"setDimension: index = %d, value = %@;", index, value] toID:callbackId];
        else
            [self failWithMessage:@"setDimension failed" toID:callbackId withError:error];
    }
    else
        [self failWithMessage:@"setDimension failed - not initialized" toID:callbackId withError:nil];
}

- (void) setMetric:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString    *callbackId = [arguments pop];
    NSInteger   index = [[arguments objectAtIndex:0] intValue];
    NSNumber    *value = [arguments objectAtIndex:1];
    
    if (inited)
    {
        NSError *error = nil;
        BOOL    result = [[[GAI sharedInstance] defaultTracker] setCustom:index metric:value];
        
        if (result)
    		[self successWithMessage:[NSString stringWithFormat:@"setMetric: index = %d, value = %@;", index, value] toID:callbackId];
        else
            [self failWithMessage:@"setMetric failed" toID:callbackId withError:error];
    }
    else
        [self failWithMessage:@"setVariable failed - not initialized" toID:callbackId withError:nil];
}


- (void) trackTransaction:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
    NSString  *callbackId = [arguments pop];
    NSString  *transId = [arguments objectAtIndex:0];
    int64_t   orderTotal = (int64_t)([[arguments objectAtIndex:1] doubleValue] * 1000000);
	NSString  *currencyCode = [arguments objectAtIndex:2]; // Not yet available in iOS GA SDK
    NSArray   *items = [arguments objectAtIndex:3];
    
    if(inited){
        NSError *error = nil;
        GAITransaction *transaction =
        [GAITransaction transactionWithId:transId            // (NSString) Transaction ID, should be unique.
                          withAffiliation:@"In-App Store"];       // (NSString) Affiliation
        transaction.shippingMicros = (int64_t)(0);                   // (int64_t) Total shipping (in micros)
        transaction.revenueMicros = (orderTotal);       // (int64_t) Total revenue (in micros)
        
        for (NSDictionary *item in items ){
            NSString* sku = [item objectForKey:@"sku"];
            NSString* name = [item objectForKey:@"name"];
            NSString* category = [item objectForKey:@"category"];
            int64_t price = (int64_t)([[item objectForKey:@"price"] doubleValue] * 1000000);
            NSInteger quantity = [[item objectForKey:@"quantity"] integerValue];
            
            [transaction addItemWithCode:sku        // (NSString) Product SKU
                                   name:name        // (NSString) Product name
                               category:category    // (NSString) Product category
                            priceMicros:price       // (int64_t)  Product price (in micros)
                               quantity:quantity];  // (NSInteger)  Product quantity
        }
        
        BOOL result = [[GAI sharedInstance].defaultTracker sendTransaction:transaction]; // Send the transaction
        if(result)
            [self successWithMessage:[NSString stringWithFormat:@"trackTransaction: transactionId = %@ OK", transId] toID:callbackId];
        else
            [self failWithMessage:@"trackTransaction failed" toID:callbackId withError:error];
    } else {
        [self failWithMessage:@"trackTransaction failed - not initialized" toID:callbackId withError:nil];
    }
    
    [self failWithMessage:@"trackTransaction not implemented yet" toID:callbackId withError:nil];
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
    [super dealloc];
}

@end
