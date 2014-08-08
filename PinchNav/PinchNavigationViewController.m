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
- (void)drawRect:(CGRect)rect {
    // Draw a circle
	CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetFillColor(ctx, CGColorGetComponents([self.fillColor CGColor]));
    CGContextFillPath(ctx);
}
@end

@interface PinchNavigationViewController ()
@property (nonatomic, strong) UIView *irisView;
@property (nonatomic, strong) UIView *superViewReference;
@property (nonatomic, readwrite) PNavState state;
@property (nonatomic, strong) NSArray *buttonArray;
@end

@implementation PinchNavigationViewController

- (instancetype)initWithSuperview:(UIView *)superView withButtonArray:(NSArray *)buttonArray
{
    self = [super init];
    if (self) {
        
        self.buttonArray = buttonArray;
        
        self.state = PNavStateClosed;
        
        [self setDefaultProperties];
        
        // assign the pinch gesture to the superview
        if(superView) {
            self.superViewReference = superView;
        
            UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinch:)];
            
            [superView addGestureRecognizer:pinchGesture];
        }
    }
    
    return self;
}

- (void)setDefaultProperties
{
    self.durationAnimatingIrisIn = 0.5;
    self.durationAnimatingIrisOut = 0.2;
    self.durationAnimatingButtonsOutFromCenter = 0.3;
    self.durationAnimatingButtonsOutAndClose = 0.3;
    self.durationAnimatingSelectedButtonIn = 0.3;
    self.durationAnimatingSelectedIrisOut = 0.5;
    self.durationTransitionPeriod = 0.5;
    self.durationAnimatingFadeOutAndClose = 0.3;
    
    self.pinchInCutoffPoint = 0.2;
    self.pinchEndedCutoffPoint = 0.65;
    
    self.buttonDistanceFromCenter = 110;
    
    self.irisAlpha = 0.3;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Tap outside to dismiss
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapToDismiss:)];
	[self.view addGestureRecognizer:tapRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setPinchInCutoffPoint:(CGFloat)pinchInCutoffPoint
{
    // value needs to be between 1.0 and 0.01
    _pinchInCutoffPoint = MIN(1.0f, MAX(kMinIrisScale, pinchInCutoffPoint));
}

- (void)onPinch:(UIPinchGestureRecognizer *)gesture
{
    if(gesture.scale < 1.0f && (self.state == PNavStateClosed || self.state == PNavStatePinching)){
        
        self.state = PNavStatePinching;
        
        if(!self.view.superview){
            self.view.frame = self.superViewReference.frame;
            [self.superViewReference addSubview:self.view];
        }
        
        if(!self.irisView){
            
            //Create a huge UIView to use for the initial animation.
            self.irisView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100000, 100000)];
            //Set the center at the screen's center, so we have plenty of room for scale animating.
            self.irisView.center = self.view.center;
            self.irisView.backgroundColor = [UIColor blackColor];
            self.irisView.alpha = 0.3;
            //Set alpha to 0 to start. Then we animate the fade.
            [self.view addSubview:self.irisView];
            //        [self.view sendSubviewToBack:self.irisView];
            
            //Circle should fit the view.
            CGFloat shortSide = (self.view.bounds.size.width < self.view.bounds.size.height) ? self.view.bounds.size.width : self.view.bounds.size.height;
            
            //Create the mask.
            [self addMaskCircleToView:self.irisView WithRadius:shortSide/2];

        }else{
            [self.irisView setTransform:CGAffineTransformMakeScale(gesture.scale, gesture.scale)];
            
            if(gesture.scale <= self.pinchInCutoffPoint){
                // animate iris all the way in
                
                self.state = PNavStateAnimatingIrisIn;
                
                [self animateIrisAtScale:gesture.scale withVelocity:gesture.velocity toCenterWithCompletion:^{
                    
                    [self animateButtonsOutFromCenterWithCompletion:^{
                        self.state = PNavStateButtonSelection;
                    }];
                    
                }];
            }
        }
    }
    
    if(gesture.state == UIGestureRecognizerStateEnded && self.irisView){
        
        if(self.state == PNavStatePinching){
            if(gesture.scale < self.pinchEndedCutoffPoint){
                [self animateIrisAtScale:gesture.scale withVelocity:gesture.velocity toCenterWithCompletion:^{
                    
                    [self animateButtonsOutFromCenterWithCompletion:^{
                        self.state = PNavStateButtonSelection;
                    }];
                    
                }];
            }else{
                self.state = PNavStateAnimatingIrisOut;
                
                [self animateIrisOutWithCompletion:^{
                    [self setMenuClosed];
                }];
            }
        }
        
    }
    
    if(gesture.scale > 1 && self.state == PNavStateButtonSelection){
        [self animateButtonsOutAndCloseWithCompletion:^{
            [self setMenuClosed];
        }];
    }

    NSLog(@"Pinch: %f", gesture.scale);
    NSLog(@"Velocity: %f", gesture.velocity);
    
}

- (void)setMenuClosed
{
    [self.irisView removeFromSuperview];
    self.irisView = nil;
    self.view.alpha = 1.0f;
    self.state = PNavStateClosed;
}

- (void)animateIrisAtScale:(CGFloat)currentScale withVelocity:(CGFloat)currentVelocity toCenterWithCompletion:(void (^)())completion
{
    CGFloat calculatedDuration = self.durationAnimatingIrisIn * currentScale;
    
    [UIView animateWithDuration:calculatedDuration
						  delay:0
						options:(UIViewAnimationOptionCurveEaseOut)
					 animations:^{
						 self.irisView.transform = CGAffineTransformScale(CGAffineTransformIdentity, kMinIrisScale, kMinIrisScale);
					 }
					 completion:^(BOOL finishedFirst){
                         completion();
                     }];

}

- (void)animateIrisOutWithCompletion:(void (^)())completion
{
    
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
    
    //Get rid of animation view, and switch to using self as the background.
    self.irisView.layer.mask = nil;
    [self.irisView setFrame:self.view.frame];
    
    [self initButtons];
    
    //Show icon circles and expand them out from the center.
    //Prepare the buttons to be animated in.
    for(PinchNavigationButtonView *item in self.buttonArray)
    {
        [self prepareButtonForStartAnimation:item];
    }
    
    //Animate each button outwards.
    //This is done with a CAKeyframeAnimation subclass,
    //So we don't need to perform this within the animation block.
    [UIView animateWithDuration:self.durationAnimatingButtonsOutFromCenter delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        for(int i = 0; i < self.buttonArray.count; i++)
        {
            PinchNavigationButtonView *button = [self.buttonArray objectAtIndex:i];
            [self animateButtonOutwards:button forIndex:i withDistance:self.buttonDistanceFromCenter];
            
        }
        
    }completion:^(BOOL animationCompleted){
        
        completion();
        
    }];
   
    
    //slide in the top/bottom views
//    [self showTopBottomViewsAnimated:YES];
}

- (void)animateButtonsOutAndCloseWithCompletion:(void(^)())completion
{
    self.state = PNavStateAnimatingButtonsOutAndClose;
    
    [UIView animateWithDuration:self.durationAnimatingButtonsOutAndClose delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        for(int i = 0; i < self.buttonArray.count; i++)
        {
            PinchNavigationButtonView *button = [self.buttonArray objectAtIndex:i];
            [self animateButtonOutwards:button forIndex:i withDistance:160];
            button.alpha = 0;
            
        }
        
        self.view.alpha = 0;
        
    }completion:^(BOOL finished){
        
        completion();
        
    }];
}

//This method will add a circular mask at the center of the view.
//The radius parameter will determine how large the circle is.
- (void)addMaskCircleToView:(UIView *)view WithRadius:(CGFloat)radius
{
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = view.bounds;
    maskLayer.fillColor = [UIColor blackColor].CGColor;
	
	//Place the circle mask in the middle of the UIView passed in.
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
	//Given a starting point, angle, and distance, calculate the new coordinates.
	CGFloat x = point.x + (cos(angle * M_PI / 180) * distance);
	CGFloat y = point.y + (sin(angle * M_PI / 180) * distance);
	return CGPointMake(x, y);
}

- (void)prepareButtonForStartAnimation:(UIView *)button
{
	button.alpha = 0.0;
	button.hidden = NO;
	button.center = self.view.center;
}

- (void)animateButtonOutwards:(UIView *)button forIndex:(NSUInteger)index withDistance:(CGFloat)distance
{
	//Because the math assumes an angle of 0 is on the x axis, we want to rotate calculations 90 degrees
	//So an angle of 0 degrees becomes staight up.
	int angleShift = -90;
	
	//Angle of separation between buttons.
	CGFloat angleVariance = 360.0 / self.buttonArray.count;
	
	//Get the new coordinates based on distance/angle
	CGPoint newCenter = [self calculateCoordinatesFromPoint:button.center forAngle:(angleVariance * index) + angleShift withDistance:self.buttonDistanceFromCenter];
    
    button.center = newCenter;
    button.alpha = 1.0f;
}

- (void)initButtons
{
	//Create the buttonContainer
	//It will be a square equal to the width of the screen.
//	CGFloat width = [[UIScreen mainScreen] bounds].size.width;
//	self.buttonContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
//	self.buttonContainer.center = self.view.center;
//	[self.view addSubview:self.buttonContainer];
	//Add constraints to have it centered always.
    //	[self.buttonContainer makeConstraints:^(MASConstraintMaker *make){
    //		make.center.equalTo(self.view);
    //		make.height.equalTo(@(width));
    //		make.width.equalTo(@(width));
    //	}];
	
    
	//Add the button
	for(PinchNavigationButtonView *buttonView in self.buttonArray)
	{
        buttonView.delegate = self;
		[self.view addSubview:buttonView];
	}
    
}

- (void)tapToDismiss:(UITapGestureRecognizer *)recognizer
{
    if(self.state == PNavStateButtonSelection){
        [self animateButtonsOutAndCloseWithCompletion:^{
            [self setMenuClosed];
        }];
    }
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
                         for(PinchNavigationButtonView *button in self.buttonArray){
                             if(![button isEqual:selectedButton]){
                                 button.alpha = 0;
                             }
                             
                             button.center = self.view.center;
                         }
                    }completion:^(BOOL finished){
                        
                        onComplete();
                        
                     }];

}

- (void)animateSelectedIrisOutForButton:(PinchNavigationButtonView *)selectedButton withCompletion:(void(^)())onComplete
{
    self.state = PNavStateAnimatingSelectedIrisOut;
    
    //Expand new view outward until it covers the screen.
    //Start it small
    PinchNavigationCircleView *animationView = [[PinchNavigationCircleView alloc] initWithFrame:CGRectMake(0, 0, selectedButton.frame.size.width - 10, selectedButton.frame.size.height - 10)];
    animationView.fillColor = selectedButton.fillColor;
    animationView.backgroundColor = [UIColor clearColor];
    animationView.center = self.view.center;
    
    [self.view addSubview:animationView];
    [self.view bringSubviewToFront:selectedButton];
    
    //Animate the circle view outwards until it fills the screen.
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
        
    }completion:^(BOOL finished){
        
        for(UIView *subview in self.view.subviews){
            [subview removeFromSuperview];
        }
        
        onComplete();
        
    }];
}


- (void)didSelectNavigationButton:(PinchNavigationButtonView *)selectedButton
{
    [self animateTransitionToButton:selectedButton withCompletion:^{
        
        [self animateSelectedIrisOutForButton:selectedButton withCompletion:^{
            
            if([self.delegate respondsToSelector:@selector(shouldTransitionToButton:)]){
                [self.delegate shouldTransitionToButton:selectedButton];
            }
            
            [self animateFadeOutAndCloseWithDelay:self.durationTransitionPeriod duration:self.durationAnimatingFadeOutAndClose onComplete:^{
                
                 [self setMenuClosed];
                
            }];

        }];
        
    }];
}


@end
