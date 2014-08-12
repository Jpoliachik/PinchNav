//
//  PinchNavigationViewController.m
//  
//
//  Created by Justin Poliachik on 7/30/14.
//
//

#import "PinchNavigationViewController.h"

static const CGFloat kMinIrisScale = 0.01f;

@interface PinchNavigationCircleView : UIView
@property (nonatomic, strong) UIColor *fillColor;
@end

@implementation PinchNavigationCircleView
- (void)drawRect:(CGRect)rect
{
    // Draw a circle
	CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetFillColor(ctx, CGColorGetComponents([self.fillColor CGColor]));
    CGContextFillPath(ctx);
}
@end

@interface PinchNavigationViewController ()
@property (nonatomic, strong) UIView *irisView;
@property (nonatomic, readwrite) PNavState state;
@property (nonatomic, strong) NSArray *buttonArray;
@end

@implementation PinchNavigationViewController

#pragma mark - Init

- (instancetype)initWithGestureRecognizingView:(UIView *)gestureView withButtonArray:(NSArray *)buttonArray
{
    self = [super init];
    if (self) {
        
        self.buttonArray = buttonArray;
        
        self.state = PNavStateClosed;
        
        [self setDefaultProperties];
        
        // assign the pinch gesture to the superview
        if(gestureView) {
        
            UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinch:)];
            
            [gestureView addGestureRecognizer:pinchGesture];
        }
    }
    
    return self;
}

#pragma mark - Setup

- (void)setDefaultProperties
{
    self.durationAnimatingIrisIn                = 0.5f;
    self.durationAnimatingIrisOut               = 0.2f;
    self.durationAnimatingButtonsOutFromCenter  = 0.3f;
    self.durationAnimatingButtonsOutAndClose    = 0.3f;
    self.durationAnimatingSelectedButtonIn      = 0.3f;
    self.durationAnimatingSelectedIrisOut       = 0.5f;
    self.durationTransitionPeriod               = 0.5f;
    self.durationAnimatingFadeOutAndClose       = 0.3f;
    
    self.pinchInCutoffPoint                     = 0.2f;
    self.pinchEndedCutoffPoint                  = 0.65f;
    
    self.buttonDistanceFromCenter               = 110;
    
    self.irisAlpha                              = 0.3f;
    self.irisColor = [UIColor blackColor];
}

- (void)initButtons
{
	// buttons are created just before showing them
    // create and add as subviewx
	for ( PinchNavigationButtonView *buttonView in self.buttonArray ) {
        buttonView.delegate = self;
        buttonView.alpha = 0.0;
        buttonView.hidden = NO;
        buttonView.center = self.view.center;
		[self.view addSubview:buttonView];
	}
}

- (void)loadView
{
    [super loadView];

    // Tap outside to dismiss
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapToDismiss:)];
	[self.view addGestureRecognizer:tapRecognizer];
}

#pragma mark - Getters / Setters
// overrite setter to make sure the value is between 1.0 and 0.01
- (void)setPinchInCutoffPoint:(CGFloat)pinchInCutoffPoint
{
    _pinchInCutoffPoint = MIN(1.0f, MAX(kMinIrisScale, pinchInCutoffPoint));
}

# pragma mark - Public Methods

- (void)onPinch:(UIPinchGestureRecognizer *)gesture
{
    if ( gesture.scale < 1.0f && ( self.state == PNavStateClosed || self.state == PNavStatePinching ) ) {
        
        self.state = PNavStatePinching;
      
        // if the nav view currently has no superview, add it to the top view controller.
        if ( !self.view.superview ) {
            UIViewController *superVC = [self getTopViewController];
            self.view.frame = superVC.view.frame;
            [superVC.view addSubview:self.view];
        }
        
        if ( !self.irisView ) {
            
            // Create a huge UIView to use for the initial animation.
            self.irisView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 100, self.view.frame.size.height * 100)];
            // Set the center at the screen's center, so we have plenty of room for scale animating.
            self.irisView.center = self.view.center;
            self.irisView.backgroundColor = self.irisColor;
            self.irisView.alpha = 0;
            // Set alpha to 0 to start. Then we animate the fade.
            [self.view addSubview:self.irisView];
            
            [UIView animateWithDuration:0.2 animations:^{
                self.irisView.alpha = self.irisAlpha;
            }];
            
            // Circle should fit the view.
            CGFloat shortSide = (self.view.bounds.size.width < self.view.bounds.size.height) ? self.view.bounds.size.width : self.view.bounds.size.height;
            
            // Create the mask.
            [self addMaskCircleToView:self.irisView WithRadius:shortSide/2];

        }
        else {
            [self.irisView setTransform:CGAffineTransformMakeScale(gesture.scale, gesture.scale)];
            
            if ( gesture.scale <= self.pinchInCutoffPoint ) {
                // animate iris all the way in
                
                [self animateIrisAtScale:gesture.scale withVelocity:gesture.velocity toCenterWithCompletion:^{
                    
                    [self animateButtonsOutFromCenterWithCompletion:^{
                        self.state = PNavStateButtonSelection;
                    }];
                    
                }];
            }
        }
    }
    
    if ( gesture.state == UIGestureRecognizerStateEnded && self.irisView ) {
        
        if ( self.state == PNavStatePinching ) {
            if ( gesture.scale < self.pinchEndedCutoffPoint ) {
                [self animateIrisAtScale:gesture.scale withVelocity:gesture.velocity toCenterWithCompletion:^{
                    
                    [self animateButtonsOutFromCenterWithCompletion:^{
                        self.state = PNavStateButtonSelection;
                    }];
                    
                }];
            }
            else {
                self.state = PNavStateAnimatingIrisOut;
                
                [self animateIrisOutWithCompletion:^{
                    [self setMenuClosed];
                }];
            }
        }
        
    }
    
    if ( gesture.scale > 1 && self.state == PNavStateButtonSelection ) {
        [self animateButtonsOutAndCloseWithCompletion:^{
            [self setMenuClosed];
        }];
    }
    
}

- (void)setMenuClosed
{
    [self.irisView removeFromSuperview];
    self.irisView = nil;
    self.view.alpha = 1.0f;
    self.state = PNavStateClosed;
}

- (void)didSelectNavigationButton:(PinchNavigationButtonView *)selectedButton
{
    [self animateTransitionToButton:selectedButton withCompletion:^{
        
        [self animateSelectedIrisOutForButton:selectedButton withCompletion:^{
            
            if ( [self.delegate respondsToSelector:@selector(shouldTransitionToButton:)] ) {
                [self.delegate shouldTransitionToButton:selectedButton];
            }
            
            // the root view controller may have changed.
            // add self as a subview again to finish the animation and close gracefully
            [[self getTopViewController].view addSubview:self.view];
            
            [self animateFadeOutAndCloseWithDelay:self.durationTransitionPeriod duration:self.durationAnimatingFadeOutAndClose onComplete:^{
                
                [self setMenuClosed];
                
            }];
            
        }];
        
    }];
}

- (void)tapToDismiss:(UITapGestureRecognizer *)recognizer
{
    if ( self.state == PNavStateButtonSelection ) {
        [self animateButtonsOutAndCloseWithCompletion:^{
            [self setMenuClosed];
        }];
    }
}

#pragma mark - Private Animations

- (void)animateIrisAtScale:(CGFloat)currentScale withVelocity:(CGFloat)currentVelocity toCenterWithCompletion:(void (^)())completion
{
    self.state = PNavStateAnimatingIrisIn;
    
    CGFloat calculatedDuration = self.durationAnimatingIrisIn * currentScale;
    
    [UIView animateWithDuration:calculatedDuration
						  delay:0
						options:(UIViewAnimationOptionCurveEaseOut)
					 animations:^{
						 self.irisView.transform = CGAffineTransformScale( CGAffineTransformIdentity, kMinIrisScale, kMinIrisScale );
					 }
					 completion:^(BOOL finishedFirst){
                         completion();
                     }];

}

- (void)animateIrisOutWithCompletion:(void (^)())completion
{
    self.state = PNavStateAnimatingIrisOut;
    
    [UIView animateWithDuration:self.durationAnimatingIrisOut
                          delay:0
                        options:(UIViewAnimationOptionCurveEaseInOut)
                     animations:^{
                         
                         self.irisView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                         self.irisView.alpha = 0;
                         
                     }completion:^(BOOL finishedSecond){
                         completion();
                     }];
}

- (void)animateButtonsOutFromCenterWithCompletion:(void (^)())completion
{
    self.state = PNavStateAnimatingButtonsOutFromCenter;
    
    // Get rid of animation view, and switch to using self as the background.
    self.irisView.layer.mask = nil;
    [self.irisView setFrame:self.view.frame];
    
    [self initButtons];
    
    // Animate each button outwards.
    // This is done with a CAKeyframeAnimation subclass,
    // So we don't need to perform this within the animation block.
    [UIView animateWithDuration:self.durationAnimatingButtonsOutFromCenter delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        for ( int i = 0; i < self.buttonArray.count; i++ ) {
            PinchNavigationButtonView *button = [self.buttonArray objectAtIndex:i];
            [self moveViewOutwardsFromCenter:button forIndex:i withDistance:self.buttonDistanceFromCenter];
            button.alpha = 1;
        }
        
    } completion:^(BOOL animationCompleted) {
        
        completion();
        
    }];

}

- (void)animateButtonsOutAndCloseWithCompletion:(void(^)())completion
{
    self.state = PNavStateAnimatingButtonsOutAndClose;
    
    [UIView animateWithDuration:self.durationAnimatingButtonsOutAndClose delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        for ( int i = 0; i < self.buttonArray.count; i++ ) {
            PinchNavigationButtonView *button = [self.buttonArray objectAtIndex:i];
            [self moveViewOutwardsFromCenter:button forIndex:i withDistance:160];
            button.alpha = 0;
            
        }
        
        self.view.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        completion();
        
    }];
}

- (void)animateTransitionToButton:(PinchNavigationButtonView *)selectedButton withCompletion:(void(^)())onComplete
{
    self.state = PNavStateAnimatingSelectedButtonIn;
    
    [self.view bringSubviewToFront:selectedButton];
    
    [UIView animateWithDuration:self.durationAnimatingSelectedButtonIn
                          delay:0
                        options:(UIViewAnimationOptionCurveEaseInOut)
                     animations:^{
                         
                         //Move the buttons back to the center.
                         //The selected button does not fade out.
                         for( PinchNavigationButtonView *button in self.buttonArray ) {
                             if ( ![button isEqual:selectedButton] ) {
                                 button.alpha = 0;
                             }
                             
                             button.center = self.view.center;
                         }
                     }completion:^(BOOL finished) {
                         
                         onComplete();
                         
                     }];
    
}

- (void)animateSelectedIrisOutForButton:(PinchNavigationButtonView *)selectedButton withCompletion:(void(^)())onComplete
{
    self.state = PNavStateAnimatingSelectedIrisOut;
    
    // Expand new view outward until it covers the screen.
    // Start it small
    PinchNavigationCircleView *animationView = [[PinchNavigationCircleView alloc] initWithFrame:CGRectMake(0, 0, selectedButton.frame.size.width - 10, selectedButton.frame.size.height - 10)];
    animationView.fillColor = selectedButton.fillColor;
    animationView.backgroundColor = [UIColor clearColor];
    animationView.center = self.view.center;
    
    [self.view addSubview:animationView];
    [self.view bringSubviewToFront:selectedButton];
    
    // Animate the circle view outwards until it fills the screen.
    [UIView animateWithDuration:self.durationAnimatingSelectedIrisOut
                          delay:0
                        options:(UIViewAnimationOptionCurveEaseInOut)
                     animations:^{
                         animationView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 20.0, 20.0);
                     }completion:^(BOOL finished){
                         
                         onComplete();
                         
                     }];
    
}


- (void)animateFadeOutAndCloseWithDelay:(CGFloat)delay duration:(CGFloat)duration onComplete:(void(^)())onComplete
{
    self.state = PNavStateTransitionPeriod;
    
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.state = PNavStateFadeOutAndClose;
        
        self.view.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        for(UIView *subview in self.view.subviews){
            [subview removeFromSuperview];
        }
        
        onComplete();
        
    }];
}

#pragma mark - Private Helper Methods

// This method will add a circular mask at the center of the view.
// The radius parameter will determine how large the circle is.
- (void)addMaskCircleToView:(UIView *)view WithRadius:(CGFloat)radius
{
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = view.bounds;
    maskLayer.fillColor = [UIColor blackColor].CGColor;
	
	// Place the circle mask in the middle of the UIView passed in.
    CGRect const circleRect = CGRectMake(CGRectGetMidX(view.bounds) - radius,
										 CGRectGetMidY(view.bounds) - radius,
										 2 * radius, 2 * radius);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:circleRect];
    [path appendPath:[UIBezierPath bezierPathWithRect:view.bounds]];
    maskLayer.path = path.CGPath;
    maskLayer.fillRule = kCAFillRuleEvenOdd;
	
    view.layer.mask = maskLayer;
}

- (CGPoint)calculateCoordinatesFromPoint:(CGPoint)point forAngle:(CGFloat)angle withDistance:(CGFloat)distance
{
	// Given a starting point, angle, and distance, calculate the new coordinates.
	CGFloat x = point.x + (cos(angle * M_PI / 180) * distance);
	CGFloat y = point.y + (sin(angle * M_PI / 180) * distance);
	return CGPointMake(x, y);
}

- (void)moveViewOutwardsFromCenter:(UIView *)view forIndex:(NSUInteger)index withDistance:(CGFloat)distance
{
	// Because the math assumes an angle of 0 is on the x axis, we want to rotate calculations 90 degrees
	// So an angle of 0 degrees becomes staight up.
	int angleShift = -90;
	
	// Angle of separation between buttons.
	CGFloat angleVariance = 360.0 / self.buttonArray.count;
	
	// Get the new coordinates based on distance/angle
	CGPoint newCenter = [self calculateCoordinatesFromPoint:view.center forAngle:(angleVariance * index) + angleShift withDistance:self.buttonDistanceFromCenter];
    
    view.center = newCenter;
}

- (UIViewController *)getTopViewController
{
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (controller.presentedViewController != nil) {
        controller = controller.presentedViewController;
    }
    
    return controller;
}

@end
