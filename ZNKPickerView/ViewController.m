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
    testButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) / 2 - 30, CGRectGetHeight(self.view.frame) / 2 - 100, 60, 40);
    [testButton setTitle:@"测试" forState:UIControlStateNormal];
    [testButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [testButton addTarget:self action:@selector(testPickerView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testButton];
    
}

- (void)testPickerView{
//    [ZNKPickerView showInView:self.view.window pickerType:ZNKPickerTypeDateTimeMode title:@"这是测试" withObject:@[@"从相册选择",@"拍照"] withOptions:nil hasInput:NO hasNav:NO objectToStringConverter:^NSString *(id obj) {
//        return [obj description];
//    } completion:^(ZNKPickerView *pickerView, NSString *input, NSInteger index, id obj) {
//        
//    } confirmHandler:^(ZNKPickerView *pickerView, NSString *input, NSInteger index, id obj) {
//        
//    }];
    
    NSDictionary *option = @{};
    [ZNKPickerView showInView:self.view.window pickerType:ZNKPickerTypeDateTimeMode options:option objectToStringConverter:^NSString *(id obj) {
        return [obj description];
    } realTimeResult:^(ZNKPickerView *pickerView) {
        
    } completionHandler:^(ZNKPickerView *pickerView) {
        
    }];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
