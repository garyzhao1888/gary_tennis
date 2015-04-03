//
//  pdbRotMatrix.h
//  ts_tennis_0331
//
//  Created by Master on 3/30/15.
//  Copyright (c) 2015 Master. All rights reserved.
//

#ifndef ts_tennis_0331_pdbRotMatrix_h
#define ts_tennis_0331_pdbRotMatrix_h
#import "tsaQuaternion.h"
#import "tsaEuler.h"
@interface TSRotMatrix : NSObject
@property(nonatomic,assign) double r11;
@property(nonatomic,assign) double r12;
@property(nonatomic,assign) double r13;
@property(nonatomic,assign) double r21;
@property(nonatomic,assign) double r22;
@property(nonatomic,assign) double r23;
@property(nonatomic,assign) double r31;
@property(nonatomic,assign) double r32;
@property(nonatomic,assign) double r33;
-(TSRotMatrix *)initWithName:(TSRotMatrix*)rot_mat;
-(void) encodeWithCoder:(NSCoder*) aCoder;
-(id) initWithCoder:(NSCoder *) aDecoder;
-(void) initWithUnit;
-(void) transpose_matrix;
-(void) transpose_matrix:(TSRotMatrix *) rot_mat;
-(void) get_rotmatrix_from_qua:(TSQuater*) qua;
-(void) cross_product:(TSRotMatrix*) rm1 rm2:(TSRotMatrix*) rm2;
-(void) calibration_by_rot_matrix:(TSRotMatrix *)rot_matrix;
-(void) sensor_to_segment_calibration:(TSRotMatrix *) sensor_rot_matrix trunk_rm:(TSRotMatrix *) trunk_rm calib_g_trunk:(TSRotMatrix *) calib_g_trunk;
-(void) joint_rot_matrix:(TSRotMatrix *) sensor_rot_mat pre_rot_mat:(TSRotMatrix *)pre_rot_mat;
-(void) rotation_matrix_2_zxy:(TSEuler *) theta;
-(void) rotation_matrix_2_xzy:(TSEuler *) theta;
@end

#endif
