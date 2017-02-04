# ZNKPickerView一行代码实现基本功能的相对可定制选择器
一，一行代码：

+ (void)showInView:(UIView *)view pickerType:(ZNKPickerType)type options: (NSDictionary *)options objectToStringConverter:(NSString *(^)(id))converter  realTimeResult:(void(^)(ZNKPickerView *pickerView))realTimeResult completionHandler:(void(^)(ZNKPickerView *pickerView))completionHandler;

二，包含以下功能:

	1. 日期选择器 （年-月-日 时:分:秒 | 年-月-日 时:分 | 时:分:秒 ...）
		例子如下:
		
	![](/Users/huangsam/Desktop/WechatIMG1.jpeg)
	

