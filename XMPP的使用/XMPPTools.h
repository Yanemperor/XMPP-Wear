//
//  XMPP.h
//  EETOP_IN
//
//  Created by zzl on 2016/10/27.
//  Copyright © 2016年 TCGroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XMPPFramework/XMPPFramework.h>

@protocol ZhouChatDelegate <NSObject>
//在线好友
- (void)newBuddyOnline:(NSString *)buddyName;
//好友下线
- (void)buddyWentOffline:(NSString *)buddyName;
- (void)didDisconnect;

@end

@protocol ZhouMessageDelegate <NSObject>

//收到信息时会调用
- (void)newMessageReceived:(NSDictionary *)messageContent;

@end

@interface XMPPTools : NSObject <XMPPStreamDelegate>

@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, assign) BOOL isOpen;   //xmppStream是否开着
@property (nonatomic, weak) id<ZhouChatDelegate> chatDelegate;
@property (nonatomic, weak) id<ZhouMessageDelegate> messageDelegate;
+ (XMPPTools *)sharedXMPPTools;
//是否连接
- (BOOL)connect;
//断开连接
- (void)disconnect;
//上线
- (void)goOnline;
//下线
- (void)goOffline;

- (void)sendNewMessage:(NSString *)message toUser:(NSString *)chatWithUser;






@end
