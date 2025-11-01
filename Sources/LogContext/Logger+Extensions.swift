import OSLog

extension Logger {
  @inlinable
  public func trace(_ message: String, context: LogContext) {
    let contextOutput = context.labeled(.trace)
    trace("\(message) \(contextOutput)")
  }

  @inlinable
  public func debug(_ message: String, context: LogContext) {
    let contextOutput = context.labeled(.debug)
    debug("\(message) \(contextOutput)")
  }

  @inlinable
  public func info(_ message: String, context: LogContext) {
    let contextOutput = context.labeled(.info)
    info("\(message) \(contextOutput)")
  }

  @inlinable
  public func notice(_ message: String, context: LogContext) {
    let contextOutput = context.labeled(.notice)
    notice("\(message) \(contextOutput)")
  }

  @inlinable
  public func warning(_ message: String, context: LogContext) {
    let contextOutput = context.labeled(.warning)
    warning("\(message) \(contextOutput)")
  }

  @inlinable
  public func error(_ message: String, context: LogContext) {
    let contextOutput = context.labeled(.error)
    error("\(message) \(contextOutput)")
  }

  @inlinable
  public func critical(_ message: String, context: LogContext) {
    let contextOutput = context.labeled(.critical)
    critical("\(message) \(contextOutput)")
  }
}
