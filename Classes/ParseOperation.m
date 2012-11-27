#import "ParseOperation.h"
#import "AppRecord.h"
#import "TFHpple.h"
#import "TFHppleElement+KeyedSubcript.h"

@interface ParseOperation ()
@property (nonatomic, copy) ArrayBlock completionHandler;
@property (nonatomic, strong) NSData *dataToParse;
@end

@implementation ParseOperation

- (id)      initWithData:(NSData *)data
       completionHandler:(ArrayBlock)handler
{
    self = [super init];
    if (self != nil)
    {
        self.dataToParse = data;
        self.completionHandler = handler;
    }
    return self;
}
- (void)main
{
    NSMutableArray *workingArray = [NSMutableArray array];
    TFHpple *appParser = [TFHpple hppleWithXMLData:self.dataToParse];
    NSString *appXpathQueryString = @"//xmlns:entry";
    NSArray *appsArray = [appParser searchWithXPathQuery:appXpathQueryString];
    for (TFHppleElement *element in appsArray) {
        AppRecord *app = [[AppRecord alloc] init];
        app.appName = [[element firstChildWithTagName:@"name"] text];
        app.appIcon = [UIImage imageWithContentsOfFile:[[element firstChildWithTagName:@"image"] text]];
        app.artist = [[element firstChildWithTagName:@"artist"] text];
        [workingArray addObject:app];
    }
    self.completionHandler(workingArray);
    self.dataToParse = nil;
}
@end
