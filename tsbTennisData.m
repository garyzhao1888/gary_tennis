//
//  tsbTennisData.m
//  ts_tennis_0331
//
//  Created by Master on 3/30/15.
//  Copyright (c) 2015 Master. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tsbTennisData.h"
@implementation TSTennisOutPutData
-(TSTennisOutPutData *) initWithUnit
{
    self = [super init];
    if (self) {
        self.index = 0;
        self.frame_start_index = 0;
        self.frame_end_index = 0;
        self.stroke_type = 0;
        self.stroke_subtype = 0;
        self.racquet_speed = 0;
        self.left_step = 0;
        self.right_step = 0;
        self.left_knee_bend_degree = 0;
        self.right_knee_bend_degree = 0;
        self.right_shoulder_elevaction_degree = 0;
        self.jump_height = 0;
        self.good_stroke = FALSE;
        self.score = 0;
    }
    return self;
}

-(void) resetValue
{
    if (self) {
        self.index = 0;
        self.frame_start_index = 0;
        self.frame_end_index = 0;
        self.stroke_type = 0;
        self.stroke_subtype = 0;
        self.racquet_speed = 0;
        self.left_step = 0;
        self.right_step = 0;
        self.left_knee_bend_degree = 0;
        self.right_knee_bend_degree = 0;
        self.right_shoulder_elevaction_degree = 0;
        self.jump_height = 0;
        self.good_stroke = FALSE;
        self.score = 0;
    }
}


-(TSTennisOutPutData *) initWithTennisOutputData:(TSTennisOutPutData *)one_stroke
{
    self = [super init];
    if (self) {
        self.index = one_stroke.index;
        self.frame_start_index = one_stroke.frame_start_index;
        self.frame_end_index = one_stroke.frame_end_index;
        self.stroke_type = one_stroke.stroke_type;
        self.stroke_subtype = one_stroke.stroke_subtype;
        self.racquet_speed = one_stroke.racquet_speed;
        self.left_step = one_stroke.left_step;
        self.right_step = one_stroke.right_step;
        self.left_knee_bend_degree = one_stroke.left_knee_bend_degree;
        self.right_knee_bend_degree = one_stroke.right_knee_bend_degree;
        self.right_shoulder_elevaction_degree = one_stroke.right_shoulder_elevaction_degree;
        self.jump_height = one_stroke.jump_height;
        self.good_stroke = one_stroke.good_stroke;
        self.score = one_stroke.score;
    }
    return self;
}

-(TSTennisOutPutData *) initWithValue:(NSInteger)index frame_start_index:(NSInteger)frame_start_index frame_end_index:(NSInteger)frame_end_index stroke_type:(NSInteger)stroke_type stroke_subtype:(NSInteger)stroke_subtype racquet_speed:(double)racquet_speed left_step:(NSInteger)left_step right_step:(NSInteger)right_step left_knee_bend_degree:(double)left_knee_bend_degree right_knee_bend_degree:(double)right_knee_bend_degree right_shoulder_elevaction_degree:(double)right_shoulder_elevaction_degree jump_height:(double)jump_height good_stroke:(bool)good_stroke score:(NSInteger) score
{
    self = [super init];
    if (self) {
        self.index = index;
        self.frame_start_index = frame_start_index;
        self.frame_end_index = frame_end_index;
        self.stroke_type = stroke_type;
        self.stroke_subtype = stroke_subtype;
        self.racquet_speed = racquet_speed;
        self.left_step = left_step;
        self.right_step = right_step;
        self.left_knee_bend_degree = left_knee_bend_degree;
        self.right_knee_bend_degree = right_knee_bend_degree;
        self.right_shoulder_elevaction_degree = right_shoulder_elevaction_degree;
        self.jump_height = jump_height;
        self.good_stroke = good_stroke;
        self.score = score;
    }
    return self;
}


@end