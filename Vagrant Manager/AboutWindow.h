//
//  AboutWindowController.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "BaseWindowController.h"

@interface AboutWindow : BaseWindowController <WebPolicyDecisionListener
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= __MAC_10_11
, WebPolicyDelegate, WebFrameLoadDelegate, WebUIDelegate
#endif
>

@property (weak) IBOutlet WebView *webView;

@end
