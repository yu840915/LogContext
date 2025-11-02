public struct LogOutput: CustomStringConvertible, Sendable {
  public let entries: [Entry]
  public init(entries: [Entry] = []) {
    self.entries = entries
  }

  public var description: String {
    "(\(entries.map(\.description).joined(separator: ", ")))"
  }

  public func appending(_ other: LogOutput) -> LogOutput {
    LogOutput(entries: entries + other.entries)
  }
}

extension LogOutput {
  public struct Entry: CustomStringConvertible, Sendable {
    public let name: LogContext.Key
    public let value: LogContextValue

    public var description: String {
      "\(name)=\(value)"
    }
  }
}

struct OSLogEntry: StringInterpolationProtocol {
  private(set) var values: [String]

  init(literalCapacity: Int, interpolationCount: Int) {
    values = []
  }

  mutating func appendLiteral(_ literal: StringLiteralType) {
    values.append(literal)
  }

  mutating func appendInterpolation(_ value: LogContext) {
    values.append(value.labeled(.debug).description)
  }
}
