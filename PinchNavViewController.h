//
//  PinchNavViewController.h
//  
//
//  Created by Justin Poliachik on 7/14/14.
//
//

#import <UIKit/UIKit.h>

@interface PinchNavViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *bottomContainer;
@property (nonatomic, strong) UIView *topContainer;

@end
