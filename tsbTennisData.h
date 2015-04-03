//
//  pdbTennisData.h
//  ts_tennis_0331
//
//  Created by Master on 3/30/15.
//  Copyright (c) 2015 Master. All rights reserved.
//

#ifndef ts_tennis_0331_pdbTennisData_h
#define ts_tennis_0331_pdbTennisData_h
@interface TSTennisOutPutData : NSObject
@property(nonatomic,assign) NSInteger index;
@property(nonatomic,assign) NSInteger frame_start_index;
@property(nonatomic,assign) NSInteger frame_end_index;
@property(nonatomic,assign) NSInteger stroke_type;
@property(nonatomic,assign) NSInteger stroke_subtype;
@property(nonatomic,assign) double racquet_speed;
@property(nonatomic,assign) NSInteger left_step;
@property(nonatomic,assign) NSInteger right_step;
@property(nonatomic,assign) double left_knee_bend_degree;
@property(nonatomic,assign) double right_knee_bend_degree;
@property(nonatomic,assign) double right_shoulder_elevaction_degree;
@property(nonatomic,assign) double jump_height;
@property(nonatomic,assign) NSInteger score;
@property(nonatomic,assign) bool good_stroke;

-(TSTennisOutPutData *) initWithUnit;
-(TSTennisOutPutData *) initWithTennisOutputData:(TSTennisOutPutData *) one_stroke;
-(void) resetValue;
-(TSTennisOutPutData *) initWithValue:(NSInteger)index frame_start_index:(NSInteger) frame_start_index
    frame_end_index:(NSInteger) frame_end_index
    stroke_type:(NSInteger) stroke_type
    stroke_subtype:(NSInteger) stroke_subtype
    racquet_speed:(double) racquet_speed
    left_step:(NSInteger) left_step
    right_step:(NSInteger) right_step
    left_knee_bend_degree:(double) left_knee_bend_degree
    right_knee_bend_degree:(double) right_knee_bend_degree
    right_shoulder_elevaction_degree:(double) right_shoulder_elevaction_degree
    jump_height:(double) jump_height
    good_stroke:(bool) good_stroke
    score:(NSInteger) score;

@end
#endif
