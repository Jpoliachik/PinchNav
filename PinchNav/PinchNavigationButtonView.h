//
//  PinchNavigationButtonView.h
//  
//
//  Created by Justin Poliachik on 7/30/14.
//
//

#import <UIKit/UIKit.h>

@interface PinchNavigationButtonView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic) BOOL shouldAnimateOnPress;

- (instancetype)initWithTitle:(NSString *)title color:(UIColor *)color diameter:(CGFloat)diameter;

@end
