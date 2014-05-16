#include "CreateContactVC.h"

#include "Base/package.h"
#include "Io/package.h"
#include "Math/package.h"

#include "GoCastTalk/package.h"

#import "InboxEntryCell.h"
#import "HeadingSubCell.h"

@interface CreateContactVC()
{
}
@end

@implementation CreateContactVC

- (void)refreshLanguage
{
    self.mTitleLabel.text           = [NSString stringWithUTF8String:I18N::getInstance()->retrieve("Create Contact").c_str()];
    self.mFullNameLabel.text        = [NSString stringWithUTF8String:I18N::getInstance()->retrieve("Full Name").c_str()];
    self.mNickNameLabel.text        = [NSString stringWithUTF8String:I18N::getInstance()->retrieve("Nick Name").c_str()];
    self.mEmailAddressLabel.text   = [NSString stringWithUTF8String:I18N::getInstance()->retrieve("Email Address").c_str()];
    [self.mDoneButton setTitle:[NSString stringWithUTF8String:I18N::getInstance()->retrieve("Done").c_str()] forState:UIControlStateNormal];

    [self.mTable reloadData];
}

#pragma mark Construction / Destruction
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self refreshLanguage];

    self.view.autoresizesSubviews = YES;

    mPeer = new CreateContactScreen(self);
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

-(void)setBlockingViewVisible:(bool)newVisible
{
    [self.mBlockingView setHidden:newVisible ? NO : YES];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.mKanji)
    {
        [self.mScrollView setContentOffset:CGPointMake(0, self.mKanji.frame.origin.y - 60) animated:YES];
    }
    else if (textField == self.mKana)
    {
        [self.mScrollView setContentOffset:CGPointMake(0, self.mKana.frame.origin.y - 60) animated:YES];
    }
    else if (textField == self.mEmail)
    {
        [self.mScrollView setContentOffset:CGPointMake(0, self.mEmail.frame.origin.y - 60) animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
#pragma unused(textField)
    [textField endEditing:YES];
    [self.mScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    return YES;
}

-(void) popSelf
{
    [(UINavigationController*)self.parentViewController popViewControllerAnimated:TRUE];
}

-(IBAction)savePressed
{
    JSONObject saveObject;

    const char* email   = [self.mEmail.text UTF8String];
    const char* kanji   = [self.mKanji.text UTF8String];
    const char* kana    = [self.mKana.text  UTF8String];

    saveObject["email"] = JSONValue(email ? email : std::string(""));
    saveObject["kanji"] = JSONValue(kanji ? kanji : std::string(""));
    saveObject["kana"]  = JSONValue(kana  ? kana  : std::string(""));

    mPeer->savePressed(saveObject);
}

@end