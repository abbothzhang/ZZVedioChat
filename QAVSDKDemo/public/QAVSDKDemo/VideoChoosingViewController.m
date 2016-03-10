//
//  VideoChoosingViewController.m
//  QAVSDKDemo
//
//


#import "VideoChoosingViewController.h"

@interface VideoChoosingViewController ()
{
    NSArray* _leftViewArray;
    NSArray* _rightViewArray;
    NSMutableArray *_videoArray;
    NSMutableArray *_videoFrameArray;
    int _currentLeftIndex;
    UITableView *leftTableView;
    UITableView *rightTableView;
    int _videoChoice;
    int _frameChoice;
    UITextField *_videoXTextField;
    UITextField *_videoYTextField;
    UIView *addView;
}
@end

@implementation VideoChoosingViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"输入视频流";

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(exit)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    [self loadTheConfig];
    leftTableView.delegate = self;
    leftTableView.dataSource = self;
    rightTableView.delegate = self;
    rightTableView.dataSource = self;
    // Do any additional setup after loading the view from its nib.
}

- (void)loadTheConfig
{
    self.view.backgroundColor = [UIColor whiteColor];
    _currentLeftIndex = 0;
    _videoChoice = 0;
    _frameChoice = 0;
    [self getVideoListFromDocument];
    
    _leftViewArray = [[NSArray arrayWithObjects:@"选择视频",@"选择视频宽和高", nil]retain];
    _videoArray = [NSMutableArray arrayWithArray:[self getVideoListFromDocument]];
//    _videoArray = [[NSMutableArray arrayWithObjects:@"123.yuv",nil]retain];
    _videoFrameArray = [NSMutableArray arrayWithObjects:@"176*144",@"320*240",@"480*360",@"640*480", nil];
    
    _rightViewArray = [[NSArray arrayWithObjects:_videoArray,_videoFrameArray, nil]retain];
    leftTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 68, CGRectGetWidth([[UIScreen mainScreen] bounds])*0.4,88)];
    leftTableView.scrollEnabled = NO;
    leftTableView.contentOffset = CGPointMake(0, 0);
    self.automaticallyAdjustsScrollViewInsets = false;
    
    rightTableView = [[UITableView alloc]initWithFrame:CGRectMake(CGRectGetWidth([[UIScreen mainScreen] bounds])*0.4, leftTableView.frame.origin.y, CGRectGetWidth([[UIScreen mainScreen] bounds])*0.6,CGRectGetHeight([[UIScreen mainScreen] bounds])-68-100)];
    
    [self.view addSubview:leftTableView];
    [self.view addSubview:rightTableView];
    
    UIButton* playVideoButton= [UIButton buttonWithType:UIButtonTypeRoundedRect];
    playVideoButton.frame = CGRectMake(0, 0, 100, 50);
    playVideoButton.layer.cornerRadius=25;
    playVideoButton.clipsToBounds=YES;
    
    [playVideoButton setTitle:@"播放本地视频" forState:UIControlStateNormal];
    playVideoButton.center=CGPointMake(CGRectGetWidth(self.view.bounds)/2, CGRectGetHeight(self.view.bounds)-25-20);
    [playVideoButton addTarget:self  action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playVideoButton];
    
}

-(void)exit{
    _rightViewArray = nil;
    [_rightViewArray release];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)playVideo
{
    _rightViewArray = nil;
    [_rightViewArray release];
    NSLog(@"video = %d,frame = %d",_videoChoice,_frameChoice);
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (_chooseDelegate != nil && _videoArray.count > 0) {
        [_chooseDelegate playVideoWithVideo:[_videoArray objectAtIndex:_videoChoice] AndFrame:[_videoFrameArray objectAtIndex:_frameChoice]];
    }
}

- (NSArray*)getFileNameListOfType:(NSString*)type fromDirPath:(NSString*)dirPath
{
    NSArray *fileList = [[[NSFileManager defaultManager]contentsOfDirectoryAtPath:dirPath error:nil]pathsMatchingExtensions:[NSArray arrayWithObject:type]];
    
    return fileList;
}

- (NSArray *)getVideoListFromDocument
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray * tempFileList = [[[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtPath:docDir error:nil]] autorelease];
    NSMutableArray *videoList = [[[NSMutableArray alloc]initWithObjects: nil]autorelease];
    for (int i = 0; i < [tempFileList count]; i++) {
        if ([[[tempFileList objectAtIndex:i]pathExtension]isEqualToString:@"yuv"]) {
            [videoList addObject:[tempFileList objectAtIndex:i]];
        }
    }
    NSLog(@"array = %@",videoList);
    return videoList;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView == leftTableView) {
        return 2;
    }
    else
    {
        if (_currentLeftIndex == 1) {
            return [[_rightViewArray objectAtIndex:_currentLeftIndex]count] + 1;
        }
        else
        {
            return [[_rightViewArray objectAtIndex:_currentLeftIndex]count];
        }
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (!cell) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
    }
    
    if (tableView == leftTableView) {
        cell.textLabel.text = [_leftViewArray objectAtIndex:indexPath.row];
        
        if(indexPath.row == 0)
        {
            cell.selected = YES;
        }
    }
    else
    {
        //添加按钮
        if (_currentLeftIndex == 1 && indexPath.row == [[_rightViewArray objectAtIndex:_currentLeftIndex ] count] ) {
            cell.textLabel.text = @"添加";
        }
        else
        {
            cell.textLabel.text =[[_rightViewArray objectAtIndex:_currentLeftIndex ] objectAtIndex:indexPath.row];
        }
        if (_currentLeftIndex == 0) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            if (indexPath.row == _videoChoice) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        else if (_currentLeftIndex == 1)
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            if (indexPath.row == _frameChoice) {
                cell.accessoryType =UITableViewCellAccessoryCheckmark;
            }
        }
    }
    cell.textLabel.font = [UIFont fontWithName:cell.textLabel.font.fontName size:14];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_currentLeftIndex == 1&&tableView == rightTableView&&indexPath.row < [_videoFrameArray count]) {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_currentLeftIndex == 1) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            [_videoFrameArray removeObjectAtIndex:indexPath.row];
            [rightTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == leftTableView) {
        if (indexPath.row == 0) {
            _currentLeftIndex = 0;
        }
        else
        {
            _currentLeftIndex = 1;
        }
    }
    else
    {
        if (_currentLeftIndex == 0) {
            _videoChoice = indexPath.row;
        }
        else if (_currentLeftIndex == 1)
        {
            //添加按钮
            if (indexPath.row == [[_rightViewArray objectAtIndex:_currentLeftIndex ] count] ) {
                //添加
                [self createAddView];
            }
            else
            {
                _frameChoice = indexPath.row;
            }
        }
    }
    [rightTableView reloadData];
    
}

- (void)createAddView
{
    addView = [[[UIView alloc]initWithFrame:CGRectMake(70, 150, CGRectGetWidth([[UIScreen mainScreen] bounds])- 140 , 180)]autorelease];
//    addView.backgroundColor = [UIColor colorWithRed:(CGFloat)182.0/255.0 green:(CGFloat)200.0/255.0 blue:(CGFloat)254.0/255.0 alpha:1];
    addView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
     
    _videoXTextField = [[[UITextField alloc]initWithFrame:CGRectMake(40, 50, 100, 20)]retain];
    _videoYTextField = [[[UITextField alloc]initWithFrame:CGRectMake(40, 90, 100, 20)]retain];
    _videoXTextField.backgroundColor = [UIColor whiteColor];
    _videoYTextField.backgroundColor = [UIColor whiteColor];
    _videoXTextField.delegate = self;
    _videoYTextField.delegate = self;
    
    UILabel *titleLabel = [[[UILabel alloc]initWithFrame:CGRectMake(20, 10, 120, 40)]autorelease];
    titleLabel.text = @"请添加分辨率";
    UILabel *videoXLabel = [[[UILabel alloc]initWithFrame:CGRectMake(10, 50, 30, 20)]autorelease];
    videoXLabel.text = @"宽";
    UILabel *videoYLabel = [[[UILabel alloc]initWithFrame:CGRectMake(10, 90 ,30, 20)]autorelease];
    videoYLabel.text = @"高";
    [addView addSubview:titleLabel];
    [addView addSubview:_videoXTextField];
    [addView addSubview:_videoYTextField];
    [addView addSubview:videoXLabel];
    [addView addSubview:videoYLabel];
    
    UIButton *commitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    commitButton.frame = CGRectMake(0, 50, 50, 30);
    commitButton.layer.cornerRadius=25;
    commitButton.clipsToBounds=YES;
    
    [commitButton setTitle:@"添加" forState:UIControlStateNormal];
    commitButton.center=CGPointMake(CGRectGetWidth(addView.bounds)*2/3, CGRectGetHeight(addView.bounds)-15-20);
    [commitButton addTarget:self  action:@selector(commitTheFrame) forControlEvents:UIControlEventTouchUpInside];
    [addView addSubview:commitButton];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelButton.frame = CGRectMake(0, 50, 50, 30);
    cancelButton.layer.cornerRadius=25;
    cancelButton.clipsToBounds=YES;
    
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    cancelButton.center=CGPointMake(CGRectGetWidth(addView.bounds)/3, CGRectGetHeight(addView.bounds)-15-20);
    [cancelButton addTarget:self  action:@selector(cancelTheFrame) forControlEvents:UIControlEventTouchUpInside];
    [addView addSubview:cancelButton];
    
    [self.view addSubview:addView];
    
}

- (void)cancelTheFrame
{
    [_videoXTextField resignFirstResponder];
    [_videoYTextField resignFirstResponder];

    [addView removeFromSuperview];
}

- (void)commitTheFrame
{
    [_videoXTextField resignFirstResponder];
    [_videoYTextField resignFirstResponder];
    
    NSString *newFrame = [NSString stringWithFormat:@"%@*%@",_videoXTextField.text,_videoYTextField.text];
    [_videoFrameArray addObject:newFrame];
    
    [addView removeFromSuperview];
    [rightTableView reloadData];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
        [_videoXTextField resignFirstResponder];
        [_videoYTextField resignFirstResponder];
}

- (void)dealloc {
    [_leftViewArray release];
    [_videoArray release];
    [_videoFrameArray release];
    [_rightViewArray release];
    [leftTableView release];
    [rightTableView release];
    [_videoYTextField release];
    [_videoXTextField release];
    _videoXTextField = nil;
    _videoYTextField = nil;
    self.chooseDelegate = nil;
    [super dealloc];
}
@end

