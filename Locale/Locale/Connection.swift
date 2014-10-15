//
//  ChatStream.swift
//  Locale
//
//  Created by Steven on 10/15/14.
//  Copyright (c) 2014 stevenschmatz. All rights reserved.
//

import Foundation

// class Connection is used to manage a TCP connection with the server.

class Connection : NSObject, NSStreamDelegate {
    
    /*
    * =====================
    * CONNECTION DATA MODEL
    * =====================
    */
    
    // Server IP and port
    private let serverAddress: CFString = "35.2.74.172"
    private let serverPort: UInt32      = 8081
    
    // inputStream and outputStream control the TCP data flow
    // between the iOS client and server.
    private var inputStream : NSInputStream!
    private var outputStream: NSOutputStream!
    
    /*
    * =========================
    * CONNECTION INITIALIZATION
    * =========================
    */
    
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
    
    /*
    * =================
    * RUNTIME FUNCTIONS
    * =================
    */
    
    // MODIFIES:    aStream
    // EFFECTS:     Handles stream events, such as detecting if a message is
    //              received, if a connection was closed, or if an error occurred.
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch (eventCode) {
            
        case NSStreamEvent.OpenCompleted:
            handleStreamOpened()
            break;
            
            // Reading from server
        case NSStreamEvent.HasBytesAvailable:
            handleHasBytesAvailable(aStream)
            break;
            
        case NSStreamEvent.ErrorOccurred:
            handleStreamErrorOccured()
            break;
            
        case NSStreamEvent.EndEncountered:
            handleStreamEndEncountered(aStream)
            break;
            
        default:
            break;
            
        }
    }
    
    /*
    * ========================
    * RUNTIME HELPER FUNCTIONS
    * ========================
    */
    
    // EFFECTS: Handles the event where a stream was opened.
    private func handleStreamOpened() {
        println("Stream opened!")
    }
    
    // REQUIRES:    aStream be a reference to an open NSStream
    // MODIFIES:    aStream
    // EFFECTS:     Handles the event where a stream reads bytes
    //              from the server.
    private func handleHasBytesAvailable(aStream: NSStream) {
        if (aStream == inputStream) {
            
            let BUFFER_LENGTH = 1024
            
            var output = ""
            
            var readBuffer = UnsafeMutablePointer<UInt8>.alloc(BUFFER_LENGTH + 1)
            var len = inputStream.read(readBuffer, maxLength: BUFFER_LENGTH)
            
            // Ensures that bytes were read from server
            if (len > 0) {
                var buf = UnsafeMutablePointer<CChar>(readBuffer)
                
                buf[BUFFER_LENGTH] = 0 // null-terminated, http://stackoverflow.com/questions/25840276/read-bytes-into-a-swift-string
                
                if let utf8String = String.fromCString(buf) {
                    output = utf8String
                }
                
                readBuffer.dealloc(BUFFER_LENGTH)
            }
            
            // Custom override for message received here
            if (output != "") {
                println("The server said \"\(output)\"")
            }
        }
    }
    
    // EFFECTS: Handles the event where an error in stream
    //          reading occurred.
    private func handleStreamErrorOccured() {
        println("Cannot connect to host!")
    }
    
    // REQUIRES:    aStream be a reference to an open NSStream
    // MODIFIES:    aStream
    // EFFECTS:     Handles the event where a stream is closed.
    private func handleStreamEndEncountered(aStream: NSStream) {
        aStream.close()
        aStream.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
    }
}
