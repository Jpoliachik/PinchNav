//
//  PinchNavButtonView.h
//  
//
//  Created by Justin Poliachik on 7/14/14.
//
//

#import <UIKit/UIKit.h>

@interface PinchNavButtonView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic) BOOL shouldAnimateOnPress;

- (instancetype)initWithTitle:(NSString *)title color:(UIColor *)color diameter:(CGFloat)diameter;
- (instancetype)initWithIcon:(UIImage *)icon color:(UIColor *)color diameter:(CGFloat)diameter;
- (instancetype)initWithTitle:(NSString *)title andIcon:(UIImage *)icon titleOnTop:(BOOL)isTitleOnTop color:(UIColor *)color diameter:(CGFloat)diameter;
- (instancetype)initWithCustomView:(UIView *)view;

@end
