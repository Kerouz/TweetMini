//
//  TParentViewController.h
//  TweetMini
//
//  Created by Ayush on 9/21/12.
//
//

#import <UIKit/UIKit.h>
#import "Twitter/Twitter.h"

@interface TParentViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *TTimeline;

-(UITableView *) getTableViewObject;
-(NSString *) getCellIdentifier;
-(void) getTimelineWithParam: (NSDictionary *) param usingRequest: (TWRequest *) request;
@end
