#include "ChangePasswordVC.h"

#include "Base/package.h"
#include "Io/package.h"
#include "Math/package.h"

#include "GoCastTalk/package.h"

#import "InboxEntryCell.h"
#import "HeadingSubCell.h"

@interface ChangePasswordVC()
{
}
@end

@implementation ChangePasswordVC

-(void) refreshLanguage
{
    self.mChangePasswordLabel.text      = [NSString stringWithUTF8String:I18N::getInstance()->retrieve("Change Password").c_str()];
    self.mCurrentPasswordLabel.text     = [NSString stringWithUTF8String:I18N::getInstance()->retrieve("Current Password").c_str()];
    self.mNewPasswordLabel.text         = [NSString stringWithUTF8String:I18N::getInstance()->retrieve("New Password").c_str()];
    [self.mDoneButton setTitle:[NSString stringWithUTF8String:I18N::getInstance()->retrieve("Done").c_str()] forState:UIControlStateNormal];

    [self.mTable reloadData];
}

#pragma mark Construction / Destruction
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self refreshLanguage];

    self.view.autoresizesSubviews = YES;
    self.view.opaque = NO;

    self->mPickedIndex = 0;

    mPeer = new ChangePasswordScreen(self);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    delete mPeer;

    [super dealloc];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#pragma unused(tableView, section)

    if (tableView == self.mTable)
    {
        return (NSInteger)3;
    }

    return (NSInteger)1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
#pragma unused(tableView, indexPath)
    [cell setBackgroundColor:[UIColor whiteColor]];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#pragma unused(indexPath)
    const char* names[1] =
    {
        "Unimplemented",
    };

    if (tableView == self.mTable)
    {
        const char* from[] =
        {
            "Sato Taro",
            "Yamada Hanako",
            "Planning 2",
        };

        const char* date[] =
        {
            "12/21 12:24",
            "12/20 12:12",
            "12/18 11:43",
        };

        const char* transcription[] =
        {
            "",
            "",
            "",
        };

        const bool recv[] =
        {
            true,
            false,
            false,
        };

        const bool isGroup[] =
        {
            false,
            false,
            true,
        };

        tableView.backgroundView = nil;

        static NSString *simpleTableIdentifier = @"InboxEntryCell";

        InboxEntryCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

        if (cell == nil)
        {
            cell = [[[InboxEntryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier] autorelease];
        }

        cell.mFrom.text = [NSString stringWithUTF8String:from[indexPath.row]];
        cell.mDate.text = [NSString stringWithUTF8String:date[indexPath.row]];
        [cell setTranscription:transcription[indexPath.row]];
        cell.mStatusIcon.image = [UIImage imageNamed:([NSString stringWithUTF8String:I18N::getInstance()->retrieve(recv[indexPath.row] ? "icon-receive.png" : "icon-sent.png").c_str()])];
        cell.mFrom.textColor =  isGroup[indexPath.row] ?
            [UIColor colorWithRed:0.0f green:0.47f blue:1.0f alpha:1.0f] :
            [UIColor colorWithRed:0.0f green:0.0f  blue:0.0f alpha:1.0f];

        return cell;
    }
    else
    {
        tableView.backgroundView = nil;

        static NSString *simpleTableIdentifier = @"TableItem";

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier] autorelease];
        }

        cell.textLabel.text = [NSString stringWithUTF8String:names[0]];

        cell.imageView.image = nil;

        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
#pragma unused(tableView, indexPath)
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
#pragma unused(tableView, indexPath)
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
#pragma unused(tableView, indexPath)
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
//        if (tableView == self.mTable)
//        {
//            GCTEventManager::getInstance()->notify(GCTEvent(GCTEvent::kTableItemDeleted, (tUInt32)indexPath.row));
//        }
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.mOldPassword)
    {
        [self.mScrollView setContentOffset:CGPointMake(0, self.mOldPassword.frame.origin.y - 64) animated:YES];
    }
    else if (textField == self.mNewPassword)
    {
        [self.mScrollView setContentOffset:CGPointMake(0, self.mNewPassword.frame.origin.y - 64) animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
#pragma unused(textField)
    [textField endEditing:YES];
    [self.mScrollView setContentOffset:CGPointMake(0, -64) animated:YES];
    return YES;
}

-(void)setBlockingViewVisible:(bool)newVisible
{
    [self.mBlockingView setHidden:newVisible ? NO : YES];
}

-(std::string)getOldPassword
{
    const char* result = [self.mOldPassword.text UTF8String];
    return result ? result : "";
}

-(std::string)getNewPassword
{
    const char* result = [self.mNewPassword.text UTF8String];
    return result ? result : "";
}

-(void) popSelf
{
    [(UINavigationController*)self.parentViewController popViewControllerAnimated:TRUE];
}

-(IBAction)savePressed
{
    mPeer->savePressed();
}

@end