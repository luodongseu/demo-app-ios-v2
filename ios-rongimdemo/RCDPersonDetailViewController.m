//
//  RCDPersonDetailViewController.m
//  RCloudMessage
//
//  Created by Liv on 15/4/9.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDPersonDetailViewController.h"
#import "RCDChatViewController.h"
#import <RongIMKit/RongIMKit.h>
#import <RongIMLib/RCUserInfo.h>
#import "RCDHttpTool.h"
#import "UIImageView+WebCache.h"

@interface RCDPersonDetailViewController ()<UIActionSheetDelegate>
@property (nonatomic)BOOL inBlackList;
@end

@implementation RCDPersonDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"config"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemClicked:)];


    self.lblName.text = self.userInfo.name;
//    self.ivAva.clipsToBounds = YES;
//    self.ivAva.layer.cornerRadius = 4.f;
    [self.ivAva sd_setImageWithURL:[NSURL URLWithString:self.userInfo.portraitUri] placeholderImage:[UIImage imageNamed:@"icon_person"]];

    __weak RCDPersonDetailViewController *weakSelf = self;
    [[RCIMClient sharedRCIMClient] getBlacklistStatus:self.userInfo.userId success:^(int bizStatus) {
        weakSelf.inBlackList = (bizStatus == 0);
    } error:^(RCErrorCode status) {
        ;
    }];
    
}
- (IBAction)btnConversation:(id)sender {
    //创建会话
    RCDChatViewController *chatViewController = [[RCDChatViewController alloc] init];
    chatViewController.conversationType = ConversationType_PRIVATE;
    chatViewController.targetId = self.userInfo.userId;
    chatViewController.title = self.userInfo.name;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (IBAction)btnVoIP:(id)sender {
    //语音通话
    [[RCIM sharedRCIM] startVoIPCallWithTargetId:self.userInfo.userId];
}


-(void) rightBarButtonItemClicked:(id) sender
{
    if (self.inBlackList) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"解除好友关系", @"取消黑名单", nil];
        [actionSheet showInView:self.view];
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"解除好友关系", @"加入黑名单", nil];
        [actionSheet showInView:self.view];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIActionSheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            //解除好友关系
            [RCDHTTPTOOL deleteFriend:self.userInfo.userId complete:^(BOOL result) {
               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"删除好友成功！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil
                , nil];
                [alertView show];
            }];

        }
            break;
        case 1:
        {
            //黑名单
            __weak RCDPersonDetailViewController *weakSelf = self;
            if (!self.inBlackList) {
                [[RCIMClient sharedRCIMClient] addToBlacklist:self.userInfo.userId success:^{
                    weakSelf.inBlackList = YES;
                } error:^(RCErrorCode status) {
                    weakSelf.inBlackList = NO;
                }];
            } else {
                [[RCIMClient sharedRCIMClient] removeFromBlacklist:self.userInfo.userId success:^{
                    weakSelf.inBlackList = NO;
                } error:^(RCErrorCode status) {
                    weakSelf.inBlackList = YES;
                }];
            }

        }
            break;
    }
}

@end
