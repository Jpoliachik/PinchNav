//
//  PinchNavigationViewController.m
//  
//
//  Created by Justin Poliachik on 7/30/14.
//
//

#import "PinchNavigationViewController.h"

@interface PinchNavigationViewController ()
@property (nonatomic, strong) UIView *irisView;
@property (nonatomic, strong) UIView *superViewReference;
@end

@implementation PinchNavigationViewController

- (instancetype)initWithSuperview:(UIView *)superView
{
    self = [super init];
    if (self) {
        
        // assign the pinch gesture to the superview
        if(superView) {
            self.superViewReference = superView;
        
            UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinch:)];
            
            [superView addGestureRecognizer:pinchGesture];
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onPinch:(UIPinchGestureRecognizer *)gesture
{
    if(gesture.scale < 1.0f){
        
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
        }
    }
    
    if(gesture.state == UIGestureRecognizerStateEnded && self.irisView){
        [self.irisView removeFromSuperview];
        self.irisView = nil;
    }

    NSLog(@"Pinch: %f", gesture.scale);
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
