//
//  ViewController.m
//  QBNetworkDemo
//
//  Created by 覃斌 卢    on 2020/9/22.
//

#import "ViewController.h"
#import "QBNetworkManager.h"
#import "TestApi.h"

@interface ViewController ()

@property (strong, nonatomic) TestApi *testApi;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.testApi = [[TestApi alloc]init];
    [self.testApi start];
    
    self.testApi.successCompletionBlock = ^(__kindof QBHttpRequest * _Nonnull request) {
        NSString *str = request.responseString;
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.testApi stop];
    });
    
    self.testApi.failureCompletionBlock = ^(__kindof QBHttpRequest * _Nonnull request) {
        NSError *err = request.error;
    };
    
}


@end
