//
//  pdbJointAngle.m
//  ts_tennis_0331
//
//  Created by Master on 3/30/15.
//  Copyright (c) 2015 Master. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tsbJointAngle.h"
#import "tsaQuaternion.h"
#import "tsaEuler.h"
#import "tsaVector.h"
#import "tsaRotMatrix.h"
#import "tsbConst.h"
#import "tsbSensorData.h"
#import "tsbTennisData.h"

@implementation TSMaxValue
-(TSMaxValue *) initWithValueIndex:(double)v index:(NSInteger)index {
    self = [super init];
    if (self) {
        self.value = v;
        self.index = index;
    }
    return self;
}
@end


@implementation TSJointAngleCalculation
-(TSJointAngleCalculation *) initQuaArray {
    self = [super init];
    if (self) {
        self.calibration_index = 0;
        self.new_data_start_index = 0;
        self.trunk_chest_qua = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.front_head_qua = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.right_shoulder_qua = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.right_upper_arm_qua = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.right_forearm_qua = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.right_back_palm_qua = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.right_thigh_qua = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.left_thigh_qua = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.right_shank_qua = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.left_shank_qua = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.calib_trunk_a_R_s = [[TSRotMatrix alloc] init];
        self.calib_shoulder_s_R_a = [[TSRotMatrix alloc] init];
        self.calib_upper_arm_s_R_a = [[TSRotMatrix alloc] init];
        self.calib_forearm_s_R_a = [[TSRotMatrix alloc] init];
        self.calib_rthigh_s_R_a = [[TSRotMatrix alloc] init];
        self.calib_lthigh_s_R_a = [[TSRotMatrix alloc] init];
        self.calib_rshank_s_R_a = [[TSRotMatrix alloc] init];
        self.calib_lshank_s_R_a = [[TSRotMatrix alloc] init];
        
        self.frame_index = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.task_angles_trunk = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.task_angles_st = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.task_angles_ht = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.task_angles_elbow = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.task_angles_rhip = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.task_angles_rknee = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.task_angles_lhip = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.task_angles_lknee = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        
        self.left_shank_raw_data = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.right_shank_raw_data = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.right_forearm_raw_data = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        
        self.stroke_output_param = [NSMutableArray arrayWithCapacity:MAX_STROKE_NUMBER];
    }
    return self;
}


-(void) addSensorQuaData:(double)w x:(double)x y:(double)y z:(double)z sensor_pos:(TSSensorPosition)sensor_pos
{
    NSMutableArray *qua_array = nil;
    if (sensor_pos == TSSensorAtFrontHead) {
        qua_array = self.front_head_qua;
    } else if (sensor_pos == TSSensorAtTrunkChest) {
        qua_array = self.trunk_chest_qua;
    } else if (sensor_pos == TSSensorAtRightShoulder) {
        qua_array = self.right_shoulder_qua;
    } else if (sensor_pos == TSSensorAtRightUpperArm) {
        qua_array = self.right_upper_arm_qua;
    } else if (sensor_pos == TSSensorAtRightForearm) {
        qua_array = self.right_forearm_qua;
    } else if (sensor_pos == TSSensorAtRightBackPalm) {
        qua_array = self.right_back_palm_qua;
    } else if (sensor_pos == TSSensorAtRightThigh) {
        qua_array = self.right_thigh_qua;
    } else if (sensor_pos == TSSensorAtLeftThigh) {
        qua_array = self.left_thigh_qua;
    } else if (sensor_pos == TSSensorAtRightShank) {
        qua_array = self.right_shank_qua;
    } else if (sensor_pos == TSSensorAtLeftShank) {
        qua_array = self.left_shank_qua;
    }
    if (qua_array == nil) {
        return;
    }
    [qua_array addObject:[[TSQuater alloc] initWithWXYZ:w x:x y:y z:z]];
}

-(NSInteger) getCalibrationIndex
{
    // TODO : Fixed me to use more sensor data
    // use trunk_chest, left shank, right shank, right wrist, right shoulder
    // right upper arm to select index to do static calibration
    NSInteger count = [self.right_forearm_raw_data count];
    if (count > [self.right_shank_raw_data count]) {
        count = [self.right_shank_raw_data count];
    }
    if (count > [self.left_shank_raw_data count]) {
        count = [self.left_shank_raw_data count];
    }
    if (count > (STROKE_MIN_TIME * 4)) {
        count = STROKE_MIN_TIME * 4;
    }
    double minv = 0;
    NSInteger minv_index = 0;
    TSAccGyroTimeData *one_data;
    for (int i = 0; i < count; i ++) {
        double curv = 0;
        one_data = [self.right_forearm_raw_data objectAtIndex:i];
        curv = curv + one_data.gyro_x * one_data.gyro_x + one_data.gyro_y * one_data.gyro_y
            + one_data.gyro_z * one_data.gyro_z;
        one_data = [self.left_shank_raw_data objectAtIndex:i];
        curv = curv + one_data.gyro_x * one_data.gyro_x + one_data.gyro_y * one_data.gyro_y
        + one_data.gyro_z * one_data.gyro_z;
        one_data = [self.right_shank_raw_data objectAtIndex:i];
        curv = curv + one_data.gyro_x * one_data.gyro_x + one_data.gyro_y * one_data.gyro_y
        + one_data.gyro_z * one_data.gyro_z;
        if (i == 0 || curv < minv) {
            minv = curv;
            minv_index = i;
        }
    }
    return minv_index;
}


-(void) genCalibRotMatrix:(bool)force_to_do_calibration
{
    if (!force_to_do_calibration && self.calibration_index > 0) {
        return;
    }
    NSInteger static_index = [self getCalibrationIndex];
    
    TSRotMatrix *trunk_rot_matrix = [[TSRotMatrix alloc] init];
    [self.calib_trunk_a_R_s initWithUnit];
    [self.calib_shoulder_s_R_a initWithUnit];
    [self.calib_upper_arm_s_R_a initWithUnit];
    [self.calib_forearm_s_R_a initWithUnit];
    [self.calib_lshank_s_R_a initWithUnit];
    [self.calib_lthigh_s_R_a initWithUnit];
    [self.calib_rshank_s_R_a initWithUnit];
    [self.calib_rthigh_s_R_a initWithUnit];
    // trunk at first
    TSQuater *qua = [self.trunk_chest_qua objectAtIndex:(static_index)];
    
    [trunk_rot_matrix get_rotmatrix_from_qua:qua];
    
    TSRotMatrix *calib_g_trunk = [[TSRotMatrix alloc] init];
    [calib_g_trunk calibration_by_rot_matrix:trunk_rot_matrix];
    TSRotMatrix *calib_g_trunk_t = [[TSRotMatrix alloc] init];
    [calib_g_trunk_t transpose_matrix:calib_g_trunk];
    
    [self.calib_trunk_a_R_s cross_product:calib_g_trunk_t rm2:trunk_rot_matrix];
    
    
    TSRotMatrix *rot_matrix = [[TSRotMatrix alloc] init];
    if ([self.right_shoulder_qua count] > (static_index)) {
        qua = [self.right_shoulder_qua objectAtIndex:(static_index)];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [self.calib_shoulder_s_R_a sensor_to_segment_calibration:rot_matrix trunk_rm:trunk_rot_matrix calib_g_trunk:calib_g_trunk];
    }
    
    
    if ([self.right_upper_arm_qua count] > (static_index)) {
        qua = [self.right_upper_arm_qua objectAtIndex:(static_index)];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [self.calib_upper_arm_s_R_a sensor_to_segment_calibration:rot_matrix trunk_rm:trunk_rot_matrix calib_g_trunk:calib_g_trunk];
    }
    
    if ([self.right_forearm_qua count] > (static_index)) {
        qua = [self.right_forearm_qua objectAtIndex:(static_index)];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [self.calib_forearm_s_R_a sensor_to_segment_calibration:rot_matrix trunk_rm:trunk_rot_matrix calib_g_trunk:calib_g_trunk];
    }
    
    if ([self.right_shank_qua count] > (static_index)) {
        qua = [self.right_shank_qua objectAtIndex:(static_index)];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [self.calib_rshank_s_R_a sensor_to_segment_calibration:rot_matrix trunk_rm:trunk_rot_matrix calib_g_trunk:calib_g_trunk];
    }
    
    if ([self.left_shank_qua count] > (static_index)) {
        qua = [self.left_shank_qua objectAtIndex:(static_index)];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [self.calib_lshank_s_R_a sensor_to_segment_calibration:rot_matrix trunk_rm:trunk_rot_matrix calib_g_trunk:calib_g_trunk];
    }
    
    if ([self.right_thigh_qua count] > (static_index)) {
        qua = [self.right_thigh_qua objectAtIndex:(static_index)];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [self.calib_rthigh_s_R_a sensor_to_segment_calibration:rot_matrix trunk_rm:trunk_rot_matrix calib_g_trunk:calib_g_trunk];
    }
    
    if ([self.left_thigh_qua count] > (static_index)) {
        qua = [self.left_thigh_qua objectAtIndex:(static_index)];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [self.calib_lthigh_s_R_a sensor_to_segment_calibration:rot_matrix trunk_rm:trunk_rot_matrix calib_g_trunk:calib_g_trunk];
    }
    self.calibration_index = static_index;
}

-(void) genJointAngles {
    NSInteger data_count = [self.trunk_chest_qua count];
    if (data_count > [self.right_shoulder_qua count]) {
        data_count = [self.right_shoulder_qua count];
    }
    if (data_count > [self.right_upper_arm_qua count]) {
        data_count = [self.right_upper_arm_qua count];
    }
    if (data_count > [self.right_forearm_qua count]) {
        data_count = [self.right_forearm_qua count];
    }
    if (data_count > [self.left_shank_qua count]) {
        data_count = [self.left_shank_qua count];
    }
    if (data_count > [self.right_shank_qua count]) {
        data_count = [self.right_shank_qua count];
    }
    if (data_count > [self.left_thigh_qua count]) {
        data_count = [self.left_thigh_qua count];
    }
    if (data_count > [self.right_thigh_qua count]) {
        data_count = [self.right_thigh_qua count];
    }
    data_count = data_count - self.new_data_start_index;
    if (data_count <= 0) {
        return;
    }
    
    NSMutableArray *trunk_chest_rot_matrix = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *shoulder_rot_matrix = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *upper_arm_rot_matrix = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *forearm_rot_matrix = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *rthigh_rot_matrix = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *rshank_rot_matrix = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *lthigh_rot_matrix = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *lshank_rot_matrix = [NSMutableArray arrayWithCapacity:data_count];
    
    for (NSInteger j = 0; j < data_count; j ++) {
        NSInteger i = j + self.new_data_start_index;
        TSQuater *qua;
        TSRotMatrix *rot_matrix = [[TSRotMatrix alloc] init];
        qua = [self.trunk_chest_qua objectAtIndex:i];

        [rot_matrix get_rotmatrix_from_qua:qua];
        [trunk_chest_rot_matrix addObject:[[TSRotMatrix alloc] initWithName:rot_matrix]];
        
   
        qua = [self.right_shoulder_qua objectAtIndex:i];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [shoulder_rot_matrix addObject:[[TSRotMatrix alloc] initWithName:rot_matrix]];
        
        qua = [self.right_upper_arm_qua objectAtIndex:i];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [upper_arm_rot_matrix addObject:[[TSRotMatrix alloc] initWithName:rot_matrix]];
        
        qua = [self.right_forearm_qua objectAtIndex:i];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [forearm_rot_matrix addObject:[[TSRotMatrix alloc] initWithName:rot_matrix]];
        
        qua = [self.right_thigh_qua objectAtIndex:i];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [rthigh_rot_matrix addObject:[[TSRotMatrix alloc] initWithName:rot_matrix]];
        
        qua = [self.right_shank_qua objectAtIndex:i];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [rshank_rot_matrix addObject:[[TSRotMatrix alloc] initWithName:rot_matrix]];
        
        qua = [self.left_thigh_qua objectAtIndex:i];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [lthigh_rot_matrix addObject:[[TSRotMatrix alloc] initWithName:rot_matrix]];
        
        qua = [self.left_shank_qua objectAtIndex:i];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [lshank_rot_matrix addObject:[[TSRotMatrix alloc] initWithName:rot_matrix]];
    }
    
    NSMutableArray *task_trunk_g_r_a = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *task_shoulder_g_r_a = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *task_upper_arm_g_r_a = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *task_forearm_g_r_a = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *task_rthigh_g_r_a = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *task_rshank_g_r_a = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *task_lthigh_g_r_a = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *task_lshank_g_r_a = [NSMutableArray arrayWithCapacity:data_count];
    
    TSRotMatrix *calib_trunk_a_R_s_t = [[TSRotMatrix alloc] init];
    [calib_trunk_a_R_s_t transpose_matrix:self.calib_trunk_a_R_s];
    
    for (NSInteger i = 0; i < data_count; i ++) {
        
        TSRotMatrix *rot_mat = [[TSRotMatrix alloc] init];
        [rot_mat cross_product:[trunk_chest_rot_matrix objectAtIndex:i] rm2:calib_trunk_a_R_s_t];
        [task_trunk_g_r_a addObject:[[TSRotMatrix alloc] initWithName:rot_mat]];
        
        [rot_mat cross_product:[shoulder_rot_matrix objectAtIndex:i] rm2:self.calib_shoulder_s_R_a];
        [task_shoulder_g_r_a addObject:[[TSRotMatrix alloc] initWithName:rot_mat]];
        
        [rot_mat cross_product:[upper_arm_rot_matrix objectAtIndex:i] rm2:self.calib_upper_arm_s_R_a];
        [task_upper_arm_g_r_a addObject:[[TSRotMatrix alloc] initWithName:rot_mat]];
        
        [rot_mat cross_product:[forearm_rot_matrix objectAtIndex:i] rm2:self.calib_forearm_s_R_a];
        [task_forearm_g_r_a addObject:[[TSRotMatrix alloc] initWithName:rot_mat]];
        
        
        [rot_mat cross_product:[rthigh_rot_matrix objectAtIndex:i] rm2:self.calib_rthigh_s_R_a];
        [task_rthigh_g_r_a addObject:[[TSRotMatrix alloc] initWithName:rot_mat]];
        
        [rot_mat cross_product:[rshank_rot_matrix objectAtIndex:i] rm2:self.calib_rshank_s_R_a];
        [task_rshank_g_r_a addObject:[[TSRotMatrix alloc] initWithName:rot_mat]];
        
        [rot_mat cross_product:[lthigh_rot_matrix objectAtIndex:i] rm2:self.calib_lthigh_s_R_a];
        [task_lthigh_g_r_a addObject:[[TSRotMatrix alloc] initWithName:rot_mat]];
        
        [rot_mat cross_product:[lshank_rot_matrix objectAtIndex:i] rm2:self.calib_lshank_s_R_a];
        [task_lshank_g_r_a addObject:[[TSRotMatrix alloc] initWithName:rot_mat]];
        
    }
    NSMutableArray *task_joint_trunk_jr = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *task_joint_st_jr = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *task_joint_ht_jr = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *task_joint_elbow_jr = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *task_joint_rhip_jr = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *task_joint_rknee_jr = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *task_joint_lhip_jr = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *task_joint_lknee_jr = [NSMutableArray arrayWithCapacity:data_count];
    
    NSInteger cal_index = self.calibration_index;
    for (int i = 0; i < data_count; i ++) {
        TSRotMatrix *rot_mat = [[TSRotMatrix alloc] init];
        [rot_mat joint_rot_matrix:[task_trunk_g_r_a objectAtIndex:cal_index] pre_rot_mat:[task_trunk_g_r_a objectAtIndex:i]];
        [task_joint_trunk_jr addObject:[[TSRotMatrix alloc] initWithName:rot_mat]];
        
        [rot_mat joint_rot_matrix:[task_trunk_g_r_a objectAtIndex:i] pre_rot_mat:[task_shoulder_g_r_a objectAtIndex:i]];
        [task_joint_st_jr addObject:[[TSRotMatrix alloc] initWithName:rot_mat]];
        
        [rot_mat joint_rot_matrix:[task_trunk_g_r_a objectAtIndex:i] pre_rot_mat:[task_upper_arm_g_r_a objectAtIndex:i]];
        [task_joint_ht_jr addObject:[[TSRotMatrix alloc] initWithName:rot_mat]];
        
        [rot_mat joint_rot_matrix:[task_upper_arm_g_r_a objectAtIndex:i] pre_rot_mat:[task_forearm_g_r_a objectAtIndex:i]];
        [task_joint_elbow_jr addObject:[[TSRotMatrix alloc] initWithName:rot_mat]];
        
        [rot_mat joint_rot_matrix:[task_trunk_g_r_a objectAtIndex:i] pre_rot_mat:[task_rthigh_g_r_a objectAtIndex:i]];
        [task_joint_rhip_jr addObject:[[TSRotMatrix alloc] initWithName:rot_mat]];
        
        [rot_mat joint_rot_matrix:[task_rthigh_g_r_a objectAtIndex:i] pre_rot_mat:[task_rshank_g_r_a objectAtIndex:i]];
        [task_joint_rknee_jr addObject:[[TSRotMatrix alloc] initWithName:rot_mat]];
        
        [rot_mat joint_rot_matrix:[task_trunk_g_r_a objectAtIndex:i] pre_rot_mat:[task_lthigh_g_r_a objectAtIndex:i]];
        [task_joint_lhip_jr addObject:[[TSRotMatrix alloc] initWithName:rot_mat]];
        
        [rot_mat joint_rot_matrix:[task_lthigh_g_r_a objectAtIndex:i] pre_rot_mat:[task_lshank_g_r_a objectAtIndex:i]];
        [task_joint_lknee_jr addObject:[[TSRotMatrix alloc] initWithName:rot_mat]];
        
    }
    
    
    
    for (NSInteger i = 0; i < data_count; i ++) {
        TSEuler *theta = [[TSEuler alloc] init];
        [[task_joint_trunk_jr objectAtIndex:i] rotation_matrix_2_xzy:theta];
        [self.task_angles_trunk addObject:[[TSEuler alloc] initWithTSEuler:theta]];
        
        [[task_joint_st_jr objectAtIndex:i] rotation_matrix_2_xzy:theta];
        [self.task_angles_st addObject:[[TSEuler alloc] initWithTSEuler:theta]];
        
        [[task_joint_ht_jr objectAtIndex:i] rotation_matrix_2_xzy:theta];
        [self.task_angles_ht addObject:[[TSEuler alloc] initWithTSEuler:theta]];
        
        [[task_joint_elbow_jr objectAtIndex:i] rotation_matrix_2_xzy:theta];
        [self.task_angles_elbow addObject:[[TSEuler alloc] initWithTSEuler:theta]];
        
        [[task_joint_rhip_jr objectAtIndex:i] rotation_matrix_2_xzy:theta];
        [self.task_angles_rhip addObject:[[TSEuler alloc] initWithTSEuler:theta]];
        
        [[task_joint_rknee_jr objectAtIndex:i] rotation_matrix_2_xzy:theta];
        [self.task_angles_rknee addObject:[[TSEuler alloc] initWithTSEuler:theta]];
        
        [[task_joint_lhip_jr objectAtIndex:i] rotation_matrix_2_xzy:theta];
        [self.task_angles_lhip addObject:[[TSEuler alloc] initWithTSEuler:theta]];
        
        [[task_joint_lknee_jr objectAtIndex:i] rotation_matrix_2_xzy:theta];
        [self.task_angles_lknee addObject:[[TSEuler alloc] initWithTSEuler:theta]];
        

    }
    
    [self generateStrokeParamForEachStoke];
    self.new_data_start_index = [self.right_forearm_raw_data count];
    // delete the data which is not related to the stroke
    [self delete_useless_data];
    self.new_data_start_index = [self.right_forearm_raw_data count];
    NSLog(@" data number is %lu \n", (unsigned long)[self.right_forearm_qua count]);
    NSLog(@" data number is %lu \n", (unsigned long)[self.right_forearm_raw_data count]);
    NSLog(@" data number is %lu \n", (unsigned long)[self.task_angles_elbow count]);
    
}

-(NSInteger) get_index_from_frame_index:(NSInteger)frame_index
{
    NSInteger count = [self.frame_index count];
    NSInteger cur_index = 0;
    NSInteger max_index = count;
    NSInteger min_index = 0;
    for (NSInteger i = 0; i < count; i ++) {
        NSInteger cur_frame_index = [[self.frame_index objectAtIndex:cur_index] integerValue];
        if (cur_frame_index < frame_index) {
            min_index = cur_index;
            cur_index = (cur_index + max_index) / 2;
            if ((max_index - cur_index) < 5) {
                return cur_index;
            }
        } else if (cur_frame_index > frame_index) {
            max_index = cur_index;
            cur_index = (cur_index + min_index) / 2;
            if ((cur_index - min_index) < 5) {
                return cur_index;
            }
        } else {
            return cur_index;
        }
    }
    return cur_index;
}



-(void) delete_useless_data
{
    //NSInteger strok_num = [self.stroke_output_param count];
    NSInteger all_data_count = [self.right_forearm_raw_data count];
    NSInteger stroke_count = [self.stroke_output_param count];
    if (stroke_count <= 0) {
        // remove all the data
        [self.right_forearm_raw_data removeAllObjects];
        [self.left_shank_raw_data removeAllObjects];
        [self.right_shank_raw_data removeAllObjects];
        [self.task_angles_elbow removeAllObjects];
        [self.task_angles_ht removeAllObjects];
        [self.task_angles_lhip removeAllObjects];
        [self.task_angles_lknee removeAllObjects];
        [self.task_angles_rhip removeAllObjects];
        [self.task_angles_rknee removeAllObjects];
        [self.task_angles_st removeAllObjects];
        [self.task_angles_trunk removeAllObjects];
        [self.frame_index removeAllObjects];
        [self.trunk_chest_qua removeAllObjects];
        [self.right_shoulder_qua removeAllObjects];
        [self.right_upper_arm_qua removeAllObjects];
        [self.right_forearm_qua removeAllObjects];
        [self.left_thigh_qua removeAllObjects];
        [self.right_thigh_qua removeAllObjects];
        [self.left_shank_qua removeAllObjects];
        [self.right_shank_qua removeAllObjects];
        return;
    }
    TSTennisOutPutData *one_stroke = [self.stroke_output_param objectAtIndex:(stroke_count-1)];
    NSInteger end_frame_index = one_stroke.frame_end_index + STROKE_MIN_TIME * 4;
    NSInteger delete_index = [self get_index_from_frame_index:end_frame_index];
    for (NSInteger i = delete_index; i < all_data_count; i ++) {
        [self.right_forearm_raw_data removeObjectAtIndex:delete_index];
        [self.left_shank_raw_data removeObjectAtIndex:delete_index];
        [self.right_shank_raw_data removeObjectAtIndex:delete_index];
        [self.task_angles_elbow removeObjectAtIndex:delete_index];
        [self.task_angles_ht removeObjectAtIndex:delete_index];
        [self.task_angles_lhip removeObjectAtIndex:delete_index];
        [self.task_angles_lknee removeObjectAtIndex:delete_index];
        [self.task_angles_rhip removeObjectAtIndex:delete_index];
        [self.task_angles_rknee removeObjectAtIndex:delete_index];
        [self.task_angles_st removeObjectAtIndex:delete_index];
        [self.task_angles_trunk removeObjectAtIndex:delete_index];
        [self.frame_index removeObjectAtIndex:delete_index];
        [self.trunk_chest_qua removeObjectAtIndex:delete_index];
        [self.right_shoulder_qua removeObjectAtIndex:delete_index];
        [self.right_upper_arm_qua removeObjectAtIndex:delete_index];
        [self.right_forearm_qua removeObjectAtIndex:delete_index];
        [self.left_thigh_qua removeObjectAtIndex:delete_index];
        [self.right_thigh_qua removeObjectAtIndex:delete_index];
        [self.left_shank_qua removeObjectAtIndex:delete_index];
        [self.right_shank_qua removeObjectAtIndex:delete_index];
    }
    NSInteger start_frame_index = 0;
    for (NSInteger i = (stroke_count-1); i >= 1; i --) {
        one_stroke = [self.stroke_output_param objectAtIndex:i];
        end_frame_index = one_stroke.frame_start_index - STROKE_MIN_TIME * 4;
        one_stroke = [self.stroke_output_param objectAtIndex:(i -1)];
        start_frame_index = one_stroke.frame_end_index + STROKE_MIN_TIME * 4;
        if (start_frame_index >= end_frame_index) {
            continue;
        }
        NSInteger delete_index = [self get_index_from_frame_index:start_frame_index];
        NSInteger end_delete_index = [self get_index_from_frame_index:end_frame_index];
        for (NSInteger j = delete_index; j < end_delete_index; j ++) {
            [self.right_forearm_raw_data removeObjectAtIndex:delete_index];
            [self.left_shank_raw_data removeObjectAtIndex:delete_index];
            [self.right_shank_raw_data removeObjectAtIndex:delete_index];
            [self.task_angles_elbow removeObjectAtIndex:delete_index];
            [self.task_angles_ht removeObjectAtIndex:delete_index];
            [self.task_angles_lhip removeObjectAtIndex:delete_index];
            [self.task_angles_lknee removeObjectAtIndex:delete_index];
            [self.task_angles_rhip removeObjectAtIndex:delete_index];
            [self.task_angles_rknee removeObjectAtIndex:delete_index];
            [self.task_angles_st removeObjectAtIndex:delete_index];
            [self.task_angles_trunk removeObjectAtIndex:delete_index];
            [self.frame_index removeObjectAtIndex:delete_index];
            [self.trunk_chest_qua removeObjectAtIndex:delete_index];
            [self.right_shoulder_qua removeObjectAtIndex:delete_index];
            [self.right_upper_arm_qua removeObjectAtIndex:delete_index];
            [self.right_forearm_qua removeObjectAtIndex:delete_index];
            [self.left_thigh_qua removeObjectAtIndex:delete_index];
            [self.right_thigh_qua removeObjectAtIndex:delete_index];
            [self.left_shank_qua removeObjectAtIndex:delete_index];
            [self.right_shank_qua removeObjectAtIndex:delete_index];
        }
    }
    one_stroke = [self.stroke_output_param objectAtIndex:0];
    end_frame_index = one_stroke.frame_start_index - STROKE_MIN_TIME * 4;
    NSInteger end_delete_index = [self get_index_from_frame_index:end_frame_index];
    delete_index = 0;
    for (NSInteger j = delete_index; j < end_delete_index; j ++) {
        [self.right_forearm_raw_data removeObjectAtIndex:delete_index];
        [self.left_shank_raw_data removeObjectAtIndex:delete_index];
        [self.right_shank_raw_data removeObjectAtIndex:delete_index];
        [self.task_angles_elbow removeObjectAtIndex:delete_index];
        [self.task_angles_ht removeObjectAtIndex:delete_index];
        [self.task_angles_lhip removeObjectAtIndex:delete_index];
        [self.task_angles_lknee removeObjectAtIndex:delete_index];
        [self.task_angles_rhip removeObjectAtIndex:delete_index];
        [self.task_angles_rknee removeObjectAtIndex:delete_index];
        [self.task_angles_st removeObjectAtIndex:delete_index];
        [self.task_angles_trunk removeObjectAtIndex:delete_index];
        [self.frame_index removeObjectAtIndex:delete_index];
        [self.trunk_chest_qua removeObjectAtIndex:delete_index];
        [self.right_shoulder_qua removeObjectAtIndex:delete_index];
        [self.right_upper_arm_qua removeObjectAtIndex:delete_index];
        [self.right_forearm_qua removeObjectAtIndex:delete_index];
        [self.left_thigh_qua removeObjectAtIndex:delete_index];
        [self.right_thigh_qua removeObjectAtIndex:delete_index];
        [self.left_shank_qua removeObjectAtIndex:delete_index];
        [self.right_shank_qua removeObjectAtIndex:delete_index];
    }
}


-(int) getGoodStrokesByAngleHT {
    NSInteger data_count = [self.task_angles_ht count];
    NSMutableArray *angle_ht_x = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *angle_ht_y = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *angle_ht_z = [NSMutableArray arrayWithCapacity:data_count];
    
    int nStrokes1 = [self getStrokeNumberByTheshold:self.task_angles_ht type:0 dir:1 threshold:SHOULDER_TRUNK_ANGLE_X max_array:angle_ht_x];
    int nStrokes2 = [self getStrokeNumberByTheshold:self.task_angles_ht type:0 dir:3 threshold:SHOULDER_TRUNK_ANGLE_Z max_array:angle_ht_z];
    int nStrokes3 = [self getStrokeNumberByTheshold:self.task_angles_ht type:0 dir:2 threshold:SHOULDER_TRUNK_ANGLE_Y max_array:angle_ht_y];
    
    int good_strokes = nStrokes1;
    if (nStrokes2 > good_strokes) {
        good_strokes = nStrokes2;
    }
    if (nStrokes3 > good_strokes) {
        good_strokes = nStrokes3;
    }
    
    return good_strokes;
}

-(int) getStrokeNumberByTheshold:(NSMutableArray *)data type:(int)type dir:(int)dir threshold:(double)threshold max_array:(NSMutableArray *)max_array {
    
    NSInteger count = [data count];
    NSInteger new_data_count = count - self.new_data_start_index;
    double org_data[new_data_count];
    double new_data[new_data_count+3];
    double value = 0;
    for (NSInteger i = self.new_data_start_index; i < count; i ++) {
        if (type == 0) {
            TSEuler *theta = [data objectAtIndex:i];
            if (dir == 1) {
                value = theta.x * 180/PI;
            } else if (dir == 2) {
                value = theta.y * 180/PI;
            } else {
                value = theta.z * 180/PI;
            }
        } else if (type == 1) {
            TSAccGyroTimeData *accel = [data objectAtIndex:i];
            if (dir == 1) {
                value = accel.accel_x;
            } else if (dir == 2) {
                value = accel.accel_y;
            } else if (dir == 3) {
                value = accel.accel_z;
            }
        }
        org_data[i-self.new_data_start_index] = value;
    }
    
    /*for (int i = 1; i < (new_data_count - 1); i ++) {
        if (i > 1500 && i < 2100) {
            NSLog(@"i=%d  before data=%f\n",i, org_data[i]);
        }
    }*/
    NSInteger x1 = org_data[0];
    NSInteger x2 = org_data[new_data_count-1];
    for (int jj = 1; jj <= 5; jj ++) {
        for (int i1 = 0; i1 < (new_data_count + 3); i1 ++) {
            new_data[i1] = 0;
        }
        for (int i1 = 0; i1 < 3; i1 ++) {
            for (int i2 = 0; i2 < new_data_count; i2++) {
                new_data[i1+i2] = new_data[i1+i2] + org_data[i2]/3;
            }
        }
        for (int i1 = 0; i1 < new_data_count; i1++) {
            org_data[i1] = new_data[i1+1];
        }
        org_data[0] = x1;
        org_data[new_data_count-1] = x2;
    }
    
    /*NSMutableString *str = [[NSMutableString alloc] init];
     NSString *file_name = [NSString stringWithFormat:@"/gary/tennis/test.txt"];
     for (int i = 0; i < count; i ++) {
     int sc = 50 + org_data[i] / 2;
     [str appendFormat:@"%10d %f", i, org_data[i]];
     for (int j = 0; j < sc; j ++) {
     [str appendString:@" "];
     }
     [str appendString:@"*\n"];
     }
     [str writeToFile:file_name atomically:YES encoding:NSUTF8StringEncoding error:nil];
     */
    
    NSMutableArray *peak_array = [NSMutableArray arrayWithCapacity:new_data_count];
    double pre_value = -threshold;
    for (int i = 1; i < (new_data_count - 2); i ++) {
        if (org_data[i >= org_data[i-1] && org_data[i] > org_data[i+1]]) {
            [peak_array addObject:[[TSMaxValue alloc] initWithValueIndex:org_data[i]
                                                                   index:(i+self.new_data_start_index)]];
        }
    }
    
    
    NSInteger pre_idx = -STROKE_MIN_TIME;
    pre_value = -threshold;
    int number = 0;
    count = [peak_array count];
    for (int i = 0; i < count; i ++) {
        TSMaxValue *max_value = [peak_array objectAtIndex:i];
        if (max_value.value >= threshold) {
            if ((max_value.index - pre_idx) >= STROKE_MIN_TIME) {
                number++;
                pre_value = max_value.value;
                pre_idx = max_value.index;
                [max_array addObject:[[TSMaxValue alloc] initWithValueIndex:max_value.value index:max_value.index]];
            } else if (max_value.value >= pre_value) {
                pre_value = max_value.value;
                pre_idx = max_value.index;
            }
        }
    }
    return number;
}

-(double) getMinPeakAngleValue:(NSMutableArray *)data dir:(NSInteger)dir start_index:(NSInteger)start_index end_index:(NSInteger)end_index
{
    double value = 0;
    TSEuler *theta;
    for (NSInteger i = start_index; i < end_index; i ++) {
        theta = [data objectAtIndex:i];
        if (i == start_index) {
            if (dir == 0) {
                value = theta.x;
            } else if (dir == 1) {
                value = theta.y;
            } else {
                value = theta.z;
            }
        }
        double cur_value = 0;
        if (dir == 0) {
            cur_value = theta.x;
        } else if (dir == 1) {
            cur_value = theta.y;
        } else {
            cur_value = theta.z;
        }
        if (cur_value < value) {
            value = cur_value;
        }
    }
    return value;
}

-(double) getMaxPeakAngleValue:(NSMutableArray *)data dir:(NSInteger)dir start_index:(NSInteger)start_index end_index:(NSInteger)end_index
{
    double value = 0;
    TSEuler *theta;
    for (NSInteger i = start_index; i < end_index; i ++) {
        theta = [data objectAtIndex:i];
        if (i == start_index) {
            if (dir == 0) {
                value = theta.x;
            } else if (dir == 1) {
                value = theta.y;
            } else {
                value = theta.z;
            }
        }
        double cur_value = 0;
        if (dir == 0) {
            cur_value = theta.x;
        } else if (dir == 1) {
            cur_value = theta.y;
        } else {
            cur_value = theta.z;
        }
        if (cur_value > value) {
            value = cur_value;
        }
    }
    return value;
}

-(NSInteger) getCountByPeakArray:(NSMutableArray *)data start_index:(NSInteger)start_index end_index:(NSInteger)end_index
{
    NSInteger score = 0;
    NSInteger check_data_count = [data count];
    for (NSInteger cur_check_data_idx = 0;cur_check_data_idx < check_data_count; cur_check_data_idx++) {
        TSMaxValue *check_data_value = [data objectAtIndex:cur_check_data_idx];
        if (check_data_value.index < start_index) {
            continue;
        } else if (check_data_value.index > end_index) {
            break;
        }
        score = score + 1;
    }
    return score;
}


-(NSInteger) getScoreByPeakArray:(NSMutableArray *)data stroke_data:(NSMutableArray *)stroke_data
    index:(NSInteger)index
{
    NSInteger score = 0;
    NSInteger stroke_count = [stroke_data count];
    if (index >= stroke_count) {
        return score;
    }

    TSMaxValue *cur_stroke_value = [stroke_data objectAtIndex:index];
    NSInteger end_index = cur_stroke_value.index;
    NSInteger start_index = end_index - STROKE_MIN_TIME;
    if (start_index < 0) {
        start_index = 0;
    }
    if (index > 0) {
        TSMaxValue *pre_stroke_value = [stroke_data objectAtIndex:(index-1)];
        start_index = pre_stroke_value.index;
    }

    NSInteger check_data_count = [data count];
    for (NSInteger cur_check_data_idx = self.new_data_start_index;
         cur_check_data_idx < check_data_count; cur_check_data_idx++) {
        TSMaxValue *check_data_value = [data objectAtIndex:cur_check_data_idx];
        if (check_data_value.index < start_index) {
            continue;
        } else if (check_data_value.index > end_index) {
            break;
        }
        score = score + 1;
    }
    return score;
}


-(void) reportEachStroke
{
    //return;
    NSInteger count = [self.stroke_output_param count];
    TSTennisOutPutData *report;
    for (int i = 0; i < count; i ++) {
        report = [self.stroke_output_param objectAtIndex:i];
        NSLog(@"StrokeIndex=%ld   ", (long)report.index);
        NSLog(@"Frame : %ld ~ %ld  ", (long)report.frame_start_index, (long)report.frame_end_index);
        //NSLog(@" %s stroke  ", report.good_stroke ? "Good" : "not Good");
        if (report.stroke_type == TSTStrokeTypeForehand) {
            NSLog(@" strokeType=Forehand  ");
        } else if (report.stroke_type == TSTStrokeTypeServe) {
            NSLog(@" strokeType=Serve  ");
        } else if (report.stroke_type == TSTStrokeTypeBackhand) {
            NSLog(@" strokeType=Backhand  ");
        } else {
            NSLog(@" strokeType=Unknown  ");
        }
        NSLog(@" wrist speed=%f  ", report.racquet_speed);
        NSLog(@"LeftStep=%ld   RightStep=%ld   ", (long)report.left_step, (long)report.right_step);
        NSLog(@"LeftKneeBend=%f     RightKneeBend=%f   ", report.left_knee_bend_degree, report.right_knee_bend_degree);
        NSLog(@"Shoulder elevaction = %f \n", report.right_shoulder_elevaction_degree);
    }
}

-(double) getStrokeMaxRacquetSpeedByGyro:(NSInteger)peak_index {
    double speed = 0;
    NSInteger start_index = peak_index - STROKE_MIN_TIME;
    NSInteger end_index = peak_index + STROKE_MIN_TIME;
    if (start_index < 0) {
        start_index = 0;
    }
    if (end_index >= [self.right_forearm_raw_data count]) {
        end_index = [self.right_forearm_raw_data count] - 1;
    }
    
    TSAccGyroTimeData *one_raw_data;
    for (NSInteger i = start_index; i < end_index; i ++) {
        one_raw_data = [self.right_forearm_raw_data objectAtIndex:i];
        double gx = one_raw_data.gyro_x/ (GYROFULLSCALE * TIMEINTEVAL);
        double gz = one_raw_data.gyro_z/ (GYROFULLSCALE * TIMEINTEVAL);
        double cur_speed = sqrt(gx*gx + gz*gz) * ARMLENGTH;
        if (cur_speed > speed) {
            speed = cur_speed;
        }
    }
    return speed;
}

-(TSTStrokeType) getStrokeTypeByWrist:(NSInteger)peak_index {
    TSTStrokeType stroke_type = TSTStrokeTypeUnknown;
    NSInteger start_index = peak_index - STROKE_MIN_TIME;
    NSInteger end_index = peak_index + STROKE_MIN_TIME;
    if (start_index < 0) {
        start_index = 0;
    }
    if (end_index >= [self.right_forearm_raw_data count]) {
        end_index = [self.right_forearm_raw_data count] - 1;
    }
    double sum_minx = 0;
    double sum_maxx = 0;
    double sum_miny = 0;
    double sum_maxy = 0;
    double sum_minz = 0;
    double sum_maxz = 0;
    double minx = 0;
    NSInteger minx_index = 0;
    double maxx = 0;
    NSInteger maxx_index = 0;
    double minz = 0;
    NSInteger minz_index = 0;
    double maxz = 0;
    NSInteger maxz_index = 0;
    TSAccGyroTimeData *one_raw_data;
    for (NSInteger i = start_index; i < end_index; i ++) {
        one_raw_data = [self.right_forearm_raw_data objectAtIndex:i];
        if (i == start_index) {
            minx = one_raw_data.gyro_x;
            maxx = one_raw_data.gyro_x;
            minx_index = i;
            maxx_index = i;
            minz = one_raw_data.gyro_z;
            minz_index = i;
            maxz = one_raw_data.gyro_z;
            maxz_index = i;
        }
        if (one_raw_data.gyro_x > 0) {
            sum_maxx = sum_maxx + one_raw_data.gyro_x;
            if (one_raw_data.gyro_x > maxx) {
                maxx = one_raw_data.gyro_x;
                maxx_index = i;
            }
        } else {
            sum_minx = sum_minx - one_raw_data.gyro_x;
            if ((-one_raw_data.gyro_x) > minx) {
                minx = -one_raw_data.gyro_x;
                minx_index = i;
            }
        }
        if (one_raw_data.gyro_y > 0) {
            sum_maxy = sum_maxy + one_raw_data.gyro_y;
        } else {
            sum_miny = sum_miny - one_raw_data.gyro_y;
        }
        if (one_raw_data.gyro_z > 0) {
            sum_maxz = sum_maxz + one_raw_data.gyro_z;
            if (one_raw_data.gyro_z > maxz) {
                maxz = one_raw_data.gyro_z;
                maxz_index = i;
            }
        } else {
            sum_minz = sum_minz - one_raw_data.gyro_z;
            if ((-one_raw_data.gyro_z) > minz) {
                minz = -one_raw_data.gyro_z;
                minz_index = i;
            }
        }
    }
    if ((sum_maxx > 2 * sum_minx) && (maxx > 4 * minx)) {
        stroke_type = TSTStrokeTypeForehand;
    } else if ((sum_miny > 3 * sum_maxy) || (sum_minz > 2 * sum_maxz)) {
        stroke_type = TSTStrokeTypeBackhand;
    }

    if ((maxz_index > minz_index) && ((maxz_index - minz_index) < 15)) {
        NSInteger data_count = end_index - start_index + 1;
        double ave = (sum_minx + sum_maxx)/data_count;
        if (maxx > 4 * ave && maxz > (maxx/2) && minz > (maxx/2)) {
            ave = (sum_minz + sum_maxz)/data_count;
            if (minz > 2 * ave && maxz > 2 *ave) {
                stroke_type = TSTStrokeTypeServe;
            }
        }
    }
    return stroke_type;
}


-(void) generateStrokeParamForEachStoke {
    NSInteger data_count = [self.task_angles_elbow count];
    NSInteger new_data_count = data_count - self.new_data_start_index;
    NSMutableArray *right_shank_peak_array = [NSMutableArray arrayWithCapacity:new_data_count];
    NSMutableArray *left_shank_peak_array = [NSMutableArray arrayWithCapacity:new_data_count];
    NSMutableArray *right_forearm_peak_array = [NSMutableArray arrayWithCapacity:new_data_count];
    
    NSMutableArray *angle_ht_x = [NSMutableArray arrayWithCapacity:new_data_count];
    NSMutableArray *angle_ht_y = [NSMutableArray arrayWithCapacity:new_data_count];
    NSMutableArray *angle_ht_z = [NSMutableArray arrayWithCapacity:new_data_count];
    
    
    [self getStrokeNumberByTheshold:self.right_forearm_raw_data type:1 dir:2
                          threshold:STROKE_MIN_ACCEL_Y max_array:right_forearm_peak_array];
    [self getStrokeNumberByTheshold:self.right_shank_raw_data type:1 dir:2
                          threshold:SHANK_STEP_MIN_ACCEL_Y max_array:right_shank_peak_array];
    [self getStrokeNumberByTheshold:self.left_shank_raw_data type:1 dir:2
                          threshold:SHANK_STEP_MIN_ACCEL_Y max_array:left_shank_peak_array];
    [self getStrokeNumberByTheshold:self.task_angles_ht type:0 dir:1
                          threshold:SHOULDER_TRUNK_ANGLE_X max_array:angle_ht_x];
    [self getStrokeNumberByTheshold:self.task_angles_ht type:0 dir:3
                          threshold:SHOULDER_TRUNK_ANGLE_Z max_array:angle_ht_z];
    [self getStrokeNumberByTheshold:self.task_angles_ht type:0 dir:2
                          threshold:SHOULDER_TRUNK_ANGLE_Y max_array:angle_ht_y];
    
    
    NSInteger stroke_count = [right_forearm_peak_array count];
    
    TSTennisOutPutData *one_stroke = [[TSTennisOutPutData alloc] initWithUnit];
    NSInteger org_stroke_count = [self.stroke_output_param count];
    for (int i = 0; i < stroke_count; i ++) {
        [one_stroke resetValue];
        one_stroke.index = i + org_stroke_count;
        
        TSMaxValue *cur_stroke_value = [right_forearm_peak_array objectAtIndex:i];
        NSInteger end_index = cur_stroke_value.index;
        NSInteger start_index = end_index - STROKE_MIN_TIME;
        if (start_index < 0) {
            start_index = 0;
        }
        if (i > 0) {
            TSMaxValue *pre_stroke_value = [right_forearm_peak_array objectAtIndex:(i-1)];
            start_index = pre_stroke_value.index;
        }
        NSInteger start_frame_index = [[self.frame_index objectAtIndex:start_index] integerValue];
        NSInteger end_frame_index = [[self.frame_index objectAtIndex:end_index] integerValue];
        one_stroke.frame_start_index = start_frame_index;
        one_stroke.frame_end_index = end_frame_index;
        
        TSTStrokeType stroke_type = [self getStrokeTypeByWrist:cur_stroke_value.index];
        one_stroke.stroke_type = stroke_type;
        
        double wrist_speed = [self getStrokeMaxRacquetSpeedByGyro:cur_stroke_value.index];
        one_stroke.racquet_speed = wrist_speed;
        
        NSInteger nLeftStep = [self getCountByPeakArray:left_shank_peak_array start_index:start_index end_index:end_index];
        one_stroke.left_step = nLeftStep;

        NSInteger nRightStep = [self getCountByPeakArray:right_shank_peak_array start_index:start_index end_index:end_index];
        one_stroke.right_step = nRightStep;
        
        double minLKnee = [self getMinPeakAngleValue:self.task_angles_lknee dir:0 start_index:start_index end_index:end_index];
        double minRknee = [self getMinPeakAngleValue:self.task_angles_rknee dir:0 start_index:start_index end_index:end_index];
        one_stroke.left_knee_bend_degree = -minLKnee*180/M_PI;
        one_stroke.right_knee_bend_degree = -minRknee*180/M_PI;
        
        double maxShoulder = [self getMaxPeakAngleValue:self.task_angles_st dir:1 start_index:start_index end_index:end_index];
        one_stroke.right_shoulder_elevaction_degree = maxShoulder*180/M_PI;
        
        NSInteger good_count = [self getCountByPeakArray:angle_ht_x start_index:start_index end_index:end_index];
        if (good_count <= 0) {
            good_count = [self getCountByPeakArray:angle_ht_y start_index:start_index end_index:end_index];
        }
        if (good_count <= 0) {
            good_count = [self getCountByPeakArray:angle_ht_z start_index:start_index end_index:end_index];
        }
        if (good_count > 0) {
            one_stroke.good_stroke = true;
        } else {
            one_stroke.good_stroke = false;
        }
        end_index = cur_stroke_value.index - STROKE_MIN_TIME;
        start_index = cur_stroke_value.index - STROKE_MIN_TIME;
        if (start_index < 0) {
            start_index = 0;
        }
        
        [self.stroke_output_param addObject:[[TSTennisOutPutData alloc] initWithTennisOutputData:one_stroke]];
        
    }
}


-(void) generateCalibrationStr:(NSMutableString *)str
{
    [str appendFormat:@" %ld  %f %f %f %f %f %f %f %f %f \n", (long)TSSensorAtTrunkChest,
     self.calib_trunk_a_R_s.r11,self.calib_trunk_a_R_s.r12,self.calib_trunk_a_R_s.r13,
     self.calib_trunk_a_R_s.r21,self.calib_trunk_a_R_s.r22,self.calib_trunk_a_R_s.r23,
     self.calib_trunk_a_R_s.r31, self.calib_trunk_a_R_s.r32,self.calib_trunk_a_R_s.r33];
    
    [str appendFormat:@" %ld  %f %f %f %f %f %f %f %f %f \n", (long)TSSensorAtRightShoulder,
     self.calib_shoulder_s_R_a.r11,self.calib_shoulder_s_R_a.r12,self.calib_shoulder_s_R_a.r13,
     self.calib_shoulder_s_R_a.r21,self.calib_shoulder_s_R_a.r22,self.calib_shoulder_s_R_a.r23,
     self.calib_shoulder_s_R_a.r31, self.calib_shoulder_s_R_a.r32,self.calib_shoulder_s_R_a.r33];
    
    [str appendFormat:@" %ld  %f %f %f %f %f %f %f %f %f \n", (long)TSSensorAtRightUpperArm,
     self.calib_upper_arm_s_R_a.r11,self.calib_upper_arm_s_R_a.r12,self.calib_upper_arm_s_R_a.r13,
     self.calib_upper_arm_s_R_a.r21,self.calib_upper_arm_s_R_a.r22,self.calib_upper_arm_s_R_a.r23,
     self.calib_upper_arm_s_R_a.r31, self.calib_upper_arm_s_R_a.r32,self.calib_upper_arm_s_R_a.r33];
    
    [str appendFormat:@" %ld  %f %f %f %f %f %f %f %f %f \n", (long)TSSensorAtRightForearm,
     self.calib_forearm_s_R_a.r11,self.calib_forearm_s_R_a.r12,self.calib_forearm_s_R_a.r13,
     self.calib_forearm_s_R_a.r21,self.calib_forearm_s_R_a.r22,self.calib_forearm_s_R_a.r23,
     self.calib_forearm_s_R_a.r31, self.calib_forearm_s_R_a.r32,self.calib_forearm_s_R_a.r33];
    
    [str appendFormat:@" %ld  %f %f %f %f %f %f %f %f %f \n", (long)TSSensorAtLeftThigh,
     self.calib_lthigh_s_R_a.r11,self.calib_lthigh_s_R_a.r12,self.calib_lthigh_s_R_a.r13,
     self.calib_lthigh_s_R_a.r21,self.calib_lthigh_s_R_a.r22,self.calib_lthigh_s_R_a.r23,
     self.calib_lthigh_s_R_a.r31, self.calib_lthigh_s_R_a.r32,self.calib_lthigh_s_R_a.r33];
    
    [str appendFormat:@" %ld  %f %f %f %f %f %f %f %f %f \n", (long)TSSensorAtRightThigh,
     self.calib_rthigh_s_R_a.r11,self.calib_rthigh_s_R_a.r12,self.calib_rthigh_s_R_a.r13,
     self.calib_rthigh_s_R_a.r21,self.calib_rthigh_s_R_a.r22,self.calib_rthigh_s_R_a.r23,
     self.calib_rthigh_s_R_a.r31, self.calib_rthigh_s_R_a.r32,self.calib_rthigh_s_R_a.r33];
    
    [str appendFormat:@" %ld  %f %f %f %f %f %f %f %f %f \n", (long)TSSensorAtLeftShank,
     self.calib_lshank_s_R_a.r11,self.calib_lshank_s_R_a.r12,self.calib_lshank_s_R_a.r13,
     self.calib_lshank_s_R_a.r21,self.calib_lshank_s_R_a.r22,self.calib_lshank_s_R_a.r23,
     self.calib_lshank_s_R_a.r31, self.calib_lshank_s_R_a.r32,self.calib_lshank_s_R_a.r33];
    
    [str appendFormat:@" %ld  %f %f %f %f %f %f %f %f %f \n", (long)TSSensorAtRightShank,
     self.calib_rshank_s_R_a.r11,self.calib_rshank_s_R_a.r12,self.calib_rshank_s_R_a.r13,
     self.calib_rshank_s_R_a.r21,self.calib_rshank_s_R_a.r22,self.calib_rshank_s_R_a.r23,
     self.calib_rshank_s_R_a.r31, self.calib_rshank_s_R_a.r32,self.calib_rshank_s_R_a.r33];
}

-(void) generateJointAngleStr:(NSMutableString *)str
{
    NSInteger data_count = [self.trunk_chest_qua count];
    if (data_count > [self.right_shoulder_qua count]) {
        data_count = [self.right_shoulder_qua count];
    }
    if (data_count > [self.right_upper_arm_qua count]) {
        data_count = [self.right_upper_arm_qua count];
    }
    if (data_count > [self.right_forearm_qua count]) {
        data_count = [self.right_forearm_qua count];
    }
    if (data_count > [self.left_shank_qua count]) {
        data_count = [self.left_shank_qua count];
    }
    if (data_count > [self.right_shank_qua count]) {
        data_count = [self.right_shank_qua count];
    }
    if (data_count > [self.left_thigh_qua count]) {
        data_count = [self.left_thigh_qua count];
    }
    if (data_count > [self.right_thigh_qua count]) {
        data_count = [self.right_thigh_qua count];
    }
    for (NSInteger i = 0; i < data_count; i ++) {
        NSInteger frame_index = [[self.frame_index objectAtIndex:i] integerValue];
        //[str appendFormat:@" %ld ", (long)frame_index];
        
        TSEuler *theta;
        theta = [self.task_angles_trunk objectAtIndex:i];
        [str appendFormat:@" %ld %ld %f %f %f ", (long)frame_index, (long)TSJointPointAtTrunk, theta.x*180/PI, theta.y*180/PI, theta.z*180/PI];
        
        theta = [self.task_angles_st objectAtIndex:i];
        [str appendFormat:@" %ld %f %f %f ", (long)TSJointPointAtRightShoulderToTrunk, theta.x*180/PI, theta.y*180/PI, theta.z*180/PI];
        
        theta = [self.task_angles_ht objectAtIndex:i];
        [str appendFormat:@" %ld %f %f %f ", (long)TSJointPointAtRightUpperArmToTrunk, theta.x*180/PI, theta.y*180/PI, theta.z*180/PI];
        
        theta = [self.task_angles_elbow objectAtIndex:i];
        [str appendFormat:@" %ld %f %f %f ", (long)TSJointPointAtRightElbow, theta.x*180/PI, theta.y*180/PI, theta.z*180/PI];
        
        theta = [self.task_angles_lhip objectAtIndex:i];
        [str appendFormat:@" %ld %f %f %f ", (long)TSJointPointAtLeftHip, theta.x*180/PI, theta.y*180/PI, theta.z*180/PI];
        
        theta = [self.task_angles_lknee objectAtIndex:i];
        [str appendFormat:@" %ld %f %f %f ", (long)TSJointPointAtLeftKnee, theta.x*180/PI, theta.y*180/PI, theta.z*180/PI];
        
        theta = [self.task_angles_rhip objectAtIndex:i];
        [str appendFormat:@" %ld %f %f %f ", (long)TSJointPointAtRightHip, theta.x*180/PI, theta.y*180/PI, theta.z*180/PI];
        
        theta = [self.task_angles_rknee objectAtIndex:i];
        [str appendFormat:@" %ld %f %f %f ", (long)TSJointPointAtRightKnee, theta.x*180/PI, theta.y*180/PI, theta.z*180/PI];
        
        [str appendString:@"\n"];
        
    }
    /*NSDate *cur_time = [NSDate date];
     NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
     [formatter setDateFormat:@"yyyy_mm_dd_hh_mm_ss"];
     NSString *file_name = [NSString stringWithFormat:@"/gary/tennis/0225/ios_pietro_sensor_%d_%@.txt", 8, [formatter stringFromDate:cur_time]];
     NSMutableString *str = [[NSMutableString alloc] init];
     [str appendString:@"start to debug \n"];
     
     for (int i = 0; i < data_count; i ++) {
     TSEuler *theta;
     theta = [self.task_angles_ht objectAtIndex:i];
     int sc = 50 + (theta.y * 50 / PI);
     [str appendFormat:@"%10d %f", i, theta.y*180/PI];
     for (int j = 0; j < sc; j ++) {
     [str appendString:@" "];
     }
     [str appendString:@"*\n"];
     }
     
     [str writeToFile:file_name atomically:YES encoding:NSUTF8StringEncoding error:nil];
     */

}


-(void) generateStrokeParamStr:(NSMutableString *)str
{
    [self reportEachStroke];
    // get good stroke number
    //int goodStrokeNumber = [self getGoodStrokesByAngleHT];
    //NSLog(@"Good Stroke number is %d\n", goodStrokeNumber);
    
    // get step, stroke number by accel in Y direction
    // stroke number got from right forearm accel in Y direction
    
    //NSMutableArray *right_forearm_peak_array = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
    //int nStrokesAcc = [self getStrokeNumberByTheshold:self.right_forearm_raw_data type:1 dir:2 threshold:STROKE_MIN_ACCEL_Y max_array:right_forearm_peak_array];
    
    //NSLog(@"nstrokesAcc = %d \n", nStrokesAcc);
    
    // output format
    //[str appendFormat:@"Total Stoke Number is %d \n", nStrokesAcc];
    //[str appendFormat:@"Good Stroke Number is %d \n", goodStrokeNumber];
    
    // output for each stroke
    // steps
    //NSMutableArray *right_shank_peak_array = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
    //[self getStrokeNumberByTheshold:self.right_shank_raw_data type:1 dir:2
     //                     threshold:SHANK_STEP_MIN_ACCEL_Y max_array:right_shank_peak_array];
    
    //NSMutableArray *left_shank_peak_array = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
    //[self getStrokeNumberByTheshold:self.left_shank_raw_data type:1 dir:2
    //                      threshold:SHANK_STEP_MIN_ACCEL_Y max_array:left_shank_peak_array];
    
    //[self reportStepsForEachStroke:right_forearm_peak_array left_shank_peak_array:left_shank_peak_array //right_shank_peak_array:right_shank_peak_array];

}


-(void) getOutPutString:(NSInteger)cal_type output_type:(NSInteger) output_type
        bvh_file_name:(NSString *)bvh_file_name strCalRotMatrix:(NSMutableString *)strCalRotMatrix
        strJointAngle:(NSMutableString *)strJointAngle
        strStroke:(NSMutableString *)strStroke {
    if (cal_type & (1 << TSJointAngleCalibration)) {
        [self genCalibRotMatrix:false];
    }
    if (cal_type & (1 << TSJointAngleUpdateData)) {
        [self genJointAngles];
    }
    
    if (output_type & (1 << TSJointAngleGenerateBVH)) {
        // bvh file generation
        [self generateBVHFile:bvh_file_name];
    }
    
    if (output_type & (1 << TSJointAngleCalibration)) {
        [self generateCalibrationStr:strCalRotMatrix];
    }
    
    if (output_type & (1 << TSJointAngleUpdateData)) {
        [self generateJointAngleStr:strJointAngle];
    }
    
    if (output_type & (1 << TSJointAngleStrokeParam)) {
        [self generateStrokeParamStr:strStroke];
    }
    

    

}
-(void) generateBVHHierarchy:(NSString *)file_name str:(NSMutableString *)str data_count:(NSInteger)data_count upper_arm_length:(double)upper_arm_length wrist_length:(double)wrist_length trunk_length:(double)trunk_length hip_half_length:(double)hip_half_length thigh_length:(double)thigh_length shank_length:(double)shank_length shoulder_length:(double)shoulder_length scale_length:(double)scale_length {
    [str appendString:@"HIERARCHY\n"];
    [str appendString:@"ROOT TrunkChest \r\n"];
    [str appendString:@"{\r\n"];
    [str appendString:@"  OFFSET 0 0 0 \r\n"];
    [str appendString:@"  CHANNELS 6 Xposition Yposition Zposition Zrotation Xrotation Yrotation\r\n"];
    [str appendString:@"  JOINT RightShoulder \r\n"];
    [str appendString:@"  { \r\n"];
    [str appendString:@"    OFFSET 0 0 0 \r\n"];
    [str appendString:@"    CHANNELS 3 Zrotation Xrotation Yrotation \r\n"];
    [str appendString:@"    End Site\r\n"];
    [str appendString:@"    {\r\n"];
    [str appendString:[NSString stringWithFormat:@"      OFFSET %f 0 0 \r\n", shoulder_length*scale_length]];
    [str appendString:@"    }\r\n"];
    [str appendString:@"  }\r\n"];
    [str appendString:@"  JOINT RightUpperArm \r\n"];
    [str appendString:@"  {\r\n"];
    [str appendString:[NSString stringWithFormat:@"    OFFSET %f 0 0 \r\n", shoulder_length*scale_length]];
    [str appendString:@"    CHANNELS 3 Zrotation Xrotation Yrotation\r\n"];
    [str appendString:@"    JOINT RightWrist\r\n"];
    [str appendString:@"    {\r\n"];
    [str appendString:[NSString stringWithFormat:@"      OFFSET 0 %f  0 \r\n", -upper_arm_length*scale_length]];
    [str appendString:@"      CHANNELS 3 Zrotation Xrotation Yrotation\r\n"];
    [str appendString:@"      End Site\r\n"];
    [str appendString:@"      {\r\n"];
    [str appendString:[NSString stringWithFormat:@"        OFFSET 0 %f 0 \r\n", -wrist_length*scale_length]];
    [str appendString:@"      }\r\n"];
    [str appendString:@"    }\r\n"];
    [str appendString:@"  }\r\n"];
    [str appendString:@"  JOINT Hips \r\n"];
    [str appendString:@"  { \r\n"];
    [str appendString:@"    OFFSET 0 0 0 \r\n"];
    [str appendString:@"    CHANNELS 3 Zrotation Xrotation Yrotation \r\n"];
    [str appendString:@"    JOINT LeftHips \r\n"];
    [str appendString:@"    { \r\n"];
    [str appendString:[NSString stringWithFormat:@"      OFFSET 0 %f 0 \r\n",-trunk_length*scale_length]];
    [str appendString:@"      CHANNELS 3 Zrotation Xrotation Yrotation \r\n"];
    [str appendString:@"      JOINT LeftThigh \r\n"];
    [str appendString:@"      { \r\n"];
    [str appendString:[NSString stringWithFormat:@"        OFFSET %f 0 0 \r\n", -hip_half_length*scale_length]];
    [str appendString:@"        CHANNELS 3 Zrotation Xrotation Yrotation \r\n"];
    [str appendString:@"        JOINT LeftShank \r\n"];
    [str appendString:@"        { \r\n"];
    [str appendString:[NSString stringWithFormat:@"          OFFSET 0 %f 0 \r\n", -thigh_length*scale_length]];
    [str appendString:@"          CHANNELS 3 Zrotation Xrotation Yrotation \r\n"];
    [str appendString:@"          End Site \r\n"];
    [str appendString:@"          { \r\n"];
    [str appendString:[NSString stringWithFormat:@"            OFFSET 0 %f 0 \r\n", -shank_length*scale_length]];
    [str appendString:@"          } \r\n"];
    [str appendString:@"        } \r\n"];
    [str appendString:@"      } \r\n"];
    [str appendString:@"    } \r\n"];
    [str appendString:@"    JOINT RightHips \r\n"];
    [str appendString:@"    { \r\n"];
    [str appendString:[NSString stringWithFormat:@"      OFFSET 0 %f 0 \r\n", -trunk_length*scale_length]];
    [str appendString:@"      CHANNELS 3 Zrotation Xrotation Yrotation \r\n"];
    [str appendString:@"      JOINT RightThigh \r\n"];
    [str appendString:@"      { \r\n"];
    [str appendString:[NSString stringWithFormat:@"        OFFSET %f 0 0 \r\n", hip_half_length*scale_length]];
    [str appendString:@"        CHANNELS 3 Zrotation Xrotation Yrotation \r\n"];
    [str appendString:@"        JOINT RightShank \r\n"];
    [str appendString:@"        { \r\n"];
    [str appendString:[NSString stringWithFormat:@"          OFFSET 0 %f 0 \r\n", -thigh_length*scale_length]];
    [str appendString:@"          CHANNELS 3 Zrotation Xrotation Yrotation \r\n"];
    [str appendString:@"          End Site \r\n"];
    [str appendString:@"          { \r\n"];
    [str appendString:[NSString stringWithFormat:@"            OFFSET 0 %f 0 \r\n",-shank_length*scale_length]];
    [str appendString:@"          } \r\n"];
    [str appendString:@"        } \r\n"];
    [str appendString:@"      } \r\n"];
    [str appendString:@"    } \r\n"];
    [str appendString:@"  }\r\n"];
    [str appendString:@"}\r\n"];
    [str appendString:@"MOTION\r\n"];
    [str appendString:[NSString stringWithFormat:@"Frames: %ld \r\n",(long)data_count]];
    [str appendString:@"Frame Time: 0.01\r\n"];
}

-(void) generateBVHFile:(NSString *)file_name {
    NSInteger data_count = [self.trunk_chest_qua count];
    if (data_count > [self.right_shoulder_qua count]) {
        data_count = [self.right_shoulder_qua count];
    }
    if (data_count > [self.right_upper_arm_qua count]) {
        data_count = [self.right_upper_arm_qua count];
    }
    if (data_count > [self.right_forearm_qua count]) {
        data_count = [self.right_forearm_qua count];
    }
    if (data_count > [self.left_shank_qua count]) {
        data_count = [self.left_shank_qua count];
    }
    if (data_count > [self.right_shank_qua count]) {
        data_count = [self.right_shank_qua count];
    }
    if (data_count > [self.left_thigh_qua count]) {
        data_count = [self.left_thigh_qua count];
    }
    if (data_count > [self.right_thigh_qua count]) {
        data_count = [self.right_thigh_qua count];
    }
    
    double upper_arm_length = 0.32;
    double shoulder_length = 0.15;
    double wrist_length = 0.38;
    double trunk_length = 0.5;
    double shank_length = 0.4;
    double thigh_lenght = 0.5;
    double hip_half_length = 0.18;
    double scale_length = 30;
    NSMutableString *bvh_str = [[NSMutableString alloc] init];
    
    
    [self generateBVHHierarchy:file_name str:bvh_str data_count:data_count upper_arm_length:upper_arm_length wrist_length:wrist_length trunk_length:trunk_length hip_half_length:hip_half_length thigh_length:thigh_lenght shank_length:shank_length shoulder_length:shoulder_length scale_length:scale_length];
    
    // print data
    double loc_y = (trunk_length + thigh_lenght + shank_length) * scale_length;
    for (int i = 0; i < data_count; i ++) {
        NSLog(@" indx=%d   from %d to %ld\n", i, 0, data_count);
        [bvh_str appendString:[NSString stringWithFormat:@" 0 %f 0  ", loc_y]];
        
        TSEuler *theta;
        theta = [self.task_angles_trunk objectAtIndex:i];
        [bvh_str appendString:[NSString stringWithFormat:@" %f %f %f ", theta.z * 180/PI, theta.x * 180/PI, theta.y*180/PI]];
        
        theta = [self.task_angles_st objectAtIndex:i];
        [bvh_str appendString:[NSString stringWithFormat:@" %f %f %f ", theta.z * 180/PI, theta.x * 180/PI, theta.y*180/PI]];
        
        theta = [self.task_angles_ht objectAtIndex:i];
        [bvh_str appendString:[NSString stringWithFormat:@" %f %f %f ", theta.z * 180/PI, theta.x * 180/PI, theta.y*180/PI]];
        
        theta = [self.task_angles_elbow objectAtIndex:i];
        [bvh_str appendString:[NSString stringWithFormat:@" %f %f %f ", theta.z * 180/PI, theta.x * 180/PI, theta.y*180/PI]];
        
        [bvh_str appendString:@" 0 0 0 0 0 0 "];
        
        theta = [self.task_angles_lhip objectAtIndex:i];
        [bvh_str appendString:[NSString stringWithFormat:@" %f %f %f ", theta.z * 180/PI, theta.x * 180/PI, theta.y*180/PI]];
        
        theta = [self.task_angles_lknee objectAtIndex:i];
        [bvh_str appendString:[NSString stringWithFormat:@" %f %f %f ", theta.z * 180/PI, theta.x * 180/PI, theta.y*180/PI]];
        
        [bvh_str appendString:@" 0 0 0  "];
        
        theta = [self.task_angles_rhip objectAtIndex:i];
        [bvh_str appendString:[NSString stringWithFormat:@" %f %f %f ", theta.z * 180/PI, theta.x * 180/PI, theta.y*180/PI]];
        
        theta = [self.task_angles_rknee objectAtIndex:i];
        [bvh_str appendString:[NSString stringWithFormat:@" %f %f %f ", theta.z * 180/PI, theta.x * 180/PI, theta.y*180/PI]];
        
        [bvh_str appendString:@"\r\n"];
    }
    [bvh_str writeToFile:file_name atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
@end

