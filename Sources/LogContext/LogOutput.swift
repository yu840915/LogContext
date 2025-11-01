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
