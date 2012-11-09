#import "AppRecord.h"
#import "ParseOperation.h"
@interface LazyTableAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSMutableArray *appRecords;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSURLConnection *appListFeedConnection;
@property (nonatomic, strong) NSMutableData *appListData;
@end

