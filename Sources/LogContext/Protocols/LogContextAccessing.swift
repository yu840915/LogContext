public protocol LogContextReading {
  var logContext: LogContext { get }
}

public protocol LogContextAccessing: LogContextReading {
  var logContext: LogContext { get set }
}

public protocol LogContextReadingActor: Actor {
  var logContext: LogContext { get }
}

public protocol LogContextAccessingActor: LogContextReadingActor {
  func configure(_ builder: (inout LogContext) -> Void) async
}
