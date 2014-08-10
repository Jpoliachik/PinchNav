PinchNavigation
========
***v0.01***

A iOS navigation menu accessed by a `UIPinchGestureRecognizer`.
Pinch in to reveal a menu of customizable items and transition to
a different `UIViewController`.

![alt tag](https://raw.githubusercontent.com/Jpoliachik/PinchNav/master/pinchnavexample.gif)


Implementation
======
-   Download the project and copy `PinchNavigationViewController`
    and `PinchNavigationButtonView` files into your project.

-   `#include PinchNavigationViewController.h` where you would like
    to initialize it.

-   Create a `NSArray` of `PinchNavigationButtonView` items.

-   Initialize `PinchNavigationViewController` with the `UIView` the
    `UIPinchGestureRecognizer` should be attached to. If it is meant
    to be a globally accessed control, initialize it with UIWindow.

-   Implement the delegate method `shouldTransitionToButton:(PinchNavigationButtonView *)selectedButton`
    and swap view controllers here.

Example:
-   In `didFinishLaunchingWithOptions:`
```
    PinchNavigationButtonView *button1 = [[PinchNavigationButtonView alloc] initWithTitle:@"Feed" color:[UIColor colorWithRed:0.38 green:0.73 blue:0.82 alpha:1] diameter:80];
    PinchNavigationButtonView *button2 = [[PinchNavigationButtonView alloc] initWithTitle:@"Messages" color:[UIColor colorWithRed:0.96 green:0.77 blue:0.44 alpha:1] diameter:80];
    PinchNavigationButtonView *button3 = [[PinchNavigationButtonView alloc] initWithTitle:@"Images" color:[UIColor colorWithRed:0.66 green:0.73 blue:0.38 alpha:1] diameter:80];
    PinchNavigationButtonView *button4 = [[PinchNavigationButtonView alloc] initWithTitle:@"About" color:[UIColor colorWithRed:0.91 green:0.41 blue:0.48 alpha:1] diameter:80];
    PinchNavigationButtonView *button5 = [[PinchNavigationButtonView alloc] initWithTitle:@"Settings" color:[UIColor colorWithRed:0.65 green:0.52 blue:0.73 alpha:1] diameter:80];

    // assign the buttons tags so we can later tell which one is which
    button1.tag = 1;
    button2.tag = 2;
    button3.tag = 3;
    button4.tag = 4;
    button5.tag = 5;

    NSArray *buttonArray = @[button1, button2, button3, button4, button5];
    self.pinchNav = [[PinchNavigationViewController alloc] initWithGestureRecognizingView:self.window withButtonArray:buttonArray];
    self.pinchNav.delegate = self;
```
-   Transition delegate

```
- (void)shouldTransitionToButton:(PinchNavigationButtonView *)selectedButton
{
    // switch root view controllers
    // use the tag of the button to determine which was selected
    UIViewController *newRoot;
    switch (selectedButton.tag) {
        case 1:
            newRoot = [[OneViewController alloc] init];
            break;
        case 2:
            newRoot = [[TwoViewController alloc] init];
            break;
        case 3:
            newRoot = [[ThreeViewController alloc] init];
            break;
        case 4:
            newRoot = [[FourViewController alloc] init];
            break;
        case 5:
            newRoot = [[FiveViewController alloc] init];
            break;
        default:
            newRoot = self.window.rootViewController;
            break;
    }

    self.window.rootViewController = newRoot;
}
```

Future Improvements
==============
-   Allow fully custom `UIViews` for `PinchNavigationButtonViews`
-   Easy integration of icons in `PinchNavigationButtonViews`
-   Handle rotation properly
-   Additional animation types for button entry/exit
-   Separate 'Pinch Out' entry animation
-   Custom center point. Use for 'Pinch Out' location
-   Allow other custom gestures or input for startup animation

About
========
- Design by [Mitch Pruitt](https://github.com/mitchpruitt)
- Under Apache license. See LICENSE file for more information.
