//
//  JRYSideBar.h
//
//  Created by Justin Schottlaender on 8/14/13.
//  Copyright (c) 2013 Justin Schottlaender. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRYSideBarDelegate.h"

typedef enum JRYSideBarLayoutMode : NSInteger {
    JRYSideBarLayoutTop,
    JRYSideBarLayoutCenter,
    JRYSideBarLayoutBottom
} JRYSideBarLayoutMode;

typedef enum JRYSideBarDirectionType : NSInteger {
    JRYSideBarDirectionLeft,
    JRYSideBarDirectionRight
} JRYSideBarDirectionType;

@interface JRYSideBar : NSView

@property (nonatomic, strong) NSColor *backgroundColor;
@property (nonatomic, weak) id<JRYSideBarDelegate>sidebarDelegate;
@property (nonatomic, weak) Class cellClass;
@property (nonatomic) JRYSideBarLayoutMode layoutMode;
@property (nonatomic) JRYSideBarDirectionType direction;
@property (nonatomic) CGFloat buttonsHeight;
@property (nonatomic) NSMatrix *matrix;
@property BOOL animateSelection;
@property NSTimeInterval animationDuration;
@property CGFloat noiseAlpha;
@property (nonatomic, strong) NSImageView *selectorImageView;

- (void)setLayoutMode:(JRYSideBarLayoutMode)layoutMode;
- (void)addButtonWithTitle:(NSString *)title;
- (void)addButtonWithTitle:(NSString *)title image:(NSImage*)image;
- (void)addButtonWithTitle:(NSString *)title image:(NSImage*)image alternateImage:(NSImage*)alternateImage;
- (void)setTarget:(id)aTarget withSelector:(SEL)aSelector atIndex:(NSInteger)anIndex;
- (void)selectButtonAtRow:(NSUInteger)row;
- (void)selectNext;
- (void)selectPrev;
- (void)drawBackground:(NSRect)rect;
- (void)setSelectionImage:(NSImage *)image;
- (id)cellForItem:(NSInteger)index;
- (NSInteger)selectedIndex;

@end
