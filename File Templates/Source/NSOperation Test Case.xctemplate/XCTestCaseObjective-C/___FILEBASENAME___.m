//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//
//  Original by Dan Zinngrabe on 6/15/15.
//

#import "NSOperationTestCase.h"

@implementation ___FILEBASENAMEASIDENTIFIER___

#pragma mark - Test Support

- (NSOperation *) operationUnderTest {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override  method %@", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark Subclases should not need to override these methods

- (NSTimeInterval) defaultTimeout {
    NSTimeInterval  result  = 1L;
    
#if TARGET_OS_SIMULATOR
    result = 10L;
#else
    result = 30L;
#endif
    
    return result;
}

+ (NSOperationQueue *) sharedSerialQueue {
    static  NSOperationQueue    *result = nil;
    
    if (result == nil){
        result = [self serialQueueWithName:NSStringFromClass([self class])];
    }
    
    return result;
}

+ (NSOperationQueue *) sharedConcurrentQueue {
    static  NSOperationQueue    *result = nil;
    
    if (result == nil){
        result = [self concurrentQueueWithName:NSStringFromClass([self class])];
    }
    
    return result;
}

+ (NSOperationQueue *)serialQueueWithName:(NSString *)name {
    NSOperationQueue    *result = nil;
    
    result = [self concurrentQueueWithName:name];
    [result setMaxConcurrentOperationCount:1];
    
    return result;
}

+ (NSOperationQueue *)concurrentQueueWithName:(NSString *)name {
    NSOperationQueue    *result = nil;
    
    result = [[NSOperationQueue alloc] init];
    [result setName:name];
    
    return result;
}

#pragma mark - Tests

/**
 *  Tests wether the operation class is actually a subclass of NSOperation.
 */

- (void) testClassIsSubclassOfNSOperation {
    XCTAssertTrue([[[self operationUnderTest] class] isSubclassOfClass:[NSOperation class]], @"Test class is not a subclass of NSOperation");
}

/**
 *  Tests wether instantiating the operation throws an exception or returns a nil object.
 */

- (void) testCanInstantiateOperation {
    NSOperation *testOperation  = nil;
    
    XCTAssertNoThrow((testOperation = [self operationUnderTest]), @"Instantiating operation:%@ threw exception", [[self operationUnderTest] class]);
    XCTAssertNotNil(testOperation, @"Instantiating operation %@ returned nil", [[self operationUnderTest] class]);
}

/**
 *  Tests wether adding the operation to a serial queue that is suspended throws an exception.
 */

- (void) testAddingToSuspendedSerialQueueDoesNotThrowException {
    NSOperation         *testOperation  = nil;
    NSOperationQueue    *queue          = nil;
    
    queue           = [[self class] serialQueueWithName:NSStringFromSelector(_cmd)];
    testOperation   = [self operationUnderTest];
    [queue setSuspended:YES];
    XCTAssertNoThrow([queue addOperation:testOperation], @"Adding operation: %@ to serial queue failed", testOperation);
    
}

/**
 *  Tests wether adding the operation to a serial queue that is not suspended throws an exception.
 */

- (void) testAddingToActiveSerialQueueDoesNotThrowException {
    NSOperation         *testOperation  = nil;
    NSOperationQueue    *queue          = nil;
    
    queue           = [[self class] serialQueueWithName:NSStringFromSelector(_cmd)];
    testOperation   = [self operationUnderTest];
    [queue setSuspended:NO];
    XCTAssertNoThrow([queue addOperation:testOperation], @"Adding operation: %@ to serial queue failed", testOperation);
    
}

/**
 *  Tests wether adding the operation to a concurrent queue that is suspended throws an exception.
 */

- (void) testAddingToSuspendedConcurrentQueueDoesNotThrowException {
    NSOperation         *testOperation  = nil;
    NSOperationQueue    *queue          = nil;
    
    queue           = [[self class] concurrentQueueWithName:NSStringFromSelector(_cmd)];
    testOperation   = [self operationUnderTest];
    [queue setSuspended:YES];
    XCTAssertNoThrow([queue addOperation:testOperation], @"Adding operation: %@ to concurrent queue failed", testOperation);
    
}

/**
 *  Tests wether adding the operation to a concurrent queue that is not suspended throws an exception.
 */

- (void) testAddingToActiveConcurrentQueueDoesNotThrowException {
    NSOperation         *testOperation  = nil;
    NSOperationQueue    *queue          = nil;
    
    queue           = [[self class] concurrentQueueWithName:NSStringFromSelector(_cmd)];
    testOperation   = [self operationUnderTest];
    [queue setSuspended:NO];
    XCTAssertNoThrow([queue addOperation:testOperation], @"Adding operation: %@ to concurrent queue failed", testOperation);
    
}

/**
 *  Tests wether upon completion the operation invokes the completion block when it is used in a serial queue.
 */

- (void) testCanExecuteCompletionBlockWithSerialQueue {
    NSOperation         *testOperation  = nil;
    NSOperationQueue    *queue          = nil;
    XCTestExpectation   *expectation    = nil;
    
    expectation     = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    queue           = [[self class] serialQueueWithName:NSStringFromSelector(_cmd)];
    testOperation   = [self operationUnderTest];
    [testOperation setCompletionBlock:^{
        [expectation fulfill];
    }];
    
    [queue setSuspended:YES];
    [queue addOperation:testOperation];
    [queue setSuspended:NO];
    [self waitForExpectationsWithTimeout:[self defaultTimeout] handler:^(NSError *error) {
        if ([[error domain] isEqualToString:XCTestErrorDomain]){
            XCTFail( @"The operation completion block did not execute within the timeout: %@", error);
        }
    }];
}

/**
 *  Tests wether upon completion the operation invokes the completion block when it is used in a concurrent queue.
 */

- (void) testCanExecuteCompletionBlockWithConcurrentQueue {
    NSOperation         *testOperation  = nil;
    NSOperationQueue    *queue          = nil;
    XCTestExpectation   *expectation    = nil;
    
    expectation     = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    queue           = [[self class] concurrentQueueWithName:NSStringFromSelector(_cmd)];
    testOperation   = [self operationUnderTest];
    [testOperation setCompletionBlock:^{
        [expectation fulfill];
    }];
    
    [queue setSuspended:YES];
    [queue addOperation:testOperation];
    [queue setSuspended:NO];
    [self waitForExpectationsWithTimeout:[self defaultTimeout] handler:^(NSError *error) {
        if ([[error domain] isEqualToString:XCTestErrorDomain]){
            XCTFail( @"The operation completion block did not execute within the timeout: %@", error);
        }
    }];
}

/**
 *  Tests wether the operation can be executed with a dependent operation when it is used in a serial queue.
 */

- (void) testCanExecuteDependentOperationWithSerialQueue {
    NSOperation         *testOperation  = nil;
    NSOperationQueue    *queue          = nil;
    XCTestExpectation   *expectation    = nil;
    NSOperation         *dependant      = nil;
    
    expectation     = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    queue           = [[self class] serialQueueWithName:NSStringFromSelector(_cmd)];
    dependant       = [NSBlockOperation blockOperationWithBlock:^{
        [expectation fulfill];
    }];
    testOperation   = [self operationUnderTest];
    [testOperation addDependency:dependant];
    
    [queue setSuspended:YES];
    [queue addOperation:testOperation];
    [queue addOperation:dependant];
    [queue setSuspended:NO];
    [self waitForExpectationsWithTimeout:[self defaultTimeout] handler:^(NSError *error) {
        if ([[error domain] isEqualToString:XCTestErrorDomain]){
            XCTFail( @"The operation dependency did not execute within the timeout: %@", error);
        }
    }];
}

/**
 *  Tests wether the operation can be executed with a dependent operation when it is used in a concurrent queue.
 */

- (void) testCanExecuteDependentOperationWithConcurrentQueue {
    NSOperation         *testOperation  = nil;
    NSOperationQueue    *queue          = nil;
    XCTestExpectation   *expectation    = nil;
    NSOperation         *dependant      = nil;
    
    expectation     = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    queue           = [[self class] concurrentQueueWithName:NSStringFromSelector(_cmd)];
    dependant       = [NSBlockOperation blockOperationWithBlock:^{
        [expectation fulfill];
    }];
    testOperation   = [self operationUnderTest];
    [testOperation addDependency:dependant];
    
    [queue setSuspended:YES];
    [queue addOperation:testOperation];
    [queue addOperation:dependant];
    [queue setSuspended:NO];
    [self waitForExpectationsWithTimeout:[self defaultTimeout] handler:^(NSError *error) {
        if ([[error domain] isEqualToString:XCTestErrorDomain]){
            XCTFail( @"The operation dependency did not execute within the timeout: %@", error);
        }
    }];
}

/**
 *  Tests wether the operation correctly sends the "isCancelled" key value notification when used in a concurrent queue.
 */

- (void) testCanCancelOperationWithConcurrentQueue {
    NSOperation         *testOperation  = nil;
    NSOperationQueue    *queue          = nil;
    XCTestExpectation   *expectation    = nil;
    
    queue           = [[self class] concurrentQueueWithName:NSStringFromSelector(_cmd)];
    
    testOperation   = [self operationUnderTest];
    expectation     = [self keyValueObservingExpectationForObject:testOperation keyPath:@"isCancelled" handler:^BOOL(id observedObject, NSDictionary *change) {
        return [[observedObject valueForKeyPath:@"isCancelled"] boolValue];
    }];
    
    [queue setSuspended:YES];
    [queue addOperation:testOperation];
    
    [queue cancelAllOperations];
    [queue setSuspended:NO];
    [self waitForExpectationsWithTimeout:[self defaultTimeout] handler:^(NSError *error) {
        if ([[error domain] isEqualToString:XCTestErrorDomain]){
            XCTFail( @"Operation did not move to the cancelled state within the timeout: %@", error);
        }
    }];
}

/**
 *  Tests wether the operation correctly sends the "isCancelled" key value notification when used in a serial queue.
 */

- (void) testCanCancelOperationWithSerialQueue {
    NSOperation         *testOperation  = nil;
    NSOperationQueue    *queue          = nil;
    XCTestExpectation   *expectation    = nil;
    
    queue           = [[self class] serialQueueWithName:NSStringFromSelector(_cmd)];
    
    testOperation   = [self operationUnderTest];
    expectation     = [self keyValueObservingExpectationForObject:testOperation keyPath:@"isCancelled" handler:^BOOL(id observedObject, NSDictionary *change) {
        return [[observedObject valueForKeyPath:@"isCancelled"] boolValue];
    }];
    
    [queue setSuspended:YES];
    [queue addOperation:testOperation];
    
    [queue cancelAllOperations];
    [queue setSuspended:NO];
    [self waitForExpectationsWithTimeout:[self defaultTimeout] handler:^(NSError *error) {
        if ([[error domain] isEqualToString:XCTestErrorDomain]){
            XCTFail( @"Operation did not move to the cancelled state within the timeout: %@", error);
        }
    }];
}

@end
