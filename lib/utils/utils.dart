import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:hive/hive.dart';

List shuffle(List items) {
  var random = new Random();

  // Go through all elements.
  for (var i = items.length - 1; i > 0; i--) {
    // Pick a pseudorandom number according to the list length
    var n = random.nextInt(i + 1);

    var temp = items[i];
    items[i] = items[n];
    items[n] = temp;
  }

  return items;
}


 Future<void> setLoopMode() async {
  var loopMode = await Hive.box('loop').get('loop');
  print(loopMode);
  if (loopMode == '0' || loopMode == null) {
    await AudioService.setRepeatMode(AudioServiceRepeatMode.none);
  } else if (loopMode == '1') {
    await AudioService.setRepeatMode(AudioServiceRepeatMode.one);
  } else {
    await AudioService.setRepeatMode(AudioServiceRepeatMode.all);
  }
}
