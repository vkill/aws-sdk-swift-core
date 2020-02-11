//
//  PerformanceTests.swift
//  AWSSDKSwiftCoreTests
//
//  Created by Adam Fowler on 2018/10/13.
//
//

import XCTest
import NIO
import NIOHTTP1
import AsyncHTTPClient
@testable import AWSSDKSwiftCore

struct HeaderRequest: AWSShape {
    static var _members: [AWSShapeMember] = [
        AWSShapeMember(label: "Header1", location: .header(locationName: "Header1"), required: true, type: .string),
        AWSShapeMember(label: "Header2", location: .header(locationName: "Header2"), required: true, type: .string),
        AWSShapeMember(label: "Header3", location: .header(locationName: "Header3"), required: true, type: .string),
        AWSShapeMember(label: "Header4", location: .header(locationName: "Header4"), required: true, type: .timestamp)
    ]

    let header1: String
    let header2: String
    let header3: String
    let header4: TimeStamp
}

struct StandardRequest: AWSShape {
    static var _members: [AWSShapeMember] = [
        AWSShapeMember(label: "item1", location: .body(locationName: "item1"), required: true, type: .string),
        AWSShapeMember(label: "item2", location: .body(locationName: "item2"), required: true, type: .integer),
        AWSShapeMember(label: "item3", location: .body(locationName: "item3"), required: true, type: .double),
        AWSShapeMember(label: "item4", location: .body(locationName: "item4"), required: true, type: .timestamp),
        AWSShapeMember(label: "item5", location: .body(locationName: "item5"), required: true, type: .list)
    ]

    let item1: String
    let item2: Int
    let item3: Double
    let item4: TimeStamp
    let item5: [Int]
}

struct PayloadRequest: AWSShape {
    public static let payloadPath: String? = "payload"
    static var _members: [AWSShapeMember] = [
        AWSShapeMember(label: "payload", location: .body(locationName: "payload"), required: true, type: .structure)
    ]

    let payload: StandardRequest
}

struct MixedRequest: AWSShape {
    static var _members: [AWSShapeMember] = [
        AWSShapeMember(label: "item1", location: .header(locationName: "item1"), required: true, type: .string),
        AWSShapeMember(label: "item2", location: .body(locationName: "item2"), required: true, type: .integer),
        AWSShapeMember(label: "item3", location: .body(locationName: "item3"), required: true, type: .double),
        AWSShapeMember(label: "item4", location: .body(locationName: "item4"), required: true, type: .timestamp)
    ]

    let item1: String
    let item2: Int
    let item3: Double
    let item4: TimeStamp
}


class PerformanceTests: XCTestCase {

    func testHeaderRequest() {
        let client = AWSClient(
            region: .useast1,
            service:"Test",
            serviceProtocol: ServiceProtocol(type: .restxml),
            apiVersion: "1.0",
            httpClientProvider: .useAWSClientShared
        )
        let date = Date()
        let request = HeaderRequest(header1: "Header1", header2: "Header2", header3: "Header3", header4: TimeStamp(date))
        measure {
            do {
                for _ in 0..<1000 {
                    _ = try client.createAWSRequest(operation: "Test", path: "/", httpMethod: "POST", input: request)
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testXMLRequest() {
        let client = AWSClient(
            region: .useast1,
            service:"Test",
            serviceProtocol: ServiceProtocol(type: .restxml),
            apiVersion: "1.0",
            httpClientProvider: .useAWSClientShared
        )
        let date = Date()
        let request = StandardRequest(item1: "item1", item2: 45, item3: 3.14, item4: TimeStamp(date), item5: [1,2,3,4,5])
        measure {
            do {
                for _ in 0..<1000 {
                    _ = try client.createAWSRequest(operation: "Test", path: "/", httpMethod: "POST", input: request)
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testXMLPayloadRequest() {
        let client = AWSClient(
            region: .useast1,
            service:"Test",
            serviceProtocol: ServiceProtocol(type: .restxml),
            apiVersion: "1.0",
            httpClientProvider: .useAWSClientShared
        )
        let date = Date()
        let request = PayloadRequest(payload: StandardRequest(item1: "item1", item2: 45, item3: 3.14, item4: TimeStamp(date), item5: [1,2,3,4,5]))
        measure {
            do {
                for _ in 0..<1000 {
                    _ = try client.createAWSRequest(operation: "Test", path: "/", httpMethod: "POST", input: request)
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testJSONRequest() {
        let client = AWSClient(
            region: .useast1,
            service:"Test",
            serviceProtocol: ServiceProtocol(type: .restjson),
            apiVersion: "1.0",
            httpClientProvider: .useAWSClientShared
        )
        let date = Date()
        let request = StandardRequest(item1: "item1", item2: 45, item3: 3.14, item4: TimeStamp(date), item5: [1,2,3,4,5])
        measure {
            do {
                for _ in 0..<1000 {
                    _ = try client.createAWSRequest(operation: "Test", path: "/", httpMethod: "POST", input: request)
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testJSONPayloadRequest() {
        let client = AWSClient(
            region: .useast1,
            service:"Test",
            serviceProtocol: ServiceProtocol(type: .restjson),
            apiVersion: "1.0",
            httpClientProvider: .useAWSClientShared
        )
        let date = Date()
        let request = PayloadRequest(payload: StandardRequest(item1: "item1", item2: 45, item3: 3.14, item4: TimeStamp(date), item5: [1,2,3,4,5]))
        measure {
            do {
                for _ in 0..<1000 {
                    _ = try client.createAWSRequest(operation: "Test", path: "/", httpMethod: "POST", input: request)
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testQueryRequest() {
        let client = AWSClient(
            region: .useast1,
            service:"Test",
            serviceProtocol: ServiceProtocol(type: .query),
            apiVersion: "1.0",
            httpClientProvider: .useAWSClientShared
        )
        let date = Date()
        let request = StandardRequest(item1: "item1", item2: 45, item3: 3.14, item4: TimeStamp(date), item5: [1,2,3,4,5])
        measure {
            do {
                for _ in 0..<1000 {
                    _ = try client.createAWSRequest(operation: "Test", path: "/", httpMethod: "POST", input: request)
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testUnsignedRequest() {
        let client = AWSClient(
            accessKeyId: "",
            secretAccessKey: "",
            region: .useast1,
            service:"Test",
            serviceProtocol: ServiceProtocol(type: .json),
            apiVersion: "1.0",
            httpClientProvider: .useAWSClientShared
        )
        let awsRequest = try! client.createAWSRequest(operation: "Test", path: "/", httpMethod: "GET")
        let signer = try! client.signer.wait()
        measure {
            for _ in 0..<1000 {
                _ = awsRequest.createHTTPRequest(signer: signer)
            }
        }
    }

    func testSignedURLRequest() {
        let client = AWSClient(
            accessKeyId: "MyAccessKeyId",
            secretAccessKey: "MySecretAccessKey",
            region: .useast1,
            service:"Test",
            serviceProtocol: ServiceProtocol(type: .json),
            apiVersion: "1.0",
            httpClientProvider: .useAWSClientShared
        )
        let awsRequest = try! client.createAWSRequest(operation: "Test", path: "/", httpMethod: "GET")
        let signer = try! client.signer.wait()
        measure {
            for _ in 0..<1000 {
                _ = awsRequest.createHTTPRequest(signer: signer)
            }
        }
    }

    func testSignedHeadersRequest() {
        let client = AWSClient(
            accessKeyId: "MyAccessKeyId",
            secretAccessKey: "MySecretAccessKey",
            region: .useast1,
            service:"Test",
            serviceProtocol: ServiceProtocol(type: .json),
            apiVersion: "1.0",
            httpClientProvider: .useAWSClientShared
        )
        let date = Date()
        let request = StandardRequest(item1: "item1", item2: 45, item3: 3.14, item4: TimeStamp(date), item5: [1,2,3,4,5])
        let awsRequest = try! client.createAWSRequest(operation: "Test", path: "/", httpMethod: "POST", input: request)
        let signer = try! client.signer.wait()
        measure {
            for _ in 0..<1000 {
                _ = awsRequest.createHTTPRequest(signer: signer)
            }
        }
    }

    func testValidateXMLResponse() {
        let client = AWSClient(
            region: .useast1,
            service:"Test",
            serviceProtocol: ServiceProtocol(type: .restxml),
            apiVersion: "1.0",
            httpClientProvider: .useAWSClientShared
        )
        var buffer = ByteBufferAllocator().buffer(capacity: 0)
        buffer.writeString("<Output><item1>Hello</item1><item2>5</item2><item3>3.141</item3><item4>2001-12-23T15:34:12.590Z</item4><item5>3</item5><item5>6</item5><item5>325</item5></Output>")
        let response = HTTPClient.Response(
            host: "localhost",
            status: .ok,
            headers: HTTPHeaders(),
            body: buffer
        )
        measure {
            do {
                for _ in 0..<1000 {
                    let _: StandardRequest = try client.validate(operation: "Output", response: response)
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testValidateJSONResponse() {
        let client = AWSClient(
            region: .useast1,
            service:"Test",
            serviceProtocol: ServiceProtocol(type: .restjson),
            apiVersion: "1.0",
            httpClientProvider: .useAWSClientShared
        )
        var buffer = ByteBufferAllocator().buffer(capacity: 0)
        buffer.writeString("{\"item1\":\"Hello\", \"item2\":5, \"item3\":3.14, \"item4\":\"2001-12-23T15:34:12.590Z\", \"item5\": [1,56,3,7]}")
        let response = HTTPClient.Response(
            host: "localhost",
            status: .ok,
            headers: HTTPHeaders(),
            body: buffer
        )
        measure {
            do {
                for _ in 0..<1000 {
                    let _: StandardRequest = try client.validate(operation: "Output", response: response)
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }

    static var allTests : [(String, (PerformanceTests) -> () throws -> Void)] {
        return [
            ("testHeaderRequest", testHeaderRequest),
            ("testXMLRequest", testXMLRequest),
            ("testXMLPayloadRequest", testXMLPayloadRequest),
            ("testJSONRequest", testJSONRequest),
            ("testJSONPayloadRequest", testJSONPayloadRequest),
            ("testQueryRequest", testQueryRequest),
            ("testUnsignedRequest", testUnsignedRequest),
            ("testSignedURLRequest", testSignedURLRequest),
            ("testSignedHeadersRequest", testSignedHeadersRequest),
            ("testValidateXMLResponse", testValidateXMLResponse),
            ("testValidateJSONResponse", testValidateJSONResponse),
        ]
    }
}
