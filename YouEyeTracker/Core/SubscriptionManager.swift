//
//  SubscriptionManager.swift
//  YouEyeTracker
//
//  Created on 9/28/19.
//  Copyright © 2019 Eric Reedy. All rights reserved.
//

import Foundation

// MARK: - Setup -
extension YouEyeTracker {
    
    ///
    /// Maintains an array of weak object wrappers.  Sweeps any null weak wrappers away every 10 seconds.
    ///
    class SubscriptionManager<T: AnyObject> {
        
        ///
        /// Used to wrap weak generic references and nothing more.
        ///
        class SubscriberWrapper<T: AnyObject> {
            weak var subscriber: T?
            init(subscriber: T) { self.subscriber = subscriber }
        }
        
        private(set) var subscribers : [SubscriberWrapper<T>] = []
        private var subscriptionCleanupTimer : Timer?
        let cleanupTimerInterval: TimeInterval = 5
        
        init() {
            // Setting up a periodic weak sweep timer
            subscriptionCleanupTimer = .scheduledTimer(withTimeInterval: cleanupTimerInterval, repeats: true, block: { [weak self] _ in
                self?.compact()
            })
        }
        
        deinit { onDeinit() }
        private func onDeinit() {
            if let subscriptionCleanupTimer = subscriptionCleanupTimer {
                subscriptionCleanupTimer.invalidate()
                self.subscriptionCleanupTimer = nil
            }
            subscribers.removeAll()
        }
    }
}

// MARK: - Subscription Management -
extension YouEyeTracker.SubscriptionManager {
        
    /// This allows conforming classes to subscribe to YouEyeTracker for protocol-defined callbacks
    ///
    func subscribe(_ subscriber: T) {
        compact()
        subscribers.append(.init(subscriber: subscriber))
    }
    
    /// Removes any null weak wrappers from the subscribers array.
    ///
    private func compact() {
        subscribers.removeAll(where: { $0.subscriber == nil })
    }
}

#if DEBUG

extension YouEyeTracker.SubscriptionManager {
    
    var test_subscriptionCleanupTimer : Timer? { return subscriptionCleanupTimer }
    
    func test_compact() {
        compact()
    }
    
    func test_onDeinit() {
        onDeinit()
    }
}

#endif
