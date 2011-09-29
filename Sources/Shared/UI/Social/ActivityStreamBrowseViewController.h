//
//  ActivityStreamBrowseViewController.h
//  eXo Platform
//
//  Created by Stévan Le Meur on 14/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocialProxy.h"
#import "SocialActivityStream.h"
#import "MockSocial_Activity.h"
#import "EGORefreshTableHeaderView.h"
#import "MessageComposerViewController.h"
#import "ATMHud.h"
#import "ATMHudDelegate.h"


#define kFontForMessage [UIFont fontWithName:@"Helvetica" size:13]

@class ActivityDetailViewController;
@class SocialUserProfile;

@interface ActivityStreamBrowseViewController : UIViewController <EGORefreshTableHeaderDelegate, SocialProxyDelegate, SocialMessageComposerDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIAlertViewDelegate>
{
    IBOutlet UITableView*                   _tblvActivityStream;
    
    NSMutableArray*                         _arrayOfSectionsTitle;
    NSMutableDictionary*                    _sortedActivities;
    ActivityDetailViewController*           _activityDetailViewController;
    UIBarButtonItem*                        _bbtnPost;
    
    NSMutableArray*                         _arrActivityStreams;
    
    BOOL                                    _bIsPostClicked;
    BOOL                                    _bIsIPad;
    UITextView*                             _txtvMsgComposer;
    SocialUserProfile*                      _socialUserProfile;
    
    //Refresh Management
    EGORefreshTableHeaderView*              _refreshHeaderView;
    BOOL                                    _reloading;
    NSDate*                                 _dateOfLastUpdate;
    
    //Loader
    ATMHud*                                 _hudActivityStream;//Heads up display
    
    BOOL                                    _activityAction;
    
}

- (void)startLoadingActivityStream;
- (void)likeDislikeActivity:(NSString *)activity like:(BOOL)isLike;
- (void)sortActivities;
- (void)clearActivityData;
- (SocialActivityStream *)getSocialActivityStreamForIndexPath:(NSIndexPath *)indexPath;
- (void)setHudPosition;
-(void)showHudForUpload;
@end
