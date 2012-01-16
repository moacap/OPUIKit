//
//  OPStyle.h
//  OPUIKit
//
//  Created by Brandon Williams on 1/16/12.
//  Copyright (c) 2012 Opetopic. All rights reserved.
//

#import <Foundation/Foundation.h>

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

/** Ways of customizing titles (i.e. title views for navigiation items on controllers).
 */
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *subtitleFont;
@property (nonatomic, strong) UIColor *titleTextColor;
@property (nonatomic, strong) UIColor *titleShadowColor;
@property (nonatomic, assign) CGSize titleShadowOffset;
@property (nonatomic, strong) NSString *defaultTitle;
@property (nonatomic, strong) UIImage *defaultTitleImage;

@end

@interface OPStyle : NSObject <OPStyleProtocol>

/**
 Apply this style object's properties to a target.
 */
-(void) applyTo:(id)target;
@end

@interface NSObject (OPStyle)

/**
 Returns the style object for this class.
 */
+(OPStyle*) op_style;

/**
 Returns the style object for this object's class.
 */
-(OPStyle*) op_style;

@end