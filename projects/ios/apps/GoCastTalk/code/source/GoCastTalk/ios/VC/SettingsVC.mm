#include "SettingsVC.h"
#include "ChangeRegisteredNameVC.h"
#include "ChangePasswordVC.h"
#include "ChangeLanguageVC.h"
#include "AboutVC.h"

#include "Base/package.h"
#include "Math/package.h"
#include "Io/package.h"

#include "GoCastTalk/package.h"

#import "InboxEntryCell.h"
#import "HeadingSubCell.h"

@interface SettingsVC()
{
}
@end

@implementation SettingsVC

-(void)refreshLanguage
{
    [self.mTable reloadData];
}

#pragma mark Construction / Destruction
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self refreshLanguage];

    [self.mTable registerNib:[UINib nibWithNibName:@"HeadingSubCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"HeadingSubCell"];

    self.view.autoresizesSubviews = YES;

    mPeer = new SettingsScreen(self);
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
        return (NSInteger)5;
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
        const char* heading[] =
        {
            "Language",
            "Registered Name",
            "Change Password",
            "Log Out",
            "About this app",
        };

        const char* subheading[] =
        {
            "",
            "",
            "",
            "",
            "",
        };

        const bool hasRightArrow[] =
        {
            true,
            true,
            true,
            false,
            true,
        };

        tableView.backgroundView = nil;

        static NSString *simpleTableIdentifier = @"HeadingSubCell";

        HeadingSubCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

        if (cell == nil)
        {
            cell = [[[HeadingSubCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier] autorelease];
        }

        cell.mHeading.text = [NSString stringWithUTF8String:I18N::getInstance()->retrieve(heading[indexPath.row]).c_str()];
        cell.mSub.text = [NSString stringWithUTF8String:I18N::getInstance()->retrieve(subheading[indexPath.row]).c_str()];
        cell.mRightArrow.hidden = hasRightArrow[indexPath.row] ? NO : YES;
        
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
    switch (indexPath.row)
    {
        case 0: mPeer->changeLanguagePressed(); break;
        case 1: mPeer->registeredNamePressed(); break;
        case 2: mPeer->changePasswordPressed(); break;
        case 3: mPeer->logOutPressed(); break;
        case 4: mPeer->aboutThisAppPressed(); break;

        default:
            break;
    }
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

-(void) pushChangeRegisteredName:(const JSONObject&)newObject
{
    ChangeRegisteredNameVC* nextVC = [[[ChangeRegisteredNameVC alloc] initWithNibName:@"ChangeRegisteredNameVC" bundle:nil] autorelease];
    [nextVC customInit:newObject];
    [(UINavigationController*)self.parentViewController  pushViewController:nextVC animated:YES];
}

-(void) pushAbout
{
    AboutVC* nextVC = [[[AboutVC alloc] initWithNibName:@"AboutVC" bundle:nil] autorelease];
    [(UINavigationController*)self.parentViewController  pushViewController:nextVC animated:YES];
}

-(void) pushChangePassword
{
    ChangePasswordVC* nextVC = [[[ChangePasswordVC alloc] initWithNibName:@"ChangePasswordVC" bundle:nil] autorelease];
    [(UINavigationController*)self.parentViewController  pushViewController:nextVC animated:YES];
}

-(void) pushChangeLanguage
{
    ChangeLanguageVC* nextVC = [[[ChangeLanguageVC alloc] initWithNibName:@"ChangeLanguageVC" bundle:nil] autorelease];
    [(UINavigationController*)self.parentViewController  pushViewController:nextVC animated:YES];
}

@end
