//
//  main.m
//  ts_tennis_0331
//
//  Created by Master on 3/30/15.
//  Copyright (c) 2015 Master. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tsbJointAngle.h"
#import "tsbSensorData.h"
#import "tsbTennisData.h"
void process_tennis()
{
    NSMutableString *strCalRotMatrix = [[NSMutableString alloc] init];
    NSMutableString *strJointAngle = [[NSMutableString alloc] init];
    NSMutableString *strStroke = [[NSMutableString alloc] init];
    NSString *bvh_file_name = nil;
    /*NSDate *cur_time = [NSDate date];
     NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
     [formatter setDateFormat:@"yyyy_mm_dd_hh_mm_ss"];
     NSString *bvh_file_name = [NSString stringWithFormat:@"/gary/tennis/0225/ios_joint_angle_sensor_%d_%@.bvh", 8, [formatter stringFromDate:cur_time]]; */
    TSJointAngleCalculation *joint_cal = [[TSJointAngleCalculation alloc] initQuaArray];
    NSInteger frame_start_index = 0;
    for (int i = 0; i < 1; i ++) {
        frame_start_index = frame_start_index + load_sensor_log_file(joint_cal, frame_start_index);
        //continue;
        //return 0;
        NSInteger cal_type = (1 << TSJointAngleUpdateData);
        NSInteger output_type = (1 << TSJointAngleStrokeParam);
        if (i == 0) {
            cal_type = cal_type + (1 << TSJointAngleCalibration);
        }
        /*if (i == 1) {
         cal_type = (1 << TSJointAngleReadData);
         output_type = (1 << TSJointangleNone);
         }*/
        
        [joint_cal getOutPutString:cal_type output_type:output_type
                     bvh_file_name:bvh_file_name strCalRotMatrix:strCalRotMatrix strJointAngle:strJointAngle strStroke: strStroke];
        //NSLog(@"%@", strJointAngle);
        //NSLog(@"%@", strStroke);
    }

}


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        // output of joint angles
        process_tennis();
    }
    return 0;
}
