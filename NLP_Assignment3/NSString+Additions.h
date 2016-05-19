//
//  NSString+Additions.h
//  NLP_Assignment3
//
//  Created by Hamid Ismail on 19/05/2016.
//  Copyright © 2016 ThatClose. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)
{
    
}
- (NSString *)stripHtml;
- (void)getTagForWordWithCompletion:(void (^)(NSString *tag, NSString *currentEntity, NSRange tokenRange, NSRange sentenceRange))completion;
@end
