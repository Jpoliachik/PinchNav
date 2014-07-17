//
//  PinchNavViewController.m
//  
//
//  Created by Justin Poliachik on 7/14/14.
//
//

#import "PinchNavViewController.h"

@interface PinchNavViewController ()
@property (nonatomic, strong) NSArray *buttonArray;

@property (nonatomic) CGPoint centerPointAdjusted;
@property (nonatomic) CGPoint bottomLeftAdjusted;
@property (nonatomic) CGPoint bottomRightAdjusted;

@property (strong, nonatomic) UIView *irisView;
@property (strong, nonatomic) UIView *buttonContainer;
@property (strong, nonatomic) UIView *bottomView;

@property (nonatomic) BOOL isAnimating;
@property (nonatomic) BOOL isInButtonSelectionState;

@end

@implementation PinchNavViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (instancetype)initWithNavigationButtons:(NSArray *)buttonsArray
{
	self = [super init];
	if (self) {
		self.buttonArray = buttonsArray;
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	//Start with a clear background for the startup animation.
	self.view.tag = 99999;
	
	[self initButtons];
	
	self.isAnimating = NO;
	self.isInButtonSelectionState = NO;
	
	//Tap outside to dismiss
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapToDismiss:)];
	[self.view addGestureRecognizer:tapRecognizer];
	
}

- (void)viewWillAppear:(BOOL)animated
{
	//The menu view will fit inside its superview
	self.view.frame = self.view.superview.frame;
	
	//Create a huge UIView to use for the initial animation.
	self.irisView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100000, 100000)];
	//Set the center at the screen's center, so we have plenty of room for scale animating.
	self.irisView.center = self.view.center;
	self.irisView.backgroundColor = [UIColor blackColor];
	//Set alpha to 0 to start. Then we animate the fade.
	[self.view addSubview:self.irisView];
	[self.view sendSubviewToBack:self.irisView];
	
	//Circle should fit the view.
	CGFloat shortSide = (self.view.bounds.size.width < self.view.bounds.size.height) ? self.view.bounds.size.width : self.view.bounds.size.height;
	
	//Create the mask.
	[self addMaskCircleToView:self.irisView WithRadius:shortSide/2];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initButtons
{
	//Create the buttonContainer
	//It will be a square equal to the width of the screen.
	CGFloat width = [[UIScreen mainScreen] bounds].size.width;
	self.buttonContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
	self.buttonContainer.center = self.view.center;
	[self.view addSubview:self.buttonContainer];
	//Add constraints to have it centered always.
//	[self.buttonContainer makeConstraints:^(MASConstraintMaker *make){
//		make.center.equalTo(self.view);
//		make.height.equalTo(@(width));
//		make.width.equalTo(@(width));
//	}];
	

	//Add the button
	for(UIView *buttonView in self.buttonArray)
	{
		[self.buttonContainer addSubview:buttonView];
	}

}


#pragma mark - Show/Hide Menu

- (void)closeMenu
{
	//Fade out
	//Never run the animation more than once at the same time.
	if(!self.isAnimating)
	{
		if(self.isInButtonSelectionState)
		{
			//Buttons fly outward and fade out.
			self.isAnimating = YES;
			[UIView animateWithDuration:kDurationClose
								  delay:0
								options:(UIViewAnimationOptionCurveEaseOut)
							 animations:^{
								 
								 for(int i = 0; i < self.buttonArray.count; i++)
								 {
									 LOBMenuButtonView *button = [self.buttonArray objectAtIndex:i];
									 [self animateButtonOutwards:button forIndex:i withDistance:160];
									 button.alpha = 0.0;
									 self.view.alpha = 0;
								 }
							 }
							 completion:^(BOOL finishedFirst){
								 self.isAnimating = NO;
								 [self.view removeFromSuperview];
							 }];
		}else
		{
			[self.view removeFromSuperview];
		}
		
	}
}

- (BOOL)isMenuShowing
{
	return (self.view.superview && !self.isAnimating);
}

#pragma mark - Gesture Recognition

- (void)tapToDismiss:(UITapGestureRecognizer *)recognizer
{
    DLogGreen(@"");
	[LOBAD closeMenu];
    
    //remove ourselves as delegate; it would be nice to have ability to
    //not have to set all delegates to nil here and just remove one at a time
    //somehow
    [LOBBadgingManager sharedManager].fetchedResultsController.delegate = nil;
    
    //post a notification to let other delegates know they should reset themselves
    //so updates can continue to be received
    [[NSNotificationCenter defaultCenter] postNotificationName:kLOBShouldResetBadgingDelegateNotification object:nil];
}


#pragma mark - Animations

- (void)animateIrisInAndShowMenuWithDuration:(CGFloat)duration
{
	self.isAnimating = YES;
	
	[UIView animateWithDuration:duration
						  delay:0
						options:(UIViewAnimationOptionCurveEaseOut)
					 animations:^{
						 self.irisView.alpha = kAlpha;
						 self.irisView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.02, 0.02);
					 }
					 completion:^(BOOL finishedFirst){
						 
						 //Get rid of animation view, and switch to using self as the background.
						 self.irisView.layer.mask = nil;
						 
						 //Show icon circles and expand them out from the center.
						 //Prepare the buttons to be animated in.
						 for(LOBMenuButtonView *button in self.buttonArray)
						 {
							 [self prepareButtonForStartAnimation:button];
						 }
						 
						 //Animate each button outwards.
						 //This is done with a CAKeyframeAnimation subclass,
						 //So we don't need to perform this within the animation block.
						 for(int i = 0; i < self.buttonArray.count; i++)
						 {
							 LOBMenuButtonView *button = [self.buttonArray objectAtIndex:i];
							 [self animateButtonOutwards:button forIndex:i withDistance:160];
							 
						 }
						 
						 //slide in the top/bottom views
						 [self showTopBottomViewsAnimated:YES];
						 
						 
						 [UIView animateWithDuration:kDurationButtonBounce
											   delay:0
											 options:(UIViewAnimationOptionCurveEaseOut)
										  animations:^{
											  
											  //Animate the alpha of each button.
											  for(int i = 0; i < self.buttonArray.count; i++)
											  {
												  LOBMenuButtonView *button = [self.buttonArray objectAtIndex:i];
												  button.alpha = 1.0;
											  }
											  
										  }completion:^(BOOL finishedSecond){
											  self.isAnimating = NO;
											  self.isInButtonSelectionState = YES;
										  }];
						 
					 }];
	
}



- (void)animateTransitionToButtonAtIndex:(NSUInteger)index withDuration:(CGFloat)duration
{
	if(!self.isAnimating)
	{
        //remove ourselves as delegate; it would be nice to have ability to
        //not have to set all delegates to nil here and just remove one at a time
        //somehow
        [LOBBadgingManager sharedManager].fetchedResultsController.delegate = nil;
        
		//Animate the buttons inward.
		self.isAnimating = YES;
		
		[UIView animateWithDuration:duration
							  delay:0
							options:(UIViewAnimationOptionCurveEaseInOut)
						 animations:^{
							 
							 //Move the buttons back to the center.
							 //The selected button does not fade out.
							 for(int i = 0; i < self.buttonArray.count; i++)
							 {
								 LOBMenuButtonView *button = [self.buttonArray objectAtIndex:i];
								 if(!(button.menuItemType == menuItem))
								 {
									 button.alpha = 0.0;
								 }
								 
								 button.center = CGPointMake(self.buttonContainer.frame.size.width/2, self.buttonContainer.frame.size.height/2);
								 
							 }
						 }completion:^(BOOL finished){
							 
							 //Expand new view outward until it covers the screen.
							 //Start it small
							 LOBCircleView *animationView = [[LOBCircleView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
							 animationView.fillColor = selectedButton.fillColor;
							 animationView.backgroundColor = [UIColor clearColor];
							 animationView.center = self.view.center;
							 
							 [self.view addSubview:animationView];
							 [self.view bringSubviewToFront:self.buttonContainer];
							 
							 //Animate the circle view outwards until it fills the screen.
							 [UIView animateWithDuration:kDurationTransition
												   delay:0
												 options:(UIViewAnimationOptionCurveEaseInOut)
											  animations:^{
												  animationView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 50.0, 50.0);
											  }completion:^(BOOL finishedSecond){
												  
												  //View covers screen.
												  //Change the root view controller.
												  [LOBAD changeRootViewController:menuItem];
											  }];
							 
						 }];
		
	}
}

- (void)animateTransitionToSettingsWithDuration:(CGFloat)duration
{
	
	//start and end frame of overlay view
	CGRect initalFrame = [self frameForSettingsTransitionOverlayForOrientation:self.interfaceOrientation];
	CGRect finalFrame = self.view.window.bounds;
	
	//create overlay to slide in from right side of screen
	UIView *settingsTransitionOverlay = [[UIView alloc]initWithFrame:initalFrame];
	
	[self createSettingsIconForTransition:settingsTransitionOverlay];
	
	[UIView animateKeyframesWithDuration:kDurationTransition
								   delay:0.0
								 options:UIViewKeyframeAnimationOptionCalculationModeLinear
							  animations:^{
								  [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
									  for(int i = 0; i < self.buttonArray.count; i++)
									  {
										  LOBMenuButtonView *button = [self.buttonArray objectAtIndex:i];
										  [self animateButtonOutwards:button forIndex:i withDistance:160];
										  button.alpha = 0.0;
										  self.irisView.alpha = 0;
										  self.bottomView.alpha = 0;
									  }
								  }];
								  
								  [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
									  settingsTransitionOverlay.frame = finalFrame;
								  }];
								  
								  
							  } completion:^(BOOL finished) {
								  
								  //View covers screen.
								  //Change the root view controller.
								  [LOBAD changeRootViewController:MenuItemSettings];
							  }];
}

- (void)animateButtonOutwards:(UIView *)button forIndex:(NSUInteger)index withDistance:(CGFloat)distance
{
	//Because the math assumes an angle of 0 is on the x axis, we want to rotate calculations 90 degrees
	//So an angle of 0 degrees becomes staight up.
	int angleShift = -90;
	
	//Angle of separation between buttons.
	CGFloat angleVariance = 360.0 / self.buttonArray.count;
	
	//Get the new coordinates based on distance/angle
	CGPoint newCenter = [self calculateCoordinatesFromPoint:button.center forAngle:(angleVariance * index) + angleShift withDistance:kDistanceFromCenter];
	
	//Bounce animation
	NSString *keyPath = @"position";
	id finalValue = [NSValue valueWithCGPoint:newCenter];
	SKBounceAnimation *bounceAnimation = [SKBounceAnimation animationWithKeyPath:keyPath];
	bounceAnimation.fromValue = [NSValue valueWithCGPoint:button.center];
	bounceAnimation.toValue = finalValue;
	bounceAnimation.duration = kDurationButtonBounce;
	bounceAnimation.numberOfBounces = 3;
	bounceAnimation.shouldOvershoot = YES;
	[button.layer addAnimation:bounceAnimation forKey:@"bounceOut"];
	[button.layer setValue:finalValue forKeyPath:keyPath];
}

- (void)animateIrisOutAndClose
{
	self.isAnimating = YES;
	[UIView animateWithDuration:kDurationIrisOut
						  delay:0
						options:(UIViewAnimationOptionCurveEaseInOut)
					 animations:^{
						 
						 self.irisView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
						 self.irisView.alpha = 0.1;
						 
					 }completion:^(BOOL finishedSecond){
						 self.isAnimating = NO;
						 [LOBAD closeMenu];
					 }];
	
}

- (void)showTopBottomViewsAnimated:(BOOL)animated
{
	CGFloat duration = (animated) ? 0.25 : 0;
	
	self.bottomView.hidden = NO;
	[self.bottomView setFrame:[self bottomViewStartPositionForOrientation:self.interfaceOrientation]];
	
	[self.view addSubview:self.bottomView];
	
	[UIView animateWithDuration:duration
						  delay:0
						options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 [self.bottomView setFrame:[self bottomViewEndPositionForOrientation:self.interfaceOrientation]];
					 }completion:^(BOOL finished){
						 
					 }];
}

- (void)hideTopBottomViewsAnimated:(BOOL)animated
{
	
}


#pragma mark - Drawing / Animation helpers

//This method will add a circular mask at the center of the view.
//The radius parameter will determine how large the circle is.
- (void)addMaskCircleToView:(UIView *)view WithRadius:(CGFloat)radius {
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

- (void)prepareButtonForStartAnimation:(LOBMenuButtonView *)button
{
	button.alpha = 0.0;
	button.hidden = NO;
	button.center = CGPointMake(self.buttonContainer.frame.size.width/2, self.buttonContainer.frame.size.height/2);
}

//Draw a circle inside a UIView
- (void)drawCircleLayer:(UIView *)view
{
    DLogYellow(@"");
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path addArcWithCenter:CGPointMake(view.frame.size.width/2, view.frame.size.height/2)
					radius:view.frame.size.width/2
				startAngle:0.0
				  endAngle:M_PI * 2.0
				 clockwise:YES];
	
	CAShapeLayer *shapeLayer = [CAShapeLayer layer];
	shapeLayer.path = [path CGPath];
	shapeLayer.fillColor = [[UIColor clearColor] CGColor];
	shapeLayer.strokeColor = [[UIColor whiteColor] CGColor];
	shapeLayer.lineWidth = 2;
	
	[view.layer addSublayer:shapeLayer];
}

- (CGRect)bottomViewEndPositionForOrientation:(UIInterfaceOrientation)orientation
{
	CGFloat viewHeight = 200;
	
	CGFloat longSide;
	CGFloat shortSide;
	
	if([[UIScreen mainScreen] bounds].size.width > [[UIScreen mainScreen] bounds].size.height){
		longSide = [[UIScreen mainScreen] bounds].size.width;
		shortSide = [[UIScreen mainScreen] bounds].size.height;
	}else{
		longSide = [[UIScreen mainScreen] bounds].size.height;
		shortSide = [[UIScreen mainScreen] bounds].size.width;
	}
	
	switch (orientation)
	{
		case UIInterfaceOrientationPortrait:
		{
			CGPoint origin = CGPointMake(0, longSide - viewHeight);
			return CGRectMake(origin.x, origin.y, shortSide, viewHeight);
		}
		case UIInterfaceOrientationPortraitUpsideDown:
		{
			CGPoint origin = CGPointMake(0, 0);
			return CGRectMake(origin.x, origin.y, shortSide, viewHeight);
		}
		case UIInterfaceOrientationLandscapeLeft:
		{
			CGPoint origin = CGPointMake(shortSide - viewHeight, 0);
			return CGRectMake(origin.x, origin.y, viewHeight, longSide);
		}
		case UIInterfaceOrientationLandscapeRight:
		{
			CGPoint origin = CGPointMake(0, 0);
			return CGRectMake(origin.x, origin.y, viewHeight, longSide);
		}
	}
}

- (CGRect)bottomViewStartPositionForOrientation:(UIInterfaceOrientation)orientation
{
	CGFloat viewHeight = 200;
	
	CGFloat longSide;
	CGFloat shortSide;
	
	if([[UIScreen mainScreen] bounds].size.width > [[UIScreen mainScreen] bounds].size.height){
		longSide = [[UIScreen mainScreen] bounds].size.width;
		shortSide = [[UIScreen mainScreen] bounds].size.height;
	}else{
		longSide = [[UIScreen mainScreen] bounds].size.height;
		shortSide = [[UIScreen mainScreen] bounds].size.width;
	}
	
	switch (orientation)
	{
		case UIInterfaceOrientationPortrait:
		{
			CGPoint origin = CGPointMake(shortSide, longSide - viewHeight);
			return CGRectMake(origin.x, origin.y, shortSide, viewHeight);
		}
		case UIInterfaceOrientationPortraitUpsideDown:
		{
			CGPoint origin = CGPointMake(0-shortSide, 0);
			return CGRectMake(origin.x, origin.y, shortSide, viewHeight);
		}
		case UIInterfaceOrientationLandscapeLeft:
		{
			CGPoint origin = CGPointMake(shortSide - viewHeight, 0-longSide);
			return CGRectMake(origin.x, origin.y, viewHeight, longSide);
		}
		case UIInterfaceOrientationLandscapeRight:
		{
			CGPoint origin = CGPointMake(0, longSide);
			return CGRectMake(origin.x, origin.y, viewHeight, longSide);
		}
	}
}

-(CGRect)frameForSettingsTransitionOverlayForOrientation:(UIInterfaceOrientation)orientation
{
	CGFloat longSide;
	CGFloat shortSide;
	
	CGRect mainScreen = [[UIScreen mainScreen] bounds];
	
	if(mainScreen.size.width > mainScreen.size.height){
		longSide = mainScreen.size.width;
		shortSide = mainScreen.size.height;
	}else{
		longSide = mainScreen.size.height;
		shortSide = mainScreen.size.width;
	}
	
	switch (orientation)
	{
		case UIInterfaceOrientationPortrait:
		{
			CGPoint origin = CGPointMake(shortSide, 0);
			return CGRectMake(origin.x, origin.y, shortSide, longSide);
		}
		case UIInterfaceOrientationPortraitUpsideDown:
		{
			CGPoint origin = CGPointMake(0-shortSide, 0);
			return CGRectMake(origin.x, origin.y, shortSide, longSide);
		}
		case UIInterfaceOrientationLandscapeLeft:
		{
			CGPoint origin = CGPointMake(0, 0-longSide);
			return CGRectMake(origin.x, origin.y, shortSide, longSide);
		}
		case UIInterfaceOrientationLandscapeRight:
		{
			CGPoint origin = CGPointMake(0, longSide);
			return CGRectMake(origin.x, origin.y, shortSide, longSide);
		}
	}
	
}

-(void)createSettingsIconForTransition:(UIView *)view
{
	//get random color
	//	int colorIndex = arc4random() % [LOBAD.colorArray count];
	view.backgroundColor = [UIColor LOBGrey];
	
	//add overlay view
	[self.view addSubview:view];
	
	//---create subviews---//
	
	//create container for settings icon + label
	UIView *containerView = [[UIView alloc]init];
	[view addSubview:containerView];
	
	//create and add settings icon to container view
	UIImageView *settingsIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"settings-icon"]];
	[containerView addSubview:settingsIcon];
	
	//create and add settings label to container view
	UILabel *settingsLabel = [[UILabel alloc]init];
	[settingsLabel setText:@"Settings"];
	[settingsLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
	[containerView addSubview:settingsLabel];
	
	//icon is only upright in portrait,
	//so rotate the image depending on the orientation
	[self makeViewUpright:containerView];
	
	//---contraints---//
	
	//container view constraints
	[containerView makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(view);
		make.centerX.equalTo(view);
		make.width.equalTo(@200);
		make.height.equalTo(@200);
	}];
	
	//image view constraints
	[settingsIcon makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(containerView);
		make.centerX.equalTo(containerView);
	}];
	
	//settings label constraints
	[settingsLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(containerView).with.offset(35);
		make.centerX.equalTo(containerView);
	}];
	
}

#pragma mark - Button Action Events

- (IBAction)onMenuBooks:(id)sender
{
	LOBMenuButtonView *selectedView = (LOBMenuButtonView *)[(UIButton *)sender superview];
	[self animateTransitionToButton:selectedView forMenuItem:MenuItemBooks withDuration:kDurationButtonInward];
}

- (IBAction)onMenuCalendar:(id)sender
{
	LOBMenuButtonView *selectedView = (LOBMenuButtonView *)[(UIButton *)sender superview];
	[self animateTransitionToButton:selectedView forMenuItem:MenuItemCalendar withDuration:kDurationButtonInward];
}

- (IBAction)onMenuDirectory:(id)sender
{
	LOBMenuButtonView *selectedView = (LOBMenuButtonView *)[(UIButton *)sender superview];
	[self animateTransitionToButton:selectedView forMenuItem:MenuItemDirectory withDuration:kDurationButtonInward];
}

- (IBAction)onMenuCommittee:(id)sender
{
	LOBMenuButtonView *selectedView = (LOBMenuButtonView *)[(UIButton *)sender superview];
	[self animateTransitionToButton:selectedView forMenuItem:MenuItemCommittee withDuration:kDurationButtonInward];
}

- (IBAction)onMenuFindings:(id)sender
{
	LOBMenuButtonView *selectedView = (LOBMenuButtonView *)[(UIButton *)sender superview];
	[self animateTransitionToButton:selectedView forMenuItem:MenuItemFindings withDuration:kDurationButtonInward];
}

- (void)onMenuPolicies:(id)sender
{
	LOBMenuButtonView *selectedView = (LOBMenuButtonView *)[(UIButton *)sender superview];
	[self animateTransitionToButton:selectedView forMenuItem:MenuItemPolicies withDuration:kDurationButtonInward];
}

- (void)onSettingsButton
{
	[self animateTransitionToSettingsWithDuration:kDurationIrisOut];
	
}

#pragma mark - Orientation

//These methods are called from AppDelegate. Since this ViewController is added as a subview of UIWindow
//We don't get orientation callbacks.
//We need to implement them manually and rely on outside calls.
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self updateViewForOrientation:toInterfaceOrientation withAnimation:YES withDuration:duration];
}

- (void)updateViewForOrientation:(UIInterfaceOrientation)orientation withAnimation:(BOOL)animated withDuration:(NSTimeInterval)duration
{
	
	//Rotate the buttonContainer view so it remains in the center.
	CGFloat rotationAngle;
	switch (orientation)
	{
		case UIInterfaceOrientationPortrait:
			rotationAngle = 0;
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			rotationAngle = 180;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			rotationAngle = 270;
			break;
		case UIInterfaceOrientationLandscapeRight:
			rotationAngle = 90;
			break;
	}
	
	[UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.buttonContainer.transform = CGAffineTransformMakeRotation(DegreesToRadians(rotationAngle));
		self.bottomView.transform = CGAffineTransformMakeRotation(DegreesToRadians(rotationAngle));
		[self.bottomView setFrame:[self bottomViewEndPositionForOrientation:orientation]];
		
    }completion:^(BOOL finished){
        if (finished) {
			[self.view layoutIfNeeded];
        }
    }];
	
}

/**
 *	This will rotate a view depending on the orientation.
 *	When adding a view programmatically, the view is oriented
 *	based on a portrait orientation. This will simply check the
 *	interface orientation, and rotate the passed in view
 *	so that it is displayed in the correct orientation rather
 *	than the defaul portrait orientation
 *
 *	@param view The view to be rotated
 */
- (void)makeViewUpright:(UIView *)view
{
	switch (self.interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			view.transform = CGAffineTransformMakeRotation(M_PI);
			break;
		case UIInterfaceOrientationLandscapeLeft:
			view.transform = CGAffineTransformMakeRotation(-M_PI_2);
			break;
		case UIInterfaceOrientationLandscapeRight:
			view.transform = CGAffineTransformMakeRotation(M_PI_2);
			break;
			
		default:
			break;
	}
}


@end
