//
//  ActivityForumTableViewCell.m
//  eXo Platform
//
//  Created by Nguyen Khac Trung on 10/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ActivityForumTableViewCell.h"
#import "LanguageHelper.h"
#import "ActivityHelper.h"
#import "NSString+HTML.h"
#import "defines.h"

@implementation ActivityForumTableViewCell

@synthesize lbMessage = _lbMessage;
@synthesize htmlName = _htmlName;
@synthesize lbTitle = _lbTitle;


- (void)configureFonts:(BOOL)highlighted {
    
    if (!highlighted) {
        _htmlName.textColor = [UIColor grayColor];
        _htmlName.backgroundColor = [UIColor whiteColor];
        
        _lbMessage.textColor = [UIColor grayColor];
        _lbMessage.backgroundColor = [UIColor whiteColor];
        
        
        _lbTitle.textColor = [UIColor grayColor];
        _lbTitle.backgroundColor = [UIColor whiteColor];
    } else {
        _htmlName.textColor = [UIColor darkGrayColor];
        _htmlName.backgroundColor = SELECTED_CELL_BG_COLOR;
        
        _lbMessage.textColor = [UIColor darkGrayColor];
        _lbMessage.backgroundColor = SELECTED_CELL_BG_COLOR;
        
        _lbTitle.textColor = [UIColor darkGrayColor];
        _lbTitle.backgroundColor = SELECTED_CELL_BG_COLOR;
    }
    
    [super configureFonts:highlighted];
}


- (void)configureCellForSpecificContentWithWidth:(CGFloat)fWidth {
    
    CGRect tmpFrame = CGRectZero;
    
    if (fWidth > 320) {
        tmpFrame = CGRectMake(70, 14, WIDTH_FOR_CONTENT_IPAD, 21);
    } else {
        tmpFrame = CGRectMake(70, 14, WIDTH_FOR_CONTENT_IPHONE, 21);
    }
    
    //Use an html styled label to display informations about the author of the wiki page
    _htmlName = [[RTLabel alloc] initWithFrame:tmpFrame];
    _htmlName.userInteractionEnabled = NO;
    _htmlName.backgroundColor = [UIColor clearColor];
    _htmlName.font = [UIFont systemFontOfSize:13.0];
    [self.contentView addSubview:_htmlName];
    
    //Use an html styled label to display informations about the author of the wiki page
    _lbTitle = [[RTLabel alloc] initWithFrame:tmpFrame];
    _lbTitle.userInteractionEnabled = NO;
    _lbTitle.backgroundColor = [UIColor clearColor];
    _lbTitle.font = [UIFont systemFontOfSize:13.0];
    [self.contentView addSubview:_lbTitle];
    
    _lbMessage = [[RTLabel alloc] initWithFrame:tmpFrame];
    _lbMessage.userInteractionEnabled = NO;
    _lbMessage.backgroundColor = [UIColor clearColor];
    _lbMessage.font = [UIFont systemFontOfSize:13.0];
    [self.contentView addSubview:_lbMessage];
}




- (void)setSocialActivityStreamForSpecificContent:(SocialActivity *)socialActivityStream {
    NSString *html = nil;
    NSString *type = [socialActivityStream.activityStream valueForKey:@"type"];
    NSString *space = nil;
    if([type isEqualToString:STREAM_TYPE_SPACE]) {
        space = [socialActivityStream.activityStream valueForKey:@"fullName"];
    }
    NSString *htmlStr;
    switch (socialActivityStream.activityType) {
        case ACTIVITY_FORUM_CREATE_POST:
            htmlStr = [NSString stringWithFormat:@"<font face='Helvetica' size=13 color='#115EAD'><b>%@%@</b></font> %@", socialActivityStream.posterIdentity.fullName, space ? [NSString stringWithFormat:@" in %@ space", space] : @"", Localize(@"NewPost")];
            html = [NSString stringWithFormat:@"<font face='Helvetica' size=13 color='#115EAD'><b>%@</b></font>",
                             [[[socialActivityStream.templateParams valueForKey:@"PostName"] stringByEncodeWithHTML] stringByConvertingHTMLToPlainText]];
            break;
        case ACTIVITY_FORUM_CREATE_TOPIC:
            htmlStr = [NSString stringWithFormat:@"<font face='Helvetica' size=13 color='#115EAD'><b>%@%@</b></font> %@", socialActivityStream.posterIdentity.fullName, space ? [NSString stringWithFormat:@" in %@ space", space] : @"", Localize(@"NewTopic")];
            
            float plfVersion = [[[NSUserDefaults standardUserDefaults] stringForKey:EXO_PREFERENCE_VERSION_SERVER] floatValue];
            
            if(plfVersion >= 4.0) { // plf 4 and later: TopicName is not in template params, it is title of socialActivityStream
                html = [NSString stringWithFormat:@"<font face='Helvetica' size=13 color='#115EAD'><b>%@</b></font>",
                        [[socialActivityStream.title stringByEncodeWithHTML] stringByConvertingHTMLToPlainText]];
            } else {
                html = [NSString stringWithFormat:@"<font face='Helvetica' size=13 color='#115EAD'><b>%@</b></font>",
                        [[[socialActivityStream.templateParams valueForKey:@"TopicName" ] stringByEncodeWithHTML] stringByConvertingHTMLToPlainText]];
            }
            
            break;
        case ACTIVITY_FORUM_UPDATE_TOPIC:
            htmlStr = [NSString stringWithFormat:@"<font face='Helvetica' size=13 color='#115EAD'><b>%@%@</b></font> %@", socialActivityStream.posterIdentity.fullName, space ? [NSString stringWithFormat:@" in %@ space", space] : @"", Localize(@"UpdateTopic")];
            html = [NSString stringWithFormat:@"<font face='Helvetica' size=13 color='#115EAD'><b>%@</b></font>",
                             [[[socialActivityStream.templateParams valueForKey:@"TopicName"] stringByEncodeWithHTML] stringByConvertingHTMLToPlainText]];
            break; 
        case ACTIVITY_FORUM_UPDATE_POST:
            htmlStr = [NSString stringWithFormat:@"<font face='Helvetica' size=13 color='#115EAD'><b>%@%@</b></font> %@", socialActivityStream.posterIdentity.fullName, space ? [NSString stringWithFormat:@" in %@ space", space] : @"", Localize(@"UpdatePost")];
            html = [NSString stringWithFormat:@"<font face='Helvetica' size=13 color='#115EAD'><b>%@</b></font>", 
                             [[[socialActivityStream.templateParams valueForKey:@"PostName"] stringByEncodeWithHTML] stringByConvertingHTMLToPlainText]];
            break; 
        default:
            break;
    }
    [_htmlName setText:htmlStr];
    [_htmlName resizeLabelToFit];
    
    [_lbTitle setText:html];
    [_lbTitle resizeLabelToFit];
    
    [_lbMessage setText:[[socialActivityStream.body stringByConvertingHTMLToPlainText] stringByEncodeWithHTML]];
    [_lbMessage resizeLabelToFit];

    //Set the position of Title
    CGRect tmpFrame = _lbTitle.frame;
    tmpFrame.origin.y = _htmlName.frame.origin.y + _htmlName.frame.size.height + 5;
    //tmpFrame.size.width = _htmlName.frame.size.width;
    _lbTitle.frame = tmpFrame;
    
    //Set the position of lbMessage
    tmpFrame = _lbMessage.frame;
    tmpFrame.origin.y = _lbTitle.frame.origin.y + _lbTitle.frame.size.height + 5;
    double heigthForTTLabel = [[self lbMessage] optimumSize].height ;
    if (heigthForTTLabel > EXO_MAX_HEIGHT){
        heigthForTTLabel = EXO_MAX_HEIGHT; 
    }
    tmpFrame.size.height = heigthForTTLabel;
    //tmpFrame.size.width = _htmlName.frame.size.width;
    _lbMessage.frame = tmpFrame;
}


- (void)dealloc {
    
    _lbMessage = nil;
    
    [_htmlName release];
    _htmlName = nil;
    
    [super dealloc];
}


@end
