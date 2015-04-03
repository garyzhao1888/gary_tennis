//
//  pdbVector.m
//  ts_tennis_0331
//
//  Created by Master on 3/30/15.
//  Copyright (c) 2015 Master. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tsaVector.h"
#import "tsaQuaternion.h"
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
