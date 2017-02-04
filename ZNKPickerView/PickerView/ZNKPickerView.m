//
//  ZNKPickerView.m
//  EnjoyLove
//
//  Created by HuangSam on 2017/1/12.
//  Copyright © 2017年 HuangSam. All rights reserved.
//

#import "ZNKPickerView.h"

#define znk_screenWidth [UIScreen mainScreen].bounds.size.width
#define znk_screenHeight [UIScreen mainScreen].bounds.size.height
#define znk_navigationBarHeight 64


#define LOCATION        @"Location"
#define COUNTRYREGION   @"CountryRegion"
#define STATE           @"State"
#define REGION          @"Region"
#define CITY            @"City"
#define CODE            @"-Code"
#define NAME            @"-Name"

@interface Country : NSObject<NSCoding>
/**国家代码*/
@property (nonatomic, copy) NSString *code;
/**国家名称*/
@property (nonatomic, copy) NSString *name;
/**省份列表*/
@property (nonatomic, copy) NSArray *provinceArray;

@end

@interface Province : NSObject<NSCoding>
/**省份代码*/
@property (nonatomic, copy) NSString *code;
/**省份名称*/
@property (nonatomic, copy) NSString *name;
/**城市列表*/
@property (nonatomic, copy) NSArray *cityArray;
@end

@interface City : NSObject<NSCoding>
/**城市代码*/
@property (nonatomic, copy) NSString *code;
/**城市名称*/
@property (nonatomic, copy) NSString *name;
/**区域列表*/
@property (nonatomic, copy) NSArray *regionArray;
@end

@interface Region : NSObject<NSCoding>
/**区域代码*/
@property (nonatomic, copy) NSString *code;
/**区域名称*/
@property (nonatomic, copy) NSString *name;
@end

@interface CountryPicker ()
/**国家*/
@property (nonatomic, copy) NSString *country;
/**省份*/
@property (nonatomic, copy) NSString *province;
/**城市*/
@property (nonatomic, copy) NSString *city;
/**区域*/
@property (nonatomic, copy) NSString *region;

@end

@interface CountryManager ()
/**获取全部国家*/
- (NSArray *)countries;
#if 0
/**获取全部国家 block回调*/
- (NSArray *)countries:(void(^)(NSArray *countryArray))completionHandler;
#endif
/**根据国家获取省份*/
- (Country *)countryForCountryName:(NSString *)countryName;
/**根据国家和省份获取城市*/
- (Province *)provinceForProvinceName:(NSString *)provinceName forCountryName:(NSString *)countryName;
/**根据国家省份城市获取区域*/
- (City *)cityForCityName:(NSString *)cityName forProvinceName:(NSString *)provinceName forCountryName:(NSString *)countryName;
@end

@implementation CountryManager

+ (CountryManager *)shareManager:(BOOL)kill{
    static CountryManager *manager = nil;
    @synchronized ([self class]) {
        if (kill) {
            NSLog(@"kill singleton");
            manager = nil;
        }else{
            if (!manager) {
                manager = [[CountryManager alloc] init];
            }
        }
    }
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initilizeWithResult:nil];
    }
    return self;
}


#if 0
- (NSArray *)countries:(void(^)(NSArray *countryArray))completionHandler{
    NSData *theData = [NSData dataWithContentsOfFile:[self documentPath]];
    if (theData.length > 0) {
        NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
        id result = [unArchiver decodeObjectForKey:@"CountryManager"];
        if ([result isKindOfClass:[NSArray class]]) {
            return (NSArray *)result;
        }
    }else{
        [self initilizeWithResult:^(NSArray *result) {
            if (completionHandler) {
                completionHandler(result);
            }
        }];
    }
    return [NSArray array];
}
#endif

- (NSArray *)countries{
    NSData *theData = [NSData dataWithContentsOfFile:[self documentPath]];
    if (theData.length > 0) {
        NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
        id result = [unArchiver decodeObjectForKey:@"CountryManager"];
        if ([result isKindOfClass:[NSArray class]]) {
            return (NSArray *)result;
        }
    }
    return [NSArray array];
}


- (Country *)countryForCountryName:(NSString *)countryName{
    NSArray *countryArray = [self countries];
    __block Country *currentCountry = nil;
    [countryArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[Country class]]) {
            Country *temp = (Country *)obj;
            if ([temp.name isEqualToString:countryName]) {
                currentCountry = temp;
                *stop = YES;
            }
        }
    }];
    return currentCountry;
}

- (Province *)provinceForProvinceName:(NSString *)provinceName forCountryName:(NSString *)countryName{
    Country *currentCountry = [self countryForCountryName:countryName];
    __block Province *currentProvince = nil;
    [currentCountry.provinceArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[Province class]]) {
            Province *temp = (Province *)obj;
            if ([temp.name isEqualToString:provinceName]) {
                currentProvince = temp;
                *stop = YES;
            }
        }
    }];
    return currentProvince;
}

- (City *)cityForCityName:(NSString *)cityName forProvinceName:(NSString *)provinceName forCountryName:(NSString *)countryName{
    Province *currentProvince = [self provinceForProvinceName:provinceName forCountryName:countryName];
    __block City *currentCity = nil;
    [currentProvince.cityArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[City class]]) {
            City *temp = (City *)obj;
            if ([temp.name isEqualToString:cityName]) {
                currentCity = temp;
                *stop = YES;
            }
        }
    }];
    return currentCity;
}

- (void)initilizeWithResult:(void(^)(NSArray * result))completionHandler{
    NSData *theData = [NSData dataWithContentsOfFile:[self documentPath]];
    if (theData.length > 0) {
        
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *path = [[NSBundle bundleForClass:[ZNKPickerView class]] pathForResource:@"area" ofType:@"json"];
            NSData *jsonData = [NSData dataWithContentsOfFile:path];
            id jsonResult = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
            if ([jsonResult isKindOfClass:[NSDictionary class]]) {
                NSDictionary *jsonDict = (NSDictionary *)jsonResult;
                id location = jsonDict[LOCATION];
                if ([location isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *locationDict = (NSDictionary *)location;
                    id countryArr = (NSArray *)locationDict[COUNTRYREGION];
                    if ([countryArr isKindOfClass:[NSArray class]]) {
                        [self archiveData:(NSArray *)countryArr compeltionResult:completionHandler];
                    }
                }
            }
        });
    }
}

- (void)archiveData:(NSArray *)countries compeltionResult:(void(^)(NSArray * result))completionHandler{
    NSMutableArray *countryArray = [NSMutableArray array];
    [countries enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Country *countryModel = [[Country alloc] init];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *countryDict = (NSDictionary *)obj;
            if (countryDict[CODE] && [countryDict[CODE] isKindOfClass:[NSString class]]) {
                countryModel.code = (NSString *)countryDict[CODE];
            }
            if (countryDict[NAME] && [countryDict[NAME] isKindOfClass:[NSString class]]) {
                countryModel.name = (NSString *)countryDict[NAME];
            }
            if (countryDict[STATE]) {
                if ([countryDict[STATE] isKindOfClass:[NSArray class]]) {
                    NSMutableArray *stateArray = [NSMutableArray array];
                    NSArray *stateArr = (NSArray *)countryDict[STATE];
                    [stateArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj isKindOfClass:[NSDictionary class]]) {
                            Province *provinceModel = [[Province alloc] init];
                            NSDictionary *provinceDict = (NSDictionary *)obj;
                            if (provinceDict[CODE] && [provinceDict[CODE] isKindOfClass:[NSString class]]) {
                                provinceModel.code = (NSString *)provinceDict[CODE];
                            }
                            if (provinceDict[NAME] && [provinceDict[NAME] isKindOfClass:[NSString class]]) {
                                provinceModel.name = (NSString *)provinceDict[NAME];
                            }
                            if (provinceDict[CITY] && [provinceDict[CITY] isKindOfClass:[NSArray class]]) {
                                NSArray *cityArr = (NSArray *)provinceDict[CITY];
                                NSMutableArray *cityArray = [NSMutableArray array];
                                [cityArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                    if ([obj isKindOfClass:[NSDictionary class]]) {
                                        NSDictionary *cityDict = (NSDictionary *)obj;
                                        City *cityModel = [[City alloc] init];
                                        if (cityDict[CODE] && [cityDict[CODE] isKindOfClass:[NSString class]]) {
                                            cityModel.code = (NSString *)cityDict[CODE];
                                        }
                                        if (cityDict[NAME] && [cityDict[NAME] isKindOfClass:[NSString class]]) {
                                            cityModel.name = (NSString *)cityDict[NAME];
                                        }
                                        if (cityDict[REGION] && [cityDict[REGION] isKindOfClass:[NSArray class]]) {
                                            NSArray *regionArr = (NSArray *)cityDict[REGION];
                                            NSMutableArray *regionArray = [NSMutableArray array];
                                            [regionArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                if ([obj isKindOfClass:[NSDictionary class]]) {
                                                    Region *regionModel = [[Region alloc] init];
                                                    NSDictionary *regionDict = (NSDictionary *)obj;
                                                    if (regionDict[CODE] && [regionDict[CODE] isKindOfClass:[NSString class]]) {
                                                        regionModel.code = (NSString *)regionDict[CODE];
                                                    }
                                                    if (regionDict[NAME] && [regionDict[NAME] isKindOfClass:[NSString class]]) {
                                                        regionModel.name = (NSString *)regionDict[NAME];
                                                    }
                                                    [regionArray addObject:regionModel];
                                                }
                                            }];
                                            cityModel.regionArray = [regionArray copy];
                                        }
                                        [cityArray addObject:cityModel];
                                    }
                                }];
                                provinceModel.cityArray = [cityArray copy];
                            }
                            [stateArray addObject:provinceModel];
                        }
                    }];
                    countryModel.provinceArray = [stateArray copy];

                }else if ([countryDict[STATE] isKindOfClass:[NSDictionary class]]){
                    NSMutableArray *stateArray = [NSMutableArray array];
                    NSDictionary *stateArr = (NSDictionary *)countryDict[STATE];
                    [stateArr enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                        if ([obj isKindOfClass:[NSDictionary class]]) {
                            Province *provinceModel = [[Province alloc] init];
                            NSDictionary *provinceDict = (NSDictionary *)obj;
                            if (provinceDict[CODE] && [provinceDict[CODE] isKindOfClass:[NSString class]]) {
                                provinceModel.code = (NSString *)provinceDict[CODE];
                            }
                            if (provinceDict[NAME] && [provinceDict[NAME] isKindOfClass:[NSString class]]) {
                                provinceModel.name = (NSString *)provinceDict[NAME];
                            }
                            if (provinceDict[CITY] && [provinceDict[CITY] isKindOfClass:[NSArray class]]) {
                                NSArray *cityArr = (NSArray *)provinceDict[CITY];
                                NSMutableArray *cityArray = [NSMutableArray array];
                                [cityArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                    if ([obj isKindOfClass:[NSDictionary class]]) {
                                        NSDictionary *cityDict = (NSDictionary *)obj;
                                        City *cityModel = [[City alloc] init];
                                        if (cityDict[CODE] && [cityDict[CODE] isKindOfClass:[NSString class]]) {
                                            cityModel.code = (NSString *)cityDict[CODE];
                                        }
                                        if (cityDict[NAME] && [cityDict[NAME] isKindOfClass:[NSString class]]) {
                                            cityModel.name = (NSString *)cityDict[NAME];
                                        }
                                        if (cityDict[REGION] && [cityDict[REGION] isKindOfClass:[NSArray class]]) {
                                            NSArray *regionArr = (NSArray *)cityDict[REGION];
                                            NSMutableArray *regionArray = [NSMutableArray array];
                                            [regionArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                if ([obj isKindOfClass:[NSDictionary class]]) {
                                                    Region *regionModel = [[Region alloc] init];
                                                    NSDictionary *regionDict = (NSDictionary *)obj;
                                                    if (regionDict[CODE] && [regionDict[CODE] isKindOfClass:[NSString class]]) {
                                                        regionModel.code = (NSString *)regionDict[CODE];
                                                    }
                                                    if (regionDict[NAME] && [regionDict[NAME] isKindOfClass:[NSString class]]) {
                                                        regionModel.name = (NSString *)regionDict[NAME];
                                                    }
                                                    [regionArray addObject:regionModel];
                                                }
                                            }];
                                            cityModel.regionArray = [regionArray copy];
                                        }
                                        [cityArray addObject:cityModel];
                                    }
                                }];
                                provinceModel.cityArray = [cityArray copy];
                            }
                            [stateArray addObject:provinceModel];
                        }else if ([obj isKindOfClass:[NSArray class]]){
                            NSArray *provinceArr = (NSArray *)obj;
                            [provinceArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                Province *provinceModel = [[Province alloc] init];
                                NSDictionary *provinceDict = (NSDictionary *)obj;
                                if (provinceDict[CODE] && [provinceDict[CODE] isKindOfClass:[NSString class]]) {
                                    provinceModel.code = (NSString *)provinceDict[CODE];
                                }
                                if (provinceDict[NAME] && [provinceDict[NAME] isKindOfClass:[NSString class]]) {
                                    provinceModel.name = (NSString *)provinceDict[NAME];
                                }
                                if (provinceDict[CITY] && [provinceDict[CITY] isKindOfClass:[NSArray class]]) {
                                    NSArray *cityArr = (NSArray *)provinceDict[CITY];
                                    NSMutableArray *cityArray = [NSMutableArray array];
                                    [cityArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                        if ([obj isKindOfClass:[NSDictionary class]]) {
                                            NSDictionary *cityDict = (NSDictionary *)obj;
                                            City *cityModel = [[City alloc] init];
                                            if (cityDict[CODE] && [cityDict[CODE] isKindOfClass:[NSString class]]) {
                                                cityModel.code = (NSString *)cityDict[CODE];
                                            }
                                            if (cityDict[NAME] && [cityDict[NAME] isKindOfClass:[NSString class]]) {
                                                cityModel.name = (NSString *)cityDict[NAME];
                                            }
                                            if (cityDict[REGION] && [cityDict[REGION] isKindOfClass:[NSArray class]]) {
                                                NSArray *regionArr = (NSArray *)cityDict[REGION];
                                                NSMutableArray *regionArray = [NSMutableArray array];
                                                [regionArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                    if ([obj isKindOfClass:[NSDictionary class]]) {
                                                        Region *regionModel = [[Region alloc] init];
                                                        NSDictionary *regionDict = (NSDictionary *)obj;
                                                        if (regionDict[CODE] && [regionDict[CODE] isKindOfClass:[NSString class]]) {
                                                            regionModel.code = (NSString *)regionDict[CODE];
                                                        }
                                                        if (regionDict[NAME] && [regionDict[NAME] isKindOfClass:[NSString class]]) {
                                                            regionModel.name = (NSString *)regionDict[NAME];
                                                        }
                                                        [regionArray addObject:regionModel];
                                                    }
                                                }];
                                                cityModel.regionArray = [regionArray copy];
                                            }
                                            [cityArray addObject:cityModel];
                                        }
                                    }];
                                    provinceModel.cityArray = [cityArray copy];
                                }
                                [stateArray addObject:provinceModel];
                            }];
                        }
                    }];
                    countryModel.provinceArray = [stateArray copy];
                }
            }
        }
        [countryArray addObject:countryModel];
    }];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:countryArray forKey:@"CountryManager"];
    [archiver finishEncoding];
    BOOL success = [data writeToFile:[self documentPath] atomically:YES];
    if (success) {
        NSLog(@"success");
        if (completionHandler) {
            completionHandler(countryArray);
        }
    }else{
        NSLog(@"failed");
    }
}

- (NSString *)documentPath{
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [filePath stringByAppendingPathComponent:@"CountryManager.archive"];
}

@end



@implementation Country

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.code = @"";
        self.name = @"";
        self.provinceArray = @[];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        id codeCoder = [coder decodeObjectForKey:@"CountryCode"];
        if ([codeCoder isKindOfClass:[NSString class]]) {
            self.code = (NSString *)codeCoder;
        }
        id nameCoder = [coder decodeObjectForKey:@"CountryName"];
        if ([nameCoder isKindOfClass:[NSString class]]) {
            self.name = (NSString *)nameCoder;
        }
        id arrayCoder = [coder decodeObjectForKey:@"CountryArray"];
        if ([arrayCoder isKindOfClass:[NSArray class]]) {
            self.provinceArray = (NSArray *)arrayCoder;
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.code forKey:@"CountryCode"];
    [coder encodeObject:self.name forKey:@"CountryName"];
    [coder encodeObject:self.provinceArray forKey:@"CountryArray"];
}

@end



@implementation Province

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.code = @"";
        self.name = @"";
        self.cityArray = @[];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        id codeCoder = [coder decodeObjectForKey:@"ProvinceCode"];
        if ([codeCoder isKindOfClass:[NSString class]]) {
            self.code = (NSString *)codeCoder;
        }
        id nameCoder = [coder decodeObjectForKey:@"ProvinceName"];
        if ([nameCoder isKindOfClass:[NSString class]]) {
            self.name = (NSString *)nameCoder;
        }
        id arrayCoder = [coder decodeObjectForKey:@"ProvinceArray"];
        if ([arrayCoder isKindOfClass:[NSArray class]]) {
            self.cityArray = (NSArray *)arrayCoder;
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.code forKey:@"ProvinceCode"];
    [coder encodeObject:self.name forKey:@"ProvinceName"];
    [coder encodeObject:self.cityArray forKey:@"ProvinceArray"];
}

@end


@implementation City

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.code = @"";
        self.name = @"";
        self.regionArray = @[];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        id codeCoder = [coder decodeObjectForKey:@"CityCode"];
        if ([codeCoder isKindOfClass:[NSString class]]) {
            self.code = (NSString *)codeCoder;
        }
        id nameCoder = [coder decodeObjectForKey:@"CityName"];
        if ([nameCoder isKindOfClass:[NSString class]]) {
            self.name = (NSString *)nameCoder;
        }
        id arrayCoder = [coder decodeObjectForKey:@"CityArray"];
        if ([arrayCoder isKindOfClass:[NSArray class]]) {
            self.regionArray = (NSArray *)arrayCoder;
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.code forKey:@"CityCode"];
    [coder encodeObject:self.name forKey:@"CityName"];
    [coder encodeObject:self.regionArray forKey:@"CityArray"];
}

@end



@implementation Region

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.code = @"";
        self.name = @"";
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        id codeCoder = [coder decodeObjectForKey:@"RegionCode"];
        if ([codeCoder isKindOfClass:[NSString class]]) {
            self.code = (NSString *)codeCoder;
        }
        id nameCoder = [coder decodeObjectForKey:@"RegionName"];
        if ([nameCoder isKindOfClass:[NSString class]]) {
            self.name = (NSString *)nameCoder;
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.code forKey:@"RegionCode"];
    [coder encodeObject:self.name forKey:@"RegionName"];
}

@end

@implementation CountryPicker

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.country = @"";
        self.province = @"";
        self.city = @"";
        self.region = @"";
    }
    return self;
}


@end


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
        CGFloat keyboardMinY = znk_screenHeight - CGRectGetHeight(keyboardFrame);
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
NSString * const ZNKPickerViewSeparateDateFormat            = @"ZNKPickerViewSeparateDateFormat";
NSString * const ZNKPickerViewSeparateTimeFormat            = @"ZNKPickerViewSeparateTimeFormat";

NSString * const ZNKToolbarBackgroundColor          = @"ZNKToolbarBackgroundColor";
NSString * const ZNKToolbarHasInput                 = @"ZNKToolbarHasInput";
NSString * const ZNKToolbarInputLeftView            = @"ZNKToolbarInputLeftView";
NSString * const ZNKToolbarInputPlachodler          = @"ZNKToolbarInputPlachodler";
NSString * const ZNKToolbarBackgroundImage          = @"ZNKToolbarBackgroundImage";
NSString * const ZNKToolbarTitle                    = @"ZNKToolbarTitle";
NSString * const ZNKToolbarTitleColor               = @"ZNKToolbarTitleColor";
NSString * const ZNKToolbarTitleMaxHeight           = @"ZNKToolbarTitleMaxHeight";
NSString * const ZNKToolbarMessageMaxHeight         = @"ZNKToolbarMessageMaxHeight";
NSString * const ZNKToolbarMessage                  = @"ZNKToolbarMessage";
NSString * const ZNKToolbarMessageColor             = @"ZNKToolbarMessageColor";
NSString * const ZNKConfirmButtonTitle              = @"ZNKConfirmButtonTitle";
NSString * const ZNKConfirmButtonTitleColor         = @"ZNKConfirmButtonTitleColor";

NSString * const ZNKCanScroll                       = @"ZNKCanScroll";
NSString * const ZNKVerticalScrollIndicator         = @"ZNKVerticalScrollIndicator";
NSString * const ZNKTableRowHeight                  = @"ZNKTableRowHeight";
NSString * const ZNKTextAlignment                   = @"ZNKTextAlignment";

NSString * const ZNKCityPickerChinaOnly             = @"ZNKCityPickerChinaOnly";

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
/**日期格式*/
@property (nonatomic, copy) NSString *pickerViewDateFormat;
/**时间格式*/
@property (nonatomic, copy) NSString *pickerViewTimeFormat;
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
/**垂直分隔线*/
@property (nonatomic, strong) UIView *verticalLine;
/**水平分隔线*/
@property (nonatomic, strong) UIView *horizontalLine;
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
@property (nonatomic, assign) NSInteger maxYear;
/**最小年份*/
@property (nonatomic, assign) NSInteger minYear;
/**标题颜色*/
@property (nonatomic, strong) UIColor *titleColor;
/**message颜色*/
@property (nonatomic, strong) UIColor *messageColor;
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

#pragma mark - 城市选择器
/**国家区域数组*/
//@property (nonatomic, strong) NSArray *countryRegion;
/**仅显示中国的城市*/
@property (nonatomic, assign) BOOL chinaOnly;
/**国家数组*/
@property (nonatomic, strong) NSArray *countryArray;
/**省份数组*/
@property (nonatomic, strong) NSArray *provinceArray;
/**城市数组*/
@property (nonatomic, strong) NSArray *cityArray;
/**区域数组*/
@property (nonatomic, strong) NSArray *regionArray;
/**国家选择结果*/
@property (nonatomic, strong) CountryPicker *pickerCountry;

#pragma mark - 选择结果
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
        case ZNKPickerTypeArea:
        {
            [CountryManager shareManager:NO];
            [self initializeForArea];
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
    if (!self.pickerViewArray) {
        return;
    }
    
    self.sheetView.frame = CGRectMake(0, znk_screenHeight, znk_screenWidth, [self defaultSheetViewHeight]);
    self.toolbarContainerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.sheetView.frame), [self defaultToolbarHeight]);
    [self.toolbarContainerView addSubview:self.pickerToolbar];
    
    self.cancelButton.frame = CGRectMake(0, CGRectGetHeight(self.sheetView.frame) - 44, CGRectGetWidth(self.sheetView.frame), [self defaultToolbarHeight]);
    CGFloat pickerViewMinY = CGRectGetMaxY(self.pickerToolbar.frame) + [self defaultToolbarPickerMargin];
    CGFloat pickerViewHeight = CGRectGetHeight(self.sheetView.frame) - CGRectGetHeight(self.pickerToolbar.frame) - CGRectGetHeight(self.cancelButton.frame) - [self defaultPickerAndCancelButton];
    
    
    
    self.pickerView.frame = CGRectMake(0, pickerViewMinY, CGRectGetWidth(self.sheetView.frame), pickerViewHeight);

    [self addSubview:self.sheetView];
    [self.sheetView addSubview:self.toolbarContainerView];
    [self.sheetView addSubview:self.pickerView];
    [self.sheetView addSubview:self.cancelButton];
    
    [UIView animateWithDuration:[self defaultSheetViewAnimationDuration] animations:^{
        self.sheetView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.sheetView.frame));
    }];
    
    if (self.objectToStringConverter == nil) {
        
        if (_ZNKPickerRealTimeResult) {
            [self formatResult:@"" selectedIndex:self.selectedIndex selectObject:[self.pickerViewArray objectAtIndex:self.selectedIndex]];
            _ZNKPickerRealTimeResult(self);
        }
    } else{
        if (_ZNKPickerRealTimeResult) {
            [self formatResult:@"" selectedIndex:self.selectedIndex selectObject:self.objectToStringConverter ([self.pickerViewArray objectAtIndex:self.selectedIndex])];
            _ZNKPickerRealTimeResult(self);
        }
    }
}

#pragma mark - 日期

- (void)initializeForDate{
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"yyyy%@MM%@dd HH%@mm%@ss",self.pickerViewDateFormat,self.pickerViewDateFormat,self.pickerViewTimeFormat,self.pickerViewTimeFormat]];
    self.dateTimeStr = [dateFormatter stringFromDate:self.defaultDate];
    
    self.sheetView.frame = CGRectMake(0, znk_screenHeight, znk_screenWidth, [self defaultSheetViewHeight]);
    self.toolbarContainerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.sheetView.frame), [self defaultToolbarHeight]);
    
    
    self.pickerToolbar.frame = CGRectMake(10, 0, CGRectGetWidth(self.toolbarContainerView.frame) - 20, CGRectGetHeight(self.toolbarContainerView.frame));
    
    self.cancelButton.frame = CGRectMake(0, CGRectGetHeight(self.sheetView.frame) - 44, CGRectGetWidth(self.sheetView.frame), 44);
    CGFloat pickerViewMinY = CGRectGetMaxY(self.pickerToolbar.frame) + [self defaultToolbarPickerMargin];
    CGFloat pickerViewHeight = CGRectGetHeight(self.sheetView.frame) - CGRectGetHeight(self.pickerToolbar.frame) - CGRectGetHeight(self.cancelButton.frame) - [self defaultPickerAndCancelButton];
    
    
    self.pickerContainerView.frame = CGRectMake(0, pickerViewMinY, CGRectGetWidth(self.sheetView.frame), pickerViewHeight);
    
    [self addSubview:self.sheetView];
    [self.sheetView addSubview:self.pickerContainerView];
    [self.sheetView addSubview:self.toolbarContainerView];
    [self.toolbarContainerView addSubview:self.pickerToolbar];
    [self.sheetView addSubview:self.cancelButton];
    
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
    
    if ([self.title isEqualToString:@""] && [self.message isEqualToString:@""] && self.pickerViewArray.count == 0) {
        return;
    }
    
    CGFloat titleHeight = 0;
    if (![self.title isEqualToString:@""]) {
        titleHeight = CGRectGetHeight(self.titleLabel.frame);
    }
    
    CGFloat messageHeight = 0;
    if (![self.message isEqualToString:@""]) {
        messageHeight = CGRectGetHeight(self.messageLabel.frame);
    }
    
    CGFloat totalViewHeight = [self defaultToolbarHeight] + titleHeight + messageHeight + self.tableViewRowHeight + [self defaultToolbarPickerMargin] + [self defaultPickerAndCancelButton];
    
    CGFloat pickerViewMinY = titleHeight + messageHeight + [self defaultToolbarPickerMargin];
    NSInteger arrayCount = self.pickerViewArray.count;
    CGFloat pickerViewHeight = self.tableViewRowHeight * arrayCount >=3 ? self.tableViewRowHeight * 3 : self.tableViewRowHeight * arrayCount;
    if (self.canScroll) {
        totalViewHeight = [self defaultToolbarHeight] + titleHeight + messageHeight + (self.tableViewRowHeight * arrayCount >= self.tableViewRowHeight * 3 ? self.tableViewRowHeight * 3 : self.tableViewRowHeight * arrayCount) + [self defaultToolbarPickerMargin] + [self defaultPickerAndCancelButton];
        pickerViewHeight = self.tableViewRowHeight * arrayCount >= self.tableViewRowHeight * 3 ? self.tableViewRowHeight * 3 : self.tableViewRowHeight * arrayCount;
        self.tableView.scrollEnabled = YES;
        self.tableView.showsVerticalScrollIndicator = self.verticalScrollIndicator;
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
    self.titleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.sheetView.frame), CGRectGetHeight(self.titleLabel.frame));
    self.messageLabel.frame = CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), CGRectGetWidth(self.sheetView.frame), CGRectGetHeight(self.messageLabel.frame));
    self.cancelButton.frame = CGRectMake(0, CGRectGetHeight(self.sheetView.frame) - [self defaultToolbarHeight], CGRectGetWidth(self.sheetView.frame), [self defaultToolbarHeight]);
    
    self.tableView.frame = CGRectMake(0, pickerViewMinY, CGRectGetWidth(self.sheetView.frame), pickerViewHeight);
    
    [self addSubview:self.sheetView];
    [self.sheetView addSubview:self.titleLabel];
    [self.sheetView addSubview:self.messageLabel];
    [self.sheetView addSubview:self.cancelButton];
    [self.sheetView addSubview:self.tableView];
    
    [UIView animateWithDuration:[self defaultSheetViewAnimationDuration] animations:^{
        self.sheetView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.sheetView.frame));
    }];
    
}



#pragma mark - 类似系统actionalert

- (void)initializeForActionAlert{
    if ([self.title isEqualToString:@""] && [self.message isEqualToString:@""] && self.pickerViewArray.count == 0) {
        return;
    }
    
    CGFloat titleHeight = 0;
    if (![self.title isEqualToString:@""]) {
        titleHeight = CGRectGetHeight(self.titleLabel.frame);
    }
    
    CGFloat messageHeight = 0;
    if (![self.message isEqualToString:@""]) {
        messageHeight = CGRectGetHeight(self.messageLabel.frame);
    }
    CGFloat pickerViewMinY = titleHeight + messageHeight + [self defaultToolbarPickerMargin];
    CGFloat tableHeight = self.pickerViewArray.count * self.tableViewRowHeight > self.tableViewRowHeight * 2 ? self.tableViewRowHeight * 2 : self.pickerViewArray.count * self.tableViewRowHeight - (2 * [self defaultToolbarPickerMargin]);
    
    CGPoint sheetViewCenter = CGPointMake(znk_screenWidth / 2, znk_screenHeight / 2);
    CGFloat sheetViewWidth = [self defaultAlertSheetViewWidth];
    CGFloat sheetViewHeight = titleHeight + messageHeight + tableHeight + 2 * [self defaultToolbarPickerMargin] + [self defaultButtonHeight];
    
    
    self.sheetView.frame = CGRectMake(sheetViewCenter.x - sheetViewWidth / 2, sheetViewCenter.y - sheetViewHeight / 2, 0, 0);
    
    self.titleLabel.frame = CGRectMake(0, 0, sheetViewWidth, CGRectGetHeight(self.titleLabel.frame));
    
    self.messageLabel.frame = CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), sheetViewWidth, CGRectGetHeight(self.messageLabel.frame));
    
    self.tableView.scrollEnabled = YES;
    self.tableView.frame = CGRectMake(0, pickerViewMinY, sheetViewWidth, tableHeight);
    
    self.cancelButton.frame = CGRectMake(0, sheetViewHeight - [self defaultButtonHeight], sheetViewWidth / 2, [self defaultButtonHeight]);
    self.confirmButton.frame = CGRectMake(CGRectGetMaxX(self.cancelButton.frame), CGRectGetMinY(self.cancelButton.frame), CGRectGetWidth(self.cancelButton.frame), CGRectGetHeight(self.cancelButton.frame));
    
    self.verticalLine.frame = CGRectMake(CGRectGetMaxX(self.cancelButton.frame), CGRectGetMinY(self.cancelButton.frame), 0.5, CGRectGetHeight(self.cancelButton.frame));
    self.horizontalLine.frame = CGRectMake(0, sheetViewWidth / 2, sheetViewWidth, 0.5);
    
    [self addSubview:self.sheetView];
    [self.sheetView addSubview:self.tableView];
    [self.sheetView addSubview:self.titleLabel];
    [self.sheetView addSubview:self.messageLabel];
    [self.sheetView addSubview:self.cancelButton];
    [self.sheetView addSubview:self.confirmButton];
    [self.sheetView addSubview:self.verticalLine];
    [self.sheetView addSubview:self.horizontalLine];
    
    
    [UIView animateWithDuration:[self defaultSheetViewAnimationDuration] animations:^{
//        self.sheetView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.sheetView.frame));
        self.sheetView.frame = CGRectMake(sheetViewCenter.x - sheetViewWidth / 2, sheetViewCenter.y - sheetViewHeight / 2, sheetViewWidth, sheetViewHeight);
    }];
    
}

#pragma mark - 地区选择器

- (void)initializeForArea{
    self.countryArray = [[CountryManager shareManager:NO] countries];
    if (self.countryArray.count == 0) {
#if 0
        dispatch_async(dispatch_get_main_queue(), ^{
            __weak typeof(self) weakSelf = self;
            [[CountryManager shareManager:NO] countries:^(NSArray *countryArray) {
                weakSelf.sheetView.frame = CGRectMake(0, znk_screenHeight, znk_screenWidth, [weakSelf defaultSheetViewHeight]);
                weakSelf.toolbarContainerView.frame = CGRectMake(0, 0, CGRectGetWidth(weakSelf.sheetView.frame), [weakSelf defaultToolbarHeight]);
                [self.toolbarContainerView addSubview:weakSelf.pickerToolbar];
                
                weakSelf.cancelButton.frame = CGRectMake(0, CGRectGetHeight(weakSelf.sheetView.frame) - 44, CGRectGetWidth(weakSelf.sheetView.frame), [weakSelf defaultToolbarHeight]);
                CGFloat pickerViewMinY = CGRectGetMaxY(weakSelf.pickerToolbar.frame) + [weakSelf defaultToolbarPickerMargin];
                CGFloat pickerViewHeight = CGRectGetHeight(weakSelf.sheetView.frame) - CGRectGetHeight(weakSelf.pickerToolbar.frame) - CGRectGetHeight(weakSelf.cancelButton.frame) - [weakSelf defaultPickerAndCancelButton];
                
                
                weakSelf.pickerView.frame = CGRectMake(0, pickerViewMinY, CGRectGetWidth(weakSelf.sheetView.frame), pickerViewHeight);
                
                [weakSelf addSubview:weakSelf.sheetView];
                [weakSelf.sheetView addSubview:weakSelf.toolbarContainerView];
                [weakSelf.sheetView addSubview:weakSelf.pickerView];
                [weakSelf.sheetView addSubview:weakSelf.cancelButton];
                
                [UIView animateWithDuration:[weakSelf defaultSheetViewAnimationDuration] animations:^{
                    weakSelf.sheetView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(weakSelf.sheetView.frame));
                }];
            }];
        });
#endif
    }else{
        self.pickerCountry = [[CountryPicker alloc] init];
        if (self.chinaOnly) {
            Country *currentCountry = [[CountryManager shareManager:NO] countryForCountryName:@"中国"];
            self.provinceArray = currentCountry.provinceArray;
            
            Province *currentProvince = (Province *)[self.provinceArray firstObject];
            self.cityArray = currentProvince.cityArray;
            
            City *currentCity = (City *)[self.cityArray firstObject];
            self.regionArray = currentCity.regionArray;
            self.pickerCountry.country = @"中国";
            self.pickerCountry.province = currentProvince.name;
            self.pickerCountry.city = currentCity.name;
            Region *currentRegion = (Region *)[self.regionArray firstObject];
            self.pickerCountry.region = currentRegion.name;
        }else{
            Country *currentCountry = (Country *)[self.countryArray firstObject];
            self.provinceArray = currentCountry.provinceArray;
            
            Province *currentProvince = (Province *)[self.provinceArray firstObject];
            self.cityArray = currentProvince.cityArray;
            
            City *currentCity = (City *)[self.cityArray firstObject];
            self.regionArray = currentCity.regionArray;
            
            self.pickerCountry.country = currentCountry.name;
            self.pickerCountry.province = currentProvince.name;
            self.pickerCountry.city = currentCity.name;
            Region *currentRegion = (Region *)[self.regionArray firstObject];
            self.pickerCountry.region = currentRegion.name;
        }
        
        self.sheetView.frame = CGRectMake(0, znk_screenHeight, znk_screenWidth, [self defaultSheetViewHeight]);
        self.toolbarContainerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.sheetView.frame), [self defaultToolbarHeight]);
        [self.toolbarContainerView addSubview:self.pickerToolbar];
        
        self.cancelButton.frame = CGRectMake(0, CGRectGetHeight(self.sheetView.frame) - 44, CGRectGetWidth(self.sheetView.frame), [self defaultToolbarHeight]);
        CGFloat pickerViewMinY = CGRectGetMaxY(self.pickerToolbar.frame) + [self defaultToolbarPickerMargin];
        CGFloat pickerViewHeight = CGRectGetHeight(self.sheetView.frame) - CGRectGetHeight(self.pickerToolbar.frame) - CGRectGetHeight(self.cancelButton.frame) - [self defaultPickerAndCancelButton] - [self defaultToolbarPickerMargin];
        
        
        self.pickerView.frame = CGRectMake(0, pickerViewMinY, CGRectGetWidth(self.sheetView.frame), pickerViewHeight);
        self.pickerView.layer.frame = CGRectMake(0, pickerViewMinY, CGRectGetWidth(self.sheetView.frame), pickerViewHeight);
        [self.pickerView selectRow:0 inComponent:0 animated:YES];
        
        [self addSubview:self.sheetView];
        [self.sheetView addSubview:self.toolbarContainerView];
        [self.sheetView addSubview:self.pickerView];
        [self.sheetView addSubview:self.cancelButton];
        
        [UIView animateWithDuration:[self defaultSheetViewAnimationDuration] animations:^{
            self.sheetView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.sheetView.frame));
        }];
        
        if (_ZNKPickerRealTimeResult) {
            [self formatResult:@"" selectedIndex:-1 selectObject:self.pickerCountry];
            _ZNKPickerRealTimeResult(self);
        }
    }
    
}

- (CGRect)textRect:(NSString *)txt size:(CGSize)s fontSize:(CGFloat)f {
    return [txt boundingRectWithSize:s options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:f]} context:nil];
}

- (void)formatResult:(NSString *)input selectedIndex:(NSInteger)index selectObject:(id)obj{
    _index = index;
    _result = obj;
    _inputResult = input;
}

#pragma mark - getter

#pragma mark - 配置项

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

#pragma mark - 遮罩视图透明度

- (CGFloat)coverViewAlpha{
    if (_options[ZNKCoverViewAlpha] != nil && [_options[ZNKCoverViewAlpha] isKindOfClass:[NSNumber class]]) {
        return ((NSNumber *)_options[ZNKCoverViewAlpha]).floatValue;
    }
    return 0.1;
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

#pragma mark - 默认sheet view宽度

- (CGFloat)defaultAlertSheetViewWidth{
    return 250.0f;
}

#pragma mark - 默认弹出时间

- (CGFloat)defaultSheetViewAnimationDuration{
    return 0.25f;//0.25
}

#pragma mark - 默认工具栏高度

- (CGFloat)defaultToolbarHeight{
    return 44.0f;
}

#pragma mark - 默认按钮高度

- (CGFloat)defaultButtonHeight{
    return 30.0f;
}

#pragma mark - title 最大高度

- (CGFloat)titleMaxHeight{
    if (_options[ZNKToolbarTitleMaxHeight] && [_options[ZNKToolbarTitleMaxHeight] isKindOfClass:[NSNumber class]]) {
        CGFloat maxHeight = ((NSNumber *)_options[ZNKToolbarTitleMaxHeight]).floatValue;
        CGFloat result = maxHeight > 120.0f ? 120.0f : maxHeight;
        return result;
    }
    return 60.0f;
}

#pragma mark - message 最大高度

- (CGFloat)messageMaxHeight{
    if (_options[ZNKToolbarMessageMaxHeight] && [_options[ZNKToolbarMessageMaxHeight] isKindOfClass:[NSNumber class]]) {
        CGFloat maxHeight = ((NSNumber *)_options[ZNKToolbarMessageMaxHeight]).floatValue;
        CGFloat result = maxHeight > 150.0f ? 150.0f : maxHeight;
        return result;
    }
    return 75.0f;
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

#pragma mark - title 颜色

- (UIColor *)titleColor{
    if (_options[ZNKToolbarTitleColor] && [_options[ZNKToolbarTitleColor] isKindOfClass:[UIColor class]]) {
        return (UIColor *)_options[ZNKToolbarTitleColor];
    }
    return [UIColor blackColor];
}

- (UIColor *)messageColor{
    if (_options[ZNKToolbarMessageColor] && [_options[ZNKToolbarMessageColor] isKindOfClass:[UIColor class]]) {
        return (UIColor *)_options[ZNKToolbarMessageColor];
    }
    return [UIColor blackColor];
}

#pragma mark - 输入框左侧视图

- (UIView *)inputLeftView{
    if (_options[ZNKToolbarInputLeftView] && [_options[ZNKToolbarInputLeftView] isKindOfClass:[UIView class]]) {
        return (UIView *)_options[ZNKToolbarInputLeftView];
    }
    if (!_inputLeftView) {
        UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, [self defaultToolbarHeight])];
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

#pragma mark - 选择器背景颜色

- (UIColor *)pickerBackgroundColor{
    if (_options[ZNKPickerViewBackgroundColor] && [_options[ZNKPickerViewBackgroundColor] isKindOfClass:[UIColor class]]) {
        return (UIColor *)_options[ZNKPickerViewBackgroundColor];
    }
    return [UIColor whiteColor];
}

#pragma mark - 选择器背景图片

- (UIImage *)pickerBackgroundImage{
    if (_options[ZNKPickerViewBackgroundImage] && [_options[ZNKPickerViewBackgroundImage] isKindOfClass:[UIImage class]]) {
        return (UIImage *)_options[ZNKPickerViewBackgroundImage];
    }
    if (!_pickerBackgroundImage) {
        _pickerBackgroundImage = [UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(1.0f, 1.0f)];
    }
    return _pickerBackgroundImage;
}

#pragma mark - 日期格式

- (NSString *)pickerViewDateFormat{
    if (_options[ZNKPickerViewSeparateDateFormat] && [_options[ZNKPickerViewSeparateDateFormat] isKindOfClass:[NSString class]]) {
        return (NSString *)_options[ZNKPickerViewSeparateDateFormat];
    }
    return @"-";
}

#pragma mark - 时间格式

- (NSString *)pickerViewTimeFormat{
    if (_options[ZNKPickerViewSeparateTimeFormat] && [_options[ZNKPickerViewSeparateTimeFormat] isKindOfClass:[NSString class]]) {
        return (NSString *)_options[ZNKPickerViewSeparateTimeFormat];
    }
    return @":";
}

#pragma mark - 日期选择器默认日期

- (NSDate *)defaultDate{
    if (_options[ZNKDefaultSelectedObject] && [_options[ZNKDefaultSelectedObject] isKindOfClass:[NSDate class]]) {
        return _options[ZNKDefaultSelectedObject];
    }
    return [NSDate date];
}

#pragma mark - 表格选择器是否可以滚动

- (BOOL)canScroll{
    if (_options[ZNKCanScroll] && [_options[ZNKCanScroll] isKindOfClass:[NSNumber class]]) {
        return ((NSNumber *)_options[ZNKCanScroll]).boolValue;
    }
    return NO;
}

#pragma mark - 表格选择器是否显示滚动条

- (BOOL)verticalScrollIndicator{
    if (_options[ZNKVerticalScrollIndicator] && [_options[ZNKVerticalScrollIndicator] isKindOfClass:[NSNumber class]]) {
        return ((NSNumber *)_options[ZNKVerticalScrollIndicator]).boolValue;
    }
    return YES;
}

#pragma mark - 表格选择器高度

- (CGFloat)tableViewRowHeight{
    if ([_options[ZNKTableRowHeight] isKindOfClass:[NSNumber class]]) {
        return ((NSNumber *)_options[ZNKTableRowHeight]).floatValue;
    }
    return 45.0;
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
        if ([self.pickerViewArray indexOfObject:self.selectedObject] > 0 && [self.pickerViewArray indexOfObject:self.selectedObject] < self.pickerViewArray.count) {
            NSInteger index = [self.pickerViewArray indexOfObject:self.selectedObject];
            [self formatResult:@"" selectedIndex:index selectObject:self.selectedObject];
            return index;
        }
    }
    return 0;
}

#pragma mark - 选择器默认选中对象

- (id)selectedObject{
    return _options[ZNKDefaultSelectedObject];
}

#pragma mark - 仅仅显示中国

- (BOOL)chinaOnly{
    if (_options[ZNKCityPickerChinaOnly] && [_options[ZNKCityPickerChinaOnly] isKindOfClass:[NSNumber class]]) {
        return ((NSNumber *)_options[ZNKCityPickerChinaOnly]).boolValue;
    }
    return YES;
}



#pragma mark - 选择器字体字号

- (UIFont *)pickerViewFont{
    if (_options[ZNKPickerViewFont] && [_options[ZNKPickerViewFont] isKindOfClass:[UIFont class]]) {
        return (UIFont *)_options[ZNKPickerViewFont];
    }
    return [UIFont systemFontOfSize:13];
}

#pragma mark - 选择器字体停靠

- (NSInteger)pickerViewTextAlignment{
    if ( _options[ZNKTextAlignment] && [ _options[ZNKTextAlignment] isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)_options[ZNKTextAlignment] integerValue];
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
    if (_options[ZNKPickerViewBackgroundColor] && [_options[ZNKPickerViewBackgroundColor] isKindOfClass:[UIColor class]]) {
        return (UIColor *)_options[ZNKPickerViewBackgroundColor];
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

#pragma mark - title frame

- (CGRect)titleRect{
    if (![self.title isEqualToString:@""]) {
        CGRect titleR = [self textRect:self.title size:CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) fontSize:18];
        return CGRectMake(0, 0, CGRectGetWidth(titleR), CGRectGetHeight(titleR) > self.tableViewRowHeight ? CGRectGetHeight(titleR) > [self titleMaxHeight] ? [self titleMaxHeight] : CGRectGetHeight(titleR) : self.tableViewRowHeight);
    }
    return CGRectZero;
}

#pragma mark - message frame

- (CGRect)messageRect{
    if (![self.message isEqualToString:@""]) {
        CGRect messageR = [self textRect:self.message size:CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) fontSize:13];
        return CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), CGRectGetWidth(messageR), CGRectGetHeight(messageR) > self.tableViewRowHeight ? CGRectGetHeight(messageR) > [self messageMaxHeight] ? [self messageMaxHeight] : CGRectGetHeight(messageR) : self.tableViewRowHeight);
    }
    return CGRectZero;
}

#pragma mark - 显示title

- (NSString *)title{
    
    if (_options[ZNKToolbarTitle] && [_options[ZNKToolbarTitle] isKindOfClass:[NSString class]]) {
        return (NSString *)_options[ZNKToolbarTitle];;
    }
    return @"";
}

- (NSString *)message{
    if (_options[ZNKToolbarMessage] && [_options[ZNKToolbarMessage] isKindOfClass:[NSString class]]) {
        return (NSString *)_options[ZNKToolbarMessage];
    }
    return @"";
}

#pragma mark - setting

#pragma mark - 选择日期

- (void)setDateTimeStr:(NSString *)dateTimeStr{
    _dateTimeStr = dateTimeStr;
    if (_ZNKPickerRealTimeResult) {
        _result = _dateTimeStr;
        NSString *input = @"";
        if (self.inputTextField) {
            input = self.inputTextField.text;
        }
        [self formatResult:input selectedIndex:0 selectObject:_dateTimeStr];
        _ZNKPickerRealTimeResult(self);
    }
}


#pragma mark - 控件

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



#pragma mark - 弹框视图

- (UIView *)sheetView{
    if (!_sheetView) {
        _sheetView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _sheetView.userInteractionEnabled = YES;
        _sheetView.backgroundColor = self.sheetViewBackgroundColor;
    }
    return _sheetView;
}



#pragma mark - tool bar / title message 

#pragma mark - 工具栏容器视图

- (UIView *)toolbarContainerView{
    if (!_toolbarContainerView) {
        _toolbarContainerView = [[UIImageView alloc] init];
        _toolbarContainerView.userInteractionEnabled = YES;
        _toolbarContainerView.backgroundColor = self.toolbarContainerViewBackgroundColor;
        _toolbarContainerView.image = self.toolbarContainerViewBackgroundImage;
    }
    return _toolbarContainerView;
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
        _inputTextField.clearButtonMode = UITextFieldViewModeUnlessEditing;
    }
    return _inputTextField;
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


#pragma mark - 选择器容器

- (UIImageView *)pickerContainerView{
    if (!_pickerContainerView) {
        _pickerContainerView = [[UIImageView alloc] init];
        _pickerContainerView.userInteractionEnabled = YES;
        _pickerContainerView.backgroundColor = self.pickerBackgroundColor;
        _pickerContainerView.image = self.pickerBackgroundImage;
    }
    return _pickerContainerView;
}



#pragma mark - 表格选择器

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

#pragma mark - 选择器取消按钮

- (UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_cancelButton addTarget:self action:@selector(dismissView) forControlEvents:(UIControlEventTouchUpInside)];
        _cancelButton.backgroundColor = self.pickerViewBackgroundColor;
        [_cancelButton setTitle:self.cancelButtonTitle  forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
    return _cancelButton;
}

#pragma mark - 工具栏确定按钮

- (UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_confirmButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        _confirmButton.backgroundColor =  self.pickerViewBackgroundColor;
        [_confirmButton setTitle:self.confirmButtonTitle forState:UIControlStateNormal];
        [_confirmButton setTitleColor:self.confirmButtonTitleColor forState:UIControlStateNormal];
    }
    return _confirmButton;
}

#pragma mark - 选择器

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

#pragma mark - 提示title label

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:self.titleRect];
        _titleLabel.font = [UIFont boldSystemFontOfSize:18];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.contentScaleFactor = 0.8;
        _titleLabel.numberOfLines = 0;
        _titleLabel.text = self.title ? self.title : @"";
        _titleLabel.textColor = self.titleColor;
        _titleLabel.backgroundColor = self.toolbarContainerViewBackgroundColor;
    }
    return _titleLabel;
}

#pragma mark - 提示message label

- (UILabel *)messageLabel{
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] initWithFrame:self.messageRect];
        _messageLabel.text = self.message ? self.message : @"";
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.font = [UIFont systemFontOfSize:12];
        _messageLabel.textColor = self.messageColor;
        _messageLabel.numberOfLines = 0;
        _messageLabel.adjustsFontSizeToFitWidth = YES;
        _messageLabel.contentScaleFactor = 0.5;
        _messageLabel.backgroundColor = self.toolbarContainerViewBackgroundColor;
        
    }
    return _messageLabel;
}

#pragma mark - 垂直分割线

- (UIView *)verticalLine{
    if (_verticalLine) {
        _verticalLine = [[UIView alloc] init];
        _verticalLine.backgroundColor = [UIColor colorFromHexString:@"cccccc"];
    }
    return _verticalLine;
}

#pragma mark - 水平分割线

- (UIView *)horizontalLine{
    if (_horizontalLine) {
        _horizontalLine = [[UIView alloc] init];
        _horizontalLine.backgroundColor = [UIColor colorFromHexString:@"cccccc"];
    }
    return _horizontalLine;
}

#pragma mark - 事件

- (void)buttonClick:(UIButton *)sender{
    if (self.inputTextField && self.hasInput) {
        [self.inputTextField resignFirstResponder];
        _inputResult = self.inputTextField.text;
    }
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
            if (_ZNKPickerConfirmResult) {
                _ZNKPickerConfirmResult(self);
            }
        }
            break;
        case ZNKPickerTypeActionAlert:
        {
            if (_ZNKPickerConfirmResult) {
                _ZNKPickerConfirmResult(self);
            }
        }
            break;
        case ZNKPickerTypeArea:
        {
            if (_ZNKPickerConfirmResult) {
                _ZNKPickerConfirmResult(self);
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
            switch (_type) {
                case ZNKPickerTypeDateMode:
                    self.dateTimeStr = [NSString stringWithFormat:@"%ld%@%ld%@%ld",(long)self.curYear, self.pickerViewDateFormat,(long)self.curMonth, self.pickerViewDateFormat,(long)self.curDay];
                    break;
                case ZNKPickerTypeTimeMode:
                    self.dateTimeStr = [NSString stringWithFormat:@"%02ld%@%02ld%@%02ld",(long)self.curHour, self.pickerViewTimeFormat,(long)self.curMin, self.pickerViewTimeFormat,(long)self.curSecond];
                    break;
                case ZNKPickerTypeDateTimeMode:
                    self.dateTimeStr = [NSString stringWithFormat:@"%ld%@%ld%@%ld %02ld%@%02ld%@%02ld",(long)self.curYear, self.pickerViewDateFormat,(long)self.curMonth, self.pickerViewDateFormat,(long)self.curDay,(long)self.curHour, self.pickerViewTimeFormat,(long)self.curMin, self.pickerViewTimeFormat,(long)self.curSecond];
                    break;
                case ZNKPickerTypeMonthDayMode:
                    self.dateTimeStr = [NSString stringWithFormat:@"%ld%@%ld",(long)self.curMonth, self.pickerViewDateFormat,(long)self.curDay];
                    break;
                case ZNKPickerTypeYearMonthMode:
                    self.dateTimeStr = [NSString stringWithFormat:@"%ld%@%ld",(long)self.curYear, self.pickerViewDateFormat,(long)self.curMonth];
                    break;
                case ZNKPickerTypeHourMinuteMode:
                    self.dateTimeStr = [NSString stringWithFormat:@"%02ld%@%02ld",(long)self.curHour, self.pickerViewTimeFormat,(long)self.curMin];
                    break;
                case ZNKPickerTypeDateHourMinuteMode:
                    self.dateTimeStr = [NSString stringWithFormat:@"%ld%@%ld%@%ld %02ld%@%02ld",(long)self.curYear, self.pickerViewDateFormat,(long)self.curMonth, self.pickerViewDateFormat,(long)self.curDay,(long)self.curHour, self.pickerViewTimeFormat,(long)self.curMin];
                    break;
                default:
                    self.dateTimeStr = [NSString stringWithFormat:@"%ld%@%ld%@%ld %02ld%@%02ld%@%02ld",(long)self.curYear,self.pickerViewDateFormat,(long)self.curMonth, self.pickerViewDateFormat,(long)self.curDay,(long)self.curHour, self.pickerViewTimeFormat,(long)self.curMin, self.pickerViewTimeFormat,(long)self.curSecond];
                    break;
            }
            if (_ZNKPickerConfirmResult) {
                if (self.inputTextField && self.hasInput) {
                    [self formatResult:(self.inputTextField.text.length > 0) ? self.inputTextField.text: self.oldInputString selectedIndex:0 selectObject:self.dateTimeStr];
                    _ZNKPickerConfirmResult(self);
                }else{
                    [self formatResult:@"" selectedIndex:0 selectObject:self.dateTimeStr];
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
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        [self removeFromSuperview];
    }];
    if (_dismissHandler) {
        _dismissHandler();
    }
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
    if (_ZNKPickerConfirmResult) {
        [self formatResult:@"" selectedIndex:indexPath.row selectObject:self.pickerViewArray[indexPath.row]];
        _ZNKPickerConfirmResult(self);
    }
    [self dismissView];
}

#pragma mark - picker view delegate and data source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    switch (_type) {
        case ZNKPickerTypeArea:
        {
            if (self.chinaOnly) {
                return 3;
            }else{
                return 4;
            }
        }
            break;
        case ZNKPickerTypeObject:
        {
            switch (self.pickerClass) {
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
        }
            break;
        default:
            break;
    }
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch (_type) {
        case ZNKPickerTypeArea:
        {
            if (self.chinaOnly) {
                switch (component) {
                    case 0:
                    {
                        return self.provinceArray.count;
                    }
                        break;
                    case 1:
                    {
                        return self.cityArray.count;
                    }
                        break;
                    case 2:
                    {
                        return self.regionArray.count;
                    }
                        break;
                        
                    default:
                        break;
                }
            }else{
                switch (component) {
                    case 0:
                    {
                        return self.countryArray.count;
                    }
                        break;
                    case 1:
                    {
                        return self.provinceArray.count;
                    }
                        break;
                    case 2:
                    {
                        return self.cityArray.count;
                    }
                        break;
                    case 3:
                    {
                        return self.regionArray.count;
                    }
                        break;
                        
                    default:
                        break;
                }
            }
        }
            break;
        case ZNKPickerTypeObject:
        {
            switch (self.pickerClass) {
                case 1:
                {
                    return self.pickerViewArray.count;
                }
                    break;
                case 2:
                {
                    return self.pickerViewArray.count;
                }
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    
    return 0;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    switch (_type) {
        case ZNKPickerTypeArea:
        {
            if (self.chinaOnly) {
                switch (component) {
                    case 0:
                    {
                        Province *currentProvince = [self.provinceArray objectAtIndex:row];
                        self.pickerCountry.province = currentProvince.name;
                        self.cityArray = currentProvince.cityArray;
                         [pickerView reloadComponent:1];
                        if (self.cityArray.count > 0) {
                            NSInteger com1Row = [pickerView selectedRowInComponent:1];
                            City *currentCity = (City *)[self.cityArray objectAtIndex:com1Row];
                            self.pickerCountry.city = currentCity.name;
                            self.regionArray = currentCity.regionArray;
                            [pickerView reloadComponent:2];
                            if (self.regionArray.count > 0) {
                                NSInteger com2Row = [pickerView selectedRowInComponent:2];
                                Region *currentRegion = (Region *)[self.regionArray objectAtIndex:com2Row];
                                self.pickerCountry.region = currentRegion.name;
                            }else{
                                self.pickerCountry.region = @"";
                            }
                        }else{
                            self.pickerCountry.city = @"";
                        }
                    }
                        break;
                    case 1:
                    {
                        City *currentCity = (City *)[self.cityArray objectAtIndex:row];
                        self.pickerCountry.city = currentCity.name;
                        self.regionArray = currentCity.regionArray;
                        [pickerView reloadComponent:2];
                        if (self.regionArray.count > 0) {
                            NSInteger com2Row = [pickerView selectedRowInComponent:2];
                            Region *currentRegion = (Region *)[self.regionArray objectAtIndex:com2Row];
                            self.pickerCountry.region = currentRegion.name;
                        }else{
                            self.pickerCountry.region = @"";
                        }
                    }
                        break;
                    case 2:
                    {
                        if (self.regionArray.count > 0) {
                            Region *currentRegion = (Region *)[self.regionArray objectAtIndex:row];
                            self.pickerCountry.region = currentRegion.name;
                        }else{
                            self.pickerCountry.region = @"";
                        }
                    }
                        break;
                        
                    default:
                        break;
                }
            }else{
                switch (component) {
                    case 0:
                    {
                        Country *currentCountry = (Country *)[self.countryArray objectAtIndex:row];
                        self.pickerCountry.country = currentCountry.name;
                        self.provinceArray = currentCountry.provinceArray;
                        [pickerView reloadComponent:1];
                        if (self.provinceArray.count > 0) {
                            NSInteger com1Row = [pickerView selectedRowInComponent:1];
                            Province *currentProvince = [self.provinceArray objectAtIndex:com1Row];
                            self.pickerCountry.province = currentProvince.name;
                            self.cityArray = currentProvince.cityArray;
                            [pickerView reloadComponent:2];
                            if (self.cityArray.count > 0) {
                                NSInteger com2Row = [pickerView selectedRowInComponent:2];
                                City *currentCity = (City *)[self.cityArray objectAtIndex:com2Row];
                                self.pickerCountry.city = currentCity.name;
                                self.regionArray = currentCity.regionArray;
                                [pickerView reloadComponent:3];
                                if (self.regionArray.count > 0) {
                                    CGFloat com3Row = [pickerView selectedRowInComponent:3];
                                    Region *currentRegion = (Region *)[self.regionArray objectAtIndex:com3Row];
                                    
                                    self.pickerCountry.region = currentRegion.name;
                                }else{
                                    self.pickerCountry.region = @"";
                                }
                            }else{
                                self.pickerCountry.city = @"";
                            }
                        }else{
                            self.pickerCountry.province = @"";
                        }
                        
                    }
                        break;
                    case 1:
                    {
                        Province *currentProvince = [self.provinceArray objectAtIndex:row];
                        self.pickerCountry.province = currentProvince.name;
                        self.cityArray = currentProvince.cityArray;
                        [pickerView reloadComponent:2];
                        if (self.cityArray.count > 0) {
                            NSInteger com2Row = [pickerView selectedRowInComponent:2];
                            City *currentCity = (City *)[self.cityArray objectAtIndex:com2Row];
                            self.pickerCountry.city = currentCity.name;
                            self.regionArray = currentCity.regionArray;
                            [pickerView reloadComponent:3];
                            if (self.regionArray.count > 0) {
                                CGFloat com3Row = [pickerView selectedRowInComponent:3];
                                Region *currentRegion = (Region *)[self.regionArray objectAtIndex:com3Row];
                                self.pickerCountry.region = currentRegion.name;
                            }else{
                                self.pickerCountry.region = @"";
                            }
                        }else{
                            self.pickerCountry.city = @"";
                        }
                    }
                        break;
                    case 2:
                    {
                        City *currentCity = (City *)[self.cityArray objectAtIndex:row];
                        self.pickerCountry.city = currentCity.name;
                        self.regionArray = currentCity.regionArray;
                        [pickerView reloadComponent:3];
                        if (self.regionArray.count > 0) {
                            CGFloat com3Row = [pickerView selectedRowInComponent:3];
                            Region *currentRegion = (Region *)[self.regionArray objectAtIndex:com3Row];
                            self.pickerCountry.region = currentRegion.name;
                        }else{
                            self.pickerCountry.region = @"";
                        }
                    }
                        break;
                    case 3:
                    {
                        if (self.regionArray.count > 0) {
                            Region *currentRegion = (Region *)[self.regionArray objectAtIndex:row];
                            self.pickerCountry.region = currentRegion.name;
                        }else{
                            self.pickerCountry.region = @"";
                        }
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            if (_ZNKPickerRealTimeResult) {
                [self formatResult:@"" selectedIndex:-1 selectObject:self.pickerCountry];
                _ZNKPickerRealTimeResult(self);
            }
        }
            break;
        case ZNKPickerTypeObject:
        {
            switch (self.pickerClass) {
                case 1:
                {
                    if (self.objectToStringConverter == nil) {
                        
                        if (_ZNKPickerRealTimeResult) {
                            [self formatResult:@"" selectedIndex:row selectObject:[self.pickerViewArray objectAtIndex:row]];
                            _ZNKPickerRealTimeResult(self);
                        }
                    } else{
                        if (_ZNKPickerRealTimeResult) {
                            [self formatResult:@"" selectedIndex:row selectObject:self.objectToStringConverter ([self.pickerViewArray objectAtIndex:row])];
                            _ZNKPickerRealTimeResult(self);
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
            break;
        default:
            break;
    }
}


- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view {
    
    switch (_type) {
        case ZNKPickerTypeArea:
        {
            UIView *customPickerView = view;
            
            UILabel *pickerViewLabel;
            
            if (customPickerView==nil) {
                if (self.chinaOnly) {
                    switch (component) {
                        case 0:
                        {
                            CGRect frame = CGRectMake(0.0, 0.0, CGRectGetWidth(pickerView.frame) / 3, self.tableViewRowHeight);
                            customPickerView = [[UIView alloc] initWithFrame: frame];
                        }
                            break;
                        case 1:
                        {
                            CGRect frame = CGRectMake(0.0, CGRectGetWidth(pickerView.frame) / (1 * 3), CGRectGetWidth(pickerView.frame) / 3, self.tableViewRowHeight);
                            customPickerView = [[UIView alloc] initWithFrame: frame];
                        }
                            break;
                        case 2:
                        {
                            CGRect frame = CGRectMake(0.0, CGRectGetWidth(pickerView.frame) / 3 * (2 * 3), CGRectGetWidth(pickerView.frame) / 3, self.tableViewRowHeight);
                            customPickerView = [[UIView alloc] initWithFrame: frame];
                        }
                            break;
                        default:
                            break;
                    }
                }else{
                    switch (component) {
                        case 0:
                        {
                            CGRect frame = CGRectMake(0.0, 0.0, CGRectGetWidth(pickerView.frame) / 4, self.tableViewRowHeight);
                            customPickerView = [[UIView alloc] initWithFrame: frame];
                        }
                            break;
                        case 1:
                        {
                            CGRect frame = CGRectMake(0.0, CGRectGetWidth(pickerView.frame) / 4, CGRectGetWidth(pickerView.frame) / 4, self.tableViewRowHeight);
                            customPickerView = [[UIView alloc] initWithFrame: frame];
                        }
                            break;
                        case 2:
                        {
                            CGRect frame = CGRectMake(0.0, CGRectGetWidth(pickerView.frame) / 4 * (2 * 4), CGRectGetWidth(pickerView.frame) / 3, self.tableViewRowHeight);
                            customPickerView = [[UIView alloc] initWithFrame: frame];
                        }
                            break;
                        case 3:
                        {
                            CGRect frame = CGRectMake(0.0, CGRectGetWidth(pickerView.frame) / 4 * (3 * 4), CGRectGetWidth(pickerView.frame) / 4, self.tableViewRowHeight);
                            customPickerView = [[UIView alloc] initWithFrame: frame];
                        }
                            break;
                        default:
                            break;
                    }
                }
                CGRect labelFrame = CGRectMake(0.0, 0.0, CGRectGetWidth(customPickerView.frame), self.tableViewRowHeight); // 35 or 44
                pickerViewLabel = [[UILabel alloc] initWithFrame:labelFrame];
                [pickerViewLabel setTag:1];
                [pickerViewLabel setTextAlignment: self.pickerViewTextAlignment];
                [pickerViewLabel setBackgroundColor:[UIColor clearColor]];
                [pickerViewLabel setTextColor:self.pickerViewTextColor];
                [pickerViewLabel setFont:self.pickerViewFont];
                [pickerViewLabel setAdjustsFontSizeToFitWidth:YES];
                [pickerViewLabel setContentScaleFactor:0.5];
                [pickerViewLabel setNumberOfLines:0];
                [customPickerView addSubview:pickerViewLabel];
            } else{
                
                for (UIView *view in customPickerView.subviews) {
                    if (view.tag == 1) {
                        pickerViewLabel = (UILabel *)view;
                        break;
                    }
                }
            }
            
            if (self.chinaOnly) {
                switch (component) {
                    case 0:
                    {
                        if (self.provinceArray.count > 0) {
                            Province *pro = (Province *)[self.provinceArray objectAtIndex:row];
                            [pickerViewLabel setText:pro.name];
                        }else{
                            [pickerViewLabel setText:@""];
                        }
                    }
                        break;
                    case 1:
                    {
                        if (self.cityArray.count > 0) {
                            City *pro = (City *)[self.cityArray objectAtIndex:row];
                            [pickerViewLabel setText:pro.name];
                        }else{
                            [pickerViewLabel setText:@""];
                        }
                    }
                        break;
                    case 2:
                    {
                        if (self.regionArray.count > 0) {
                            Region *pro = (Region *)[self.regionArray objectAtIndex:row];
                            [pickerViewLabel setText:pro.name];
                        }else{
                            [pickerViewLabel setText:@""];
                        }
                    }
                        break;
                    default:
                        break;
                }
            }else{
                switch (component) {
                    case 0:
                    {
                        if (self.countryArray.count > 0) {
                            Country *pro = (Country *)[self.countryArray objectAtIndex:row];
                            [pickerViewLabel setText:pro.name];
                        }else{
                            [pickerViewLabel setText:@""];
                        }
                    }
                        break;
                    case 1:
                    {
                        if (self.provinceArray.count > 0) {
                            Province *pro = (Province *)[self.provinceArray objectAtIndex:row];
                            [pickerViewLabel setText:pro.name];
                        }else{
                            [pickerViewLabel setText:@""];
                        }
                    }
                        break;
                    case 2:
                    {
                        if (self.cityArray.count > 0) {
                            City *pro = (City *)[self.cityArray objectAtIndex:row];
                            [pickerViewLabel setText:pro.name];
                        }else{
                            [pickerViewLabel setText:@""];
                        }
                    }
                        break;
                    case 3:
                    {
                        if (self.regionArray.count > 0) {
                            Region *pro = (Region *)[self.regionArray objectAtIndex:row];
                            [pickerViewLabel setText:pro.name];
                        }else{
                            [pickerViewLabel setText:@""];
                        }
                    }
                        break;
                    default:
                        break;
                }
            }
            
            
            
            return customPickerView;
        }
            break;
        case ZNKPickerTypeObject:
        {
            switch (self.pickerClass) {
                case 1:
                {
                    UIView *customPickerView = view;
                    
                    UILabel *pickerViewLabel;
                    
                    if (customPickerView==nil) {
                        
                        CGRect frame = CGRectMake(0.0, 0.0, CGRectGetWidth(pickerView.frame), self.tableViewRowHeight);
                        customPickerView = [[UIView alloc] initWithFrame: frame];
                        
                        
                        CGRect labelFrame = CGRectMake(0.0, 0.0, CGRectGetWidth(customPickerView.frame), self.tableViewRowHeight); // 35 or 44
                        pickerViewLabel = [[UILabel alloc] initWithFrame:labelFrame];
                        [pickerViewLabel setTag:1];
                        [pickerViewLabel setTextAlignment: self.pickerViewTextAlignment];
                        [pickerViewLabel setBackgroundColor:[UIColor clearColor]];
                        [pickerViewLabel setTextColor:self.pickerViewTextColor];
                        [pickerViewLabel setFont:self.pickerViewFont];
                        [pickerViewLabel setAdjustsFontSizeToFitWidth:YES];
                        [pickerViewLabel setContentScaleFactor:0.5];
                        [pickerViewLabel setNumberOfLines:0];
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
                        [pickerViewLabel setText: [self.pickerViewArray objectAtIndex:row]];
                    } else{
                        [pickerViewLabel setText:(self.objectToStringConverter ([self.pickerViewArray objectAtIndex:row]))];
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
        }
            break;
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
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"yyyy%@MM%@dd HH%@mm%@ss", self.pickerViewDateFormat, self.pickerViewDateFormat, self.pickerViewTimeFormat,self.pickerViewTimeFormat]];
    NSString *selectTimeString = [NSString stringWithFormat:@"%ld%@%02ld%@%02ld %02ld%@%02ld%@%02ld",(long)self.curYear,self.pickerViewDateFormat,(long)self.curMonth,self.pickerViewDateFormat,(long)self.curDay,(long)self.curHour, self.pickerViewTimeFormat,(long)self.curMin, self.pickerViewTimeFormat,(long)self.curSecond];
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


