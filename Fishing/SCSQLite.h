//
//  SCSQLite.h
//
//  Created by John Nik on 21/6/17.
//  Copyright (c) 2017 johnik703. All rights reserved.
//  Kdl%120681

#import <Foundation/Foundation.h>
#import "sqlite3.h"


@interface SCSQLite : NSObject {
    sqlite3 *db;
}

@property (copy, nonatomic) NSString *database;


+ (void)initWithDatabase:(NSString *)database;
+ (BOOL)executeSQL:(NSString *)sql, ...;
+ (NSArray *)selectRowSQL:(NSString *)sql;
//NS_FORMAT_FUNCTION(1,2);
+ (NSString *)getDatabaseDump;

@end
