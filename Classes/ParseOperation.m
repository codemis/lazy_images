#import "ParseOperation.h"
#import "AppRecord.h"
#import "LazyTableAppDelegate.h"
static NSString *kIDStr     = @"id";
static NSString *kNameStr   = @"im:name";
static NSString *kImageStr  = @"im:image";
static NSString *kArtistStr = @"im:artist";
static NSString *kEntryStr  = @"entry";

@interface ParseOperation ()
@property (nonatomic, copy) ArrayBlock completionHandler;
@property (nonatomic, strong) NSData *dataToParse;
@property (nonatomic, strong) NSMutableArray *workingArray;
@property (nonatomic, strong) AppRecord *workingEntry;
@property (nonatomic, strong) NSMutableString *workingPropertyString;
@property (nonatomic, strong) NSArray *elementsToParse;
@property (nonatomic, assign) BOOL storingCharacterData;
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
        self.elementsToParse = @[kIDStr, kNameStr, kImageStr, kArtistStr];
    }
    return self;
}
- (void)main
{
	@autoreleasepool {
        self.workingArray = [NSMutableArray array];
        self.workingPropertyString = [NSMutableString string];
        
        // It's also possible to have NSXMLParser download the data, by passing it a URL, but this is not
        // desirable because it gives less control over the network, particularly in responding to
        // connection errors.
        //
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.dataToParse];
        [parser setDelegate:self];
        [parser parse];
            
        if (![self isCancelled])
        {
            self.completionHandler(self.workingArray);
        }    
        self.workingArray = nil;
        self.workingPropertyString = nil;
        self.dataToParse = nil;
	}
}
#pragma mark - RSS processing
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
                                        namespaceURI:(NSString *)namespaceURI
                                       qualifiedName:(NSString *)qName
                                          attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:kEntryStr])
	{
        self.workingEntry = [[AppRecord alloc] init];
    }
    self.storingCharacterData = [self.elementsToParse containsObject:elementName];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
                                      namespaceURI:(NSString *)namespaceURI
                                     qualifiedName:(NSString *)qName
{
    if (self.workingEntry)
	{
        if (self.storingCharacterData)
        {
            NSString *trimmedString = [self.workingPropertyString stringByTrimmingCharactersInSet:
                                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [self.workingPropertyString setString:@""];
            if ([elementName isEqualToString:kIDStr])
            {
                self.workingEntry.appURLString = trimmedString;
            }
            else if ([elementName isEqualToString:kNameStr])
            {        
                self.workingEntry.appName = trimmedString;
            }
            else if ([elementName isEqualToString:kImageStr])
            {
                self.workingEntry.imageURLString = trimmedString;
            }
            else if ([elementName isEqualToString:kArtistStr])
            {
                self.workingEntry.artist = trimmedString;
            }
        }
        else if ([elementName isEqualToString:kEntryStr])
        {
            [self.workingArray addObject:self.workingEntry];  
            self.workingEntry = nil;
        }
    }
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (self.storingCharacterData)
    {
        [self.workingPropertyString appendString:string];
    }
}
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    self.errorHandler(parseError);
}
@end
