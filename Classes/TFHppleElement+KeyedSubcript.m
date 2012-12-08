#import "TFHppleElement+KeyedSubcript.h"

@implementation TFHppleElement (KeyedSubcript)

-(id)objectForKeyedSubscript:(id)key {
    return self.attributes[key];
}
@end
