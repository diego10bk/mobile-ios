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


#import "HTTPStubsHelper.h"
#import <OHHTTPStubs.h>

@implementation HTTPStubsHelper

+ (HTTPStubsHelper*)getInstance
{
    static HTTPStubsHelper *instance;
    @synchronized(self)
    {
        if (!instance)
        {
            instance = [[HTTPStubsHelper alloc] init];
        }
        return instance;
    }
    return instance;
}

- (id) init
{
	self = [super init];
    if (self)
    {
        [self logStubbedHTTPRequests];
    }
	return self;
}

#pragma mark General

- (void)logStubbedHTTPRequests
{
    [OHHTTPStubs onStubActivation:^(NSURLRequest *request, id<OHHTTPStubsDescriptor> stub) {
        NSLog(@"%@ request stubbed (%@ %@)", stub.name, request.HTTPMethod, request.URL);
    }];
}

#pragma mark Authentication

- (void)HTTPStubForAuthenticationWithSuccess:(BOOL)success
{
    NSString *name = success ? @"Successful Authenticate challenge" : @"Failed Authenticate challenge";
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.path isEqualToString:@"/rest/private"];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        if (success)
            return [OHHTTPStubsResponse responseWithData:[@"" dataUsingEncoding:NSUTF8StringEncoding] statusCode:200 headers:nil];
        else
            return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:kCFURLErrorUserAuthenticationRequired userInfo:nil]];
    }].name = name;
    
}

- (void)HTTPStubForPlatformInfoAuthenticated:(BOOL)auth
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        if (auth)
            return [request.URL.path isEqualToString:@"/rest/private/platform/info"];
        else
            return [request.URL.path isEqualToString:@"/rest/platform/info"];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(@"PlatformInfoResponse-4.0.json", nil) statusCode:200 headers:[NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"]];
    }].name = @"Platform Information";
}

#pragma mark Social

- (void)HTTPStubForActivityStream
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.path isEqualToString:@"/rest/private/api/social/v1-alpha3/portal/activity_stream/feed.json"];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(@"ActivityStreamResponse-4.0.json", nil) statusCode:200 headers:[NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"]];
    }].name = @"Activity Stream";
}

- (void)HTTPStubForActivityDetails
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.path isEqualToString:@"/rest/private/api/social/v1-alpha3/portal/activity/1e20cf09c06313bc0a9d372ecd6bd2a7.json"];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(@"ActivityDetailsResponse-4.0.json", nil) statusCode:200 headers:[NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"]];
    }].name = @"Activity Details";
}

- (void)HTTPStubForActivityLikes
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.path isEqualToString:@"/rest/private/api/social/v1-alpha3/portal/activity/1e20cf09c06313bc0a9d372ecd6bd2a7/likes.json"];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(@"ActivityDetailsLikesResponse-4.0.json", nil) statusCode:200 headers:[NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"]];
    }].name = @"Activity Likes";
}

- (void)HTTPStubForActivityComments
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.path isEqualToString:@"/rest/private/api/social/v1-alpha3/portal/activity/1e20cf09c06313bc0a9d372ecd6bd2a7/comments.json"];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(@"ActivityDetailsCommentsResponse-4.0.json", nil) statusCode:200 headers:[NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"]];
    }].name = @"Activity Comments";
}

- (void)HTTPStubForSocialUserProfileWithUsername:(NSString *)username
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        NSString *urlPath = [NSString stringWithFormat:@"/rest/private/api/social/v1-alpha3/portal/identity/organization/%@.json",
                             username];
        return [request.URL.path isEqualToString:urlPath];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(@"SocialUserProfileResponse-4.0.json", nil) statusCode:200 headers:[NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"]];
    }].name = @"Social User Profile";
}

- (void)HTTPStubForPostActivity
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        NSString *urlPath = @"/rest/private/api/social/v1-alpha3/portal/activity.json";
        return [request.URL.path isEqualToString:urlPath];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(@"PostActivityResponse-4.0.json", nil) statusCode:200 headers:[NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"]];
    }].name = @"Post Activity";
}

- (void)HTTPStubForPostComment
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        NSString *urlPath = @"/rest/private/api/social/v1-alpha3/portal/activity/1e20cf09c06313bc0a9d372ecd6bd2a7/comment.json";
        return [request.URL.path isEqualToString:urlPath];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(@"PostCommentResponse-4.0.json", nil) statusCode:200 headers:[NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"]];
    }].name = @"Post Comment";
}

- (void)HTTPStubForLikeActivityWithBoolean:(BOOL)like
{
    NSString *stubName = like ? @"Like Activity" : @"Unlike Activity";
    NSString *fileName = like ? @"PostLikeResponse-4.0.json" : @"DeleteLikeResponse-4.0.json";
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        NSString *urlPath = @"/rest/private/api/social/v1-alpha3/portal/activity/1e20cf09c06313bc0a9d372ecd6bd2a7/like.json";
        return [request.URL.path isEqualToString:urlPath];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(fileName, nil) statusCode:200 headers:[NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"]];
    }].name = stubName;

}

- (void)HTTPStubForGetLatestVersion
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        NSString *urlPath = @"/api/social/version/latest.json";
        return [request.URL.path isEqualToString:urlPath];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(@"LatestVersionResponse-4.0.json", nil) statusCode:200 headers:[NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"]];
    }].name = @"Get Latest Version";
}

@end
