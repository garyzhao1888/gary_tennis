//
//  sensor_data.h
//  ts_tennis_0325
//
//  Created by Master on 3/26/15.
//  Copyright (c) 2015 Master. All rights reserved.
//

#ifndef ts_tennis_0325_sensor_data_h
#define ts_tennis_0325_sensor_data_h
#import <Foundation/Foundation.h>
static const int MAX_DATA_NUMBER = 100000;
static const double PI = M_PI;
static const int SHOULDER_TRUNK_ANGLE_X = 80;
static const int SHOULDER_TRUNK_ANGLE_Y = 150;
static const int SHOULDER_TRUNK_ANGLE_Z = 70;
static const int STROKE_MIN_TIME = 50;
static const double STROKE_MIN_ACCEL_Y = 8;
static const double SHANK_STEP_MIN_ACCEL_Y = 1.2;
static const int STATIC_INDEX = 5;


static const NSInteger trunk_start = 41940;
static const NSInteger trial_range = 54060 - trunk_start;
static const NSInteger shoulder_start = 39550;
static const NSInteger upper_arm_start = 39430;
static const NSInteger forearm_start = 29210;
static const NSInteger rthigh_start = 34650;
static const NSInteger rshank_start = 39490;
static const NSInteger lthigh_start = 39430;
static const NSInteger lshank_start = 23280;
static const NSInteger data_count = trial_range;


@interface TSAccGyroTimeData : NSObject
@property(nonatomic,assign) double accel_x;
@property(nonatomic,assign) double accel_y;
@property(nonatomic,assign) double accel_z;
@property(nonatomic,assign) double gyro_x;
@property(nonatomic,assign) double gyro_y;
@property(nonatomic,assign) double gyro_z;
@property(nonatomic,assign) double time_stamp;

-(TSAccGyroTimeData *) initWithXYZ:(double) accel_x accel_y:(double) accel_y accel_z:(double) accel_z
                            gyro_x:(double) gyro_x gyro_y:(double) gyro_y gyro_z:(double)gyro_z
                        time_stamp:(double) time_stamp;
@end

void read_qua_from_log_file(TSJointAngleCalculation *joint_cal, TSSensorPosition sensor_id);
void read_raw_data_from_log_file(NSMutableArray *raw_data, TSSensorPosition sensor_id, NSInteger start_idx, NSInteger data_count);
#endif
