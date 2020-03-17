//
//  QueryEncoder.swift
//  AWSSDKSwift
//
//  Created by Adam Fowler on 2020/01/28.
//
//

/// The wrapper class for encoding Codable classes to Query dictionary
public class QueryEncoder {

    /// override container encoding and flatten all the containers (needed for EC2, which reports unflattened containers when they are flattened)
    open var flattenContainers : Bool = false

    /// Contextual user-provided information for use during encoding.
    open var userInfo: [CodingUserInfoKey : Any] = [:]
    
    /// Options set on the top-level encoder to pass down the encoding hierarchy.
    fileprivate struct _Options {
        let flattenContainers: Bool
        let userInfo: [CodingUserInfoKey : Any]
    }
    
    /// The options set on the top-level encoder.
    fileprivate var options: _Options {
        return _Options(flattenContainers: flattenContainers,
                        userInfo: userInfo)
    }
    
    public init() {}
    
    open func encode<T : Encodable>(_ value: T, name: String? = nil) throws -> [String: Any] {
        let encoder = _QueryEncoder(options: options)
        try value.encode(to: encoder)
        
        // encode generates a tree of dictionaries and arrays. We need to flatten this into a single dictionary with keys joined together
        return flatten(encoder.result)
    }
    
    /// Flatten dictionary and array tree into one dictionary
    /// - Parameter container: The root container
    fileprivate func flatten(_ container: _QueryEncoderKeyedContainer?) -> [String: Any] {
        var result: [String: Any] = [:]
        
        func flatten(dictionary: [String: Any], path: String) {
            for (key, value) in dictionary {
                switch value {
                case let keyed as _QueryEncoderKeyedContainer:
                    flatten(dictionary: keyed.values, path: "\(path)\(key).")
                case let unkeyed as _QueryEncoderUnkeyedContainer:
                    flatten(array: unkeyed.values, path: "\(path)\(key).")
                default:
                    result["\(path)\(key)"] = value
                }
            }
        }
        func flatten(array: [Any], path: String) {
            for iterator in array.enumerated() {
                switch iterator.element {
                case let keyed as _QueryEncoderKeyedContainer:
                    flatten(dictionary: keyed.values, path: "\(path)\(iterator.offset+1).")
                case let unkeyed as _QueryEncoderUnkeyedContainer:
                    flatten(array: unkeyed.values, path: "\(path)\(iterator.offset+1)")
                default:
                    result["\(path)\(iterator.offset+1)"] = iterator.element
                }
            }
        }
        if let container = container {
            flatten(dictionary: container.values, path: "")
        }
        return result
    }
}

/// class for holding a keyed container (dictionary). Need to encapsulate dictionary in class so we can be sure we are
/// editing the dictionary we push onto the stack
fileprivate class _QueryEncoderKeyedContainer {
    var values: [String: Any] = [:]

    func addChild(path: String, child: Any) {
        values[path] = child
    }
}

/// class for holding unkeyed container (array). Need to encapsulate array in class so we can be sure we are
/// editing the array we push onto the stack
fileprivate class _QueryEncoderUnkeyedContainer {
    var values: [Any] = []

    func addChild(_ child: Any) {
        values.append(child)
    }
}

/// storage for Query Encoder. Stores a stack of QueryEncoder containers, plus leaf objects
fileprivate struct _QueryEncoderStorage {
    /// the container stack
    private var containers : [Any] = []

    /// initializes self with no containers
    init() {}
    
    /// push a new container onto the storage
    mutating func pushKeyedContainer() -> _QueryEncoderKeyedContainer {
        let container = _QueryEncoderKeyedContainer()
        containers.append(container)
        return container
    }
    
    /// push a new container onto the storage
    mutating func pushUnkeyedContainer() -> _QueryEncoderUnkeyedContainer {
        let container = _QueryEncoderUnkeyedContainer()
        containers.append(container)
        return container
    }
    
    mutating func push(container: Any) {
        containers.append(container)
    }
    
    /// pop a container from the storage
    @discardableResult mutating func popContainer() -> Any {
        return containers.removeLast()
    }
}

/// Internal QueryEncoder class. Does all the heavy lifting
fileprivate class _QueryEncoder : Encoder {
    var codingPath: [CodingKey]

    /// the encoder's storage
    var storage : _QueryEncoderStorage

    /// options
    var options: QueryEncoder._Options

    /// resultant query array
    var result: _QueryEncoderKeyedContainer?

    /// Contextual user-provided information for use during encoding.
    public var userInfo: [CodingUserInfoKey : Any] {
        return self.options.userInfo
    }
    
    /// Initialization
    /// - Parameters:
    ///   - options: options
    ///   - containerCodingMapType: Container encoding for the top level object
    init(options: QueryEncoder._Options) {
        self.storage = _QueryEncoderStorage()
        self.options = options
        self.codingPath = []
        self.result = nil
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let newContainer = storage.pushKeyedContainer()
        if self.result == nil {
            self.result = newContainer
        }
        return KeyedEncodingContainer(KEC(referencing:self, container: newContainer))
    }
    
    struct KEC<Key: CodingKey> : KeyedEncodingContainerProtocol {
        var codingPath: [CodingKey] { return encoder.codingPath }
        let container: _QueryEncoderKeyedContainer
        let encoder: _QueryEncoder
        
        /// Initialization
        /// - Parameter referencing: encoder that created this
        init(referencing: _QueryEncoder, container: _QueryEncoderKeyedContainer) {
            self.encoder = referencing
            self.container = container
        }
        
        mutating func encode(_ value: Any, key: String) {
            container.values["\(key)"] = value
        }
        
        mutating func encodeNil(forKey key: Key) throws { encode("", key: key.stringValue) }
        mutating func encode(_ value: Bool, forKey key: Key) throws { encode(value, key: key.stringValue) }
        mutating func encode(_ value: String, forKey key: Key) throws { encode(value, key: key.stringValue) }
        mutating func encode(_ value: Double, forKey key: Key) throws { encode(value, key: key.stringValue) }
        mutating func encode(_ value: Float, forKey key: Key) throws { encode(value, key: key.stringValue) }
        mutating func encode(_ value: Int, forKey key: Key) throws { encode(value, key: key.stringValue) }
        mutating func encode(_ value: Int8, forKey key: Key) throws { encode(value, key: key.stringValue) }
        mutating func encode(_ value: Int16, forKey key: Key) throws { encode(value, key: key.stringValue) }
        mutating func encode(_ value: Int32, forKey key: Key) throws { encode(value, key: key.stringValue) }
        mutating func encode(_ value: Int64, forKey key: Key) throws { encode(value, key: key.stringValue) }
        mutating func encode(_ value: UInt, forKey key: Key) throws { encode(value, key: key.stringValue) }
        mutating func encode(_ value: UInt8, forKey key: Key) throws { encode(value, key: key.stringValue) }
        mutating func encode(_ value: UInt16, forKey key: Key) throws { encode(value, key: key.stringValue) }
        mutating func encode(_ value: UInt32, forKey key: Key) throws { encode(value, key: key.stringValue) }
        mutating func encode(_ value: UInt64, forKey key: Key) throws { encode(value, key: key.stringValue) }
        
        mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
            self.encoder.codingPath.append(key)
            defer { self.encoder.codingPath.removeLast() }

            let childContainer = try encoder.box(value)
            container.addChild(path: key.stringValue, child: childContainer)
        }
        
        mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            self.encoder.codingPath.append(key)
            defer { self.encoder.codingPath.removeLast() }

            let keyedContainer = _QueryEncoderKeyedContainer()
            container.addChild(path: key.stringValue, child: keyedContainer)
            
            let kec = KEC<NestedKey>(referencing: self.encoder, container: keyedContainer)
            return KeyedEncodingContainer(kec)
        }
        
        mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
            self.encoder.codingPath.append(key)
            defer { self.encoder.codingPath.removeLast() }
            
            let unkeyedContainer = _QueryEncoderUnkeyedContainer()
            container.addChild(path: key.stringValue, child: unkeyedContainer)
            
            return UKEC(referencing: self.encoder, container: unkeyedContainer)
        }
        
        mutating func superEncoder() -> Encoder {
            return encoder
        }
        
        mutating func superEncoder(forKey key: Key) -> Encoder {
            return encoder
        }
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        let container = storage.pushUnkeyedContainer()
        return UKEC(referencing: self, container: container)
    }
    
    struct UKEC : UnkeyedEncodingContainer {
        var codingPath: [CodingKey] { return encoder.codingPath }
        let container: _QueryEncoderUnkeyedContainer
        let encoder: _QueryEncoder
        var count: Int

        init(referencing: _QueryEncoder, container: _QueryEncoderUnkeyedContainer) {
            self.encoder = referencing
            self.container = container
            self.count = 0
        }

        mutating func encodeResult(_ value: Any) {
            count += 1
            container.addChild(value)
        }
        
        mutating func encodeNil() throws { encodeResult("") }
        mutating func encode(_ value: Bool) throws { encodeResult(value) }
        mutating func encode(_ value: String) throws { encodeResult(value) }
        mutating func encode(_ value: Double) throws { encodeResult(value) }
        mutating func encode(_ value: Float) throws { encodeResult(value) }
        mutating func encode(_ value: Int) throws { encodeResult(value) }
        mutating func encode(_ value: Int8) throws { encodeResult(value) }
        mutating func encode(_ value: Int16) throws { encodeResult(value) }
        mutating func encode(_ value: Int32) throws { encodeResult(value) }
        mutating func encode(_ value: Int64) throws { encodeResult(value) }
        mutating func encode(_ value: UInt) throws { encodeResult(value) }
        mutating func encode(_ value: UInt8) throws { encodeResult(value) }
        mutating func encode(_ value: UInt16) throws { encodeResult(value) }
        mutating func encode(_ value: UInt32) throws { encodeResult(value) }
        mutating func encode(_ value: UInt64) throws { encodeResult(value) }
        
        mutating func encode<T: Encodable>(_ value: T) throws  {
            count += 1

            self.encoder.codingPath.append(_QueryKey(index: count))
            defer { self.encoder.codingPath.removeLast() }
            
            let childContainer = try encoder.box(value)
            container.addChild(childContainer)
        }
        
        mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            count += 1

            self.encoder.codingPath.append(_QueryKey(index: count))
            defer { self.encoder.codingPath.removeLast() }

            let keyedContainer = _QueryEncoderKeyedContainer()
            container.addChild(keyedContainer)

            let kec = KEC<NestedKey>(referencing: self.encoder, container: keyedContainer)
            return KeyedEncodingContainer(kec)
        }
        
        mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
            count += 1

            let unkeyedContainer = _QueryEncoderUnkeyedContainer()
            container.addChild(unkeyedContainer)
            
            return UKEC(referencing: self.encoder, container: unkeyedContainer)
        }
        
        mutating func superEncoder() -> Encoder {
            return encoder
        }
    }
}

extension _QueryEncoder : SingleValueEncodingContainer {
    func encodeResult(_ value: Any) {
        storage.push(container: value)
    }
    
    func encodeNil() throws {
        encodeResult("")
    }
    
    func encode(_ value: Bool) throws { encodeResult(value)}
    func encode(_ value: String) throws { encodeResult(value)}
    func encode(_ value: Double) throws { encodeResult(value)}
    func encode(_ value: Float) throws { encodeResult(value)}
    func encode(_ value: Int) throws { encodeResult(value)}
    func encode(_ value: Int8) throws { encodeResult(value)}
    func encode(_ value: Int16) throws { encodeResult(value)}
    func encode(_ value: Int32) throws { encodeResult(value)}
    func encode(_ value: Int64) throws { encodeResult(value)}
    func encode(_ value: UInt) throws { encodeResult(value)}
    func encode(_ value: UInt8) throws { encodeResult(value)}
    func encode(_ value: UInt16) throws { encodeResult(value)}
    func encode(_ value: UInt32) throws { encodeResult(value)}
    func encode(_ value: UInt64) throws { encodeResult(value)}
    
    func encode<T: Encodable>(_ value: T) throws {
        try value.encode(to: self)
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }
}

extension _QueryEncoder {
    func box(_ value: Encodable) throws -> Any {
        try value.encode(to: self)
        return storage.popContainer()
    }
}

//===----------------------------------------------------------------------===//
// Shared Key Types
//===----------------------------------------------------------------------===//

fileprivate struct _QueryKey : CodingKey {
    public var stringValue: String
    public var intValue: Int?
    
    public init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    public init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
    
    public init(stringValue: String, intValue: Int?) {
        self.stringValue = stringValue
        self.intValue = intValue
    }
    
    fileprivate init(index: Int) {
        self.stringValue = "\(index)"
        self.intValue = index
    }
    
    fileprivate static let `super` = _QueryKey(stringValue: "super")!
}

