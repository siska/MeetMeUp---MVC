//
//  Event.m
//  MeetMeUp
//
//  Created by Dave Krawczyk on 9/8/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "Event.h"

@implementation Event

#pragma mark - Event Instance Methods

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        
        self.name = dictionary[@"name"];
        

        self.eventID = dictionary[@"id"];
        self.RSVPCount = [NSString stringWithFormat:@"%@",dictionary[@"yes_rsvp_count"]];
        self.hostedBy = dictionary[@"group"][@"name"];
        self.eventDescription = dictionary[@"description"];
        self.address = dictionary[@"venue"][@"address"];
        self.eventURL = [NSURL URLWithString:dictionary[@"event_url"]];
        self.photoURL = [NSURL URLWithString:dictionary[@"photo_url"]];
    }
    return self;
}

- (void)initCommentFromEventID:(NSString *)eventID arrayProvidedBack:(void (^)(NSArray *))complete
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.meetup.com/2/event_comments?&sign=true&photo-host=public&event_id=%@&page=20&key=5c141e6f197b202950a3f4d15345f26",eventID]];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
    {

        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

        NSArray *jsonArray = [dict objectForKey:@"results"];
        NSArray *dataArray = [Comment objectsFromArray:jsonArray];
        complete(dataArray);
    }];
}


#pragma mark - Event Class Methods
//defines what comes back and what goes in - this void, NSArray stuff is unique - per Don
+ (void)eventsFromKeyword:(NSString *)keyword completionHandler:(void (^)(NSArray *))complete
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.meetup.com/2/open_events.json?zip=60604&text=%@&time=,1w&key=5c141e6f197b202950a3f4d15345f26",keyword]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
    {
        NSArray *jsonArray = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil] objectForKey:@"results"];

        NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:jsonArray.count];

        for (NSDictionary *d in jsonArray) //bug - had replaced jsonArray with newArray
        {
            Event *e = [[Event alloc]initWithDictionary:d];
            [newArray addObject:e];
            NSLog(@"Adding to newArray: %@", newArray);
        }
    complete(newArray);
    }];
}

@end
