//
//  pdbQuaternion.h
//  ts_tennis_0331
//
//  Created by Master on 3/30/15.
//  Copyright (c) 2015 Master. All rights reserved.
//

#ifndef ts_tennis_0331_pdbQuaternion_h
#define ts_tennis_0331_pdbQuaternion_h
#import <Foundation/Foundation.h>
@interface TSQuater : NSObject
@property(nonatomic,assign) double w;
@property(nonatomic,assign) double x;
@property(nonatomic,assign) double y;
@property(nonatomic,assign) double z;
-(TSQuater *) initWithWXYZ:(double) w x:(double)x y:(double)y z:(double)z;
-(TSQuater *) initWithQua:(TSQuater *)qua;
-(void) initWithUnit;
-(void) normalize;
-(void) conj_qua:(TSQuater *) qua;
-(void) qua_product:(TSQuater *) qua1 qua2:(TSQuater *) qua2;
@end


#endif
