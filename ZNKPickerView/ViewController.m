//
//  ViewController.m
//  ZNKPickerView
//
//  Created by 黄漫 on 2017/1/15.
//  Copyright © 2017年 黄漫. All rights reserved.
//

#import "ViewController.h"
#import "ZNKPickerView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *testButton = [UIButton buttonWithType:UIButtonTypeCustom];
    testButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) / 2 - 30, 50, 60, 40);
    testButton.tag = 100;
    [testButton setTitle:@"测试1" forState:UIControlStateNormal];
    [testButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [testButton addTarget:self action:@selector(testPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testButton];
    
    testButton = [UIButton buttonWithType:UIButtonTypeCustom];
    testButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) / 2 - 30, 100, 60, 40);
    testButton.tag = 101;
    [testButton setTitle:@"测试2" forState:UIControlStateNormal];
    [testButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [testButton addTarget:self action:@selector(testPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testButton];
    
    testButton = [UIButton buttonWithType:UIButtonTypeCustom];
    testButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) / 2 - 30, 150, 60, 40);
    testButton.tag = 102;
    [testButton setTitle:@"测试3" forState:UIControlStateNormal];
    [testButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [testButton addTarget:self action:@selector(testPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testButton];
    
    testButton = [UIButton buttonWithType:UIButtonTypeCustom];
    testButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) / 2 - 30, 200, 60, 40);
    testButton.tag = 103;
    [testButton setTitle:@"测试4" forState:UIControlStateNormal];
    [testButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [testButton addTarget:self action:@selector(testPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testButton];
    
    testButton = [UIButton buttonWithType:UIButtonTypeCustom];
    testButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) / 2 - 30, 250, 60, 40);
    testButton.tag = 104;
    [testButton setTitle:@"测试5" forState:UIControlStateNormal];
    [testButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [testButton addTarget:self action:@selector(testPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testButton];
    
    testButton = [UIButton buttonWithType:UIButtonTypeCustom];
    testButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) / 2 - 30, 300, 60, 40);
    testButton.tag = 105;
    [testButton setTitle:@"测试6" forState:UIControlStateNormal];
    [testButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [testButton addTarget:self action:@selector(testPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testButton];
    
}

- (void)testPickerView:(UIButton *)btn{
//    [ZNKPickerView showInView:self.view.window pickerType:ZNKPickerTypeDateTimeMode title:@"这是测试" withObject:@[@"从相册选择",@"拍照"] withOptions:nil hasInput:NO hasNav:NO objectToStringConverter:^NSString *(id obj) {
//        return [obj description];
//    } completion:^(ZNKPickerView *pickerView, NSString *input, NSInteger index, id obj) {
//        
//    } confirmHandler:^(ZNKPickerView *pickerView, NSString *input, NSInteger index, id obj) {
//        
//    }];
    
    switch (btn.tag) {
        case 100:
        {
            NSDictionary *option = @{};
            [ZNKPickerView showInView:self.view.window pickerType:ZNKPickerTypeDateTimeMode options:option objectToStringConverter:^NSString *(id obj) {
                return [obj description];
            } realTimeResult:^(ZNKPickerView *pickerView) {
                NSLog(@"realTimeResult picker view index %ld",(long)pickerView.index);
                NSLog(@"realTimeResult picker view input %@", pickerView.inputResult);
                NSLog(@"realTimeResult picker view select result %@",pickerView.result);
            } completionHandler:^(ZNKPickerView *pickerView) {
                NSLog(@"completionHandler picker view index %ld",(long)pickerView.index);
                NSLog(@"completionHandler picker view input %@", pickerView.inputResult);
                NSLog(@"completionHandler picker view select result %@",pickerView.result);
            }];
        }
            break;
        case 101:
        {
            NSDictionary *option = @{ZNKPickerViewData:@[@"从相册选择",@"相机"]};
            [ZNKPickerView showInView:self.view.window pickerType:ZNKPickerTypeActionSheet options:option objectToStringConverter:^NSString *(id obj) {
                return [obj description];
            } realTimeResult:^(ZNKPickerView *pickerView) {
                NSLog(@"realTimeResult picker view index %ld",(long)pickerView.index);
                NSLog(@"realTimeResult picker view input %@", pickerView.inputResult);
                NSLog(@"realTimeResult picker view select result %@",pickerView.result);
            } completionHandler:^(ZNKPickerView *pickerView) {
                NSLog(@"completionHandler picker view index %ld",(long)pickerView.index);
                NSLog(@"completionHandler picker view input %@", pickerView.inputResult);
                NSLog(@"completionHandler picker view select result %@",pickerView.result);
            }];
        }
            break;
        case 102:
        {
            NSDictionary *option = @{ZNKPickerViewData:@[@"从相册选择",@"相机", @6, @[@(YES), @[@"哈哈哈", @"呀呀呀"]], @(987), @"我去", @"hahahahah",@"呵呵呵呵呵",@"咳咳咳咳",@"略略略",@"路啦啦啦啦啦了", @(90),@(100),@(80),@(123),@"卡卡卡",@"擦擦擦"], ZNKCanScroll: @(YES),ZNKToolbarTitle:@"hahahahahhahah哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈啊哈哈哈哈", ZNKToolbarMessage:@"卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡卡"};
            [ZNKPickerView showInView:self.view.window pickerType:ZNKPickerTypeActionSheet options:option objectToStringConverter:^NSString *(id obj) {
                return [obj description];
            } realTimeResult:^(ZNKPickerView *pickerView) {
                NSLog(@"realTimeResult picker view index %ld",(long)pickerView.index);
                NSLog(@"realTimeResult picker view input %@", pickerView.inputResult);
                NSLog(@"realTimeResult picker view select result %@",pickerView.result);
            } completionHandler:^(ZNKPickerView *pickerView) {
                NSLog(@"completionHandler picker view index %ld",(long)pickerView.index);
                NSLog(@"completionHandler picker view input %@", pickerView.inputResult);
                NSLog(@"completionHandler picker view select result %@",pickerView.result);
            }];
        }
            break;
        case 103:
        {
            NSDictionary *option = @{ZNKPickerViewData:@[@"从相册选择",@"相机", @6, @[@(YES), @[@"哈哈哈", @"呀呀呀"]], @(987), @"我去", @"hahahahah",@"呵呵呵呵呵",@"咳咳咳咳",@"略略略",@"路啦啦啦啦啦了", @(90),@(100),@(80),@(123),@"卡卡卡",@"擦擦擦"],/* ZNKCanScroll: @(YES)*/ ZNKDefaultSelectedObject:@"我去", ZNKToolbarHasInput:@(YES),};
            [ZNKPickerView showInView:self.view.window pickerType:ZNKPickerTypeObject options:option objectToStringConverter:^NSString *(id obj) {
                return [obj description];
            } realTimeResult:^(ZNKPickerView *pickerView) {
                NSLog(@"realTimeResult picker view index %ld",(long)pickerView.index);
                NSLog(@"realTimeResult picker view input %@", pickerView.inputResult);
                NSLog(@"realTimeResult picker view select result %@",pickerView.result);
            } completionHandler:^(ZNKPickerView *pickerView) {
                NSLog(@"completionHandler picker view index %ld",(long)pickerView.index);
                NSLog(@"completionHandler picker view input %@", pickerView.inputResult);
                NSLog(@"completionHandler picker view select result %@",pickerView.result);
            }];
        }
            break;
        case 104:
        {
            NSDictionary *option = @{ZNKPickerViewData:@[@"从相册选择",@"相机", @6, @[@(YES), @[@"哈哈哈", @"呀呀呀"]], @(987), @"我去", @"hahahahah",@"呵呵呵呵呵",@"咳咳咳咳",@"略略略",@"路啦啦啦啦啦了", @(90),@(100),@(80),@(123),@"卡卡卡",@"擦擦擦"],/* ZNKCanScroll: @(YES) ZNKDefaultSelectedObject:@"我去"*/ ZNKToolbarTitle:@"hahahahahhahah哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈啊哈哈哈哈"};
            [ZNKPickerView showInView:self.view.window pickerType:ZNKPickerTypeActionAlert options:option objectToStringConverter:^NSString *(id obj) {
                return [obj description];
            } realTimeResult:^(ZNKPickerView *pickerView) {
                NSLog(@"realTimeResult picker view index %ld",(long)pickerView.index);
                NSLog(@"realTimeResult picker view input %@", pickerView.inputResult);
                NSLog(@"realTimeResult picker view select result %@",pickerView.result);
            } completionHandler:^(ZNKPickerView *pickerView) {
                NSLog(@"completionHandler picker view index %ld",(long)pickerView.index);
                NSLog(@"completionHandler picker view input %@", pickerView.inputResult);
                NSLog(@"completionHandler picker view select result %@",pickerView.result);
            }];
        }
            break;
        case 105:
        {
            NSDictionary *option = @{ZNKPickerViewData:@[@"从相册选择",@"相机", @6, @[@(YES), @[@"哈哈哈", @"呀呀呀"]], @(987), @"我去", @"hahahahah",@"呵呵呵呵呵",@"咳咳咳咳",@"略略略",@"路啦啦啦啦啦了", @(90),@(100),@(80),@(123),@"卡卡卡",@"擦擦擦"],/* ZNKCanScroll: @(YES)*/ ZNKDefaultSelectedObject:@"我去"};
            [ZNKPickerView showInView:self.view.window pickerType:ZNKPickerTypeObject options:option objectToStringConverter:^NSString *(id obj) {
                return [obj description];
            } realTimeResult:^(ZNKPickerView *pickerView) {
                NSLog(@"realTimeResult picker view index %ld",(long)pickerView.index);
                NSLog(@"realTimeResult picker view input %@", pickerView.inputResult);
                NSLog(@"realTimeResult picker view select result %@",pickerView.result);
            } completionHandler:^(ZNKPickerView *pickerView) {
                NSLog(@"completionHandler picker view index %ld",(long)pickerView.index);
                NSLog(@"completionHandler picker view input %@", pickerView.inputResult);
                NSLog(@"completionHandler picker view select result %@",pickerView.result);
            }];
        }
            break;
            
        default:
            break;
    }
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
