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
        NSDictionary *dic = nil;
        if ([responseObject isKindOfClass:NSData.class]) {
            dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        } else if ([responseObject isKindOfClass:NSDictionary.class]) {
            dic = responseObject;
        }
        if (dic) {
            if ([[dic objectForKey:@"success"] boolValue]) {
                self.successful = true;
                self.contentData = [dic objectForKey:@"content"];
            }
            self.message = [dic objectForKey:@"message"];
        }
    }
}

@end
