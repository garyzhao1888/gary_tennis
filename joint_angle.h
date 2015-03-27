//
//  joint_angle.h
//  ts_tennis_0325
//
//  Created by Master on 3/26/15.
//  Copyright (c) 2015 Master. All rights reserved.
//

#ifndef ts_tennis_0325_joint_angle_h
#define ts_tennis_0325_joint_angle_h
#import <Foundation/Foundation.h>


@class TSQuater;
@class TSVector;

@interface TSQuater : NSObject
@property(nonatomic,assign) double w;
@property(nonatomic,assign) double x;
@property(nonatomic,assign) double y;
@property(nonatomic,assign) double z;
-(TSQuater *) initWithWXYZ:(double) w x:(double)x y:(double)y z:(double)z;
-(TSQuater *) initWithQua:(TSQuater *)qua;
-(void) normalize;
-(void) conj_qua:(TSQuater *) qua;
-(void) qua_product:(TSQuater *) qua1 qua2:(TSQuater *) qua2;
@end

@interface TSVector : NSObject
@property(nonatomic,assign) double x;
@property(nonatomic,assign) double y;
@property(nonatomic,assign) double z;
-(void) qua_roration:(TSQuater*) qua;
-(void) normalize;
-(void) setQuaterByVector:(TSQuater*) qua v1:(TSVector*)v1 v2:(TSVector*)v2;
-(void) setQuaterByVector:(TSQuater*) qua v:(TSVector*)v theta:(double) theta;
-(void) crossprod:(TSVector*)v1 v2:(TSVector*)v2;
-(double) dotprod:(TSVector*)v1 v2:(TSVector*)v2;
@end

@interface TSEuler : NSObject
@property(nonatomic,assign) double x;
@property(nonatomic,assign) double y;
@property(nonatomic,assign) double z;
-(TSEuler *) initWithTSEuler:(TSEuler *) theta;
-(void) getZXYFromQua:(TSQuater*) qua;
@end

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

@interface TSMaxValue : NSObject
@property(nonatomic,assign) double value;
@property(nonatomic,assign) int index;
-(TSMaxValue *) initWithValueIndex:(double) v index:(int) index;
@end


typedef NS_ENUM(NSInteger, TSSensorPosition) {
    TSSensorAtTrunkChest,
    TSSensorAtFrontHead,
    TSSensorAtRightShoulder,
    TSSensorAtRightUpperArm,
    TSSensorAtRightForearm,
    TSSensorAtRightBackPalm,
    TSSensorAtLeftThigh,
    TSSensorAtRightThigh,
    TSSensorAtLeftShank,
    TSSensorAtRightShank,
};

@interface TSJointAngleCalculation : NSObject
@property(nonatomic,strong) NSMutableArray *trunk_chest_qua;
@property(nonatomic,strong) NSMutableArray *front_head_qua;
@property(nonatomic,strong) NSMutableArray *right_shoulder_qua;
@property(nonatomic,strong) NSMutableArray *right_upper_arm_qua;
@property(nonatomic,strong) NSMutableArray *right_forearm_qua;
@property(nonatomic,strong) NSMutableArray *right_back_palm_qua;
@property(nonatomic,strong) NSMutableArray *right_thigh_qua;
@property(nonatomic,strong) NSMutableArray *left_thigh_qua;
@property(nonatomic,strong) NSMutableArray *right_shank_qua;
@property(nonatomic,strong) NSMutableArray *left_shank_qua;
// static calibration
@property(nonatomic,strong) TSRotMatrix *calib_trunk_a_R_s;
@property(nonatomic,strong) TSRotMatrix *calib_shoulder_s_R_a;
@property(nonatomic,strong) TSRotMatrix *calib_upper_arm_s_R_a;
@property(nonatomic,strong) TSRotMatrix *calib_forearm_s_R_a;
@property(nonatomic,strong) TSRotMatrix *calib_rthigh_s_R_a;
@property(nonatomic,strong) TSRotMatrix *calib_lthigh_s_R_a;
@property(nonatomic,strong) TSRotMatrix *calib_rshank_s_R_a;
@property(nonatomic,strong) TSRotMatrix *calib_lshank_s_R_a;
@property(nonatomic,strong) TSRotMatrix *calib_trunk_a_R_s_t;

// joint angles
@property(nonatomic,strong) NSMutableArray *task_angles_trunk;
@property(nonatomic,strong) NSMutableArray *task_angles_st;
@property(nonatomic,strong) NSMutableArray *task_angles_ht;
@property(nonatomic,strong) NSMutableArray *task_angles_elbow;
@property(nonatomic,strong) NSMutableArray *task_angles_rhip;
@property(nonatomic,strong) NSMutableArray *task_angles_rknee;
@property(nonatomic,strong) NSMutableArray *task_angles_lhip;
@property(nonatomic,strong) NSMutableArray *task_angles_lknee;

-(TSJointAngleCalculation *) initQuaArray;
-(void) addSensorQuaData:(TSQuater *) qua sensor_pos:(TSSensorPosition) sensor_pos;
-(void) genCalibRotMatrix;
-(void) genJointAngles;
-(int) getGoodStrokesByAngleHT;
-(int) getStrokeNumberByTheshold:(NSMutableArray *) data type:(int) type dir:(int)dir threshold:(double) threshold max_array:(NSMutableArray *) max_array;
-(void) reportStepsForEachStroke:(NSMutableArray *) right_forearm_peak_array left_shank_peak_array:(NSMutableArray *) left_shank_peak_array right_shank_peak_array:(NSMutableArray *) right_shank_peak_array;
-(void) generateBVHFile:(NSString *) file_name;
-(void) generateBVHHierarchy:(NSString *) file_name str:(NSMutableString *) str data_count:(int) data_count upper_arm_length:(double) upper_arm_length wrist_length:(double) wrist_length trunk_length:(double) trunk_length hip_half_length:(double) hip_half_length thigh_length:(double) thigh_length shank_length:(double) shank_length shoulder_length:(double) shoulder_length scale_length:(double) scale_length;
@end

#endif
