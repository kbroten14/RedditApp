//
//  PostsTableViewController.m
//  RedditApp
//
//  Created by Kevin Broten on 5/16/14.
//  Copyright (c) 2014 Kevin Broten. All rights reserved.
//

#import "PostsTableViewController.h"
#import "RedditPost.h"
#import "NSString+CategoryThing.h"
//#import <SDWebIMage/....>  <- path of folder that has the .h file you want to import

@interface PostsTableViewController ()

@property (nonatomic, strong) NSArray *postsArray;

@end

@implementation PostsTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Reddit Posts";
    
    NSLog(@"it's about to begin");
    
    [self refresh];
}

-(void)refresh
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://reddit.com/.json"]];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        //technically nothing is needed here
//        NSLog(@"it's done!");
//        NSString *string = [NSString stringWithContentsOfURL:location encoding:NSUTF8StringEncoding error:nil];
        
        NSData *data = [NSData dataWithContentsOfURL:location];
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSArray *array = [dictionary valueForKeyPath:@"data.children"]; //dictionary[@"data"][@"children"];
        
        NSMutableArray *mutArray = [NSMutableArray array];
        
        for(NSDictionary *postDict in array)
        {
            RedditPost *newPost = [[RedditPost alloc] init];
            newPost.title = [postDict valueForKeyPath:@"data.title"];
            
            [mutArray addObject:newPost];
        }
        
        self.postsArray = [NSArray arrayWithArray:mutArray];
        
        dispatch_async(dispatch_get_main_queue(), ^{ //go to main thread and do the following block of code
            [self.tableView reloadData];
        });
        
        NSLog(@"done!");
    }];
    
    
    [task resume];
    
//    or
//    
//    [[session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
//        //technically nothing is needed here
//    }] resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.postsArray count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostIdentifier"];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PostIdentifier"];
    }
    
    RedditPost *post = self.postsArray[indexPath.row];
    
    cell.textLabel.text = post.title;
    
    return cell;
}


@end
