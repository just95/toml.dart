library toml.src.util.date;

/// An extension on integers that represent years.
extension YearExtension on int {
  /// Tests whether this year is a leap year.
  ///
  /// See also <https://en.wikipedia.org/wiki/Leap_year>.
  ///
  /// > Every year that is exactly divisible by four is a leap year, except
  /// > for years that are exactly divisible by 100, but these centurial years
  /// > are leap years if they are exactly divisible by 400.
  bool get isLeapYear => (this % 4 == 0 && this % 100 != 0) || this % 400 == 0;

  /// Gets the number of days of the given month.
  int daysOfMonth(int month) {
    switch (month) {
      case DateTime.january:
        return 31;
      case DateTime.february:
        if (isLeapYear) return 29;
        return 28;
      case DateTime.march:
        return 31;
      case DateTime.april:
        return 30;
      case DateTime.may:
        return 31;
      case DateTime.june:
        return 30;
      case DateTime.july:
        return 31;
      case DateTime.august:
        return 31;
      case DateTime.september:
        return 30;
      case DateTime.october:
        return 31;
      case DateTime.november:
        return 30;
      case DateTime.december:
        return 31;
    }
    throw ArgumentError('Invalid month: ${month.toString().padLeft(2, '0')}');
  }
}
