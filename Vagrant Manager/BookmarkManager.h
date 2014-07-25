//
//  BookmarkManager.h
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookmarkManager : NSObject {
    NSMutableArray *_bookmarks;
}

+ (BookmarkManager*)sharedManager;

- (void)loadBookmarks;
- (void)saveBookmarks;
- (void)clearBookmarks;
- (NSMutableArray*)getBookmarks;
- (Bookmark*)addBookmark:(Bookmark*)bookmark;
- (Bookmark*)addBookmarkWithPath:(NSString*)path displayName:(NSString*)displayName providerIdentifier:(NSString*)providerIdentifier;
- (void)removeBookmarkWithPath:(NSString*)path;
- (Bookmark*)getBookmarkWithPath:(NSString*)path;

@end
