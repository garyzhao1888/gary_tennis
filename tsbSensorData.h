//
//  pdbData.h
//  ts_tennis_0331
//
//  Created by Master on 3/30/15.
//  Copyright (c) 2015 Master. All rights reserved.
//

#ifndef ts_tennis_0331_pdbData_h
#define ts_tennis_0331_pdbData_h
#import "tsbConst.h"
@class TSJointAngleCalculation;

@interface TSAccGyroTimeData : NSObject
@property(nonatomic,assign) NSInteger frame_index;
@property(nonatomic,assign) double accel_x;
@property(nonatomic,assign) double accel_y;
@property(nonatomic,assign) double accel_z;
@property(nonatomic,assign) double gyro_x;
@property(nonatomic,assign) double gyro_y;
@property(nonatomic,assign) double gyro_z;
@property(nonatomic,assign) double time_stamp;

-(TSAccGyroTimeData *) initWithXYZ:(NSInteger) frame_index
                           accel_x: (double) accel_x accel_y:(double) accel_y accel_z:(double) accel_z
                            gyro_x:(double) gyro_x gyro_y:(double) gyro_y gyro_z:(double)gyro_z
                        time_stamp:(double) time_stamp;
@end

void read_qua_from_log_file(TSJointAngleCalculation *joint_cal, TSSensorPosition sensor_id, NSInteger start_idx, NSInteger data_count);
NSInteger read_raw_data_from_log_file(TSJointAngleCalculation *joint_cal, TSSensorPosition sensor_id, NSInteger start_idx, NSInteger data_count, NSInteger frame_start_index);
NSInteger load_sensor_log_file(TSJointAngleCalculation *joint_cal, NSInteger frame_start_index);

#endif
