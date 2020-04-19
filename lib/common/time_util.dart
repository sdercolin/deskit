class DurationUtil {
  static String formatSeconds(int total) {
    final duration = Duration(seconds: total);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final minutesText = minutes.toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60);
    final secondsText = seconds.toString().padLeft(2, '0');
    var text = '$minutesText:$secondsText';
    if (hours > 0) {
      text = '$hours:$text';
    }
    return text;
  }

  static Duration parse(String text) {
    var hours = 0;
    var minutes = 0;
    var seconds = 0;
    var parts = text.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    seconds = int.parse(parts[parts.length - 1]);
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  static int parseAsSeconds(String text) {
    return parse(text).inSeconds;
  }
}
