//
//  DJViewController.m
//  MultiPeerTest
//
//  Created by sadmin on 7/5/13.
//  Copyright (c) 2013 DJMobileInc. All rights reserved.

#import "DJViewController.h"
#import "MCNearbyHelper.h"

@interface DJViewController ()<MCBrowserViewControllerDelegate, MCSessionDelegate>
@property (nonatomic,strong) MCNearbyHelper * mcnearbyHelper;

- (IBAction)startAdvertising:(id)sender;
- (IBAction)startBrowsing:(id)sender;
- (IBAction)useController:(id)sender;
- (IBAction)startSessionFromC:(id)sender;
@property(nonatomic,strong) MCBrowserViewController * browserController;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property(nonatomic,strong) MCSession * session;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation DJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
   
}
- (IBAction)sendData:(UIButton *)sender {
    NSError *error;
    NSData *data  = UIImagePNGRepresentation([UIImage imageNamed:@"GreenStar"]);
    if(self.session) {
        [self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataUnreliable error:&error];
       
//         NSString * path =[[NSBundle mainBundle]pathForResource:@"GreenStar" ofType:@"png"];
//         NSURL * url = [NSURL fileURLWithPath:path];
        
//         [self.session sendResourceAtURL:url withName:@"file" toPeer:self.session.connectedPeers[0] withCompletionHandler:^(NSError *error) {
//            NSLog(@"Complete with error %@", error);
//         
//         }];
    }
    if(error) {
        NSLog(@"%@",error);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startAdvertising:(id)sender {

    NSLog(@"%@ ",_mcnearbyHelper.advertiser);
    [_mcnearbyHelper.advertiser startAdvertisingPeer];
}

- (IBAction)startBrowsing:(id)sender {
    NSLog(@"%@ ",_mcnearbyHelper.browser);
    [_mcnearbyHelper.browser startBrowsingForPeers];
    
}
- (IBAction)useController:(id)sender {
    if(!_browserController){
        
        _browserController = [[MCBrowserViewController alloc]initWithServiceType:SERVICE session:_session];
        _browserController.delegate = self;
     }
    
    _browserController.view.frame  =self.view.bounds;
    [self.view addSubview:_browserController.view];

}

- (IBAction)startSessionFromC:(id)sender {
    _mcnearbyHelper = [[MCNearbyHelper alloc]initWithName:self.textField.text];
    _session= [[MCSession alloc]initWithPeer:_mcnearbyHelper.peerId];
    _mcnearbyHelper.session = _session;
    _session.delegate = self;
    
}

#pragma mark browser delegate
-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    [_browserController.view removeFromSuperview];
    self.session.delegate = self;
}
-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [_browserController.view removeFromSuperview];
    self.session.delegate = self;
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error{
      NSLog(@"%@ ",error.debugDescription);
}

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info{
     NSLog(@"Found Peer! %@ ",peerID);
}
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID{
     NSLog(@"Lost Peer! %@ ",peerID);
}

-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
    NSLog(@"Received Resource %@",resourceName);
    
}

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    NSLog(@"Data received %@",data);
}
-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    if(state ==  MCSessionStateConnected)
    {
        NSLog(@"Connected");
        //NSString * string =@"Hello";
        
        
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"apple.com"]];
        NSError * error;
        
        [session sendData:data toPeers:@[peerID] withMode:MCSessionSendDataReliable error:&error];
        if(error){
            NSLog(@"Error %@",error.debugDescription);
        }
        
        
    }
    else if(state == MCSessionStateNotConnected) {
        NSLog(@"Not connected");
    }
    else if(state == MCSessionSendDataUnreliable) {
        NSLog(@"unreliable");
    }
    else if(state == MCSessionStateConnecting) {
        NSLog(@"Connecting");
    }
}
-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    NSLog(@"Did Finish Receiving Resource");
}
-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    
}
@end
