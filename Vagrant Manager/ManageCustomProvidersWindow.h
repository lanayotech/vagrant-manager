//
//  ManageCustomProvidersWindow.h
//  Vagrant Manager
//
//  Copyright (c) 2019 Lanayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseWindowController.h"

@interface ManageCustomProvidersWindow : BaseWindowController <NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate, NSTextFieldDelegate> {
    NSMutableArray *_providers;
}

@property (weak) IBOutlet NSButton *addProviderButton;
@property (weak) IBOutlet NSButton *removeProviderButton;
@property (weak) IBOutlet NSTableView *providersTableView;

- (IBAction)addProviderButtonClicked:(id)sender;
- (IBAction)removeProviderButtonClicked:(id)sender;

@end
