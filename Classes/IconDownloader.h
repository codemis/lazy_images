@class AppRecord;
@class RootViewController;
@protocol IconDownloaderDelegate;
@interface IconDownloader : NSObject
@property (nonatomic, strong) AppRecord *appRecord;
@property (nonatomic, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, weak) id <IconDownloaderDelegate> delegate;
@property (nonatomic, strong) NSMutableData *activeDownload;
@property (nonatomic, strong) NSURLConnection *imageConnection;
- (void)startDownload;
- (void)cancelDownload;
@end

@protocol IconDownloaderDelegate 
- (void)appImageDidLoad:(NSIndexPath *)indexPath;
@end