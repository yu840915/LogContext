public struct LogContext: LogContextStoring, LogContextReporting, Sendable {
  public private(set) var labels: [String] = []

  private var environment = LogContextStore()
  private var debugDetail = LogContextStore()

  public subscript(key: LogContext.Key) -> (any LogContextValue)? {
    get { environment[key] }
    set { environment[key] = newValue }
  }

  public var description: String {
    labeled(.info).description
  }

  public mutating func addLabels(_ labels: [String]) {
    for label in labels {
      addLabel(label)
    }
  }

  public mutating func addLabel(_ label: String) {
    if labels.contains(label) { return }
    labels.append(label)
  }

  public init(_ builder: StructBuilder<LogContext>? = nil) {
    if let builder {
      builder(&self)
    }
  }

  func getOutput(for scenario: LogScenario) -> LogOutput {
    switch scenario {
    case .trace: environment.getOutput(for: .trace)
    case .debug:
      environment
        .getOutput(for: .debug)
        .appending(debugDetail.getOutput(for: .debug))
    case .info: environment.getOutput(for: .info)
    case .notice:
      environment
        .getOutput(for: .notice)
        .appending(debugDetail.getOutput(for: .notice))
    case .warning:
      environment
        .getOutput(for: .warning)
        .appending(debugDetail.getOutput(for: .warning))
    case .error:
      environment
        .getOutput(for: .error)
        .appending(debugDetail.getOutput(for: .error))
    case .critical:
      environment
        .getOutput(for: .critical)
        .appending(debugDetail.getOutput(for: .critical))
    }
  }

  public mutating func setDebugDetail(_ builder: StructBuilder<LogContextStoring>) {
    var context: LogContextStoring = debugDetail
    builder(&context)
    if let context = context as? LogContext.LogContextStore {
      debugDetail = context
    }
  }

  func labeled(_ scenario: LogScenario) -> LogOutput {
    var list = [LogOutput.Entry]()
    if !labels.isEmpty {
      list.append(
        .init(
          name: .init(rawValue: "labels"),
          value: labels.map { "[\($0)]" }.joined(),
        )
      )
    }
    return LogOutput(entries: list).appending(getOutput(for: scenario))
  }

  public var trace: LogOutput { labeled(.trace) }
  public var debug: LogOutput { labeled(.debug) }
  public var info: LogOutput { labeled(.info) }
  public var notice: LogOutput { labeled(.notice) }
  public var warning: LogOutput { labeled(.warning) }
  public var error: LogOutput { labeled(.error) }
  public var critical: LogOutput { labeled(.critical) }
}

extension LogContext {
  public struct Key: Hashable, RawRepresentable, Sendable, CustomStringConvertible {
    public let rawValue: String
    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    public var description: String {
      rawValue
    }
  }
}

extension LogContext.Key {
  public static let id = Self(rawValue: "id")
  public static let error = Self(rawValue: "error")
  public static let status = Self(rawValue: "status")
  public static let state = Self(rawValue: "state")
}

extension LogContext {
  struct LogContextStore: LogContextStoring {
    private var entries: [LogContext.Key: any LogContextValue] = [:]
    subscript(key: LogContext.Key) -> (any LogContextValue)? {
      get { entries[key] }
      set { entries[key] = newValue }
    }

    func getOutput(for scenario: LogScenario) -> LogOutput {
      LogOutput(
        entries: entries.map {
          if let contextArray = $0.value as? [any LogContextValue] {
            LogOutput.Entry(
              name: $0.key,
              value: contextArray.map { $0.getValue(for: scenario) }
            )
          } else {
            LogOutput.Entry(
              name: $0.key,
              value: $0.value.getValue(for: scenario)
            )
          }
        },
      )
    }

    var description: String {
      getOutput(for: .info).description
    }
  }
}

extension LogContext {
  public mutating func setError(_ error: Error) {
    self[.error] = "\(error)"
  }

  public func adding(_ builder: StructBuilder<LogContext>) -> LogContext {
    var copy = self
    builder(&copy)
    return copy
  }
}
