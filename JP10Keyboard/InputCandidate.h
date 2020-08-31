//
//  InputCandidate.h
//  JapaneseKeyboardKit
//
//  Created by kishikawa katsumi on 2014/09/28.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>

// from mozc/src/converter/segments.h
typedef NS_OPTIONS(NSUInteger, CandidateAttributes) {
    DEFAULT_ATTRIBUTE = 0,
    // this was the best candidate before learning
    BEST_CANDIDATE = 1 << 0,
    // this candidate was reranked by user
    RERANKED = 1 << 1,
    // don't save it in history
    NO_HISTORY_LEARNING = 1 << 2,
    // don't save it in suggestion
    NO_SUGGEST_LEARNING = 1 << 3,
    // NO_HISTORY_LEARNING | NO_SUGGEST_LEARNING
    NO_LEARNING = (1 << 2 | 1 << 3),
    // learn it with left/right context
    CONTEXT_SENSITIVE = 1 << 4,
    // has "did you mean"
    SPELLING_CORRECTION = 1 << 5,
    // No need to have full/half width expansion
    NO_VARIANTS_EXPANSION = 1 << 6,
    // No need to have extra descriptions
    NO_EXTRA_DESCRIPTION = 1 << 7,
    // was generated by real-time conversion
    REALTIME_CONVERSION = 1 << 8,
    // contains tokens in user dictionary.
    USER_DICTIONARY = 1 << 9,
    // command candidate. e.g., incognito mode.
    COMMAND_CANDIDATE = 1 << 10,
    // key characters are consumed partially.
    // Consumed size is |consumed_key_size|.
    // If not set, all the key characters are consumed.
    PARTIALLY_KEY_CONSUMED = 1 << 11,
    // Typing correction candidate.
    // - Special description should be shown when the candidate is created
    //   by a dictionary predictor.
    // - No description should be shown when the candidate is loaded from
    //   history.
    // - Otherwise following unexpected behavior can be observed.
    //   1. Type "やんしょん" and submit "マンション<入力補正>".
    //   2. Type "まんしょん".
    //   3. "マンション<入力補正>" is shown as a candidate
    //      regardless of a user's correct typing.
    TYPING_CORRECTION = 1 << 12,
    // Auto partial suggestion candidate.
    // - Special description should be shown when the candidate is created
    //   by a dictionary predictor.
    // - No description should be shown when the candidate is loaded from
    //   history.
    AUTO_PARTIAL_SUGGESTION = 1 << 13,
    // Predicted from user prediction history.
    USER_HISTORY_PREDICTION = 1 << 14
};

@interface InputCandidate : NSObject

@property (nonatomic) NSString *input;
@property (nonatomic) NSString *candidate;

@property (nonatomic) NSString *prefix;
@property (nonatomic) NSString *suffix;
@property (nonatomic) NSString *description_;

@property (nonatomic) int usage_id;
@property (nonatomic) NSString *usage_title;
@property (nonatomic) NSString *usage_description;

@property (nonatomic) int cost;
@property (nonatomic) int wcost;
@property (nonatomic) int structure_cost;

@property (nonatomic) int lid;
@property (nonatomic) int rid;

@property (nonatomic) CandidateAttributes attributes;


- (id)initWithInput:(NSString *)input candidate:(NSString *)candidate prefix:(NSString *)prefix suffix:(NSString *)suffix description:(NSString *)description usage_id:(int)usage_id usage_title:(NSString *)usage_title usage_description:(NSString *)usage_description cost:(int32_t)cost wcost:(int32_t)wcost structure_cost:(int32_t)structure_cost lid:(int)lid rid:(int)rid attributes:(uint32_t)attributes;

@end