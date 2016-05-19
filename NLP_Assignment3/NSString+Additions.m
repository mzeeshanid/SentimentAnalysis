//
//  NSString+Additions.m
//  NLP_Assignment3
//
//  Created by Hamid Ismail on 19/05/2016.
//  Copyright © 2016 ThatClose. All rights reserved.
//

#import "NSString+Additions.h"

@interface NSString_stripHtml_XMLParsee : NSObject<NSXMLParserDelegate> {
    
@private
    NSMutableArray* strings;
}

- (NSString*)getCharsFound;
@end

@implementation NSString_stripHtml_XMLParsee

- (id)init {
    if((self = [super init])) {
        strings = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string {
    [strings addObject:string];
}

- (NSString*)getCharsFound {
    return [strings componentsJoinedByString:@""];
}
@end

@implementation NSString (Additions)

- (NSString*)stripHtml {
    // take this string obj and wrap it in a root element to ensure only a single root element exists
    // and that any ampersands are escaped to preserve the escaped sequences
    NSString* string = [self stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    string = [NSString stringWithFormat:@"<root>%@</root>", string];
    
    // add the string to the xml parser
    NSStringEncoding encoding = string.fastestEncoding;
    NSData* data = [string dataUsingEncoding:encoding];
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
    
    // parse the content keeping track of any chars found outside tags (this will be the stripped content)
    NSString_stripHtml_XMLParsee* parsee = [[NSString_stripHtml_XMLParsee alloc] init];
    parser.delegate = parsee;
    [parser parse];
    
    /*
     NSError * error = nil;
     if((error = [parser parserError])) {
     NSLog(@"This is a warning only. There was an error parsing the string to strip HTML. This error may be because the string did not contain valid XML, however the result will likely have been decoded correctly anyway.: %@", error);
     }
     */
    
    // any chars found while parsing are the stripped content
    NSString* strippedString = [parsee getCharsFound];
    
    // get the raw text out of the parsee after parsing, and return it
    return strippedString;
}

- (void)getTagForWordWithCompletion:(void (^)(NSString *__nullable tag, NSString *__nullable currentEntity, NSRange tokenRange, NSRange sentenceRange))completion {
    NSString *word = self;
    NSRange stringRange = NSMakeRange(0, word.length);
    NSDictionary* languageMap = @{@"Latn" : @[@"en"]};
    [word enumerateLinguisticTagsInRange:stringRange
                                  scheme:NSLinguisticTagSchemeLemma
                                 options:NSLinguisticTaggerOmitWhitespace
                             orthography:[NSOrthography orthographyWithDominantScript:@"Latn" languageMap:languageMap]
                              usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
                                  // Log info to console for debugging purposes
                                  NSString *currentEntity = [word substringWithRange:tokenRange];
                                  completion(tag, currentEntity, tokenRange, sentenceRange);
                              }];
}
@end


