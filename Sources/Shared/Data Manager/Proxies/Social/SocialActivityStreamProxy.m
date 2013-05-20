//
//  SocialActivityStreamProxy.m
//  eXo Platform
//
//  Created by Stévan Le Meur on 07/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SocialActivityStreamProxy.h"
#import "SocialIdentity.h"
#import "SocialRestConfiguration.h"
#import "SocialUserProfileProxy.h"


@implementation SocialActivityStreamProxy

@synthesize arrActivityStreams = _arrActivityStreams;
@synthesize isUpdateRequest = _isUpdateRequest;
@synthesize userProfile = _userProfile;

- (id)init
{
    if ((self = [super init])) 
    { 
        _isUpdateRequest = NO;
    } 
    return self;
}

- (void)dealloc 
{
    delegate = nil;
    [_arrActivityStreams release];
    [_userProfile release];
    [super dealloc];
}


#pragma mark - helper methods

//Helper to create the path to get the resources
- (NSString *)createPath 
{    
    return [NSString stringWithFormat:@"%@/activity_stream/%@", [super createPath], @"feed.json"]; 
}

- (NSString *)createPathForType:(ActivityStreamProxyActivityType)activityType {
    NSString *lastPath = nil;
    switch (activityType) {
        case ActivityStreamProxyActivityTypeAllUpdates:
            lastPath = @"feed.json";
            break;
        case ActivityStreamProxyActivityTypeMyConnections:
            lastPath = @"connections.json";
            break;
        case ActivityStreamProxyActivityTypeMySpaces:
            lastPath = @"spaces.json";            
            break;
        case ActivityStreamProxyActivityTypeMyStatus:
            lastPath = [NSString stringWithFormat:@"%@.json", self.userProfile.identity];
            break;
        default:
            break;
    }

    return [NSString stringWithFormat:@"%@/activity_stream/%@", [super createPath], lastPath];
}

#pragma mark - Call methods

/*
 * Load the 100 most recent activities of the given type:
 * ActivityStreamProxyActivityTypeAllUpdates    : All updates 
 * ActivityStreamProxyActivityTypeMyConnections : My connections only
 * ActivityStreamProxyActivityTypeMySpaces      : My spaces only
 * ActivityStreamProxyActivityTypeMyStatus      : My statuses only
 * Maps the JSON properties with the SocialActivity attributes, cf
 * https://github.com/RestKit/RestKit/blob/master/Docs/Object%20Mapping.md
 */
- (void) getActivityStreams:(ActivityStreamProxyActivityType)activitytype
{
    RKObjectManager* manager = [RKObjectManager sharedManager];
    
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[SocialActivity class]];
    [mapping mapKeyPathsToAttributes:
     @"identityId",@"identityId",
     @"liked",@"liked",
     @"postedTime",@"postedTime",
     @"type",@"type",
     @"id",@"activityId",
     @"title",@"title",
     @"body",@"body",
     @"createdAt",@"createdAt",
     @"titleId",@"titleId",
     @"totalNumberOfComments",@"totalNumberOfComments",
     @"totalNumberOfLikes",@"totalNumberOfLikes",
     @"templateParams", @"templateParams",
     @"activityStream", @"activityStream",
     @"lastUpdated",@"lastUpdated",
    nil];
    
    [manager.mappingProvider setObjectMapping:mapping forKeyPath:@"activities"];
    
    //Retrieve the UserProfile directly on the activityStream service
    RKObjectMapping* posterProfileMapping = [RKObjectMapping mappingForClass:[SocialUserProfile class]];
    [posterProfileMapping mapKeyPathsToAttributes:
     @"id",@"identity",
     @"remoteId",@"remoteId",
     @"providerId",@"providerId",
     @"profile.avatarUrl",@"avatarUrl",
     @"profile.fullName",@"fullName",
     nil];
    [mapping mapKeyPath:@"posterIdentity" toRelationship:@"posterIdentity" withObjectMapping:posterProfileMapping];
    
    // No need to keep and retain the RKObjectLoader here because we don't need RK if the
    // request fails, we just display an error dialog
    [manager loadObjectsAtResourcePath:[self createPathForType:activitytype] delegate:self];
}

/*
 * Loads the 100 activities of the given type that were published before the given activity
 * Cf method above for explanation of the types and the RK mapping
 */
- (void)getActivitiesOfType:(ActivityStreamProxyActivityType)activitytype BeforeActivity:(SocialActivity*)activity {
        
    RKObjectManager* manager = [RKObjectManager sharedManager];
    
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[SocialActivity class]];
    [mapping mapKeyPathsToAttributes:
     @"identityId",@"identityId",
     @"liked",@"liked",
     @"postedTime",@"postedTime",            
     @"type",@"type",
     @"id",@"activityId",
     @"title",@"title",
     @"body",@"body",
     @"createdAt",@"createdAt",
     @"titleId",@"titleId",
     @"templateParams", @"templateParams",
     @"activityStream", @"activityStream",
     @"lastUpdated", @"lastUpdated",
     nil];
    
    [manager.mappingProvider setObjectMapping:mapping forKeyPath:@"activities"];
    
    
    //Retrieve the UserProfile directly on the activityStream service
    RKObjectMapping* posterProfileMapping = [RKObjectMapping mappingForClass:[SocialUserProfile class]];
    [posterProfileMapping mapKeyPathsToAttributes:
     @"id",@"identity",
     @"remoteId",@"remoteId",
     @"providerId",@"providerId",
     @"profile.avatarUrl",@"avatarUrl",
     @"profile.fullName",@"fullName",
     nil];
    [mapping mapKeyPath:@"posterIdentity" toRelationship:@"posterIdentity" withObjectMapping:posterProfileMapping];
    
    // Keep and retain the instance of RKObjectLoader, so RK can use it if there is an error
    // and it needs to make another request to reload all activities
    // We will release it when the LoadMore request is successful, 
    // or when the UpdateAfterError request ends (successful or not)
    // Cf ActivityStreamBrowseViewController:didFinishLoading and :didFailWithError
    rkLoader = [[manager loadObjectsAtResourcePath:[NSString stringWithFormat:@"%@?max_id=%@",[self createPathForType:activitytype], activity.activityId] delegate:self] retain];
}

#pragma mark - RKObjectLoaderDelegate methods
- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects 
{
    self.arrActivityStreams = objects;
    [super objectLoader:objectLoader didLoadObjects:objects];
}

@end
