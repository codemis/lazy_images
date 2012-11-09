typedef void (^ArrayBlock)(NSArray *);
typedef void (^ErrorBlock)(NSError *);
@class AppRecord;
@interface ParseOperation : NSOperation <NSXMLParserDelegate>
@property (nonatomic, copy) ErrorBlock errorHandler;
- (id)initWithData:(NSData *)data completionHandler:(ArrayBlock)handler;
@end
