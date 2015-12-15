#import <Foundation/Foundation.h>

int main (int argc, const char* argv[]) {
    NSDictionary *eD = [[NSProcessInfo processInfo] environment];
    NSLog(@"%@",[[eD objectForKey:@"USER"] description]);
    return 0;
}