//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//
//  Original by Dan Zinngrabe on 1/27/16.
//

import XCTest

/**
    `NSOperation` objects are expected to implement logic and state transitions that allow them to be safely used with `NSOperationQueue` instances. This test case exercises the behavior expected of `NSOperation` instances.
 
    - SeeAlso: `NSOperation`
 */

public class ___FILEBASENAMEASIDENTIFIER___: XCTestCase {
    
 /// A shared static serial queue used by some tests.
    
    static var sharedSerialQueue:NSOperationQueue? = {
        var result:NSOperationQueue?

        result = ___FILEBASENAMEASIDENTIFIER___.serialQueueWithName(_stdlib_getDemangledTypeName(self))
        return result
    }()

 /// A shared static concurrent queue used by some tests.
    
    static var concurrentSerialQueue:NSOperationQueue? = {
        var result:NSOperationQueue?
        
        result =  ___FILEBASENAMEASIDENTIFIER___.concurrentQueueWithName(_stdlib_getDemangledTypeName(self))
        return result
    }()

    // MARK: - Test Support
    
    /**
        The NSOperation instance to be tested.
    
        **Important** Test cases must implement this method to return an instance of the custom NSOperation class initialized with test values.
    
    - returns: The operation to test
    */
    
    public func operationUnderTest() -> NSOperation {
        fatalError("Function must be overridden")
    }
    
    /**
     *  The default timeout for asynchronous tests.
     *  Test cases may override this method as appropriate.
     
     - returns: The default timeout
     */
    
    public func defaultTimeout() -> NSTimeInterval {
        var result:NSTimeInterval  = 10
        
        #if (arch(arm) || arch(arm64)) && (os(iOS) || os(watchOS) || os(tvOS))
            result = 30
        #endif
            
        return result
    }
    
    /**
     Returns a serial queue created with the name provided.
     
     - parameter name: The name of the queue.
     
     - returns: An `NSOperationQueue` with the name provided and a maxConcurrentOperationCount of 1.
     */
    
    public static func serialQueueWithName(name:String) -> NSOperationQueue {
        let result:NSOperationQueue = self.concurrentQueueWithName(name)
        
        result.maxConcurrentOperationCount = 1
        return result
    }
    
    /**
     Returns a concurrent queue created with the name provided.
     
     - parameter name: The name of the queue.
     
     - returns: An `NSOperationQueue` with the name provided.
     */
    
    public static func concurrentQueueWithName(name:String) -> NSOperationQueue {
        let result:NSOperationQueue = NSOperationQueue()
        
        result.name = name
        return result
    }

    // MARK: - Tests
    
    /**
      Tests wether the operation class is actually a subclass of NSOperation.
    */
    
    func testClassIsSubclassOfNSOperation() {
        XCTAssertTrue(self.operationUnderTest().isKindOfClass(NSOperation.self), "Test class is not a subclass of NSOperation")
    }
    
    /**
      Tests wether upon completion the operation invokes the completion block when it is used in a serial queue.
    */
    
    func testCanExecuteCompletionBlockWithSerialQueue() {
        let testOperation:NSOperation       = self.operationUnderTest();
        let queue:NSOperationQueue          = self.dynamicType.serialQueueWithName(__FUNCTION__)
        let expectation:XCTestExpectation   = expectationWithDescription(__FUNCTION__)
    
        
        testOperation.completionBlock = {
            expectation.fulfill()
        }
        queue.suspended = true
        queue.addOperation(testOperation)
        queue.suspended = false
        
        self.waitForExpectationsWithTimeout(self.defaultTimeout()) { error -> Void in
            if let testError = error {
                if (testError.domain == XCTestErrorDomain){
                    XCTFail( "The operation completion block did not execute within the timeout: \(error)");
                }
            }
        }    

    }
    
    /**
       Tests wether upon completion the operation invokes the completion block when it is used in a concurrent queue.
     */
    
    func testCanExecuteCompletionBlockWithConcurrentQueue() {
        let testOperation:NSOperation       = self.operationUnderTest();
        let queue:NSOperationQueue          = self.dynamicType.concurrentQueueWithName(__FUNCTION__)
        let expectation:XCTestExpectation   = expectationWithDescription(__FUNCTION__)
        
        
        testOperation.completionBlock = {
            expectation.fulfill()
        }
        queue.suspended = true
        queue.addOperation(testOperation)
        queue.suspended = false
        
        self.waitForExpectationsWithTimeout(self.defaultTimeout()) { error -> Void in
            if let testError = error {
                if (testError.domain == XCTestErrorDomain){
                    XCTFail( "The operation completion block did not execute within the timeout: \(error)");
                }
            }
        }
        
    }
    
    /**
      Tests wether the operation can be executed with a dependent operation when it is used in a serial queue.
    */
    
    func testCanExecuteDependentOperationWithSerialQueue() {
        let testOperation:NSOperation       = self.operationUnderTest();
        let queue:NSOperationQueue          = self.dynamicType.serialQueueWithName(__FUNCTION__)
        let expectation:XCTestExpectation   = expectationWithDescription(__FUNCTION__)
        let dependant:NSOperation           = NSBlockOperation { () -> Void in
            expectation.fulfill()
        }
        
        testOperation.addDependency(dependant)
        queue.suspended = true
        queue.addOperation(testOperation)
        queue.addOperation(dependant)
        queue.suspended = false
        
        self.waitForExpectationsWithTimeout(self.defaultTimeout()) { error -> Void in
            if let testError = error {
                if (testError.domain == XCTestErrorDomain){
                    XCTFail( "The operation dependency did not execute within the timeout: \(error)");
                }
            }
        }
    }
    
    /**
       Tests wether the operation can be executed with a dependent operation when it is used in a concurrent queue.
     */
    
    func testCanExecuteDependentOperationWithConcurrentQueue() {
        let testOperation:NSOperation       = self.operationUnderTest();
        let queue:NSOperationQueue          = self.dynamicType.concurrentQueueWithName(__FUNCTION__)
        let expectation:XCTestExpectation   = expectationWithDescription(__FUNCTION__)
        let dependant:NSOperation           = NSBlockOperation { () -> Void in
            expectation.fulfill()
        }
        
        testOperation.addDependency(dependant)
        queue.suspended = true
        queue.addOperation(testOperation)
        queue.addOperation(dependant)
        queue.suspended = false
        
        self.waitForExpectationsWithTimeout(self.defaultTimeout()) { error -> Void in
            if let testError = error {
                if (testError.domain == XCTestErrorDomain){
                    XCTFail( "The operation dependency did not execute within the timeout: \(error)");
                }
            }
        }
    }
    
    /**
      Tests wether the operation correctly sends the "isCancelled" key value notification when used in a concurrent queue.
    */
    
    func testCanCancelOperationWithSerialQueue() {
        let testOperation:NSOperation       = self.operationUnderTest();
        let queue:NSOperationQueue          = self.dynamicType.serialQueueWithName(__FUNCTION__)
        var expectation:XCTestExpectation?  = keyValueObservingExpectationForObject(testOperation, keyPath: "isCancelled", expectedValue: true)
        
        queue.suspended = true
        queue.addOperation(testOperation)
        queue.cancelAllOperations()
        queue.suspended = false
        
        self.waitForExpectationsWithTimeout(self.defaultTimeout()) { error -> Void in
            if let testError = error {
                if (testError.domain == XCTestErrorDomain){
                    XCTFail( "Operation did not move to the cancelled state within the timeout: \(error)");
                }
            }
            
            if (expectation != nil){
                expectation = nil
            }
        }
    }
    
    /**
       Tests wether the operation correctly sends the "isCancelled" key value notification when used in a concurrent queue.
     */
    
    func testCanCancelOperationWithConcurrentQueue() {
        let testOperation:NSOperation       = self.operationUnderTest();
        let queue:NSOperationQueue          = self.dynamicType.concurrentQueueWithName(__FUNCTION__)
        var expectation:XCTestExpectation?  = keyValueObservingExpectationForObject(testOperation, keyPath: "isCancelled", expectedValue: true)
        
        queue.suspended = true
        queue.addOperation(testOperation)
        queue.cancelAllOperations()
        queue.suspended = false
        
        self.waitForExpectationsWithTimeout(self.defaultTimeout()) { error -> Void in
            if let testError = error {
                if (testError.domain == XCTestErrorDomain){
                    XCTFail( "Operation did not move to the cancelled state within the timeout: \(error)");
                }
            }
            
            if (expectation != nil){
                expectation = nil
            }

        }
    }
}