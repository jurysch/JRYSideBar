//
//  JRYSideBarButtonCell.m
//
//  Created by Justin Schottlaender on 8/14/13.
//  Copyright (c) 2013 Justin Schottlaender. All rights reserved.
//

#import "JRYSideBarButtonCell.h"

@implementation JRYSideBarButtonCell

- (void)setTextColor:(NSColor *)textColor
{
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc]
											initWithAttributedString:[self attributedTitle]];
    
    NSUInteger len = [attrTitle length];
    NSRange range = NSMakeRange(0, len);
    
    [attrTitle addAttribute:NSForegroundColorAttributeName
                      value:textColor
                      range:range];
    
    [attrTitle fixAttributesInRange:range];
    [self setAttributedTitle:attrTitle];
}

- (id)init
{
	self = [super init];
	if (self) {
		[self setTextColor:[NSColor whiteColor]];
		[self setImagePosition:NSImageAbove];
		[self setFont:[NSFont fontWithName:@"Lucida Grande" size:11]];
        
        self.cellTarget = nil;
        self.cellAction = nil;
	}
	return self;
}

- (void)drawWithFrame:(NSRect)frame inView:(NSView *)view
{	
	NSColor *cellColor = nil;
	if ([self state] == NSOnState)
		cellColor = [NSColor colorWithDeviceWhite:54.0/255.0 alpha:1.0];
	else
		cellColor = [NSColor colorWithDeviceWhite:65.0/255.0 alpha:1.0];
	
	[cellColor setFill];
	NSRectFill(frame);
	[self drawBezelWithFrame:frame inView:view];
	
	// some hard-coded test positions
	NSRect rectTitle = NSMakeRect(frame.origin.x, frame.origin.y+frame.size.height-23, frame.size.width, 20);
	NSRect rectImage = NSMakeRect(frame.origin.x, frame.origin.y+5, frame.size.width, frame.size.height - 25);
	
	NSImage *image = nil;
	
	if ([self state] == NSOnState) {
		[self setTextColor:[NSColor whiteColor]];
		image = [self image];
	}
	else {
		image = [self alternateImage] != nil ? [self alternateImage] : [self image];
		[self setTextColor:[NSColor lightGrayColor]];
	}
	
	[super drawImage:image withFrame:rectImage inView:view];
	[super drawTitle:(NSAttributedString *)[self attributedTitle] withFrame:(NSRect)rectTitle inView:(NSView *)view];
}

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)view
{
	NSColor *cellColor = nil;
	if ([self state] == NSOnState)
		cellColor = [NSColor colorWithDeviceWhite:54.0/255.0 alpha:1.0];
	else
		cellColor = [NSColor colorWithDeviceWhite:65.0/255.0 alpha:1.0];
	
	[cellColor setFill];
	NSRectFill(frame);
	
	// emboss
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSetRGBFillColor(ctx, 37.0/255.0, 37.0/255.0, 37.0/255.0, 1.0);
	CGContextFillRect(ctx, CGRectMake(0.5, NSMaxY(frame)-2, frame.size.width-1, 1));
	CGContextSetRGBFillColor(ctx, 77.0/255.0, 77.0/255.0, 77.0/255.0, 1.0);
	CGContextFillRect(ctx, CGRectMake(0.5, NSMaxY(frame)-1, frame.size.width-1, 1));
	[[NSGraphicsContext currentContext] setShouldAntialias:YES];
	
	if ([self state] == NSOnState) {
		// upper shadow
		NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:(42.0/255.0) alpha:1.0]
															 endingColor:[NSColor colorWithDeviceWhite:(56.0/255.0) alpha:1.0]];
        
		NSRect rectGradient = NSMakeRect(0-0.5, NSMinY(frame)-1-0.5, NSWidth(frame)-1, 4.0);
		NSBezierPath *path = [NSBezierPath bezierPathWithRect:rectGradient];
		[gradient drawInBezierPath:path angle:90];
	}
	
	// inset in the right
	CGContextSetRGBFillColor(ctx, 53.0/255.0, 53.0/255.0, 53.0/255.0, 0.8);
	CGContextFillRect(ctx, CGRectMake(NSMaxX(frame)-2, NSMinY(frame), 1.0, frame.size.height));
	CGContextSetRGBFillColor(ctx, 18.0/255.0, 18.0/255.0, 18.0/255.0, 1.0);
	CGContextFillRect(ctx, CGRectMake(NSMaxX(frame)-1, NSMinY(frame), 1.0, frame.size.height));
}

@end
