//
//  JRYSideBar.m
//
//  Created by Justin Schottlaender on 8/14/13.
//  Copyright (c) 2013 Justin Schottlaender. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "JRYSideBar.h"
#import "JRYSideBarButtonCell.h"

#define DEFAULT_SIDEBAR_BUTTON_HEIGHT 60.0
#define DEFAULT_SIDEBAR_ANIMATION_DURATION 0.15

@implementation JRYSideBar

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		_layoutMode = JRYSideBarLayoutCenter;
        _direction = JRYSideBarDirectionLeft;
		_backgroundColor = [NSColor colorWithDeviceWhite:60.0/255.0 alpha:1.0];
		_animationDuration = DEFAULT_SIDEBAR_ANIMATION_DURATION;
		_animateSelection = NO;
		_matrix = [[NSMatrix alloc] initWithFrame:NSZeroRect];
		[_matrix setBackgroundColor:_backgroundColor];
		[_matrix setMode:NSRadioModeMatrix];
		[_matrix setAllowsEmptySelection:NO];
		
        // defaults
		[_matrix setCellClass:[JRYSideBarButtonCell class]];
		[self addSubview:_matrix];
		[self setButtonsHeight:DEFAULT_SIDEBAR_BUTTON_HEIGHT];
		[_matrix setDrawsBackground:YES];
		
		// Setup resize notification
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(viewResized:)
													 name:NSViewFrameDidChangeNotification
                                                   object:self];
		
	}
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)drawBackground:(NSRect)rect
{
	[_backgroundColor set];
	NSRectFill(rect);
    
	if (self.noiseAlpha > 0) {
        static CIImage *noisePattern = nil;
        if (noisePattern == nil) {
            CIFilter *randomGenerator = [CIFilter filterWithName:@"CIColorMonochrome"];
            [randomGenerator setValue:[[CIFilter filterWithName:@"CIRandomGenerator"] valueForKey:@"outputImage"]
                               forKey:@"inputImage"];
            [randomGenerator setDefaults];
            noisePattern = [randomGenerator valueForKey:@"outputImage"];
        }
        
        [noisePattern drawAtPoint:NSZeroPoint
                         fromRect:self.bounds
                        operation:NSCompositePlusLighter
                         fraction:self.noiseAlpha];
    }
}

- (void)drawRect:(NSRect)dirtyRect
{	
	[self drawBackground:dirtyRect];
}

- (void)selectButtonAtRow:(NSUInteger)row
{
	NSUInteger rowToSelect = row;
	if ([_matrix numberOfRows] < row)
		rowToSelect = 0;
    
	[_matrix setState:(NSInteger)NSOnState atRow:(NSInteger)rowToSelect column:(NSInteger)0];
	[self moveSelectionImage];
}

- (void)addButtonWithTitle:(NSString *)title
{
	NSCell *cell = [self addButton];
	[cell setTitle:title];
}

- (void)addButtonWithTitle:(NSString *)title image:(NSImage *)image
{
	NSCell *cell = [self addButton];
	[cell setTitle:title];
	[cell setImage:image];
}

- (void)addButtonWithTitle:(NSString *)title image:(NSImage *)image alternateImage:(NSImage *)alternateImage
{
	NSButtonCell *cell = [self addButton];
	[cell setTitle:title];
	[cell setImage:image];
	[cell setAlternateImage:alternateImage];
}

- (void)setTarget:(id)aTarget withSelector:(SEL)aSelector atIndex:(NSInteger)anIndex
{
    id cell = [_matrix cellAtRow:anIndex column:0];
    
    if ([cell isKindOfClass:[JRYSideBarButtonCell class]]) {
        JRYSideBarButtonCell *buttonCell = (JRYSideBarButtonCell *)cell;
        
        buttonCell.cellTarget = aTarget;
        buttonCell.cellAction = aSelector;
    }
}

- (void)setCellClass:(Class)class
{
	[_matrix setCellClass:class];
}

- (void)setLayoutMode:(JRYSideBarLayoutMode)mode
{
	_layoutMode = mode;
	[self resizeMatrix];
}

- (void)setButtonsHeight:(CGFloat)height
{
	_buttonsHeight = height;
	[_matrix setCellSize:NSMakeSize([self frame].size.width, height)];
	[_matrix setIntercellSpacing:NSMakeSize(0.0, 0.0)];
	[self resizeMatrix];
}

- (void)setSelectionImage:(NSImage*)img
{
	if (self.selectorImageView == nil) {
		NSRect r = [self frame];
        
        // for left sidebars
		NSRect imageRect = NSMakeRect(NSMaxX(r)-img.size.width, NSMinY(r), img.size.width, img.size.height);
        
        if (self.direction == JRYSideBarDirectionRight)
            // for right sidebars
            imageRect = NSMakeRect(NSMinX(r), NSMinY(r), img.size.width, img.size.height);
        
		self.selectorImageView = [[NSImageView alloc]initWithFrame:imageRect];
        [self.selectorImageView setImage:img];
        [self.selectorImageView setAutoresizingMask:NSViewNotSizable];
		
		[_matrix addSubview:self.selectorImageView positioned:NSWindowAbove relativeTo:nil];
	}
    
	[self.selectorImageView setImage:img];
	[self moveSelectionImage];
}

- (id)cellForItem:(NSInteger)index
{
	if (index < 0 || index > [_matrix numberOfRows])
		return nil;
    
	id cell = [_matrix cellAtRow:index column:0];
	return cell;
}

- (void)buttonClicked:(id)sender
{
	[self moveSelectionImage];
    
    NSInteger row = [_matrix selectedRow];
    id cell = [_matrix cellAtRow:row column:0];
    
    if ([cell isKindOfClass:[JRYSideBarButtonCell class]]) {
        JRYSideBarButtonCell *buttonCell = (JRYSideBarButtonCell *)cell;
        
        if (buttonCell.cellTarget && buttonCell.cellAction &&
            [buttonCell.cellTarget respondsToSelector:buttonCell.cellAction]) {
 
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [buttonCell.cellTarget performSelector:buttonCell.cellAction withObject:self];
#pragma clang diagnostic pop
            
            return;
        }
    }
    
    if (self.sidebarDelegate && [self.sidebarDelegate respondsToSelector:@selector(sideBar:didSelectItemAtIndex:)]) 
		[self.sidebarDelegate sideBar:self didSelectItemAtIndex:row];
}

- (void)selectNext
{
    NSInteger row = [_matrix selectedRow] + 1;
    if (row >= [_matrix.cells count])
        return;
    
    [_matrix selectCellAtRow:row column:0];
    [self buttonClicked:self];
}

- (void)selectPrev
{
    NSInteger row = [_matrix selectedRow] - 1;
    if (row <= 0)
        return;
    
    [_matrix selectCellAtRow:row column:0];
    [self buttonClicked:self];
}

- (NSInteger)selectedIndex
{
    return [_matrix selectedRow];
}

- (void)moveSelectionImage
{
	if (self.selectorImageView == nil)
		return;
    
	NSInteger row = [_matrix selectedRow];
	if (row == -1)
		return;
    
	NSRect rect = [_matrix cellFrameAtRow:(NSInteger)row column:(NSInteger)0];
	
	// move image view to the new position
	NSRect imgFrame = [self.selectorImageView frame];
	imgFrame.origin.y = rect.origin.y + NSHeight(rect)/2.0 - [[self.selectorImageView image] size].height/2.0;
    
    if (self.direction == JRYSideBarDirectionLeft)
        imgFrame.origin.x = rect.origin.x + NSWidth(rect)-[[self.selectorImageView image] size].width;
    else if (self.direction == JRYSideBarDirectionRight)
        imgFrame.origin.x = rect.origin.x - 1;
    
	if (!self.animateSelection)
		[self.selectorImageView setFrame:imgFrame];
	else {
		[[NSAnimationContext currentContext] setDuration:self.animationDuration];
		[[self.selectorImageView animator] setFrame:imgFrame];
	}
}

- (void)viewResized:(NSNotification *)notification
{
	[self resizeMatrix];
}

- (NSButtonCell*)addButton
{
	[_matrix addRow];
	NSButtonCell * cell = [_matrix cellAtRow:[_matrix numberOfRows]-1 column:0];
	[cell setButtonType:NSPushOnPushOffButton];
	[cell setTarget:self];
	[cell setAction:@selector(buttonClicked:)];
	[cell setFocusRingType:NSFocusRingTypeNone];
	
	[self resizeMatrix];
	return cell;
}

- (void)resizeMatrix
{
	NSInteger numRows = [_matrix numberOfRows];
	CGFloat matrixHeight = numRows * self.buttonsHeight;
	
	NSRect rect = [self frame];
	
	NSRect matrixRect = rect;
	matrixRect.origin.x = 0.0;
	matrixRect.size.width = NSWidth(rect);
	matrixRect.size.height = matrixHeight;
    
	if (self.layoutMode == JRYSideBarLayoutTop)
		matrixRect.origin.y = NSHeight(rect)-matrixHeight;
	else if (self.layoutMode == JRYSideBarLayoutCenter)
		matrixRect.origin.y = ((NSHeight(rect)-matrixHeight)/2.0);
	else if (self.layoutMode == JRYSideBarLayoutBottom)
		matrixRect.origin.y = 0.0;

	[_matrix setFrame:matrixRect];
	
	[self moveSelectionImage];
}

@end
