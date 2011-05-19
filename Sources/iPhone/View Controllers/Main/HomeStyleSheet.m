//
//  HomeStyleSheet.m
//  eXo Platform
//
//  Created by Stévan Le Meur on 10/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HomeStyleSheet.h"


@implementation HomeStyleSheet

- (TTStyle*)launcherButton:(UIControlState)state {
	return
    [TTPartStyle styleWithName:@"image" style:TTSTYLESTATE(launcherButtonImage:, state) next:
	 [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:11] color:[UIColor blackColor]
				minimumFontSize:11 shadowColor:nil
				   shadowOffset:CGSizeZero next:nil]];
}

- (TTStyle*)launcherPageDot:(UIControlState)state {
	if (state != UIControlStateSelected) {
		return [self pageDotWithColor:[UIColor whiteColor]];
	} else {
		return [self pageDotWithColor:[UIColor colorWithRed:0.227 green:0.455 blue:0.647 alpha:1.000]];
	}
}

@end