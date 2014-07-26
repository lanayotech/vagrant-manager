//
//  BookmarkManager.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "BookmarkManager.h"

@implementation BookmarkManager

+ (BookmarkManager*)sharedManager {
    static BookmarkManager *manager;
    @synchronized(self) {
        if(manager == nil) {
            manager = [[BookmarkManager alloc] init];
        }
    }
    
    return manager;
}

- (id)init {
    self = [super init];
    
    if(self) {
        _bookmarks = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)loadBookmarks {
    @synchronized(_bookmarks) {
        [_bookmarks removeAllObjects];
    
        NSArray *savedBookmarks = [[NSUserDefaults standardUserDefaults] arrayForKey:@"bookmarks"];
        if(savedBookmarks) {
            for(NSDictionary *savedBookmark in savedBookmarks) {
                [self addBookmarkWithPath:[savedBookmark objectForKey:@"path"] displayName:[savedBookmark objectForKey:@"displayName"] providerIdentifier:[savedBookmark objectForKey:@"providerIdentifier"]];
            }
        }
    }
}

- (void)saveBookmarks {
    @synchronized(_bookmarks) {
        NSMutableArray *bookmarks = [self getBookmarks];
        if(bookmarks) {
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            for(Bookmark *b in bookmarks) {
                [arr addObject:@{@"displayName":b.displayName, @"path":b.path, @"providerIdentifier":b.providerIdentifier?:@""}];
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"bookmarks"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (void)clearBookmarks {
    @synchronized(_bookmarks) {
        [_bookmarks removeAllObjects];
    }
}

- (Bookmark*)addBookmark:(Bookmark*)bookmark {
    Bookmark *existing = [self getBookmarkWithPath:bookmark.path];
    
    if(existing) {
        return existing;
    }
    
    @synchronized(_bookmarks) {
        [_bookmarks addObject:bookmark];
    }
    
    return bookmark;
}

- (NSMutableArray*)getBookmarks {
    NSMutableArray *bookmarks;
    @synchronized(_bookmarks) {
        bookmarks = [NSMutableArray arrayWithArray:_bookmarks];
    }
    return bookmarks;
}

- (Bookmark*)addBookmarkWithPath:(NSString*)path displayName:(NSString*)displayName providerIdentifier:(NSString*)providerIdentifier {
    Bookmark *bookmark = [self getBookmarkWithPath:path];
    if(bookmark) {
        return bookmark;
    }
    
    bookmark = [[Bookmark alloc] init];
    bookmark.displayName = displayName;
    bookmark.path = path;
    if(!providerIdentifier || [providerIdentifier length] == 0) {
        bookmark.providerIdentifier = [[VagrantManager sharedManager] detectVagrantProvider:path];
    } else {
        bookmark.providerIdentifier = providerIdentifier;
    }
    @synchronized(_bookmarks) {
        [_bookmarks addObject:bookmark];
    }
    
    return bookmark;
}

- (void)removeBookmarkWithPath:(NSString*)path {
    Bookmark *bookmark = [self getBookmarkWithPath:path];
    if(bookmark) {
        @synchronized(_bookmarks) {
            [_bookmarks removeObject:bookmark];
        }
    }
}

- (Bookmark*)getBookmarkWithPath:(NSString*)path {
    @synchronized(_bookmarks) {
        for(Bookmark *bookmark in _bookmarks) {
            if([bookmark.path isEqualToString:path]) {
                return bookmark;
            }
        }
    }
    
    return nil;
}

- (int)getIndexOfBookmarkWithPath:(NSString*)path {
    for(int i=0; i<_bookmarks.count; ++i) {
        Bookmark *bookmark = [_bookmarks objectAtIndex:i];
        if([bookmark.path isEqualToString:path]) {
            return i;
        }
    }
    
    return -1;
}

@end
