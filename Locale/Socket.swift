//
//  Socket.swift
//  Locale
//
//  Created by Steven on 10/16/14.
//  Copyright (c) 2014 stevenschmatz. All rights reserved.
//

import Foundation

protocol SocketDelegate {
    func socket(socket: Socket, didChangeState state: Socket.State)
}

class Socket: NSObject, GCDAsyncSocketDelegate {
    
    let socket = GCDAsyncSocket()
    
    /*
    * ============
    * MARK: Socket
    * ============
    */
    
    let host: String
    let port: UInt16
    
    let separatorData = "\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    
    func connect() {
        
        var possibleConnectError: NSError?
        socket.connectToHost(host, onPort: port, withTimeout: 5.0, error: &possibleConnectError)
        
        if let error = possibleConnectError {
            println(error)
        }
        
        socket.readDataToData(separatorData, withTimeout: -1.0, tag: 0)
    }
    
    /*
    * ==============
    * MARK: Delegate
    * ==============
    */
    
    var delegate: SocketDelegate?
    
    /*
    * ====================
    * MARK: Initialization
    * ====================
    */
    
    init(host: String, port: UInt16) {
        
        self.host = host
        self.port = port
        
        super.init()
        
        socket.setDelegate(self, delegateQueue: dispatch_get_main_queue())
        
        connect()
    }
    
    /*
    * ===========
    * MARK: State
    * ===========
    */
    
    // Does not necessarily indicate when data comes in
    var state: State = .Connecting {
        didSet {
            if state != oldValue { delegate?.socket(self, didChangeState: state) }
        }
    }
    
    enum State {
        case Connecting     // Before first connection
        case Connected      // Normal
        case Disconnected   // Between subsequent connections, or if initial connection times out
    }
    
    /*
    * =====================
    * MARK: Socket delegate
    * =====================
    */
    
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        println("Connected to host!")
        self.state = .Connected
    }
    
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        var dataString = NSString(data: data, encoding: NSUTF8StringEncoding)
        print(dataString)
        socket.readDataToData(separatorData, withTimeout: -1.0, tag: 0)
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        println("Disconnected!")
        self.state = .Disconnected
        
        connect()
    }
    
}