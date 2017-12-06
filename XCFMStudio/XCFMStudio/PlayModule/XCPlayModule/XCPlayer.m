//
//  XCPlayer.m
//  XCFMStudio
//
//  Created by caijinzhu on 2017/12/6.
//  Copyright © 2017年 caijinzhu. All rights reserved.
//

#import "XCPlayer.h"
#import <AVFoundation/AVFoundation.h>


@interface XCPlayer()

@property (nonatomic, strong) AVPlayer *player;

@end



@implementation XCPlayer

- (void)playWithUrl:(NSString *)url{
    _playURL = url;
    // 1. 请求资源
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:url]];
    
    // 2. 组织资源
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    // 2.1 使用kvo,监听资源组织的状态(当资源准备好后,再进行播放)
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 3. 播放资源
    self.player = [AVPlayer playerWithPlayerItem:item];
    
    [self.player play];
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerItemStatusReadyToPlay) {  // 资源准备好了..
            
        }
        
    }
}


#pragma mark - interface method

- (void)pause{
    [self.player pause];
}
- (void)resume{
    [self.player play];
}
- (void)stop{
    [self.player pause];
    self.player = nil;
}

- (void)seekWithTimeOffset:(NSTimeInterval)offset{

    // 当前播放时长
    NSTimeInterval playingTime = offset + self.currentTime;
    [self seekWithProgress:playingTime / self.totalTime];
}
// 快进
- (void)seekWithProgress:(float)progress{
    if (progress < 0 || progress > 1) {return;}
    // CMTime : 影片时间(以帧率为计时单位)
    // 1. 影片时间 -> 秒
    // 当前播放时长
    // CMTime currentTime = self.player.currentTime;
    NSTimeInterval playTime = self.totalTime * progress;
    CMTime gotoTime = CMTimeMake(playTime, 1);
    
    [self.player seekToTime:gotoTime completionHandler:^(BOOL finished) {
        if (finished) {  // 播放加载的资源
            
        }else{ // 取消加载的资源
            
        }
    }];
}
- (void)setRate:(float)rate{
    [self.player setRate:rate];
}
- (float)rate{
    return self.player.rate;
}
- (void)setMute:(BOOL)mute{
    self.player.muted = mute;
}
- (BOOL)mute{
    return self.player.muted;
}

- (void)setVolume:(float)volume{
    if (volume < 0 || volume > 1) {return;}
    self.player.muted = volume == 0;
    self.player.volume = volume;
}
- (float)volume{
    return self.player.volume;
}

#pragma mark - 数据
- (NSTimeInterval)totalTime{
    CMTime totalTime = self.player.currentItem.duration;
    NSTimeInterval time = CMTimeGetSeconds(totalTime);
    if (isnan(time)) {return 0;}
    return time;
}
- (NSTimeInterval)currentTime{
    CMTime currentTime = self.player.currentTime;
   NSTimeInterval time = CMTimeGetSeconds(currentTime);
    if (isnan(time)) {return 0;}
    return time;
}

- (float)progress{
    if (self.totalTime == 0) {return 0;}
    return self.currentTime / self.totalTime;
}
- (float)loadingCacheProgress{
    if (self.totalTime == 0) {return 0;}
    CMTimeRange loadedRange = [self.player.currentItem.loadedTimeRanges.lastObject CMTimeRangeValue];
    CMTime loadedTime = CMTimeAdd(loadedRange.start, loadedRange.duration);
    NSTimeInterval loadedSecond = CMTimeGetSeconds(loadedTime);
    return loadedSecond / self.totalTime;
}
@end
