//
//  OPStyle.m
//  OPUIKit
//
//  Created by Brandon Williams on 1/16/12.
//  Copyright (c) 2012 Opetopic. All rights reserved.
//

#import "OPStyle.h"
#import "RTProtocol.h"
#import "RTMethod.h"

#pragma mark -
#pragma mark OPStyleProxy
#pragma mark -

@interface OPStyleProxy : NSProxy
@property (nonatomic, strong) OPStyle *style;
@end

@implementation OPStyleProxy

-(id) initWithStyle:(OPStyle*)style {
    _style = style;
    
    return self;
}

-(void) forwardInvocation:(NSInvocation *)invocation {
    
    // forward everything to the style, but keep track of which properties were edited
    [self.style.editedProperties addObject:NSStringFromSelector(invocation.selector)];
    [invocation invokeWithTarget:self.style];
}

-(NSMethodSignature*) methodSignatureForSelector:(SEL)sel {
    return [self.style methodSignatureForSelector:sel];
}

@end

#pragma mark -
#pragma mark Private OPStyle interface
#pragma mark -

@interface OPStyle (/**/)
@property (nonatomic, assign) Class styledClass;
@property (nonatomic, strong, readwrite) NSMutableSet *editedProperties;
@property (nonatomic, strong) NSMutableDictionary *keyPathValuePairs;
-(id) initForClass:(Class)styledClass;
@end

#pragma mark -
#pragma mark OPStyle implementation
#pragma mark -

@implementation OPStyle

@synthesize styledClass = _styledClass;
@synthesize editedProperties = _editedProperties;
@synthesize keyPathValuePairs = _keyPathValuePairs;

@synthesize backgroundColor = _backgroundColor;
@synthesize backgroundImage = _backgroundImage;
@synthesize glossAmount = _glossAmount;
@synthesize glossOffset = _glossOffset;
@synthesize gradientAmount = _gradientAmount;
@synthesize shadowHeight = _shadowHeight;
@synthesize shadowColors = _shadowColors;
@synthesize titleFont = _titleFont;
@synthesize subtitleFont = _subtitleFont;
@synthesize titleColor = _titleColor;
@synthesize titleShadowColor = _titleShadowColor;
@synthesize titleShadowOffset = _titleShadowOffset;
@synthesize defaultTitle = _defaultTitle;
@synthesize defaultSubtitle = _defaultSubtitle;
@synthesize defaultTitleImage = _defaultTitleImage;
@synthesize navigationBarDrawingBlock = _navigationBarDrawingBlock;
@synthesize drawingBlocks = _drawingBlocks;
@synthesize drawingBlocksByControlState = _drawingBlocksByControlState;
@synthesize allowSwipeToPop = _allowSwipeToPop;

-(id) initForClass:(Class)styledClass {
    if (! (self = [self init]))
        return nil;
    _styledClass = styledClass;
    return self;
}

-(id) init {
    if (! (self = [super init]))
        return nil;
    _editedProperties = [NSMutableSet new];
    _keyPathValuePairs = [NSMutableDictionary new];
    return self;
}

-(void) applyTo:(id)target {
    
    // first apply any stylings from the superclass so that styles inherit
    if ([self.styledClass superclass])
        [[[self.styledClass superclass] styling] applyTo:target];
    
    // loop through the methods in our protocol so we can apply the properties to the object passed in
    RTProtocol *protocol = [RTProtocol protocolWithObjCProtocol:@protocol(OPStyleProtocol)];
    for (RTMethod *method in [protocol methodsRequired:NO instance:YES])
    {
        // only look at setter methods
        if ([method.selectorName hasPrefix:@"set"] && [target respondsToSelector:method.selector])
        {
            // find the corresponding getter selector name
            NSString *getter = [method.selectorName substringFromIndex:3];
            getter = [getter stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[getter substringToIndex:1] lowercaseString]];
            getter = [getter substringToIndex:[getter length]-1];
            
            // transfer the value from the style to the target (but only if it has been edited)
            if ([self.editedProperties containsObject:method.selectorName]) {
                id value = [self valueForKey:getter];
                [target setValue:value forKeyPath:getter];
            }
        }
    }
    
    // apply stylings that were stored in our key path value dictionary
    [self.keyPathValuePairs enumerateKeysAndObjectsUsingBlock:^(id keyPath, id value, BOOL *stop) {
        [target setValue:value forKeyPath:keyPath];
    }];
}

-(void) setValue:(id)value forKeyPath:(NSString *)keyPath {
    if (!value)
        [self.keyPathValuePairs removeObjectForKey:keyPath];
    else
        [self.keyPathValuePairs setObject:value forKey:keyPath];
}

-(id) valueForKeyPath:(NSString *)keyPath {
    return [self.keyPathValuePairs objectForKey:keyPath];
}

-(NSString*) description {
    return [NSString stringWithFormat:@"<%@: %p> for %@", NSStringFromClass([self class]), self, NSStringFromClass(self.styledClass)];
}

@end


/**
 Internal mapping of classes to OPStyle instances.
 */
static NSMutableDictionary *OPStyleByClass;

@implementation NSObject (OPStyle)

+(OPStyle*) styling {
    
    // lazily create the dictionary that maps classes to style objects
    if (! OPStyleByClass)
        OPStyleByClass = [NSMutableDictionary new];
    
    // lazily create the style object for this class (well, secretly the style proxy... shhh)
    NSString *classString = NSStringFromClass([self class]);
    if (! [OPStyleByClass objectForKey:classString])
    {
        OPStyle *style = [[OPStyle alloc] initForClass:[self class]];
        OPStyleProxy *styleProxy = [[OPStyleProxy alloc] initWithStyle:style];
        [OPStyleByClass setObject:styleProxy forKey:classString];
    }
    
    return [OPStyleByClass objectForKey:classString];
}

-(OPStyle*) styling {
    return [[self class] styling];
}

@end
