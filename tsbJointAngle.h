
//
//  pdbJointAngle.h
//  ts_tennis_0331
//
//  Created by Master on 3/30/15.
//  Copyright (c) 2015 Master. All rights reserved.
//

#ifndef ts_tennis_0331_pdbJointAngle_h
#define ts_tennis_0331_pdbJointAngle_h
#import "tsaQuaternion.h"
#import "tsaRotMatrix.h"
#import "tsbConst.h"

@interface TSJointAngleCalculation : NSObject
@property(nonatomic,assign) NSInteger calibration_index;
@property(nonatomic,assign) NSInteger new_data_start_index;
@property(nonatomic,strong) NSMutableArray *frame_index;
// qua for joint angles
@property(nonatomic,strong) NSMutableArray *trunk_chest_qua;
@property(nonatomic,strong) NSMutableArray *front_head_qua;
@property(nonatomic,strong) NSMutableArray *right_shoulder_qua;
@property(nonatomic,strong) NSMutableArray *right_upper_arm_qua;
@property(nonatomic,strong) NSMutableArray *right_forearm_qua;
@property(nonatomic,strong) NSMutableArray *right_back_palm_qua;
@property(nonatomic,strong) NSMutableArray *right_thigh_qua;
@property(nonatomic,strong) NSMutableArray *left_thigh_qua;
@property(nonatomic,strong) NSMutableArray *right_shank_qua;
@property(nonatomic,strong) NSMutableArray *left_shank_qua;
// other raw data, such as accel, gyro, timestamp
@property(nonatomic,strong) NSMutableArray *left_shank_raw_data;
@property(nonatomic,strong) NSMutableArray *right_shank_raw_data;
@property(nonatomic,strong) NSMutableArray *right_forearm_raw_data;

// static calibration
@property(nonatomic,strong) TSRotMatrix *calib_trunk_a_R_s;
@property(nonatomic,strong) TSRotMatrix *calib_shoulder_s_R_a;
@property(nonatomic,strong) TSRotMatrix *calib_upper_arm_s_R_a;
@property(nonatomic,strong) TSRotMatrix *calib_forearm_s_R_a;
@property(nonatomic,strong) TSRotMatrix *calib_rthigh_s_R_a;
@property(nonatomic,strong) TSRotMatrix *calib_lthigh_s_R_a;
@property(nonatomic,strong) TSRotMatrix *calib_rshank_s_R_a;
@property(nonatomic,strong) TSRotMatrix *calib_lshank_s_R_a;

// joint angles

@property(nonatomic,strong) NSMutableArray *task_angles_trunk;
@property(nonatomic,strong) NSMutableArray *task_angles_st;
@property(nonatomic,strong) NSMutableArray *task_angles_ht;
@property(nonatomic,strong) NSMutableArray *task_angles_elbow;
@property(nonatomic,strong) NSMutableArray *task_angles_rhip;
@property(nonatomic,strong) NSMutableArray *task_angles_rknee;
@property(nonatomic,strong) NSMutableArray *task_angles_lhip;
@property(nonatomic,strong) NSMutableArray *task_angles_lknee;

// stroke param
@property(nonatomic,strong) NSMutableArray *stroke_output_param;

-(TSJointAngleCalculation *) initQuaArray;
-(void) addSensorQuaData:(double) w x:(double) x y:(double) y z:(double) z sensor_pos:(TSSensorPosition) sensor_pos;
-(NSInteger) getCalibrationIndex;
-(void) genCalibRotMatrix:(bool) force_to_do_calibration;
-(void) genJointAngles;
-(int) getGoodStrokesByAngleHT;
-(double) getMinPeakAngleValue:(NSMutableArray *) data dir:(NSInteger) dir
                start_index:(NSInteger) start_index end_index:(NSInteger) end_index;
-(double) getMaxPeakAngleValue:(NSMutableArray *) data dir:(NSInteger) dir
                start_index:(NSInteger) start_index end_index:(NSInteger) end_index;

-(int) getStrokeNumberByTheshold:(NSMutableArray *) data type:(int) type dir:(int)dir threshold:(double) threshold max_array:(NSMutableArray *) max_array;
-(NSInteger) getCountByPeakArray:(NSMutableArray *) data
                     start_index:(NSInteger) start_index end_index:(NSInteger) end_index;
-(NSInteger) getScoreByPeakArray:(NSMutableArray *) data stroke_data:(NSMutableArray *)stroke_data index:(NSInteger) index;
-(double) getStrokeMaxRacquetSpeedByGyro:(NSInteger) peak_index;
-(TSTStrokeType) getStrokeTypeByWrist:(NSInteger) peak_index;
-(void) reportEachStroke;
-(void) generateStrokeParamForEachStoke;
-(void) generateCalibrationStr:(NSMutableString *) str;
-(void) generateJointAngleStr:(NSMutableString *) str;
-(void) generateStrokeParamStr:(NSMutableString *) str;
-(void) getOutPutString:(NSInteger) cal_type  output_type:(NSInteger) output_type
          bvh_file_name:(NSString *) bvh_file_name
        strCalRotMatrix:(NSMutableString *) strCalRotMatrix
        strJointAngle:(NSMutableString *) strJointAngle
        strStroke:(NSMutableString *) strStroke;
-(void) generateBVHFile:(NSString *) file_name;
-(void) generateBVHHierarchy:(NSString *) file_name str:(NSMutableString *) str data_count:(NSInteger) data_count upper_arm_length:(double) upper_arm_length wrist_length:(double) wrist_length trunk_length:(double) trunk_length hip_half_length:(double) hip_half_length thigh_length:(double) thigh_length shank_length:(double) shank_length shoulder_length:(double) shoulder_length scale_length:(double) scale_length;
-(void) delete_useless_data;
-(NSInteger) get_index_from_frame_index:(NSInteger) frame_index;
@end

@interface TSMaxValue : NSObject
@property(nonatomic,assign) double value;
@property(nonatomic,assign) NSInteger index;
-(TSMaxValue *) initWithValueIndex:(double) v index:(NSInteger) index;
@end

#endif
