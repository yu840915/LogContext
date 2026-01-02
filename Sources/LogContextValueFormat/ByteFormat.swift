import LogContext
import OSLog

private let sizeStyle: ByteCountFormatStyle = ByteCountFormatStyle(
  style: .binary,
  allowedUnits: [.bytes, .kb, .mb],
  spellsOutZero: true,
  includesActualByteCount: false,
  locale: Locale(identifier: "en_US"),
)

extension BinaryInteger {
  public var formattedSize: String {
    formatted(sizeStyle)
  }

  public var formattedBandwidth: String {
    formattedSize + "/s"
  }
}

extension Double {
  public var formattedSize: String {
    Int(self).formatted(sizeStyle)
  }

  public var formattedBandwidth: String {
    formattedSize + "/s"
  }
}
