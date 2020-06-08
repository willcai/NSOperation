//
//  ViewController.m
//  多线程-NSOperation2
//
//  Created by Will on 2020/6/4.
//  Copyright © 2020 Will. All rights reserved.
//

#import "ViewController.h"
#import "CustomOperation.h"
@interface ViewController ()
@property (nonatomic, assign) NSInteger totalTicketCount;
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSOperationQueue *queue;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // NSOperation 抽象类，子类NSInvocation 和NSBlockOperation
    // NSOperation四个状态：准备、执行中、取消、完成
    // NSOperation 添加quque才能开启多线程
    // 继承NSOperation
    // 优先级，并发数，相互依赖、非线程安全-锁、监听queue中的操作是否全部完成、
        
    
//    [self customOperation];
    
//    [self InvocationOperation_noneQueue];
//    [self blockOperation_noneQueue];
//    [self blockOperation_addExecutionBlock];
//    [self queue_NSInvocationOperation_NSBlockOperation];
//    [self operation_addDependency];
//    [self queue_addOperationWithBlock];
//    [self runInOtherThread];
//    [self ticketSale_unsafe];
    [self queue_kvo_operationCount];
    
}
#pragma mark - NSInvocationOperation
/**
 子类：NSInvocationOperation
 知识点：不添加queue,串行执行操作
 */
- (void)InvocationOperation_noneQueue{
    NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(method1) object:nil];
    [invocationOperation start];
}

#pragma mark - NSBlockOperation
/**
子类：NSBlockOperation
知识点：不添加queue,串行执行操作
*/
- (void)blockOperation_noneQueue{
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"3------%@",[NSThread currentThread]);
        }
    }];
    [blockOperation start];
}
/**
子类：NSBlockOperation
知识点：addExecutionBlock,添加额外的操作，可能会在不同线程并行
 
*/
- (void)blockOperation_addExecutionBlock{
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"blockOperationWithBlock------%@",[NSThread currentThread]);
        }
    }];
    [blockOperation addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"addExecutionBlock---1---%@",[NSThread currentThread]);
        }
    }];
    [blockOperation addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"addExecutionBlock---2---%@",[NSThread currentThread]);
        }
    }];
    [blockOperation start];
    
    
}

#pragma mark - 使用自定义继承自 NSOperation 的子类
/**
 继承NSOperation，重写main方法，main方法里添加要执行的操作
 在当前线程运行
 */
- (void)customOperation{
    CustomOperation *op = [[CustomOperation alloc] init];
    [op start];
}
/**
 在其他线程运行
 */
- (void)runInOtherThread{
    [NSThread detachNewThreadSelector:@selector(customOperation) toTarget:self withObject:nil];
}
#pragma mark -操作间相互依赖
/**
 addDependency，相互依赖大于优先级
 */
- (void)operation_addDependency
{
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(method1) object:nil];
    NSInvocationOperation *op2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(method2) object:nil];
    NSInvocationOperation *op3 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(method3) object:nil];
    
    [op1 addDependency:op2];//op1依赖op2
    [op2 addDependency:op3];//op2依赖op3
//    [op2 removeDependency:op3];移除依赖
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
    
    
}
#pragma mark - Queue

- (void)queue_NSInvocationOperation_NSBlockOperation{
    
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(method1) object:nil];
    NSInvocationOperation *op2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(method2) object:nil];
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        [self method3];
    }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
    
        //警告：不要即把操作添加到操作队列中，又调用操作的start方法，这样是不允许的！否则运行时直接报错。
    //    [op1 start];
    //    [op2 start];
    //    [op3 start];
    
}
/**
 addOperationWithBlock，开启新线程，并发执行
 */
- (void)queue_addOperationWithBlock
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 2;
    
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"1---%@",[NSThread currentThread]);
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"2---%@",[NSThread currentThread]);
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"3---%@",[NSThread currentThread]);
        }
    }];
    
}
/**
 线程间通讯，主线程刷新ui
 */
- (void)queue_otherqueue_mainqueue{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"1---%@",[NSThread currentThread]);
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"主线程刷新UI");
            NSLog(@"2---%@",[NSThread currentThread]);
        }];
        
    }];
}

/**
 kvo监听queue的operationCount，监听queue是否执行完成
 */
- (void)queue_kvo_operationCount{
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(method1) object:nil];
    NSInvocationOperation *op2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(method2) object:nil];
    NSInvocationOperation *op3 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(method3) object:nil];
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 1;
    [self.queue addOperation:op1];
    [self.queue addOperation:op2];
    [self.queue addOperation:op3];

    [self.queue addObserver:self forKeyPath:@"operationCount" options:(NSKeyValueObservingOptionNew) context:nil];
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"operationCount:%zi",self.queue.operationCount);
}


- (void)method1{
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:2];
        NSLog(@"1------%@",[NSThread currentThread]);
    }
}
- (void)method2{
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:2];
        NSLog(@"2------%@",[NSThread currentThread]);
    }
}
- (void)method3{
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:2];
        NSLog(@"3------%@",[NSThread currentThread]);
    }
}
#pragma mark - 线程不安全
/**
 线程不安全
 */
- (void)ticketSale_unsafe{
    self.totalTicketCount = 50;
    
    NSBlockOperation *salewin1 = [NSBlockOperation blockOperationWithBlock:^{
        [self ticketBeginSale];
        
    }];
    NSBlockOperation *salewin2 = [NSBlockOperation blockOperationWithBlock:^{
        [self ticketBeginSale];
        
    }];
    
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:salewin1];
    [queue addOperation:salewin2];
    
    
}
- (void)ticketBeginSale{
    
    while (1) {
        [self.lock lock];//加锁
        if (self.totalTicketCount > 0) {
            self.totalTicketCount--;
            NSLog(@"剩余票数：%zi",self.totalTicketCount);
            [NSThread sleepForTimeInterval:0.2];
           
        }
        [self.lock unlock];//解锁
        if (self.totalTicketCount <= 0) {
            NSLog(@"票已售完~~~~~~~~");
            
            break;
        }
        
    }
}
- (NSLock *)lock{
    if (!_lock) {
        _lock = [[NSLock alloc] init];
    }
    return _lock;
}
@end
