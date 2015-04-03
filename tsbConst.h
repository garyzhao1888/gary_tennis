//
//  pdbConst.h
//  ts_tennis_0331
//
//  Created by Master on 3/30/15.
//  Copyright (c) 2015 Master. All rights reserved.
//

#ifndef ts_tennis_0331_pdbConst_h
#define ts_tennis_0331_pdbConst_h
static const int MAX_DATA_NUMBER = 100000;
static const int MAX_STROKE_NUMBER = 100;
static const double PI = M_PI;
static const int SHOULDER_TRUNK_ANGLE_X = 100;
static const int SHOULDER_TRUNK_ANGLE_Y = 150;
static const int SHOULDER_TRUNK_ANGLE_Z = 70;
static const int STROKE_MIN_TIME = 50;
static const double STROKE_MIN_ACCEL_Y = 8;
static const double SHANK_STEP_MIN_ACCEL_Y = 1.2;
// static const int STATIC_INDEX = 5;

// some const for sensor, should be got from sensor collection codes.
static const int GYROFULLSCALE = 2000;
static const double TIMEINTEVAL = 0.01;

// some const value for user, should also be got from input
static const double ARMLENGTH = 1.5;

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

typedef NS_ENUM(NSInteger, TSJointPoint) {
    TSJointPointAtTrunk,
    TSJointPointAtRightShoulderToTrunk,
    TSJointPointAtRightUpperArmToTrunk,
    TSJointPointAtRightElbow,
    TSJointPointAtRightHip,
    TSJointPointAtLeftHip,
    TSJointPointAtRightKnee,
    TSJointPointAtLeftKnee,
};

typedef NS_ENUM(NSInteger, TSJointAngleCalculateType) {
    TSJointAngleReadData,
    TSJointAngleCalibration,
    TSJointAngleUpdateData,
    TSJointAngleGenerateBVH,
    TSJointAngleStrokeParam,
    TSJointangleNone,
};

typedef NS_ENUM(NSUInteger, TSTStrokeType) {
    TSTStrokeTypeUnknown,
    TSTStrokeTypeForehand,
    TSTStrokeTypeBackhand,
    TSTStrokeTypeVolley,
    TSTStrokeTypeOverhead,
    TSTStrokeTypeServe,
    TSTStrokeTypeOther
};
const NSString *kTSTStrokeDataOtherType;

typedef NS_ENUM(NSUInteger, TSTStrokeSubtype) {
    TSTStrokeSubtypeUnknown,
    TSTStrokeSubtypeTopSpin,
    TSTStrokeSubtypeFlat,
    TSTStrokeSubtypeSlice,
    TSTStrokeSubtypeKick,
    TSTStrokeSubtypeForehandVolley,
    TSTStrokeSubtypeBackhandVolley,
    TSTStrokeSubtypeOther,
};

#endif
