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
#define kScaleFrom_iPhone5_Desgin(_X_) (_X_ * (CGRectGetWidth(self.pickerContainerView.frame)/320))
#define kTopViewHeight kScaleFrom_iPhone5_Desgin(44)
#define kTimeBroadcastViewHeight kScaleFrom_iPhone5_Desgin(200)
#define kDatePickerHeight (0 + CGRectGetHeight(self.pickerContainerView.frame))
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
        
        if (_keyboardShowHandler) {
            _keyboardShowHandler(keyboardFrame, note);
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

@implementation UIImage (ZNKPickerView)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
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

@interface TranslucentToolbar : UIToolbar

@end

@implementation TranslucentToolbar

- (void)drawRect:(CGRect)rect {
    // do nothing
}

- (id)initWithFrame:(CGRect)aRect {
    if ((self = [super initWithFrame:aRect])) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.clearsContextBeforeDrawing = YES;
    }
    return self;
}
@end

NSString * const ZNKCoverViewAlpha                  = @"ZNKCoverViewAlpha";
NSString * const ZNKSheetViewBackgroundColor        = @"ZNKSheetViewBackgroundColor";
NSString * const ZNKSheetViewBackgroundImage        = @"ZNKSheetViewBackgroundImage";
NSString * const ZNKPickerViewData                  = @"ZNKPickerViewData";
NSString * const ZNKDefaultSelectedObject           = @"ZNKDefaultSelectedObject";
NSString * const ZNKDefaultHasNavigationBar         = @"ZNKDefaultHasNavigationBar";

NSString * const ZNKSheetViewCancelTitle            = @"ZNKPickerViewCancelTitle";
NSString * const ZNKShowsSelectionIndicator         = @"ZNKShowsSelectionIndicator";
NSString * const ZNKPickerViewTitleColor            = @"ZNKPickerViewTitleColor";
NSString * const ZNKPickerViewFont                  = @"ZNKPickerViewFont";
NSString * const ZNKPickerViewBackgroundColor       = @"ZNKPickerViewBackgroundColor";
NSString * const ZNKPickerViewBackgroundImage       = @"ZNKPickerViewBackgroundImage";

NSString * const ZNKToolbarBackgroundColor          = @"ZNKToolbarBackgroundColor";
NSString * const ZNKToolbarHasInput                 = @"ZNKToolbarHasInput";
NSString * const ZNKToolbarInputLeftView            = @"ZNKToolbarInputLeftView";
NSString * const ZNKToolbarInputPlachodler          = @"ZNKToolbarInputPlachodler";
NSString * const ZNKToolbarBackgroundImage          = @"ZNKToolbarBackgroundImage";
NSString * const ZNKConfirmButtonTitle              = @"ZNKConfirmButtonTitle";
NSString * const ZNKConfirmButtonTitleColor         = @"ZNKConfirmButtonTitleColor";

NSString * const ZNKCanScroll                       = @"ZNKCanScroll";
NSString * const ZNKVerticalScrollIndicator         = @"ZNKVerticalScrollIndicator";
NSString * const ZNKTableRowHeight                  = @"ZNKTableRowHeight";
NSString * const ZNKTextAlignment                   = @"ZNKTextAlignment";







#define znk_screenWidth [UIScreen mainScreen].bounds.size.width
#define znk_screenHeight [UIScreen mainScreen].bounds.size.height
#define znk_navigationBarHeight 64


@interface ZNKPickerView ()<UIPickerViewDelegate, UIPickerViewDataSource,ZNKCycleScrollViewDatasource,ZNKCycleScrollViewDelegate, UITextFieldDelegate, UITableViewDelegate,UITableViewDataSource>

#pragma mark - 基本UI属性
/** 选择器类型*/
@property (nonatomic, assign) ZNKPickerType type;
/**主视图*/
@property (nonatomic, strong) UIView *mainView;
/**遮罩*/
@property (nonatomic, strong) UIButton *coverView;
/** 中间 底部弹出视图 */
@property (nonatomic, strong) UIImageView *sheetView;
/**弹框视图背景颜色*/
@property (nonatomic, strong) UIColor *sheetViewBackgroundColor;
/**弹框视图背景图片*/
@property (nonatomic, strong) UIImage *sheetViewBackgroundImage;
/**遮罩透明度*/
@property (nonatomic, assign) CGFloat coverViewAlpha;
/** 取消按钮 */
@property (nonatomic, strong) UIButton *cancelButton;
/**日期选择器容器*/
@property (nonatomic, strong) UIImageView *pickerContainerView;
/**日期选择器背景颜色*/
@property (nonatomic, strong) UIColor *pickerBackgroundColor;
/**日期选择器背景图片*/
@property (nonatomic, strong) UIImage *pickerBackgroundImage;
#pragma mark - 基本数据属性
/**配置项*/
@property (nonatomic, strong) NSDictionary *options;
/**选择项*/
@property (nonatomic, strong) NSArray *pickerViewArray;
/**选择字典*/
@property (nonatomic, strong) NSDictionary *pickerViewDict;
/**接收传入数据*/
@property (nonatomic, strong) id receiveObject;
/**转换*/
@property (nonatomic, copy) NSString *(^objectToStringConverter)(id object);
/**
 数组或字典
 数组 1  字典 2 字符串 3
 */
@property (nonatomic, assign) NSInteger pickerClass;


#pragma mark - 工具栏
/**工具栏容器*/
@property (nonatomic, strong) UIImageView *toolbarContainerView;
/**工具栏容器背景视图*/
@property (nonatomic, strong) UIColor *toolbarContainerViewBackgroundColor;
/** 工具栏容器背景图片 */
@property (nonatomic, strong) UIImage *toolbarContainerViewBackgroundImage;
/**工具栏*/
@property (nonatomic, strong) TranslucentToolbar *pickerToolbar;
/**确定按钮*/
@property (nonatomic, strong) UIButton *confirmButton;
/**确定按钮title*/
@property (nonatomic, copy) NSString *confirmButtonTitle;
/**确定按钮titleColor*/
@property (nonatomic, strong) UIColor *confirmButtonTitleColor;
/**占空符*/
@property (nonatomic, strong) UIBarButtonItem *flexibleSpaceBar;
/**是否有输入框*/
@property (nonatomic, assign) BOOL hasInput;
/**输入框左侧视图*/
@property (nonatomic, strong) UIView *inputLeftView;
/**文本输入框*/
@property (nonatomic, strong) MyTextField *inputTextField;
/**输入框占位*/
@property (nonatomic, copy) NSString *placehodler;
/**输入内容*/
@property (nonatomic, copy) NSString *oldInputString;
/**键盘管理*/
@property (nonatomic, strong) KeyboardManager *keyboard;
/**输入内容*/
@property (nonatomic, strong) NSString *inputString;
/**是否有导航栏*/
@property (nonatomic, assign) BOOL hasNav;

#pragma mark - 日期选择器

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

#pragma mark - ActionSheet/Alert
/**是否可以滚动*/
@property (nonatomic, assign) BOOL canScroll;
/**显示垂直滚动条*/
@property (nonatomic, assign) BOOL verticalScrollIndicator;
/** 其他按钮表格 */
@property (nonatomic, strong) UITableView *tableView;
/**提示title*/
@property (nonatomic, copy) NSString *title;
/**提示titleLabel*/
@property (nonatomic, strong) UILabel *titleLabel;
/**提示内容*/
@property (nonatomic, copy) NSString *message;
/**提示内容Label*/
@property (nonatomic, strong) UILabel *messageLabel;
/**选择器*/
@property (nonatomic, strong) UIPickerView *pickerView;
/**文字停靠*/
@property (nonatomic, assign) NSInteger pickerViewTextAlignment;
/**文字颜色*/
@property (nonatomic, strong) UIColor *pickerViewTextColor;
/**总视图背景颜色*/
@property (nonatomic, strong) UIColor *pickerViewBackgroundColor;
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
@property (nonatomic, copy) void(^ZNKPickerRealTimeResult)(ZNKPickerView *pickerView);
/**确定时候的回调*/
@property (nonatomic, copy) void(^ZNKPickerConfirmResult)(ZNKPickerView *pickerView);

@end

@implementation ZNKPickerView

- (void)dealloc
{
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
        obj = nil;
    }];
    _pickerViewArray = nil;
    _options = nil;
    _pickerViewDict = nil;
    _result = nil;
    _selectedObject = nil;
    _keyboard = nil;
}

+ (void)showInView:(UIView *)view pickerType:(ZNKPickerType)type options:(NSDictionary *)options objectToStringConverter:(NSString *(^)(id))converter  realTimeResult:(void(^)(ZNKPickerView *pickerView))realTimeResult completionHandler:(void(^)(ZNKPickerView *pickerView))completionHandler{
    if (!view) {
        return;
    }
    UIView *sheet = [[self alloc] initWithFrame:view.bounds superView:view pickerType:type options:options objectToStringConverter:converter realTimeResult:realTimeResult completionHandler:completionHandler];
    [view addSubview:sheet];
}


- (instancetype)initWithFrame:(CGRect)frame superView:(UIView *)view pickerType:(ZNKPickerType)type options:(NSDictionary *)options objectToStringConverter:(NSString *(^)(id))converter  realTimeResult:(void(^)(ZNKPickerView *pickerView))realTimeResult completionHandler:(void(^)(ZNKPickerView *pickerView))completionHandler
{
    self = [super initWithFrame:frame];
    if (self) {
        _mainView = view;
        _type = type;
        _ZNKPickerRealTimeResult = realTimeResult;
        _ZNKPickerConfirmResult = completionHandler;
        _objectToStringConverter = converter;
        _options = options;
        [self addSubview:self.coverView];
        [self baseInitialize];
    }
    return self;
}




#pragma mark - private

- (void)baseInitialize{
    switch (_type) {
        case ZNKPickerTypeObject:
        {
            switch (self.pickerClass) {
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
    if (self.hasInput) {
        self.keyboard = [[KeyboardManager alloc] initWithTargetView:self.inputTextField containerView:self.sheetView hasNav:self.hasNav contentOffset:0 showBlock:nil hideBlock:nil];
    }
}

#pragma mark - 单列

- (void)initializeForArray{
    if (!_pickerViewArray) {
        return;
    }
    [self addSubview:self.sheetView];
    [self.sheetView addSubview:self.toolbarContainerView];
    [self.sheetView addSubview:self.cancelButton];
    
    self.sheetView.frame = CGRectMake(0, znk_screenHeight, znk_screenWidth, [self defaultSheetViewHeight]);
    self.toolbarContainerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.sheetView.frame), [self defaultToolbarHeight]);
    [self.toolbarContainerView addSubview:self.pickerToolbar];
    
    self.cancelButton.frame = CGRectMake(0, CGRectGetHeight(self.sheetView.frame) - 44, CGRectGetWidth(self.sheetView.frame), 44);
    CGFloat pickerViewMinY = CGRectGetMaxY(self.pickerToolbar.frame) + 1;
    CGFloat pickerViewHeight = CGRectGetHeight(self.sheetView.frame) - CGRectGetHeight(self.pickerToolbar.frame) - CGRectGetHeight(self.cancelButton.frame) - [self defaultPickerAndCancelButton];
    
    [self.sheetView addSubview:self.pickerView];
    
    self.pickerView.layer.frame = CGRectMake(0, pickerViewMinY, CGRectGetWidth(self.sheetView.frame), pickerViewHeight);

    
    [UIView animateWithDuration:[self defaultSheetViewAnimationDuration] animations:^{
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
    
    self.sheetView.frame = CGRectMake(0, znk_screenHeight, znk_screenWidth, [self defaultSheetViewHeight]);
    self.toolbarContainerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.sheetView.frame), [self defaultToolbarHeight]);
    
     [self.toolbarContainerView addSubview:self.pickerToolbar];
    self.pickerToolbar.frame = CGRectMake(10, 0, CGRectGetWidth(self.sheetView.frame) - 20, CGRectGetHeight(self.toolbarContainerView.frame));
    
    self.cancelButton.frame = CGRectMake(0, CGRectGetHeight(self.sheetView.frame) - 44, CGRectGetWidth(self.sheetView.frame), 44);
    CGFloat pickerViewMinY = CGRectGetMaxY(self.pickerToolbar.frame) + [self defaultToolbarPickerMargin];
    CGFloat pickerViewHeight = CGRectGetHeight(self.sheetView.frame) - CGRectGetHeight(self.pickerToolbar.frame) - CGRectGetHeight(self.cancelButton.frame) - [self defaultPickerAndCancelButton];
    
    [self.sheetView addSubview:self.pickerContainerView];
    self.pickerContainerView.frame = CGRectMake(0, pickerViewMinY, CGRectGetWidth(self.sheetView.frame), pickerViewHeight);
    
    
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
    
//    [self.pickerContainerView addSubview:self.dateSepratorLabel];
//    CGFloat labelHeight = CGRectGetHeight(self.pickerContainerView.frame) * (1 / 5.0);
//    self.dateSepratorLabel.frame = CGRectMake(0, (CGRectGetHeight(self.pickerContainerView.frame) - labelHeight) / 2, CGRectGetWidth(self.pickerContainerView.frame), labelHeight);

    [UIView animateWithDuration:[self defaultSheetViewAnimationDuration] animations:^{
        self.sheetView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.sheetView.frame));
    }];
}

#pragma mark - 类似系统actionsheet

- (void)initializeForActionSheet{
    if (!self.pickerViewArray || self.pickerViewArray.count == 0) {
        return;
    }
    [self addSubview:self.sheetView];
    [self.sheetView addSubview:self.titleLabel];
    [self.sheetView addSubview:self.messageLabel];
    [self.sheetView addSubview:self.cancelButton];
    [self.sheetView addSubview:self.tableView];
    
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
        messageMaxY = CGRectGetMaxY(self.messageLabel.frame) + [self defaultToolbarPickerMargin];
        messageHeight = CGRectGetHeight(self.messageLabel.frame);
    }
    
    CGFloat totalViewHeight = [self defaultToolbarHeight] + titleHeight + messageHeight + self.tableViewRowHeight + [self defaultToolbarPickerMargin] + [self defaultPickerAndCancelButton];
    
    CGFloat pickerViewMinY = CGRectGetMaxY(self.pickerToolbar.frame) + [self defaultToolbarPickerMargin];
    NSInteger arrayCount = self.pickerViewArray.count;
    CGFloat pickerViewHeight = self.tableViewRowHeight * arrayCount >=3 ? 3 : arrayCount;
    if (self.canScroll) {
        totalViewHeight = [self defaultToolbarHeight] + titleHeight + messageHeight + (self.tableViewRowHeight * arrayCount >= self.tableViewRowHeight * 3 ? self.tableViewRowHeight * 3 : self.tableViewRowHeight * arrayCount) + [self defaultToolbarPickerMargin] + [self defaultPickerAndCancelButton];
        pickerViewHeight = self.tableViewRowHeight * arrayCount >= self.tableViewRowHeight * 3 ? self.tableViewRowHeight * 3 : self.tableViewRowHeight * arrayCount;
        self.tableView.scrollEnabled = YES;
        self.tableView.showsVerticalScrollIndicator = NO;
    }else{
        totalViewHeight = [self defaultToolbarHeight] + titleHeight + messageHeight + self.pickerViewArray.count * self.tableViewRowHeight + [self defaultPickerAndCancelButton] + [self defaultToolbarPickerMargin];
        pickerViewHeight = self.pickerViewArray.count * self.tableViewRowHeight;
        self.tableView.scrollEnabled = NO;
        if (totalViewHeight > znk_screenHeight - znk_navigationBarHeight) {
            totalViewHeight = znk_screenHeight - znk_navigationBarHeight;
            pickerViewHeight = totalViewHeight - titleHeight - messageHeight - [self defaultToolbarHeight] - [self defaultPickerAndCancelButton] - [self defaultToolbarPickerMargin];
            self.tableView.scrollEnabled = YES;
        }
    }
    
    self.sheetView.frame = CGRectMake(0, znk_screenHeight, znk_screenWidth, totalViewHeight);
    self.cancelButton.frame = CGRectMake(0, CGRectGetHeight(self.sheetView.frame) - [self defaultToolbarHeight], CGRectGetWidth(self.sheetView.frame), [self defaultToolbarHeight]);
    
    self.tableView.frame = CGRectMake(0, pickerViewMinY, CGRectGetWidth(self.sheetView.frame), pickerViewHeight);
    
    [UIView animateWithDuration:[self defaultSheetViewAnimationDuration] animations:^{
        self.sheetView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.sheetView.frame));
    }];
    
}



#pragma mark - 类似系统actionalert

- (void)initializeForActionAlert{
    if (!self.pickerViewArray) {
        return;
    }
    
    
}

- (CGRect)textRect:(NSString *)txt size:(CGSize)s fontSize:(CGFloat)f {
    return [txt boundingRectWithSize:s options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:f]} context:nil];
}

#pragma mark - getter

#pragma mark - 接收数据

- (id)receiveObject{
    return _options[ZNKPickerViewData];
}

#pragma mark - 接收数组解析

- (NSArray *)pickerViewArray{
    if (self.receiveObject && [self.receiveObject isKindOfClass:[NSArray class]]) {
        return (NSArray *)self.receiveObject;
    }
    return [NSArray array];
}

#pragma mark - 接收字典解析

- (NSDictionary *)pickerViewDict{
    if (self.receiveObject && [self.receiveObject isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *)self.receiveObject;
    }
    return [NSDictionary dictionary];
}

#pragma mark - 接收数据类型解析

- (NSInteger)pickerClass{
    if ([self.receiveObject isKindOfClass:[NSArray class]]) {
        return 1;
    }else if ([self.receiveObject isKindOfClass:[NSDictionary class]]) {
        return 2;
    }else if ([self.receiveObject isKindOfClass:[NSString class]]) {
        return 3;
    }
    return 3;
}

#pragma mark - 是否有导航栏

- (BOOL)hasNav{
    if (_options[ZNKDefaultHasNavigationBar] && [_options[ZNKDefaultHasNavigationBar] isKindOfClass:[NSNumber class]]) {
        return ((NSNumber *)_options[ZNKDefaultHasNavigationBar]).boolValue;
    }
    return NO;
}

#pragma mark - 遮罩视图

- (UIButton *)coverView{
    if (!_coverView) {
        _coverView = [UIButton buttonWithType:UIButtonTypeCustom];
        _coverView.frame = _mainView.bounds;
        _coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:self.coverViewAlpha];
        [_coverView addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _coverView;
}

#pragma mark - 遮罩视图透明度

- (CGFloat)coverViewAlpha{
    if (_options[ZNKCoverViewAlpha] != nil && [_options[ZNKCoverViewAlpha] isKindOfClass:[NSNumber class]]) {
        return ((NSNumber *)_options[ZNKCoverViewAlpha]).floatValue;
    }
    return 0.1;
}

#pragma mark - 弹框视图

- (UIView *)sheetView{
    if (!_sheetView) {
        _sheetView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _sheetView.userInteractionEnabled = YES;
        _sheetView.backgroundColor = self.sheetViewBackgroundColor;
    }
    return _sheetView;
}

#pragma mark - 工具栏到picker view之间的距离

- (CGFloat)defaultToolbarPickerMargin{
    return 1.0f;
}

#pragma mark - picker view到取消按钮之间的距离

- (CGFloat)defaultPickerAndCancelButton{
    return 5.0f;
}

#pragma mark - 默认sheet view高度

- (CGFloat)defaultSheetViewHeight{
    return 216.0f;
}

#pragma mark - 默认弹出时间

- (CGFloat)defaultSheetViewAnimationDuration{
    return 0.25f;
}

#pragma mark - 默认工具栏高度

- (CGFloat)defaultToolbarHeight{
    return 44.0f;
}

#pragma mark - 弹框视图背景颜色

- (UIColor *)sheetViewBackgroundColor{
    if (_options[ZNKSheetViewBackgroundColor] != nil && [_options[ZNKSheetViewBackgroundColor] isKindOfClass:[UIColor class]]) {
        return (UIColor *)_options[ZNKSheetViewBackgroundColor];
    }
    return [UIColor colorFromHexString:@"#ECE3E6"];
}

#pragma mark - 弹框视图背景图片

- (UIImage *)sheetViewBackgroundImage{
    if (_options[ZNKSheetViewBackgroundImage] != nil && [_options[ZNKSheetViewBackgroundImage] isKindOfClass:[UIImage class]]) {
        return (UIImage *)_options[ZNKSheetViewBackgroundImage];
    }
    return [UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(1.0f, 1.0f)];
}

#pragma mark - tool bar / title message 

#pragma mark - 工具栏容器视图

- (UIView *)toolbarContainerView{
    if (!_toolbarContainerView) {
        _toolbarContainerView = [[UIImageView alloc] init];
        _toolbarContainerView.userInteractionEnabled = YES;
        _toolbarContainerView.backgroundColor = [UIColor whiteColor];
    }
    return _toolbarContainerView;
}

#pragma mark - 工具栏容器视图背景颜色

- (UIColor *)toolbarContainerViewBackgroundColor{
    if (_options[ZNKToolbarBackgroundColor] != nil && [_options[ZNKToolbarBackgroundColor] isKindOfClass:[UIColor class]]) {
        return (UIColor *)_options[ZNKToolbarBackgroundColor];
    }
    return [UIColor whiteColor];
}

#pragma mark - 工具栏容器视图背景图片

- (UIImage *)toolbarContainerViewBackgroundImage{
    if (_options[ZNKToolbarBackgroundImage] != nil && [_options[ZNKToolbarBackgroundImage] isKindOfClass:[UIImage class]]) {
        return (UIImage *)_options[ZNKToolbarBackgroundImage];
    }
    return [UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(1.0f, 1.0f)];
}

#pragma mark - 工具栏确定按钮

- (UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_confirmButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_confirmButton setTitle:self.confirmButtonTitle forState:UIControlStateNormal];
        [_confirmButton setTitleColor:self.confirmButtonTitleColor forState:UIControlStateNormal];
    }
    return _confirmButton;
}

#pragma mark - 工具栏确定按钮title

- (NSString *)confirmButtonTitle{
    if (_options[ZNKConfirmButtonTitle] && [_options[ZNKConfirmButtonTitle] isKindOfClass:[NSString class]]) {
        return (NSString *)_options[ZNKConfirmButtonTitle];
    }
    return @"确定";
}

#pragma mark - 工具栏确定按钮titleColor

- (UIColor *)confirmButtonTitleColor{
    if (_options[ZNKConfirmButtonTitleColor] && [_options[ZNKConfirmButtonTitleColor] isKindOfClass:[UIColor class]]) {
        return (UIColor *)_options[ZNKConfirmButtonTitleColor];
    }
    return [UIColor colorFromHexString:@"#E0748E"];
}

#pragma mark - 工具栏占空符

- (UIBarButtonItem *)flexibleSpaceBar{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

#pragma mark - 是否有输入框

- (BOOL)hasInput{
    if (_options[ZNKToolbarHasInput] && [_options[ZNKToolbarHasInput] isKindOfClass:[NSNumber class]]) {
        return ((NSNumber *)_options[ZNKToolbarHasInput]).boolValue;
    }
    return NO;
}

#pragma mark - 输入框

- (MyTextField *)inputTextField{
    if (!_inputTextField) {
        _inputTextField = [[MyTextField alloc] initWithFrame:CGRectZero padding:40];
        _inputTextField.leftView = self.inputLeftView;
        _inputTextField.leftViewMode = UITextFieldViewModeAlways;
        _inputTextField.delegate = self;
        _inputTextField.placeholder = self.placehodler;
//        _inputTextField.text = _inputString;
    }
    return _inputTextField;
}

#pragma mark - 输入框左侧视图

- (UIView *)inputLeftView{
    if (_options[ZNKToolbarInputLeftView] && [_options[ZNKToolbarInputLeftView] isKindOfClass:[UIView class]]) {
        return (UIView *)_options[ZNKToolbarInputLeftView];
    }
    if (!_inputLeftView) {
        UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, CGRectGetHeight(self.inputTextField.frame))];
        leftLabel.text = @"备注:";
        leftLabel.font = [UIFont systemFontOfSize:15];
        leftLabel.textAlignment = NSTextAlignmentCenter;
        leftLabel.adjustsFontSizeToFitWidth = YES;
        _inputLeftView = leftLabel;
    }
    return _inputLeftView;
}

#pragma mark - 占位

- (NSString *)placehodler{
    if (_options[ZNKToolbarInputPlachodler] && [_options[ZNKToolbarInputPlachodler] isKindOfClass:[NSString class]]) {
        return (NSString *)_options[ZNKToolbarInputPlachodler];
    }
    return @"请输入...";
}

#pragma mark - 旧内容

- (NSString *)oldInputString{
    return self.placehodler;
}

#pragma mark - 工具栏

- (TranslucentToolbar *)pickerToolbar{
    if (!_pickerToolbar) {
        _pickerToolbar = [[TranslucentToolbar alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(self.sheetView.frame) - 20, CGRectGetHeight(self.toolbarContainerView.frame))];
        if (self.hasInput) {
            self.inputTextField.frame = CGRectMake(0, 0, CGRectGetWidth(_pickerToolbar.frame) * (4 / 5.0), CGRectGetHeight(_pickerToolbar.frame));
            
            UIBarButtonItem *inputBar = [[UIBarButtonItem alloc] initWithCustomView:self.inputTextField];
            self.confirmButton.frame = CGRectMake(0, 0, 40, CGRectGetHeight(_pickerToolbar.frame));
            UIBarButtonItem *confirmButton = [[UIBarButtonItem alloc] initWithCustomView:self.confirmButton];
            _pickerToolbar.items = @[inputBar, self.flexibleSpaceBar, confirmButton];
        }else{
            self.confirmButton.frame = CGRectMake(0, 0, 40, CGRectGetHeight(_pickerToolbar.frame));
            UIBarButtonItem *confirmButton = [[UIBarButtonItem alloc] initWithCustomView:self.confirmButton];
            _pickerToolbar.items = @[self.flexibleSpaceBar, confirmButton];
        }
    }
    return _pickerToolbar;
}

#pragma mark - Private

#pragma mark - 日期选择器

- (UIImageView *)pickerContainerView{
    if (!_pickerContainerView) {
        _pickerContainerView = [[UIImageView alloc] init];
        _pickerContainerView.userInteractionEnabled = YES;
        _pickerContainerView.backgroundColor = self.pickerBackgroundColor;
        _pickerContainerView.image = self.pickerBackgroundImage;
    }
    return _pickerContainerView;
}

#pragma mark - 日期选择器背景颜色

- (UIColor *)pickerBackgroundColor{
    if (_options[ZNKPickerViewBackgroundColor] && [_options[ZNKPickerViewBackgroundColor] isKindOfClass:[UIColor class]]) {
        return (UIColor *)_options[ZNKPickerViewBackgroundColor];
    }
    return [UIColor whiteColor];
}

#pragma mark - 日期选择器背景图片

- (UIImage *)pickerBackgroundImage{
    if (_options[ZNKPickerViewBackgroundImage] && [_options[ZNKPickerViewBackgroundImage] isKindOfClass:[UIImage class]]) {
        return (UIImage *)_options[ZNKPickerViewBackgroundImage];
    }
    if (!_pickerBackgroundImage) {
        _pickerBackgroundImage = [UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(1.0f, 1.0f)];
    }
    return _pickerBackgroundImage;
}

#pragma mark - 日期选择器默认日期

- (NSDate *)defaultDate{
    if (_options[ZNKDefaultSelectedObject] && [_options[ZNKDefaultSelectedObject] isKindOfClass:[NSDate class]]) {
        return _options[ZNKDefaultSelectedObject];
    }
    return [NSDate date];
}

#pragma mark - 日期选择器是否可以滚动

- (BOOL)canScroll{
    if (_options[ZNKCanScroll] && [_options[ZNKCanScroll] isKindOfClass:[NSNumber class]]) {
        return ((NSNumber *)_options[ZNKCanScroll]).boolValue;
    }
    return NO;
}

#pragma mark - 日期选择器是否显示滚动条

- (BOOL)verticalScrollIndicator{
    if (_options[ZNKVerticalScrollIndicator] && [_options[ZNKVerticalScrollIndicator] isKindOfClass:[NSNumber class]]) {
        return ((NSNumber *)_options[ZNKVerticalScrollIndicator]).boolValue;
    }
    return YES;
}

#pragma mark - 日期选择器表格高度

- (CGFloat)tableViewRowHeight{
    if ([_options[ZNKTableRowHeight] isKindOfClass:[NSNumber class]]) {
        return ((NSNumber *)_options[ZNKTableRowHeight]).floatValue;
    }
    return 45.0;
}

#pragma mark - 日期选择器

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.layoutMargins = UIEdgeInsetsZero;
    }
    return _tableView;
}

#pragma mark - 日期选择器选中警示

- (BOOL)pickerViewShowsSelectionIndicator{
    if (_options[ZNKShowsSelectionIndicator] && [_options[ZNKShowsSelectionIndicator] isKindOfClass:[NSNumber class]]) {
        return [((NSNumber *)_options[ZNKShowsSelectionIndicator]) boolValue];
    }
    return YES;
}

#pragma mark - 选择器选择下标

- (NSInteger)selectedIndex{
    if (self.selectedObject) {
        if ([self.pickerViewArray indexOfObject:self.selectedObject] > 0 && [_pickerViewArray indexOfObject:self.selectedObject] < _pickerViewArray.count) {
            _result = self.selectedObject;
            return [self.pickerViewArray indexOfObject:self.selectedObject];
        }
        return 0;
    }
    return [[self.pickerViewArray objectAtIndex:0] integerValue];
}

#pragma mark - 选择器默认选中对象

- (id)selectedObject{
    return _options[ZNKDefaultSelectedObject];
}

#pragma mark - 选择器字体字号

- (UIFont *)pickerViewFont{
    if (_options[ZNKPickerViewFont] && [_options[ZNKPickerViewFont] isKindOfClass:[UIFont class]]) {
        return (UIFont *)_options[ZNKPickerViewFont];
    }
    return [UIFont systemFontOfSize:14];
}

#pragma mark - 选择器字体停靠

- (NSInteger)pickerViewTextAlignment{
    NSNumber *textAlignment = [[NSNumber alloc] init];
    textAlignment = _options[ZNKTextAlignment];
    
    if (textAlignment != nil) {
        return [_options[ZNKTextAlignment] integerValue];
    }
    return 1;
}

#pragma mark - 选择器字体颜色

- (UIColor *)pickerViewTextColor{
    if (_options[ZNKPickerViewTitleColor] && [_options[ZNKPickerViewTitleColor] isKindOfClass:[UIColor class]]) {
        return ((UIColor *)_options[ZNKPickerViewTitleColor]);
    }
    return [UIColor colorFromHexString:@"#E0748E"];
}

#pragma mark - 选择器背景颜色

- (UIColor *)pickerViewBackgroundColor{
    UIColor *pickerViewBackgroundColor = _options[ZNKPickerViewBackgroundColor];
    if (pickerViewBackgroundColor != nil) {
        return pickerViewBackgroundColor;
    }
    return [UIColor whiteColor];
}

#pragma mark - 选择器取消按钮title

- (NSString *)cancelButtonTitle{
    if (_options[ZNKSheetViewCancelTitle] && [_options[ZNKSheetViewCancelTitle] isKindOfClass:[NSString class]]) {
        return (NSString *)_options[ZNKSheetViewCancelTitle];
    }
    return @"取消";
}

#pragma mark - 选择器取消按钮

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


//- (UILabel *)dateSepratorLabel{
//    if (!_dateSepratorLabel) {
//        _dateSepratorLabel = [[UILabel alloc] init];
//        _dateSepratorLabel.text = @":";
//        _dateSepratorLabel.font = [UIFont systemFontOfSize:20];
//        _dateSepratorLabel.textColor = self.pickerViewTextColor;
//        if (_textColor) {
//            _dateSepratorLabel.textColor = _textColor;
//        }else{
//            _dateSepratorLabel.textColor = [UIColor colorFromHexString:@"#B95561"];
//        }
//        _dateSepratorLabel.textAlignment = NSTextAlignmentCenter;
//        _dateSepratorLabel.backgroundColor = [UIColor clearColor];
//    }
//    return _dateSepratorLabel;
//}


- (UIPickerView *)pickerView{
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        [_pickerView setDelegate:self];
        [_pickerView setDataSource:self];
        _pickerView.backgroundColor = self.pickerViewBackgroundColor;
        _pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_pickerView setShowsSelectionIndicator: self.pickerViewShowsSelectionIndicator];//YES];
        [_pickerView selectRow:self.selectedIndex inComponent:0 animated:YES];
    }
    return _pickerView;
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

#pragma mark - setting

#pragma mark - 选择日期

- (void)setDateTimeStr:(NSString *)dateTimeStr{
    _dateTimeStr = dateTimeStr;
    if (_ZNKPickerRealTimeResult) {
        _result = _dateTimeStr;
        _index = -1;
        _ZNKPickerRealTimeResult(self);
    }
}

- (void)setInputString:(NSString *)inputString{
    _inputString = inputString;
    if (_ZNKPickerRealTimeResult) {
        _index = -1;
        _inputResult = _inputString;
        _ZNKPickerRealTimeResult(self);
    }
}



- (void)setTitle:(NSString *)title{
    _title = title;
    if (self.titleLabel && self.tableView) {
        CGRect titleRect = [self textRect:_title size:CGSizeMake(CGRectGetWidth(self.tableView.frame), self.tableViewRowHeight) fontSize:17];
        self.titleLabel.text = _title;
        self.titleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(titleRect) > self.tableViewRowHeight ? CGRectGetHeight(titleRect) : self.tableViewRowHeight);
    }
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





#pragma mark - 事件

- (void)buttonClick:(UIButton *)sender{
    
    switch (_type) {
        case ZNKPickerTypeObject:
        {
            if (_ZNKPickerConfirmResult) {
                _ZNKPickerConfirmResult(self);
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
                    self.dateTimeStr = [NSString stringWithFormat:@"%ld-%ld-%ld",(long)self.curYear,(long)self.curMonth,(long)self.curDay];
                    break;
                case ZNKPickerTypeTimeMode:
                    self.dateTimeStr = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)self.curHour,(long)self.curMin,(long)self.curSecond];
                    break;
                case ZNKPickerTypeDateTimeMode:
                    self.dateTimeStr = [NSString stringWithFormat:@"%ld-%ld-%ld %02ld:%02ld:%02ld",(long)self.curYear,(long)self.curMonth,(long)self.curDay,(long)self.curHour,(long)self.curMin,(long)self.curSecond];
                    break;
                case ZNKPickerTypeMonthDayMode:
                    self.dateTimeStr = [NSString stringWithFormat:@"%ld-%ld",(long)self.curMonth,(long)self.curDay];
                    break;
                case ZNKPickerTypeYearMonthMode:
                    self.dateTimeStr = [NSString stringWithFormat:@"%ld-%ld",(long)self.curYear,(long)self.curMonth];
                    break;
                case ZNKPickerTypeHourMinuteMode:
                    self.dateTimeStr = [NSString stringWithFormat:@"%02ld:%02ld",(long)self.curHour,(long)self.curMin];
                    break;
                case ZNKPickerTypeDateHourMinuteMode:
                    self.dateTimeStr = [NSString stringWithFormat:@"%ld-%ld-%ld %02ld:%02ld",(long)self.curYear,(long)self.curMonth,(long)self.curDay,(long)self.curHour,(long)self.curMin];
                    break;
                default:
                    self.dateTimeStr = [NSString stringWithFormat:@"%ld-%ld-%ld %02ld:%02ld:%02ld",(long)self.curYear,(long)self.curMonth,(long)self.curDay,(long)self.curHour,(long)self.curMin,(long)self.curSecond];
                    break;
            }
            if (_ZNKPickerConfirmResult) {
                if (self.inputTextField) {
                    _ZNKPickerConfirmResult(self);
                }else{
                    _result = _dateTimeStr;
                    _ZNKPickerConfirmResult(self);
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
    [UIView animateWithDuration:[self defaultSheetViewAnimationDuration] animations:^{
        self.sheetView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - 代理

#pragma mark - table view delegate and data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.pickerViewArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cellIdForAction";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;
    [cell.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), self.tableViewRowHeight)];
    titleLabel.text = _objectToStringConverter == nil ? [self.pickerViewArray[indexPath.row] isKindOfClass:[NSString class]] ? self.pickerViewArray[indexPath.row] : @"" : _objectToStringConverter(self.pickerViewArray[indexPath.row]);
    titleLabel.textColor = self.pickerViewTextColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.contentScaleFactor = 0.5;
    titleLabel.font = [UIFont systemFontOfSize:18];
    [cell.contentView addSubview:titleLabel];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.tableViewRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _result = self.pickerViewArray[indexPath.row];
    _index = indexPath.row;
    if (_ZNKPickerConfirmResult) {
        _ZNKPickerConfirmResult(self);
    }
    [self dismissView];
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
            return _pickerViewArray.count;
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
                if (_ZNKPickerConfirmResult) {
                    _ZNKPickerConfirmResult(self);
                    _result = [_pickerViewArray objectAtIndex:row];
                }
            } else{
                _result = self.objectToStringConverter ([_pickerViewArray objectAtIndex:row]);
                if (_ZNKPickerConfirmResult) {
                    _ZNKPickerConfirmResult(self);
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
        _yearScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.pickerContainerView.frame)*0.25, CGRectGetHeight(self.pickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeDateMode) {
        _yearScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.pickerContainerView.frame)*0.34, CGRectGetHeight(self.pickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeYearMonthMode) {
        _yearScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.pickerContainerView.frame)*0.5, CGRectGetHeight(self.pickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeDateHourMinuteMode) {
        _yearScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.pickerContainerView.frame)*0.28, CGRectGetHeight(self.pickerContainerView.frame))];
    }
    
    self.curYear = [self setNowTimeShow:0];
    [_yearScrollView setCurrentSelectPage:(self.curYear-(_minYear+2))];
    _yearScrollView.delegate = self;
    _yearScrollView.datasource = self;
    [self setAfterScrollShowView:_yearScrollView andCurrentPage:1];
    [self.pickerContainerView addSubview:_yearScrollView];
}
//设置年月日时分的滚动视图
- (void)set_monthScrollView
{
    if (_type == ZNKPickerTypeDateTimeMode) {
        _monthScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.pickerContainerView.frame)*0.25, 0, CGRectGetWidth(self.pickerContainerView.frame)*0.15, CGRectGetHeight(self.pickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeDateMode) {
        _monthScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.pickerContainerView.frame)*0.34, 0, CGRectGetWidth(self.pickerContainerView.frame)*0.33, CGRectGetHeight(self.pickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeMonthDayMode) {
        _monthScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.pickerContainerView.frame)*0, 0, CGRectGetWidth(self.pickerContainerView.frame)*0.5, CGRectGetHeight(self.pickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeYearMonthMode) {
        _monthScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.pickerContainerView.frame)*0.5, 0, CGRectGetWidth(self.pickerContainerView.frame)*0.5, CGRectGetHeight(self.pickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeDateHourMinuteMode) {
        _monthScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.pickerContainerView.frame)*0.28, 0, CGRectGetWidth(self.pickerContainerView.frame)*0.18, CGRectGetHeight(self.pickerContainerView.frame))];
    }
    
    self.curMonth = [self setNowTimeShow:1];
    [_monthScrollView setCurrentSelectPage:(self.curMonth-3)];
    _monthScrollView.delegate = self;
    _monthScrollView.datasource = self;
    [self setAfterScrollShowView:_monthScrollView andCurrentPage:1];
    [self.pickerContainerView addSubview:_monthScrollView];
}
//设置年月日时分的滚动视图
- (void)set_dayScrollView
{
    if (_type == ZNKPickerTypeDateTimeMode) {
        _dayScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.pickerContainerView.frame)*0.40, 0, CGRectGetWidth(self.pickerContainerView.frame)*0.15, CGRectGetHeight(self.pickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeDateMode) {
        _dayScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.pickerContainerView.frame)*0.67, 0, CGRectGetWidth(self.pickerContainerView.frame)*0.33, CGRectGetHeight(self.pickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeMonthDayMode) {
        _dayScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.pickerContainerView.frame)*0.5, 0, CGRectGetWidth(self.pickerContainerView.frame)*0.5, CGRectGetHeight(self.pickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeDateHourMinuteMode) {
        _dayScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.pickerContainerView.frame)*0.46, 0, CGRectGetWidth(self.pickerContainerView.frame)*0.18, CGRectGetHeight(self.pickerContainerView.frame))];
    }
    
    self.curDay = [self setNowTimeShow:2];
    [_dayScrollView setCurrentSelectPage:(self.curDay-3)];
    _dayScrollView.delegate = self;
    _dayScrollView.datasource = self;
    [self setAfterScrollShowView:_dayScrollView andCurrentPage:1];
    [self.pickerContainerView addSubview:_dayScrollView];
}
//设置年月日时分的滚动视图
- (void)set_hourScrollView
{
    if (_type == ZNKPickerTypeDateTimeMode) {
        _hourScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.pickerContainerView.frame)*0.55, 0, CGRectGetWidth(self.pickerContainerView.frame)*0.15, CGRectGetHeight(self.pickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeTimeMode) {
        _hourScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.pickerContainerView.frame)*0.34, CGRectGetHeight(self.pickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeHourMinuteMode) {
        _hourScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.pickerContainerView.frame)*0.5, CGRectGetHeight(self.pickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeDateHourMinuteMode) {
        _hourScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.pickerContainerView.frame)*0.64, 0, CGRectGetWidth(self.pickerContainerView.frame)*0.18, CGRectGetHeight(self.pickerContainerView.frame))];
    }
    
    self.curHour = [self setNowTimeShow:3];
    [_hourScrollView setCurrentSelectPage:(self.curHour-2)];
    _hourScrollView.delegate = self;
    _hourScrollView.datasource = self;
    [self setAfterScrollShowView:_hourScrollView andCurrentPage:1];
    [self.pickerContainerView addSubview:_hourScrollView];
}
//设置年月日时分的滚动视图
- (void)set_minuteScrollView
{
    if (_type == ZNKPickerTypeDateTimeMode) {
        _minuteScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.pickerContainerView.frame)*0.70, 0, CGRectGetWidth(self.pickerContainerView.frame)*0.15, CGRectGetHeight(self.pickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeTimeMode) {
        _minuteScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.pickerContainerView.frame)*0.34, 0, CGRectGetWidth(self.pickerContainerView.frame)*0.33, CGRectGetHeight(self.pickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeHourMinuteMode) {
        _minuteScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.pickerContainerView.frame)*0.5, 0, CGRectGetWidth(self.pickerContainerView.frame)*0.5, CGRectGetHeight(self.pickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeDateHourMinuteMode) {
        _minuteScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.pickerContainerView.frame)*0.82, 0, CGRectGetWidth(self.pickerContainerView.frame)*0.18, CGRectGetHeight(self.pickerContainerView.frame))];
    }
    
    self.curMin = [self setNowTimeShow:4];
    [_minuteScrollView setCurrentSelectPage:(self.curMin-2)];
    _minuteScrollView.delegate = self;
    _minuteScrollView.datasource = self;
    [self setAfterScrollShowView:_minuteScrollView andCurrentPage:1];
    [self.pickerContainerView addSubview:_minuteScrollView];
}
//设置年月日时分的滚动视图
- (void)set_secondScrollView
{
    if (_type == ZNKPickerTypeDateTimeMode) {
        _secondScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.pickerContainerView.frame)*0.85, 0, CGRectGetWidth(self.pickerContainerView.frame)*0.15, CGRectGetHeight(self.pickerContainerView.frame))];
    } else if (_type == ZNKPickerTypeTimeMode) {
        _secondScrollView = [[ZNKCycleScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.pickerContainerView.frame)*0.67, 0, CGRectGetWidth(self.pickerContainerView.frame)*0.33, CGRectGetHeight(self.pickerContainerView.frame))];
    }
    self.curSecond = [self setNowTimeShow:5];
    [_secondScrollView setCurrentSelectPage:(self.curSecond-2)];
    _secondScrollView.delegate = self;
    _secondScrollView.datasource = self;
    [self setAfterScrollShowView:_secondScrollView andCurrentPage:1];
    [self.pickerContainerView addSubview:_secondScrollView];
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
    self.dateTimeStr = selectTimeString;
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


