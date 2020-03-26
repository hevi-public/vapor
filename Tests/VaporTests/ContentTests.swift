import Vapor
import XCTVapor
import COperatingSystem
import AsyncHTTPClient

class ContentTests: XCTestCase {
    func testBeforeEncodeContent() throws {
        let content = SampleContent()
        XCTAssertEqual(content.name, "old name")

        let response = Response(status: .ok)
        try response.content.encode(content)

        let body = try XCTUnwrap(response.body.string)
        XCTAssertEqual(body, #"{"name":"new name"}"#)
    }

    func testAfterContentEncode() throws {
        let app = Application()
        defer { app.shutdown() }

        var body = ByteBufferAllocator().buffer(capacity: 0)
        body.writeString(#"{"name": "before decode"}"#)

        let request = Request(
            application: app,
            collectedBody: body,
            on: EmbeddedEventLoop()
        )

        request.headers.contentType = .json

        let content = try request.content.decode(SampleContent.self)
        XCTAssertEqual(content.name, "new name after decode")
    }
}

private struct SampleContent: Content {
    var name = "old name"

    mutating func beforeEncode() throws {
        name = "new name"
    }

    mutating func afterDecode() throws {
        name = "new name after decode"
    }
}
