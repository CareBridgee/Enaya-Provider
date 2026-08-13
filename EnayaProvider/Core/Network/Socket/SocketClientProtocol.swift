//
//  SocketClientProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 07/08/2026.
//


import Foundation

protocol SocketClientProtocol: AnyObject {
    var isConnected: Bool { get }

    func connect()
    func disconnect()
    func subscribe(to destination: String)
    func unsubscribe(from destination: String)
    func send(to destination: String, headers: [String: String], body: String)
    var onConnectedListeners: [String: () -> Void] { get set }
        var onDisconnectedListeners: [String: () -> Void] { get set }
        var onMessageReceivedListeners: [String: (_ destination: String, _ body: String) -> Void] { get set }
        var onErrorListeners: [String: (_ description: String) -> Void] { get set }
}
