//
//  VideoChoosingViewController.m
//  QAVSDKDemo
//
//


#import "ChangeAuthorityController.h"
#import "UserConfig.h"
#include <string>
#import "AVUtil.h"
@interface ChangeAuthorityController ()
{
    NSArray* _rightViewArray;
    NSMutableArray *_authArray;
    int _currentRightIndex;
    UITableView *rightTableView;
    UIView *addView;
    
    BOOL _isAudioSend;
    BOOL _isAudioRev;
    BOOL _isVideoSend;
    BOOL _isVideoRev;
}
@end

@implementation ChangeAuthorityController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改权限";

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(exit)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    [self loadTheConfig];
    rightTableView.delegate = self;
    rightTableView.dataSource = self;
    // Do any additional setup after loading the view from its nib.
}

- (void)loadTheConfig
{
    self.view.backgroundColor = [UIColor whiteColor];
    _currentRightIndex = -1;
    _rightViewArray = [[NSArray arrayWithObjects:
                        @"权限全关",
                        @"音频上行权限开，其它关",
                        @"音频下行权限开，其它关",
                        @"视频上行权限开，其它关",
                        @"视频下行权限开，其它关",
                        @"音频上行、视频上行权限开，其它关",
                        @"音频上行、视频下行权限开，其它关",
                        @"音频上行、音频下行权限开，其它关",
                        @"音频下行，视频上行权限开，其它关",
                        @"音频下行，视频下行权限开，其它关",
                        @"视频上行，视频下行权限开，其它关",
                        @"音频上行、视频上行、音频下行权限开，其它关",
                        @"音频上行、视频上行、视频下行权限开，其它关",
                        @"音频下行、视频下行、视频上行权限开，其它关",
                        @"音频上行、音频下行、视频下行权限开，其它关",
                        @"权限全开",
                        nil]retain];
    
    self.automaticallyAdjustsScrollViewInsets = false;
    rightTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 68, CGRectGetWidth([[UIScreen mainScreen] bounds]),CGRectGetHeight([[UIScreen mainScreen] bounds])-68-100)];
    [self.view addSubview:rightTableView];
    
    UIButton* changeButton= [UIButton buttonWithType:UIButtonTypeRoundedRect];
    changeButton.frame = CGRectMake(0, 0, 100, 50);
    changeButton.layer.cornerRadius=25;
    changeButton.clipsToBounds=YES;
    
    [changeButton setTitle:@"应用修改权限" forState:UIControlStateNormal];
    changeButton.center=CGPointMake(CGRectGetWidth(self.view.bounds)/2, CGRectGetHeight(self.view.bounds)-25-20);
    [changeButton addTarget:self  action:@selector(change) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeButton];
    
}

-(void)exit{
    _rightViewArray = nil;
    [_rightViewArray release];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)change
{
    if (_currentRightIndex == -1){
        [AVUtil ShowMsg:@"没有选择权限"];
        return;
    }
    
    typedef struct  {
        char c;
        char lv;
        char hv;
    } privilege_map_entry;
    
    static const privilege_map_entry dataPrivilegeMap[16] = {
        {'0',0x0,0x0}, {'1',0x01,0x10},{'2',0x02,0x20},{'3',0x03,0x30},
        {'4',0x04,0x40},{'5',0x05,0x50},{'6',0x06,0x60},{'7',0x07,0x70},
        {'8',0x08,0x80},{'9',0x09,0x90},{'A',0x0A,0xA0},{'B',0x0B,0xB0},
        {'C',0x0C,0xC0},{'D',0x0D,0xD0},{'E',0x0E,0xE0},{'F',0x0F,0xF0},
    };
    
    static const char* private_map_300000[16] = {
		"13A9EBF132AAEE040BB8315C49828D6432E02BD9A1C1DF0EC5E3A3DE28B63B6D4DBF0549100C9853",
		"BE1BC40DBD4151D595C2FE1BB0BA72512603C69663CB03AE1E29E1F27DF53B5AAAFB017E339D391E",
		"663ABD4BF9EED329364314A3CC1F4AC5D91EFC131E27B26829698C0A374832E6B37AC10937CB60D7",
		"C7939445D5D31DC76456E7580F7227EBDD7D4C404CFC275A1293D8BC809AED7E8DD368B7064228E1",
		"660A639A43872834364920A4566307CBF246B518E690360F13FBD0D1B7B5F96A56E4FE480398BED8",
		"9F34A35EE1DB91B6B704F0BFC7BC67B6415AD170DC1572940E080E576F8BB86B7808FD9097E89A96",
		"E4D2D2761C34AB696110EC27B3259FE47E8FFF8805087AB962170859F14FF41B23EF50A472FA18E3",
		"D24606EB208701A67CFDE599A4895FF2556E4378334BCE5CBD071B3E39C42CCD1B0509987862DC76",
		"AEA837EA773BC13FC9784254E39F77B8775E1DA582F990D9D43B7ADF8F1B68A1E31DD63B383E2329",
		"756753C5E1BF13DED6EB0DECF4D59319BA2347CCF9919836B2C7E579E8D738B5F5509D827C22BD06",
		"8EA97A9C58DCDA846B6A624F74ADFC9D9A9AFD72DB444D8018B434A7B2EA3383C5374525EF56DD66",
		"39D38DA6EFB6B5064FE173124C428B39409265D12D7A6A9A56FA82011C8B49D7E920662B363EFE80",
		"D95BBAB236523CFCD81B3CA84FD3F0AB32C82EB5BCFB4DDE19E57D567AEFD73C5B5ED6EDDC1C9908",
		"142C165EC643B802372A2149CAFCB21D36B0E1054D037A7C58C89D4C1EDDA14F3801DC0794D0CD21",
		"F5DF4B10E6C95E58F1077446978CA0B40DC99742780F8ED58DE0D0D26E7E7C269D7CE33FDD7483D3",
		"B7CA8A44C01CB6BCE5B555E61B3EFB3616D3A65847C9C99AA1D5A2D5B471051A3587469995166575"
    };
    
     static const char* private_map_400000[16] = {
		"198E2C99791770AC00D8F05E90BCEEA14F38C813F79B193BEE13DD12CE4792DFC6D78D5517DDDFFD",
		"B031FE5A7D0962487F4A23635C478094795E18E78680A7C0CAF2194F8758D386AFB68A6EF7767765",
		"CE67718E6BEEE8F5221377A0920CF89EF575579846112A937FB8876E7A1F9D469D90BF64E16A4852",
		"202F99842E7BEDD5FF8680B92FDED69115DCA677B60014652F381C7902B33DB581ACE4FC3DFF25A2",
		"14D2EBFB6F6B1DD943FE1842CE007251A3CAAAA0F0DA1C07B4A1718FB13F365B8803F43C2561DFA1",
		"55196F54B6886E956B538EA05D970C9A67E97C49606450FF5377BAC9CFD085F97DC4DEE94E444E22",
		"D14B95BB62C40E5F6116B179C8E7B97E0E38F2BAE4971E928F122C880EB1A2A15669C26013B88614",
		"B6EE1C98CDA2A90760EB12B385E10C829F791F7107D4A6480C207C5DFC096586EE5F80E5CBC3BDC5",
		"574BF0CC5E629D001F3C38E6CFBD706A5D16F0029E5D8A51469F21DD5A98524186FD947D33091628",
		"8E81C21C339814E2B8F4F9CD1C2D99E2D6A66963FD9768C8E559B74F6F2DB502E81921BC56E86926",
		"F49AC2A9D4C4F0FBE57DB500ACC1CBAB0C65F7FA0B838975338AE0F8F0E46C3269AD7AB4C6D31EFD",
		"1507463C9A55402EA8CA579A03A9F9E3DD88658CE2E6130B1B6475014F048ABE374763E3D5F40F63",
		"E9E154E4CC16717BC431ADD6914EFD0DAA666C75EF4E13D4295451AA51B1522038467DCA96D1BCCB",
		"E6849F78E3932513F57FB07981E1DDE9963A61446967529B7D7B827CD9026D9AACF9DB0D75317988",
		"EA7C2EB166FF5CFD8496E9270F67199CF017BE0ED108C363D0DAC50C7A2B173CF1E71580E82D0470",
		"EF33D622A907A959ED275DA15CBE480DE70E822600ABF39B16CC48AA877A3A19CBB5C14103D78248"
    };
    
    std::string strProtoAuthBuffer;
    if ( std::string("1104620500") == [UserConfig shareConfig].sdkAppId.UTF8String ) {
        strProtoAuthBuffer = private_map_300000[_currentRightIndex];
    }
    else {
        strProtoAuthBuffer = private_map_400000[_currentRightIndex];
    }
    
    std::string strPrivilegeMap;
    
    for(int n=0; n < strProtoAuthBuffer.size(); n+=2) {
        char v = 0x00;
        
        bool bValid = false;
        for(int i=0; i<16; i++) {
            if(strProtoAuthBuffer[n] == dataPrivilegeMap[i].c)
            {
                v |= dataPrivilegeMap[i].hv;
                bValid = true;
                break;
            }
        }
        if(!bValid) {
            return;
        }
        bValid = false;
        for(int i=0; i<16; i++) {
            if(strProtoAuthBuffer[n+1] == dataPrivilegeMap[i].c)
            {
                v |= dataPrivilegeMap[i].lv;
                bValid = true;
                break;
            }
        }
        if(!bValid) {
            return;
        }
        strPrivilegeMap.append(1, v);
    }
    
    NSData* data = [[NSData alloc] initWithBytes:strPrivilegeMap.data() length:strPrivilegeMap.size()];

    _rightViewArray = nil;
    [_rightViewArray release];

    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (_changeDelegate != nil) {
        [_changeDelegate changeAuthority:data];
    }

}

- (NSArray*)getFileNameListOfType:(NSString*)type fromDirPath:(NSString*)dirPath
{
    NSArray *fileList = [[[NSFileManager defaultManager]contentsOfDirectoryAtPath:dirPath error:nil]pathsMatchingExtensions:[NSArray arrayWithObject:type]];
    
    return fileList;
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
    return [_rightViewArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (!cell) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
    }
    
    cell.textLabel.text = [_rightViewArray objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.font = [UIFont fontWithName:cell.textLabel.font.fontName size:14];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
    for(int i=0; i<[_rightViewArray count]; i++) {
        if(i != indexPath.row) {
            NSIndexPath * cellIndex = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
            UITableViewCell * cellOther = [tableView cellForRowAtIndexPath:cellIndex];
            cellOther.accessoryType=UITableViewCellAccessoryNone;
        }
    }
        
    BOOL selected=NO;
    if(cell.accessoryType==UITableViewCellAccessoryCheckmark){
        selected=NO;
        cell.accessoryType=UITableViewCellAccessoryNone;
    }else{
        selected=YES;
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }

    if(selected)
        _currentRightIndex = indexPath.row;
    else
        _currentRightIndex = -1;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

}

- (void)dealloc {
    [_rightViewArray release];
    [rightTableView release];
    self.changeDelegate = nil;
    [super dealloc];
}
@end

