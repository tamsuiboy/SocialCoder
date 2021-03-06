//
//  RepositoriesTableViewController.m
//  SocialCoder
//
//  Created by Toni Suter on 18.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RepositoriesTableViewController.h"
#import "GitHubRepositoryServiceFactory.h"
#import "GitHubCommitServiceFactory.h"
#import "GitHubServiceSettings.h"
#import "RepositoryCell.h"
#import "FileBrowserTableViewController.h"
#import "ShadowedTableView.h"

@implementation RepositoriesTableViewController

@synthesize tableData;

#pragma mark -
#pragma mark Initialization


- (id)init {
    self = [super init];
    if (self) {
        self.tableView = [[ShadowedTableView alloc] init];
        [self.tableView setRowHeight:100];
		[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.tableView setBackgroundColor:[UIColor clearColor]];
        
        UIView *bgView = [[UIView alloc] initWithFrame:self.view.bounds];
        [bgView setBackgroundColor:[UIColor grayColor]];
        [self.tableView setBackgroundView:bgView];
        [bgView release];
    
		tableData = [[NSMutableArray alloc] initWithObjects:
					 [NSMutableArray array],
					 [NSMutableArray array],
					 nil];
		
		[self setTitle:@"Repositories"];
    }
    return self;
}

- (void)loadContent  {
	[[tableData objectAtIndex:0] removeAllObjects];
	[[tableData objectAtIndex:1] removeAllObjects];
	[GitHubRepositoryServiceFactory requestRepositoriesOwnedByUser:[[GitHubServiceSettings credential] user] delegate:self];
}

-(void)gitHubService:(id<GitHubService>)gitHubService gotRepository:(id<GitHubRepository>)repository  {
	[[tableData objectAtIndex:0] addObject:repository];
}

-(void)gitHubService:(id <GitHubService>)gitHubService gotCommit:(id <GitHubCommit>)commit  {
	[gitHubService cancelRequest];
	[[tableData objectAtIndex:1] addObject:[commit sha]];
	[self loadNextCommit];
}

-(void)gitHubService:(id<GitHubService>)gitHubService didFailWithError:(NSError *)error  {

}

-(void)gitHubServiceDone:(id<GitHubService>)gitHubService  {
	[self loadNextCommit];
}

- (void)loadNextCommit  {
	static int i = 0;
	if(i < [[tableData objectAtIndex:0] count])  {
		[GitHubCommitServiceFactory requestCommitsOnBranch:@"master" 
												repository:[[[tableData objectAtIndex:0] objectAtIndex:i] name]
													  user:[[GitHubServiceSettings credential] user] 
												  delegate:self];
		i++;
	}
	else  {
		[self.tableView reloadData];
	}
}


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[tableData objectAtIndex:0] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RepositoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	[[cell nameLabel] setText:[[[tableData objectAtIndex:0] objectAtIndex:indexPath.row] name]];
	[[cell descLabel] setText:[[[tableData objectAtIndex:0] objectAtIndex:indexPath.row] desc]];
	[[cell homepageLabel] setText:[[[[tableData objectAtIndex:0] objectAtIndex:indexPath.row] homepage] absoluteString]];
	[[cell forksLabel] setText:[NSString stringWithFormat:@"%d", [[[tableData objectAtIndex:0] objectAtIndex:indexPath.row] forks]]];
	[[cell watchersLabel] setText:[NSString stringWithFormat:@"%d", [[[tableData objectAtIndex:0] objectAtIndex:indexPath.row] watchers]]];
	
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	FileBrowserTableViewController *fileBrowser = [[FileBrowserTableViewController alloc] initWithRepository:[[[tableData objectAtIndex:0] objectAtIndex:indexPath.row] name] 
																									  andSha:[[tableData objectAtIndex:1] objectAtIndex:indexPath.row]];
	[fileBrowser setTitle:[[[tableData objectAtIndex:0] objectAtIndex:indexPath.row] name]];
	[self.navigationController pushViewController:fileBrowser animated:YES];
	[fileBrowser release];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[tableData release];
    [super dealloc];
}


@end

