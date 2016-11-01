//
//  ViewController.m
//  XMPP的使用
//
//  Created by zzl on 2016/11/1.
//  Copyright © 2016年 Zhou. All rights reserved.
//

#import "ViewController.h"
#import "XMPPTools.h"
@interface ViewController () <ZhouMessageDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    XMPPTools *xmpp = [XMPPTools sharedXMPPTools];
    xmpp.messageDelegate = self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
