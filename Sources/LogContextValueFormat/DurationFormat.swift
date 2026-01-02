let millisecondsStyle = Duration.UnitsFormatStyle.units(
  allowed: [.milliseconds],
  width: .condensedAbbreviated,
)

extension Duration {
  public var formattedMilliseconds: String {
    formatted(millisecondsStyle)
  }
}
