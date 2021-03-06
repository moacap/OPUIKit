//
//  OPButton.m
//  OPUIKit
//
//  Created by Brandon Williams on 1/14/12.
//  Copyright (c) 2012 Opetopic. All rights reserved.
//

#import "OPButton.h"
#import "NSNumber+Opetopic.h"
#import "OPStyle.h"

@implementation OPButton

@synthesize drawingBlocksByControlState = _drawingBlocksByControlState;
@synthesize backgroundImageByControlState = _backgroundImageByControlState;

#pragma mark -
#pragma mark Object lifecycle
#pragma mark -

-(id) initWithFrame:(CGRect)frame {
    if (! (self = [super initWithFrame:frame]))
        return nil;
    
    self.drawingBlocksByControlState = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSMutableArray new], @(UIControlStateNormal), 
                                        [NSMutableArray new], @(UIControlStateHighlighted), 
                                        [NSMutableArray new], @(UIControlStateDisabled), 
                                        [NSMutableArray new], @(UIControlStateSelected), nil];
    
    // observe states so we can redraw the button when it changes
    [self addObserver:self forKeyPath:@"enabled" options:0 context:NULL];
    [self addObserver:self forKeyPath:@"selected" options:0 context:NULL];
    [self addObserver:self forKeyPath:@"highlighted" options:0 context:NULL];
    
    // apply styles
    [[[self class] styling] applyTo:self];
    
    return self;
}

-(void) dealloc {
    [self removeObserver:self forKeyPath:@"enabled"];
    [self removeObserver:self forKeyPath:@"selected"];
    [self removeObserver:self forKeyPath:@"highlighted"];
}

#pragma mark -
#pragma mark Helper methods
#pragma mark -

-(void) addDrawingBlock:(OPControlDrawingBlock)block forState:(UIControlState)state {
    
    if (state == UIControlStateNormal)
        [[self.drawingBlocksByControlState objectForKey:@(UIControlStateNormal)] addObject:[block copy]];
    
    if (state & UIControlStateHighlighted)
        [[self.drawingBlocksByControlState objectForKey:@(UIControlStateHighlighted)] addObject:[block copy]];
    
    if (state & UIControlStateDisabled)
        [[self.drawingBlocksByControlState objectForKey:@(UIControlStateDisabled)] addObject:[block copy]];
    
    if (state & UIControlStateSelected)
        [[self.drawingBlocksByControlState objectForKey:@(UIControlStateSelected)] addObject:[block copy]];
    
    [self setNeedsDisplay];
}

#pragma mark -
#pragma mark Drawing methods
#pragma mark -

-(void) drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    for (OPControlDrawingBlock block in [self.drawingBlocksByControlState objectForKey:@(UIControlStateNormal)])
        block(self, rect, c);
    
    for (NSNumber *drawState in self.drawingBlocksByControlState)
    {
        if ([drawState intValue] & self.state)
        {
            for (OPControlDrawingBlock block in [self.drawingBlocksByControlState objectForKey:drawState])
                block(self, rect, c);
        }
    }
}

#pragma mark -
#pragma mark Custom getters/setters
#pragma mark -

-(void) setDrawingBlocksByControlState:(NSMutableDictionary *)drawingBlocksByControlState {
    _drawingBlocksByControlState = [drawingBlocksByControlState mutableCopy];
    
    // make sure there is an array of drawing blocks for each state
    if (! [self.drawingBlocksByControlState objectForKey:@(UIControlStateNormal)])
        [self.drawingBlocksByControlState setObject:[NSMutableArray new] forKey:@(UIControlStateNormal)];
    if (! [self.drawingBlocksByControlState objectForKey:@(UIControlStateHighlighted)])
        [self.drawingBlocksByControlState setObject:[NSMutableArray new] forKey:@(UIControlStateHighlighted)];
    if (! [self.drawingBlocksByControlState objectForKey:@(UIControlStateSelected)])
        [self.drawingBlocksByControlState setObject:[NSMutableArray new] forKey:@(UIControlStateSelected)];
    if (! [self.drawingBlocksByControlState objectForKey:@(UIControlStateDisabled)])
        [self.drawingBlocksByControlState setObject:[NSMutableArray new] forKey:@(UIControlStateDisabled)];
    
    [self setNeedsDisplay];
}

-(void) setBackgroundImageByControlState:(NSMutableDictionary *)backgroundImageByControlState {
    _backgroundImageByControlState = [backgroundImageByControlState mutableCopy];
    
    [self.backgroundImageByControlState enumerateKeysAndObjectsUsingBlock:^(NSNumber *state, UIImage *image, BOOL *stop) {
        [self setBackgroundImage:image forState:[state intValue]];
    }];
    
    [self setNeedsDisplay];
}

#pragma mark -
#pragma mark KVO methods
#pragma mark -

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    // confirm that the object that changed was this button
    if (object == self)
        [self setNeedsDisplay];
}

@end
