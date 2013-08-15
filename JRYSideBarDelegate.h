//
//  JRYSideBarDelegate.h
//
//  Created by Justin Schottlaender on 8/14/13.
//  Copyright (c) 2013 Justin Schottlaender. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JRYSideBar;

@protocol JRYSideBarDelegate <NSObject>

@optional

- (void)sideBar:(JRYSideBar *)sideBar didSelectItemAtIndex:(NSInteger)index;

@end
