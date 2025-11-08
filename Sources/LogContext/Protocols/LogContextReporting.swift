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
