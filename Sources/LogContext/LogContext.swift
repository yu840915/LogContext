public struct LogContext: LogContextStoring, LogContextReporting {
  private var labels: [String] = []

  private var environment = LogContextStore()
  private var debugDetail = LogContextStore()

  public subscript(key: LogContext.Key) -> (any LogContextValue)? {
    get { environment[key] }
    set { environment[key] = newValue }
  }

  public var description: String {
    labeled(.info).description
  }

  public mutating func addLabel(_ label: String) {
    if labels.contains(label) { return }
    labels.append(label)
  }

  public var trace: LogOutput {
    environment.getOutput(for: .trace)
  }

  public var debug: LogOutput {
    environment.getOutput(for: .debug).appending(debugDetail.getOutput(for: .debug))
  }

  public var info: LogOutput {
    environment.getOutput(for: .info)
  }

  public var notice: LogOutput {
    warning
  }

  public var warning: LogOutput {
    error
  }

  public var error: LogOutput {
    critical
  }

  public var critical: LogOutput {
    environment.getOutput(for: .critical).appending(debugDetail.getOutput(for: .critical))
  }

  public init(_ builder: StructBuilder<LogContext>? = nil) {
    if let builder {
      builder(&self)
    }
  }

  func getOutput(for scenario: LogScenario) -> LogOutput {
    switch scenario {
    case .trace: trace
    case .debug: debug
    case .info: info
    case .notice: notice
    case .warning: warning
    case .error: error
    case .critical: critical
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

  public var labeledTrace: LogOutput { labeled(.trace) }
  public var labeledDebug: LogOutput { labeled(.debug) }
  public var labeledInfo: LogOutput { labeled(.info) }
  public var labeledNotice: LogOutput { labeled(.notice) }
  public var labeledWarning: LogOutput { labeled(.warning) }
  public var labeledError: LogOutput { labeled(.error) }
  public var labeledCritical: LogOutput { labeled(.critical) }
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
