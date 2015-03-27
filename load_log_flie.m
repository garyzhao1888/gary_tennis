//
//  read_log_file.m
//  ts_tennis_0325
//
//  Created by Master on 3/26/15.
//  Copyright (c) 2015 Master. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "joint_angle.h"
#import "sensor_data.h"



@implementation TSAccGyroTimeData
-(TSAccGyroTimeData *) initWithXYZ:(double)accel_x accel_y:(double)accel_y accel_z:(double)accel_z gyro_x:(double)gyro_x gyro_y:(double)gyro_y gyro_z:(double)gyro_z time_stamp:(double)time_stamp {
    self = [super init];
    if (self) {
        self.accel_x = accel_x/65536;
        self.accel_y = accel_y/65536;
        self.accel_z = accel_z/65536;
        self.gyro_x = gyro_x/65536;
        self.gyro_y = gyro_y/65536;
        self.gyro_z = gyro_z/65536;
        self.time_stamp = time_stamp/100;
    }
    return self;
}
@end

void read_raw_data_from_log_file(NSMutableArray *raw_data, int sensor_id, NSInteger start_idx, NSInteger data_count)
{
    NSString *file_name = 0;
    if (sensor_id == TSSensorAtFrontHead) {
        file_name = @"/gary/tennis/0318/front_head.log";
    } else if (sensor_id == TSSensorAtTrunkChest) {
        file_name = @"/gary/tennis/0318/trunk_chest.log";
    } else if (sensor_id == TSSensorAtRightShoulder) {
        file_name = @"/gary/tennis/0318/right_shoulder.log";
    } else if (sensor_id == TSSensorAtRightUpperArm) {
        file_name = @"/gary/tennis/0318/right_upper_arm.log";
    } else if (sensor_id == TSSensorAtRightForearm) {
        file_name = @"/gary/tennis/0318/right_wrist.log";
    } else if (sensor_id == TSSensorAtRightBackPalm) {
        file_name = @"/gary/tennis/0318/right_back_palm.log";
    } else if (sensor_id == TSSensorAtLeftThigh) {
        file_name = @"/gary/tennis/0318/left_thigh.log";
    } else if (sensor_id == TSSensorAtRightThigh) {
        file_name = @"/gary/tennis/0318/right_thigh.log";
    } else if (sensor_id == TSSensorAtLeftShank) {
        file_name = @"/gary/tennis/0318/left_shank.log";
    } else if (sensor_id == TSSensorAtRightShank) {
        file_name = @"/gary/tennis/0318/right_shank.log";
    }
    if (file_name == 0) {
        return;
    }
    NSString *raw_data_str = [NSString stringWithContentsOfFile:file_name encoding:NSUTF8StringEncoding error:nil];
    NSArray *raw_data_array = [raw_data_str componentsSeparatedByString:@"\n"];
    NSInteger count = [raw_data_array count];
    if (count > MAX_DATA_NUMBER) {
        count = MAX_DATA_NUMBER - 1;
    }
    int cur_idx = 0;
    for (int i = 10; i < count; i ++) {
        NSString *one_line_str = [raw_data_array objectAtIndex:i];
        NSArray *one_line_array = [one_line_str componentsSeparatedByString:@","];
        NSInteger cur_count = [one_line_array count];
        if (cur_count < 22) {
            continue;
        }
        cur_idx ++;
        if (cur_idx < start_idx) {
            continue;
        }
        if (cur_idx >= (start_idx + data_count)) {
            break;
        }
        double time_stamp = [[one_line_array objectAtIndex:2] doubleValue];
        
        double gyro_x = [[one_line_array objectAtIndex:3] doubleValue];
        double gyro_y = [[one_line_array objectAtIndex:4] doubleValue];
        double gyro_z = [[one_line_array objectAtIndex:5] doubleValue];
        
        double accel_x = [[one_line_array objectAtIndex:6] doubleValue];
        double accel_y = [[one_line_array objectAtIndex:7] doubleValue];
        double accel_z = [[one_line_array objectAtIndex:8] doubleValue];
        [raw_data addObject:[[TSAccGyroTimeData alloc] initWithXYZ:accel_x accel_y:accel_y accel_z:accel_z gyro_x:gyro_x gyro_y:gyro_y gyro_z:gyro_z time_stamp:time_stamp]];
    }
}

void read_qua_from_log_file(TSJointAngleCalculation *joint_cal, TSSensorPosition sensor_id)
{
    NSString *file_name = 0;
    if (sensor_id == TSSensorAtFrontHead) {
        file_name = @"/gary/tennis/0318/front_head.log";
    } else if (sensor_id == TSSensorAtTrunkChest) {
        file_name = @"/gary/tennis/0318/trunk_chest.log";
    } else if (sensor_id == TSSensorAtRightShoulder) {
        file_name = @"/gary/tennis/0318/right_shoulder.log";
    } else if (sensor_id == TSSensorAtRightUpperArm) {
        file_name = @"/gary/tennis/0318/right_upper_arm.log";
    } else if (sensor_id == TSSensorAtRightForearm) {
        file_name = @"/gary/tennis/0318/right_wrist.log";
    } else if (sensor_id == TSSensorAtRightBackPalm) {
        file_name = @"/gary/tennis/0318/right_back_palm.log";
    } else if (sensor_id == TSSensorAtLeftThigh) {
        file_name = @"/gary/tennis/0318/left_thigh.log";
    } else if (sensor_id == TSSensorAtRightThigh) {
        file_name = @"/gary/tennis/0318/right_thigh.log";
    } else if (sensor_id == TSSensorAtLeftShank) {
        file_name = @"/gary/tennis/0318/left_shank.log";
    } else if (sensor_id == TSSensorAtRightShank) {
        file_name = @"/gary/tennis/0318/right_shank.log";
    }
    if (file_name == 0) {
        return;
    }
    NSString *raw_data_str = [NSString stringWithContentsOfFile:file_name encoding:NSUTF8StringEncoding error:nil];
    NSArray *raw_data_array = [raw_data_str componentsSeparatedByString:@"\n"];
    NSInteger count = [raw_data_array count];
    if (count > MAX_DATA_NUMBER) {
        count = MAX_DATA_NUMBER - 1;
    }
    
    for (int i = 10; i < count; i ++) {
        NSString *one_line_str = [raw_data_array objectAtIndex:i];
        NSArray *one_line_array = [one_line_str componentsSeparatedByString:@","];
        NSInteger cur_count = [one_line_array count];
        if (cur_count < 22) {
            continue;
        }
        NSInteger qua_w = [[one_line_array objectAtIndex:9] integerValue];
        NSInteger qua_x = [[one_line_array objectAtIndex:10] integerValue];
        NSInteger qua_y = [[one_line_array objectAtIndex:11] integerValue];
        NSInteger qua_z = [[one_line_array objectAtIndex:12] integerValue];
        // normalize
        double temp = sqrt(qua_w*qua_w + qua_x*qua_x+qua_y*qua_y+qua_z*qua_z);
        double w = qua_w/temp;
        double x = qua_x/temp;
        double y = qua_y/temp;
        double z = qua_z/temp;
        TSQuater *qua = [[TSQuater alloc] init];
        qua.w = w;
        qua.x = x;
        qua.y = y;
        qua.z = z;
        [joint_cal addSensorQuaData:qua sensor_pos:sensor_id];
    }
}
