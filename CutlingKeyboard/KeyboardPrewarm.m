//
//  KeyboardPrewarm.m
//  CutlingKeyboard
//
//  Starts building Cutling's keyboard as soon as UIKit is up in the keyboard's process, which iOS starts when the
//  globe key is held (KeyboardPrewarm.swift). Swift has no code that runs when a binary loads, hence this file.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

#import <Foundation/Foundation.h>

extern void CutlingKeyboardPrewarm(void);

__attribute__((constructor))
static void CutlingKeyboardPrewarmOnLaunch(void) {
    // UIApplicationDidFinishLaunchingNotification, by its value: UIKit posts it once the process's application object
    // is set up, before its run loop takes iOS's request for the keyboard.
    [[NSNotificationCenter defaultCenter] addObserverForName:@"UIApplicationDidFinishLaunchingNotification"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
        CutlingKeyboardPrewarm();
    }];
}
