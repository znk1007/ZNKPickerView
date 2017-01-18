//
//  ZNKPickerView.h
//  EnjoyLove
//
//  Created by HuangSam on 2017/1/12.
//  Copyright © 2017年 HuangSam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ZNKPickerView)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

@end

@interface KeyboardManager : NSObject


- (instancetype)initWithTargetView:(UIView *)targetView containerView:(UIView *)containView hasNav:(BOOL)has contentOffset:(CGFloat)offset showBlock:(void(^)(CGRect keyboardFrame, NSNotification *notification))show hideBlock:(void(^)(CGRect keyboardFrame, NSNotification *notification))hide;

@end

extern NSString * const ZNKToolbarTitle;
extern NSString * const ZNKToolbarMessage;
extern NSString * const ZNKCoverViewAlpha;
extern NSString * const ZNKSheetViewBackgroundColor;
extern NSString * const ZNKSheetViewBackgroundImage;
extern NSString * const ZNKPickerViewBackgroundColor;
extern NSString * const ZNKPickerViewBackgroundImage;
extern NSString * const ZNKPickerViewFont;
extern NSString * const ZNKSheetViewCancelTitle;
extern NSString * const ZNKCanScroll;
extern NSString * const ZNKVerticalScrollIndicator;
extern NSString * const ZNKTextAlignment;
extern NSString * const ZNKPickerViewData;
extern NSString * const ZNKDefaultSelectedObject;
extern NSString * const ZNKDefaultHasNavigationBar;
extern NSString * const ZNKToolbarBackgroundColor;
extern NSString * const ZNKToolbarHasInput;
extern NSString * const ZNKToolbarInputLeftView;
extern NSString * const ZNKToolbarInputPlachodler;
extern NSString * const ZNKToolbarBackgroundImage;
extern NSString * const ZNKConfirmButtonTitle;
extern NSString * const ZNKConfirmButtonTitleColor;
extern NSString * const ZNKCanScroll;
extern NSString * const ZNKTableRowHeight;
extern NSString * const ZNKTextAlignment;
extern NSString * const ZNKShowsSelectionIndicator;
extern NSString * const ZNKPickerViewTitleColor;


typedef enum : NSUInteger {
    ZNKPickerTypeDateMode,
    ZNKPickerTypeTimeMode,
    ZNKPickerTypeDateTimeMode,
    ZNKPickerTypeYearMonthMode,
    ZNKPickerTypeMonthDayMode,
    ZNKPickerTypeHourMinuteMode,
    ZNKPickerTypeDateHourMinuteMode,
    ZNKPickerTypeObject,
    ZNKPickerTypeActionSheet,
    ZNKPickerTypeActionAlert,
} ZNKPickerType;


@interface ZNKPickerView : UIView
/**输入文本*/
@property (nonatomic, readonly) NSString *inputResult;
/**选择结果*/
@property (nonatomic, readonly) id result;
/**选中的下标*/
@property (nonatomic, readonly) NSInteger index;

+ (void)showInView:(UIView *)view pickerType:(ZNKPickerType)type options:(NSDictionary *)options objectToStringConverter:(NSString *(^)(id))converter  realTimeResult:(void(^)(ZNKPickerView *pickerView))realTimeResult completionHandler:(void(^)(ZNKPickerView *pickerView))completionHandler;


@end
