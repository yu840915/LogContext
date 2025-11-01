import LogContext
import OSLog
import Testing

let logger = Logger(subsystem: "MockSystem", category: "TestCategory")

struct LogContextTests {
    @Test
    func setBaseProperties() async throws {
        var sut = LogContext()
        sut[.id] = "12345"
        sut[.status] = "started"

        #expect(sut[.id] as? String == "12345")
        #expect(sut[.status] as? String == "started")
    }

    @Test
    func showBasePropertiesInEveryOutput() async throws {
        var sut = LogContext()
        sut[.id] = "12345"

        #expect(sut.trace.description == "(id=12345)")
        #expect(sut.debug.description == "(id=12345)")
        #expect(sut.info.description == "(id=12345)")
        #expect(sut.notice.description == "(id=12345)")
        #expect(sut.warning.description == "(id=12345)")
        #expect(sut.error.description == "(id=12345)")
        #expect(sut.critical.description == "(id=12345)")
    }

    @Test
    func showLabelInOrderOfAdding() async throws {
        var sut = LogContext()
        sut.addLabel("First")
        sut.addLabel("Second")
        sut.addLabel("Third")

        #expect(sut.labeled(.critical).description == "(labels=[First][Second][Third])")
    }

    @Test
    func showLabelsBeforeValue() async throws {
        var sut = LogContext()
        sut.addLabel("First")
        sut[.id] = "12345"

        #expect(sut.labeled(.critical).description == "(labels=[First], id=12345)")
    }

    @Test
    func setDebugDetailAndEnvironment() async throws {
        var sut = LogContext()

        sut[.id] = "12345"
        sut.setDebugDetail {
            $0[.init(rawValue: "name")] = "Mike"
        }

        #expect(sut.trace.description == "(id=12345)")
        #expect(sut.debug.description == "(id=12345, name=Mike)")
        #expect(sut.info.description == "(id=12345)")
        #expect(sut.notice.description == "(id=12345, name=Mike)")
        #expect(sut.warning.description == "(id=12345, name=Mike)")
        #expect(sut.error.description == "(id=12345, name=Mike)")
        #expect(sut.critical.description == "(id=12345, name=Mike)")
    }

    @Test
    func nestContext() async throws {
        var sut = LogContext()

        sut.addLabel("outer")
        sut[.init(rawValue: "nested")] = LogContext {
            $0[.id] = "67890"
            $0.addLabel("inner")
            $0.setDebugDetail {
                $0[.init(rawValue: "Msg")] = "Hello"
            }
        }
        sut.setDebugDetail {
            $0[.id] = "12345"
        }

        #expect(
            sut.labeled(.critical).description
                == "(labels=[outer], nested=(id=67890, Msg=Hello), id=12345)"
        )
        #expect(
            sut.labeled(.info).description
                == "(labels=[outer], nested=(id=67890))"
        )
    }

    @Test
    func listOfValue() async throws {
        var sut = LogContext()
        sut[.init(rawValue: "strings")] = ["one", "two", "three"]
        sut.setDebugDetail {
            $0[.init(rawValue: "numbers")] = [1, 2, 3]
        }

        #expect(
            sut.labeled(.critical).description
                == "(strings=[\"one\", \"two\", \"three\"], numbers=[1, 2, 3])"
        )
    }

    @Test
    func builder() async throws {
        let sut = LogContext {
            $0[.id] = "12345"
            $0.addLabel("built")
            $0.setDebugDetail {
                $0[.init(rawValue: "name")] = "Mike"
            }
        }

        #expect(sut.labeled(.info).description == "(labels=[built], id=12345)")
        #expect(sut.labeled(.critical).description == "(labels=[built], id=12345, name=Mike)")
    }

    @Test
    func listOfContexts() async throws {
        var sut = LogContext {
            $0[.init(rawValue: "users")] = [
                LogContext {
                    $0[.id] = "1"
                    $0.setDebugDetail {
                        $0[.init(rawValue: "name")] = "Alice"
                    }
                },
                LogContext {
                    $0[.id] = "2"
                    $0.setDebugDetail {
                        $0[.init(rawValue: "name")] = "Bob"
                    }
                },
            ]
        }

        sut.addLabel("Nesting")

        #expect(
            sut.labeled(.debug).description
                == "(labels=[Nesting], users=[(id=1, name=Alice), (id=2, name=Bob)])"
        )
        #expect(
            sut.labeled(.info).description
                == "(labels=[Nesting], users=[(id=1), (id=2)])"
        )
    }

    @Test func deduplicateLabel() async throws {
        var sut = LogContext {
            $0.addLabel("Test")
            $0[.id] = "12345"
        }

        sut.addLabel("Test")

        #expect(sut.labeled(.info).description == "(labels=[Test], id=12345)")
    }

    @Test
    func usage() async throws {
        let sut = LogContext {
            $0.addLabel("Test")
            $0[.id] = "12345"
            $0.setDebugDetail {
                $0[.init(rawValue: "user")] = "Alice"
            }
        }

        logger.debug("\(sut.labeled(.debug))")
        logger.debug("Hello", context: sut)
        logger.trace("\(sut.labeled(.trace))")
        logger.trace("Hello", context: sut)
    }
}
