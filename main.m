//
//  main.m
//  ts_tennis_0325
//
//  Created by Master on 3/26/15.
//  Copyright (c) 2015 Master. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "joint_angle.h"
#import "sensor_data.h"
//#import "load_log_file.m"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        // get the input raw data and quaternion data
        NSMutableArray *right_forearm_raw_data = [NSMutableArray arrayWithCapacity:data_count];
        read_raw_data_from_log_file(right_forearm_raw_data,TSSensorAtRightForearm,forearm_start,data_count);
        
        NSMutableArray *right_shank_raw_data = [NSMutableArray arrayWithCapacity:data_count];
        read_raw_data_from_log_file(right_shank_raw_data, TSSensorAtRightShank, rshank_start, data_count);
        
        NSMutableArray *left_shank_raw_data = [NSMutableArray arrayWithCapacity:data_count];
        read_raw_data_from_log_file(left_shank_raw_data, TSSensorAtLeftShank, lshank_start, data_count);
        
        TSJointAngleCalculation *joint_cal = [[TSJointAngleCalculation alloc] initQuaArray];
        read_qua_from_log_file(joint_cal, TSSensorAtTrunkChest);
        read_qua_from_log_file(joint_cal, TSSensorAtRightShoulder);
        read_qua_from_log_file(joint_cal, TSSensorAtRightUpperArm);
        read_qua_from_log_file(joint_cal, TSSensorAtRightForearm);
        read_qua_from_log_file(joint_cal, TSSensorAtRightThigh);
        read_qua_from_log_file(joint_cal, TSSensorAtLeftThigh);
        read_qua_from_log_file(joint_cal, TSSensorAtRightShank);
        read_qua_from_log_file(joint_cal, TSSensorAtLeftShank);
        
        // generate joint angles
        [joint_cal genCalibRotMatrix];
        [joint_cal genJointAngles];
        
        // bvh file generation
        /*NSDate *cur_time = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy_mm_dd_hh_mm_ss"];
        NSString *bvh_file_name = [NSString stringWithFormat:@"/gary/tennis/0225/ios_joint_angle_sensor_%d_%@.bvh", 8, [formatter stringFromDate:cur_time]];
        [joint_cal generateBVHFile:bvh_file_name];
        */
        
        // get good stroke number
        int goodStrokeNumber = [joint_cal getGoodStrokesByAngleHT];
        NSLog(@"Good Stroke number is %d\n", goodStrokeNumber);
        
        // get step, stroke number by accel in Y direction
        // stroke number got from right forearm accel in Y direction

        NSMutableArray *right_forearm_peak_array = [NSMutableArray arrayWithCapacity:data_count];
        int nStrokesAcc = [joint_cal getStrokeNumberByTheshold:right_forearm_raw_data type:1 dir:2 threshold:STROKE_MIN_ACCEL_Y max_array:right_forearm_peak_array];
        
        NSLog(@"nstrokesAcc = %d \n", nStrokesAcc);
        
        // steps

        NSMutableArray *right_shank_peak_array = [NSMutableArray arrayWithCapacity:data_count];
        int nStepsRShank = [joint_cal getStrokeNumberByTheshold:right_shank_raw_data type:1 dir:2 threshold:SHANK_STEP_MIN_ACCEL_Y max_array:right_shank_peak_array];
        NSLog(@"nStepsRShank  = %d \n", nStepsRShank);
        

        NSMutableArray *left_shank_peak_array = [NSMutableArray arrayWithCapacity:data_count];
        int nStepsLShank = [joint_cal getStrokeNumberByTheshold:left_shank_raw_data type:1 dir:2 threshold:SHANK_STEP_MIN_ACCEL_Y max_array:left_shank_peak_array];
        NSLog(@"nStepsLShank  = %d \n", nStepsLShank);

        [joint_cal reportStepsForEachStroke:right_forearm_peak_array left_shank_peak_array:left_shank_peak_array right_shank_peak_array:right_shank_peak_array];
        
    }
    return 0;
}
