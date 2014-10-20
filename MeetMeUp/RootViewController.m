//
//  ViewController.m
//  MeetMeUp
//
//  Created by Dave Krawczyk on 9/8/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "Event.h"
#import "EventDetailViewController.h"
#import "RootViewController.h"

@interface RootViewController () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *searchBar;
@property (nonatomic, strong) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation RootViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];

    [self performSearchWithKeyword:@"mobile"];

}

- (void)performSearchWithKeyword:(NSString *)keyword
{
    [Event eventsFromKeyword:keyword completionHandler:^(NSArray *events)
    {
        self.dataArray = events;
    }];
}

-(void)setDataArray:(NSArray *)dataArray
{
    _dataArray = dataArray;
    [self.tableView reloadData];
}


//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.meetup.com/2/open_events.json?zip=60604&text=%@&time=,1w&key=5c141e6f197b202950a3f4d15345f26",keyword]];
//    
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//                               
//                               NSArray *jsonArray = [[NSJSONSerialization JSONObjectWithData:data
//                                                                                     options:NSJSONReadingAllowFragments
//                                                                                       error:nil] objectForKey:@"results"];
//                               
//                               
//                               self.dataArray = [Event eventsFromArray:jsonArray];
//                               [self.tableView reloadData];
//                           }];
//}

#pragma mark - Tableview Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell"];
    
    Event *e = self.dataArray[indexPath.row];
    
    cell.textLabel.text = e.name;
    cell.detailTextLabel.text = e.address;
    if (e.photoURL)
    {
        NSURLRequest *imageReq = [NSURLRequest requestWithURL:e.photoURL];
        
        [NSURLConnection sendAsynchronousRequest:imageReq queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
           dispatch_async(dispatch_get_main_queue(), ^{
               if (!connectionError) {
                   [cell.imageView setImage:[UIImage imageWithData:data]];
                   [cell layoutSubviews];
               }
           });


        }];
        
        
    }else
    {
       [cell.imageView setImage:[UIImage imageNamed:@"logo"]];
    }
    
    return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    EventDetailViewController *detailVC = [segue destinationViewController];

    Event *e = self.dataArray[self.tableView.indexPathForSelectedRow.row];
    detailVC.event = e;
}

#pragma searchbar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self performSearchWithKeyword:searchBar.text];
    [searchBar resignFirstResponder];
}

@end
