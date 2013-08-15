//
//  JRYSideBarButtonCell.h
//
//  Created by Justin Schottlaender on 8/14/13.
//  Copyright (c) 2013 Justin Schottlaender. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JRYSideBarButtonCell : NSButtonCell

@property id cellTarget;
@property SEL cellAction;

- (void)setTextColor:(NSColor *)textColor;

@end
