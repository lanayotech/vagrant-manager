//
//  AboutWindowController.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "BaseWindowController.h"

@interface AboutWindow : BaseWindowController <WebPolicyDecisionListener>

@property (weak) IBOutlet WebView *webView;

@end
