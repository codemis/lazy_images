#import "RootViewController.h"
#import "AppRecord.h"
#import "IconDownloader.h"
#define kCustomRowCount     7
#pragma mark -
@interface RootViewController ()<UIScrollViewDelegate, IconDownloaderDelegate>
- (void)startIconDownload:(AppRecord *)appRecord forIndexPath:(NSIndexPath *)indexPath;
@end

@implementation RootViewController
#pragma mark 
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
}
#pragma mark - Table view creation (UITableViewDataSource)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int count = [self.entries count];
    return (count == 0) ? kCustomRowCount : count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"LazyTableCell";
    static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";
    int nodeCount = [self.entries count];
	if (nodeCount == 0 && indexPath.row == 0)
	{
        return [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier];
    }
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Leave cells empty because 7 are empty on load
    if (nodeCount > 0)
	{
        AppRecord *appRecord = (self.entries)[indexPath.row];
		cell.textLabel.text = appRecord.appName;
        cell.detailTextLabel.text = appRecord.artist;
        // Only load cached images; defer new downloads until scrolling ends
        if (!appRecord.appIcon)
        {
            if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
            {
                [self startIconDownload:appRecord forIndexPath:indexPath];
            }
            cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];                
        }
        else
        {
           cell.imageView.image = appRecord.appIcon;
        }
    }
    return cell;
}
#pragma mark - Table cell image support
- (void)startIconDownload:(AppRecord *)appRecord
             forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = self.imageDownloadsInProgress[indexPath];
    if (iconDownloader == nil) 
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.appRecord = appRecord;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        self.imageDownloadsInProgress[indexPath] = iconDownloader;
        [iconDownloader startDownload];
    }
}
// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([self.entries count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            AppRecord *appRecord = (self.entries)[indexPath.row];
            
            if (!appRecord.appIcon)
            {
                [self startIconDownload:appRecord forIndexPath:indexPath];
            }
        }
    }
}
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = self.imageDownloadsInProgress[indexPath];
    if (iconDownloader != nil)
    {
        UITableViewCell *cell =
          [self.tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        cell.imageView.image = iconDownloader.appRecord.appIcon;
    }
    [self.imageDownloadsInProgress removeObjectForKey:indexPath];
}
#pragma mark - Deferred image loading (UIScrollViewDelegate)
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

@end