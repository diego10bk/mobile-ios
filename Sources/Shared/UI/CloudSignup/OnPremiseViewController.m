//
//  OnPremiseViewController.m
//  eXo Platform
//
//  Created by vietnq on 6/17/13.
//  Copyright (c) 2013 eXoPlatform. All rights reserved.
//

#import "OnPremiseViewController.h"
#import "LanguageHelper.h"
#import "ApplicationPreferencesManager.h"
#import "defines.h"
#import "CloudUtils.h"
@interface OnPremiseViewController ()

@end

@implementation OnPremiseViewController
@synthesize usernameTf, serverUrlTf, passwordTf;
@synthesize hud = _hud;
@synthesize loginButton = _loginButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self configTextFields];
    self.loginButton.userInteractionEnabled = NO;
   
}

- (void)dealloc
{
    [super dealloc];
    [self.passwordTf release];
    [self.usernameTf release];
    [self.serverUrlTf release];
    [_hud release];
    [_loginButton release];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)login:(id)sender
{
    [self dismissKeyboards];
    [self.hud show];

    LoginProxy *loginProxy = [[LoginProxy alloc] initWithDelegate:self username:self.usernameTf.text password:self.passwordTf.text serverUrl:[CloudUtils correctServerUrl:self.serverUrlTf.text]];
    [loginProxy authenticate];
}

- (SSHUDView *)hud {
    if (!_hud) {
        _hud = [[SSHUDView alloc] initWithTitle:Localize(@"Loading")];
        _hud.completeImage = [UIImage imageNamed:@"19-check.png"];
        _hud.failImage = [UIImage imageNamed:@"11-x.png"];
    }
    return _hud;
}

#pragma mark LoginProxyDelegate methods
- (void)loginProxy:(LoginProxy *)proxy authenticateFailedWithError:(NSError *)error
{
    [self view].userInteractionEnabled = YES;
    [self.hud setHidden:YES];
    UIAlertView *alert = nil;
    
    if([error.domain isEqualToString:NSURLErrorDomain] && error.code == kCFURLErrorNotConnectedToInternet) { // network connection problem
        alert = [[[UIAlertView alloc] initWithTitle:Localize(@"Authorization") message:Localize(@"NetworkConnection") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] autorelease];
    } else if ([error.domain isEqualToString:NSURLErrorDomain] && (error.code == NSURLErrorCannotConnectToHost || error.code == NSURLErrorCannotFindHost || error.code == kCFURLErrorTimedOut)) { // cant connect to server
        alert = [[[UIAlertView alloc] initWithTitle:Localize(@"Authorization") message:Localize(@"InvalidServer") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] autorelease];
    } else if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorUserCancelledAuthentication) { // wrong username/password
        alert = [[[UIAlertView alloc] initWithTitle:Localize(@"Authorization") message:Localize(@"WrongUserNamePassword") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] autorelease];
    } else if ([error.domain isEqualToString:RKRestKitErrorDomain] && error.code == RKRequestBaseURLOfflineError) { //error getting platform info by restkit
        alert = [[[UIAlertView alloc] initWithTitle:Localize(@"Authorization") message:Localize(@"NetworkConnection") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] autorelease];
    } else if([error.domain isEqualToString:EXO_NOT_COMPILANT_ERROR_DOMAIN]) {
        alert = [[[UIAlertView alloc] initWithTitle:Localize(@"Error")
                                            message:Localize(@"NotCompliant")
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] autorelease];
        
    } else {
        alert = [[[UIAlertView alloc] initWithTitle:Localize(@"Authorization") message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] autorelease];
    }
    [alert show];
}

- (void)loginProxy:(LoginProxy *)proxy platformVersionCompatibleWithSocialFeatures:(BOOL)compatibleWithSocial withServerInformation:(PlatformServerVersion *)platformServerVersion
{
    self.view.userInteractionEnabled = YES;
    [self.hud completeAndDismissWithTitle:Localize(@"Success")];
    
    //add the server url to server list
    ApplicationPreferencesManager *appPref = [ApplicationPreferencesManager sharedInstance];
    [appPref addAndSetSelectedServer:proxy.serverUrl];
    
    //1 account is already configured, next time starting app, display authenticate screen
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:EXO_CLOUD_ACCOUNT_CONFIGURED];
}


#pragma mark UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self dismissKeyboards];
    if(textField == self.serverUrlTf) {
        [self.usernameTf becomeFirstResponder];
    } else if(textField == self.usernameTf) {
        [self.passwordTf becomeFirstResponder];
    } else if(textField == self.passwordTf) {
        if(self.passwordTf.text.length > 0 && self.serverUrlTf.text.length > 0 && self.usernameTf.text.length > 0) {
            [self login:nil];
        }
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([string length] > 0) {
        if(self.passwordTf.text.length > 0 && self.serverUrlTf.text.length > 0 && self.usernameTf.text.length > 0) {
            self.loginButton.userInteractionEnabled = YES;
        }
    } else {
        if(range.location == 0) {//delete all the text, disable login button
            self.loginButton.userInteractionEnabled = NO;
        }
    }
    return YES;
}
#pragma mark UIAlertViewDelegate method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.hud.hidden = NO;
    [self.hud dismiss];
}

#pragma mark Utils
- (void)configTextFields
{
    self.passwordTf.delegate = self;
    self.serverUrlTf.delegate = self;
    self.usernameTf.delegate = self;
}
- (void) dismissKeyboards
{
    [self.passwordTf resignFirstResponder];
    [self.serverUrlTf resignFirstResponder];
    [self.usernameTf resignFirstResponder];
}

@end
