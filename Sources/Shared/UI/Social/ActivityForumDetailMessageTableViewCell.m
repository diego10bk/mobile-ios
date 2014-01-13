//
//  ActivityForumDetailMessageTableViewCell.m
//  eXo Platform
//
//  Created by Nguyen Khac Trung on 10/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ActivityForumDetailMessageTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "defines.h"
#import "ActivityHelper.h"
#import "LanguageHelper.h"
#import "EGOImageView.h"
#import "NSString+HTML.h"

@implementation ActivityForumDetailMessageTableViewCell

@synthesize htmlMessage = _htmlMessage;
@synthesize htmlName = _htmlName;

- (void)configureCellForSpecificContentWithWidth:(CGFloat)fWidth{
    CGRect tmpFrame = CGRectZero;
    if (fWidth > 320) {
        tmpFrame = CGRectMake(65, 0, WIDTH_FOR_CONTENT_IPAD, 21);
        width = WIDTH_FOR_CONTENT_IPAD;
     } else {
        tmpFrame = CGRectMake(65, 0, WIDTH_FOR_CONTENT_IPHONE , 21);
        width = WIDTH_FOR_CONTENT_IPHONE;
    }
    
    _htmlName = [[RTLabel alloc] initWithFrame:tmpFrame];
    _htmlName.userInteractionEnabled = NO;
    _htmlName.backgroundColor = [UIColor clearColor];
    _htmlName.font = [UIFont systemFontOfSize:13.0];
    _htmlName.textColor = [UIColor grayColor];
    
    [self.contentView addSubview:_htmlName];
    
    _htmlMessage = [[RTLabel alloc] initWithFrame:tmpFrame];
    _htmlMessage.userInteractionEnabled = NO;
    _htmlMessage.backgroundColor = [UIColor clearColor];
    _htmlMessage.font = [UIFont systemFontOfSize:13.0];
    _htmlMessage.textColor = [UIColor grayColor];
    
    [self.contentView addSubview:_htmlMessage];
}

- (void)updateSizeToFitSubViews {
    // update position of last line: icon and date label
    float lastLineY = _htmlMessage.frame.origin.y + _htmlMessage.frame.size.height;
    
    CGRect myFrame = self.frame;
    myFrame.size.height = lastLineY + self.lbDate.frame.size.height + kBottomMargin;
    self.frame = myFrame;
}

- (void)setSocialActivityDetail:(SocialActivity *)socialActivityDetail
{
    [super setSocialActivityDetail:socialActivityDetail];
    NSString *type = [socialActivityDetail.activityStream valueForKey:@"type"];
    NSString *space = nil;
    NSString *htmlStr = nil;
    if([type isEqualToString:STREAM_TYPE_SPACE]) {
        space = [socialActivityDetail.activityStream valueForKey:@"fullName"];
    }
    
    NSString *textWithoutHtml = @"";
    
    NSDictionary *_templateParams = self.socialActivity.templateParams;
    switch (self.socialActivity.activityType) {
        case ACTIVITY_FORUM_CREATE_TOPIC:{
           
            htmlStr = [NSString stringWithFormat:@"<font face='Helvetica' size=13 color='#115EAD'><b>%@%@</b></font> %@", socialActivityDetail.posterIdentity.fullName, space ? [NSString stringWithFormat:@" in %@ space", space] : @"",Localize(@"NewTopic")];
                        
            
            float plfVersion = [[[NSUserDefaults standardUserDefaults] valueForKey:EXO_PREFERENCE_VERSION_SERVER] floatValue];
            if(plfVersion >= 4.0) { // plf 4 and later
                [_webViewForContent loadHTMLString:[NSString stringWithFormat:@"<html><head><style>body{background-color:transparent;color:#808080;font-family:\"Helvetica\";font-size:13;word-wrap: break-word;} a:link{color: #115EAD; text-decoration: none; font-weight: bold;} a{color: #115EAD; text-decoration: none; font-weight: bold;}</style> </head><a href=\"%@\">%@</a></body></html>", [_templateParams valueForKey:@"TopicLink"], socialActivityDetail.title]
                                           baseURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] valueForKey:EXO_PREFERENCE_DOMAIN]]
                 ];
                textWithoutHtml = socialActivityDetail.title;
            } else {
                [_webViewForContent loadHTMLString:[NSString stringWithFormat:@"<html><head><style>body{background-color:transparent;color:#808080;font-family:\"Helvetica\";font-size:13;word-wrap: break-word;} a:link{color: #115EAD; text-decoration: none; font-weight: bold;} a{color: #115EAD; text-decoration: none; font-weight: bold;}</style> </head><a href=\"%@\">%@</a></body></html>", [_templateParams valueForKey:@"TopicLink"], [_templateParams valueForKey:@"TopicName"]]
                                           baseURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] valueForKey:EXO_PREFERENCE_DOMAIN]]
                 ];
                textWithoutHtml = [_templateParams valueForKey:@"TopicName"];

            }
            
        }
            break;
        case ACTIVITY_FORUM_CREATE_POST:{
            htmlStr = [NSString stringWithFormat:@"<font face='Helvetica' size=13 color='#115EAD'><b>%@%@</b></font> %@", socialActivityDetail.posterIdentity.fullName, space ? [NSString stringWithFormat:@" in %@ space", space] : @"", Localize(@"NewPost")];

            [_webViewForContent loadHTMLString:[NSString stringWithFormat:@"<html><head><style>body{background-color:transparent;color:#808080;font-family:\"Helvetica\";font-size:13;word-wrap: break-word;} a:link{color: #115EAD; text-decoration: none; font-weight: bold;} a{color: #115EAD; text-decoration: none; font-weight: bold;}</style> </head><a href=\"%@\">%@</a></body></html>",[_templateParams valueForKey:@"PostLink"],[_templateParams valueForKey:@"PostName"]]
                                       baseURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] valueForKey:EXO_PREFERENCE_DOMAIN]]
             ];
            textWithoutHtml = [_templateParams valueForKey:@"PostName"];
        }
            
            break; 
        case ACTIVITY_FORUM_UPDATE_POST:{
            htmlStr = [NSString stringWithFormat:@"<font face='Helvetica' size=13 color='#115EAD'><b>%@%@</b></font> %@", socialActivityDetail.posterIdentity.fullName, space ? [NSString stringWithFormat:@" in %@ space", space] : @"",Localize(@"UpdatePost")];
            [_webViewForContent loadHTMLString:[NSString stringWithFormat:@"<html><head><style>body{background-color:transparent;color:#808080;font-family:\"Helvetica\";font-size:13;word-wrap: break-word;} a:link{color: #115EAD; text-decoration: none; font-weight: bold;} a{color: #115EAD; text-decoration: none; font-weight: bold;}</style> </head><body><a href=\"%@\">%@</a></body></html>", [_templateParams valueForKey:@"PostLink"],[[_templateParams valueForKey:@"PostName"] stringByConvertingHTMLToPlainText]]
                                       baseURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] valueForKey:EXO_PREFERENCE_DOMAIN]]
             ];
            textWithoutHtml = [_templateParams valueForKey:@"PostName"];
        }
            
            break;
        case ACTIVITY_FORUM_UPDATE_TOPIC:{
            htmlStr = [NSString stringWithFormat:@"<font face='Helvetica' size=13 color='#115EAD'><b>%@%@</b></font> %@", socialActivityDetail.posterIdentity.fullName, space ? [NSString stringWithFormat:@" in %@ space", space] : @"",Localize(@"UpdateTopic")];
            [_webViewForContent loadHTMLString:[NSString stringWithFormat:@"<html><head><style>body{background-color:transparent;color:#808080;font-family:\"Helvetica\";font-size:13;word-wrap: break-word;} a:link{color: #115EAD; text-decoration: none; font-weight: bold;} a{color: #115EAD; text-decoration: none; font-weight: bold;}</style> </head><body><a href=\"%@\">%@</a></body></html>", [_templateParams valueForKey:@"TopicLink"],[[_templateParams valueForKey:@"TopicName"] stringByConvertingHTMLToPlainText]]
                                       baseURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] valueForKey:EXO_PREFERENCE_DOMAIN]]
             ];
            textWithoutHtml = [_templateParams valueForKey:@"TopicName"];
        }
            break;
    }
    // Name
    [_htmlName setText:htmlStr];
    [_htmlName resizeLabelToFit];
    
    [_htmlMessage setText:[[socialActivityDetail.body stringByConvertingHTMLToPlainText] stringByEncodeWithHTML]] ;
    
    
    CGRect tmpFrame = _htmlName.frame;
    tmpFrame.origin.y = 5;
    _htmlName.frame = tmpFrame;

    //Set the position of web
    CGSize theSize = [textWithoutHtml sizeWithFont:kFontForTitle 
                                 constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) 
                                     lineBreakMode:UILineBreakModeWordWrap];
    
    _webViewForContent.contentMode = UIViewContentModeScaleAspectFit;
    tmpFrame = _webViewForContent.frame;
    tmpFrame.origin.y = _htmlName.frame.size.height + _htmlName.frame.origin.y + 5;
    tmpFrame.size.height = theSize.height + 10;
    _webViewForContent.frame = tmpFrame;
    
    
    // Content
    tmpFrame = _htmlMessage.frame;
    tmpFrame.origin.y = _webViewForContent.frame.size.height + _webViewForContent.frame.origin.y + 5;
    _htmlMessage.frame = tmpFrame;
    [_htmlMessage sizeToFit];
    
    [_webViewForContent sizeToFit];
    
    [self updateSizeToFitSubViews];
}

- (void)dealloc {
    [_htmlMessage release];
    [_htmlName release];
    
    [super dealloc];
}

@end
