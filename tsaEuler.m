//
//  pdbEuler.m
//  ts_tennis_0331
//
//  Created by Master on 3/30/15.
//  Copyright (c) 2015 Master. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tsaEuler.h"
#import "tsaQuaternion.h"

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
    if ((self.x < -M_PI/2) || (self.x > M_PI/2)) {
        
    }
    if (self.x < -M_PI/2) {
        self.x = -M_PI - self.x;
    } else if (self.x > M_PI/2) {
        self.x = M_PI - self.x;
    }
    double sy = -r31/cos(self.x);
    double cy = r33/cos(self.x);
    double sz = -r12/cos(self.x);
    double cz = r22/cos(self.x);
    self.y = atan2(sy,cy);
    self.z = atan2(sz,cz);
}
@end
