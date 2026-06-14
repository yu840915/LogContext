import LogContext

private let logger = Loggers.lifecycle.build()

public final class LifecycleDummy: Sendable {
  let logContext: LogContext

  public init(logContextBuilder: StructBuilder<LogContext>? = nil) {
    let logContext = LogContext {
      logContextBuilder?(&$0)
      $0.addLabel("Lifecycle")
    }
    self.logContext = logContext
    logger.debug("init \(logContext.debug)")
  }

  deinit {
    let logContext = self.logContext
    logger.debug("deinit \(logContext.debug)")
  }
}
