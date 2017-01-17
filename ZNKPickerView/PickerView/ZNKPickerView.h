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

extern NSString * const ZNKPickerViewData;
extern NSString * const ZNKCoverViewAlpha;
extern NSString * const ZNKsheetViewViewBackgroundColor;
extern NSString * const ZNKsuviewsbackgroundColor;
extern NSString * const ZNKtoolbarColor;
extern NSString * const ZNKcomfirmButtonColor;
extern NSString * const ZNKConfirmButtonTitle;
extern NSString * const ZNKDefaultSelectedObject;
extern NSString * const ZNKtextAlignment;
extern NSString * const ZNKshowsSelectionIndicator;
extern NSString * const ZNKpickerViewTitleColor;
extern NSString * const ZNKpickerViewFont;
extern NSString * const ZNKpickerViewCancelTitle;
extern NSString * const ZNKdefaultTableRowHeight;
extern NSString * const ZNKleftInputViewTitle;
extern NSString * const ZNKDatePickerDefaultDate;

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
