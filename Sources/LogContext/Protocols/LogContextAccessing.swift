public protocol LogContextReadable {
  var logContext: LogContext { get }
}

public protocol LogContextAccessible: LogContextReadable {
  var logContext: LogContext { get set }
}

public protocol LogContextReadingActor: Actor {
  var logContext: LogContext { get }
}

public protocol LogContextAccessingActor: LogContextReadingActor {
  func configure(_ builder: (inout LogContext) -> Void) async
}
