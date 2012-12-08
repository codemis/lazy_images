#import "LazyTableAppDelegate.h"
#import "AppTableViewController.h"
#import "ParseOperation.h"
#import <CFNetwork/CFNetwork.h> // For kCFURLErrorNotConnectedToInternet error
static NSString *const TopPaidAppsFeed =
	@"http://phobos.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/"
    @"toppaidapplications/limit=75/xml";

@interface LazyTableAppDelegate ()
@property (nonatomic, strong) AppTableViewController *appTableVC;
@end

@implementation LazyTableAppDelegate
#pragma mark -
- (BOOL)            application:(UIApplication *)application
  didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.appRecords = [NSMutableArray array];
    self.appTableVC = (AppTableViewController *)((UINavigationController *)
      self.window.rootViewController).topViewController;
    self.appTableVC.entries = self.appRecords;
    NSURLRequest *urlRequest =
      [NSURLRequest requestWithURL:[NSURL URLWithString:TopPaidAppsFeed]];
    self.appListFeedConnection =
      [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    NSAssert(self.appListFeedConnection != nil,
             @"Failure to create URL connection.");         // Programmer error
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.appListData = [NSMutableData data];
    return YES;
}
- (void)handleLoadedApps:(NSArray *)loadedApps
{
    [self.appRecords addObjectsFromArray:loadedApps];
    [self.appTableVC.tableView reloadData];
}
- (void)reportError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"Cannot Show Top Paid Apps"
                                message:[error localizedDescription]
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}
#pragma mark - NSURLConnection delegate methods             //TODO: protocol?
- (void)    connection:(NSURLConnection *)connection
    didReceiveResponse:(NSURLResponse *)response
{
    self.appListData.length = 0;
}
- (void)    connection:(NSURLConnection *)connection
        didReceiveData:(NSData *)data
{
    [self.appListData appendData:data];
}
- (void)    connection:(NSURLConnection *)connection
      didFailWithError:(NSError *)error
{
    self.appListFeedConnection = nil;           //FIXME: Use connection parm?
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if ([error code] == kCFURLErrorNotConnectedToInternet)
	{
        NSDictionary *userInfo =
          @{NSLocalizedDescriptionKey: @"No Connection Error"};
        NSError *noConnectionError =
          [NSError errorWithDomain:NSCocoaErrorDomain
                              code:kCFURLErrorNotConnectedToInternet
                          userInfo:userInfo];
        [self reportError:noConnectionError];
    }
	else
	{
        [self reportError:error];
    }
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.appListFeedConnection = nil;           //FIXME: Use connection parm?
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.queue = [[NSOperationQueue alloc] init];
    ParseOperation *parser =
      [[ParseOperation alloc] initWithData:self.appListData
                         completionHandler:^(NSArray *appList) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleLoadedApps:appList];
        });
        self.queue = nil;
    }];
    parser.errorHandler = ^(NSError *parseError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reportError:parseError];
        });                                     //FIXME: Also self.queue = nil?
    };
    [self.queue addOperation:parser];
    self.appListData = nil;                     // transfers ownership to parser
}
@end