#include <Cocoa/Cocoa.h>
#import "PasswordHelper.h"

int main() {
    NSArray *promptArray = [PasswordHelper promptForPassword];
    NSInteger returnCode = [[promptArray objectAtIndex:1] intValue];
    if (returnCode == 0) {
        void *pword = (void*)[[promptArray objectAtIndex:0] UTF8String];
        printf("%s\n", (char*)pword);
        return 0;
    } else if (returnCode == 1) {
        return 1;
    }
}



