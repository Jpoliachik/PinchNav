//
//  PinchNavigationButtonView.h
//  
//
//  Created by Justin Poliachik on 7/30/14.
//
//

#import <UIKit/UIKit.h>

@class PinchNavigationButtonView;
@protocol PinchNavigationButtonDelegate <NSObject>

- (void)didSelectNavigationButton:(PinchNavigationButtonView *)selectedButton;

@end

@interface PinchNavigationButtonView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic) BOOL shouldAnimateOnPress;
@property (nonatomic, strong) UIColor *fillColor;

@property (nonatomic, weak) id<PinchNavigationButtonDelegate> delegate;

- (instancetype)initWithTitle:(NSString *)title color:(UIColor *)color diameter:(CGFloat)diameter;

@end
