//
//  InputManager.m
//  JapaneseKeyboardKit
//
//  Created by kishikawa katsumi on 2014/09/28.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import "InputManager.h"
#import "InputCandidate.h"

#include <string>

using namespace std;

#include "composer/composer.h"
#include "composer/table.h"
#include "converter/conversion_request.h"
#include "converter/converter_interface.h"
#include "converter/segments.h"
#include "prediction/predictor_interface.h"
#include "engine/engine_factory.h"
#include "engine/engine_interface.h"

void MakeSegmentsForSuggestion(const string key, mozc::Segments *segments) {
    segments->Clear();
    segments->set_max_prediction_candidates_size(10);
    segments->set_request_type(mozc::Segments::SUGGESTION);
    mozc::Segment *seg = segments->add_segment();
    seg->set_key(key);
    seg->set_segment_type(mozc::Segment::FREE);
}

void MakeSegmentsForPrediction(const string key, mozc::Segments *segments) {
    segments->Clear();
    segments->set_max_prediction_candidates_size(50);
    segments->set_request_type(mozc::Segments::PREDICTION);
    mozc::Segment *seg = segments->add_segment();
    seg->set_key(key);
    seg->set_segment_type(mozc::Segment::FREE);
}

void AddCandidate(size_t index, const string &value, mozc::Segments *segments) {
    mozc::Segment::Candidate *candidate =
        segments->mutable_segment(index)->add_candidate();
    CHECK(candidate);
    candidate->Init();
    candidate->value = value;
    candidate->content_value = value;
    candidate->key = segments->segment(index).key();
    candidate->content_key = segments->segment(index).key();
}
void AddCandidate(const string &value, mozc::Segments *segments) {
  AddCandidate(0, value, segments);
}


@interface InputManager ()

@property (nonatomic, readwrite) NSArray *candidates;
@property (nonatomic) NSOperationQueue *networkQueue;

@end

@implementation InputManager {
    scoped_ptr<mozc::EngineInterface> engine;
    mozc::ConverterInterface *converter;
    mozc::PredictorInterface *predictor;
}

- (id)init
{
    self = [super init];
    if (self) {
        engine.reset(mozc::EngineFactory::Create());
        converter = engine->GetConverter();
        CHECK(converter);
        predictor = engine->GetPredictor();
        CHECK(predictor);
    }
    
    return self;
}

- (void)requestCandidatesForInput:(NSString *)input
{
    mozc::commands::Request request;
    mozc::Segments segments;
    
    mozc::composer::Table table;
    mozc::composer::Composer composer(&table, &request);
    composer.InsertCharacterPreedit(input.UTF8String);
    mozc::ConversionRequest conversion_request(&composer, &request);
    
    converter->StartPredictionForRequest(conversion_request, &segments);
    
    NSMutableOrderedSet *candidates = [[NSMutableOrderedSet alloc] init];
    
    for (int i = 0; i < segments.segments_size(); ++i) {
        const mozc::Segment &segment = segments.segment(i);
        for (int j = 0; j < segment.candidates_size(); ++j) {
            const mozc::Segment::Candidate &cand = segment.candidate(j);
            
            [candidates addObject:[[InputCandidate alloc] initWithInput:[NSString stringWithUTF8String:cand.key.c_str()] candidate:[NSString stringWithUTF8String:cand.value.c_str()] prefix:[NSString stringWithUTF8String:cand.prefix.c_str()] suffix:[NSString stringWithUTF8String:cand.suffix.c_str()] description:[NSString stringWithUTF8String:cand.description.c_str()] usage_id:cand.usage_id  usage_title:[NSString stringWithUTF8String:cand.usage_title.c_str()] usage_description:[NSString stringWithUTF8String:cand.usage_description.c_str()] cost:cand.cost wcost:cand.wcost structure_cost:cand.structure_cost lid:cand.lid rid:cand.rid attributes:cand.attributes]];
        }
    }
    
    
    converter->StartConversionForRequest(conversion_request, &segments);

//    for (int i = 0; i < segments.segments_size(); ++i) {
        const mozc::Segment &segment = segments.segment(/*i*/0);
        for (int j = 0; j < segment.candidates_size(); ++j) {
            const mozc::Segment::Candidate &cand = segment.candidate(j);

            [candidates addObject:[[InputCandidate alloc] initWithInput:[NSString stringWithUTF8String:cand.key.c_str()] candidate:[NSString stringWithUTF8String:cand.value.c_str()] prefix:[NSString stringWithUTF8String:cand.prefix.c_str()] suffix:[NSString stringWithUTF8String:cand.suffix.c_str()] description:[NSString stringWithUTF8String:cand.description.c_str()] usage_id:cand.usage_id  usage_title:[NSString stringWithUTF8String:cand.usage_title.c_str()] usage_description:[NSString stringWithUTF8String:cand.usage_description.c_str()] cost:cand.cost wcost:cand.wcost structure_cost:cand.structure_cost lid:cand.lid rid:cand.rid attributes:cand.attributes]];
        }
//        // 先頭の候補以外は無視
//        break;
//    }
    
    self.candidates = candidates.array;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate inputManager:self didCompleteWithCandidates:self.candidates];
    });
}

- (void)commitCandidate:(NSString *)key value:(NSString *)value
{
    mozc::Segments segments;
    MakeSegmentsForPrediction([key UTF8String], &segments);
    AddCandidate([value UTF8String], &segments);
    
    mozc::commands::Request request;
    mozc::composer::Table table;
    mozc::composer::Composer composer(&table, &request);
    mozc::ConversionRequest conversion_request(&composer, &request);

    // 学習させる
    converter->CommitSegmentValue(&segments, 0, 0);
    converter->FinishConversion(conversion_request, &segments);
}


@end

