//
//  User+Create.m
//  TweetMini
//
//  Created by Ayush on 10/10/12.
//  Copyright (c) 2012 Ayush. All rights reserved.
//

#import "User+Create.h"

@implementation User (Create)

+ (User *)createUserWithInfo:(id)info inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"userID == %@", [NSString stringWithFormat:@"%@", [info objectForKey:@"id"]]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"userID" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    __block NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    User *user = nil;
    
    if (!matches) {
        NSLog(@"User Create Error, matches array is NULL");
    } else if ([matches count] > 1) {
        NSLog(@"More than one matches when inserting User! %i %@", [matches count], matches);
        user = [matches lastObject];
    } else if ([matches count] == 1) {
        NSLog(@"User Already here");
        user = [matches lastObject];
        user.favoritesCount = [info objectForKey:@"favourites_count"];
        user.followersCount = [info objectForKey:@"followers_count"];
        user.friendsCount = [info objectForKey:@"friends_count"];
        user.statusCount = [info objectForKey:@"statuses_count"];
        user.url = [info objectForKey:@"url"];
        user.userDescription = [info objectForKey:@"description"];
        [context performBlock:^{
            [context save:&error];
        }];
    } else {
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
        user.userID = [NSString stringWithFormat:@"%@", [info objectForKey:@"id"]];
        user.favoritesCount = [info objectForKey:@"favourites_count"];
        user.followersCount = [info objectForKey:@"followers_count"];
        user.friendsCount = [info objectForKey:@"friends_count"];
        user.statusCount = [info objectForKey:@"statuses_count"];
        user.location = [info objectForKey:@"location"];
        user.url = [info objectForKey:@"url"];
        user.userDescription = [info objectForKey:@"description"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];
        user.creationDate = [dateFormatter dateFromString:[info objectForKey:@"created_at"]];
        user.miniUser = [MiniUser createMiniUserWithInfo:info inManagedObjectContext:context];
        user.bigImageURL = [NSString stringWithFormat:@"http://api.twitter.com/1/users/profile_image?screen_name=%@&size=bigger", user.miniUser.screenName];
        NSLog(@"New User created with ID: %@", user.userID);
    }
    return user;
}

- (void)addImageData:(NSData *)data inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"userID == %@", self.userID];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"userID" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    __block NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    User *user = nil;
    
    if (!matches) {
        NSLog(@"No matches array!");
    } else if ([matches count]>1) {
        NSLog(@"More than one photo with same ID: %@", self.userID);
    } else if ([matches count] == 1) {
        user = [matches lastObject];
        user.bigImage = data;
        [context performBlock:^{
            [context save:&error];
        }];
    } else {
        NSLog(@"What is this? Please check!");
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"ID:%@ miniUser:{%@}", self.userID, self.miniUser];
}

@end
