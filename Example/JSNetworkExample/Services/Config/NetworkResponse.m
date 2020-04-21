//
//  NetworkResponse.m
//  JSNetwork
//
//  Created by jiasong on 2020/4/19.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "NetworkResponse.h"

@implementation NetworkResponse

- (void)processingTask:(NSURLSessionTask *)task responseObject:(id)responseObject error:(NSError *)error {
    [super processingTask:task responseObject:responseObject error:error];
    if (error) {
        self.message = error.localizedDescription;
    } else {
        NSDictionary *dic = responseObject;
        if ([dic isKindOfClass:NSDictionary.class]) {
            if ([[dic objectForKey:@"success"] boolValue]) {
                self.successful = YES;
                self.contentData = [dic objectForKey:@"data"];
            }
            self.message = [dic objectForKey:@"message"];
        }
    }
}

@end
