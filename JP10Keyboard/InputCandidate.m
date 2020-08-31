//
//  InputCandidate.m
//  JapaneseKeyboardKit
//
//  Created by kishikawa katsumi on 2014/09/28.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import "InputCandidate.h"

@implementation InputCandidate

- (id)initWithInput:(NSString *)input candidate:(NSString *)candidate prefix:(NSString *)prefix suffix:(NSString *)suffix description:(NSString *)description usage_id:(int)usage_id usage_title:(NSString *)usage_title usage_description:(NSString *)usage_description cost:(int32_t)cost wcost:(int32_t)wcost structure_cost:(int32_t)structure_cost lid:(int)lid rid:(int)rid attributes:(uint32_t)attributes
{
    self = [super init];
    if (self) {
        _input = input;
        _candidate = candidate;
        _prefix = prefix;
        _suffix = suffix;
        _description_ = description;
        _usage_id = usage_id;
        _usage_title = usage_title;
        _usage_description = usage_description;
        _cost = cost;
        _wcost = wcost;
        _structure_cost = structure_cost;
        _lid = lid;
        _rid = rid;
        _attributes = attributes;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object
{
    return ([object isKindOfClass:[InputCandidate class]] &&
            [self.input isEqualToString:[object input]] &&
            [self.candidate isEqualToString:[object candidate]]);
}

#define NSUINT_BIT (CHAR_BIT * sizeof(NSUInteger))
#define NSUINTROTATE(val, howmuch) ((((NSUInteger)val) << howmuch) | (((NSUInteger)val) >> (NSUINT_BIT - howmuch)))

- (NSUInteger)hash
{
    return NSUINTROTATE([_input hash], NSUINT_BIT / 2) ^ [_candidate hash];
}

@end
