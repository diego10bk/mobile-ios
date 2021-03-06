//
// Copyright (C) 2003-2014 eXo Platform SAS.
//
// This is free software; you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License as
// published by the Free Software Foundation; either version 3 of
// the License, or (at your option) any later version.
//
// This software is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this software; if not, write to the Free
// Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
// 02110-1301 USA, or see the FSF site: http://www.fsf.org.
//
//

#import "DashboardProxy_old.h"
#import "defines.h"
#import "AuthenticateProxy.h"
#import "DataProcess.h"
#import "Gadget.h"


@interface DashboardProxy_old (PrivateMethods)
- (NSData*)sendRequest:(NSString*)urlStr;
- (NSData*)sendRequestToGetGadget:(NSString*)urlStr;
- (NSMutableArray*)listOfGadgetsWithURL:(NSString *)url;
- (NSMutableDictionary *)retrieveURLsForStandaloneGadget:(NSString *)dashboardString;
- (BOOL)isAGadgetIDString:(NSString *)potentialIDString;
- (NSString *)getStringForGadget:(NSString *)gadgetStr startStr:(NSString *)startStr endStr:(NSString *)endStr;
@end



@implementation DashboardProxy_old

@synthesize proxyDelegate = proxyDelegate;

#pragma mark - Object Management
//Singleton Accessor/Creator
+ (DashboardProxy_old*)sharedInstance
{
	static DashboardProxy_old *sharedInstance;
	@synchronized(self)
	{
		if(!sharedInstance)
		{
			sharedInstance = [[DashboardProxy_old alloc] init];
		}
		return sharedInstance;
	}
	return sharedInstance;
}


//Initialisation Method
- (id) init
{
    if ((self = [super init])) 
    {
        _localDashboardGadgetsString = nil;
        
    }	
	return self;
}


- (void)dealloc {
	[_localDashboardGadgetsString release];
    _localDashboardGadgetsString = nil;
    
    proxyDelegate = nil;
	
	[super dealloc];
}

#pragma mark - Private Methods
- (NSData*)sendRequest:(NSString*)urlStr
{
	NSURLResponse* response;
	NSError* error;
	NSData* dataResponse;	
	NSURL* url = [NSURL URLWithString:urlStr];
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];	
	
	[request setURL:url];
	[request setTimeoutInterval:60.0];
	[request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
	[request setHTTPMethod:@"GET"];
	dataResponse = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	return dataResponse;
}


- (NSData*)sendRequestToGetGadget:(NSString*)urlStr
{
	NSURLResponse* response;
	NSError* error;
	NSData* dataResponse;
	NSData* bodyData;
	
    NSHTTPCookieStorage *store = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray *tmpArr = [store cookies];
	for(int i = 0; i < [tmpArr count]; i++)
    {
		[store deleteCookie:[tmpArr objectAtIndex:i]];
    }
    
	NSURL* redirectURL = [NSURL URLWithString:urlStr];
	NSString* checkUrlStr = [NSString stringWithContentsOfURL:redirectURL encoding:NSUTF8StringEncoding error:nil];
	if(checkUrlStr == nil) 
	{
		redirectURL = nil;
		[redirectURL release];
		return nil;
	}
	
	//NSHTTPCookieStorage *store = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	
	NSRange rangeOfPrivate = [urlStr rangeOfString:@"/classic"];
	
	//Request to login
    // SLM note : here the loginStr could be uninitialized
    // --> probably cause a problem to retrieve gadgets...
	NSString* loginStr;
	if(rangeOfPrivate.length > 0)
    {
		loginStr = [[urlStr substringToIndex:rangeOfPrivate.location] stringByAppendingString:@"/j_security_check"];
    }
	else
	{
		rangeOfPrivate = [urlStr rangeOfString:@"/intranet"];
		if(rangeOfPrivate.length > 0)
        {
			loginStr = [[urlStr substringToIndex:rangeOfPrivate.location + rangeOfPrivate.length] stringByAppendingString:@"/j_security_check"];
		}
	}
    //Prevent any crash with a wrong initialization of loginStr
    if (loginStr == nil) return nil;
	
	NSURL* loginURL = [NSURL URLWithString:loginStr];
	NSMutableURLRequest* loginRequest = [[NSMutableURLRequest alloc] init];	
	[loginRequest setURL:loginURL];
	[loginRequest setTimeoutInterval:60.0];
	[loginRequest setCachePolicy:NSURLRequestUseProtocolCachePolicy];
	[loginRequest setHTTPShouldHandleCookies:NO];
	
	NSDictionary* postDictionary = [[NSMutableDictionary alloc] initWithCapacity:2];
	[postDictionary setValue:[AuthenticateProxy sharedInstance].username forKey:@"j_username"];
	[postDictionary setValue:[AuthenticateProxy sharedInstance].password forKey:@"j_password"];
	DataProcess* dataProcess = [DataProcess instance];
	bodyData = [dataProcess formatDictData:postDictionary WithEncoding:NSUTF8StringEncoding];
    [postDictionary release];
	
	[loginRequest setHTTPBody:bodyData];
	[loginRequest setHTTPMethod: @"POST"]; 
	
	NSDictionary *cookiesInfo = [NSHTTPCookie requestHeaderFieldsWithCookies:[store cookies]];
	[loginRequest setValue:[cookiesInfo objectForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];
	
	dataResponse = [NSURLConnection sendSynchronousRequest:loginRequest returningResponse:&response error:&error];
	
	return dataResponse;
}



- (NSMutableArray*)listOfGadgetsWithURL:(NSString *)url
{
	NSString* strGadgetName;
	NSString* strGadgetDescription;
	NSURL* urlGadgetContent;
	UIImage* imgGadgetIcon;
	
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	NSString* domain = [userDefaults objectForKey:EXO_PREFERENCE_DOMAIN];
	
	NSMutableString* strContent;
	
	NSData *data = [self sendRequestToGetGadget:url];
	//NSData *data = [self sendRequest:url];
	strContent = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
	_localDashboardGadgetsString = [strContent copy];
	
	NSRange range1;
	NSRange range2;
	
	range1 = [strContent rangeOfString:@"eXo.gadget.UIGadget.createGadget"];
	if(range1.length <= 0)
    {
		return nil;
	}
    
    NSMutableArray* arrTmpGadgets = [[NSMutableArray alloc] init];
    
    
	do 
	{
		strContent = (NSMutableString *)[strContent substringFromIndex:range1.location + range1.length];
		range2 = [strContent rangeOfString:@"'/eXoGadgetServer/gadgets',"];
		if (range2.length > 0) 
		{
			NSString *tmpStr = [strContent substringToIndex:range2.location + range2.length + 10];
			
			strGadgetName = [self getStringForGadget:tmpStr startStr:@"\"title\":\"" endStr:@"\","]; 
			strGadgetDescription = [self getStringForGadget:tmpStr startStr:@"\"description\":\"" endStr:@"\","];
			NSString *gadgetIconUrl = [self getStringForGadget:tmpStr startStr:@"\"thumbnail\":\"" endStr:@"\","];
			NSString *idString = [self getStringForGadget:tmpStr startStr:@"'content-" endStr:@"'"];
            
			if([gadgetIconUrl isEqualToString:@""])
				imgGadgetIcon = [UIImage imageNamed:@"PortletsIcon.png"];
			else
			{
				imgGadgetIcon = [UIImage imageWithData:[self sendRequest:gadgetIconUrl]];
				if(imgGadgetIcon == nil)
				{	
					NSRange range3 = [gadgetIconUrl rangeOfString:@"://"];
					if(range3.length == 0)
					{
						strContent = (NSMutableString *)[strContent substringFromIndex:range2.location + range2.length];
						range1 = [strContent rangeOfString:@"eXo.gadget.UIGadget.createGadget"];
						continue;
					}
					
					gadgetIconUrl = [gadgetIconUrl substringFromIndex:range3.location + range3.length];
					range3 = [gadgetIconUrl rangeOfString:@"/"];
					gadgetIconUrl = [gadgetIconUrl substringFromIndex:range3.location];
					NSString* tmpGGIC= [NSString stringWithFormat:@"%@%@", domain, gadgetIconUrl];		
					imgGadgetIcon = [UIImage imageWithData:[self sendRequest:tmpGGIC]];
					if(imgGadgetIcon == nil)
					{
						imgGadgetIcon = [UIImage imageNamed:@"PortletsIcon.png"];
					}	
				}
			}
			
			NSMutableString *gadgetUrl = [[NSMutableString alloc] initWithString:@""];
			[gadgetUrl appendString:domain];
			
			[gadgetUrl appendFormat:@"%@/", [self getStringForGadget:tmpStr startStr:@"'home', '" endStr:@"',"]];
			[gadgetUrl appendFormat:@"ifr?container=default&mid=1&nocache=0&lang=%@&debug=1&st=default", [self getStringForGadget:tmpStr startStr:@"&lang=" endStr:@"\","]];
			
			NSString *token = [NSString stringWithFormat:@":%@", [self getStringForGadget:tmpStr startStr:@"\"default:" endStr:@"\","]];
			token = [token stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
			token = [token stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
			token = [token stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
			
			
			[gadgetUrl appendFormat:@"%@&url=", token];
			
			NSString *gadgetXmlFile = [self getStringForGadget:tmpStr startStr:@"\"url\":\"" endStr:@"\","];
			gadgetXmlFile = [gadgetXmlFile stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
			gadgetXmlFile = [gadgetXmlFile stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
			
			[gadgetUrl appendFormat:@"%@", gadgetXmlFile];
			
			urlGadgetContent = [NSURL URLWithString:gadgetUrl];
			
			Gadget* gadget = [[Gadget alloc] init];
			
			[gadget setObjectWithName:strGadgetName description:strGadgetDescription urlContent:urlGadgetContent urlIcon:nil imageIcon:imgGadgetIcon];
			gadget._strID = [idString copy];
			[arrTmpGadgets addObject:gadget];
			
			strContent = (NSMutableString *)[strContent substringFromIndex:range2.location + range2.length];
			range1 = [strContent rangeOfString:@"eXo.gadget.UIGadget.createGadget"];
		}
        else
        {
            break;
        }
		
	} while (range1.length > 0);
	
	return arrTmpGadgets;
    
}


- (NSMutableDictionary *)retrieveURLsForStandaloneGadget:(NSString *)dashboardString
{
	
	NSRange range1;
	NSRange range2;
	
	NSString* strStandaloneUrl = nil;
	
	NSMutableDictionary* dictionaryURLForStandaloneGadget = [[NSMutableDictionary alloc] init];
	
	NSArray* arrParagraphs = [dashboardString componentsSeparatedByString:@"<div class=\"UIGadget\" id=\""];
	
	for (int i = 1; i < [arrParagraphs count]; i++) 
	{
		NSString* tmpStr1 = [arrParagraphs objectAtIndex:i];
		
		NSRange tmpRange = NSMakeRange(0, 36);
		
		NSString *idString = [tmpStr1 substringWithRange:tmpRange];
		
		if ([self isAGadgetIDString:idString]) {
			range1 = [tmpStr1 rangeOfString:@"standalone"];
			if (range1.length > 0) 
			{
				range2 = [tmpStr1 rangeOfString:@"<a style=\"display:none\" href=\""];
				if (range2.length > 0) 
				{
					int mark = 0;
					for (int j = range2.location + range2.length; j < [tmpStr1 length]; j++) 
					{
						if ([tmpStr1 characterAtIndex:j] == '"') 
						{
							mark = j;
							break;
						}
					}
					NSRange range3 = NSMakeRange(range2.location + range2.length, mark - range2.location - range2.length);
					strStandaloneUrl = [tmpStr1 substringWithRange:range3];
				}
				[dictionaryURLForStandaloneGadget setObject:strStandaloneUrl forKey:idString];
			}
		}
	}
	return dictionaryURLForStandaloneGadget;
}

- (BOOL)isAGadgetIDString:(NSString *)potentialIDString
{
	if(([potentialIDString characterAtIndex:8] == '-')&&([potentialIDString characterAtIndex:13] == '-')) return TRUE;
	return FALSE;
}

-(NSString *)getStringForGadget:(NSString *)gadgetStr startStr:(NSString *)startStr endStr:(NSString *)endStr
{
	NSString *returnValue = @"";
	NSRange range1;
	NSRange range2;
	
	range1 = [gadgetStr rangeOfString:startStr];
	
	if(range1.length > 0)
	{
		NSString *tmpStr = [gadgetStr substringFromIndex:range1.location + range1.length];
		range2 = [tmpStr rangeOfString:endStr];
		if(range2.length > 0)
		{
			returnValue = [tmpStr substringToIndex:range2.location];
		}
	}
	
	return [returnValue retain];
}


- (void)retrievingGadgetsOperation
{    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	NSString* domain = [userDefaults objectForKey:EXO_PREFERENCE_DOMAIN];	
	
	NSString* strContent = [AuthenticateProxy sharedInstance].firstLoginContent;
	
	NSRange range1;
	NSRange range3;
	range1 = [strContent rangeOfString:@"DashboardIcon TBIcon"];
	
	if(range1.length <= 0) return;
	
	strContent = [strContent substringFromIndex:range1.location + range1.length];
	range1 = [strContent rangeOfString:@"TBIcon"];
	
	if(range1.length <= 0) return;
	
    NSMutableArray* arrDbItems = [[NSMutableArray alloc] init];
    
	strContent = [strContent substringToIndex:range1.location];
	
	do 
	{ 
        //Search for each '<a class="ItemIcon DefaultPageIcon"' in the HTML
		range1 = [strContent rangeOfString:@"<a class=\"ItemIcon DefaultPageIcon\" href=\""];
        
        if (range1.length > 0) {
            
            //SLM Patch for gadgetParsing
            //Remove the ***...<a class="ItemIcon DefaultPageIcon" from the string
            NSString *stringCutted = [strContent substringFromIndex:range1.location + range1.length];
            
            //Search for the next '"' in the string
            NSRange rangeForComma = [stringCutted rangeOfString:@"\""];
            
            //Get the URL string
            NSString* gadgetTabUrlStr = [stringCutted substringToIndex:rangeForComma.location];
            
            //Search for the next '>' in the string
            NSRange rangeForSup = [stringCutted rangeOfString:@">"];
            
            //Remove the '>' from stringCutted
            stringCutted = [stringCutted substringFromIndex:rangeForSup.location+rangeForSup.length];
            
            //Search for the '</a>'
            NSRange rangeForDashboardNameEnd = [stringCutted rangeOfString:@"</a>"];
            
            //Get the TabName
            NSString *gadgetTabName = [stringCutted substringToIndex:rangeForDashboardNameEnd.location];
            
            
			NSURL *gadgetTabUrl = [NSURL URLWithString:gadgetTabUrlStr];
            
			//Getting informations about a gadget from not standalone gadgets
			//NSArray* arrTmpGadgetsInItem = [[NSArray alloc] init];
			NSArray* arrTmpGadgetsInItem = [self listOfGadgetsWithURL:[domain stringByAppendingFormat:@"%@", gadgetTabUrlStr]];
			
			//Retrieving standalone urls for gadgets			
			NSMutableDictionary *dictionaryStandaloneURL = [self retrieveURLsForStandaloneGadget:_localDashboardGadgetsString];
			
			for (int i = 0; i < [arrTmpGadgetsInItem count]; i++) 
			{
				Gadget* tmpGadget = [arrTmpGadgetsInItem objectAtIndex:i];
				
				NSString *urlStandalone = [dictionaryStandaloneURL objectForKey:tmpGadget._strID];
				// If the url is not find, we maintain the iframe url
				if (urlStandalone) tmpGadget._urlContent = [NSURL URLWithString:urlStandalone]; 
			}
			
			GateInDbItem* tmpGateInDbItem = [[GateInDbItem alloc] init];
			[tmpGateInDbItem setObjectWithName:gadgetTabName andURL:gadgetTabUrl andGadgets:arrTmpGadgetsInItem];
			[arrDbItems addObject:tmpGateInDbItem];
			
            //Prepare for the next iteration
            range3 = [strContent rangeOfString:[NSString stringWithFormat:@"%@</a>",gadgetTabName]];
			strContent = [strContent substringFromIndex:range3.location+range3.length];
            range1 = [strContent rangeOfString:@"<a class=\"ItemIcon DefaultPageIcon\" href=\""];
		}	
	} 
	while (range1.length > 0);
	
    if (proxyDelegate && [proxyDelegate respondsToSelector:@selector(didFinishLoadingGadgets:)]) {
        [proxyDelegate performSelectorOnMainThread:@selector(didFinishLoadingGadgets:) withObject:arrDbItems waitUntilDone:NO];
    }
    
    [pool release];
}




#pragma mark - Requests


- (void)startRetrievingGadgets
{	
    [self performSelectorInBackground:@selector(retrievingGadgetsOperation) withObject:nil];
}
    





@end
