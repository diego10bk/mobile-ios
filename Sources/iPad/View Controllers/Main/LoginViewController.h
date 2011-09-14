//
//  LoginViewController.h
//  eXoMobile
//
//  Created by Tran Hoai Son on 5/31/10.
//  Copyright 2010 home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSHUDView.h"
#import "PlatformVersionProxy.h"
#import "SettingsViewController_iPad.h"

@class Checkbox;
@class ServerObj;

//Login page
@interface LoginViewController : UIViewController <PlatformVersionProxyDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, SettingsDelegateProcotol> {
	
	id										_delegate;

	NSString*								_strUsername;	//Username
	NSString*								_strPassword;	//Passowrd
	
	BOOL									_bRememberMe;	//Is remember
	BOOL									_bAutoSignIn;	//Is auto sign in
	
	NSDictionary*							_dictLocalize;	//Language dictionary
	int										_intSelectedLanguage;	//Language index
    
    
    BOOL                                    bRememberMe;        //Remember
	BOOL                                    bAutoLogin;         //Autologin
    BOOL                                    isFirstTimeLogin;	//Is first time login
    NSString*                               _strBSuccessful;	//Login status
    
    IBOutlet UILabel*						_lbSigningInStatus;	//Loading label
    IBOutlet UIActivityIndicatorView*		_actiSigningIn;	//Loading indicator
    
    IBOutlet UIButton*          _btnAccount;
    IBOutlet UIButton*          _btnServerList;
    IBOutlet UILabel*           _lbUsername;
    IBOutlet UILabel*           _lbPassword;
    IBOutlet UITextField*       _txtfUsername;
    IBOutlet UITextField*       _txtfPassword;
    IBOutlet UIButton*          _btnLogin;
    IBOutlet UIButton*          _btnSettings;
    IBOutlet UIView*            _vLoginView;
    IBOutlet UIView*            _vAccountView;
    IBOutlet UIView*            _vServerListView;
    IBOutlet UITableView*       _tbvlServerList;
    IBOutlet UIView*            _vContainer;
    
    NSMutableArray*             _arrServerList;
    NSString*                   _strHost;
    int                         _intSelectedServer;
    
    UINavigationController*             _modalNavigationSettingViewController;
    SettingsViewController_iPad*          _iPadSettingViewController;
    
    NSMutableArray*             _arrViewOfViewControllers;
    UIInterfaceOrientation      _interfaceOrientation;
    SSHUDView*                  _hud;
    
    IBOutlet UIImageView*       _panelBackground;
}

@property (nonatomic, retain) NSDictionary* _dictLocalize;

- (void)setDelegate:(id)delegate;	//Set delegate
- (void)setPreferenceValues;	//Set prefrrences
- (void)localize;	//Set language dictionary
- (int)getSelectedLanguage;	//Get current language
- (NSDictionary*)getLocalization;	//Get language dictionary
- (void)changeOrientation:(UIInterfaceOrientation)interfaceOrientation;	//Change device orientation

- (void)doSignIn;
- (void)startSignInProgress;
- (void)signInSuccesfully;
- (void)signInFailed;
- (void)signInAnimation:(int)animationMode;

- (IBAction)onSignInBtn:(id)sender;	//Login action
- (IBAction)onSettingBtn:(id)sender;	//Setting action
- (IBAction)onBtnAccount:(id)sender;
- (IBAction)onBtnServerList:(id)sender;

@end
