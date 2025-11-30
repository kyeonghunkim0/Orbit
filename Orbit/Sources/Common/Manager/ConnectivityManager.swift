//
//  ConnectivityManager.swift
//  Orbit
//
//  Created by Orbit Agent on 11/30/25.
//

import Foundation
import WatchConnectivity
import Combine

struct ReceivedTransaction: Equatable {
    let amount: Double
    let category: String
    let type: String
    let memo: String
    let date: Date
}

struct WatchCategory: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var type: String
}

final class ConnectivityManager: NSObject, ObservableObject {
    static let shared = ConnectivityManager()
    
    @Published var receivedTransaction: ReceivedTransaction?
    @Published var watchCategories: [WatchCategory] = []
    
    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
        
        // Load cached categories
        if let data = UserDefaults.standard.data(forKey: "watchCategories"),
           let categories = try? JSONDecoder().decode([WatchCategory].self, from: data) {
            self.watchCategories = categories
        }
    }
    
    func sendTransaction(amount: Double, category: String, type: String, memo: String, date: Date) {
        guard WCSession.default.activationState == .activated else {
            print("WCSession is not activated")
            return
        }
        
        let data: [String: Any] = [
            "amount": amount,
            "category": category,
            "type": type,
            "memo": memo,
            "date": date
        ]
        
        WCSession.default.transferUserInfo(data)
    }
    
    func sendCategories(_ categories: [WatchCategory]) {
        guard WCSession.default.activationState == .activated else { return }
        
        if let data = try? JSONEncoder().encode(categories) {
            let message = ["categories": data]
            WCSession.default.transferUserInfo(message)
        }
    }
}

extension ConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }
    
    // iOS only methods
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        // Handle Transaction
        if let amount = userInfo["amount"] as? Double,
           let category = userInfo["category"] as? String,
           let type = userInfo["type"] as? String,
           let memo = userInfo["memo"] as? String,
           let date = userInfo["date"] as? Date {
            
            let transaction = ReceivedTransaction(
                amount: amount,
                category: category,
                type: type,
                memo: memo,
                date: date
            )
            
            DispatchQueue.main.async {
                self.receivedTransaction = transaction
            }
        }
        
        // Handle Categories
        if let categoryData = userInfo["categories"] as? Data,
           let categories = try? JSONDecoder().decode([WatchCategory].self, from: categoryData) {
            
            DispatchQueue.main.async {
                self.watchCategories = categories
                // Cache categories
                if let encoded = try? JSONEncoder().encode(categories) {
                    UserDefaults.standard.set(encoded, forKey: "watchCategories")
                }
            }
        }
    }
}
