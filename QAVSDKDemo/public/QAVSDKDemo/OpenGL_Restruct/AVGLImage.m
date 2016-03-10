//
//  AVGLImage.m
//  OpenGLRestruct
//
//

#import "AVGLImage.h"

@implementation AVGLImage

@synthesize width = _imageWidth,height = _imageHeight, data = _imageData,angle = _angle,isFullScreenShow = _isFullScreenShow,viewStatus = _viewStatus,dataFormat = _dataFormat;
-(void)dealloc{
    [super dealloc];
}
@end
