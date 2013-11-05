//
//  ExoWeemoHandler.m
//  eXo Platform
//
//  Created by vietnq on 10/3/13.
//  Copyright (c) 2013 eXoPlatform. All rights reserved.
//

#import "ExoWeemoHandler.h"
#import "AppDelegate_iPad.h"
#import "MenuViewController.h"
#import "RootViewController.h"
#import "AppDelegate_iPhone.h"

//in seconds
#define CHECK_CONNECTION_PERIOD 60
#define DELAY_GET_STATUS 5

@implementation ExoWeemoHandler {
    UIAlertView *incomingCall;
}
@synthesize userId = _userId;
@synthesize displayName = _displayName;
@synthesize activeCallVC = _activeCallVC;
@synthesize isConnectedToExo = _isConnectedToExo;
@synthesize delegate = _delegate;

+ (ExoWeemoHandler*)sharedInstance
{
	static ExoWeemoHandler *sharedInstance;
	@synchronized(self)
	{
		if(!sharedInstance)
		{
			sharedInstance = [[ExoWeemoHandler alloc] init];
        }
		return sharedInstance;
	}
	return sharedInstance;
}


- (void)connect
{
    //user is connected to Weemo after connecting to exo platform,
    //so isConnectedToExo is YES at this stage
    self.isConnectedToExo = YES;
    
    NSError *error;
    [Weemo WeemoWithAppID:URLReferer andDelegate:self error:&error];
}

- (void)disconnect
{
    self.isConnectedToExo = NO;
    
    @try {
        [[Weemo instance] disconnect];
    }
    @catch (NSException *exception) {
        NSLog(@"excetion while disconnecting Weemo: %@",exception);
    }
}
- (void)dealloc
{
    [super dealloc];
    [_displayName release];
    _displayName = nil;
    [_activeCallVC release];
    _activeCallVC = nil;
}

#pragma mark GUI integration

- (void)addCallView
{
	NSLog(@">>>> addCallView ");
	if(!_activeCallVC) {
        [self createCallView];
    }
    
    UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    
    if(_activeCallVC.view.superview == rootVC.view) {
        return;
    }
        
    _activeCallVC.view.frame =  CGRectMake(0., 0., rootVC.view.frame.size.width, rootVC.view.frame.size.height);
    
	[rootVC.view addSubview:_activeCallVC.view];
    
    
}

- (void)removeCallView
{
    [_activeCallVC removeFromParentViewController];
    [_activeCallVC.view removeFromSuperview];
    _activeCallVC = nil;
}

- (void)createCallView
{
	NSLog(@">>>> createCallView");
		
    if(_activeCallVC) {
        _activeCallVC.call = [[Weemo instance] activeCall];
        return;
    }
    
    BOOL isIpad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;

    _activeCallVC = [[CallViewController alloc] initWithNibName:isIpad ? @"CallViewController_iPad" : @"CallViewController_iPhone" bundle:nil];
	
    _activeCallVC.call = [[Weemo instance] activeCall];
    
    [[[Weemo instance] activeCall] setDelegate:_activeCallVC];
    
    UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    
    [rootVC addChildViewController:_activeCallVC];

}

- (void)receiveCall
{
    [self createCallView];
    [self addCallView];
    [self setCallStatus:[[[Weemo instance] activeCall]callStatus]];
    [[[Weemo instance] activeCall]resume];
}

- (void)setCallStatus:(int)newStatus
{
	dispatch_async(dispatch_get_main_queue(), ^{
		switch (newStatus) {
			case CALLSTATUS_ACTIVE:
			{
				NSLog(@">>> Call Active");
				[self createCallView];
				[self addCallView];
			}break;
			case CALLSTATUS_PROCEEDING:
			{
				NSLog(@">>>> Call Proceeding");
				[self createCallView];
			}break;
			case CALLSTATUS_INCOMING:
			{
				NSLog(@">>>> Call Incoming");
				[self createCallView];
//				[self addCallView];
			}break;
			case CALLSTATUS_ENDED:
			{
				[self removeCallView];
				
			}break;
			default:
			{
				
			}
            break;
		}
	});
}

#pragma mark WeemoDelegate methods

- (void)weemoDidConnect:(NSError *)error
{
    if(error) {
        NSLog(@">>>WeemoHandler: %@", [error description]);
    } else {
        [[Weemo instance] authenticateWithToken:[NSString stringWithFormat:@"weemo%@",self.userId] andType:USERTYPE_INTERNAL];
    }
}

- (void)weemoDidAuthenticate:(NSError *)error
{
    if(!error) {
        //TODO: set display name
        [[Weemo instance] setDisplayName:self.displayName];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //update the indicator for authentication status
            [self updateWeemoIndicator:YES];
        });
    } else {
        NSLog(@"%@", [error description]);
    }
}

- (void)weemoDidDisconnect:(NSError *)error
{
    if(error) {
      NSLog(@">>>WeemoHandler: %@", [error description]);
    } else {
        NSLog(@">>>WeemoHandler: weemo did disconnect");
    }
    
    //only update the indicator and auto-reconnect if user is currently logged in
    if(self.isConnectedToExo)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            //update the indicator for authentication status
            [self updateWeemoIndicator:NO];
        });
        
        [self connect];
    }
}

- (void)weemoCallCreated:(WeemoCall*)call
{
    
	NSLog(@">>>> Controller callCreated: 0x%X", [call callStatus]);
    	
    if ([call callStatus] == CALLSTATUS_INCOMING) {
        
        if([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
            //if the app is in background, display a local notification
            UILocalNotification *notif = [[UILocalNotification alloc] init];
            notif.alertBody = [NSString stringWithFormat:Localize(@"Someone is calling"), [call contactID]];
            notif.alertAction = Localize(@"Pick-up");
            notif.soundName = UILocalNotificationDefaultSoundName;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] presentLocalNotificationNow:notif];
                [notif release];
            });
            
        } else {
            
            incomingCall = [[UIAlertView alloc]initWithTitle:Localize(@"Incoming Call")
                                                     message:[NSString stringWithFormat:Localize(@"Someone is calling"), [call contactID]]
                                                    delegate:self
                                           cancelButtonTitle:Localize(@"Close")
                                           otherButtonTitles:Localize(@"Pick-up"), nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [incomingCall show];
            });
        }
		
    } else {
        [self setCallStatus:[call callStatus]];
    }
}


- (void)weemoCallEnded:(WeemoCall *)call
{
    [self addToCallHistory:call];
    
    dispatch_async(dispatch_get_main_queue(), ^{
		[self removeCallView];
		[incomingCall dismissWithClickedButtonIndex:1 animated:YES];
		incomingCall = nil;
	});
}

- (void)weemoContact:(NSString *)contactID canBeCalled:(BOOL)canBeCalled
{
    if(_delegate)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate weemoHandler:self updateUIWithStatus:canBeCalled ofContact:contactID];
            _delegate = nil;
        });
    }
}

#pragma mark - dealing with the incoming call
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView == incomingCall)
    {
        if (buttonIndex == 1)
        {
            //user took the call
            [self receiveCall];
        }
        else
        {
            //user hangup
            [self removeCallView];
            [[[Weemo instance] activeCall]hangup];
        }
    }
}

#pragma mark Call History
- (void) addToCallHistory:(WeemoCall *)call
{
    //save call history
    CallHistory *entry = [[CallHistory alloc] init];
    NSString *contactID = call.contactID;
    
    if([contactID hasPrefix:@"weemo"])
    {
        contactID = [contactID substringFromIndex:[@"weemo" length]];
    }
    
    entry.caller = contactID;
    entry.date = [[NSDate alloc] init];
    entry.direction = ([call callStatus] == CALLSTATUS_INCOMING) ? 0 : 1;

    CallHistoryManager *historyManager = [CallHistoryManager sharedInstance];
    [historyManager.history addObject:entry];
    [historyManager saveHistory];
}

#pragma mark Update Weemo status indicator

- (void) updateWeemoIndicator:(BOOL)isConnectedToWeemo
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        AppDelegate_iPad *ipadDelegate = [AppDelegate_iPad instance];
        
        RootViewController *rootVC = ipadDelegate.rootViewController;
        if(rootVC)
        {
            MenuViewController *menuVC = rootVC.menuViewController;
            
            [menuVC updateCellForVideoCall:isConnectedToWeemo];
        }
    }
    else
    {
        AppDelegate_iPhone *iphoneDelegate = [AppDelegate_iPhone instance];
        HomeSidebarViewController_iPhone *homeVC = iphoneDelegate.homeSidebarViewController_iPhone;
        if(homeVC)
        {
            [homeVC updateCellForVideoCall:isConnectedToWeemo];
        }
    }
}
@end
