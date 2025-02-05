//
//  RCDMessageNoDisturbSettingController.m
//  RCloudMessage
//
//  Created by 张改红 on 15/7/15.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDMessageNoDisturbSettingController.h"
#import <RongIMKit/RongIMKit.h>

#define UserDefaults [NSUserDefaults standardUserDefaults]

@interface RCDMessageNoDisturbSettingController ()
@property (nonatomic,strong) NSIndexPath *indexPath;

@property (nonatomic,copy) NSString *start;
@property (nonatomic,copy) NSString *end;

@end

@implementation RCDMessageNoDisturbSettingController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _swch.on = [UserDefaults boolForKey:@"disturbStatus"];
    NSLog(@"%d",_swch.on);
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:YES scrollPosition:UITableViewScrollPositionTop];
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _swch = [[UISwitch alloc] init];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:18]};
    self.title = @"免打扰设置";
    
    [[RCIMClient sharedRCIMClient] getNotificationQuietHours:^(NSString *startTime, int spansMin) {

    } error:^(RCErrorCode status) {
        
    }];
    
    
    self.tableView.tableFooterView = [UIView new];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSIndexPath *startIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    NSIndexPath *endIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    UITableViewCell *startCell = [self.tableView cellForRowAtIndexPath:startIndexPath];
    UITableViewCell *endCell = [self.tableView cellForRowAtIndexPath:endIndexPath];
    
    NSString *startTime = startCell.detailTextLabel.text;
    NSString *endTime = endCell.detailTextLabel.text;
    
    
    
    if (_swch.on) {
        if (startTime.length == 0 || endTime.length == 0  || (startTime == _start && endTime == _end)) {
            return;
        }
        
        NSDateFormatter *formatterE = [[NSDateFormatter alloc] init];
        [formatterE setDateFormat:@"HH:mm:ss"];
        NSDate *startDate = [formatterE dateFromString:startTime];
        NSDate *endDate = [formatterE dateFromString:endTime];
        double timeDiff = [endDate timeIntervalSinceDate:startDate];
        int timeDif = timeDiff/60;
        
        [[RCIMClient sharedRCIMClient] setConversationNotificationQuietHours:startTime spanMins:timeDif success:^{
            [RCIM sharedRCIM].disableMessageNotificaiton = YES;
            [UserDefaults setObject:startTime forKey:@"startTime"];
            [UserDefaults setObject:endTime forKey:@"endTime"];
        } error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设置失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                [alert show];
            });
        } ];
        
    }
    [UserDefaults setBool:self.swch.on forKey:@"disturbStatus"];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if(section == 0)
        return 1;
    
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 200;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCellReuseIdentifier"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MyCellReuseIdentifier"];
    }
    
    if(indexPath.section == 1 && indexPath.row == 0){
        cell.detailTextLabel.text = [UserDefaults objectForKey:@"startTime"];
    }else if(indexPath.section == 1 && indexPath.row == 1){
        cell.detailTextLabel.text = [UserDefaults objectForKey:@"endTime"];
    }
    
    
    if (indexPath.section == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        datePicker.datePickerMode = UIDatePickerModeCountDownTimer;
        [datePicker setDate:[NSDate date]];
        
        [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:datePicker];
    }else{
        
        switch (indexPath.row) {
            case 0:
            {
                cell.textLabel.text = @"开始时间";
            }
                break;
            case 1:
            {
                cell.textLabel.text = @"结束时间";
            }
                break;
            default:
            {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.text = @"屏蔽所有消息";
                [_swch setFrame:CGRectMake(self.view.frame.size.width - _swch.frame.size.width -15, 6, 0, 0)];
                [_swch addTarget:self action:@selector(setSwitchState:) forControlEvents:UIControlEventValueChanged];
                [cell.contentView addSubview:_swch];
                
                
            }
                break;
        }
        
        
    }
    return cell;
}

#pragma mark - Table view Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if((indexPath.section == 1 && indexPath.row == 0) || (indexPath.section == 1 && indexPath.row == 1)){
        
        _indexPath = indexPath;
    }
}

#pragma mark - datePickerValueChanged
-(void) datePickerValueChanged:(UIDatePicker *) datePicker
{
    [self.tableView selectRowAtIndexPath:_indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:datePicker.date];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_indexPath];
    cell.detailTextLabel.text = currentDateStr;

    
    NSIndexPath *startIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    NSIndexPath *endIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    UITableViewCell *startCell = [self.tableView cellForRowAtIndexPath:startIndexPath];
    UITableViewCell *endCell = [self.tableView cellForRowAtIndexPath:endIndexPath];
    NSDate *startTime = [dateFormatter dateFromString:startCell.detailTextLabel.text];
    NSDate *endTime = [dateFormatter dateFromString:endCell.detailTextLabel.text];
    
    if (startTime == nil || endTime == nil) {
        return;
    }
    NSDate *laterTime = [startTime laterDate:endTime];
    if ([laterTime isEqualToDate:startTime]) {
        startCell.detailTextLabel.text = @"";
        [self.tableView selectRowAtIndexPath:startIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        [self tableView:self.tableView didSelectRowAtIndexPath:startIndexPath];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"开始时间不能大于等于结束时间" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    [UserDefaults setObject:startCell.detailTextLabel.text forKey:@"startTime"];
    [UserDefaults setObject:endCell.detailTextLabel.text forKey:@"endTime"];
    
}

#pragma mark - setSwitchState

-(void) setSwitchState:(UISwitch *) swich
{
    NSString *startTime = [UserDefaults objectForKey:@"startTime"];
    NSString *endTime = [UserDefaults objectForKey:@"endTime"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSIndexPath *startIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        NSIndexPath *endIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
        UITableViewCell *startCell = [self.tableView cellForRowAtIndexPath:startIndexPath];
        UITableViewCell *endCell = [self.tableView cellForRowAtIndexPath:endIndexPath];
        startCell.detailTextLabel.text = startTime;
        endCell.detailTextLabel.text = endTime;
        
    });
    
    if (swich.on) {
        NSDateFormatter *formatterE = [[NSDateFormatter alloc] init];
        [formatterE setDateFormat:@"HH:mm:ss"];
        NSDate *startDate = [formatterE dateFromString:startTime];
        NSDate *endDate = [formatterE dateFromString:endTime];
        double timeDiff = [endDate timeIntervalSinceDate:startDate];
        int timeDif = timeDiff/60;
        __weak typeof(&*self) blockSelf = self;
        [[RCIMClient sharedRCIMClient] setConversationNotificationQuietHours:startTime spanMins:timeDif success:^{
            [RCIM sharedRCIM].disableMessageNotificaiton = YES;
            
        } error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设置失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                [alert show];
                blockSelf.swch.on = NO;
            });
        }];
        
    }else{
        __weak typeof(&*self) blockSelf = self;
        [[RCIMClient sharedRCIMClient] removeConversationNotificationQuietHours:^{
            
            [RCIM sharedRCIM].disableMessageNotificaiton = NO;
            NSLog(@"关闭成功");
        } error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"关闭失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                [alert show];
                blockSelf.swch.on = YES;
            });
        }];
    }
}

@end
