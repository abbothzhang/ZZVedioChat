//
//  RoomMenberViewController.m
//  QAVSDKDemo_P
//
//  Created by TOBINCHEN on 14-11-19.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import "RoomMemberViewController.h"
#import "AVUtil.h"
@interface MemberTableViewCell : UITableViewCell{
    UIImageView* _speakImageView;
    UIImageView* _cameraVideoImageView;
    UIImageView* _screenVideoImageView;
    BOOL _isSpeak;
    BOOL _hasCameraVideo;
    BOOL _hasScreenVideo;
}
@property (assign,nonatomic) BOOL isSpeak;
@property (assign,nonatomic) BOOL hasCameraVideo;
@property (assign,nonatomic) BOOL hasScreenVideo;
@end

@implementation MemberTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _speakImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"speak.png"]];
        _speakImageView.frame=CGRectMake(0, 0, 21,21);
        _speakImageView.hidden=YES;
        [self.contentView addSubview:_speakImageView];
        
        _cameraVideoImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera.png"]];
        _cameraVideoImageView.frame=CGRectMake(0, 0, 21, 21);
        _cameraVideoImageView.hidden=YES;
        [self.contentView addSubview:_cameraVideoImageView];
	
        _screenVideoImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screen.png"]];
        _screenVideoImageView.frame=CGRectMake(0, 0, 21, 21);
        _screenVideoImageView.hidden=YES;
        [self.contentView addSubview:_screenVideoImageView];
        
        self.textLabel.backgroundColor=[UIColor redColor];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    _speakImageView.center=CGPointMake(self.contentView.bounds.size.width-80,self.contentView.bounds.size.height/2);
    _cameraVideoImageView.center=CGPointMake(self.contentView.bounds.size.width-110,self.contentView.bounds.size.height/2);
    _screenVideoImageView.center=CGPointMake(self.contentView.bounds.size.width-140,self.contentView.bounds.size.height/2);
    
    //self.imageView.frame=CGRectMake(10, 6, 38, 38);
    self.textLabel.frame=CGRectMake(10, 0, self.contentView.bounds.size.width-170, self.contentView.bounds.size.height);
    
}
-(void)setIsSpeak:(BOOL)isSpeak
{
    _isSpeak=isSpeak;
    if (_isSpeak) {
        _speakImageView.hidden=NO;
    }else{
        _speakImageView.hidden=YES;
    }
}

-(void)setHasCameraVideo:(BOOL)hasCameraVideo
{
    _hasCameraVideo=hasCameraVideo;
    if (_hasCameraVideo) {
        _cameraVideoImageView.hidden=NO;
    }else{
        _cameraVideoImageView.hidden=YES;
    }
}

-(void)setHasScreenVideo:(BOOL)hasScreenVideo
{
    _hasScreenVideo=hasScreenVideo;
    if (_hasScreenVideo) {
        _screenVideoImageView.hidden=NO;
    }else{
        _screenVideoImageView.hidden=YES;
    }
}

-(BOOL)isAccessibilityElement
{
    return YES;
}
-(NSString*)accessibilityLabel
{
    return self.textLabel.text;
}
@end


@interface RoomMemberViewController ()

@end

@implementation RoomMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.bounces=YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endpointStateUpdate:) name:EndpointStateUpdate object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)dealloc
{
    [_model removeObserver:self forKeyPath:@"endpoints"];
    [_model release];
    [super dealloc];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setModel:(MultiRoomMemberModel*)aModel
{
    if (_model!=aModel) {
        [_model release];
        _model=[aModel retain];
        
        [_model addObserver:self forKeyPath:@"endpoints" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    
    [self.tableView reloadData];
    
}
- (void)endpointStateUpdate:(NSNotification*)notification
{
    [self.tableView reloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"endpoints"]) {
        [self.tableView reloadData];
    }else{
        [super observeValueForKeyPath:keyPath
                         ofObject:object
                           change:change
                          context:context];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"通话成员";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _model.endpoints.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    
    if (!cell) {
        cell=[[MemberTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
    }
    MemberData* endpoint=[_model.endpoints objectAtIndex:indexPath.row];
    if ([endpoint.identifier isEqualToString:[AVUtil sharedContext].Config.identifier]) {
        cell.textLabel.text=@"自己";
    }else{
        cell.textLabel.text=endpoint.identifier;
    }
    cell.hasCameraVideo=endpoint.isCameraVideo;
	cell.hasScreenVideo=endpoint.isScreenVideo;
    cell.isSpeak=endpoint.isAudio;
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
