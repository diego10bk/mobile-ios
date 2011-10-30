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
#import "EGOImageView.h"
#import "SocialPictureAttach.h"
#import "eXoViewController.h"

#define kFontForMessage [UIFont fontWithName:@"Helvetica" size:13]

@class ActivityDetailViewController;
@class SocialUserProfile;

@interface ActivityStreamBrowseViewController : eXoViewController <EGORefreshTableHeaderDelegate, SocialProxyDelegate, SocialMessageComposerDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIAlertViewDelegate, UIScrollViewDelegate>
{
    IBOutlet UITableView*                   _tblvActivityStream;
    
    NSMutableArray*                          _arrayOfType;
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
    NSIndexPath*                            _indexpathSelectedActivity;
    BOOL                                    _activityAction;
    
        
}
- (NSString *)getIconForType:(NSString *)type;
- (void)emptyState;
- (void)startLoadingActivityStream;
- (void)likeDislikeActivity:(NSString *)activity like:(BOOL)isLike;
- (void)postACommentOnActivity:(NSString *)activity;
- (void)sortActivities;
- (void)clearActivityData;
- (SocialActivityStream *)getSocialActivityStreamForIndexPath:(NSIndexPath *)indexPath;
- (void)setHudPosition;
-(void)showHudForUpload;
@end
