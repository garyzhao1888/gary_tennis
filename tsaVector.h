//
//  pdbVector.h
//  ts_tennis_0331
//
//  Created by Master on 3/30/15.
//  Copyright (c) 2015 Master. All rights reserved.
//

#ifndef ts_tennis_0331_pdbVector_h
#define ts_tennis_0331_pdbVector_h
@class TSQuater;

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

#endif
