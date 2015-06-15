//
//  RCDGroupDetailViewController.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/3/21.
//  Copyright (c) 2015年 胡利武. All rights reserved.
//

#import "RCDGroupDetailViewController.h"
#import "RCDGroupInfo.h"
#import "RCDHttpTool.h"
#import "RCDRCIMDataSource.h"
#import "RCDChatViewController.h"

@interface RCDGroupDetailViewController () <UIActionSheetDelegate>

@end

@implementation RCDGroupDetailViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  _lbGroupName.text = _groupInfo.groupName;
  _lbGroupIntru.text = _groupInfo.introduce;

  _lbNumberInGroup.text = [NSString
      stringWithFormat:@"%@/%@", _groupInfo.number, _groupInfo.maxNumber];
  UIImage *imageChat = [UIImage imageNamed:@"group_add"];
  imageChat = [imageChat
      stretchableImageWithLeftCapWidth:floorf(imageChat.size.width / 2)
                          topCapHeight:floorf(imageChat.size.height / 2)];
  [_btChat setTitle:@"发起会话" forState:UIControlStateNormal];
  [_btChat setBackgroundImage:imageChat forState:UIControlStateNormal];
  if (_groupInfo.isJoin) {
    [_btChat setHidden:NO];
    UIImage *image = [UIImage imageNamed:@"group_quit"];
    image =
        [image stretchableImageWithLeftCapWidth:floorf(image.size.width / 2)
                                   topCapHeight:floorf(image.size.height / 2)];
    [_btJoinOrQuitGroup setTitle:@"删除并退出" forState:UIControlStateNormal];
    [_btJoinOrQuitGroup setBackgroundImage:image forState:UIControlStateNormal];
  } else {
    [_btChat setHidden:YES];
    UIImage *image = [UIImage imageNamed:@"group_add"];
    image =
        [image stretchableImageWithLeftCapWidth:floorf(image.size.width / 2)
                                   topCapHeight:floorf(image.size.height / 2)];
    [_btJoinOrQuitGroup setTitle:@"加入" forState:UIControlStateNormal];
    [_btJoinOrQuitGroup setBackgroundImage:image forState:UIControlStateNormal];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)joinOrQuitGroup:(id)sender {
  int groupId = [_groupInfo.groupId intValue];
  if (!_groupInfo.isJoin) {

    [RCDHTTPTOOL
        joinGroup:groupId
         complete:^(BOOL isOk) {
           dispatch_async(dispatch_get_main_queue(), ^{
             if (isOk) {
               _groupInfo.isJoin = YES;
               UIImage *image = [UIImage imageNamed:@"group_quit"];
               image = [image
                   stretchableImageWithLeftCapWidth:floorf(image.size.width / 2)
                                       topCapHeight:floorf(image.size.height /
                                                           2)];
               [_btJoinOrQuitGroup setTitle:@"删除并退出"
                                   forState:UIControlStateNormal];

               [_btChat setHidden:NO];
               [_btJoinOrQuitGroup setBackgroundImage:image
                                             forState:UIControlStateNormal];
             } else {
               NSString *msg = @"加入失败";
               if (_groupInfo.number == _groupInfo.maxNumber)
                 msg = @"群组人数已满";

               UIAlertView *alertView =
                   [[UIAlertView alloc] initWithTitle:nil
                                              message:msg
                                             delegate:nil
                                    cancelButtonTitle:@"确定"
                                    otherButtonTitles:nil, nil];
               [alertView show];

               [RCDDataSource syncGroups];
             }
           });

         }];
  } else {
    UIActionSheet *actionSheet =
        [[UIActionSheet alloc] initWithTitle:@"确定退出群组？"
                                    delegate:self
                           cancelButtonTitle:@"取消"
                      destructiveButtonTitle:@"确定"
                           otherButtonTitles:nil];
    [actionSheet showInView:self.view];
  }
}

- (IBAction)beginGroupChat:(id)sender {
  RCDChatViewController *temp = [[RCDChatViewController alloc] init];
  temp.targetId = _groupInfo.groupId;
  temp.conversationType = ConversationType_GROUP;
  temp.userName = _groupInfo.groupName;
  temp.title = _groupInfo.groupName;
  [self.navigationController pushViewController:temp animated:YES];
}

#pragma mark -UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  int groupId = [_groupInfo.groupId intValue];
  if (buttonIndex == 0) {
    [RCDHTTPTOOL
        quitGroup:groupId
         complete:^(BOOL isOk) {
           dispatch_async(dispatch_get_main_queue(), ^{
             if (isOk) {
               _groupInfo.isJoin = NO;
               UIImage *image = [UIImage imageNamed:@"group_add"];
               image = [image
                   stretchableImageWithLeftCapWidth:floorf(image.size.width / 2)
                                       topCapHeight:floorf(image.size.height /
                                                           2)];
               [_btJoinOrQuitGroup setTitle:@"加入"
                                   forState:UIControlStateNormal];
               [_btJoinOrQuitGroup setBackgroundImage:image
                                             forState:UIControlStateNormal];
               [RCDDataSource syncGroups];

               [_btChat setHidden:YES];
             } else {
               UIAlertView *alertView =
                   [[UIAlertView alloc] initWithTitle:nil
                                              message:@"退出失败！"
                                             delegate:nil
                                    cancelButtonTitle:@"确定"
                                    otherButtonTitles:nil, nil];
               [alertView show];
             }
           });
         }];
  }
}

@end
