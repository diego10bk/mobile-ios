//
//  eXoFullScreenView.m
//  eXo Platform
//
//  Created by Nguyen Khac Trung on 11/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "eXoFullScreenView.h"
#import "defines.h"

#define IOS_5 5

@implementation eXoFullScreenView

@synthesize orientation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        first = YES;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle




// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.wantsFullScreenLayout = YES;
    
    // because on iOS 5, when init class the function willAnimateRotationToInterfaceOrientation don't call
    
    #if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_4_3
        first = NO;
    #elif 
        first = YES;
    #endif
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    // if the first time presentModalViewController, return
    if(first){
        first = NO;
        return;
    }
    // when device rotate
    self.orientation = interfaceOrientation;
    [[NSNotificationCenter defaultCenter] postNotificationName:EXO_NOTIFICATION_WEBVIEW_FULLSCREEN object:self];
}
@end
