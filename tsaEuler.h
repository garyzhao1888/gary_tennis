
//
//  pdbEuler.h
//  ts_tennis_0331
//
//  Created by Master on 3/30/15.
//  Copyright (c) 2015 Master. All rights reserved.
//

#ifndef ts_tennis_0331_pdbEuler_h
#define ts_tennis_0331_pdbEuler_h
@class TSQuater;
@interface TSEuler : NSObject
@property(nonatomic,assign) double x;
@property(nonatomic,assign) double y;
@property(nonatomic,assign) double z;
-(TSEuler *) initWithTSEuler:(TSEuler *) theta;
-(void) getZXYFromQua:(TSQuater*) qua;
@end

#endif
