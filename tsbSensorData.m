
//
//  pdbData.m
//  ts_tennis_0331
//
//  Created by Master on 3/30/15.
//  Copyright (c) 2015 Master. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tsbSensorData.h"
#import "tsbJointAngle.h"
@implementation TSAccGyroTimeData
-(TSAccGyroTimeData *) initWithXYZ:(NSInteger)frame_index accel_x:(double)accel_x accel_y:(double)accel_y accel_z:(double)accel_z gyro_x:(double)gyro_x gyro_y:(double)gyro_y gyro_z:(double)gyro_z time_stamp:(double)time_stamp
{
   self = [super init];
    if (self) {
        self.frame_index = frame_index;
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


NSInteger read_raw_data_from_log_file(TSJointAngleCalculation *joint_cal, TSSensorPosition sensor_id, NSInteger start_idx, NSInteger data_count, NSInteger frame_start_index)
{
    NSMutableArray *raw_data = nil;
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
        raw_data = joint_cal.right_forearm_raw_data;
        file_name = @"/gary/tennis/0318/right_wrist.log";
    } else if (sensor_id == TSSensorAtRightBackPalm) {
        file_name = @"/gary/tennis/0318/right_back_palm.log";
    } else if (sensor_id == TSSensorAtLeftThigh) {
        file_name = @"/gary/tennis/0318/left_thigh.log";
    } else if (sensor_id == TSSensorAtRightThigh) {
        file_name = @"/gary/tennis/0318/right_thigh.log";
    } else if (sensor_id == TSSensorAtLeftShank) {
        file_name = @"/gary/tennis/0318/left_shank.log";
        raw_data = joint_cal.left_shank_raw_data;
    } else if (sensor_id == TSSensorAtRightShank) {
        file_name = @"/gary/tennis/0318/right_shank.log";
        raw_data = joint_cal.right_shank_raw_data;
    }
    /*if (sensor_id == TSSensorAtFrontHead) {
     file_name = @"/gary/tennis/0223/front_head.log";
     } else if (sensor_id == TSSensorAtTrunkChest) {
     file_name = @"/gary/tennis/0223/trunk_chest.log";
     } else if (sensor_id == TSSensorAtRightShoulder) {
     file_name = @"/gary/tennis/0223/right_shoulder.log";
     } else if (sensor_id == TSSensorAtRightUpperArm) {
     file_name = @"/gary/tennis/0223/right_upper_arm.log";
     } else if (sensor_id == TSSensorAtRightForearm) {
     raw_data = joint_cal.right_forearm_raw_data;
     file_name = @"/gary/tennis/0223/right_wrist.log";
     } else if (sensor_id == TSSensorAtRightBackPalm) {
     file_name = @"/gary/tennis/0223/right_back_palm.log";
     } else if (sensor_id == TSSensorAtLeftThigh) {
     file_name = @"/gary/tennis/0223/left_thigh.log";
     } else if (sensor_id == TSSensorAtRightThigh) {
     file_name = @"/gary/tennis/0223/right_thigh.log";
     } else if (sensor_id == TSSensorAtLeftShank) {
     file_name = @"/gary/tennis/0223/left_shank.log";
     raw_data = joint_cal.left_shank_raw_data;
     } else if (sensor_id == TSSensorAtRightShank) {
     file_name = @"/gary/tennis/0223/right_shank.log";
     raw_data = joint_cal.right_shank_raw_data;
    }*/
    
    if (file_name == 0 || (raw_data == nil)) {
        return 0;
    }
    NSString *raw_data_str = [NSString stringWithContentsOfFile:file_name encoding:NSUTF8StringEncoding error:nil];
    NSArray *raw_data_array = [raw_data_str componentsSeparatedByString:@"\n"];
    NSInteger count = [raw_data_array count];
    if (count > MAX_DATA_NUMBER) {
        count = MAX_DATA_NUMBER - 1;
    }
    //return 0;
    int cur_idx = 0;
    int real_count = 0;
    for (int i = 10; i < count; i ++) {
        NSString *one_line_str = [raw_data_array objectAtIndex:i];
        NSArray *one_line_array = [one_line_str componentsSeparatedByString:@","];
        NSInteger cur_count = [one_line_array count];
        //continue;
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
        NSInteger cur_frame_index = frame_start_index + real_count;
        [raw_data addObject:[[TSAccGyroTimeData alloc] initWithXYZ:cur_frame_index accel_x:accel_x accel_y:accel_y accel_z:accel_z gyro_x:gyro_x gyro_y:gyro_y gyro_z:gyro_z time_stamp:time_stamp]];
        real_count ++;
        
    }
    return real_count;
}

void read_qua_from_log_file(TSJointAngleCalculation *joint_cal, TSSensorPosition sensor_id, NSInteger start_idx, NSInteger data_count)
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
    /*if (sensor_id == TSSensorAtFrontHead) {
        file_name = @"/gary/tennis/0223/front_head.log";
    } else if (sensor_id == TSSensorAtTrunkChest) {
        file_name = @"/gary/tennis/0223/trunk_chest.log";
    } else if (sensor_id == TSSensorAtRightShoulder) {
        file_name = @"/gary/tennis/0223/right_shoulder.log";
    } else if (sensor_id == TSSensorAtRightUpperArm) {
        file_name = @"/gary/tennis/0223/right_upper_arm.log";
    } else if (sensor_id == TSSensorAtRightForearm) {
        
        file_name = @"/gary/tennis/0223/right_wrist.log";
    } else if (sensor_id == TSSensorAtRightBackPalm) {
        file_name = @"/gary/tennis/0223/right_back_palm.log";
    } else if (sensor_id == TSSensorAtLeftThigh) {
        file_name = @"/gary/tennis/0223/left_thigh.log";
    } else if (sensor_id == TSSensorAtRightThigh) {
        file_name = @"/gary/tennis/0223/right_thigh.log";
    } else if (sensor_id == TSSensorAtLeftShank) {
        file_name = @"/gary/tennis/0223/left_shank.log";
        
    } else if (sensor_id == TSSensorAtRightShank) {
        file_name = @"/gary/tennis/0223/right_shank.log";
        
    }*/
    if (file_name == 0) {
        return;
    }
    NSString *raw_data_str = [NSString stringWithContentsOfFile:file_name encoding:NSUTF8StringEncoding error:nil];
    NSArray *raw_data_array = [raw_data_str componentsSeparatedByString:@"\n"];
    NSInteger count = [raw_data_array count];
    if (count > MAX_DATA_NUMBER) {
        count = MAX_DATA_NUMBER - 1;
    }
    //return;
    int cur_idx = 0;
    for (int i = 10; i < count; i ++) {
        NSString *one_line_str = [raw_data_array objectAtIndex:i];
        NSArray *one_line_array = [one_line_str componentsSeparatedByString:@","];
        NSInteger cur_count = [one_line_array count];
        if (cur_count < 22) {
            continue;
        }
        //continue;
        cur_idx ++;
        if (cur_idx < start_idx) {
            continue;
        }
        if (cur_idx >= (start_idx + data_count)) {
            break;
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
        [joint_cal addSensorQuaData:w x:x y:y z:z sensor_pos:sensor_id];
    }
}


NSInteger load_sensor_log_file(TSJointAngleCalculation *joint_cal, NSInteger frame_start_index)
{
    NSInteger trunk_start = 41940;
    NSInteger trial_range = 54060 - trunk_start;
    // NSInteger trial_range = 46000 - trunk_start;
    NSInteger shoulder_start = 39550;
    NSInteger upper_arm_start = 39430;
    NSInteger forearm_start = 29210;
    NSInteger rthigh_start = 34650;
    NSInteger rshank_start = 39490;
    NSInteger lthigh_start = 39430;
    NSInteger lshank_start = 23280;
    
    /*NSInteger trunk_start = 1;
    NSInteger trial_range = 20000 - trunk_start;
    // NSInteger trial_range = 46000 - trunk_start;
    NSInteger shoulder_start = 1;
    NSInteger upper_arm_start = 1;
    NSInteger forearm_start = 1;
    NSInteger rthigh_start = 1;
    NSInteger rshank_start = 1;
    NSInteger lthigh_start = 1;
    NSInteger lshank_start = 1;
    */
    
    NSInteger data_count = trial_range;
    NSInteger real_count = 0;
    // get the input raw data and quaternion data
    real_count = read_raw_data_from_log_file(joint_cal,
                                             TSSensorAtRightForearm, forearm_start, data_count,frame_start_index);
    
    
    read_raw_data_from_log_file(joint_cal, TSSensorAtRightShank, rshank_start, data_count,frame_start_index);
    read_raw_data_from_log_file(joint_cal, TSSensorAtLeftShank, lshank_start, data_count,frame_start_index);
    
    
    read_qua_from_log_file(joint_cal, TSSensorAtTrunkChest,trunk_start,data_count);
    read_qua_from_log_file(joint_cal, TSSensorAtRightShoulder,shoulder_start,data_count);
    read_qua_from_log_file(joint_cal, TSSensorAtRightUpperArm,upper_arm_start,data_count);
    read_qua_from_log_file(joint_cal, TSSensorAtRightForearm,forearm_start,data_count);
    read_qua_from_log_file(joint_cal, TSSensorAtRightThigh,rthigh_start,data_count);
    read_qua_from_log_file(joint_cal, TSSensorAtLeftThigh,lthigh_start,data_count);
    read_qua_from_log_file(joint_cal, TSSensorAtRightShank,rshank_start,data_count);
    read_qua_from_log_file(joint_cal, TSSensorAtLeftShank,lshank_start,data_count);
    
    for (NSInteger i = 0; i < real_count; i ++) {
        NSInteger cur_frame_index = frame_start_index + i;
        [joint_cal.frame_index addObject:[[NSNumber alloc] initWithInteger:cur_frame_index]];
    }
    return real_count;
    
}

