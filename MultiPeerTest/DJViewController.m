//
//  DJViewController.m
//  MultiPeerTest
//
//  Created by sadmin on 7/5/13.
//  Copyright (c) 2013 DJMobileInc. All rights reserved.

#import "DJViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface DJViewController ()<MCBrowserViewControllerDelegate, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCAdvertiserAssistantDelegate, UITextViewDelegate>

@property(strong,nonatomic)MCNearbyServiceAdvertiser *adevertiser;
@property(strong,nonatomic)MCNearbyServiceBrowser *browser;
@property(strong,nonatomic)MCPeerID *peerId;
- (IBAction)startAdvertising:(id)sender;
- (IBAction)startBrowsing:(id)sender;
- (IBAction)useController:(id)sender;
- (IBAction)startSessionFromC:(id)sender;
@property(nonatomic,strong) MCBrowserViewController * browserController;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property(nonatomic,strong) MCSession * session;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property(strong,nonatomic) NSOperationQueue * queue;



@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation DJViewController
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    [self.session sendData:[textView.text dataUsingEncoding:NSUTF8StringEncoding] toPeers:self.session.connectedPeers withMode:MCSessionSendDataUnreliable error:nil];
    return YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textView.delegate = self;
    _queue = [[NSOperationQueue alloc]init];
}
- (IBAction)sendData:(UIButton *)sender {
    NSError *error;
    NSLog(@" Sending data!!");
    
    if(self.session) {
        [self.session sendData:UIImagePNGRepresentation([UIImage imageNamed:@"GreenStar"]) toPeers:self.session.connectedPeers withMode:MCSessionSendDataUnreliable error:&error];
        
            NSLog(@" Sending data!! !! !!! ");
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

    
    
    [self.adevertiser startAdvertisingPeer];
}

- (IBAction)startBrowsing:(id)sender {
   
    [self.browser startBrowsingForPeers];
    
}
- (IBAction)useController:(id)sender {
    if(!_browserController){
        
        _browserController = [[MCBrowserViewController alloc]initWithServiceType:SERVICE session:_session];
        _browserController.delegate = self;
     }
    [self presentViewController:_browserController animated:YES completion:nil];


}

- (IBAction)startSessionFromC:(id)sender {
    self.peerId = [[MCPeerID alloc]initWithDisplayName:self.textField.text];
    
    _session= [[MCSession alloc]initWithPeer:self.peerId securityIdentity:nil encryptionPreference:MCEncryptionNone];
    _session.delegate = self;
    self.adevertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerId discoveryInfo:nil serviceType:SERVICE];
    self.adevertiser.delegate = self;
    self.browser =[[MCNearbyServiceBrowser alloc]initWithPeer:self.peerId serviceType:SERVICE];

    self.browser.delegate = self;
    
}

#pragma mark browser delegate
-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    [browserViewController dismissViewControllerAnimated:YES completion:^{
        self.session.delegate = self;
    }];
}
-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [browserViewController dismissViewControllerAnimated:YES completion:^{
        self.session.delegate = self;
    }];
    
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error{
      NSLog(@"%@ ",error.debugDescription);
}

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info{
    [browser invitePeer:peerID toSession:self.session withContext:[NSData dataWithBytes:"\x01" length:1] timeout:30];
}
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID{
     NSLog(@"Lost Peer! %@ ",peerID);
}

-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
    NSLog(@"Received Resource %@",resourceName);
    
}

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    NSString * s = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",s);
   
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            self.textView.text =[self.textView.text stringByAppendingString:s];
    
    
    }];
    
    
}



-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    if(state ==  MCSessionStateConnected)
    {
        NSLog(@"Connected");
        //NSString * string =@"Hello";
        
        NSError *error;
        [session sendData:[@"SDGSDGGS" dataUsingEncoding:NSUTF8StringEncoding] toPeers:@[peerID] withMode:MCSessionSendDataReliable error:&error];
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
    
}// Made first contact with peer and have identity information about the remote peer (peerCert may be nil)
- (BOOL)session:(MCSession *)session shouldAcceptCertificate:(SecCertificateRef)peerCert forPeer:(MCPeerID *)peerID
{
    NSLog(@"should accept");
    return YES;
    
}
-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error{
    NSLog(@"Advertising Start Error %@",[error debugDescription]);
}

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL isTrue, MCSession * _session))invitationHandler{
    NSLog(@"Did receive invitation");
    invitationHandler(YES, _session);
}

@end