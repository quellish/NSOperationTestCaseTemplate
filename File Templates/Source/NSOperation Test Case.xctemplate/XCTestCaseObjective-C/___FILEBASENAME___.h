//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//
//  Original by Dan Zinngrabe on 6/15/15.
//

@import Foundation;
@import XCTest;

/**
 *  @class NSOperationTestCase
 *  @description `NSOperation` objects are expected to implement logic and state transitions
 *  that allow them to be safely used with `NSOperationQueue` instances. This 
 *  test case exercises the behavior expected of `NSOperation` instances.
 *
 *  @see `NSOperation`
 */

@interface ___FILEBASENAMEASIDENTIFIER___ : XCTestCase

/**
 *  The NSOperation instance to be tested.
 *  Test cases must implement this method to return an instance of
 *  the custom NSOperation class initialized with test values.
 *
 *  @return The NSOperation instance to be tested.
 */

- (NSOperation *) operationUnderTest;

/**
 *  The default timeout for asynchronous tests.
 *  Test cases may override this method as appropriate.
 *
 *  @return The default timeout
 */

- (NSTimeInterval) defaultTimeout;

/**
 *  A shared static serial queue.
 *
 *  @return A serial queue
 */

+ (NSOperationQueue *) sharedSerialQueue;

/**
 *  A shared static concurrent queue.
 *
 *  @return A concurrent queue
 */

+ (NSOperationQueue *) sharedConcurrentQueue;

/**
 *  Returns a serial queue created with the name provided.
 *
 *  @param name The name of the queue.
 *
 *  @return An `NSOperationQueue` with the name provided and a maxConcurrentOperationCount of 1.
 */

+ (NSOperationQueue *) serialQueueWithName:(NSString *)name;

/**
 *  Returns a concurrent queue created with the name provided.
 *
 *  @param name The name of the queue.
 *
 *  @return An `NSOperationQueue` with the name provided.
 */

+ (NSOperationQueue *) concurrentQueueWithName:(NSString *)name;

@end
