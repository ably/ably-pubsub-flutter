@import AblyPubSubDevice;

#import "AblyInstanceStore.h"

@implementation AblyInstanceStore {
    NSMutableDictionary<NSNumber *, ARTPubSubClient *>* _realtimeInstances;
    NSMutableDictionary<NSNumber *, ARTPaginatedResult *>* _paginatedResults;
    long long _nextHandle;
}

+ (AblyInstanceStore *)sharedInstance {
    static AblyInstanceStore *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(NSNumber *) getNextHandle {
    return @(_nextHandle++);
}

-(instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _realtimeInstances = [NSMutableDictionary new];
    _paginatedResults = [NSMutableDictionary new];
    _nextHandle = 1;
    
    return self;
}

-(void)setRealtime:(ARTPubSubClient *const)realtime with:(NSNumber *const)handle {
    _realtimeInstances[handle] = realtime;
}

-(ARTPubSubClient *)realtimeFrom:(NSNumber *)handle {
    return _realtimeInstances[handle];
}

-(NSNumber *)setPaginatedResult:(ARTPaginatedResult *const)result handle:(NSNumber *) handle {
    if(!handle){
        handle = @(_nextHandle++);
    }
    _paginatedResults[handle] = result;
    return handle;
}

-(ARTPaginatedResult *) getPaginatedResult:(NSNumber *const) handle {
    return _paginatedResults[handle];
}

// Set device token on all existing clients
-(void) didRegisterForRemoteNotificationsWithDeviceToken:(NSData *const) deviceToken {
    _didRegisterForRemoteNotificationsWithDeviceToken_deviceToken = deviceToken;
    
    for (id realtimeHandle in _realtimeInstances) {
        ARTPubSubClient *const realtime = _realtimeInstances[realtimeHandle];
        [ARTPush didRegisterForRemoteNotificationsWithDeviceToken:deviceToken pubsub:realtime];
    }
}

-(void)reset {
    for (ARTPubSubClient *const r in _realtimeInstances.allValues) {
        [r close];
    }
    [_realtimeInstances removeAllObjects];
}

@end

