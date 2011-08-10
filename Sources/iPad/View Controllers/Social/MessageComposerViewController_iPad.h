//
//  MessageComposerViewController_iPad.h
//  eXo Platform
//
//  Created by Tran Hoai Son on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageComposerViewController.h"
#import "PhotoActionViewController.h"

@interface MessageComposerViewController_iPad : MessageComposerViewController {
 
    PhotoActionViewController*      _photoActionViewController;
}

- (void)showActionSheetForPhotoAttachment;
- (void)showPhotoLibrary;
- (void)addPhotoToView:(UIImage *)image;

@end
