//
//  RCDMessageNotifyTableViewController.m
//  RCloudMessage
//
//  Created by Liv on 14/11/20.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCDMessageNotifySettingTableViewController.h"
#import "MBProgressHUD.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDMessageNoDisturbSettingController.h"

@interface RCDMessageNotifySettingTableViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *notifySwitch;

@property (weak, nonatomic) IBOutlet UILabel *noDisturbLabel;

@end

@implementation RCDMessageNotifySettingTableViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"notiSwitch"]) {
        cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
        _noDisturbLabel.alpha = 0.5;
         self.notifySwitch.on = NO;
        
    }else{
        cell.backgroundColor = [UIColor whiteColor];
        _noDisturbLabel.alpha = 1;
         self.notifySwitch.on = YES;
    }
   
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    通知开启状态
//    UIUserNotificationType userNotiType = [[UIApplication sharedApplication] currentUserNotificationSettings].types;
//    if (userNotiType != UIUserNotificationTypeNone) {
//        [self.notifySwitch setEnabled:YES];
//    }else{
//        [self.notifySwitch setEnabled:NO];
//    }
    
}


- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSUserDefaults standardUserDefaults] setBool:_notifySwitch.on forKey:@"notiSwitch"];
}

- (IBAction)onSwitch:(id)sender {
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"设置中...";
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];

    if (!self.notifySwitch.on) {
        __weak typeof(&*self) blockSelf = self;
        [[RCIMClient sharedRCIMClient] setConversationNotificationQuietHours:@"00:00:00" spanMins:1439 success:^{
            NSLog(@"setConversationNotificationQuietHours succeed");
            [[RCIM sharedRCIM] setDisableMessageNotificaiton:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hide:YES];
                cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
                blockSelf.noDisturbLabel.alpha = 0.5;
            });
        } error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设置失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                [alert show];
                self.notifySwitch.on = YES;
                [hud hide:YES];
            });
        }];
    } else {
        __weak typeof(&*self) blockSelf = self;
        [[RCIMClient sharedRCIMClient] removeConversationNotificationQuietHours:^{
            [[RCIM sharedRCIM] setDisableMessageNotificaiton:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hide:YES];
                cell.backgroundColor = [UIColor whiteColor];
                blockSelf.noDisturbLabel.alpha = 1;
            });
            BOOL onoDiturb =[[NSUserDefaults standardUserDefaults] boolForKey:@"disturbStatus"];
            
            if (onoDiturb) {
                NSString * startTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"startTime"];
                NSString * endTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"endTime"];
                if (startTime.length == 0 || endTime.length == 0){
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
                } error:^(RCErrorCode status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"免打扰设置失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                        [alert show];
                    });
                } ];
                
            }
        } error:^(RCErrorCode status) {

            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"取消失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                [alert show];
                self.notifySwitch.on = NO;
                [hud hide:YES];
            });
        }];
        
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.row == 1 && indexPath.section == 0) {
        
        if (_notifySwitch.on){
            RCDMessageNoDisturbSettingController *noMessage = [[RCDMessageNoDisturbSettingController alloc] init];
            [self.navigationController pushViewController:noMessage animated:YES];
           
        }
        
    }
    
}


@end
