#import <UIKit/UIKit.h>

#include "Base/package.h"

#include <string>

void tAlert(const std::string& msg)
{
	UIAlertView* alert = [[UIAlertView alloc] init];

	alert.title = @"Alert";
	alert.message = [NSString stringWithUTF8String:msg.c_str()];
    [alert addButtonWithTitle:@"Okay"];

    [alert show];
    
    [alert release];
}
