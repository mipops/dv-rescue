/*  Copyright (c) MIPoPS. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-3-Clause license that can
 *  be found in the LICENSE.txt file in the root of the source tree.
 */

#include "Common/AvfCtlWrapper.h"
#import "Common/AvfCtl.h"

using namespace std;

@interface AVFCtlBufferReceiver : NSObject
@property (retain,nonatomic) NSMutableData *output_data;
@property (assign,nonatomic) FileWrapper *output_wrapper;

- (id) initWithFileWrapper:(FileWrapper*)wrapper;
- (void) captureOutput:(AVCaptureOutput*)captureOutput
  didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
         fromConnection:(AVCaptureConnection*)connection;
- (void) captureOutput:(AVCaptureOutput*)captureOutput
    didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer
         fromConnection:(AVCaptureConnection*)connection;
@end

@implementation AVFCtlBufferReceiver
- (id) initWithFileWrapper:(FileWrapper*)wrapper
{
    self = [super init];

    if (self) {
        _output_wrapper = wrapper;
        _output_data = [NSMutableData dataWithLength:1000];
    }
    
    return self;
}

- (void) captureOutput:(AVCaptureOutput *)captureOutput
  didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
         fromConnection:(AVCaptureConnection *)connection
{
    if (_output_wrapper != nil) {
        CMBlockBufferRef block_buffer = CMSampleBufferGetDataBuffer(sampleBuffer); // raw, DV data only
        size_t bb_len = CMBlockBufferGetDataLength(block_buffer);
        if (_output_data.length != bb_len) {
            _output_data.length = bb_len;
        }
        CMBlockBufferCopyDataBytes(block_buffer, 0, _output_data.length, _output_data.mutableBytes);
        
        _output_wrapper->Parse_Buffer((const uint8_t*)_output_data.bytes, (size_t)_output_data.length);
    }
}

- (void) captureOutput:(AVCaptureOutput *)captureOutput
    didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer
         fromConnection:(AVCaptureConnection *)connection
{
    NSLog(@"Frame dropped.");
}
@end

AVFCtlWrapper::AVFCtlWrapper(size_t DeviceIndex)
{
    Ctl = (void*)[[AVFCtl alloc] initWithDeviceIndex:DeviceIndex];
}

AVFCtlWrapper::~AVFCtlWrapper()
{
    [(id)Ctl release];
}

size_t AVFCtlWrapper::GetDeviceCount()
{
    return (size_t)[AVFCtl getDeviceCount];
}

string AVFCtlWrapper::GetDeviceName(size_t DeviceIndex)
{
    return string([[AVFCtl getDeviceName:DeviceIndex] UTF8String]);
}

void AVFCtlWrapper::CreateCaptureSession(FileWrapper* Wrapper)
{
    AVFCtlBufferReceiver *receiver = [[AVFCtlBufferReceiver alloc] initWithFileWrapper:Wrapper];
    [(id)Ctl createCaptureSession:receiver];
}

void AVFCtlWrapper::StartCaptureSession()
{
    [(id)Ctl startCaptureSession];
}

void AVFCtlWrapper::StopCaptureSession()
{
    [(id)Ctl stopCaptureSession];
}

void AVFCtlWrapper::SetPlaybackMode(playback_mode Mode, float Speed)
{
    [(id)Ctl setPlaybackMode:(AVCaptureDeviceTransportControlsPlaybackMode)Mode speed:Speed];
}

void AVFCtlWrapper::WaitForSessionEnd()
{
    [(id)Ctl waitForSessionEnd];
}
