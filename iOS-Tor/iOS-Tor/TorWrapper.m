//
//  TorWrapper.m
//  iOS-Tor
//
//  Created by Mathieu Bolard on 05/05/2014.
//  Copyright (c) 2014 Mathieu Bolard. All rights reserved.
//

#import "TorWrapper.h"
#import "TorManager.h"
#include "or/or.h"
#include "or/main.h"

@implementation TorWrapper


- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(NSData *)readTorCookie {
    /* We have the CookieAuthentication ControlPort method set up, so Tor
     * will create a "control_auth_cookie" in the data dir. The contents of this
     * file is the data that AppDelegate will use to communicate back to Tor. */
    NSString *tmpDir = NSTemporaryDirectory();
    NSString *control_auth_cookie = [tmpDir stringByAppendingPathComponent:@"control_auth_cookie"];
    
    NSData *cookie = [[NSData alloc] initWithContentsOfFile:control_auth_cookie];
    return cookie;
}

-(void)main {
    NSString *tmpDir = NSTemporaryDirectory();
    
    //NSString *base_torrc = [[NSBundle mainBundle] pathForResource:@"torrc" ofType:nil];
    //NSString *base_torrc = [[[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"torrc"] relativePath];
    NSString *base_torrc = [[NSBundle mainBundle] pathForResource:@"torrc" ofType:nil];
    
    NSString *geoip = [[NSBundle mainBundle] pathForResource:@"geoip" ofType:nil];
    NSLog(@"%@ %@",[NSBundle allBundles], [NSBundle allFrameworks]);
    
    NSString *controlPortStr = [NSString stringWithFormat:@"%ld", (unsigned long)[TorManager defaultManager].torControlPort];
    NSString *socksPortStr = [NSString stringWithFormat:@"%ld", (unsigned long)[TorManager defaultManager].torSocksPort];
    
    //NSLog(@"%@ / %@", controlPortStr, socksPortStr);
    
    /**************/
    
    char *arg_0 = "tor";
    
    // These options here (and not in torrc) since we don't know the temp dir
    // and data dir for this app until runtime.
    char *arg_1 = "DataDirectory";
    char *arg_2 = (char *)[tmpDir cStringUsingEncoding:NSUTF8StringEncoding];
    char *arg_3 = "ControlPort";
    char *arg_4 = (char *)[controlPortStr cStringUsingEncoding:NSUTF8StringEncoding];
    char *arg_5 = "SocksPort";
    char *arg_6 = (char *)[socksPortStr cStringUsingEncoding:NSUTF8StringEncoding];
    char *arg_7 = "GeoIPFile";
    char *arg_8 = (char *)[geoip cStringUsingEncoding:NSUTF8StringEncoding];
    char *arg_9 = "-f";
    char *arg_10 = (char *)[base_torrc cStringUsingEncoding:NSUTF8StringEncoding];
    
    // Set loglevel based on compilation option (loglevel "notice" for debug,
    // loglevel "warn" for release). Debug also will receive "DisableDebuggerAttachment"
    // torrc option (which allows GDB/LLDB to attach to the process).
    char *arg_11 = "Log";
    
#ifndef DEBUG
    char *arg_12 = "warn stderr";
#endif
#ifdef DEBUG
    char *arg_12 = "notice stderr";
#endif
    char* argv[] = {arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6, arg_7, arg_8, arg_9, arg_10, arg_11, arg_12, NULL};
    tor_main(13, argv);
}

@end
