//
//  OPView.m
//  OPUIKit
//
//  Created by Brandon Williams on 1/2/12.
//  Copyright (c) 2012 Opetopic. All rights reserved.
//

#import "OPView.h"
#import "OPStyle.h"
#import "OPGradient.h"
#import "UIColor+Opetopic.h"
#import "NSDictionary+Opetopic.h"

@interface OPView (/**/)
-(void) __init;
@end

@implementation OPView

@synthesize drawingBlocks = _drawingBlocks;

-(id) init {
    if (! (self = [super init]))
        return nil;
    [self __init];
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
    if (! (self = [super initWithCoder:aDecoder]))
        return nil;
    [self __init];
    return self;
}

-(id) initWithFrame:(CGRect)frame {
    if (! (self = [super initWithFrame:frame]))
        return nil;
    [self __init];
    return self;
}

-(void) __init {
    self.drawingBlocks = [NSMutableArray new];
    [self addObserver:self forKeyPath:@"drawingBlocks" options:0 context:NULL];
    [[[self class] styling] applyTo:self];
}

-(void) drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    for (UIViewDrawingBlock block in self.drawingBlocks)
        block(self, rect, c);
}

-(void) setDrawingBlocks:(NSMutableArray *)drawingBlocks {
    _drawingBlocks = drawingBlocks;
    [self setNeedsDisplay];
}

-(void) insertObject:(UIViewDrawingBlock)block inDrawingBlocksAtIndex:(NSUInteger)index {
    [_drawingBlocks insertObject:block atIndex:index];
    [self setNeedsDisplay];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self setNeedsDisplay];
}

NSString * const OPViewDrawingBaseColorKey = @"OPViewDrawingBaseColorKey";
NSString * const OPViewDrawingBaseGradientKey = @"OPViewDrawingBaseGradientKey";
NSString * const OPViewDrawingGradientAmountKey = @"OPViewDrawingGradientAmountKey";
NSString * const OPViewDrawingInvertedKey = @"OPViewDrawingInvertedKey";
NSString * const OPViewDrawingBorderColorKey = @"OPViewDrawingBorderColorKey";
NSString * const OPViewDrawingCornerRadiusKey = @"OPViewDrawingCornerRadiusKey";
NSString * const OPViewDrawingBevelKey = @"OPViewDrawingBevelKey";
NSString * const OPViewDrawingBevelInnerColorKey = @"OPViewDrawingBevelInnerColorKey";
NSString * const OPViewDrawingBevelOuterColorKey = @"OPViewDrawingBevelOuterColorKey";
NSString * const OPViewDrawingBevelBorderColorKey = @"OPViewDrawingBevelBorderColorKey";

+(UIViewDrawingBlock) roundedRectDrawingBlocksWithOptions:(NSDictionary*)options {
    
    // grab values from the options dictionary
    UIColor *baseColor          = [options objectForKey:OPViewDrawingBaseColorKey];
    OPGradient *baseGradient    = [options objectForKey:OPViewDrawingBaseGradientKey];
    CGFloat gradientAmount      = [[options numberForKey:OPViewDrawingGradientAmountKey] floatValue];
    BOOL inverted               = [[options numberForKey:OPViewDrawingInvertedKey] boolValue];
    UIColor *borderColor        = [options objectForKey:OPViewDrawingBorderColorKey];
    CGFloat radius              = [[options numberForKey:OPViewDrawingCornerRadiusKey] floatValue];
    BOOL bevel                  = [[options numberForKey:OPViewDrawingBevelKey] boolValue];
    UIColor *bevelInnerColor    = [options objectForKey:OPViewDrawingBevelInnerColorKey];
    UIColor *bevelOuterColor    = [options objectForKey:OPViewDrawingBevelOuterColorKey];
    UIColor *bevelBorderColor   = [options objectForKey:OPViewDrawingBevelBorderColorKey];
    
    // create a baseGradient from the baseColor if no gradient is provided
    if (! baseGradient && ! inverted)
        baseGradient = [OPGradient gradientWithColors:[NSArray arrayWithObjects:[baseColor lighten:gradientAmount], [baseColor darken:gradientAmount], nil]];
    else if (! baseGradient)
        baseGradient = [OPGradient gradientWithColors:[NSArray arrayWithObjects:[baseColor darken:gradientAmount], [baseColor lighten:gradientAmount], nil]];
    
    // create the drawing block
    return [^(UIView *v, CGRect r, CGContextRef c){
        
        CGRect fullRect = CGRectMake(0.0f, 0.0f, r.size.width, r.size.height-1.0f);
        CGRect insetRect = CGRectInset(fullRect, 1.0f, 1.0f);
        
        if (bevel) {
            [bevelOuterColor set];
            [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0.0f, r.size.height-radius*2.0f, r.size.width, radius*2.0f) cornerRadius:radius] fill];
        }
        
        UIBezierPath *fullPath = [UIBezierPath bezierPathWithRoundedRect:fullRect cornerRadius:radius];
        UIBezierPath *insetPath = [UIBezierPath bezierPathWithRoundedRect:insetRect cornerRadius:radius-1.0f];
        
        [borderColor set];
        [fullPath fill];
        
        [insetPath addClip];
        [baseGradient fillRectLinearly:insetRect];
        
        if (bevel)
        {
            // and a light border
            [bevelBorderColor setStroke];
            [[UIBezierPath bezierPathWithRoundedRect:CGRectInset(insetRect, 0.5f, 0.5f) cornerRadius:radius-1.0f] stroke];
            
            CGContextSaveGState(c);
            {
                UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:insetRect cornerRadius:radius-1.0f];
                CGContextSetFillColorWithColor(c, bevelInnerColor.CGColor);
                CGContextClipToRect(c, CGRectMake(0.0f, 0.0f, r.size.width, radius));
                CGContextAddPath(c, path.CGPath);
                CGContextTranslateCTM(c, 0.0f, 1.0f);
                CGContextAddPath(c, path.CGPath);
                CGContextEOFillPath(c);
            }
            CGContextRestoreGState(c);
        }
        
    } copy];
}

@end
