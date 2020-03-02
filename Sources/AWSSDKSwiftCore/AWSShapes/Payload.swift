//
//  Payload.swift
//  AWSSDKCore
//
//  Created by Adam Fowler on 2020/03/01.
//
import struct Foundation.Data
import NIO

public enum AWSPayload: Codable {
    case data(Data)
    case byteBuffer(ByteBuffer)
    case empty
    
    public init() {
        self = .empty
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
