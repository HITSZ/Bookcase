//
//  MeTableViewController.m
//  Bookcase
//
//  Created by Ching-Hua Hung on 15/7/21.
//
//

#import "MeTableViewController.h"

@interface MeTableViewController ()

@end

@implementation MeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
