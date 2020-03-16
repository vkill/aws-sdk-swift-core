//
//  AWSShape.swift
//  AWSSDKSwift
//
//  Created by Yuki Takei on 2017/04/12.
//
//

import struct Foundation.UUID
import class  Foundation.NSRegularExpression
import var    Foundation.NSNotFound
import func   Foundation.NSMakeRange

/// Protocol for the input and output objects for all AWS service commands. They need to be Codable so they can be serialized. They also need to provide details on how their container classes are coded when serializing XML.
public protocol AWSShape: XMLCodable {
    /// The path to the object that is included in the request/response body
    static var payloadPath: String? { get }
    /// The XML namespace for the object
    static var _xmlNamespace: String? { get }
    /// The array of members serialization helpers
    static var _encoding: [AWSMemberEncoding] { get }

    /// returns if a shape is valid. The checks for validity are defined by the AWS model files we get from http://github.com/aws/aws-sdk-go
    func validate(name: String) throws
}

extension AWSShape {
    public static var payloadPath: String? {
        return nil
    }

    public static var _xmlNamespace: String? {
        return nil
    }

    public static var _encoding: [AWSMemberEncoding] {
        return []
    }

    /// return member with provided name
    public static func getPayloadEncoding(for: String) -> (name: String?, raw: Bool)? {
        for member in _encoding {
            guard case .payload(let name, let payloadName, let raw) = member else { continue }
            if name == `for` {
                return (name: payloadName, raw: raw)
            }
        }
        return nil
    }

    /// return list of member variables serialized in the URL path
    public static var pathParams: [String: String] {
        var params: [String: String] = [:]
        for member in _encoding {
            guard case .uri(let name, let uri) = member else { continue }
            params[uri] = name
        }
        return params
    }

    /// return list of member variables serialized in the headers
    public static var headerParams: [String: String] {
        var params: [String: String] = [:]
        for member in _encoding {
            guard case .header(let name, let header) = member else { continue }
            params[header] = name
        }
        return params
    }

    /// return list of member variables serialized as query parameters
    public static var queryParams: [String: String] {
        var params: [String: String] = [:]
        for member in _encoding {
            guard case .query(let name, let query) = member else { continue }
            params[query] = name
        }
        return params
    }
}

/// Validation code to add to AWSShape
extension AWSShape {
    public func validate() throws {
        try validate(name: "\(type(of:self))")
    }

    /// stub validate function for all shapes
    public func validate(name: String) throws {
    }

    public func validate<T : BinaryInteger>(_ value: T, name: String, parent: String, min: T) throws {
        guard value >= min else { throw AWSClientError.validationError(message: "\(parent).\(name) (\(value)) is less than minimum allowed value \(min).") }
    }
    public func validate<T : BinaryInteger>(_ value: T, name: String, parent: String, max: T) throws {
        guard value <= max else { throw AWSClientError.validationError(message: "\(parent).\(name) (\(value)) is greater than the maximum allowed value \(max).") }
    }
    public func validate<T : FloatingPoint>(_ value: T, name: String, parent: String, min: T) throws {
        guard value >= min else { throw AWSClientError.validationError(message: "\(parent).\(name) (\(value)) is less than minimum allowed value \(min).") }
    }
    public func validate<T : FloatingPoint>(_ value: T, name: String, parent: String, max: T) throws {
        guard value <= max else { throw AWSClientError.validationError(message: "\(parent).\(name) (\(value)) is greater than the maximum allowed value \(max).") }
    }
    public func validate<T : Collection>(_ value: T, name: String, parent: String, min: Int) throws {
        guard value.count >= min else { throw AWSClientError.validationError(message: "Length of \(parent).\(name) (\(value.count)) is less than minimum allowed value \(min).") }
    }
    public func validate<T : Collection>(_ value: T, name: String, parent: String, max: Int) throws {
        guard value.count <= max else { throw AWSClientError.validationError(message: "Length of \(parent).\(name) (\(value.count)) is greater than the maximum allowed value \(max).") }
    }
    public func validate(_ value: String, name: String, parent: String, pattern: String) throws {
        let regularExpression = try NSRegularExpression(pattern: pattern, options: [])
        let firstMatch = regularExpression.rangeOfFirstMatch(in: value, options: .anchored, range: NSMakeRange(0, value.count))
        guard firstMatch.location != NSNotFound && firstMatch.length > 0 else { throw AWSClientError.validationError(message: "\(parent).\(name) (\(value)) does not match pattern \(pattern).") }
    }
    // validate optional values
    public func validate<T : BinaryInteger>(_ value: T?, name: String, parent: String, min: T) throws {
        guard let value = value else {return}
        try validate(value, name: name, parent: parent, min: min)
    }
    public func validate<T : BinaryInteger>(_ value: T?, name: String, parent: String, max: T) throws {
        guard let value = value else {return}
        try validate(value, name: name, parent: parent, max: max)
    }
    public func validate<T : FloatingPoint>(_ value: T?, name: String, parent: String, min: T) throws {
        guard let value = value else {return}
        try validate(value, name: name, parent: parent, min: min)
    }
    public func validate<T : FloatingPoint>(_ value: T?, name: String, parent: String, max: T) throws {
        guard let value = value else {return}
        try validate(value, name: name, parent: parent, max: max)
    }
    public func validate<T : Collection>(_ value: T?, name: String, parent: String, min: Int) throws {
        guard let value = value else {return}
        try validate(value, name: name, parent: parent, min: min)
    }
    public func validate<T : Collection>(_ value: T?, name: String, parent: String, max: Int) throws {
        guard let value = value else {return}
        try validate(value, name: name, parent: parent, max: max)
    }
    public func validate(_ value: String?, name: String, parent: String, pattern: String) throws {
        guard let value = value else {return}
        try validate(value, name: name, parent: parent, pattern: pattern)
    }
}

extension AWSShape {
    /// Return an idempotencyToken 
    public static func idempotencyToken() -> String {
        return UUID().uuidString
    }
}

/// extension to CollectionEncoding to produce the XML equivalent class
extension AWSMemberEncoding.ShapeEncoding {
    public var xmlEncoding : XMLContainerCoding? {
        switch self {
        case .default:
            return nil
        case .flatList:
            return .default
        case .list(let entry):
            return .array(entry: entry)
        case .flatMap(let key, let value):
            return .dictionary(entry: nil, key: key, value: value)
        case .map(let entry, let key, let value):
            return .dictionary(entry: entry, key: key, value: value)
        }
    }
}

/// extension to AWSShape that returns XML container encoding for members of it
extension AWSShape {
    /// return member for CodingKey
    public static func getEncoding(forKey: CodingKey) -> AWSMemberEncoding.ShapeEncoding? {
        for member in _encoding {
            guard case .collection(let key, let encoding) = member else { continue }
            if key == forKey.stringValue {
                return encoding
            }
        }
        return nil
    }

    public static func getXMLContainerCoding(for key: CodingKey) -> XMLContainerCoding? {
        return getEncoding(forKey: key)?.xmlEncoding
    }
}
