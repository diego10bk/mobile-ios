//
//  iPadSettingViewController.h
//  eXoMobile
//
//  Created by Tran Hoai Son on 5/31/10.
//  Copyright 2010 home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class eXoApplicationsViewController;
@class iPadServerManagerViewController;

@interface iPadSettingViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    id              _delegate;
    
	BOOL bRememberMe;
	BOOL bAutoLogin;
	NSString *languageStr;
	NSString *serverNameStr;
	
	UISwitch *rememberMe;
	UISwitch *autoLogin;
	UITextField *txtfDomainName;
	NSString*	_localizeStr;
	int			_selectedLanguage;
	NSDictionary*	_dictLocalize;
	BOOL edit;
	
    IBOutlet UITableView* tblView;
    
    NSMutableArray*                     _arrServerList;
    int                                 _intSelectedServer;
    iPadServerManagerViewController*    _iPadServerManagerViewController;
    int                                 _interfaceOrientation;
}

@property(nonatomic, retain) NSDictionary*	_dictLocalize;
@property(nonatomic, retain) UITableView*	tblView;

- (void)setDelegate:(id)delegate;
- (void)localize;
- (IBAction)onBtnBack:(id)sender;
- (void)setInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)changeOrientation:(UIInterfaceOrientation)interfaceOrientation;
-(UIImageView *) makeCheckmarkOffAccessoryView;
-(UIImageView *) makeCheckmarkOnAccessoryView;
@end
