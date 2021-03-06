//
// Created by sbuglakov on 04/06/14.
// Copyright (c) 2014 redetection. All rights reserved.
//

#import <AFOAuth2Client/AFOAuth2Client.h>
#import <RestKit/RestKit.h>
#import "RTKClient.h"
#import "RTKUser.h"
#import "RTKExpense.h"

static NSString *const TOSHL_AUTH_URL_STRING = @"https://toshl.com";
static NSString *const TOSHL_TOKEN_BY_AUTH_CODE_PATH = @"/oauth2/token";
static NSString *const TOSHL_TOKEN_REFRESH_PATH = @"/oauth2/token";

static NSString *const TOSHL_API_URL_STRING = @"https://api.toshl.com";


@interface RTKClient ()
@property (nonatomic, strong) AFOAuth2Client *tokensClient;
@property (nonatomic, strong) AFOAuth2Client *apiClient;
@property (nonatomic, strong) RKObjectManager *restkit;
@end

@implementation RTKClient

- (instancetype)initWithClientID:(NSString *)clientID secret:(NSString *)secret {
    self = [super init];
    if (self) {
        _tokensClient = [[AFOAuth2Client alloc] initWithBaseURL:[NSURL URLWithString:TOSHL_AUTH_URL_STRING] clientID:clientID secret:secret];
        _apiClient = [[AFOAuth2Client alloc] initWithBaseURL:[NSURL URLWithString:TOSHL_API_URL_STRING] clientID:clientID secret:secret];
        _restkit = [[RKObjectManager alloc] initWithHTTPClient:_apiClient];
        [self registerMappings];
    }
    return self;
}

- (void)authorizeWithCode:(NSString *)code redirectURI:(NSString *)redirectURI success:(void (^)(AFOAuthCredential *credential))successBlock fail:(void (^)(NSError *error))failBlock{
    [_tokensClient authenticateUsingOAuthWithPath:TOSHL_TOKEN_BY_AUTH_CODE_PATH code:code redirectURI:redirectURI success:^(AFOAuthCredential *credential) {
        [_apiClient setAuthorizationHeaderWithCredential:credential];
        if (successBlock != NULL) {
            successBlock(credential);
        }

    } failure:^(NSError *error) {
        if (failBlock != NULL) {
            failBlock(error);
        }
    }];
}

- (void)authorizeWithCredential:(AFOAuthCredential *)credential success:(void (^)(AFOAuthCredential *credential))successBlock fail:(void (^)(NSError *error))failBlock {
    [_tokensClient authenticateUsingOAuthWithPath:TOSHL_TOKEN_REFRESH_PATH refreshToken:credential.refreshToken success:^(AFOAuthCredential *newCredential) {
        [_apiClient setAuthorizationHeaderWithCredential:newCredential];
        if (successBlock != NULL) {
            successBlock(newCredential);
        }

    } failure:^(NSError *error) {
        if (failBlock != NULL) {
            failBlock(error);
        }
    }];
}

- (void)userInfoWithSuccess:(void(^)(RTKUser *userInfo))successBlock fail:(void(^)(NSError *error))failBlock {
    [_restkit getObject:nil path:@"/me" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (successBlock != NULL) {
            successBlock(mappingResult.firstObject);
        }

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failBlock != NULL) {
            failBlock(error);
        }
    }];
}

- (void)expensesPageWithSuccess:(void(^)(NSArray *expenses))successBlock fail:(void(^)(NSError *error))failBlock {
    [_restkit getObjectsAtPath:@"/expenses" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (successBlock != NULL) {
            successBlock(mappingResult.array);
        }

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failBlock != NULL) {
            failBlock(error);
        }
    }];
}

- (void)createExpense:(RTKExpense *)expense success:(void(^)())successBlock fail:(void(^)(NSError *error))failBlock {
    [_restkit postObject:expense path:@"/expenses" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (successBlock != nil) {
            successBlock();
        }

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failBlock) {
            failBlock(error);
        }
    }];
}


- (void)registerMappings {
    NSIndexSet *successGETStatusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);

    RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[RTKUser class]];
    [userMapping addAttributeMappingsFromDictionary:@{
            @"id" : @"identifier",
            @"email" : @"email",
            @"first_name" : @"firstname",
            @"last_name" : @"lastname",
    }];
    RKResponseDescriptor *userDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                        method:RKRequestMethodGET
                                                                                   pathPattern:@"/me"
                                                                                       keyPath:nil
                                                                                   statusCodes:successGETStatusCodes];

    [_restkit addResponseDescriptor:userDescriptor];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];

    RKObjectMapping *expenseMapping = [RKObjectMapping mappingForClass:[RTKExpense class]];
    expenseMapping.valueTransformer = [RKCompoundValueTransformer compoundValueTransformerWithValueTransformers:@[
            dateFormatter,
            [RKValueTransformer nullValueTransformer],
            [RKValueTransformer keyOfDictionaryValueTransformer],
    ]];

    [expenseMapping addAttributeMappingsFromDictionary:@{
            @"id": @"identifier",
            @"amount": @"amount",
            @"currency": @"currency",
            @"date": @"date",
            @"desc": @"comment",
            @"tags": @"tags",
    }];
    RKResponseDescriptor *expenseResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:expenseMapping
                                                                                                   method:RKRequestMethodGET
                                                                                              pathPattern:@"/expenses"
                                                                                                  keyPath:nil
                                                                                              statusCodes:successGETStatusCodes];
    [_restkit addResponseDescriptor:expenseResponseDescriptor];


    RKRequestDescriptor *expenseRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[expenseMapping inverseMapping]
                                                                                           objectClass:[RTKExpense class]
                                                                                           rootKeyPath:nil
                                                                                                method:RKRequestMethodPOST];
    [_restkit addRequestDescriptor:expenseRequestDescriptor];


}

@end
