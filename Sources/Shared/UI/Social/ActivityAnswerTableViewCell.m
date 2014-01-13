//
//  ActivityAnswerTableViewCell.m
//  eXo Platform
//
//  Created by Nguyen Khac Trung on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ActivityAnswerTableViewCell.h"
#import "LanguageHelper.h"
#import "ActivityHelper.h"
#import "NSString+HTML.h"
#import "defines.h"

@implementation ActivityAnswerTableViewCell

@synthesize lbMessage = _lbMessage;
@synthesize htmlName = _htmlName;
@synthesize htmlTitle = _htmlTitle;


- (void)configureFonts:(BOOL)highlighted {
    
    if (!highlighted) {
        _htmlName.textColor = [UIColor grayColor];
        _htmlName.backgroundColor = [UIColor whiteColor];
        
        _htmlTitle.textColor = [UIColor grayColor];
        _htmlTitle.backgroundColor = [UIColor whiteColor];
        
        _lbMessage.textColor = [UIColor grayColor];
        _lbMessage.backgroundColor = [UIColor whiteColor];
    } else {
        _htmlName.textColor = [UIColor darkGrayColor];
        _htmlName.backgroundColor = SELECTED_CELL_BG_COLOR;
        
        _htmlTitle.textColor = [UIColor darkGrayColor];
        _htmlTitle.backgroundColor = SELECTED_CELL_BG_COLOR;
        
        _lbMessage.textColor = [UIColor darkGrayColor];
        _lbMessage.backgroundColor = SELECTED_CELL_BG_COLOR;
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
    
    _htmlTitle = [[RTLabel alloc] initWithFrame:tmpFrame];
    _htmlTitle.userInteractionEnabled = NO;
    _htmlTitle.backgroundColor = [UIColor clearColor];
    _htmlTitle.font = [UIFont systemFontOfSize:13.0];
    [self.contentView addSubview:_htmlTitle];
    
    _lbMessage = [[RTLabel alloc] initWithFrame:tmpFrame];
    _lbMessage.userInteractionEnabled = NO;
    _lbMessage.backgroundColor = [UIColor clearColor];
    _lbMessage.font = [UIFont systemFontOfSize:13.0];
    [self.contentView addSubview:_lbMessage];
}




- (void)setSocialActivityStreamForSpecificContent:(SocialActivity *)socialActivityStream {
    NSString *type = [socialActivityStream.activityStream valueForKey:@"type"];
    NSString *space = nil;
    if([type isEqualToString:STREAM_TYPE_SPACE]) {
        space = [socialActivityStream.activityStream valueForKey:@"fullName"];
    }
    NSString *htmlStr;
    switch (socialActivityStream.activityType) {
        case ACTIVITY_ANSWER_ADD_QUESTION:
            htmlStr = [NSString stringWithFormat:@"<font face='Helvetica' size=13 color='#115EAD'><b>%@%@</b></font> %@", socialActivityStream.posterIdentity.fullName,  space ? [NSString stringWithFormat:@" in %@ space", space] : @"",Localize(@"Asked")];
            break;
        case ACTIVITY_ANSWER_QUESTION:
            htmlStr = [NSString stringWithFormat:@"<font face='Helvetica' size=13 color='#115EAD'><b>%@%@</b></font> %@", socialActivityStream.posterIdentity.fullName,  space ? [NSString stringWithFormat:@" in %@ space", space] : @"",Localize(@"Answered")];
            break; 
        case ACTIVITY_ANSWER_UPDATE_QUESTION:
            htmlStr = [NSString stringWithFormat:@"<font face='Helvetica' size=13 color='#115EAD'><b>%@%@</b></font> %@", socialActivityStream.posterIdentity.fullName,  space ? [NSString stringWithFormat:@" in %@ space", space] : @"",Localize(@"UpdateQuestion")];
            break; 
        default:
            break;
    }
    [_htmlName setText:htmlStr];
    [_htmlName resizeLabelToFit];
    
    //Set the position of Title
    float plfVersion = [[[NSUserDefaults standardUserDefaults] valueForKey:EXO_PREFERENCE_VERSION_SERVER] floatValue];
    // in plf 4, no Name in template params, it's the title of ActivityStream
    NSString *title = plfVersion >= 4.0 ? socialActivityStream.title : [socialActivityStream.templateParams valueForKey:@"Name"];
    
    [_htmlTitle setText:[NSString stringWithFormat:@"<font face='Helvetica' size=13 color='#115EAD'><b>%@</b></font>", [[title stringByConvertingHTMLToPlainText] stringByEncodeWithHTML]]];
    [_htmlTitle resizeLabelToFit];
    
    [_lbMessage setText:[[socialActivityStream.body stringByConvertingHTMLToPlainText] stringByEncodeWithHTML]];
    [_lbMessage resizeLabelToFit];
    
    
    // for title
    CGRect tmpFrame = _htmlTitle.frame;
    tmpFrame.origin.y = _htmlName.frame.origin.y + _htmlName.frame.size.height + 5;
    double heigthForTTLabel = [[self htmlTitle] optimumSize].height;
    if (heigthForTTLabel > EXO_MAX_HEIGHT) heigthForTTLabel = EXO_MAX_HEIGHT;  
    tmpFrame.size.height = heigthForTTLabel;
    _htmlTitle.frame = tmpFrame;
    
    
    //Set the position of lbMessage
    tmpFrame = _lbMessage.frame;
    tmpFrame.origin.y = _htmlTitle.frame.origin.y + _htmlTitle.frame.size.height + 5;
    heigthForTTLabel = [[self lbMessage] optimumSize].height;
    if (heigthForTTLabel > EXO_MAX_HEIGHT) heigthForTTLabel = EXO_MAX_HEIGHT;  
    tmpFrame.size.height = heigthForTTLabel;
    _lbMessage.frame = tmpFrame;
    
}


- (void)dealloc {
    
    _lbMessage = nil;
    
    [_htmlName release];
    _htmlName = nil;
    
    [super dealloc];
}


@end
