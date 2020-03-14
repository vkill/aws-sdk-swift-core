//
//  Payload.swift
//  AWSSDKCore
//
//  Created by Adam Fowler on 2020/03/01.
//
import struct Foundation.Data
import NIO

public enum AWSPayload: Codable {
    case byteBuffer(ByteBuffer)
    case empty
    
    public init() {
        self = .empty
    }
    
    public static func data(_ data: Data) -> Self {
        var byteBuffer = ByteBufferAllocator().buffer(capacity: data.count)
        byteBuffer.writeBytes(data)
        return .byteBuffer(byteBuffer)
    }
    
    public static func string(_ string: String) -> Self {
        var byteBuffer = ByteBufferAllocator().buffer(capacity: string.utf8.count)
        byteBuffer.writeString(string)
        return .byteBuffer(byteBuffer)
    }
    
    // AWSPayload has to comform to Codable so I can add it to AWSShape objects (which conform to Codable). But we don't want the
    // Encoder/Decoder ever to process a AWSPayload
    public init(from decoder: Decoder) throws {
        preconditionFailure("Cannot decode an AWSPayload")
    }
    
    public func encode(to encoder: Encoder) throws {
        preconditionFailure("Cannot encode an AWSPayload")
    }
}
