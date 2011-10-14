//
//  SocialPostActivity.m
//  eXo Platform
//
//  Created by Stévan Le Meur on 19/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SocialPostActivity.h"
#import "SocialActivityDetails.h"
#import "SocialRestConfiguration.h"
#import "defines.h"


@implementation SocialPostActivity

@synthesize text=_text;

#pragma - Object Management

-(id)init {
    if ((self=[super init])) {
        //Default behavior
        _text = @"";
    }
    return self;
}



- (void) dealloc {
    [_text release];
    [super dealloc];
}


#pragma mark - helper methods

//Helper to create the base URL
- (NSString *)createBaseURL {
    SocialRestConfiguration* socialConfig = [SocialRestConfiguration sharedInstance];
    
    //http://demo:gtn@localhost:8080/rest/private/api/social/v1/portal/activity/1ed7c4c9c0a8012636585a573a15c26e
    
    return [NSString stringWithFormat:@"%@/%@/private/api/social/%@/%@/", socialConfig.domainNameWithCredentials, socialConfig.restContextName,socialConfig.restVersion, socialConfig.portalContainerName]; 
    //return @"http://john:gtn@localhost:8080/rest-socialdemo/private/api/social/v1-alpha1/socialdemo/identity/";
    
}


//Helper to create the path to get the ressources
- (NSString *)createPath:(NSString *)activityId {
    return [NSString stringWithFormat:@"activity.json",activityId]; 
}


-(void)postActivity:(NSString *)message fileURL:(NSString*)fileURL fileName:(NSString*)fileName {
    if (message != nil) {
        _text = message;
    }
    
    
    RKObjectManager* manager = [RKObjectManager objectManagerWithBaseURL:[self createBaseURL]];
    [RKObjectManager setSharedManager:manager];
    manager.serializationMIMEType = RKMIMETypeJSON;

    RKObjectRouter* router = [[RKObjectRouter new] autorelease];
    manager.router = router;
    
    // Send POST requests for instances of SocialActivityDetails to '/activity.json'
    [router routeClass:[SocialActivityDetails class] toResourcePath:@"activity.json" forMethod:RKRequestMethodPOST];
    
    // Let's create an SocialActivityDetails
    SocialActivityDetails* activity = [[SocialActivityDetails alloc] init];
    activity.title = _text;
    
    //Register our mappings with the provider FOR SERIALIZATION
    RKObjectMapping *activitySimpleMapping = [RKObjectMapping mappingForClass: 
                                              [SocialActivityDetails class]]; 
    [activitySimpleMapping mapKeyPath:@"title" toAttribute:@"title"];
    
    //Attach file
    if(fileURL != nil) {
        activity.type = @"DOC_ACTIVITY";
       /* "DOCPATH":"/Users/xuyen_mai/Public/Kaka.jpg",
        "MESSAGE":"",
        "DOCLINK":"/portal/rest/jcr/repository/collaboration/Users/xuyen_mai/Public/Kaka.jpg",
        "WORKSPACE":"collaboration",
        "REPOSITORY":"repository",
        "DOCNAME":"KakaHaha.jpg"*/
        
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *host = [userDefaults objectForKey:EXO_PREFERENCE_DOMAIN];
        
        NSRange rangeOfDocLink = [fileURL rangeOfString:host];
        NSString* docLink = [fileURL substringFromIndex:rangeOfDocLink.location + rangeOfDocLink.length];

        rangeOfDocLink = [fileURL rangeOfString:@"jcr/repository/collaboration"];
        NSString* docPath = [fileURL substringFromIndex:rangeOfDocLink.location + rangeOfDocLink.length];

         activity.templateParams = [[NSMutableDictionary alloc] init];
        
        [activity setKeyForTemplateParams:@"DOCPATH" value:docPath];
        [activity setKeyForTemplateParams:@"MESSAGE" value:@""];
        [activity setKeyForTemplateParams:@"DOCLINK" value:docLink];
        [activity setKeyForTemplateParams:@"WORKSPACE" value:@"collaboration"];
        [activity setKeyForTemplateParams:@"REPOSITORY" value:@"repository"];
        [activity setKeyForTemplateParams:@"DOCNAME" value:fileName];
        
        [activitySimpleMapping mapKeyPath:@"type" toAttribute:@"type"];
        [activitySimpleMapping mapKeyPath:@"templateParams" toAttribute:@"templateParams"];
    }
    
    //Configure a serialization mapping for our Product class 
    RKObjectMapping *activitySimpleSerializationMapping = [activitySimpleMapping 
                                                    inverseMapping]; 
    
    //serialization mapping 
    [manager.mappingProvider 
     setSerializationMapping:activitySimpleSerializationMapping forClass:[SocialActivityDetails 
                                                                   class]]; 
    
    
    
    //Now create the mapping for the response
    RKObjectMapping* mappingForResponse = [RKObjectMapping mappingForClass:[SocialActivityDetails class]];
    [mappingForResponse mapKeyPathsToAttributes:
     @"identityId",@"identityId",
     @"totalNumberOfComments",@"totalNumberOfComments",
     @"postedTime",@"postedTime",
     @"type",@"type",
     @"activityStream",@"activityStream",
     @"title",@"title",
     @"priority",@"priority",
     @"identifyId",@"identifyId",
     @"createdAt",@"createdAt",
     @"titleId",@"titleId",
     @"posterIdentity",@"posterIdentity",
     @"templateParams",@"templateParams",
     nil];
    
    
    //[manager.mappingProvider addObjectMapping:mappingForResponse]; 
    
    // Send a POST to /articles to create the remote instance
    [manager postObject:activity mapResponseWith:mappingForResponse delegate:self];    
    
}


#pragma mark - RKObjectLoaderDelegate methods

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response 
{
    NSLog(@"Loaded payload: %@", [response bodyAsString]);
}


- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects 
{
    if (delegate && [delegate respondsToSelector:@selector(proxyDidFinishLoading:)]) {
        [delegate proxyDidFinishLoading:self];
    }
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error 
{
    
    if (delegate && [delegate respondsToSelector:@selector(proxy: didFailWithError:)]) {
        [delegate proxy:self didFailWithError:error];
    }
}


@end
