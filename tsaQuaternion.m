//
//  pdbQuaternion.m
//  ts_tennis_0331
//
//  Created by Master on 3/30/15.
//  Copyright (c) 2015 Master. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tsaQuaternion.h"
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
-(void) initWithUnit {
    self.w = 1;
    self.x = 0;
    self.y = 0;
    self.z = 0;
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

