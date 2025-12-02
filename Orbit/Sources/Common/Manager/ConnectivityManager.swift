//
//  ConnectivityManager.swift
//  Orbit
//
//  Created by Orbit Agent on 11/30/25.
//

import Foundation
import WatchConnectivity
import Combine

struct TransactionSummary: Codable, Equatable {
    var todayExpense: Double
    var todayIncome: Double
    var weekExpense: Double
    var weekIncome: Double
    var monthExpense: Double
    var monthIncome: Double
    var yearExpense: Double
    var yearIncome: Double
}

final class ConnectivityManager: NSObject, ObservableObject {
    static let shared = ConnectivityManager()
    
    @Published var receivedSummary: TransactionSummary?
    @Published var isSessionActivated: Bool = false
    
    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
        
        // Load cached summary
        if let data = UserDefaults.standard.data(forKey: "watchSummary"),
           let summary = try? JSONDecoder().decode(TransactionSummary.self, from: data) {
            self.receivedSummary = summary
        }
    }
    
    func sendSummary(_ summary: TransactionSummary) {
        guard WCSession.default.activationState == .activated else {
            print("Cannot send summary: WCSession not activated")
            return
        }
        
        print("Sending summary: \(summary)")
        
        if let data = try? JSONEncoder().encode(summary) {
            let message = ["summary": data]
            
            // 1. Use Application Context for background updates (replaces old data)
            do {
                try WCSession.default.updateApplicationContext(message)
                print("Updated Application Context")
            } catch {
                print("Error updating application context: \(error)")
            }
            
            // 2. Use sendMessage for immediate foreground updates if reachable
            if WCSession.default.isReachable {
                WCSession.default.sendMessage(message, replyHandler: nil) { error in
                    print("Error sending message: \(error)")
                }
                print("Sent message to Watch")
            } else {
                print("Watch is not reachable for sendMessage")
            }
        }
    }
}

extension ConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isSessionActivated = activationState == .activated
        }
        
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif
    
    // Handle Application Context (Background)
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("didReceiveApplicationContext: \(applicationContext)")
        handleReceivedData(applicationContext)
    }
    
    // Handle Message (Foreground)
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("didReceiveMessage: \(message)")
        handleReceivedData(message)
    }
    
    // Handle User Info (Legacy/Queue)
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("didReceiveUserInfo: \(userInfo)")
        handleReceivedData(userInfo)
    }
    
    private func handleReceivedData(_ userInfo: [String: Any]) {
        print("Handling received data...")
        
        // Handle Summary
        if let summaryData = userInfo["summary"] as? Data {
            print("Found summary data, attempting to decode...")
            do {
                let summary = try JSONDecoder().decode(TransactionSummary.self, from: summaryData)
                print("Successfully decoded summary: \(summary)")
                
                DispatchQueue.main.async {
                    self.receivedSummary = summary
                    if let encoded = try? JSONEncoder().encode(summary) {
                        UserDefaults.standard.set(encoded, forKey: "watchSummary")
                    }
                }
            } catch {
                print("Failed to decode summary: \(error)")
            }
        } else {
            print("No summary data found in userInfo")
        }
    }
}
