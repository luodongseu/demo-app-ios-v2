//
//  RCDChatListCell.m
//  RCloudMessage
//
//  Created by Liv on 15/4/15.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#define HEXCOLOR(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#import "RCDChatListCell.h"

@implementation RCDChatListCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        _ivAva = [UIImageView new];
        _ivAva.clipsToBounds = YES;
        _ivAva.layer.cornerRadius = 6.0f;
        if ([[RCIM sharedRCIM]globalConversationAvatarStyle]==RC_USER_AVATAR_CYCLE) {
            _ivAva.layer.cornerRadius=[[RCIM sharedRCIM]globalConversationPortraitSize].height/2;
        }
        
        [_ivAva setBackgroundColor:[UIColor blackColor]];
        
        _lblDetail = [UILabel new];
        [_lblDetail setFont:[UIFont systemFontOfSize:14.f]];
        [_lblDetail setTextColor:HEXCOLOR(0x8c8c8c)];
        _lblDetail.text = [NSString stringWithFormat:@"来自%@的好友请求",_userName];
        
        _lblName = [UILabel new];
        [_lblName setFont:[UIFont boldSystemFontOfSize:16.f]];
        [_lblName setTextColor:HEXCOLOR(0x252525)];
        _lblName.text = @"好友消息";
        
        [self addSubview:_ivAva];
        [self addSubview:_lblDetail];
        [self addSubview:_lblName];
        _ivAva.translatesAutoresizingMaskIntoConstraints = NO;
        _lblName.translatesAutoresizingMaskIntoConstraints = NO;
        _lblDetail.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *_bindingViews = NSDictionaryOfVariableBindings(_ivAva,_lblName,_lblDetail);
        
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-13-[_ivAva(width)]" options:0 metrics:@{@"width" :@([RCIM sharedRCIM].globalConversationPortraitSize.width)} views:NSDictionaryOfVariableBindings(_ivAva)]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_ivAva(height)]" options:0 metrics:@{@"height" :@([RCIM sharedRCIM].globalConversationPortraitSize.height)} views:NSDictionaryOfVariableBindings(_ivAva)]];
    
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_lblName(18)]-[_lblDetail(18)]" options:kNilOptions metrics:kNilOptions views:_bindingViews]];
        
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_lblName attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_ivAva attribute:NSLayoutAttributeTop multiplier:1.0 constant:2.f]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_lblName attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_ivAva attribute:NSLayoutAttributeRight multiplier:1.0 constant:8]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_lblDetail attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_lblName attribute:NSLayoutAttributeLeft multiplier:1.0 constant:1]];

    }
    return self;
}

@end
