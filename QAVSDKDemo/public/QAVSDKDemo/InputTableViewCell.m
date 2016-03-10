//
//  InputTableViewCell.m
//  QAVSDKDemo_public
//
//  Created by 孟磊 on 16/3/10.
//  Copyright © 2016年 TOBINCHEN. All rights reserved.
//

#import "InputTableViewCell.h"

@implementation InputTableViewCell
@synthesize roomId,showText;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        roomId = [[[UITextField alloc] initWithFrame:CGRectMake(120, 2, 200, 40)] autorelease];
        [self addSubview:roomId];
        showText=[[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 40)] autorelease];
        [self addSubview:showText];
    }
    return self;
}

- (void)dealloc
{
    
    [super dealloc];
}


@end
