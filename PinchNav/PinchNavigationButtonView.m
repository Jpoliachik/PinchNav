//
//  PinchNavigationButtonView.m
//  
//
//  Created by Justin Poliachik on 7/30/14.
//
//

#import "PinchNavigationButtonView.h"

@interface PinchNavigationButtonView()
@end

@implementation PinchNavigationButtonView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (instancetype)initWithTitle:(NSString *)title color:(UIColor *)color diameter:(CGFloat)diameter
{
	self = [self initWithFrame:CGRectMake(0, 0, diameter, diameter)];
	
	if(!self){
		return nil;
	}
	self.shouldAnimateOnPress = YES;
    [self setBackgroundColor:[UIColor clearColor]];
    
	_fillColor = color;
    
    //Title only
    self.titleLabel = [self createLabel];
    self.titleLabel.center = self.center;
    [self.titleLabel setText:title];
    
    [self addSubview:self.titleLabel];
    
    UIButton *button = [[UIButton alloc] initWithFrame:self.frame];
    [button addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(buttonRelease:) forControlEvents:UIControlEventTouchCancel];
    [button addTarget:self action:@selector(buttonRelease:) forControlEvents:UIControlEventTouchDragExit];
    [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(buttonRelease:) forControlEvents:UIControlEventTouchUpOutside];
    [self addSubview:button];
	
	return self;
}

/**
 *  Creates a UILabel with default properties to be used as the titleLabel view
 *
 *  @return new UILabel with default properties
 */
- (UILabel *)createLabel
{
	UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	[newLabel setTextAlignment:NSTextAlignmentCenter];
    [newLabel setTextColor:[UIColor whiteColor]];
	return newLabel;
}

/**
 *  DrawRect override
 *	Unless we are using a custom view, draw the view as a circle with the correct fill color.
 *
 *  @param rect size to draw the view
 */
- (void)drawRect:(CGRect)rect
{
    // Draw a circle
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetFillColor(ctx, CGColorGetComponents([self.fillColor CGColor]));
    CGContextFillPath(ctx);

}

/**
 *  ButtonPress action handler. Will scale the view to simulate touch if animations are enabled.
 *
 *  @param sender button
 */
- (void)buttonPress:(id)sender
{
	if(self.shouldAnimateOnPress){
		//Button scale animation slightly larger
		[UIView beginAnimations:@"ScaleSelf" context:NULL];
		[UIView setAnimationDuration: 0.1f];
		self.transform = CGAffineTransformMakeScale(1.2,1.2);
		[UIView commitAnimations];
	}
}

/**
 *  ButtonRelease action handler. Will scale the view back to normal if animations are enabled.
 *
 *  @param sender button
 */
- (void)buttonRelease:(id)sender
{
	if(self.shouldAnimateOnPress){
		//Scale animation back to normal
		[UIView beginAnimations:@"ScaleSelf" context:NULL];
		[UIView setAnimationDuration: 0.3f];
		self.transform = CGAffineTransformMakeScale(1.0,1.0);
		[UIView commitAnimations];
	}
}

- (void)buttonSelected:(id)sender
{
    [self buttonRelease:sender];
    
    if([self.delegate respondsToSelector:@selector(didSelectNavigationButton:)]){
        [self.delegate didSelectNavigationButton:self];
    }
}

@end
