//
//  FirstLoginViewController.h
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/18/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstLoginViewController : UIViewController <NSURLConnectionDataDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *profilePic;

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end
