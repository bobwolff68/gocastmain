#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AVFoundation/AVFoundation.h>

@interface GroupsVC : UIViewController
<
    UITableViewDelegate,
    UITableViewDataSource,
    UIAlertViewDelegate
>
{
}

//mInboxView
@property (nonatomic, strong) IBOutlet UITableView*     mTable;

#pragma mark Construction / Destruction
- (void)viewDidLoad;

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end