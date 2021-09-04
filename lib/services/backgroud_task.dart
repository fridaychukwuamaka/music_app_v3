import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

///Start background task
Future onBackground() async {
  await AudioService.start(
    backgroundTaskEntrypoint: myBackgroundTaskEntrypoint,
    androidStopForegroundOnPause: true,
    androidEnableQueue: true,
    androidNotificationChannelName: 'Audio Service Demo',
    androidNotificationIcon: 'mipmap/ic_launcher',
  );
}

void myBackgroundTaskEntrypoint() {
  AudioServiceBackground.run(() => MyBackgroundTask());
}

class MyBackgroundTask extends BackgroundAudioTask {
  AudioPlayer _player = AudioPlayer();
  List<MediaItem> _queue = [];
  AudioProcessingState _skipState;
  StreamSubscription<PlaybackEvent> _eventSubscription;

  /// Broadcasts the current state to all clients.
  Future<void> _broadcastState() async {
    await AudioServiceBackground.setState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: [
        MediaAction.seekTo,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      ],
      androidCompactActions: [0, 1, 3],
      processingState: _getProcessingState(),
      playing: _player.playing,
      position: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    );
  }

  /// Maps just_audio's processing state into into audio_service's playing
  /// state. If we are in the middle of a skip, we use [_skipState] instead.
  AudioProcessingState _getProcessingState() {
    if (_skipState != null) return _skipState;
    switch (_player.processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.stopped;
      case ProcessingState.loading:
        return AudioProcessingState.connecting;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      default:
        throw Exception("Invalid state: ${_player.processingState}");
    }
  }

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    print('hii');
    // We configure the audio session for speech since we're playing a podcast.
    // You can also put this in your app's initialisation if your app doesn't
    // switch between two types of audio as this example does.
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    // Broadcast media item changes.

    /*   _player.currentIndexStream.listen((index) {
      if (index != null) AudioServiceBackground.setMediaItem(_queue[index]);
    }); */

    // Propagate all events from the audio player to AudioService clients.
    _eventSubscription = _player.playbackEventStream.listen((event) {
      _broadcastState();
    });
    // Special processing for state transitions.
    _player.processingStateStream.listen((state) async {
      switch (state) {
        case ProcessingState.completed:
          // when a song is completed it goes to the next one in the list if it is not the last element in the index
          if (AudioServiceBackground.queue.last.extras['index'] ==
              AudioServiceBackground.mediaItem.extras['index']) {
            _player.stop();
          } else {
            onSkipToNext();
          }
          // onStop();
          break;
        case ProcessingState.ready:
          // If we just came from skipping between tracks, clear the skip
          // state now that we're ready to play.
          _skipState = null;
          break;
        default:
          break;
      }
    });
    return super.onStart(params);
  }

  @override
  Future<void> onUpdateMediaItem(MediaItem mediaItem) {
    AudioServiceBackground.setMediaItem(mediaItem);
    return super.onUpdateMediaItem(mediaItem);
  }

  @override
  Future<void> onUpdateQueue(List<MediaItem> queue) {
    AudioServiceBackground.setQueue(queue);
    return super.onUpdateQueue(queue);
  }

  @override
  Future<void> onAddQueueItemAt(MediaItem mediaItem, int index) {
    var queue = AudioServiceBackground.queue;
    queue.insert(index, mediaItem);
    AudioServiceBackground.setQueue(queue);
    queue = [];
    return super.onAddQueueItemAt(mediaItem, index);
  }

  @override
  Future<void> onAddQueueItem(MediaItem mediaItem) {
    var queue = AudioServiceBackground.queue;
    queue.add(mediaItem);
    AudioServiceBackground.setQueue(queue);
    queue = [];
    return super.onAddQueueItem(mediaItem);
  }

  @override
  Future<void> onSkipToQueueItem(String mediaId) {
    final items = AudioServiceBackground.queue
        .where((item) => item.extras['index'] == mediaId);
    var item = items.toList()[0];
    onPlayMediaItem(item);
    AudioServiceBackground.setMediaItem(item);
    return super.onSkipToQueueItem(mediaId);
  }

  @override
  Future<void> onPlayMediaItem(MediaItem mediaItem) async {
    print(mediaItem.id);
    try {
      await _player.setFilePath(mediaItem.id);
      onPlay();
    } catch (e) {
      print('errr: $e');
    }
    return super.onPlayMediaItem(mediaItem);
  }

  @override
  Future<void> onPlay() {
    _player.play();
    return super.onPlay();
  }

  @override
  Future<void> onPause() {
    _player.pause();
    return super.onPause();
  }

  @override
  Future<void> onSkipToNext() async {
    int index = AudioServiceBackground.queue.indexWhere(
      (element) =>
          element.extras['index'] ==
          AudioServiceBackground.mediaItem.extras['index'],
    );
    index++;
    MediaItem mediaItem = AudioServiceBackground.queue[index];

    onPlayMediaItem(mediaItem);

    AudioServiceBackground.setMediaItem(mediaItem);
  }

  @override
  Future<void> onSkipToPrevious() async {
    int index = AudioServiceBackground.queue.indexWhere(
      (element) =>
          element.extras['index'] ==
          AudioServiceBackground.mediaItem.extras['index'],
    );
    index--;
    MediaItem mediaItem = AudioServiceBackground.queue[index];
    onPlayMediaItem(mediaItem);

    AudioServiceBackground.setMediaItem(mediaItem);
  }

  @override
  Future<void> onSeekTo(Duration position) {
    _player.seek(position);
    return super.onSeekTo(position);
  }

  @override
  Future onCustomAction(String name, arguments) {
    switch (name) {
      case 'UPDATE-INDEX':
        print(arguments);
        MediaItem mediaItem = AudioServiceBackground.mediaItem.copyWith(
          extras: {},
        );

        AudioServiceBackground.setMediaItem(mediaItem);
        break;
      default:
    }
    return super.onCustomAction(name, arguments);
  }
}
