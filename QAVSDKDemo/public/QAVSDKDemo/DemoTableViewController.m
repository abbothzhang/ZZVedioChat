 //
//  DemoTableViewController.m
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-11-24.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import "DemoTableViewController.h"
#import "UserSelectViewController.h"
#import "UserAddViewController.h"
#import "MSDynamicsDrawerViewController.h"
#import "NPairVideoViewController.h"
#import "PairRoomConfigViewController.h"

@interface DemoTableViewController ()

@end

@implementation DemoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"Demo列表";
    
    _demos=@[
//             @{@"name":@"房间创建",@"ViewController":@"RoomDemoViewController",@"storybord":@"RoomDemo"},
//             @{@"name":@"成员管理",@"ViewController":@"MemberDemoViewController",@"storybord":@"MemberDemo"},
//             @{@"name":@"画面请求",@"ViewController":@"RequestViewDemoViewController",@"storybord":@"RequestViewDemo"},
//#ifdef _BUILD_FOR_MULT
           //  @{@"name":@"多人通话",@"ViewController":@"MultiVideoViewController",@"storybord":@"Main"},
//#else
             //@{@"name":@"双人通话",@"ViewController":@"PairVideoViewController",@"storybord":@"Main"},
             @{@"name":@"双人通话",@"ViewController":@"NPairVideoViewController"},
//#endif
             ];
    [_demos retain];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
-(void)dealloc{
    [_demos release];
    [super dealloc];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section==0){
        return _demos.count;
    }
    return 0;
}
-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section==0){
        return @"Demo";
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0 ){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
        if (!cell) {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
        }
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text=[_demos objectAtIndex:indexPath.row][@"id"];
     
        return cell;
    }
        return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        
        NSDictionary* selectedDemo=[_demos objectAtIndex:indexPath.row];
        
        if ([[selectedDemo objectForKey:@"ViewController"] isEqualToString:@"NPairVideoViewController"]) {
            MSDynamicsDrawerViewController* drawerController=[[MSDynamicsDrawerViewController alloc] init];
            [drawerController setRevealWidth:120 forDirection:MSDynamicsDrawerDirectionRight];
            
            PairRoomConfigViewController* roomConfigController=[[PairRoomConfigViewController alloc] initWithStyle:UITableViewStyleGrouped];
            
            NPairVideoViewController* multiVideoViewController=[[NPairVideoViewController alloc] init];
            
            //设置成员列表控制器、设置操作列表控制器、设置显示控制器
            [drawerController setDrawerViewController:roomConfigController forDirection:MSDynamicsDrawerDirectionRight];
            //[drawerController setDrawerViewController:roomMenberController forDirection:MSDynamicsDrawerDirectionLeft];
            [drawerController setPaneViewController:multiVideoViewController];
            
            [self presentViewController:drawerController animated:YES completion:^{
                
            }];
            
            return;
        }
        
        UIViewController* entryViewController=nil;
        if ([selectedDemo objectForKey:@"storybord"]) {
            UIStoryboard* storyboard=[UIStoryboard storyboardWithName:selectedDemo[@"storybord"] bundle:nil];
            entryViewController=[storyboard instantiateViewControllerWithIdentifier:selectedDemo[@"ViewController"]];
        }else{
           entryViewController=[[NSClassFromString(selectedDemo[@"ViewController"]) alloc] init];
        }

        
        if ([entryViewController isKindOfClass:UIViewController.class]) {
            [self presentViewController:entryViewController animated:YES completion:^{
            }];
        }
    }
}


@end
