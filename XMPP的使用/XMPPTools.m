//
//  XMPP.m
//  EETOP_IN
//
//  Created by zzl on 2016/10/27.
//  Copyright © 2016年 TCGroup. All rights reserved.
//

#import "XMPPTools.h"
//#import "NSString+MD5Addition.h"
#define kUserDefaults [NSUserDefaults standardUserDefaults]
@interface XMPPTools ()

@end

@implementation XMPPTools
#pragma mark 单例方法的实现
+ (XMPPTools *)sharedXMPPTools {
    static XMPPTools *tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[XMPPTools alloc] init];
    });
    return tool;
}

- (instancetype)init
{
    self.xmppStream = [[XMPPStream alloc] init];
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];

    return self;
}

- (BOOL)connect {
    //按照你公司文档的要求拼接userID
    NSString *userID = [NSString stringWithFormat:@"%@@Zhou.com/Smack",@"这里放userID"];
    //密码
    NSString *passWord = [kUserDefaults objectForKey:@"password"];
    //服务器地址
    NSString *server = @"10.10.10.10";
    if (![self.xmppStream isDisconnected]) {
        return YES;
    }
    if (userID == nil || passWord == nil) {
        return NO;
    }
    //设置用户
    [self.xmppStream setMyJID:[XMPPJID jidWithString:userID]];
    //设置服务器
    [self.xmppStream setHostName:server];
    [self.xmppStream setHostPort:5222]; //端口
    //密码
    self.password = [passWord stringFromMD5];   //我这里是使用了MD5加密
    //连接服务器
    NSError *error = nil;
    [self.xmppStream connectWithTimeout:10.0f error:&error];
    if (error) {
        NSLog(@"cant connect%@",error);
        return NO;
    }
    self.userID = userID;
    return YES;
}

- (void)disconnect {
    [self goOffline];
    [self.xmppStream disconnect];
}

- (void)goOnline {
    //发送在线状态
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
}

- (void)goOffline {
    //发送下线状态
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}

#pragma mark --XMPPStreamDelegate
//连接服务器
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    _isOpen = YES;
    NSError *error = nil;
    [[self xmppStream] authenticateWithPassword:self.password error:&error];
}

//验证通过
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    NSLog(@"验证通过");
    [self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    NSLog(@"%@",error);
}

//收到信息是会调用
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    NSString *msg = [[message elementForName:@"body"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:msg forKey:@"msg"];
    [dic setObject:from forKey:@"sender"];
    NSDate *date = [NSDate date];
    [dic setObject:[NSString stringWithFormat:@"%@",date] forKey:@"date"];
    //消息委托
    if ([self.messageDelegate respondsToSelector:@selector(newMessageReceived:)]) {
        [self.messageDelegate newMessageReceived:dic];
    }
}

//收到好友状态
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    //取得好友状态
    NSString *presenceType = [presence type];
    //当前用户
    NSString *userID = [[sender myJID] user];
    //在线用户
    NSString *presenceFromUser = [[presence from] user];
    if (![presenceFromUser isEqualToString:userID]) {
        //在线状态
        if ([presenceType isEqualToString:@"available"]) {
            //用户列表委托
            if ([self.chatDelegate performSelector:@selector(newBuddyOnline:)]) {
                [self.chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@",presenceFromUser,@"nqc1338a"]];
            }
        }else if ([presenceType isEqualToString:@"unavailable"]){
            //用户列表委托
            if ([self.chatDelegate performSelector:@selector(buddyWentOffline:)]) {
                [self.chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@",presenceFromUser,@"nqc1338a"]];
            }
        }
    }
}

//发送信息
- (void)sendNewMessage:(NSString *)message toUser:(NSString *)chatWithUser {
#pragma mark - 这是简单的xml 你的自己去组合自己公司的格式
    //XMPPFramework主要是通过KissXML来生成XML文件
    //生成<body>文档
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:message];
    
    //生成XML消息文档
    NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
    //消息类型
    [mes addAttributeWithName:@"type" stringValue:@"chat"];
    //发送给谁
    [mes addAttributeWithName:@"to" stringValue:chatWithUser];
    //由谁发送
    [mes addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:USERID]];
    //组合
    [mes addChild:body];
    
    //发送消息
    [[self xmppStream] sendElement:mes];
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
    NSLog(@"消息发送成功");
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error {
    NSLog(@"消息发送失败:%@",error);
}

- (NSString *)getTime {
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
    return timeString;
}




@end
/*
<message type="chat" to="c757e24a-fe37-4c07-8574-18c3309367e4@eetop.com/Smack" from="9b7533ba-72aa-4a01-920b-83f24834a904@eetop.com/Smack"><body>哈哈</body></message>

<message xmlns="jabber:client" type="chat" to="9b7533ba-72aa-4a01-920b-83f24834a904@eetop.com/Smack" from="c757e24a-fe37-4c07-8574-18c3309367e4@eetop.com/Smack" id="1477642445119"><properties xmlns="http://www.jivesoftware.com/xmlns/xmpp/properties"><property><name>groupname</name><value type="string">周大王005</value></property><property><name>send_time</name><value type="long">1477642445162</value></property><property><name>name</name><value type="string">周大王005</value></property><property><name>avatar_path</name><value type="string">http://tcfs.topchoice.com.cn/eetopin/test/pic/avatar/mobileUser/204/53a7d47b487c8.jpg</value></property><property><name>type</name><value type="integer">0</value></property><property><name>globalId</name><value type="string">79928FD0-C055-4230-B0C5-8A5B5207A894</value></property><property><name>grouptype</name><value type="integer">2</value></property><property><name>ent_id</name><value type="string">70709</value></property></properties><body>Asss</body></message>


*/






