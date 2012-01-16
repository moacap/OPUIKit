//
//  OPStyle.m
//  OPUIKit
//
//  Created by Brandon Williams on 1/16/12.
//  Copyright (c) 2012 Opetopic. All rights reserved.
//

#import "OPStyle.h"
#import "NSObject+Opetopic.h"
#import "RTProtocol.h"
#import "RTMethod.h"
#import "MARTNSObject.h"

#pragma mark -
#pragma mark Private OPStyle interface
#pragma mark -

@interface OPStyle (/**/)
@property (nonatomic, assign) Class styledClass;
@property (nonatomic, strong) NSMutableSet *touchedMethods;
-(id) initForClass:(Class)styledClass;
@end

#pragma mark -
#pragma mark OPStyleProxy
#pragma mark -

@interface OPStyleProxy : NSProxy
@property (nonatomic, strong) OPStyle *style;
@end

@implementation OPStyleProxy

@synthesize style = _style;

-(id) initWithStyle:(OPStyle*)style {
    _style = style;
    return self;
}

-(void) forwardInvocation:(NSInvocation *)invocation {
    
    // forward everything to the style, but keep track of which properties were edited
    [self.style.touchedMethods addObject:NSStringFromSelector(invocation.selector)];
    [invocation invokeWithTarget:self.style];
}

-(NSMethodSignature*) methodSignatureForSelector:(SEL)sel {
    return [self.style methodSignatureForSelector:sel];
}

@end

#pragma mark -
#pragma mark OPStyle implementation
#pragma mark -

@implementation OPStyle

@synthesize styledClass = _styledClass;
@synthesize touchedMethods = _touchedMethods;

@synthesize backgroundImage = _backgroundImage;
@synthesize backgroundColor = _backgroundColor;
@synthesize glossAmount = _glossAmount;
@synthesize glossOffset = _glossOffset;
@synthesize gradientAmount = _gradientAmount;
@synthesize shadowHeight = _shadowHeight;
@synthesize shadowColors = _shadowColors;
@synthesize titleFont = _titleFont;
@synthesize subtitleFont = _subtitleFont;
@synthesize titleTextColor = _titleTextColor;
@synthesize titleShadowColor = _titleShadowColor;
@synthesize titleShadowOffset = _titleShadowOffset;
@synthesize defaultTitle = _defaultTitle;
@synthesize defaultTitleImage = _defaultTitleImage;

-(id) initForClass:(Class)styledClass {
    if (! (self = [self init]))
        return nil;
    _styledClass = styledClass;
    return self;
}

-(id) init {
    if (! (self = [super init]))
        return nil;
    _touchedMethods = [NSMutableSet new];
    return self;
}

-(void) applyTo:(id)target {
    
    // first apply any stylings from the superclass so that styles inherit
    if ([self.styledClass superclass])
        [[[self.styledClass superclass] op_style] applyTo:target];
    
    // loop through the methods in our protocol so we can apply the properties to the object passed in
    RTProtocol *protocol = [RTProtocol protocolWithObjCProtocol:@protocol(OPStyleProtocol)];
    for (RTMethod *method in [protocol methodsRequired:NO instance:YES])
    {
        // only look at setter methods
        if ([method.selectorName hasPrefix:@"set"] && [target respondsToSelector:method.selector])
        {
            // find the corresponding getter method
            NSString *selector = [method.selectorName substringFromIndex:3];
            selector = [selector stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[selector substringToIndex:1] lowercaseString]];
            selector = [selector substringToIndex:[selector length]-1];
            SEL getterSelector = NSSelectorFromString(selector);
            
            // get the value stored in this class so that we can send it to the target
            void *value = NULL;
            [self rt_returnValue:&value sendSelector:getterSelector];
            
            // send the setter method to the target (but only if this property has been touched while styling)
            if ([self.touchedMethods containsObject:method.selectorName])
                [target rt_returnValue:NULL sendSelector:method.selector, RTARG(value)];
        }
    }
}

-(NSString*) description {
    return [NSString stringWithFormat:@"<%@: %p> for %@", NSStringFromClass([self class]), self, NSStringFromClass(self.styledClass)];
}

@end


/**
 Internal mapping of classes to OPStyle instances.
 */
static NSMutableDictionary *OPStylesByClass;

@implementation NSObject (OPStyle)

+(OPStyle*) styling {
    
    // lazily create the dictionary that maps classes to style objects
    if (! OPStylesByClass)
        OPStylesByClass = [NSMutableDictionary new];
    
    // lazily create the style object for this class
    NSString *classString = NSStringFromClass([self class]);
    if (! [OPStylesByClass objectForKey:classString])
    {
        OPStyle *style = [[OPStyle alloc] initForClass:[self class]];
        OPStyleProxy *styleProxy = [[OPStyleProxy alloc] initWithStyle:style];
        [OPStylesByClass setObject:styleProxy forKey:classString];
    }
    
    return [OPStylesByClass objectForKey:classString];
}

-(OPStyle*) styling {
    return [[self class] op_style];
}

@end
