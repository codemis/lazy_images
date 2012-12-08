typedef void (^ArrayBlock)(NSArray *);
typedef void (^ErrorBlock)(NSError *);

@interface ParseOperation : NSOperation
@property (nonatomic, copy) ErrorBlock errorHandler;
- (id)initWithData:(NSData *)data completionHandler:(ArrayBlock)handler;
@end
