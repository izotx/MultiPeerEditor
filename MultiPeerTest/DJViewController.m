//
//  DJViewController.m
//  MultiPeerTest
//
//  Created by sadmin on 7/5/13.
//  Copyright (c) 2013 DJMobileInc. All rights reserved.

#import "DJViewController.h"
#import "MessageData.h"
#import "MPUser.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "DataSource.h"


@interface DJViewController ()<MCBrowserViewControllerDelegate, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCAdvertiserAssistantDelegate, UITextViewDelegate>
{
    NSRange previousSelectedRange;
}
@property(strong,nonatomic)MCNearbyServiceAdvertiser *adevertiser;
@property(strong,nonatomic)MCNearbyServiceBrowser *browser;
@property(strong,nonatomic)MCPeerID *peerId;
@property(strong,nonatomic)MPUser * mpuser;
@property(strong,nonatomic)UITableView * tableView;
@property (nonatomic,strong)NSMutableDictionary * userColors;
@property (nonatomic,strong)NSArray * colors;
@property (nonatomic,strong) DataSource * datasource;

@property(nonatomic,strong) MCBrowserViewController * browserController;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property(nonatomic,strong) MCSession * session;

@property (weak, nonatomic) IBOutlet UITextView *textViewUp;
@property (strong, nonatomic) IBOutlet UITextView *textViewDown;
@property(strong,nonatomic) NSOperationQueue * queue;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)startAdvertising:(id)sender;
- (IBAction)startBrowsing:(id)sender;
- (IBAction)useController:(id)sender;
- (IBAction)startSessionFromC:(id)sender;

@end

@implementation DJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textViewUp.delegate = self;
    self.textViewDown.delegate = self;
    _colors = @[[UIColor blackColor], [UIColor redColor],[UIColor blueColor],[UIColor greenColor], [UIColor grayColor],[UIColor darkGrayColor],[UIColor orangeColor],[UIColor purpleColor]];
    _userColors =  [NSMutableDictionary new];
    previousSelectedRange = NSMakeRange(0, 0);
    _queue = [[NSOperationQueue alloc]init];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-200, 0, 200, 300) style:UITableViewStylePlain];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    _datasource = [[DataSource alloc]initWithItems:self.userColors.allKeys cellIdentifier:@"Cell" configureCellBlock:^(UITableViewCell *cell, MCPeerID * item, id indexPath){
        cell.textLabel.text = item.displayName;
        cell.textLabel.textColor = self.userColors[item];
        
    }];
    self.tableView.dataSource = self.datasource;
    [self.view addSubview:self.tableView];
    [self.tableView reloadData];
    
}


-(void)sendDataWithData:(NSData *)messageData{
    NSError *error;
    
    if(self.session){
        [self.session sendData:messageData toPeers:self.session.connectedPeers withMode:MCSessionSendDataUnreliable error:&error];
    }
    else{
        [self session:self.session didReceiveData:messageData fromPeer:self.peerId];
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
    //set user color, since we want to start new session we can safely remove all objects.
    [self.userColors removeAllObjects];
    self.userColors[self.peerId] = self.colors[0];
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

#pragma mark TextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView;{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
}
- (void)textViewDidEndEditing:(UITextView *)textView;{
    
}

- (void)textViewDidChange:(UITextView *)textView{
    
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    MessageData * message = [[MessageData alloc]init];
    message.range = range;
    //message.messageText = text;
    
    if(textView.attributedText.length==0)
    {
        NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:textView.text];
        [string addAttribute:NSForegroundColorAttributeName
                     value:[UIColor blackColor]
                       range:NSMakeRange(0, textView.text.length)];

        textView.attributedText = string;
    }
    
    NSAttributedString * attributedString = [[NSAttributedString alloc]initWithString:text];
    NSLog(@"Attributed String %@",attributedString);
    
    message.attributedString = attributedString;
  // message.attributedString  = textView.attributedText;
  //  message.range = NSMakeRange(0, textView.text.length);
    message.selection= NO;
    NSData * messageData =[NSKeyedArchiver archivedDataWithRootObject:message];
    [self sendDataWithData:messageData];
    
    
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView{
    // UITextRange * selectionRange =textView.selectedTextRange;
    //debugging only
    if(textView == self.textViewDown){
        NSRange selectedRange = textView.selectedRange;

        MessageData * md = [[MessageData alloc]init];
        md.selection = YES;
        md.range = selectedRange;
        
        NSLog(@" Did Change Selection %@",[NSValue valueWithRange:selectedRange]);
        
        NSData * messageData =[NSKeyedArchiver archivedDataWithRootObject:md];
        [self sendDataWithData:messageData];
 
        if(md.range.length>0){
      //      [self sendDataWithData:messageData];
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    return  YES;
}
- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
    return  YES;
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
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.userColors];
    [browser invitePeer:peerID toSession:self.session withContext:data timeout:30];
    
     NSLog(@"invite Peer! %@ ",peerID);
    
    
    
}
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID{
    NSLog(@"Lost Peer! %@ ",peerID);
}


#pragma mark Session

-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
    NSLog(@"Received Resource %@",resourceName);
    
}

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    //NSString * s = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSData * _data  =   [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSLog(@" Data Received ");
    if([_data isKindOfClass:[NSDictionary class]]){
        NSDictionary * dict =(NSDictionary *) _data;
        NSLog(@"Dictionary received %@",dict);
        self.userColors = [dict mutableCopy];
        self.datasource.items = self.userColors.allKeys;
        [self.tableView reloadData];
    
    }
    
    //find out which data it is
    if([_data isKindOfClass:[MessageData class]]){
        MessageData * md = (MessageData *)_data;
        [_queue addOperationWithBlock:^{
            
            NSMutableAttributedString *text = [self.textViewUp.attributedText mutableCopy];
            
            if (text.length<md.range.location + md.range.length) {
                NSLog(@"Out of range");
                
                int emptiness = md.range.location + md.range.length - text.string.length;
                NSMutableString * s = [[NSMutableString alloc]initWithCapacity:emptiness];
                if(emptiness>0){
                    while (s.length<emptiness) {
                        [s appendString:@" "];
                    }
                }
                NSAttributedString * as = [[NSAttributedString alloc]initWithString:s attributes:nil];
                [text appendAttributedString:as];
            }
            
            if(!md.selection){
                [text replaceCharactersInRange:md.range withAttributedString:md.attributedString];
                
            }
            else{
                //check what is selected?
                //            [text addAttribute:NSForegroundColorAttributeName
                //                                     value:[UIColor redColor]
                //                                     range:md.range];
            }
            
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                
                self.textViewUp.attributedText = text;
                
                //            if(!md.selection){
                //                self.textViewUp.attributedText = text;
                //            }
                //            else{
                //                self.textViewUp.scrollEnabled = NO;
                //                self.textViewUp.attributedText = attributedString;
                //                NSLog(@"Selecting range %@",[NSValue valueWithRange:md.range]);
                //                self.textViewUp.selectedRange =md.range;
                //                NSLog(@"Selecting range 2");
                //                self.textViewUp.scrollEnabled = YES;
                // I need to disable it for now. It doesn't work like I expected.
                // [self.textViewUp select:self];
                // self.textViewUp.selectedRange = md.range;
                // }
                //what if multiple people select at the same time? we need to add ranges right??
                
                
                
                
            }];
            
        }];
    
    }
    
   
    //get text
    
    
    
    
    
}



-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
   
    
    if(state ==  MCSessionStateConnected)
    {
        NSLog(@"Connected");
        _mpuser = [[MPUser alloc]init];
        _mpuser.peerID = peerID;
        //_mpuser.displayName  =
        if(!self.userColors[peerID])
        {
             NSLog(@"Not Included");
            //get the color from the list
            //get colors that are already in use
            for(int i=0; i<self.colors.count;i++){
                __block NSInteger foundIndex = NSNotFound;
                [self.userColors.allValues enumerateObjectsUsingBlock:^(UIColor * color, NSUInteger idx, BOOL *stop) {
                    if (color == self.colors[i]) {
                        foundIndex = idx;
                        // stop the enumeration
                        *stop = YES;
                    }
                }];
                
                if (foundIndex == NSNotFound) {
                    
                    //color wasn't used yet. so go ahead and use it.
                    self.userColors[peerID]=self.colors[i];
                    // notify other users
                    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:self.userColors];
                    [self sendDataWithData:data];
                    NSLog(@"Not found. Send Data");
                    break;
                    
                }
            
            }
            
        }
        
        
        //Pick color for the user.
//        for(UIColor * color in self.session.colors.allKeys)
//        {
//            if([self.session.colors[color]  isEqual: @NO])
//            {
//                _mpuser.userColor = color;
//                
//                self.session.colors[color] = @YES;
//                session.colors = self.session.colors;
//                
//                break;
//            }
//        }
        
        NSError *error;
        //[session sendData:[@"SDGSDGGS" dataUsingEncoding:NSUTF8StringEncoding] toPeers:@[peerID] withMode:MCSessionSendDataReliable error:&error];
        
        
        
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

#pragma mark Advertising
-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error{
    NSLog(@"Advertising Start Error %@",[error debugDescription]);
}

//it won't be called first time when the app starts
-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL isTrue, MCSession * _session))invitationHandler{
    NSMutableDictionary * dict  = [[NSKeyedUnarchiver unarchiveObjectWithData:context]mutableCopy];
    NSLog(@"Did receive invitation with context: %@",dict);
    self.userColors = dict;
    invitationHandler(YES, _session);
}

@end