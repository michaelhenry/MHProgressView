//
//  ViewController.m
//  MHProgressView_Demo
//
//  Created by Michael henry Pantaleon on 8/1/13.
//  Copyright (c) 2013 Michael Henry Pantaleon. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "MHProgressView.h"
#import "UIImageView+AFNetworking.h"
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) MHProgressView * progressView;
@property(nonatomic,strong) NSArray * feeds;
@end

@implementation ViewController
@synthesize feeds;
- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!self.progressView) self.progressView = [[MHProgressView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.progressView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://apis.jollisoft.com/cacheAPI.php?q=BBCBreaking"]];
    AFJSONRequestOperation * _operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        self.feeds = [JSON objectForKey:@"results"];
        [self.tableView reloadData];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.progressView removeFromSuperview];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"FAILED %@",error);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.progressView removeFromSuperview];
        
    }];
    
    __weak AFHTTPRequestOperation *_operationInsideBlock = _operation;
    [_operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse*)_operationInsideBlock.response;
        NSString *contentLength = [[response allHeaderFields] objectForKey:@"Content-Length"];
        if (contentLength != nil){
            totalBytesExpectedToRead = [contentLength doubleValue];
        }
        
        CGFloat downloadProgress =(float) totalBytesRead/totalBytesExpectedToRead;
        [self.progressView setProgress:downloadProgress];
    }];
    [_operation start];
  
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate and Datasource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.feeds count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"feed_cell"];
    UIImageView * userImageView = (UIImageView*)[cell viewWithTag:1];
    UILabel * userNameLabel = (UILabel*) [cell viewWithTag:2];
    UILabel * timeLabel = (UILabel*)[cell viewWithTag:3];
    UILabel * textLabel = (UILabel*)[cell viewWithTag:4];
    
    NSDictionary * row = [self.feeds objectAtIndex:indexPath.row];
    [userImageView setImageWithURL:[NSURL URLWithString:[row objectForKey:@"profile_image_url"]]];
    [userNameLabel setText:[row objectForKey:@"from_user_name"]];
    [textLabel setText:[row objectForKey:@"text"]];
    [timeLabel setText:[self getRelativeTimeTwitter:[row objectForKey:@"created_at"]]];
    [textLabel sizeToFit];
    textLabel.frame = CGRectMake(textLabel.frame.origin.x,textLabel.frame.origin.y,226.0f, textLabel.frame.size.height);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary * row = [self.feeds objectAtIndex:[indexPath row]];
    
    return [self computeTextHeight:[row objectForKey:@"text"] withContentMargin:5.0f withContentWidth:226.0f withMinimumHeight:34.0f withFont:[UIFont systemFontOfSize:16.0f]] + 30.0f;
}


#pragma mark - Helper Functions
- (NSUInteger) computeTextHeight:(NSString*)text withContentMargin:(CGFloat)margin withContentWidth:(CGFloat) width withMinimumHeight:(CGFloat) minHeight withFont:(UIFont*)font {
    CGSize constraintText = CGSizeMake(width - (margin * 2), 20000.0f);
    CGSize sizeText = [text sizeWithFont:font constrainedToSize:constraintText lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat heighText = MAX(sizeText.height, minHeight);
    return heighText + (margin * 2)  ;
}

- (NSString*) getRelativeTimeWithDateTwitterFormat:(NSDate *)date {
    NSInteger idate = [date timeIntervalSinceNow]*-1;
    
    const int SECOND = 1;
    const int MINUTE = 60 * SECOND;
    const int HOUR = 60 * MINUTE;
    const int DAY = 24 * HOUR;
    
    if (idate <= 0)
    {
        return @"0s";
    }
    else if (idate == 1) {
        return @"1s";
    }
    else if (idate < 1 * MINUTE)
    {
        return [[NSString alloc]initWithFormat:@"%is",idate];
    }
    if (idate < 2 * MINUTE)
    {
        return @"1m";
    }
    if (idate < 45 * MINUTE)
    {
        return  [[NSString alloc]initWithFormat:@"%im",idate/60 ];
    }
    if (idate < (2 * HOUR) - 1)
    {
        return @"1h";
    }
    if (idate < 24 * HOUR)
    {
        return [[NSString alloc]initWithFormat:@"%ih",idate/3600 ];
    }
    if (idate < 48 * HOUR)
    {
        return @"1d";
    }
    if (idate < 30 * DAY)
    {
        return [[NSString alloc]initWithFormat:@"%id",idate/(3600*24) ];
    }
    else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM dd, yyyy"];
        return [formatter stringFromDate:date];
    }
    
    return @"##";
}

- (NSString*) getRelativeTimeTwitter:(NSString *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE',' dd MMM yyyy HH:mm:ss ZZ"];
    NSDate *odate = [formatter dateFromString:date];
    return [self getRelativeTimeWithDateTwitterFormat:odate];
}



@end
