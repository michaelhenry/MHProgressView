//
//  MHProgressView.m
//
// Copyright (c) 2013 Michael Henry Pantaleon (http://www.iamkel.net). All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MHProgressView.h"
#import <QuartzCore/QuartzCore.h>
#define CIRCLE_RADIUS 40.0f
#define LINEWIDTH 10.0f
@interface MHProgressLayer : CALayer{
    CGFloat _ringRadius;
    CATextLayer * _percentageLabel;
}
@property (nonatomic) CGFloat progress;
@property (nonatomic,assign) BOOL reset;
@end

@implementation MHProgressLayer
@dynamic progress;
@synthesize reset;

+ (BOOL)needsDisplayForKey:(NSString *)key {
	return [key isEqualToString:@"progress"] || [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)context {
    CGRect rect = self.frame;
    CGFloat angleForPercentage = MIN(self.progress,1) * 360;
    CGFloat xOrigin = rect.size.width/2 ;
    CGFloat yOrigin = rect.size.height/2;
    
    // Background Ring
    drawArc(context,[[UIColor darkGrayColor]colorWithAlphaComponent:0.5f], LINEWIDTH, xOrigin, yOrigin,CIRCLE_RADIUS, 0.0f, 360.0f, 0);
    // Progress Ring
    drawArc(context,[UIColor whiteColor], LINEWIDTH, xOrigin, yOrigin, CIRCLE_RADIUS, 0.0f, angleForPercentage, 0);
	[super drawInContext:context];
}

- (id<CAAction>)actionForKey:(NSString *)event {
    if ([event isEqualToString:@"progress"]) {
        if(self.reset){
            self.reset = NO;
            return [super actionForKey:event];
        }
   
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:event];
        animation.fromValue = [self.presentationLayer valueForKey:event];
        return animation;
    }
	return [super actionForKey:event];
}

void drawArc(CGContextRef context,UIColor * color,float lineWidth,float x,float y,float radius,float startAngle,float endAngle,bool clockwise) {
    CGContextSetStrokeColorWithColor(context,  color.CGColor);
    CGMutablePathRef path = CGPathCreateMutable();
    CGContextSetLineWidth(context, lineWidth);
    CGPathAddArc(path, NULL, x, y, radius, (startAngle-90.0f)*3.14159/180, (endAngle-90.0f)*3.14159/180, clockwise);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    CGPathRelease(path);
}

- (CGFloat)ringRadius {
    return _ringRadius;
}

- (void) setRingRadius:(CGFloat)ringRadius {
    _ringRadius = ringRadius;
}


@end

@implementation MHProgressView
@synthesize progress = _progress;
+ (Class)layerClass {
    return [MHProgressLayer class];
}
 
- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self)  {

        self.opaque = NO;
        [(id)self.layer setProgress:0];
        [(id)self.layer setRingRadius:25.0f];
        [self setBackgroundColor:[UIColor lightGrayColor]];
        self.layer.shouldRasterize = YES;
        [self.layer setNeedsDisplay];
    }
    return self;
}

- (void) reset {
    [(id)self.layer setReset:YES];
    [(id)self.layer setProgress:0];
    [self.layer setNeedsDisplay];
}

- (void)setProgress:(CGFloat)progress {
	[(id)self.layer setProgress:progress];
}

- (CGFloat)progress {
	return [(id)self.layer progress];
}

@end
