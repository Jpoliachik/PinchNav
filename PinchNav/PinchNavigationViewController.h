//
//  PinchNavigationViewController.h
//  
//
//  Created by Justin Poliachik on 7/30/14.
//
//

#import <UIKit/UIKit.h>
#import "PinchNavigationButtonView.h"

typedef enum PNavState{
    PNavStateClosed,                            // sleep state. nothing in self.view
    PNavStatePinching,                          // user is currently pinching inwards
    PNavStateAnimatingIrisOut,                  // pinch ended, animating back out to cancel
    PNavStateAnimatingIrisIn,                   // pinch ended, animating iris inwards
    PNavStateAnimatingButtonsOutFromCenter,     // buttons fade in and animate in out from center
    PNavStateButtonSelection,                   // rest state. awaiting user interaction
    PNavStateAnimatingButtonsOutAndClose,       // user cancelled from button selection state. animate buttons further outwards and fade out
    PNavStateAnimatingSelectedButtonIn,         // user selected button animates back to center with the rest
    PNavStateAnimatingSelectedIrisOut,          // with selected button on top, animate an iris of that color outwards to fill the screen
    PNavStateTransitionPeriod,                  // colored iris fills the screen. wait to give time for view switch behind the menu
    PNavStateFadeOutAndClose                    // fade colored view out to reveal new view
}PNavState;

@protocol PinchNavigationDelegate <NSObject>
- (void)shouldTransitionToButton:(PinchNavigationButtonView *)selectedButton;
@end

@interface PinchNavigationViewController : UIViewController <PinchNavigationButtonDelegate>

@property (nonatomic, readonly) PNavState state;

@property (nonatomic, assign) CGFloat durationAnimatingIrisIn;  // time to animate from fully open to fully closed.
@property (nonatomic, assign) CGFloat durationAnimatingIrisOut;
@property (nonatomic, assign) CGFloat durationAnimatingButtonsOutFromCenter;
@property (nonatomic, assign) CGFloat durationAnimatingButtonsOutAndClose;
@property (nonatomic, assign) CGFloat durationAnimatingSelectedButtonIn;
@property (nonatomic, assign) CGFloat durationAnimatingSelectedIrisOut;
@property (nonatomic, assign) CGFloat durationTransitionPeriod;
@property (nonatomic, assign) CGFloat durationAnimatingFadeOutAndClose;

@property (nonatomic, assign) CGFloat pinchInCutoffPoint;       // where iris switches from pinch scaling to animation scaling. value between 1.0 and 0.01
@property (nonatomic, assign) CGFloat pinchEndedCutoffPoint;    // on pinch ended, when to animate in vs out. value between 1.0 and 0.01

@property (nonatomic, assign) CGFloat buttonDistanceFromCenter;

@property (nonatomic, strong) UIColor *irisColor;
@property (nonatomic, assign) CGFloat irisAlpha;

@property (nonatomic, assign) CGFloat cornerPadding;

@property (nonatomic, weak) id<PinchNavigationDelegate> delegate;

@property (nonatomic, assign) BOOL enabled;

@property (nonatomic, strong) PinchNavigationButtonView *bottomRightButton;


- (instancetype)initWithGestureRecognizingView:(UIView *)gestureView withButtonArray:(NSArray *)buttonArray;

@end
