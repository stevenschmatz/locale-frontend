//
//  ChatStream.swift
//  Locale
//
//  Created by Steven on 10/15/14.
//  Copyright (c) 2014 stevenschmatz. All rights reserved.
//

import Foundation

class Connection : NSObject, NSStreamDelegate {
    
    // Server IP and port
    let serverAddress: CFString = "35.2.74.172"
    let serverPort: UInt32      = 8081
    
    // inputStream and outputStream control the TCP data flow
    // between the iOS client and server.
    private var inputStream : NSInputStream!
    private var outputStream: NSOutputStream!
    
    // EFFECTS: Creates a socket connection with the server.
    func initConnection() {
        println("Connecting...")
        
        // readStream and writeStream are used to create a 
        // socket with the host
        var readStream:     Unmanaged<CFReadStream>?
        var writeStream:    Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(nil, self.serverAddress,
            self.serverPort, &readStream, &writeStream)
        
        // declares that this class is reponsible for releasing
        // the result
        self.inputStream = readStream!.takeRetainedValue()
        self.outputStream = writeStream!.takeRetainedValue()
        
        self.inputStream.delegate = self
        self.outputStream.delegate = self
        
        self.inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(),
            forMode: NSDefaultRunLoopMode)
        self.outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(),
            forMode: NSDefaultRunLoopMode)
        
        self.inputStream.open()
        self.outputStream.open()
    }
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        println("\(eventCode)")
    }
}
