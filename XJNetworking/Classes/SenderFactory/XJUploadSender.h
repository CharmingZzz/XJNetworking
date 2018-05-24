//
//  XJUploadSender.h
//  XJNetworking_Example
//
//  Created by xujie on 2018/5/22.
//  Copyright © 2018年 m17600026862@163.com. All rights reserved.
//

#import "XJSenderBridge.h"

/**need to upload object(NSString Path , NSData or NSInputStream) This parameter must not be nil*/
UIKIT_EXTERN NSString * const XJUploadSenderSourceKey;
/** when source is InputStream This parameter must not be nil*/
UIKIT_EXTERN NSString * const XJUploadSenderMineTypeKey;
UIKIT_EXTERN NSString * const XJUploadSenderNameKey;
UIKIT_EXTERN NSString * const XJUploadSenderFileNameKey;
/** when source is InputStream This parameter must not be nil*/
UIKIT_EXTERN NSString * const XJUploadSenderInputLength;

@interface XJUploadSender : XJSenderBridge

@end
