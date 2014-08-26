//
//  ZKAppDelegate.m
//  ZKMultiThreading
//
//  Created by Zeeshan Khan on 18/08/14.
//  Copyright (c) 2014 Zeeshan Khan. All rights reserved.
//

#import "ZKAppDelegate.h"
#import "ZKOperation.h"

@interface ZKAppDelegate () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *arrRows;
@end

@implementation ZKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self addTableInWindow];
    return YES;
}

- (void)addTableInWindow {
    
    self.arrRows = @[@"Without NSOperation", @"NSInvocationOperation", @"NSBlockOperation", @"Without NSOperationQueue", @"Operation Sub Class", @"Dependecy Use", @"Priority Use", @"Dependecy & Priority Use"];

    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    UITableView *tbl = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, screenSize.width-20, screenSize.height-40)];
    [tbl setCenter:_window.center];
    [tbl.layer setBorderColor:[UIColor blueColor].CGColor];
    [tbl.layer setCornerRadius:5];
    [tbl.layer setBorderWidth:1];
    [tbl setDataSource:self];
    [tbl setDelegate:self];
    [_window addSubview:tbl];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrRows.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"] autorelease];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.arrRows objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self withoutOperation];
            break;
            
        case 1:
            [self usingInvocationOperation];
            break;
            
        case 2:
            [self usingBlockOperation];
            break;
            
        case 3:
            [self usingOperationWithoutQueue];
            break;
            
        case 4:
            [self usingOperationSubClass];
            break;

        case 5:
            [self usingDependecies];
            break;

        case 6:
            [self usingPriority];
            break;

        case 7:
            [self usingDependencyAndPriority];
            break;

        default:
            NSLog(@"Row Selected Index: %d", indexPath.row);
            break;
    }
}

#pragma mark - Without Operation

- (void)withoutOperation {

    NSOperationQueue *queue = [NSOperationQueue new];
    [queue addOperationWithBlock:^{
        NSLog(@"NSOperationQueue executing block without any operation.Is Main thread: %@", [NSThread isMainThread] ? @"YES" : @"NO");
    }];
    [queue release]; queue = nil;
}

#pragma mark - Invocation Operation

- (void)usingInvocationOperation {

    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(loadDataWithOperation)
																			  object:nil];

    NSOperationQueue *queue = [NSOperationQueue new];
	[queue addOperation:operation];
    [queue release]; queue = nil;
    [operation release]; operation = nil;
}

- (void)loadDataWithOperation {
    NSLog(@"NSOperationQueue executing NSInvocationOperation through selector call. Is Main thread: %@", [NSThread isMainThread] ? @"YES" : @"NO");
}

#pragma mark - Block Operation

- (void)usingBlockOperation {

    // Way 1
    NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"NSOperationQueue executing NSBlockOperation 1st Added in queue, Is Main thread: %@", [NSThread isMainThread] ? @"YES" : @"NO");
    }];
    
    // Way 2
    NSBlockOperation *blockOp2 = [[NSBlockOperation new] autorelease];
    [blockOp2 addExecutionBlock:^{
        NSLog(@"NSOperationQueue executing NSBlockOperation 2nd Added in queue, Is Main thread: %@", [NSThread isMainThread] ? @"YES" : @"NO");
    }];

    
    NSOperationQueue *queue = [NSOperationQueue new];
    [queue addOperation:blockOp];
    [queue addOperation:blockOp2];
    [queue release]; queue = nil;
}

#pragma mark - Operation without Queue

- (void)usingOperationWithoutQueue {
    

    NSBlockOperation *blockOp2 = [NSBlockOperation new];
    [blockOp2 addExecutionBlock:^{
        NSLog(@"Executing NSBlockOperation without queue, Is Main thread: %@", [NSThread isMainThread] ? @"YES" : @"NO");
    }];
    [blockOp2 start];
    [blockOp2 release]; blockOp2 = nil;
}

#pragma mark - Operation Subclass

- (void)usingOperationSubClass {
    
    ZKOperation *op = [ZKOperation new];
    NSOperationQueue *opq = [NSOperationQueue new];
    [opq addOperation:op];
//    [op start]; // If you want to control the access of execution of Any Operation
    [op release]; op = nil;
    [opq release]; opq = nil;
}


#pragma mark - Operation Subclass

- (void)usingDependecies {
    
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"Dependent - First Added in queue");
    }];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"Dependent - Second Added in queue");
    }];
    [op1 addDependency:op2];

    
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"Independent - Last Added in queue");
    }];
    [op2 addDependency:op3];


    NSOperationQueue *queue = [NSOperationQueue new];
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
    [queue release]; queue = nil;
}


- (void)usingPriority {
    
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"Priority Very Low - First Added in queue");
    }];
    [op1 setQueuePriority:NSOperationQueuePriorityVeryLow];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"Priority High - Second Added in queue");
    }];
    [op1 setQueuePriority:NSOperationQueuePriorityHigh];
    
    
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"Priority Normal - Last Added in queue");
    }];
    [op1 setQueuePriority:NSOperationQueuePriorityNormal];

    
    NSOperationQueue *queue = [NSOperationQueue new];
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
    [queue release]; queue = nil;
}

- (void)usingDependencyAndPriority {
    
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"Priority Very Low - First Added in queue");
    }];
    [op1 setQueuePriority:NSOperationQueuePriorityVeryLow];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"Priority High, Dependent on First - Second Added in queue");
    }];
    [op1 setQueuePriority:NSOperationQueuePriorityHigh];
    [op2 addDependency:op1];
    
    
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"Priority Normal, Dependent on Second - Last Added in queue");
    }];
    [op1 setQueuePriority:NSOperationQueuePriorityNormal];
    [op3 addDependency:op2];
    
    
    NSOperationQueue *queue = [NSOperationQueue new];
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
    [queue release]; queue = nil;
}

@end
