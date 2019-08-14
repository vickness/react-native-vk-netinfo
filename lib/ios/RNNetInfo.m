
#import "RNNetInfo.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#include <arpa/inet.h>
#import <netdb.h>
#include <ifaddrs.h>
#import <sys/utsname.h>
#import <CFNetwork/CFNetwork.h>
#import <netinet/in.h>
#import <net/ethernet.h>
#import <net/if_dl.h>

@implementation RNNetInfo

RCT_EXPORT_MODULE()

/** 检测是否连接VPN*/
RCT_EXPORT_METHOD(isVPNConnected:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *dict = CFBridgingRelease(CFNetworkCopySystemProxySettings());
        NSArray *keys = [dict[@"__SCOPED__"]allKeys];
        BOOL isVpn = NO;
        for (NSString *key in keys) {
            if ([key rangeOfString:@"tap"].location != NSNotFound ||
                [key rangeOfString:@"tun"].location != NSNotFound ||
                [key rangeOfString:@"ppp"].location != NSNotFound){
                isVpn = YES;
            }
        }
        resolve([NSNumber numberWithBool:isVpn]);
    });
}

/**获取运营商*/
RCT_EXPORT_METHOD(getCarrierName:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //获取运营商名称
        CTCarrier *carrier = [[CTTelephonyNetworkInfo new] subscriberCellularProvider];
        NSString *carrierName = [carrier carrierName];
        resolve(carrierName);
    });
}

/** 域名解析为ip地址*/
RCT_EXPORT_METHOD(getIpsFromHost:(NSString *)host
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSError * error;
        NSArray * addresses = [self performDnsLookup:host error:&error];
        
        if (!addresses) {
            
            NSString * errorCode = [NSString stringWithFormat:@"%ld", (long) error.code];
            reject(errorCode, error.userInfo[NSDebugDescriptionErrorKey], error);
        } else {
            
            resolve(addresses);
        }
    });
}

- (NSArray *) performDnsLookup: (NSString *) hostname
                         error: (NSError ** _Nonnull) error
{
    if (hostname == nil) {
        *error = [NSError errorWithDomain:NSGenericException code: kCFHostErrorUnknown userInfo: @{ NSDebugDescriptionErrorKey:@"Hostname cannot be null." }];
        return nil;
    }
    
    CFHostRef hostRef = CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef) hostname);
    if (hostRef == nil) {
        *error = [NSError errorWithDomain:NSGenericException code: kCFHostErrorUnknown userInfo: @{NSDebugDescriptionErrorKey:@"Failed to create host."}];
        return nil;
    }
    
    BOOL didStart = CFHostStartInfoResolution(hostRef, kCFHostAddresses, nil);
    if (!didStart) {
        *error = [NSError errorWithDomain:NSGenericException code: kCFHostErrorUnknown userInfo: @{NSDebugDescriptionErrorKey:@"Failed to start."}];
        CFRelease(hostRef);
        return nil;
    }
    
    CFArrayRef addressesRef = CFHostGetAddressing(hostRef, nil);
    if (addressesRef == nil) {
        *error = [NSError errorWithDomain:NSGenericException code: kCFHostErrorUnknown userInfo: @{NSDebugDescriptionErrorKey:@"Failed to get addresses."}];
        CFRelease(hostRef);
        return nil;
    }
    
    // Convert these addresses into strings.
    NSMutableArray * addresses = [NSMutableArray array];
    char ipAddress[INET6_ADDRSTRLEN];
    CFIndex numAddresses = CFArrayGetCount(addressesRef);
    for (CFIndex currentIndex = 0; currentIndex < numAddresses; currentIndex++) {
        struct sockaddr *address = (struct sockaddr *)CFDataGetBytePtr(CFArrayGetValueAtIndex(addressesRef, currentIndex));
        getnameinfo(address, address->sa_len, ipAddress, INET6_ADDRSTRLEN, nil, 0, NI_NUMERICHOST);
        [addresses addObject:[NSString stringWithCString:ipAddress encoding:NSASCIIStringEncoding]];
    }
    CFRelease(hostRef);
    return addresses;
}

@end
  
