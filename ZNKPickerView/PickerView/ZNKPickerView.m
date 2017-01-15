//
//  ZNKPickerView.m
//  EnjoyLove
//
//  Created by HuangSam on 2017/1/12.
//  Copyright © 2017年 HuangSam. All rights reserved.
//

#import "ZNKPickerView.h"
#define kScreen_Height [UIScreen mainScreen].bounds.size.height
#define kScreen_Width [UIScreen mainScreen].bounds.size.width
#define kScaleFrom_iPhone5_Desgin(_X_) (_X_ * (CGRectGetWidth(self.datePickerContainerView.frame)/320))
#define kTopViewHeight kScaleFrom_iPhone5_Desgin(44)
#define kTimeBroadcastViewHeight kScaleFrom_iPhone5_Desgin(200)
#define kDatePickerHeight (0 + CGRectGetHeight(self.datePickerContainerView.frame))
#define kOKBtnTag 101
#define kCancleBtnTag 100

@interface KeyboardManager ()

@property (nonatomic, strong) UIView *targetView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, assign) CGRect targetViewOriginFrame;
@property (nonatomic, assign) CGRect containerViewOriginFrame;
@property (nonatomic, assign) CGFloat contentOffset;
@property (nonatomic, assign) BOOL hasNav;
@property (nonatomic, copy) void(^keyboardShowHandler)(CGRect keyboardFrame, NSNotification *notification);
@property (nonatomic, copy) void(^keyboardHideHandler)(CGRect keyboardFrame, NSNotification *notification);

@end

@implementation KeyboardManager

- (void)dealloc{
    self.keyboardShowHandler = nil;
    self.keyboardHideHandler = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithTargetView:(UIView *)targetView containerView:(UIView *)containView hasNav:(BOOL)has contentOffset:(CGFloat)offset showBlock:(void(^)(CGRect keyboardFrame, NSNotification *notification))show hideBlock:(void(^)(CGRect keyboardFrame, NSNotification *notification))hide{
    self = [super init];
    if (self) {
        if (!targetView || !containView) {
            self.targetView = [[UIView alloc] init];
            self.containerView = [[UIView alloc] init];
        }
        self.targetView = targetView;
        self.targetViewOriginFrame = self.targetView.frame;
        self.containerView = containView;
        self.containerViewOriginFrame = self.containerView.frame;
        self.keyboardHideHandler = hide;
        self.keyboardShowHandler = show;
        self.contentOffset = offset;
        self.hasNav = has;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShowNotification:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)keyboardShowNotification:(NSNotification *)note{
    CGRect keyboardFrame = CGRectZero;
    NSDictionary *userInfo = note.userInfo;
    keyboardFrame = ((NSValue *)userInfo[UIKeyboardFrameEndUserInfoKey]).CGRectValue;
    NSNumber *durationNumber = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curveNumber = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    [UIView animateWithDuration:durationNumber.doubleValue delay:0 options:curveNumber.unsignedIntegerValue animations:^{
        
        CGFloat navHeight = self.hasNav == YES ? 64 : 0;
        CGFloat keyboardMinY = kScreen_Height - CGRectGetHeight(keyboardFrame);
        CGFloat targetMinY = CGRectGetMinY(self.containerView.frame) - navHeight + CGRectGetMinY(self.targetView.frame);
        CGFloat targetMaxY = CGRectGetMinY(self.containerView.frame) - navHeight + CGRectGetMaxY(self.targetView.frame) + self.contentOffset;
        if (targetMaxY > keyboardMinY) {
            CGFloat viewKeyboardDistance = targetMinY - keyboardMinY;
            CGFloat resultDistance = CGRectGetHeight(self.targetView.frame) + viewKeyboardDistance + self.contentOffset + navHeight;
            self.containerView.frame = CGRectMake(CGRectGetMinX(self.containerView.frame), CGRectGetMinY(self.containerView.frame) - resultDistance, CGRectGetWidth(self.containerView.frame), CGRectGetHeight(self.containerView.frame));
        }else{
//            self.containerView.frame = self.containerViewOriginFrame;
            self.containerView.frame = CGRectMake(CGRectGetMinX(self.containerView.frame), CGRectGetMinY(self.containerView.frame), CGRectGetWidth(self.containerView.frame), CGRectGetHeight(self.containerView.frame));
        }
        
        CGFloat between = [UIScreen mainScreen].bounds.size.height - CGRectGetMaxY(self.targetView.frame);
        if (between < keyboardFrame.size.height + self.contentOffset) {
            self.containerView.frame = CGRectMake(0, between - (keyboardFrame.size.height  + self.contentOffset), CGRectGetWidth(self.containerView.frame), CGRectGetHeight(self.containerView.frame));
            if (_keyboardShowHandler) {
                _keyboardShowHandler(keyboardFrame, note);
            }
        }
    } completion:nil];
}

- (void)keyboardHideNotification:(NSNotification *)note{
    CGRect keyboardFrame = CGRectZero;
    NSDictionary *userInfo = note.userInfo;
    keyboardFrame = ((NSValue *)userInfo[UIKeyboardFrameEndUserInfoKey]).CGRectValue;
    NSNumber *durationNumber = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curveNumber = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    [UIView animateWithDuration:durationNumber.doubleValue delay:0 options:curveNumber.unsignedIntegerValue animations:^{
        self.containerView.frame = self.containerViewOriginFrame;
        self.targetView.frame = self.targetViewOriginFrame;
        if (_keyboardHideHandler) {
            _keyboardHideHandler(CGRectZero, note);
        }
    } completion:nil];
}

@end

@interface MyTextField :UITextField

@property (nonatomic, assign) CGFloat padding;

- (instancetype)initWithFrame:(CGRect)frame padding:(CGFloat)padding;

@end

@implementation MyTextField

- (instancetype)initWithFrame:(CGRect)frame padding:(CGFloat)padding{
    self = [super initWithFrame:frame];
    if (self) {
        self.padding = padding;
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds{
    return CGRectMake(self.padding, CGRectGetMinY(bounds), CGRectGetWidth(bounds), CGRectGetHeight(bounds));
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds{
    return CGRectMake(self.padding, CGRectGetMinY(bounds), CGRectGetWidth(bounds), CGRectGetHeight(bounds));
}

- (CGRect)editingRectForBounds:(CGRect)bounds{
    return CGRectMake(self.padding, CGRectGetMinY(bounds), CGRectGetWidth(bounds), CGRectGetHeight(bounds));
}

@end

@interface UIColor (ZNKPicker)

@property (nonatomic, readonly) CGColorSpaceModel colorSpaceModel;
@property (nonatomic, readonly) BOOL canProvideRGBComponents;
@property (nonatomic, readonly) CGFloat red; // Only valid if canProvideRGBComponents is YES
@property (nonatomic, readonly) CGFloat green; // Only valid if canProvideRGBComponents is YES
@property (nonatomic, readonly) CGFloat blue; // Only valid if canProvideRGBComponents is YES
@property (nonatomic, readonly) CGFloat white; // Only valid if colorSpaceModel == kCGColorSpaceModelMonochrome
@property (nonatomic, readonly) CGFloat alpha;
@property (nonatomic, readonly) UInt32 rgbHex;

+ (UIColor *)colorWithRGBHex:(UInt32)hex;
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert andAlpha:(CGFloat)alpha;

+ (UIColor *)colorFromHexString:(NSString *)hexString;

+ (UIColor*)colorFromRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue;

+ (UIColor*)colorFromRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(CGFloat)alpha;

@end

@implementation UIColor (ZNKPicker)

+ (UIColor *)colorFromHexString:(NSString *)hexString{
    NSString *cString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) {
        cString = [cString substringFromIndex:2];
    }
    if ([cString hasPrefix:@"#"]) {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6) {
        return  [UIColor grayColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
    
}

+ (UIColor*)colorFromRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue{
    return [UIColor colorWithRed:(red / 255.0) green:(green / 255.0) blue:(blue/255.0) alpha:1.0];
}

+ (UIColor*)colorFromRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:(red / 255.0) green:(green / 255.0) blue:(blue/255.0) alpha:alpha];
}

- (CGColorSpaceModel)colorSpaceModel {
    return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

- (BOOL)canProvideRGBComponents {
    switch (self.colorSpaceModel) {
        case kCGColorSpaceModelRGB:
        case kCGColorSpaceModelMonochrome:
            return YES;
        default:
            return NO;
    }
}

- (CGFloat)red {
    NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -red");
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    return c[0];
}

- (CGFloat)green {
    NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -green");
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    if (self.colorSpaceModel == kCGColorSpaceModelMonochrome) return c[0];
    return c[1];
}

- (CGFloat)blue {
    NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -blue");
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    if (self.colorSpaceModel == kCGColorSpaceModelMonochrome) return c[0];
    return c[2];
}

- (CGFloat)white {
    NSAssert(self.colorSpaceModel == kCGColorSpaceModelMonochrome, @"Must be a Monochrome color to use -white");
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    return c[0];
}

- (CGFloat)alpha {
    return CGColorGetAlpha(self.CGColor);
}

- (UInt32)rgbHex {
    NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use rgbHex");
    
    CGFloat r,g,b,a;
    if (![self red:&r green:&g blue:&b alpha:&a]) return 0;
    
    r = MIN(MAX(self.red, 0.0f), 1.0f);
    g = MIN(MAX(self.green, 0.0f), 1.0f);
    b = MIN(MAX(self.blue, 0.0f), 1.0f);
    
    return (((int)roundf(r * 255)) << 16)
    | (((int)roundf(g * 255)) << 8)
    | (((int)roundf(b * 255)));
}

- (BOOL)red:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha {
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    
    CGFloat r,g,b,a;
    
    switch (self.colorSpaceModel) {
        case kCGColorSpaceModelMonochrome:
            r = g = b = components[0];
            a = components[1];
            break;
        case kCGColorSpaceModelRGB:
            r = components[0];
            g = components[1];
            b = components[2];
            a = components[3];
            break;
        default:	// We don't know how to handle this model
            return NO;
    }
    
    if (red) *red = r;
    if (green) *green = g;
    if (blue) *blue = b;
    if (alpha) *alpha = a;
    
    return YES;
}


+ (UIColor *)colorWithRGBHex:(UInt32)hex {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:1.0f];
}

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert {
    NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
    unsigned hexNum;
    if (![scanner scanHexInt:&hexNum]) return nil;
    return [UIColor colorWithRGBHex:hexNum];
}
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert andAlpha:(CGFloat)alpha{
    UIColor *color = [UIColor colorWithHexString:stringToConvert];
    return [UIColor colorWithRed:color.red green:color.green blue:color.blue alpha:alpha];
}

@end

@protocol ZNKCycleScrollViewDatasource;
@protocol ZNKCycleScrollViewDelegate;

@interface ZNKCycleScrollView : UIView<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    
    NSInteger _totalPages;
    NSInteger _curPage;
    
    NSMutableArray *_curViews;
}

@property (nonatomic,readonly) UIScrollView *scrollView;
@property (nonatomic,assign) NSInteger currentPage;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *farTextColor;
@property (nonatomic, strong) UIColor *nearTextColor;
@property (nonatomic,assign,setter = setDataource:) id<ZNKCycleScrollViewDatasource> datasource;
@property (nonatomic,assign,setter = setDelegate:) id<ZNKCycleScrollViewDelegate> delegate;

- (void)setCurrentSelectPage:(NSInteger)selectPage; //设置初始化页数
- (void)reloadData;
- (void)setViewContent:(UIView *)view atIndex:(NSInteger)index;
@end

@protocol ZNKCycleScrollViewDelegate <NSObject>

@optional
- (void)didClickPage:(ZNKCycleScrollView *)csView atIndex:(NSInteger)index;
- (void)scrollviewDidChangeNumber;

@end

@protocol ZNKCycleScrollViewDatasource <NSObject>

@required
- (NSInteger)numberOfPages:(ZNKCycleScrollView*)scrollView;
- (UIView *)pageAtIndex:(NSInteger)index andScrollView:(ZNKCycleScrollView*)scrollView;

@end

@implementation ZNKCycleScrollView

@synthesize scrollView = _scrollView;
@synthesize currentPage = _curPage;
@synthesize datasource = _datasource;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width, (self.bounds.size.height/5)*7);
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.contentOffset = CGPointMake(0, (self.bounds.size.height/5));
        
        [self addSubview:_scrollView];
    }
    return self;
}
//设置初始化页数
- (void)setCurrentSelectPage:(NSInteger)selectPage
{
    _curPage = selectPage;
}

- (void)setDataource:(id<ZNKCycleScrollViewDatasource>)datasource
{
    _datasource = datasource;
    [self reloadData];
}

- (void)reloadData
{
    _totalPages = [_datasource numberOfPages:self];
    if (_totalPages == 0) {
        return;
    }
    [self loadData];
}

- (void)loadData
{
    //从scrollView上移除所有的subview
    NSArray *subViews = [_scrollView subviews];
    if([subViews count] != 0) {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [self getDisplayImagesWithCurpage:_curPage];
    
    for (int i = 0; i < 7; i++) {
        UIView *v = [_curViews objectAtIndex:i];
        //        v.userInteractionEnabled = YES;
        //        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
        //                                                                                    action:@selector(handleTap:)];
        //        [v addGestureRecognizer:singleTap];
        v.frame = CGRectOffset(v.frame, 0, v.frame.size.height * i );
        [_scrollView addSubview:v];
    }
    
    [_scrollView setContentOffset:CGPointMake( 0, (self.bounds.size.height/5) )];
}

- (void)getDisplayImagesWithCurpage:(NSInteger)page {
    NSInteger pre1 = [self validPageValue:_curPage-1];
    NSInteger pre2 = [self validPageValue:_curPage];
    NSInteger pre3 = [self validPageValue:_curPage+1];
    NSInteger pre4 = [self validPageValue:_curPage+2];
    NSInteger pre5 = [self validPageValue:_curPage+3];
    NSInteger pre = [self validPageValue:_curPage+4];
    NSInteger last = [self validPageValue:_curPage+5];
    
    if (!_curViews) {
        _curViews = [[NSMutableArray alloc] init];
    }
    
    [_curViews removeAllObjects];
    
    [_curViews addObject:[_datasource pageAtIndex:pre1 andScrollView:self]];
    [_curViews addObject:[_datasource pageAtIndex:pre2 andScrollView:self]];
    [_curViews addObject:[_datasource pageAtIndex:pre3 andScrollView:self]];
    [_curViews addObject:[_datasource pageAtIndex:pre4 andScrollView:self]];
    [_curViews addObject:[_datasource pageAtIndex:pre5 andScrollView:self]];
    [_curViews addObject:[_datasource pageAtIndex:pre andScrollView:self]];
    [_curViews addObject:[_datasource pageAtIndex:last andScrollView:self]];
}

- (NSInteger)validPageValue:(NSInteger)value {
    
    if(value < 0 ) value = _totalPages + value;
    if(value == _totalPages+1) value = 1;
    if (value == _totalPages+2) value = 2;
    if(value == _totalPages+3) value = 3;
    if (value == _totalPages+4) value = 4;
    if(value == _totalPages) value = 0;
    
    
    return value;
    
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    
    if ([_delegate respondsToSelector:@selector(didClickPage:atIndex:)]) {
        [_delegate didClickPage:self atIndex:_curPage];
    }
    
}

- (void)setViewContent:(UIView *)view atIndex:(NSInteger)index
{
    if (index == _curPage) {
        [_curViews replaceObjectAtIndex:1 withObject:view];
        for (int i = 0; i < 7; i++) {
            UIView *v = [_curViews objectAtIndex:i];
            v.userInteractionEnabled = YES;
            //            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
            //                                                                                        action:@selector(handleTap:)];
            //            [v addGestureRecognizer:singleTap];
            v.frame = CGRectOffset(v.frame, 0, v.frame.size.height * i);
            [_scrollView addSubview:v];
        }
    }
}

- (void)setAfterScrollShowView:(UIScrollView*)scrollview  andCurrentPage:(NSInteger)pageNumber
{
    UILabel *oneLabel = (UILabel*)[[scrollview subviews] objectAtIndex:pageNumber];
    [oneLabel setFont:[UIFont systemFontOfSize:14]];
    if (_farTextColor) {
        [oneLabel setTextColor:_farTextColor];
    }else{
        [oneLabel setTextColor:[UIColor colorFromHexString:@"#F4CDD6"]];
    }
    UILabel *twoLabel = (UILabel*)[[scrollview subviews] objectAtIndex:pageNumber+1];
    [twoLabel setFont:[UIFont systemFontOfSize:16]];
    if (_nearTextColor) {
        [twoLabel setTextColor:_nearTextColor];
    }else{
        [twoLabel setTextColor:[UIColor colorFromHexString:@"#EDB2C0"]];
    }
    
    UILabel *currentLabel = (UILabel*)[[scrollview subviews] objectAtIndex:pageNumber+2];
    [currentLabel setFont:[UIFont systemFontOfSize:18]];
    if (_textColor) {
        [currentLabel setTextColor:_textColor];
    }else{
        [currentLabel setTextColor:[UIColor colorFromHexString:@"#B95561"]];
    }
    
    UILabel *threeLabel = (UILabel*)[[scrollview subviews] objectAtIndex:pageNumber+3];
    [threeLabel setFont:[UIFont systemFontOfSize:16]];
    if (_nearTextColor) {
        [threeLabel setTextColor:_nearTextColor];
    }else{
        [threeLabel setTextColor:[UIColor colorFromHexString:@"#EDB2C0"]];
    }
    UILabel *fourLabel = (UILabel*)[[scrollview subviews] objectAtIndex:pageNumber+4];
    [fourLabel setFont:[UIFont systemFontOfSize:14]];
    if (_farTextColor) {
        [fourLabel setTextColor:_farTextColor];
    }else{
        [fourLabel setTextColor:[UIColor colorFromHexString:@"#F4CDD6"]];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    int y = aScrollView.contentOffset.y;
    NSInteger page = aScrollView.contentOffset.y/((self.bounds.size.height/5));
    
    if (y>2*(self.bounds.size.height/5)) {
        _curPage = [self validPageValue:_curPage+1];
        [self loadData];
    }
    if (y<=0) {
        _curPage = [self validPageValue:_curPage-1];
        [self loadData];
    }
    //    //往下翻一张
    //    if(x >= (4*self.frame.size.width)) {
    //        _curPage = [self validPageValue:_curPage+1];
    //        [self loadData];
    //    }
    //
    //    //往上翻
    //    if(x <= 0) {
    //
    //    }
    if (page>1 || page <=0) {
        [self setAfterScrollShowView:aScrollView andCurrentPage:1];
    }
    if ([_delegate respondsToSelector:@selector(scrollviewDidChangeNumber)]) {
        [_delegate scrollviewDidChangeNumber];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self setAfterScrollShowView:scrollView andCurrentPage:1];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_scrollView setContentOffset:CGPointMake(0, (self.bounds.size.height/5)) animated:YES];
    [self setAfterScrollShowView:scrollView andCurrentPage:1];
    if ([_delegate respondsToSelector:@selector(scrollviewDidChangeNumber)]) {
        [_delegate scrollviewDidChangeNumber];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self setAfterScrollShowView:scrollView andCurrentPage:1];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [_scrollView setContentOffset:CGPointMake(0, (self.bounds.size.height/5)) animated:YES];
    [self setAfterScrollShowView:scrollView andCurrentPage:1];
    if ([_delegate respondsToSelector:@selector(scrollviewDidChangeNumber)]) {
        [_delegate scrollviewDidChangeNumber];
    }
}

@end

NSString * const ZNKsuviewsbackgroundColor = @"ZNKsuviewsbackgroundColor";
NSString * const ZNKtoolbarColor = @"ZNKtoolbarColor";
NSString * const ZNKcomfirmButtonColor = @"ZNKcomfirmButtonColor";
NSString * const ZNKconfirmButtonTitle = @"ZNKconfirmButtonTitle";
NSString * const ZNKselectedObject = @"selectedObject";
NSString * const ZNKtoolbarBackgroundImage = @"toolbarBackgroundImage";
NSString * const ZNKtextAlignment = @"textAlignment";
NSString * const ZNKshowsSelectionIndicator = @"showsSelectionIndicator";
NSString * const ZNKpickerViewTitleColor = @"ZNKpickerViewTitleColor";
NSString * const ZNKpickerViewFont = @"ZNKpickerViewFont";
NSString * const ZNKpickerViewCancelTitle = @"ZNKpickerViewCancelTitle";
NSString * const ZNKsheetViewViewBackgroundColor = @"ZNKsheetViewViewBackgroundColor";
NSString * const ZNKleftInputViewTitle = @"ZNKleftInputViewTitle";
NSString * const ZNKdefaultDate = @"ZNKdefaultDate";
NSString * const ZNKdefaultTableRowHeight = @"ZNKdefaultTableRowHeight";
NSString * const ZNKcoverViewAlpha = @"ZNKcoverViewAlpha";
NSString * const ZNKcanScroll = @"ZNKcanScroll";


#define znk_screenWidth [UIScreen mainScreen].bounds.size.width
#define znk_screenHeight [UIScreen mainScreen].bounds.size.height


/** 取消按钮到other按钮之间的间距 */
static CGFloat const margin_cancelButton_to_otherButton = 5;

/** 底部View弹出的时间 */
static CGFloat const SheetViewAnimationDuration = 0.25;

/**工具栏高度*/
static CGFloat const pickerViewToolbarHeight = 44;
/**选择器高度*/
static CGFloat const sheetViewHeight = 216;


@interface ZNKPickerView ()<UIPickerViewDelegate, UIPickerViewDataSource,ZNKCycleScrollViewDatasource,ZNKCycleScrollViewDelegate, UITextFieldDelegate, UITableViewDelegate,UITableViewDataSource>

/** 选择器类型*/
@property (nonatomic, assign) ZNKPickerType type;
/**主视图*/
@property (nonatomic, strong) UIView *mainView;
/**遮罩*/
@property (nonatomic, strong) UIButton *coverView;
/** 中间 底部弹出视图 */
@property (nonatomic, strong) UIView *sheetView;
/**遮罩透明度*/
@property (nonatomic, assign) CGFloat coverViewAlpha;

#pragma mark - date picker
/**日期字符串*/
@property (nonatomic, strong) NSString *dateTimeStr;
/**年份滚动视图*/
@property (nonatomic, strong) ZNKCycleScrollView *yearScrollView;
/**月份滚动视图*/
@property (nonatomic, strong) ZNKCycleScrollView *monthScrollView;
/**日份滚动视图*/
@property (nonatomic, strong) ZNKCycleScrollView *dayScrollView;
/**时份滚动视图*/
@property (nonatomic, strong) ZNKCycleScrollView *hourScrollView;
/**年份滚动视图*/
@property (nonatomic, strong) ZNKCycleScrollView *minuteScrollView;
/**年份滚动视图*/
@property (nonatomic, strong) ZNKCycleScrollView *secondScrollView;
/**当前年*/
@property (nonatomic, assign) NSInteger curYear;
/**当前月*/
@property (nonatomic, assign) NSInteger curMonth;
/**当前日*/
@property (nonatomic, assign) NSInteger curDay;
/**当前小时*/
@property (nonatomic, assign) NSInteger curHour;
/**当前分*/
@property (nonatomic, assign) NSInteger curMin;
/**当前秒*/
@property (nonatomic, assign) NSInteger curSecond;
/**默认日期*/
@property (nonatomic, strong) NSDate *defaultDate;
/**日期选择器容器*/
@property (nonatomic, strong) UIView *datePickerContainerView;
/**日期分割*/
@property (nonatomic, strong) UILabel *dateSepratorLabel;


/**文本输入框*/
@property (nonatomic, strong) MyTextField *inputTextField;
/**是否有输入框*/
@property (nonatomic, assign) BOOL hasInput;
/**输入内容*/
@property (nonatomic, strong) NSString *inputString;
/**键盘管理*/
@property (nonatomic, strong) KeyboardManager *keyboard;

/** 其他按钮表格 */
@property (nonatomic, strong) UITableView *tableView;
/**确定按钮*/
@property (nonatomic, strong) UIButton *confirmButton;
/** 取消按钮 */
@property (nonatomic, strong) UIButton *cancelButton;
/**配置项*/
@property (nonatomic, strong) NSDictionary *options;
/**选择项*/
@property (nonatomic, strong) NSArray *pickerViewArray;
/**选择键*/
@property (nonatomic, strong) NSArray *pickerViewKeys;
/**选择字典*/
@property (nonatomic, strong) NSDictionary *pickerViewDict;
/**
 数组或字典
 数组 1  字典 2
 */
@property (nonatomic, assign) NSInteger pickerClass;

/**提示title*/
@property (nonatomic, copy) NSString *title;
/**提示titleLabel*/
@property (nonatomic, strong) UILabel *titleLabel;
/**提示内容*/
@property (nonatomic, copy) NSString *message;
/**提示内容Label*/
@property (nonatomic, strong) UILabel *messageLabel;
/**工具栏容器*/
@property (nonatomic, strong) UIView *toolbarContainerView;
/**工具栏*/
@property (nonatomic, strong) UIToolbar *pickerToolbar;
/**转换*/
@property (nonatomic, copy) NSString *(^objectToStringConverter)(id object);
/**选择器*/
@property (nonatomic, strong) UIPickerView *pickerView;
/**选择器高度*/
@property (nonatomic, assign) CGFloat pickerViewHeight;
/**选择器y坐标*/
@property (nonatomic, assign) CGFloat pickerViewMinY;
/**文字停靠*/
@property (nonatomic, assign) NSInteger pickerViewTextAlignment;
/**文字颜色*/
@property (nonatomic, strong) UIColor *pickerViewTextColor;
/**总视图背景颜色*/
@property (nonatomic, strong) UIColor *pickerViewBackgroundColor;
/**sheet背景颜色*/
@property (nonatomic, strong) UIColor *sheetViewBackgroundColor;
/**显示字体*/
@property (nonatomic, strong) UIFont *pickerViewFont;
/**选中对象*/
@property (nonatomic, strong) id selectedObject;
/**选中下标*/
@property (nonatomic, assign) NSInteger selectedIndex;
/**是否*/
@property (nonatomic, assign) BOOL pickerViewShowsSelectionIndicator;
/**最大年份*/
@property (nonatomic,assign) NSInteger maxYear;
/**最小年份*/
@property (nonatomic,assign) NSInteger minYear;
/**标题颜色*/
@property (nonatomic,strong) UIColor *titleColor;
/**选择部分颜色*/
@property (nonatomic, strong) UIColor *textColor;
/**远离选中部分颜色*/
@property (nonatomic, strong) UIColor *farTextColor;
/**靠近选择部分颜色*/
@property (nonatomic, strong) UIColor *nearTextColor;
/**提示标题frame*/
@property (nonatomic, assign) CGRect titleRect;
/**提示内容frame*/
@property (nonatomic, assign) CGRect messageRect;
/**表格高度*/
@property (nonatomic, assign) CGFloat tableViewRowHeight;
/**总试图高度*/
@property (nonatomic, assign) CGFloat totalViewHeight;

/**选中结果*/
@property (nonatomic, strong) id result;
/**实时回调*/
@property (nonatomic, copy) void(^ZNKPickertViewResult)(ZNKPickerView *pickerView,NSString *input, NSInteger index, NSObject *obj);
/**点击确定时候的回调*/
@property (nonatomic, copy) void(^ZNKPickertViewConfirmResult)(ZNKPickerView *pickerView,NSString *input, NSInteger index, NSObject *obj);

@end

@implementation ZNKPickerView

- (void)dealloc
{
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
        obj = nil;
    }];
    _pickerViewArray = nil;
    _ZNKPickertViewResult = nil;
    _options = nil;
    _pickerViewDict = nil;
    _result = nil;
    _selectedObject = nil;
    _keyboard = nil;
}

+ (void)showInView:(UIView *)view pickerType:(ZNKPickerType)type title:(NSString *)title withObject:(id)objects withOptions:(NSDictionary *)options hasInput:(BOOL)hasInput hasNav:(BOOL)hasNav objectToStringConverter:(NSString *(^)(id))converter completion:(void(^)(ZNKPickerView *pickerView,NSString *input, NSInteger index, id obj))completionBlock confirmHandler:(void(^)(ZNKPickerView *pickerView,NSString *input, NSInteger index, id obj))confirmBlock{
    UIView *sheet = [[self alloc] initWithFrame:view.bounds superView:view  pickerType:type title: title withObject:objects withOptions:options hasInput:hasInput hasNav: hasNav objectToStringConverter:converter resultBlock:completionBlock confirmHandler:confirmBlock];
    if (view == nil) {
        return;
    }
    [view addSubview:sheet];
}

- (instancetype)initWithFrame:(CGRect)frame superView:(UIView *)view  pickerType:(ZNKPickerType)type title:(NSString *)title  withObject:(id)objects withOptions:(NSDictionary *)options hasInput:(BOOL)has hasNav:(BOOL)hasNav  objectToStringConverter:(NSString *(^)(id))converter resultBlock:(void(^)(ZNKPickerView *pickerView,NSString *input, NSInteger index, id obj))block confirmHandler:(void(^)(ZNKPickerView *pickerView,NSString *input, NSInteger index, id obj))confirmBlock
{
    self = [super initWithFrame:frame];
    if (self) {
        _hasInput = has;
        _mainView = view;
        _ZNKPickertViewResult = block;
        _ZNKPickertViewConfirmResult = confirmBlock;
        _type = type;
        _options = options;
        _objectToStringConverter = converter;
        _inputString = @"";
        if ([objects isKindOfClass:[NSArray class]]) {
            _pickerClass = 1;
            _pickerViewArray = (NSArray *)objects;
            _result = _pickerViewArray.firstObject;
        }else if ([objects isKindOfClass:[NSDictionary class]]){
            _pickerClass = 2;
            NSDictionary *objDict = (NSDictionary *)objects;
            _pickerViewDict = objDict;
            _pickerViewKeys = objDict.allKeys;
            _pickerViewArray = objDict.allValues;
            _result = _pickerViewArray.firstObject;
        }else if ([objects isKindOfClass:[NSString class]]){
            _inputString = (NSString *)objects;
        }
        
        [self addSubview:self.coverView];
        
        switch (_type) {
            case ZNKPickerTypeObject:
            {
                switch (_pickerClass) {
                    case 1:
                    {
                        [self initializeForArray];
                    }
                        break;
                    case 2:
                    {
                        
                    }
                    default:
                        break;
                }
            }
                break;
            case ZNKPickerTypeDateMode:
            case ZNKPickerTypeTimeMode:
            case ZNKPickerTypeDateTimeMode:
            case ZNKPickerTypeYearMonthMode:
            case ZNKPickerTypeMonthDayMode:
            case ZNKPickerTypeHourMinuteMode:
            case ZNKPickerTypeDateHourMinuteMode:
            {
                [self initializeForDate];
            }
                break;
            case ZNKPickerTypeActionSheet:
            {
                [self initializeForActionSheet];
            }
                break;
            case ZNKPickerTypeActionAlert:
            {
                [self initializeForActionAlert];
            }
                break;
            default:
                break;
        }
        if (_hasInput) {
            self.keyboard = [[KeyboardManager alloc] initWithTargetView:self.inputTextField containerView:self.sheetView hasNav:hasNav contentOffset:0 showBlock:nil hideBlock:nil];
        }
    }
    return self;
}


#pragma mark - private

#pragma mark - 单列

- (void)initializeForArray{
    if (!_pickerViewArray) {
        return;
    }
    [self addSubview:self.sheetView];
    [self.sheetView addSubview:self.toolbarContainerView];
    [self.sheetView addSubview:self.cancelButton];
    
    self.sheetView.frame = CGRectMake(0, znk_screenHeight, znk_screenWidth, sheetViewHeight);
    self.toolbarContainerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.sheetView.frame), pickerViewToolbarHeight);
    [self.toolbarContainerView addSubview:self.pickerToolbar];
    
    self.cancelButton.frame = CGRectMake(0, CGRectGetHeight(self.sheetView.frame) - 44, CGRectGetWidth(self.sheetView.frame), 44);
    _pickerViewMinY = CGRectGetMaxY(self.pickerToolbar.frame) + 1;
    _pickerViewHeight = CGRectGetHeight(self.sheetView.frame) - CGRectGetHeight(self.pickerToolbar.frame) - CGRectGetHeight(self.cancelButton.frame) - margin_cancelButton_to_otherButton;
    
    [self.sheetView addSubview:self.pickerView];
    
    [UIView animateWithDuration:SheetViewAnimationDuration animations:^{
        self.sheetView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.sheetView.frame));
    }];
    
}

#pragma mark - 日期

- (void)initializeForDate{
    [self addSubview:self.sheetView];
    [self.sheetView addSubview:self.toolbarContainerView];
   
    [self.sheetView addSubview:self.cancelButton];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    _dateTimeStr = [dateFormatter stringFromDate:self.defaultDate];
    
    self.sheetView.frame = CGRectMake(0, znk_screenHeight, znk_screenWidth, sheetViewHeight);
    self.toolbarContainerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.sheetView.frame), pickerViewToolbarHeight);
     [self.toolbarContainerView addSubview:self.pickerToolbar];
    
    
    self.pickerToolbar.frame = CGRectMake(10, 0, CGRectGetWidth(self.sheetView.frame) - 20, CGRectGetHeight(self.toolbarContainerView.frame));
    self.cancelButton.frame = CGRectMake(0, CGRectGetHeight(self.sheetView.frame) - 44, CGRectGetWidth(self.sheetView.frame), 44);
    _pickerViewMinY = CGRectGetMaxY(self.pickerToolbar.frame) + 1;
    _pickerViewHeight = CGRectGetHeight(self.sheetView.frame) - CGRectGetHeight(self.pickerToolbar.frame) - CGRectGetHeight(self.cancelButton.frame) - margin_cancelButton_to_otherButton;
    
    [self.sheetView addSubview:self.datePickerContainerView];
    self.datePickerContainerView.frame = CGRectMake(0, _pickerViewMinY, CGRectGetWidth(self.sheetView.frame), _pickerViewHeight);
    
    
    if (_type == ZNKPickerTypeDateMode) {
        [self set_yearScrollView];
        [self set_monthScrollView];
        [self set_dayScrollView];
    }
    else if (_type == ZNKPickerTypeTimeMode) {
        [self set_hourScrollView];
        [self set_minuteScrollView];
        [self set_secondScrollView];
    }
    else if (_type == ZNKPickerTypeDateTimeMode) {
        [self set_yearScrollView];
        [self set_monthScrollView];
        [self set_dayScrollView];
        [self set_hourScrollView];
        [self set_minuteScrollView];
        [self set_secondScrollView];
    }
    else if (_type == ZNKPickerTypeYearMonthMode) {
        [self set_yearScrollView];
        [self set_monthScrollView];
    }
    else if (_type == ZNKPickerTypeMonthDayMode) {
        [self set_monthScrollView];
        [self set_dayScrollView];
    }
    else if (_type == ZNKPickerTypeHourMinuteMode) {
        [self set_hourScrollView];
        [self set_minuteScrollView];
    }
    else if (_type == ZNKPickerTypeDateHourMinuteMode) {
        [self set_yearScrollView];
        [self set_monthScrollView];
        [self set_dayScrollView];
        [self set_hourScrollView];
        [self set_minuteScrollView];
    }
    
    [self.datePickerContainerView addSubview:self.dateSepratorLabel];
    CGFloat labelHeight = CGRectGetHeight(self.datePickerContainerView.frame) * (1 / 5.0);
    self.dateSepratorLabel.frame = CGRectMake(0, (CGRectGetHeight(self.datePickerContainerView.frame) - labelHeight) / 2, CGRectGetWidth(self.datePickerContainerView.frame), labelHeight);

    [UIView animateWithDuration:SheetViewAnimationDuration animations:^{
        self.sheetView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.sheetView.frame));
    }];
}

#pragma mark - 类似系统actionsheet

- (void)initializeForActionSheet{
    if (!_pickerViewArray) {
        return;
    }
    [self addSubview:self.sheetView];
    CGFloat titleMaxY = 0;
    CGFloat titleHeight = 0;
    if (self.title && ![self.title isEqualToString:@""]) {
        [self.sheetView addSubview:self.titleLabel];
        titleMaxY = CGRectGetMaxY(self.titleLabel.frame);
        titleHeight = CGRectGetHeight(self.titleLabel.frame);
    }
    
    CGFloat messageMaxY = 0;
    CGFloat messageHeight = 0;
    if (self.message && ![self.message isEqualToString:@""]) {
        [self.sheetView addSubview:self.messageLabel];
        messageMaxY = CGRectGetMaxY(self.messageLabel.frame) + 1;
        messageHeight = CGRectGetHeight(self.messageLabel.frame);
    }
    
    [self.sheetView addSubview:self.cancelButton];
    self.cancelButton.frame = CGRectMake(0, CGRectGetHeight(self.sheetView.frame) - 44, CGRectGetWidth(self.sheetView.frame), 44);
    
    CGFloat totalViewHeight = 44 + titleHeight + messageHeight + self.tableViewRowHeight * 2 + 6;
    //CGRectGetHeight(self.sheetView.frame) - CGRectGetHeight(self.pickerToolbar.frame) - CGRectGetHeight(self.cancelButton.frame) - margin_cancelButton_to_otherButton;
    if (self.canScroll) {
        totalViewHeight = 44 + titleHeight + messageHeight + self.tableViewRowHeight * 2 + 6;
    }else{
        totalViewHeight = 44 + titleHeight + messageHeight + _pickerViewArray.count * self.tableViewRowHeight + 6;
    }
    
    self.sheetView.frame = CGRectMake(0, znk_screenHeight, znk_screenWidth, totalViewHeight);
    
    
    _pickerViewMinY = CGRectGetMaxY(self.pickerToolbar.frame) + 1;
    _pickerViewHeight = CGRectGetHeight(self.sheetView.frame) - CGRectGetHeight(self.pickerToolbar.frame) - CGRectGetHeight(self.cancelButton.frame) - margin_cancelButton_to_otherButton;
    
    [self.sheetView addSubview:self.tableView];
    self.tableView.frame = CGRectMake(0, _pickerViewMinY, CGRectGetWidth(self.sheetView.frame), _pickerViewHeight);
    
    [UIView animateWithDuration:SheetViewAnimationDuration animations:^{
        self.sheetView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.sheetView.frame));
    }];
    
}

#pragma mark - 类似系统actionalert

- (void)initializeForActionAlert{
    if (!_pickerViewArray) {
        return;
    }
    
    
}

#pragma mark - getter

- (void)setCanScroll:(BOOL)canScroll{
    _canScroll = canScroll;
}

- (CGFloat)coverViewAlpha{
    if ([_options[ZNKcoverViewAlpha] isKindOfClass:[NSNumber class]]) {
        return ((NSNumber *)_options[ZNKcoverViewAlpha]).floatValue;
    }
    return 0.3;
}

- (CGFloat)tableViewRowHeight{
    if ([_options[ZNKdefaultTableRowHeight] isKindOfClass:[NSNumber class]]) {
        return ((NSNumber *)_options[ZNKdefaultTableRowHeight]).floatValue;
    }
    return 45;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 45;
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.layoutMargins = UIEdgeInsetsZero;
    }
    return _tableView;
}

- (NSDate *)defaultDate{
    if ([_options[ZNKdefaultDate] isKindOfClass:[NSDate class]]) {
        return _options[ZNKdefaultDate];
    }
    return [NSDate date];
}

- (MyTextField *)inputTextField{
    if (!_inputTextField) {
        _inputTextField = [[MyTextField alloc] initWithFrame:CGRectZero padding:40];
        _inputTextField.delegate = self;
        _inputTextField.text = _inputString;
    }
    return _inputTextField;
}

- (BOOL)pickerViewShowsSelectionIndicator{
    id showSelectionIndicator = _options[ZNKshowsSelectionIndicator];
    if (showSelectionIndicator) {
        return [showSelectionIndicator boolValue];
    }
    return YES;
}

- (NSInteger)selectedIndex{
    if (self.selectedObject) {
        if ([_pickerViewArray indexOfObject:self.selectedObject] > 0 && [_pickerViewArray indexOfObject:self.selectedObject] < _pickerViewArray.count) {
            _result = self.selectedObject;
            return [_pickerViewArray indexOfObject:self.selectedObject];
        }
        return 0;
    }
    return [[_pickerViewArray objectAtIndex:0] integerValue];
}

- (id)selectedObject{
    return _options[ZNKselectedObject];
}

- (UIFont *)pickerViewFont{
    UIFont *pickerViewFont = [[UIFont alloc] init];
    pickerViewFont = _options[ZNKpickerViewFont];
    if (pickerViewFont) {
        return pickerViewFont;
    }
    return [UIFont systemFontOfSize:14];
}

- (NSInteger)pickerViewTextAlignment{
    NSNumber *textAlignment = [[NSNumber alloc] init];
    textAlignment = _options[ZNKtextAlignment];
    
    if (textAlignment != nil) {
        return [_options[ZNKtextAlignment] integerValue];
    }
    return 1;
}

- (UIColor *)pickerViewTextColor{
    UIColor *pickerViewTextColor = _options[ZNKpickerViewTitleColor];
    if (pickerViewTextColor != nil) {
        return pickerViewTextColor;
    }
    return [UIColor colorFromHexString:@"#E0748E"];
}

- (UIColor *)pickerViewBackgroundColor{
    UIColor *pickerViewBackgroundColor = _options[ZNKsuviewsbackgroundColor];
    if (pickerViewBackgroundColor != nil) {
        return pickerViewBackgroundColor;
    }
    return [UIColor whiteColor];
}

- (UIColor *)sheetViewBackgroundColor{
    UIColor *pickerViewBackgroundColor = _options[ZNKsheetViewViewBackgroundColor];
    if (pickerViewBackgroundColor != nil) {
        return pickerViewBackgroundColor;
    }
    return [UIColor colorFromHexString:@"#ECE3E6"];
}

- (NSString *)cancelButtonTitle{
    NSString *cancelTitle = _options[ZNKpickerViewCancelTitle];
    if (cancelTitle) {
        return cancelTitle;
    }
    return @"取消";
}



- (UIButton *)coverView{
    if (!_coverView) {
        _coverView = [UIButton buttonWithType:UIButtonTypeCustom];
        _coverView.frame = _mainView.bounds;
        _coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:self.coverViewAlpha];
        [_coverView addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _coverView;
}

- (UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton addTarget:self action:@selector(dismissView) forControlEvents:(UIControlEventTouchUpInside)];
        _cancelButton.backgroundColor = self.pickerViewBackgroundColor;
        [_cancelButton setTitle:self.cancelButtonTitle  forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
    return _cancelButton;
}

- (UIView *)sheetView{
    if (!_sheetView) {
        _sheetView = [[UIView alloc] initWithFrame:CGRectZero];
        _sheetView.backgroundColor = self.sheetViewBackgroundColor;
    }
    return _sheetView;
}

- (UIView *)datePickerContainerView{
    if (!_datePickerContainerView) {
        _datePickerContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        _datePickerContainerView.backgroundColor = self.pickerViewBackgroundColor;
    }
    return _datePickerContainerView;
}

- (UILabel *)dateSepratorLabel{
    if (!_dateSepratorLabel) {
        _dateSepratorLabel = [[UILabel alloc] init];
        _dateSepratorLabel.text = @":";
        _dateSepratorLabel.font = [UIFont systemFontOfSize:20];
        _dateSepratorLabel.textColor = self.pickerViewTextColor;
        if (_textColor) {
            _dateSepratorLabel.textColor = _textColor;
        }else{
            _dateSepratorLabel.textColor = [UIColor colorFromHexString:@"#B95561"];
        }
        _dateSepratorLabel.textAlignment = NSTextAlignmentCenter;
        _dateSepratorLabel.backgroundColor = [UIColor clearColor];
    }
    return _dateSepratorLabel;
}

- (UIView *)toolbarContainerView{
    if (!_toolbarContainerView) {
        _toolbarContainerView = [[UIView alloc] init];
        _toolbarContainerView.backgroundColor = [UIColor whiteColor];
    }
    return _toolbarContainerView;
}

- (UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_confirmButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_confirmButton setTitle:(NSString *)_options[ZNKconfirmButtonTitle] == nil ? @"确定" : (NSString *)_options[ZNKconfirmButtonTitle] forState:UIControlStateNormal];
        
        if ([_options[ZNKcomfirmButtonColor] isKindOfClass:[UIColor class]]) {
            [_confirmButton setTitleColor:_options[ZNKcomfirmButtonColor] forState:UIControlStateNormal];
        }else{
            [_confirmButton setTitleColor:[UIColor colorFromHexString:@"#E0748E"] forState:UIControlStateNormal];
        }
    }
    return _confirmButton;
}

- (UIToolbar *)pickerToolbar{
    if (!_pickerToolbar) {
        _pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(self.sheetView.frame) - 20, CGRectGetHeight(self.toolbarContainerView.frame))];
        _pickerToolbar.barTintColor = self.pickerViewBackgroundColor;
        if (_hasInput) {
            self.inputTextField.frame = CGRectMake(0, 0, CGRectGetWidth(_pickerToolbar.frame) * (4 / 5.0), CGRectGetHeight(_pickerToolbar.frame));
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, CGRectGetHeight(self.inputTextField.frame))];
            titleLabel.text = _options[ZNKleftInputViewTitle] == nil ? @"备注:": _options[ZNKleftInputViewTitle];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.textColor = [UIColor darkGrayColor];
            titleLabel.font = [UIFont systemFontOfSize:14];
            self.inputTextField.leftViewMode = UITextFieldViewModeAlways;
            self.inputTextField.leftView = titleLabel;
            
            UIBarButtonItem *inputBar = [[UIBarButtonItem alloc] initWithCustomView:self.inputTextField];
            UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            self.confirmButton.frame = CGRectMake(0, 0, 40, CGRectGetHeight(_pickerToolbar.frame));
            UIBarButtonItem *confirmButton = [[UIBarButtonItem alloc] initWithCustomView:self.confirmButton];
            _pickerToolbar.items = @[inputBar, flexButton, confirmButton];
        }else{
            UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            UIBarButtonItem *confirmButton = [[UIBarButtonItem alloc] initWithTitle:(NSString *)_options[ZNKconfirmButtonTitle] == nil ? @"确定" : (NSString *)_options[ZNKconfirmButtonTitle] style:UIBarButtonItemStylePlain target:self action:@selector(buttonClick:)];
            if ([_options[ZNKcomfirmButtonColor] isKindOfClass:[UIColor class]]) {
                [confirmButton setTitleTextAttributes:@{NSForegroundColorAttributeName:_options[ZNKcomfirmButtonColor]} forState:UIControlStateNormal];
            }else{
                [confirmButton setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorFromHexString:@"#E0748E"]} forState:UIControlStateNormal];
            }
            _pickerToolbar.items = @[flexButton, confirmButton];
        }
        
    }
    return _pickerToolbar;
}

- (UIPickerView *)pickerView{
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        [_pickerView setDelegate:self];
        [_pickerView setDataSource:self];
        _pickerView.backgroundColor = self.pickerViewBackgroundColor;
        _pickerView.layer.frame = CGRectMake(0, _pickerViewMinY, CGRectGetWidth(self.sheetView.frame), _pickerViewHeight);
        _pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_pickerView setShowsSelectionIndicator: self.pickerViewShowsSelectionIndicator];//YES];
        [_pickerView selectRow:self.selectedIndex inComponent:0 animated:YES];
    }
    return _pickerView;
}

- (void)setTitle:(NSString *)title{
    _title = title;
    if (self.titleLabel && self.tableView) {
        CGRect titleRect = [self textRect:_title size:CGSizeMake(CGRectGetWidth(self.tableView.frame), self.tableViewRowHeight) fontSize:17];
        self.titleLabel.text = _title;
        self.titleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(titleRect) > self.tableViewRowHeight ? CGRectGetHeight(titleRect) : self.tableViewRowHeight);
    }
}


- (CGRect)titleRect{
    if (self.title && self.tableView) {
        CGRect titleR = [self textRect:self.title size:CGSizeMake(CGRectGetWidth(self.tableView.frame), CGRectGetHeight(self.frame)) fontSize:17];
        return CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(titleR) > self.tableViewRowHeight ? CGRectGetHeight(titleR) : self.tableViewRowHeight);
    }
    return CGRectZero;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:self.titleRect];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.contentScaleFactor = 0.5;
        _titleLabel.text = self.title ? self.title : @"";
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}

- (void)setMessage:(NSString *)message{
    _message = message;
    if (self.messageLabel && self.tableView) {
        CGRect messageRect = [self textRect:_message size:CGSizeMake(CGRectGetWidth(self.tableView.frame), CGRectGetHeight(self.frame)) fontSize:17];
        self.messageLabel.text = _message;
        self.messageLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(messageRect) > self.tableViewRowHeight ? CGRectGetHeight(messageRect) : self.tableViewRowHeight);
        self.messageLabel.font = [UIFont systemFontOfSize:15];
    }
}

- (CGRect)messageRect{
    if (self.message && self.tableView) {
        CGRect messageR = [self textRect:self.message size:CGSizeMake(CGRectGetWidth(self.tableView.frame), CGRectGetHeight(self.frame)) fontSize:17];
        return CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), CGRectGetWidth(self.tableView.frame), CGRectGetHeight(messageR) > self.tableViewRowHeight ? CGRectGetHeight(messageR) : self.tableViewRowHeight);
    }
    return CGRectZero;
}

- (UILabel *)messageLabel{
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] initWithFrame:self.messageRect];
        _messageLabel.text = self.message ? self.message : @"";
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.font = [UIFont systemFontOfSize:12];
        _messageLabel.textColor = [UIColor blackColor];
    }
    return _messageLabel;
}

- (CGRect)textRect:(NSString *)txt size:(CGSize)s fontSize:(CGFloat)f {
    return [txt boundingRectWithSize:s options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:f]} context:nil];
}

#pragma mark - 事件

- (void)buttonClick:(UIButton *)sender{
    
    switch (_type) {
        case ZNKPickerTypeObject:
        {
            if (_ZNKPickertViewConfirmResult) {
                _ZNKPickertViewConfirmResult(self, nil, 0, _result);
            }
        }
            break;
        case ZNKPickerTypeActionSheet:
        {
            
        }
            break;
        case ZNKPickerTypeActionAlert:
        {
            
        }
            break;
        case ZNKPickerTypeDateMode:
        case ZNKPickerTypeTimeMode:
        case ZNKPickerTypeDateTimeMode:
        case ZNKPickerTypeYearMonthMode:
        case ZNKPickerTypeMonthDayMode:
        case ZNKPickerTypeHourMinuteMode:
        case ZNKPickerTypeDateHourMinuteMode:
        {
            switch (_type) {
                case ZNKPickerTypeDateMode:
                    _dateTimeStr = [NSString stringWithFormat:@"%ld-%ld-%ld",(long)self.curYear,(long)self.curMonth,(long)self.curDay];
                    break;
                case ZNKPickerTypeTimeMode:
                    _dateTimeStr = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)self.curHour,(long)self.curMin,(long)self.curSecond];
                    break;
                case ZNKPickerTypeDateTimeMode:
                    _dateTimeStr = [NSString stringWithFormat:@"%ld-%ld-%ld %02ld:%02ld:%02ld",(long)self.curYear,(long)self.curMonth,(long)self.curDay,(long)self.curHour,(long)self.curMin,(long)self.curSecond];
                    break;
                case ZNKPickerTypeMonthDayMode:
                    _dateTimeStr = [NSString stringWithFormat:@"%ld-%ld",(long)self.curMonth,(long)self.curDay];
                    break;
                case ZNKPickerTypeYearMonthMode:
                    _dateTimeStr = [NSString stringWithFormat:@"%ld-%ld",(long)self.curYear,(long)self.curMonth];
                    break;
                case ZNKPickerTypeHourMinuteMode:
                    _dateTimeStr = [NSString stringWithFormat:@"%02ld:%02ld",(long)self.curHour,(long)self.curMin];
                    break;
                case ZNKPickerTypeDateHourMinuteMode:
                    _dateTimeStr = [NSString stringWithFormat:@"%ld-%ld-%ld %02ld:%02ld",(long)self.curYear,(long)self.curMonth,(long)self.curDay,(long)self.curHour,(long)self.curMin];
                    break;
                default:
                    _dateTimeStr = [NSString stringWithFormat:@"%ld-%ld-%ld %02ld:%02ld:%02ld",(long)self.curYear,(long)self.curMonth,(long)self.curDay,(long)self.curHour,(long)self.curMin,(long)self.curSecond];
                    break;
            }
            if (_ZNKPickertViewConfirmResult) {
                if (self.inputTextField) {
                    _ZNKPickertViewConfirmResult(self, self.inputTextField.text, 0, _dateTimeStr);
                }else{
                    _ZNKPickertViewConfirmResult(self, nil, 0, _dateTimeStr);
                }
            }
        }
        default:
            break;
    }
    [self dismissView];
}

/** 点击按钮以及遮盖部分执行的方法 */
- (void)dismissView {
    [UIView animateWithDuration:SheetViewAnimationDuration animations:^{
        self.sheetView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - 代理

#pragma mark - table view delegate and data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _pickerViewArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cellIdForAction";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;
    [cell.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), self.tableViewRowHeight)];
    titleLabel.text = _pickerViewArray[indexPath.row];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:18];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - picker view delegate and data source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    switch (_pickerClass) {
        case 1:
        {
            return 1;
        }
            break;
        case 2:
        {
            return 2;
        }
        default:
            break;
    }
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch (_pickerClass) {
        case 1:
        {
            return _pickerViewArray.count;
        }
            break;
        case 2:
        {
            if (component == 0) {
                return _pickerViewKeys.count;
            }else{
                return _pickerViewArray.count;
            }
        }
        default:
            break;
    }
    return 0;
}

//- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
//    switch (_pickerClass) {
//        case 1:
//        {
//            NSString *title = @"";
//            if (_objectToStringConverter) {
//                title = _objectToStringConverter(_pickerViewArray[row]);
//            }else{
//                title = _pickerViewArray[row];
//            }
//            NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:title];
//            if ([_options[ZNKpickerViewTitleColor] isKindOfClass:[UIColor class]]) {
//                [attrTitle addAttribute:NSForegroundColorAttributeName value:_options[ZNKpickerViewTitleColor] range:NSMakeRange(0, title.length)];
//            }else{
//                [attrTitle addAttribute:NSForegroundColorAttributeName value:[UIColor colorFromHexString:@"#E0748E"] range:NSMakeRange(0, title.length)];
//            }
//            if ([_options[ZNKpickerViewFont] isKindOfClass:[UIFont class]]) {
//                [attrTitle addAttribute:NSFontAttributeName value:_options[ZNKpickerViewFont] range:NSMakeRange(0, title.length)];
//            }else{
//                [attrTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, title.length)];
//            }
//            return attrTitle;
//        }
//            break;
//            
//        default:
//            break;
//    }
//    return nil;
//}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    switch (_pickerClass) {
        case 1:
        {
            if (self.objectToStringConverter == nil) {
                _result = [_pickerViewArray objectAtIndex:row];
                if (_ZNKPickertViewResult) {
                    _ZNKPickertViewResult(self, nil, 0, [_pickerViewArray objectAtIndex:row]);
                    _result = [_pickerViewArray objectAtIndex:row];
                }
            } else{
                _result = self.objectToStringConverter ([_pickerViewArray objectAtIndex:row]);
                if (_ZNKPickertViewResult) {
                    _ZNKPickertViewResult(self, nil, 0, self.objectToStringConverter ([_pickerViewArray objectAtIndex:row]));
                }
            }
        }
            break;
        case 2:
        {
            
        }
        default:
            break;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view {
    switch (_pickerClass) {
        case 1:
        {
            UIView *customPickerView = view;
            
            UILabel *pickerViewLabel;
            
            if (customPickerView==nil) {
                
                CGRect frame = CGRectMake(0.0, 0.0, 292.0, 44.0);
                customPickerView = [[UIView alloc] initWithFrame: frame];
                
                
                CGRect labelFrame = CGRectMake(0.0, 0.0, CGRectGetWidth(pickerView.frame), 35); // 35 or 44
                pickerViewLabel = [[UILabel alloc] initWithFrame:labelFrame];
                [pickerViewLabel setTag:1];
                [pickerViewLabel setTextAlignment: self.pickerViewTextAlignment];
                [pickerViewLabel setBackgroundColor:[UIColor clearColor]];
                [pickerViewLabel setTextColor:self.pickerViewTextColor];
                [pickerViewLabel setFont:self.pickerViewFont];
                [customPickerView addSubview:pickerViewLabel];
            } else{
                
                for (UIView *view in customPickerView.subviews) {
                    if (view.tag == 1) {
                        pickerViewLabel = (UILabel *)view;
                        break;
                    }
                }
            }
            
            if (self.objectToStringConverter == nil){
                [pickerViewLabel setText: [_pickerViewArray objectAtIndex:row]];
            } else{
                [pickerViewLabel setText:(self.objectToStringConverter ([_pickerViewArray objectAtIndex:row]))];
            }
            
            return customPickerView;
        }
            break;
        case 2:
        {
            return nil;
        }
        default:
            break;
    }
    return nil;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - date picker

- (void)setMaxYear:(NSInteger)maxYear {
    _maxYear = maxYear;
    [self update_yearScrollView];
}
- (void)setMinYear:(NSInteger)minYear {
    _minYear = minYear;
    [self update_yearScrollView];
}

- (void)update_yearScrollView {
    [_yearScrollView reloadData];
    
    [_yearScrollView setCurrentSelectPage:(self.curYear-(_minYear+2))];
    [self setAfterScrollShowView:_yearScrollView andCurrentPage:1];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */



- (NSString *)defaultFormat:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    return [dateFormatter stringFromDate:localeDate];
}


//设置年月日时分的滚动视图
- (void)set_yearScrollView
{
    if (_type == ZNKPickerTypeDateTimeMode) {
        _yearScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.datePickerContainerView.frame)*0.25, CGRectGetHeight(self.datePickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeDateMode) {
        _yearScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.datePickerContainerView.frame)*0.34, CGRectGetHeight(self.datePickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeYearMonthMode) {
        _yearScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.datePickerContainerView.frame)*0.5, CGRectGetHeight(self.datePickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeDateHourMinuteMode) {
        _yearScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.datePickerContainerView.frame)*0.28, CGRectGetHeight(self.datePickerContainerView.frame))];
    }
    
    self.curYear = [self setNowTimeShow:0];
    [_yearScrollView setCurrentSelectPage:(self.curYear-(_minYear+2))];
    _yearScrollView.delegate = self;
    _yearScrollView.datasource = self;
    [self setAfterScrollShowView:_yearScrollView andCurrentPage:1];
    [self.datePickerContainerView addSubview:_yearScrollView];
}
//设置年月日时分的滚动视图
- (void)set_monthScrollView
{
    if (_type == ZNKPickerTypeDateTimeMode) {
        _monthScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.datePickerContainerView.frame)*0.25, 0, CGRectGetWidth(self.datePickerContainerView.frame)*0.15, CGRectGetHeight(self.datePickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeDateMode) {
        _monthScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.datePickerContainerView.frame)*0.34, 0, CGRectGetWidth(self.datePickerContainerView.frame)*0.33, CGRectGetHeight(self.datePickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeMonthDayMode) {
        _monthScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.datePickerContainerView.frame)*0, 0, CGRectGetWidth(self.datePickerContainerView.frame)*0.5, CGRectGetHeight(self.datePickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeYearMonthMode) {
        _monthScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.datePickerContainerView.frame)*0.5, 0, CGRectGetWidth(self.datePickerContainerView.frame)*0.5, CGRectGetHeight(self.datePickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeDateHourMinuteMode) {
        _monthScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.datePickerContainerView.frame)*0.28, 0, CGRectGetWidth(self.datePickerContainerView.frame)*0.18, CGRectGetHeight(self.datePickerContainerView.frame))];
    }
    
    self.curMonth = [self setNowTimeShow:1];
    [_monthScrollView setCurrentSelectPage:(self.curMonth-3)];
    _monthScrollView.delegate = self;
    _monthScrollView.datasource = self;
    [self setAfterScrollShowView:_monthScrollView andCurrentPage:1];
    [self.datePickerContainerView addSubview:_monthScrollView];
}
//设置年月日时分的滚动视图
- (void)set_dayScrollView
{
    if (_type == ZNKPickerTypeDateTimeMode) {
        _dayScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.datePickerContainerView.frame)*0.40, 0, CGRectGetWidth(self.datePickerContainerView.frame)*0.15, CGRectGetHeight(self.datePickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeDateMode) {
        _dayScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.datePickerContainerView.frame)*0.67, 0, CGRectGetWidth(self.datePickerContainerView.frame)*0.33, CGRectGetHeight(self.datePickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeMonthDayMode) {
        _dayScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.datePickerContainerView.frame)*0.5, 0, CGRectGetWidth(self.datePickerContainerView.frame)*0.5, CGRectGetHeight(self.datePickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeDateHourMinuteMode) {
        _dayScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.datePickerContainerView.frame)*0.46, 0, CGRectGetWidth(self.datePickerContainerView.frame)*0.18, CGRectGetHeight(self.datePickerContainerView.frame))];
    }
    
    self.curDay = [self setNowTimeShow:2];
    [_dayScrollView setCurrentSelectPage:(self.curDay-3)];
    _dayScrollView.delegate = self;
    _dayScrollView.datasource = self;
    [self setAfterScrollShowView:_dayScrollView andCurrentPage:1];
    [self.datePickerContainerView addSubview:_dayScrollView];
}
//设置年月日时分的滚动视图
- (void)set_hourScrollView
{
    if (_type == ZNKPickerTypeDateTimeMode) {
        _hourScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.datePickerContainerView.frame)*0.55, 0, CGRectGetWidth(self.datePickerContainerView.frame)*0.15, CGRectGetHeight(self.datePickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeTimeMode) {
        _hourScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.datePickerContainerView.frame)*0.34, CGRectGetHeight(self.datePickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeHourMinuteMode) {
        _hourScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.datePickerContainerView.frame)*0.5, CGRectGetHeight(self.datePickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeDateHourMinuteMode) {
        _hourScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.datePickerContainerView.frame)*0.64, 0, CGRectGetWidth(self.datePickerContainerView.frame)*0.18, CGRectGetHeight(self.datePickerContainerView.frame))];
    }
    
    self.curHour = [self setNowTimeShow:3];
    [_hourScrollView setCurrentSelectPage:(self.curHour-2)];
    _hourScrollView.delegate = self;
    _hourScrollView.datasource = self;
    [self setAfterScrollShowView:_hourScrollView andCurrentPage:1];
    [self.datePickerContainerView addSubview:_hourScrollView];
}
//设置年月日时分的滚动视图
- (void)set_minuteScrollView
{
    if (_type == ZNKPickerTypeDateTimeMode) {
        _minuteScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.datePickerContainerView.frame)*0.70, 0, CGRectGetWidth(self.datePickerContainerView.frame)*0.15, CGRectGetHeight(self.datePickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeTimeMode) {
        _minuteScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.datePickerContainerView.frame)*0.34, 0, CGRectGetWidth(self.datePickerContainerView.frame)*0.33, CGRectGetHeight(self.datePickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeHourMinuteMode) {
        _minuteScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.datePickerContainerView.frame)*0.5, 0, CGRectGetWidth(self.datePickerContainerView.frame)*0.5, CGRectGetHeight(self.datePickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeDateHourMinuteMode) {
        _minuteScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.datePickerContainerView.frame)*0.82, 0, CGRectGetWidth(self.datePickerContainerView.frame)*0.18, CGRectGetHeight(self.datePickerContainerView.frame))];
    }
    
    self.curMin = [self setNowTimeShow:4];
    [_minuteScrollView setCurrentSelectPage:(self.curMin-2)];
    _minuteScrollView.delegate = self;
    _minuteScrollView.datasource = self;
    [self setAfterScrollShowView:_minuteScrollView andCurrentPage:1];
    [self.datePickerContainerView addSubview:_minuteScrollView];
}
//设置年月日时分的滚动视图
- (void)set_secondScrollView
{
    if (_type == ZNKPickerTypeDateTimeMode) {
        _secondScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.datePickerContainerView.frame)*0.85, 0, CGRectGetWidth(self.datePickerContainerView.frame)*0.15, CGRectGetHeight(self.datePickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeTimeMode) {
        _secondScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.datePickerContainerView.frame)*0.67, 0, CGRectGetWidth(self.datePickerContainerView.frame)*0.33, CGRectGetHeight(self.datePickerContainerView.frame))];
    }
    self.curSecond = [self setNowTimeShow:5];
    [_secondScrollView setCurrentSelectPage:(self.curSecond-2)];
    _secondScrollView.delegate = self;
    _secondScrollView.datasource = self;
    [self setAfterScrollShowView:_secondScrollView andCurrentPage:1];
    [self.datePickerContainerView addSubview:_secondScrollView];
}
- (void)setAfterScrollShowView:(ZNKCycleScrollView*)scrollview  andCurrentPage:(NSInteger)pageNumber
{
    UILabel *oneLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber];
    [oneLabel setFont:[UIFont systemFontOfSize:14]];
    if (_farTextColor) {
        [oneLabel setTextColor:_farTextColor];
    }else{
        [oneLabel setTextColor:[UIColor colorFromHexString:@"#F4CDD6"]];
    }
    UILabel *twoLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+1];
    [twoLabel setFont:[UIFont systemFontOfSize:16]];
    if (_nearTextColor) {
        [twoLabel setTextColor:_nearTextColor];
    }else{
        [twoLabel setTextColor:[UIColor colorFromHexString:@"#EDB2C0"]];
    }
    
    UILabel *currentLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+2];
    [currentLabel setFont:[UIFont systemFontOfSize:18]];
    if (_textColor) {
        [currentLabel setTextColor:_textColor];
    }else{
        [currentLabel setTextColor:[UIColor colorFromHexString:@"#B95561"]];
    }
    
    UILabel *threeLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+3];
    [threeLabel setFont:[UIFont systemFontOfSize:16]];
    if (_nearTextColor) {
        [threeLabel setTextColor:_nearTextColor];
    }else{
        [threeLabel setTextColor:[UIColor colorFromHexString:@"#EDB2C0"]];
    }
    UILabel *fourLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+4];
    [fourLabel setFont:[UIFont systemFontOfSize:14]];
    if (_farTextColor) {
        [fourLabel setTextColor:_farTextColor];
    }else{
        [fourLabel setTextColor:[UIColor colorFromHexString:@"#F4CDD6"]];
    }
}
#pragma mark mxccyclescrollview delegate
#pragma mark mxccyclescrollview databasesource
- (NSInteger)numberOfPages:(ZNKCycleScrollView*)scrollView
{
    if (scrollView == _yearScrollView) {
        
        if (_type == ZNKPickerTypeDateMode || _type == ZNKPickerTypeDateTimeMode) {
            return _maxYear - _minYear + 1;
        }
        
        return 299;
    }
    else if (scrollView == _monthScrollView)
    {
        return 12;
    }
    else if (scrollView == _dayScrollView)
    {
        
        if (ZNKPickerTypeMonthDayMode == _type) {
            return 29;
        }
        
        if (self.curMonth == 1 || self.curMonth == 3 || self.curMonth == 5 ||
            self.curMonth == 7 || self.curMonth == 8 || self.curMonth == 10 ||
            self.curMonth == 12) {
            return 31;
        } else if (self.curMonth == 2) {
            if ([self isLeapYear:self.curYear]) {
                return 29;
            } else {
                return 28;
            }
        } else {
            return 30;
        }
    }
    else if (scrollView == _hourScrollView)
    {
        return 24;
    }
    else if (scrollView == _minuteScrollView)
    {
        return 60;
    }
    return 60;
}

- (UIView *)pageAtIndex:(NSInteger)index andScrollView:(ZNKCycleScrollView *)scrollView
{
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, scrollView.bounds.size.width, scrollView.bounds.size.height/5)];
    l.tag = index+1;
    if (scrollView == _yearScrollView) {
        l.text = [NSString stringWithFormat:@"%ld",(long)(_minYear+index)];
    }
    else if (scrollView == _monthScrollView)
    {
        l.text = [NSString stringWithFormat:@"%ld",(long)(1+index)];
    }
    else if (scrollView == _dayScrollView)
    {
        l.text = [NSString stringWithFormat:@"%ld",(long)(1+index)];
    }
    else if (scrollView == _hourScrollView)
    {
        if (index < 10) {
            l.text = [NSString stringWithFormat:@"0%ld",(long)index];
        }
        else
            l.text = [NSString stringWithFormat:@"%ld",(long)index];
    }
    else if (scrollView == _minuteScrollView)
    {
        if (index < 10) {
            l.text = [NSString stringWithFormat:@"0%ld",(long)index];
        }
        else
            l.text = [NSString stringWithFormat:@"%ld",(long)index];
    }
    else
        if (index < 10) {
            l.text = [NSString stringWithFormat:@"0%ld",(long)index];
        }
        else
            l.text = [NSString stringWithFormat:@"%ld",(long)index];
    
    l.font = [UIFont systemFontOfSize:12];
    l.textAlignment = NSTextAlignmentCenter;
    l.backgroundColor = [UIColor clearColor];
    return l;
}
//设置现在时间
- (NSInteger)setNowTimeShow:(NSInteger)timeType
{
    NSDate *now = self.defaultDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:now];
    switch (timeType) {
        case 0:
        {
            NSRange range = NSMakeRange(0, 4);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
        case 1:
        {
            NSRange range = NSMakeRange(4, 2);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
        case 2:
        {
            NSRange range = NSMakeRange(6, 2);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
        case 3:
        {
            NSRange range = NSMakeRange(8, 2);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
        case 4:
        {
            NSRange range = NSMakeRange(10, 2);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
        case 5:
        {
            NSRange range = NSMakeRange(12, 2);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
        default:
            break;
    }
    return 0;
}
//选择设置的播报时间
- (void)selectSetBroadcastTime
{
    UILabel *yearLabel = [[(UILabel*)[[_yearScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *monthLabel = [[(UILabel*)[[_monthScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *dayLabel = [[(UILabel*)[[_dayScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *hourLabel = [[(UILabel*)[[_hourScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *minuteLabel = [[(UILabel*)[[_minuteScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *secondLabel = [[(UILabel*)[[_secondScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    
    NSInteger yearInt = yearLabel.tag + _minYear - 1;
    NSInteger monthInt = monthLabel.tag;
    NSInteger dayInt = dayLabel.tag;
    NSInteger hourInt = hourLabel.tag - 1;
    NSInteger minuteInt = minuteLabel.tag - 1;
    NSInteger secondInt = secondLabel.tag - 1;
    NSString *taskDateString = [NSString stringWithFormat:@"%ld%02ld%02ld%02ld%02ld%02ld",(long)yearInt,(long)monthInt,(long)dayInt,(long)hourInt,(long)minuteInt,(long)secondInt];
    NSLog(@"Now----%@",taskDateString);
}
//滚动时上下标签显示(当前时间和是否为有效时间)
- (void)scrollviewDidChangeNumber
{
    UILabel *yearLabel = [[(UILabel*)[[_yearScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *monthLabel = [[(UILabel*)[[_monthScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *dayLabel = [[(UILabel*)[[_dayScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *hourLabel = [[(UILabel*)[[_hourScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *minuteLabel = [[(UILabel*)[[_minuteScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *secondLabel = [[(UILabel*)[[_secondScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    
    NSInteger month = monthLabel.tag;
    NSInteger year = yearLabel.tag + _minYear - 1;
    if (month != self.curMonth) {
        self.curMonth = month;
        [_dayScrollView reloadData];
        [_dayScrollView setCurrentSelectPage:(self.curDay-3)];
        [self setAfterScrollShowView:_dayScrollView andCurrentPage:1];
    }
    if (year != self.curYear) {
        self.curYear = year;
        [_dayScrollView reloadData];
        [_dayScrollView setCurrentSelectPage:(self.curDay-3)];
        [self setAfterScrollShowView:_dayScrollView andCurrentPage:1];
    }
    
    self.curMonth = monthLabel.tag;
    self.curDay = dayLabel.tag;
    self.curHour = hourLabel.tag - 1;
    self.curMin = minuteLabel.tag - 1;
    self.curSecond = secondLabel.tag - 1;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *selectTimeString = [NSString stringWithFormat:@"%ld-%02ld-%02ld %02ld:%02ld:%02ld",(long)self.curYear,(long)self.curMonth,(long)self.curDay,(long)self.curHour,(long)self.curMin,(long)self.curSecond];
    NSDate *selectDate = [dateFormatter dateFromString:selectTimeString];
    NSDate *nowDate = self.defaultDate;
    NSString *nowString = [dateFormatter stringFromDate:nowDate];
    NSDate *nowStrDate = [dateFormatter dateFromString:nowString];
    if (NSOrderedAscending == [selectDate compare:nowStrDate]) {//选择的时间与当前系统时间做比较
        [self.confirmButton setEnabled:YES];
    }
    else
    {
        [self.confirmButton setEnabled:YES];
    }
}
//通过日期求星期
- (NSString*)fromDateToWeek:(NSString*)selectDate
{
    NSInteger yearInt = [selectDate substringWithRange:NSMakeRange(0, 4)].integerValue;
    NSInteger monthInt = [selectDate substringWithRange:NSMakeRange(4, 2)].integerValue;
    NSInteger dayInt = [selectDate substringWithRange:NSMakeRange(6, 2)].integerValue;
    int c = 20;//世纪
    NSInteger y = yearInt -1;//年
    NSInteger d = dayInt;
    NSInteger m = monthInt;
    int w =(y+(y/4)+(c/4)-2*c+(26*(m+1)/10)+d-1)%7;
    NSString *weekDay = @"";
    switch (w) {
        case 0:
            weekDay = @"周日";
            break;
        case 1:
            weekDay = @"周一";
            break;
        case 2:
            weekDay = @"周二";
            break;
        case 3:
            weekDay = @"周三";
            break;
        case 4:
            weekDay = @"周四";
            break;
        case 5:
            weekDay = @"周五";
            break;
        case 6:
            weekDay = @"周六";
            break;
        default:
            break;
    }
    return weekDay;
}





-(void)selectedButtons:(UIButton *)btns{
    
    
    
}

-(BOOL)isLeapYear:(NSInteger)year {
    if ((year%4==0 && year %100 !=0) || year%400==0) {
        return YES;
    }else {
        return NO;
    }
    return NO;
}


@end


