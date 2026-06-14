import OSLog

enum Loggers: String {
  case lifecycle

  func build() -> Logger {
    return Logger(
      subsystem: "com.teleshot.DebugToolkit",
      category: rawValue,
    )
  }
}
