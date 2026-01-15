public protocol LogContextReadable {
  var logContext: LogContext { get }
}

public protocol LogContextAccessible: LogContextReadable {
  var logContext: LogContext { get set }
}

public protocol LogContextReadableActor: Actor {
  var logContext: LogContext { get }
}

public protocol LogContextAccessibleActor: LogContextReadableActor {
  func configure(_ builder: (inout LogContext) -> Void) async
}
