/*  Copyright (c) MIPoPS. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-3-Clause license that can
 *  be found in the LICENSE.txt file in the root of the source tree.
 */

#import "avfctl.h"

@implementation AVFCtlReceiver

- (id) initWithDevice:(AVCaptureDevice*) theDevice
{
    self = [super init];
    if (self) {
        _device = theDevice;

    }
    return self;
}

- (void)  captureOutput:(AVCaptureOutput *)captureOutput
  didOutputSampleBuffer:(CMSampleBufferRef)videoFrame
         fromConnection:(AVCaptureConnection *)connection
{
    //NSLog(@"Frame received. Output File: %@", _output_file);
    if (_output_file != nil) {
        CMBlockBufferRef block_buffer = CMSampleBufferGetDataBuffer(videoFrame); // raw, DV data only
        size_t bb_len = CMBlockBufferGetDataLength(block_buffer);
        if (_output_data.length != bb_len) {
            //NSLog(@"Frame received. New length: %ld -> %ld", _output_data.length, bb_len);
            _output_data.length = bb_len;
        }
        //NSLog(@"Frame received. Copy %ld -> %ld", bb_len, _output_data.length);
        CMBlockBufferCopyDataBytes(block_buffer, 0, _output_data.length, _output_data.mutableBytes);
        [_output_file writeData:_output_data];
    }
}

- (void)  captureOutput:(AVCaptureOutput *)captureOutput
    didDropSampleBuffer:(CMSampleBufferRef)videoFrame
         fromConnection:(AVCaptureConnection *)connection
{
    NSLog(@"Frame dropped.");
}

@end


@implementation AVFCtl

- (id) initWithDevice:(AVCaptureDevice*) theDevice
{
    self = [super init];
    if (self) {
        _device = theDevice;

        _old_mode  = [_device transportControlsPlaybackMode];
        _old_speed = [_device transportControlsSpeed];

        _status_mode = NO;

        NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew;
        NSString *keyPath = nil;

        keyPath = NSStringFromSelector(@selector(transportControlsPlaybackMode));
        [_device addObserver:self forKeyPath:keyPath options:options context:nil];

        keyPath = NSStringFromSelector(@selector(transportControlsSpeed));
        [_device addObserver:self forKeyPath:keyPath options:options context:nil];
    }
    return self;
}

- (void) dealloc
{
        NSString *keyPath = nil;

        keyPath = NSStringFromSelector(@selector(transportControlsPlaybackMode));
        [_device removeObserver:self forKeyPath:keyPath];

        keyPath = NSStringFromSelector(@selector(transportControlsSpeed));
        [_device removeObserver:self forKeyPath:keyPath];
}

- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                       change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == nil) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(transportControlsPlaybackMode))]) {
            AVCaptureDeviceTransportControlsPlaybackMode mode =
                [change[NSKeyValueChangeNewKey] integerValue];

            if (_old_mode != mode && !_status_mode) {
                NSLog(@"Mode changed: %ld -> %ld", _old_mode, mode);
                if (mode == AVCaptureDeviceTransportControlsNotPlayingMode &&
                    [_session isRunning]) {
                    NSLog(@"Stopping capturing.");
                    [self stopCaptureSession];
                }
                _old_mode = mode;
            }
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(transportControlsSpeed))]) {
            AVCaptureDeviceTransportControlsSpeed speed =
                [change[NSKeyValueChangeNewKey] floatValue];

            if (_old_speed != speed && !_status_mode) {
                NSLog(@"Speed changed: %f -> %f", _old_speed, speed);
                _old_speed = speed;
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

- (NSString*) getDeviceName
{
    return [_device localizedName];
}

- (NSString*) getStatus
{
    NSString *status;

    float speed = [_device transportControlsSpeed];
    if (speed == 0.0f) {
        status = @"stopped";
    } else if (speed == 1.0f) {
        status = @"playing";
    } else if (speed > 1.0f) {
        status = @"fast-forwarding";
    } else if (speed < 0.0f) {
        status = @"rewinding";
    } else {
        status = @"unknown";
    }

    return status;
}

- (void) setPlaybackMode:(AVCaptureDeviceTransportControlsPlaybackMode)theMode speed:(AVCaptureDeviceTransportControlsSpeed) theSpeed;
{
    @try {
        NSError *error = nil;
        if ([_device lockForConfiguration:&error] == YES) {
            [_device setTransportControlsPlaybackMode:theMode speed:theSpeed];
            [_device unlockForConfiguration];
        } else {
            NSLog(@"Error: %@", error);
        }
    }
    @catch (NSException *e) {
        NSLog(@"Exception: %@", e);
    }
}

- (void) createCaptureSessionWithOutputFileName:(NSString*) theFileName;
{
    NSError *error = nil;

    @try {
        _session = [[AVCaptureSession alloc] init];

        // add input to session
        AVCaptureDeviceInput *device_input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
        if (device_input == nil) {
            NSLog(@"Error creating device input: %@", error);
            return;
        }

        if (![_session canAddInput:device_input]) {
            NSLog(@"Error adding input to session");
            return;
        }

        [_session addInput:device_input];

        // create output for session
        _output = [[AVCaptureVideoDataOutput alloc] init];
        _output.videoSettings = @{ }; // set empty dict to receive raw data
        [_output setAlwaysDiscardsLateVideoFrames:NO];

        // create receiver delegate
        NSUInteger datalen = 1000; // some dummy value, subject to realloc during first frame

        _receiver = [[AVFCtlReceiver alloc] initWithDevice:_device];
         if ([theFileName isEqualToString: @"-"]) {
            _receiver.output_file = [NSFileHandle fileHandleWithStandardOutput];
        } else {
            [[NSFileManager defaultManager] createFileAtPath:theFileName contents:nil attributes:nil];
            _receiver.output_file = [NSFileHandle fileHandleForWritingAtPath:theFileName];
        }
        _receiver.output_data = [NSMutableData dataWithLength:datalen];

        //NSLog(@"Output file: %@", _receiver.output_file);
        //NSLog(@"Output data: %ld", _receiver.output_data.length);

        // add receiver delegate to output
        dispatch_queue_t queue = dispatch_queue_create("avfctl_queue", NULL);
        [_output setSampleBufferDelegate:(id)_receiver queue:queue];
        // not in arc: dispatch_release(queue);

        // add output to session
        if (![_session canAddOutput:_output]) {
            NSLog(@"Error adding output to session");
            return;
        }

        [_session addOutput:_output];
    }
    @catch (NSException *e) {
        NSLog(@"Error creating capture session: %@", e);
        return;
    }

}

- (void) startCaptureSession
{
    [_session startRunning];

}

- (void) stopCaptureSession
{
    [_session stopRunning];
}

- (void) waitForSessionEnd
{
    // block as long as the capture session is running
    // terminates if playback mode changes to NotPlaying
    while ([_device transportControlsSpeed] != 0.0f) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5f]];
    }
}

@end
