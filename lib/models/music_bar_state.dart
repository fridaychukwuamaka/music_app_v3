
import 'package:audio_service/audio_service.dart';

class MusicBarState {
  final PlaybackState playbackState;
  final MediaItem mediaItem;

  MusicBarState(this.playbackState, this.mediaItem);
}