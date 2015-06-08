//
//  RCWKStatusDelegate.h
//  RongIMLib
//
//  Created by litao on 15/6/4.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#ifndef RongIMLib_RCWKStatusDelegate_h
#define RongIMLib_RCWKStatusDelegate_h

/*
 * 该delegage是用来监听所有imlib的各种活动。实现该protocol用来通知watch kit各种状态变化。
 */
@protocol RCWKStatusDelegate <NSObject>

@optional

/*
 * 收到消息
 */
- (void)notifyWatchKitReceivedMessage:(RCMessage *)receivedMsg;

/*
 * 退出讨论组。创建结果通过notifyWatchKitDiscussionOperationCompletion获得
 */
- (void)notifyWatchKitQuitDiscussion:(NSString *)discussionId;
/*
 * 踢出成员。踢出结果通过notifyWatchKitDiscussionOperationCompletion获得
 */
- (void)notifyWatchKitRemoveMemberFromDiscussion:(NSString *)discussionId
                                          userId:(NSString *)userId;
/*
 * 添加成员。添加结果通过notifyWatchKitDiscussionOperationCompletion获得
 */
- (void)notifyWatchKitAddMemberToDiscussion:(NSString *)discussionId
                                 userIdList:(NSArray *)userIdList;
/*
 * 讨论组相关操作结果。tag：100-邀请；101-踢人；102-退出。status：0成功，非0失败
 */
- (void)notifyWatchKitDiscussionOperationCompletion:(int)tag status:(RCErrorCode)status;

/*
 * 创建讨论组
 */
- (void)notifyWatchKitCreateDiscussion:(NSString *)name
                            userIdList:(NSArray *)userIdList;

/*
 * 创建讨论组成功
 */
- (void)notifyWatchKitCreateDiscussionSuccess:(NSString *)discussionId;

/*
 * 创建讨论组失败
 */
- (void)notifyWatchKitCreateDiscussionError:(RCErrorCode)errorCode;

/*
 * 清除会话
 */
- (void)notifyWatchKitClearConversations:(NSArray *)conversationTypeList;

/*
 * 清除消息
 */
- (void)notifyWatchKitClearMessages:(RCConversationType)conversationType targetId:(NSString *)targetId;

/*
 * 清除未读状态
 */
- (void)notifyWatchKitClearUnReadStatus:(RCConversationType)conversationType targetId:(NSString *)targetId;

/*
 * 删除消息
 */
- (void)notifyWatchKitDeleteMessages:(NSArray *)messageIds;

/*
 * 发送消息
 */
- (void)notifyWatchKitSendMessage:(RCMessage *)message;

/*
 * 发送消息完成。status：0成功，非0失败
 */
- (void)notifyWatchKitSendMessageCompletion:(long)messageId status:(RCErrorCode)status;

/*
 * 上传图片进度
 */
- (void)notifyWatchKitUploadFileProgress:(int)progress  messageId:(long)messageId;

/*
 * 网络状态发生变化
 */
- (void)notifyWatchKitConnectionStatusChanged:(RCConnectionStatus) status;

@end
#endif
