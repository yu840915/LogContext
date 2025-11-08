public protocol LogContextStoring: LogContextValue {
  subscript(key: LogContext.Key) -> (any LogContextValue)? { get set }
}

extension LogContextStoring {
  public subscript(key: String) -> (any LogContextValue)? {
    get { self[LogContext.Key(rawValue: key)] }
    set { self[LogContext.Key(rawValue: key)] = newValue }
  }
}
