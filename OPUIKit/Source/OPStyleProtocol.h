//
//  OPStyleProtocol.h
//  OPUIKit
//
//  Created by Brandon Williams on 1/16/12.
//  Copyright (c) 2012 Opetopic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPBlockDefinitions.h"

@protocol OPStyleProtocol <NSObject>
@optional

/**
 Ways of customizing background images/colors if supported.
 */
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIImage *backgroundImage;

/**
 Ways of customizing background effects if supported.
 */
@property (nonatomic, assign) CGFloat glossAmount;      // % alpha to apply to the top half of the tab bar for the gloss effect
@property (nonatomic, assign) CGFloat glossOffset;      // how many pixels from the center to offset the gloss
@property (nonatomic, assign) CGFloat gradientAmount;   // a number between 0 and 1 that determines how much to lighten/darken the background color for the gradient

/**
 Ways of customizing drop shadows if supported.
 */
@property (nonatomic, assign) CGFloat shadowHeight;
@property (nonatomic, strong) NSArray *shadowColors;

/** 
 Ways of customizing titles (i.e. title views for navigiation items on controllers).
 */
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *subtitleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *titleShadowColor;
@property (nonatomic, assign) CGFloat titleShadowOffset;
@property (nonatomic, strong) NSString *defaultTitle;
@property (nonatomic, strong) NSString *defaultSubtitle;
@property (nonatomic, strong) UIImage *defaultTitleImage;

/**
 Styles specific to navigation bars.
 */
@property (nonatomic, assign) NSInteger translucent;
@property (nonatomic, copy) UIViewDrawingBlock drawingBlock;

/**
 Styles specific to OPView instances.
 */
@property (nonatomic, strong) NSArray *drawingBlocks;

/**
 Determines if a swipe gesture pops the current view controller from the stack. Of course this is
 only application to instances of OPNavigationController. We gotta use an NSInteger for this
 datatype because MAObjCRuntime doesn't seem to handle BOOL types.
 */
@property (nonatomic, assign) NSInteger allowSwipeToPop;

@end