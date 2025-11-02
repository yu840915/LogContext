public enum LogScenario: Sendable {
  case trace
  case debug
  case info
  case notice
  case warning
  case error
  case critical
}

public typealias LogContextValue = CustomStringConvertible & Sendable

public typealias StructBuilder<T> = (inout T) -> Void

public protocol LogContextStoring: LogContextValue {
  subscript(key: LogContext.Key) -> (any LogContextValue)? { get set }
}

extension LogContextStoring {
  public subscript(key: String) -> (any LogContextValue)? {
    get { self[LogContext.Key(rawValue: key)] }
    set { self[LogContext.Key(rawValue: key)] = newValue }
  }
}

protocol LogContextReporting: LogContextValue {
  func getOutput(for scenario: LogScenario) -> LogOutput
}

extension CustomStringConvertible where Self: LogContextValue {
  func getValue(for scenario: LogScenario) -> LogContextValue {
    if let context = self as? LogContextReporting {
      context.getOutput(for: scenario)
    } else {
      self
    }
  }
}
