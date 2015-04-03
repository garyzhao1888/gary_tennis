//
//  pdbRotMatrix.m
//  ts_tennis_0331
//
//  Created by Master on 3/30/15.
//  Copyright (c) 2015 Master. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tsaQuaternion.h"
#import "tsaRotMatrix.h"
#import "tsaVector.h"
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
-(void) initWithUnit {
    self.r11 = 1;
    self.r12 = 0;
    self.r13 = 0;
    self.r21 = 0;
    self.r22 = 0;
    self.r23 = 0;
    self.r31 = 0;
    self.r32 = 0;
    self.r33 = 1;
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
    if (theta.x > M_PI/2) {
        theta.x = M_PI - theta.x;
    } else if (theta.x < -M_PI/2) {
        theta.x = -M_PI - theta.x;
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
    if (theta.z > M_PI/2) {
        theta.z = M_PI - theta.z;
    } else if (theta.z < -M_PI/2) {
        theta.z = -M_PI - theta.z;
    }
    double sx = self.r32/cos(theta.z);
    double cx = self.r22/cos(theta.z);
    double sy = self.r13/cos(theta.z);
    double cy = self.r11/cos(theta.z);
    theta.x = atan2(sx,cx);
    theta.y = atan2(sy,cy);
}
@end
