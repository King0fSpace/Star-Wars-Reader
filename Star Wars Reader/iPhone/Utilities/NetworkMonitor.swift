//
//  NetworkMonitor.swift
//  Star Wars Reader
//
//  Created by Long Le on 2/28/23.
//

import Network

protocol NetworkMonitorDelegate: AnyObject {
    func networkMonitorDidChangeConnectionStatus(_ isConnected: Bool)
}

class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    var isConnected: Bool = false {
        didSet {
            if isConnected != oldValue {
                delegate?.networkMonitorDidChangeConnectionStatus(isConnected)
            }
        }
    }
    
    weak var delegate: NetworkMonitorDelegate?
    
    init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
    }
    
    deinit {
        monitor.cancel()
    }
    
    func addDelegate(_ delegate: NetworkMonitorDelegate) {
        self.delegate = delegate
    }
    
    func removeDelegate(_ delegate: NetworkMonitorDelegate) {
        self.delegate = nil
    }
}


