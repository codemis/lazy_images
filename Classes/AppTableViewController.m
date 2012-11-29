#import "AppTableViewController.h"
#import "AppRecord.h"
#import "UIImageView+WebCache.h"

@implementation AppTableViewController
#pragma mark - Table view creation (UITableViewDataSource)
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.entries count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"LazyTableCell";
    UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    AppRecord *appRecord = (self.entries)[indexPath.row];
    cell.textLabel.text = appRecord.appName;
    cell.detailTextLabel.text = appRecord.artist;
    [cell.imageView
       setImageWithURL:[NSURL URLWithString:appRecord.imageURLString]
      placeholderImage:[UIImage imageNamed:@"Placeholder.png"]];
    return cell;
}
@end