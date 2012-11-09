@interface RootViewController : UITableViewController
@property (nonatomic, strong) NSArray *entries;
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@end