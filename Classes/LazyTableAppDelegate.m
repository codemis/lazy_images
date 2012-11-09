#import "LazyTableAppDelegate.h"
#import "AppTableViewController.h"
#import "ParseOperation.h"
// This framework was imported so we could use the kCFURLErrorNotConnectedToInternet error code.
#import <CFNetwork/CFNetwork.h>
static NSString *const TopPaidAppsFeed =
	@"http://phobos.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/toppaidapplications/limit=75/xml";
@interface LazyTableAppDelegate ()
@property (nonatomic, strong) AppTableViewController *appTableVC;
@end

@implementation LazyTableAppDelegate
#pragma mark -
- (BOOL)            application:(UIApplication *)application
  didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.appRecords = [NSMutableArray array];
    self.appTableVC = (AppTableViewController *)((UINavigationController *) self.window.rootViewController).topViewController;
    self.appTableVC.entries = self.appRecords;
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:TopPaidAppsFeed]];
    self.appListFeedConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    // Test the validity of the connection object. The most likely reason for the connection object
    // to be nil is a malformed URL, which is a programmatic error easily detected during development
    // If the URL is more dynamic, then you should implement a more flexible validation technique, and
    // be able to both recover from errors and communicate problems to the user in an unobtrusive manner.
    //
    NSAssert(self.appListFeedConnection != nil, @"Failure to create URL connection.");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    return YES;
}
- (void)handleLoadedApps:(NSArray *)loadedApps
{
    [self.appRecords addObjectsFromArray:loadedApps];
    [self.appTableVC.tableView reloadData];
}
#pragma mark - NSURLConnection delegate methods
- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Show Top Paid Apps"
														message:errorMessage
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
    [alertView show];
}
- (void)    connection:(NSURLConnection *)connection
    didReceiveResponse:(NSURLResponse *)response
{
    self.appListData = [NSMutableData data];
}
- (void)    connection:(NSURLConnection *)connection
        didReceiveData:(NSData *)data
{
    [self.appListData appendData:data];
}
- (void)    connection:(NSURLConnection *)connection
      didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([error code] == kCFURLErrorNotConnectedToInternet)
	{
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"No Connection Error"};
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
														 code:kCFURLErrorNotConnectedToInternet
													 userInfo:userInfo];
        [self handleError:noConnectionError];
    }
	else
	{
        [self handleError:error];
    }
    self.appListFeedConnection = nil;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.appListFeedConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.queue = [[NSOperationQueue alloc] init];
    ParseOperation *parser = [[ParseOperation alloc] initWithData:self.appListData
                                                completionHandler:^(NSArray *appList) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleLoadedApps:appList];
        });
        self.queue = nil;
    }];
    parser.errorHandler = ^(NSError *parseError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleError:parseError];
        });
    };
    [self.queue addOperation:parser];
    self.appListData = nil;// transferred ownership to the parse operation
}
@end