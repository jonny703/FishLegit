//
//  SQLiteHelper.m
//  Fishing
//
//  Created by John Nik on 3/4/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

#import "SQLiteHelper.h"
#import "SCSQLite.h"

static NSString * defaultDB = @"fishy.sqlite3";

@implementation SQLiteHelper

+ (BOOL)insertInTable:(NSString *)table params:(NSDictionary *)dic {
    return [self insertInDatabase:defaultDB table:table params:dic];
}

+ (BOOL)updateInTable:(NSString *)table params:(NSDictionary *)dic where:(NSDictionary *)whereDic {
    return [self updateInDatabase:defaultDB table:table params:dic where:whereDic];
}

+ (BOOL)deleteInTable:(NSString *)table where:(NSDictionary *)whereDic {
    return [self deleteInDatabase:defaultDB table:table where:whereDic];
}

#pragma mark - CRUD Operations with Database

+ (BOOL)insertInDatabase:(NSString *)database table:(NSString *)table params:(NSDictionary *)dic {
    [SCSQLite initWithDatabase:database];
    NSString *head = [NSString stringWithFormat:@"INSERT INTO %@", table];
    
    NSMutableArray *keyArr = [[NSMutableArray alloc] init];
    NSMutableArray *valueArr = [[NSMutableArray alloc] init];
    for (NSString * key in dic.allKeys) {
        [keyArr addObject:key];
        [valueArr addObject:[NSString stringWithFormat:@"'%@'", dic[key]]];
    }
    NSString *key = [keyArr componentsJoinedByString:@","];
    NSString *value = [valueArr componentsJoinedByString:@","];
    NSString *sql = [NSString stringWithFormat:@"%@ (%@) VALUES(%@)", head, key, value];
    BOOL result = [SCSQLite executeSQL:sql];
    
    return result;
}

+ (BOOL)updateInDatabase:(NSString *)database table:(NSString *)table params:(NSDictionary *)dic where:(NSDictionary *)whereDic {
    [SCSQLite initWithDatabase:database];
    NSString *head = [NSString stringWithFormat:@"UPDATE %@ SET", table];
    
    // Value
    NSMutableArray *valueArr = [[NSMutableArray alloc] init];
    for (NSString * key in dic.allKeys) {
        [valueArr addObject:[NSString stringWithFormat:@"%@ = '%@'", key, dic[key]]];
    }
    NSString *value = [valueArr componentsJoinedByString:@","];
    
    // Where Caluse
    NSString *whereStr = [self whereCaluseString:whereDic];
    
    NSString *sql = [NSString stringWithFormat:@"%@ %@ WHERE %@", head, value, whereStr];
    NSLog(@"update sql---%@", sql);
    BOOL result = [SCSQLite executeSQL:sql];
    
    return result;
}

+ (BOOL)deleteInDatabase:(NSString *)database table:(NSString *)table where:(NSDictionary *)whereDic {
    [SCSQLite initWithDatabase:database];
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@", table, [self whereCaluseString:whereDic]];
    BOOL result = [SCSQLite executeSQL: sql];
    
    return result;
}

#pragma mark - Private Methods

+ (NSString *)whereCaluseString:(NSDictionary *)dic {
    NSMutableArray *whereArr = [[NSMutableArray alloc] init];
    
    for (NSString * key in dic.allKeys) {
        [whereArr addObject:[NSString stringWithFormat:@"%@ = '%@'", key, dic[key]]];
    }
    NSString *whereStr = [whereArr componentsJoinedByString:@" AND "];
    
    return whereStr;
}

@end
