//
//  UITextField+Underline.m
//  RCloudMessage
//
//  Created by MiaoGuangfa on 4/16/15.
//  Copyright (c) 2015 胡利武. All rights reserved.
//

#import "UITextField+Underline.h"

@implementation UITextField ( Underline )

- (void)drawUnderlineWithTextFieldBounds:(CGRect)bounds
{
    NSLog(@"%@", NSStringFromCGRect(bounds));
    
    //Get the current drawing context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Set the line color and width
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:161 green:163 blue:168 alpha:0.2f].CGColor);
    CGContextSetLineWidth(context, 1.0f);
    
    
    //Start a new Path
    CGContextBeginPath(context);
    
    //Find the number of lines in our textView + add a bit more height to draw lines in the empty part of the view
    //NSUInteger numberOfLines = (self.contentSize.height + self.bounds.size.height) / self.font.leading;
    
    //Set the line offset from the baseline. (I'm sure there's a concrete way to calculate this.)
    //CGFloat baselineOffset = 20.0f;
    
    //iterate over numberOfLines and draw each line

    //0.5f offset lines up line with pixel boundary
//    CGContextMoveToPoint(context, bounds.origin.x, self.font.leading + 1.5f + baselineOffset);
//    CGContextAddLineToPoint(context, bounds.size.width-10, self.font.leading + 0.5f + baselineOffset);
    
    CGContextMoveToPoint(context, bounds.origin.x, bounds.size.height);
    CGContextAddLineToPoint(context, bounds.size.width, bounds.size.height);
    
    //Close our Path and Stroke (draw) it
    CGContextClosePath(context);
    CGContextStrokePath(context);
}
@end
