//
//  joint_angle_process.m
//  ts_tennis_0325
//
//  Created by Master on 3/26/15.
//  Copyright (c) 2015 Master. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "joint_angle.h"
#import "sensor_data.h"
@implementation TSQuater
-(TSQuater *) initWithQua:(TSQuater *)qua {
    self = [super init];
    if (self) {
        self.w = qua.w;
        self.x = qua.x;
        self.y = qua.y;
        self.z = qua.z;
    }
    return self;
}
-(TSQuater *) initWithWXYZ:(double)w x:(double)x y:(double)y z:(double)z {
    self = [super init];
    if (self) {
        self.w = w;
        self.x = x;
        self.y = y;
        self.z = z;
    }
    return self;
}
- (void) normalize {
    double am = sqrt(self.w*self.w + self.x*self.x+self.y*self.y+self.z*self.z);
    self.w = self.w/am;
    self.x = self.x/am;
    self.y = self.y/am;
    self.z = self.z/am;
}
-(void) conj_qua:(TSQuater *)qua {
    self.w = qua.w;
    self.x = -qua.x;
    self.y = -qua.y;
    self.z = -qua.z;
}
-(void) qua_product:(TSQuater *)qua1 qua2:(TSQuater *)qua2 {
    self.w = qua1.w * qua2.w - qua1.x * qua2.x - qua1.y * qua2.y - qua1.z * qua2.z;
    self.x = qua1.w * qua2.x + qua1.x * qua2.w + qua1.y * qua2.z - qua1.z * qua2.y;
    self.y = qua1.y * qua2.w + qua1.w * qua2.y + qua1.z * qua2.x - qua1.x * qua2.z;
    self.z = qua1.w * qua2.z + qua1.z * qua2.w + qua1.x * qua2.y - qua1.y * qua2.x;
}
@end

@implementation TSVector
-(void) qua_roration:(TSQuater *)qua {
    TSQuater *t_q = [[TSQuater alloc] init];
    [t_q conj_qua:qua];
    TSQuater *vector_q = [[TSQuater alloc] init];
    vector_q.w = 0;
    vector_q.x = self.x;
    vector_q.y = self.y;
    vector_q.z = self.z;
    // [vector_q normalize];
    TSQuater *temp = [[TSQuater alloc] init];
    [temp qua_product:qua qua2:vector_q];
    vector_q.w = temp.w;
    vector_q.x = temp.x;
    vector_q.y = temp.y;
    vector_q.z = temp.z;
    [temp qua_product:vector_q qua2:t_q];
    self.x = temp.x;
    self.y = temp.y;
    self.z = temp.z;
}

-(void) normalize {
    double am = sqrt(self.x*self.x + self.y*self.y + self.z*self.z);
    if (am <= 0) {
        return;
    }
    self.x = self.x/am;
    self.y = self.y/am;
    self.z = self.z/am;
}
-(double) dotprod:(TSVector *)v1 v2:(TSVector *)v2 {
    double sm = sqrt(v1.x*v2.x + v1.y * v2.y + v1.z * v2.z);
    return sm;
}
-(void) crossprod:(TSVector *)v1 v2:(TSVector *)v2 {
    self.x = v1.y * v2.z - v1.z * v2.y;
    self.y = v1.z * v2.x - v1.x * v2.z;
    self.z = v1.x * v2.y - v1.y * v2.x;
    [self normalize];
}

-(void) setQuaterByVector:(TSQuater *)qua v1:(TSVector *)v1 v2:(TSVector *)v2 {
    [v1 normalize];
    [v2 normalize];
    double sm = [v1 dotprod:v1 v2:v2];
    double theta = acos(sm)/2;
    TSVector *new_v = [[TSVector alloc] init];
    [new_v dotprod:v1 v2:v2];
    qua.w = cos(theta);
    qua.x = new_v.x * sin(theta);
    qua.y = new_v.y * sin(theta);
    qua.z = new_v.z * sin(theta);
}

-(void) setQuaterByVector:(TSQuater *)qua v:(TSVector *)v theta:(double)theta {
    double h_theta = theta/2;
    [v normalize];
    qua.w = cos(h_theta);
    qua.x = v.x * sin(h_theta);
    qua.y = v.y * sin(h_theta);
    qua.z = v.z * sin(h_theta);
}

@end


@implementation TSEuler
-(TSEuler *) initWithTSEuler:(TSEuler *)theta {
    self = [super init];
    if (self) {
        self.x = theta.x;
        self.y = theta.y;
        self.z = theta.z;
    }
    return self;
}
-(void) getZXYFromQua:(TSQuater *)qua {
    // convert quater to Rotation matrix at first
    [qua normalize];
    //double r11 = 2 * (qua.w * qua.w + qua.x * qua.x) - 1;
    double r12 = 2 * (qua.x * qua.y - qua.w * qua.z);
    //double r13 = 2 * (qua.x * qua.z + qua.w * qua.y);
    
    //double r21 = 2 * (qua.x * qua.y + qua.w * qua.z);
    double r22 = 2 * (qua.w * qua.w + qua.y * qua.y) - 1;
    //double r23 = 2 * (qua.y * qua.z - qua.w * qua.x);
    
    double r31 = 2 * (qua.x * qua.z - qua.w * qua.y);
    double r32 = 2 * (qua.y * qua.z + qua.w * qua.x);
    double r33 = 2 * (qua.w * qua.w + qua.z * qua.z) - 1;
    
    self.x = asin(r32);
    if ((self.x < -PI/2) || (self.x > PI/2)) {
        
    }
    if (self.x < -PI/2) {
        self.x = -PI - self.x;
    } else if (self.x > PI/2) {
        self.x = PI - self.x;
    }
    double sy = -r31/cos(self.x);
    double cy = r33/cos(self.x);
    double sz = -r12/cos(self.x);
    double cz = r22/cos(self.x);
    self.y = atan2(sy,cy);
    self.z = atan2(sz,cz);
}
@end

@implementation TSRotMatrix
-(TSRotMatrix*)initWithName:(TSRotMatrix *)rot_mat {
    self = [super init];
    if (self) {
        self.r11 = rot_mat.r11;
        self.r12 = rot_mat.r12;
        self.r13 = rot_mat.r13;
        self.r21 = rot_mat.r21;
        self.r22 = rot_mat.r22;
        self.r23 = rot_mat.r23;
        self.r31 = rot_mat.r31;
        self.r32 = rot_mat.r32;
        self.r33 = rot_mat.r33;
    }
    return self;
}
-(void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeDouble:self.r11 forKey:@"r11"];
    [aCoder encodeDouble:self.r12 forKey:@"r12"];
    [aCoder encodeDouble:self.r13 forKey:@"r13"];
    [aCoder encodeDouble:self.r21 forKey:@"r21"];
    [aCoder encodeDouble:self.r22 forKey:@"r22"];
    [aCoder encodeDouble:self.r23 forKey:@"r23"];
    [aCoder encodeDouble:self.r31 forKey:@"r31"];
    [aCoder encodeDouble:self.r32 forKey:@"r32"];
    [aCoder encodeDouble:self.r33 forKey:@"r33"];
}
-(id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.r11 = [aDecoder decodeDoubleForKey:@"r11"];
        self.r12 = [aDecoder decodeDoubleForKey:@"r12"];
        self.r13 = [aDecoder decodeDoubleForKey:@"r13"];
        self.r21 = [aDecoder decodeDoubleForKey:@"r21"];
        self.r22 = [aDecoder decodeDoubleForKey:@"r22"];
        self.r23 = [aDecoder decodeDoubleForKey:@"r23"];
        self.r31 = [aDecoder decodeDoubleForKey:@"r31"];
        self.r32 = [aDecoder decodeDoubleForKey:@"r32"];
        self.r33 = [aDecoder decodeDoubleForKey:@"r33"];
    }
    return self;
}
-(void) transpose_matrix {
    double temp = self.r12;
    self.r12 = self.r21;
    self.r21 = temp;
    
    temp = self.r13;
    self.r13 = self.r31;
    self.r31 = temp;
    
    temp = self.r23;
    self.r23 = self.r32;
    self.r32 = temp;
}

-(void) transpose_matrix:(TSRotMatrix *)rot_mat {
    self.r11 = rot_mat.r11;
    self.r12 = rot_mat.r21;
    self.r13 = rot_mat.r31;
    self.r21 = rot_mat.r12;
    self.r22 = rot_mat.r22;
    self.r23 = rot_mat.r32;
    self.r31 = rot_mat.r13;
    self.r32 = rot_mat.r23;
    self.r33 = rot_mat.r33;
}
-(void) get_rotmatrix_from_qua:(TSQuater *)qua {
    [qua normalize];
    self.r11 = 2 * (qua.w * qua.w + qua.x * qua.x) - 1;
    self.r12 = 2 * (qua.x * qua.y - qua.w * qua.z);
    self.r13 = 2 * (qua.x * qua.z + qua.w * qua.y);
    
    self.r21 = 2 * (qua.x * qua.y + qua.w * qua.z);
    self.r22 = 2 * (qua.w * qua.w + qua.y * qua.y) - 1;
    self.r23 = 2 * (qua.y * qua.z - qua.w * qua.x);
    
    self.r31 = 2 * (qua.x * qua.z - qua.w * qua.y);
    self.r32 = 2 * (qua.y * qua.z + qua.w * qua.x);
    self.r33 = 2 * (qua.w * qua.w + qua.z * qua.z) - 1;
}

-(void) cross_product:(TSRotMatrix *)rm1 rm2:(TSRotMatrix *)rm2 {
    self.r11 = rm1.r11 * rm2.r11 + rm1.r12 * rm2.r21 + rm1.r13 * rm2.r31;
    self.r12 = rm1.r11 * rm2.r12 + rm1.r12 * rm2.r22 + rm1.r13 * rm2.r32;
    self.r13 = rm1.r11 * rm2.r13 + rm1.r12 * rm2.r23 + rm1.r13 * rm2.r33;
    
    self.r21 = rm1.r21 * rm2.r11 + rm1.r22 * rm2.r21 + rm1.r23 * rm2.r31;
    self.r22 = rm1.r21 * rm2.r12 + rm1.r22 * rm2.r22 + rm1.r23 * rm2.r32;
    self.r23 = rm1.r21 * rm2.r13 + rm1.r22 * rm2.r23 + rm1.r23 * rm2.r33;
    
    self.r31 = rm1.r31 * rm2.r11 + rm1.r32 * rm2.r21 + rm1.r33 * rm2.r31;
    self.r32 = rm1.r31 * rm2.r12 + rm1.r32 * rm2.r22 + rm1.r33 * rm2.r32;
    self.r33 = rm1.r31 * rm2.r13 + rm1.r32 * rm2.r23 + rm1.r33 * rm2.r33;
}

-(void) calibration_by_rot_matrix:(TSRotMatrix *)rot_matrix {
    self.r12 = 0;
    self.r22 = 0;
    self.r32 = 1;
    
    TSVector *v1 = [[TSVector alloc] init];
    v1.x = rot_matrix.r13;
    v1.y = rot_matrix.r23;
    v1.z = rot_matrix.r33;
    
    TSVector *v2 = [[TSVector alloc] init];
    v2.x = 0;
    v2.y = 0;
    v2.z = 1;
    
    TSVector *vx = [[TSVector alloc] init];
    [vx crossprod:v1 v2:v2];
    [vx normalize];
    
    self.r11 = vx.x;
    self.r21 = vx.y;
    self.r31 = vx.z;
    
    TSVector *vz = [[TSVector alloc] init];
    [vz crossprod:vx v2:v2];
    [vz normalize];
    
    self.r13 = vz.x;
    self.r23 = vz.y;
    self.r33 = vz.z;
}
-(void) sensor_to_segment_calibration:(TSRotMatrix *)sensor_rot_matrix trunk_rm:(TSRotMatrix *)trunk_rm calib_g_trunk:(TSRotMatrix *)calib_g_trunk {
    TSRotMatrix *tmp_sensor_rm = [[TSRotMatrix alloc] init];
    [tmp_sensor_rm transpose_matrix:sensor_rot_matrix];
    
    TSRotMatrix *tmp1 = [[TSRotMatrix alloc] init];
    [tmp1 cross_product:tmp_sensor_rm rm2:trunk_rm];
    
    TSRotMatrix *tmp2 = [[TSRotMatrix alloc] init];
    [tmp2 transpose_matrix:trunk_rm];
    [tmp_sensor_rm cross_product:tmp1 rm2:tmp2];
    
    [self cross_product:tmp_sensor_rm rm2:calib_g_trunk];
    
}
-(void) joint_rot_matrix:(TSRotMatrix *)sensor_rot_mat pre_rot_mat:(TSRotMatrix *)pre_rot_mat {
    TSRotMatrix *tmp = [[TSRotMatrix alloc] init];
    [tmp transpose_matrix:sensor_rot_mat];
    [self cross_product:tmp rm2:pre_rot_mat];
}

-(void) rotation_matrix_2_zxy:(TSEuler *)theta {
    theta.x = asin(self.r32);
    if (theta.x > PI/2) {
        theta.x = PI - theta.x;
    } else if (theta.x < -PI/2) {
        theta.x = -PI - theta.x;
    }
    double sy = -self.r31/cos(theta.x);
    double cy = self.r33/cos(theta.x);
    double sz = -self.r12/cos(theta.x);
    double cz = self.r22/cos(theta.x);
    theta.y = atan2(sy,cy);
    theta.z = atan2(sz,cz);
}

-(void) rotation_matrix_2_xzy:(TSEuler *)theta {
    theta.z = asin(-self.r12);
    if (theta.z > PI/2) {
        theta.z = PI - theta.z;
    } else if (theta.z < -PI/2) {
        theta.z = -PI - theta.z;
    }
    double sx = self.r32/cos(theta.z);
    double cx = self.r22/cos(theta.z);
    double sy = self.r13/cos(theta.z);
    double cy = self.r11/cos(theta.z);
    theta.x = atan2(sx,cx);
    theta.y = atan2(sy,cy);
}
@end

@implementation TSMaxValue
-(TSMaxValue *) initWithValueIndex:(double)v index:(int)index {
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
        self.calib_trunk_a_R_s_t = [[TSRotMatrix alloc] init];
        self.calib_shoulder_s_R_a = [[TSRotMatrix alloc] init];
        self.calib_upper_arm_s_R_a = [[TSRotMatrix alloc] init];
        self.calib_forearm_s_R_a = [[TSRotMatrix alloc] init];
        self.calib_rthigh_s_R_a = [[TSRotMatrix alloc] init];
        self.calib_lthigh_s_R_a = [[TSRotMatrix alloc] init];
        self.calib_rshank_s_R_a = [[TSRotMatrix alloc] init];
        self.calib_lshank_s_R_a = [[TSRotMatrix alloc] init];
        
        self.task_angles_trunk = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.task_angles_st = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.task_angles_ht = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.task_angles_elbow = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.task_angles_rhip = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.task_angles_rknee = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.task_angles_lhip = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
        self.task_angles_lknee = [NSMutableArray arrayWithCapacity:MAX_DATA_NUMBER];
    }
    return self;
}

-(void) addSensorQuaData:(TSQuater *)qua sensor_pos:(TSSensorPosition)sensor_pos {
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
    [qua_array addObject:[[TSQuater alloc] initWithWXYZ:qua.w x:qua.x y:qua.y z:qua.z]];
}

-(void) genCalibRotMatrix {
    TSQuater *qua = [[TSQuater alloc] init];
    TSRotMatrix *trunk_rot_matrix = [[TSRotMatrix alloc] init];
    qua = [self.trunk_chest_qua objectAtIndex:(trunk_start + STATIC_INDEX)];
  
    [trunk_rot_matrix get_rotmatrix_from_qua:qua];
    
    TSRotMatrix *calib_g_trunk = [[TSRotMatrix alloc] init];
    [calib_g_trunk calibration_by_rot_matrix:trunk_rot_matrix];
    TSRotMatrix *calib_g_trunk_t = [[TSRotMatrix alloc] init];
    [calib_g_trunk_t transpose_matrix:calib_g_trunk];
    
    [self.calib_trunk_a_R_s cross_product:calib_g_trunk_t rm2:trunk_rot_matrix];
    [self.calib_trunk_a_R_s_t transpose_matrix:self.calib_trunk_a_R_s];
    
          
    TSRotMatrix *rot_matrix = [[TSRotMatrix alloc] init];
    
    if ([self.right_shoulder_qua count] > (shoulder_start+STATIC_INDEX)) {
        qua = [self.right_shoulder_qua objectAtIndex:(shoulder_start+STATIC_INDEX)];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [self.calib_shoulder_s_R_a sensor_to_segment_calibration:rot_matrix trunk_rm:trunk_rot_matrix calib_g_trunk:calib_g_trunk];
    }
    
    if ([self.right_upper_arm_qua count] > (upper_arm_start+STATIC_INDEX)) {
        qua = [self.right_upper_arm_qua objectAtIndex:(upper_arm_start+STATIC_INDEX)];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [self.calib_upper_arm_s_R_a sensor_to_segment_calibration:rot_matrix trunk_rm:trunk_rot_matrix calib_g_trunk:calib_g_trunk];
    }
    
    if ([self.right_forearm_qua count] > (forearm_start+STATIC_INDEX)) {
        qua = [self.right_forearm_qua objectAtIndex:(forearm_start+STATIC_INDEX)];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [self.calib_forearm_s_R_a sensor_to_segment_calibration:rot_matrix trunk_rm:trunk_rot_matrix calib_g_trunk:calib_g_trunk];
    }
    
    if ([self.right_shank_qua count] > (rshank_start+STATIC_INDEX)) {
        qua = [self.right_shank_qua objectAtIndex:(rshank_start+STATIC_INDEX)];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [self.calib_rshank_s_R_a sensor_to_segment_calibration:rot_matrix trunk_rm:trunk_rot_matrix calib_g_trunk:calib_g_trunk];
    }
    
    if ([self.left_shank_qua count] > (lshank_start+STATIC_INDEX)) {
        qua = [self.left_shank_qua objectAtIndex:(lshank_start+STATIC_INDEX)];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [self.calib_lshank_s_R_a sensor_to_segment_calibration:rot_matrix trunk_rm:trunk_rot_matrix calib_g_trunk:calib_g_trunk];
    }
    
    if ([self.right_thigh_qua count] > (rthigh_start+STATIC_INDEX)) {
        qua = [self.right_thigh_qua objectAtIndex:(rthigh_start+STATIC_INDEX)];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [self.calib_rthigh_s_R_a sensor_to_segment_calibration:rot_matrix trunk_rm:trunk_rot_matrix calib_g_trunk:calib_g_trunk];
    }
    
    if ([self.left_thigh_qua count] > (lthigh_start+STATIC_INDEX)) {
        qua = [self.left_thigh_qua objectAtIndex:(lthigh_start+STATIC_INDEX)];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [self.calib_lthigh_s_R_a sensor_to_segment_calibration:rot_matrix trunk_rm:trunk_rot_matrix calib_g_trunk:calib_g_trunk];
    }
    
}

-(void) genJointAngles {
    NSMutableArray *trunk_chest_rot_matrix = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *shoulder_rot_matrix = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *upper_arm_rot_matrix = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *forearm_rot_matrix = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *rthigh_rot_matrix = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *rshank_rot_matrix = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *lthigh_rot_matrix = [NSMutableArray arrayWithCapacity:data_count];
    NSMutableArray *lshank_rot_matrix = [NSMutableArray arrayWithCapacity:data_count];
    
    for (int i = 0; i < data_count; i ++) {
        TSQuater *qua = [[TSQuater alloc] init];
        TSRotMatrix *rot_matrix = [[TSRotMatrix alloc] init];
        qua = [self.trunk_chest_qua objectAtIndex:trunk_start+i];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [trunk_chest_rot_matrix addObject:[[TSRotMatrix alloc] initWithName:rot_matrix]];
        
        qua = [self.right_shoulder_qua objectAtIndex:shoulder_start+i];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [shoulder_rot_matrix addObject:[[TSRotMatrix alloc] initWithName:rot_matrix]];
        
        qua = [self.right_upper_arm_qua objectAtIndex:upper_arm_start+i];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [upper_arm_rot_matrix addObject:[[TSRotMatrix alloc] initWithName:rot_matrix]];
      
        qua = [self.right_forearm_qua objectAtIndex:forearm_start+i];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [forearm_rot_matrix addObject:[[TSRotMatrix alloc] initWithName:rot_matrix]];
       
        qua = [self.right_thigh_qua objectAtIndex:rthigh_start+i];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [rthigh_rot_matrix addObject:[[TSRotMatrix alloc] initWithName:rot_matrix]];
      
        qua = [self.right_shank_qua objectAtIndex:rshank_start+i];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [rshank_rot_matrix addObject:[[TSRotMatrix alloc] initWithName:rot_matrix]];
     
        qua = [self.left_thigh_qua objectAtIndex:lthigh_start+i];
        [rot_matrix get_rotmatrix_from_qua:qua];
        [lthigh_rot_matrix addObject:[[TSRotMatrix alloc] initWithName:rot_matrix]];
  
        qua = [self.left_shank_qua objectAtIndex:lshank_start+i];
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
    for (int i = 0; i < data_count; i ++) {
        TSRotMatrix *rot_mat = [[TSRotMatrix alloc] init];
        [rot_mat cross_product:[trunk_chest_rot_matrix objectAtIndex:i] rm2:self.calib_trunk_a_R_s_t];
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
    
    for (int i = 0; i < data_count; i ++) {
        TSRotMatrix *rot_mat = [[TSRotMatrix alloc] init];
        [rot_mat joint_rot_matrix:[task_trunk_g_r_a objectAtIndex:STATIC_INDEX] pre_rot_mat:[task_trunk_g_r_a objectAtIndex:i]];
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


    
    for (int i = 0; i < data_count; i ++) {
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
    
    /*NSDate *cur_time = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy_mm_dd_hh_mm_ss"];
    NSString *file_name = [NSString stringWithFormat:@"/gary/tennis/0225/ios_pietro_sensor_%d_%@.txt", 8, [formatter stringFromDate:cur_time]];
    NSMutableString *str = [[NSMutableString alloc] init];
    [str appendString:@"start to debug \n"];

    for (int i = 0; i < data_count; i ++) {
        TSEuler *theta = [[TSEuler alloc] init];
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
    double org_data[count];
    double new_data[count+3];
    double value = 0;
    for (int i = 0; i < count; i ++) {
        if (type == 0) {
            TSEuler *theta = [[TSEuler alloc] init];
            theta = [data objectAtIndex:i];
            if (dir == 1) {
                value = theta.x * 180/PI;
            } else if (dir == 2) {
                value = theta.y * 180/PI;
            } else {
                value = theta.z * 180/PI;
            }
        } else if (type == 1) {
            TSAccGyroTimeData *accel = [[TSAccGyroTimeData alloc] init];
            accel = [data objectAtIndex:i];
            if (dir == 1) {
                value = accel.accel_x;
            } else if (dir == 2) {
                value = accel.accel_y;
            } else if (dir == 3) {
                value = accel.accel_z;
            }
        }
        org_data[i] = value;
    }
    
    NSInteger x1 = org_data[0];
    NSInteger x2 = org_data[count-1];
    for (int jj = 1; jj <= 5; jj ++) {
        for (int i1 = 0; i1 < (count + 3); i1 ++) {
            new_data[i1] = 0;
        }
        for (int i1 = 0; i1 < 3; i1 ++) {
            for (int i2 = 0; i2 < count; i2++) {
                new_data[i1+i2] = new_data[i1+i2] + org_data[i2]/3;
            }
        }
        for (int i1 = 0; i1 < count; i1++) {
            org_data[i1] = new_data[i1+1];
        }
        org_data[0] = x1;
        org_data[count-1] = x2;
    }
    NSMutableArray *peak_array = [NSMutableArray arrayWithCapacity:count];
    double pre_value = -threshold;
    for (int i = 1; i < (count - 1); i ++) {
        if (org_data[i] > org_data[i-1] && org_data[i] > org_data[i+1]) {
            [peak_array addObject:[[TSMaxValue alloc] initWithValueIndex:org_data[i] index:i]];
        } else if (org_data[i] == org_data[i-1] && org_data[i] > org_data[i+1]) {
            if (org_data[i] > pre_value) {
                [peak_array addObject:[[TSMaxValue alloc] initWithValueIndex:org_data[i] index:i]];
            }
        } else if (org_data[i] > org_data[i-1] && org_data[i] == org_data[i+1]) {
            pre_value = org_data[i-1];
        } else {
            pre_value = org_data[i];
        }
    }
    int pre_idx = -STROKE_MIN_TIME;
    pre_value = -threshold;
    int number = 0;
    count = [peak_array count];
    for (int i = 0; i < count; i ++) {
        TSMaxValue *max_value = [[TSMaxValue alloc] init];
        max_value = [peak_array objectAtIndex:i];
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

-(void) reportStepsForEachStroke:(NSMutableArray *)right_forearm_peak_array left_shank_peak_array:(NSMutableArray *)left_shank_peak_array right_shank_peak_array:(NSMutableArray *)right_shank_peak_array {
    NSInteger stroke_count = [right_forearm_peak_array count];
    NSInteger left_shank_count = [left_shank_peak_array count];
    NSInteger right_shank_count = [right_shank_peak_array count];
    int cur_left_shank_idx = 0;
    int cur_right_shank_idx = 0;
    for (int i = 0; i < stroke_count; i ++) {
        TSMaxValue *forearm = [[TSMaxValue alloc] init];
        forearm = [right_forearm_peak_array objectAtIndex:i];
        int pre_idx = cur_left_shank_idx;
        for (;cur_left_shank_idx < left_shank_count;cur_left_shank_idx++) {
            TSMaxValue *leftshank = [[TSMaxValue alloc] init];
            leftshank = [left_shank_peak_array objectAtIndex:cur_left_shank_idx];
            if (leftshank.index > forearm.index) {
                break;
            }
        }
        NSLog(@"stroke idx is %d \n", i);
        NSLog(@"    left step is %d \n", cur_left_shank_idx-pre_idx);
        pre_idx = cur_right_shank_idx;
        for (;cur_right_shank_idx < right_shank_count;cur_right_shank_idx++) {
            TSMaxValue *rightshank = [[TSMaxValue alloc] init];
            rightshank = [right_shank_peak_array objectAtIndex:cur_right_shank_idx];
            if (rightshank.index > forearm.index) {
                break;
            }
        }
        NSLog(@"    right step is %d \n", cur_right_shank_idx - pre_idx);
    }
}

-(void) generateBVHHierarchy:(NSString *)file_name str:(NSMutableString *)str data_count:(int)data_count upper_arm_length:(double)upper_arm_length wrist_length:(double)wrist_length trunk_length:(double)trunk_length hip_half_length:(double)hip_half_length thigh_length:(double)thigh_length shank_length:(double)shank_length shoulder_length:(double)shoulder_length scale_length:(double)scale_length {
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
    [str appendString:[NSString stringWithFormat:@"Frames: %d \r\n",data_count]];
    [str appendString:@"Frame Time: 0.01\r\n"];
}

-(void) generateBVHFile:(NSString *)file_name {
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
        
        TSEuler *theta = [[TSEuler alloc] init];
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



