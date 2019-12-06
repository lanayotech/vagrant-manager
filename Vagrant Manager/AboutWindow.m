//
//  AboutWindowController.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "AboutWindow.h"
#import "Environment.h"

@interface AboutWindow ()

@end

@implementation AboutWindow

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];

    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    BOOL isDarkMode = [[[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"] isEqualToString:@"Dark"];
    
    NSString *styles = @"";
    
    if (isDarkMode) {
        styles = @"<style>body { color:#fff; } a { color: #66f; }</style>";
    }

    NSString *str = [NSString stringWithFormat:@"%@<div style=\"text-align:center;font-family:Arial;font-size:13px\">Copyright &copy;{YEAR} Lanayo Tech<br><br>Vagrant Manager {VERSION}<br><br>For more information visit:<br><a href=\"{URL}\">{URL}</a><br><br>or check us out on GitHub:<br><a href=\"{GITHUB_URL}\">{GITHUB_URL}</a></div>", styles];
    
    NSString *dateString = [NSString stringWithCString:__DATE__ encoding:NSASCIIStringEncoding];
    NSString *yearString = [dateString substringWithRange:NSMakeRange([dateString length] - 4, 4)];
    
    str = [str stringByReplacingOccurrencesOfString:@"{YEAR}" withString:yearString];
    str = [str stringByReplacingOccurrencesOfString:@"{VERSION}" withString:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"]];
    str = [str stringByReplacingOccurrencesOfString:@"{URL}" withString:[[Environment sharedInstance] aboutURL]];
    str = [str stringByReplacingOccurrencesOfString:@"{GITHUB_URL}" withString:[[Environment sharedInstance] githubURL]];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
    
    self.webView.policyDelegate = self;
    [self.webView setDrawsBackground:NO];
    [self.webView.mainFrame loadHTMLString:str baseURL:nil];
}

- (void)webView:(WebView*)webView decidePolicyForNavigationAction:(NSDictionary*)actionInformation request:(NSURLRequest*)request frame:(WebFrame*)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
    NSString *host = [[request URL] host];
    if(host) {
        [[NSWorkspace sharedWorkspace] openURL:[request URL]];
    } else {
        [listener use];
    }
}

- (void)use {
}

- (void)download {
}

- (void)ignore {
}

@end
