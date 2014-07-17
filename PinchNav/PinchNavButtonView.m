//
//  PinchNavButtonView.m
//  
//
//  Created by Justin Poliachik on 7/14/14.
//
//

#import "PinchNavButtonView.h"

@interface PinchNavButtonView()

@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic) BOOL isCustomView;

@end

@implementation PinchNavButtonView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.hidden = YES;
		self.shouldAnimateOnPress = YES;
    }
    return self;
}

#pragma mark - Public Init Methods

- (instancetype)initWithTitle:(NSString *)title color:(UIColor *)color diameter:(CGFloat)diameter
{
	return [self initWithTitle:title andIcon:nil titleOnTop:NO color:color diameter:diameter];
}

- (instancetype)initWithIcon:(UIImage *)icon color:(UIColor *)color diameter:(CGFloat)diameter
{
	return [self initWithTitle:nil andIcon:icon titleOnTop:NO color:color diameter:diameter];
}

- (instancetype)initWithTitle:(NSString *)title andIcon:(UIImage *)icon titleOnTop:(BOOL)isTitleOnTop color:(UIColor *)color diameter:(CGFloat)diameter
{
	self = [self initWithFrame:CGRectMake(0, 0, diameter, diameter)];
	
	if(!self){
		return nil;
	}
	
	self.isCustomView = NO;
	self.fillColor = color;
	
	if(title && !icon){
		
		//Title only
		self.titleLabel = [self createLabel];
		self.titleLabel.center = self.center;
		
	}else if(icon && !title){
		
		//Icon only
		
	}else if(title && icon){
		
		//Both title and icon
		
	}
	
	return self;
}

- (instancetype)initWithCustomView:(UIView *)view
{
	self = [self initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.width)];
	
	if(!self){
		return nil;
	}
	
	self.isCustomView = YES;
	[self addSubview:view];
	return self;
}


#pragma mark - Private Methods

/**
 *  Creates a UIButton used to handle touch events for the PinchNavButtonView
 *	Frame size is the same as self.frame
 *
 *  @return new UIButton with control event actions
 */
- (UIButton *)createButton
{
	UIButton *newButton = [[UIButton alloc] initWithFrame:self.frame];
	newButton.backgroundColor = [UIColor clearColor];
	[newButton addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchDown];
	[newButton addTarget:self action:@selector(buttonRelease:) forControlEvents:UIControlEventTouchUpInside];
	[newButton addTarget:self action:@selector(buttonRelease:) forControlEvents:UIControlEventTouchUpOutside];
	[newButton addTarget:self action:@selector(buttonRelease:) forControlEvents:UIControlEventTouchCancel];
	[newButton addTarget:self action:@selector(buttonRelease:) forControlEvents:UIControlEventTouchDragExit];
	
	return newButton;
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
	if(self.isCustomView){
		[super drawRect:rect];
	}else{
		// Draw a circle
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		CGContextAddEllipseInRect(ctx, rect);
		CGContextSetFillColor(ctx, CGColorGetComponents([self.fillColor CGColor]));
		CGContextFillPath(ctx);
	}
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
		self.transform = CGAffineTransformMakeScale(1.4,1.4);
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
		[UIView setAnimationDuration: 0.1f];
		self.transform = CGAffineTransformMakeScale(1.0,1.0);
		[UIView commitAnimations];
	}
}


@end
