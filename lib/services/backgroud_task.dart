import 'dart:async';
import 'dart:convert';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

///Start background task
Future onBackground() async {
  await AudioService.start(
    backgroundTaskEntrypoint: myBackgroundTaskEntrypoint,
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
  AudioProcessingState _skipState;
  StreamSubscription<PlaybackEvent> _eventSubscription;

  AudioServiceRepeatMode loopMode;

  Future<void> initHive() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    await Hive.initFlutter();
    await Hive.openBox('lastSong');
    await Hive.openBox('lastQueue');
    await Hive.openBox('lastPosition');
  }

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

  AudioProcessingState _getProcessingState() {
    print(_player.processingState);
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
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    await initHive();

    _eventSubscription = _player.playbackEventStream.listen((event) {
      _broadcastState();
    });

    _player.positionStream.listen((event) async {
      await Hive.box('lastPosition')
          .put('lastPosition', _player.position.inMilliseconds);
    });

    _player.processingStateStream.listen((state) async {
      print('loopMode njnj');
      print(loopMode);
      switch (state) {
        case ProcessingState.completed:
          // when a song is completed it goes to the next one in the list if it is not the last element in the index
          if (loopMode == AudioServiceRepeatMode.one) {
            print('dnfkn');
            repeatOneSong();
          } else if (AudioServiceBackground.queue.last.id ==
                  AudioServiceBackground.mediaItem.id &&
              loopMode == AudioServiceRepeatMode.none) {
            _player.stop();
            print('seccc');
          } else if (AudioServiceBackground.queue.last.id ==
                  AudioServiceBackground.mediaItem.id &&
              loopMode == AudioServiceRepeatMode.all) {
            repeatFromBegining();
            print('thijdjf');
          } else {
            onSkipToNext();
            print('neet');
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
    AudioServiceBackground.setQueue([]);
    return super.onStart(params);
  }

  Future<void> repeatFromBegining() async {
    int index = 0;
    MediaItem mediaItem = AudioServiceBackground.queue[index];

    onPlayMediaItem(mediaItem);

    AudioServiceBackground.setMediaItem(mediaItem);
  }

  @override
  Future<void> onClick(MediaButton button) {
    return super.onClick(button);
  }

  @override
  Future<void> onPrepareFromMediaId(String mediaId) {
    // TODO: implement onPrepareFromMediaId
    return super.onPrepareFromMediaId(mediaId);
  }

  @override
  Future<void> onUpdateMediaItem(MediaItem mediaItem) async {
    AudioServiceBackground.setMediaItem(mediaItem);
    return super.onUpdateMediaItem(mediaItem);
  }

  @override
  Future<void> onUpdateQueue(List<MediaItem> queue) async {
    await AudioServiceBackground.setQueue(queue);

    await Hive.box('lastQueue').put('lastQueue', json.encode(queue));
  }

  @override
  Future<void> onAddQueueItemAt(MediaItem mediaItem, int index) async {
    var queue = AudioServiceBackground.queue;
    queue.insert(index, mediaItem);
    await AudioServiceBackground.setQueue(queue);
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
    final items =
        AudioServiceBackground.queue.where((item) => item.id == mediaId);
    var item = items.toList()[0];
    onPlayMediaItem(item);
    AudioServiceBackground.setMediaItem(item);
    return super.onSkipToQueueItem(mediaId);
  }

  @override
  Future<void> onPlayMediaItem(MediaItem mediaItem) async {
    print(mediaItem.id);
    try {
      await _player.setFilePath(mediaItem.extras['filePath']);
      await onPlay();
      await Hive.box('lastSong').put('lastSong', json.encode(mediaItem));
    } catch (e) {}
    return super.onPlayMediaItem(mediaItem);
  }

  repeatOneSong() {
    int index = AudioServiceBackground.queue.indexWhere(
      (element) => element.id == AudioServiceBackground.mediaItem.id,
    );
    MediaItem mediaItem = AudioServiceBackground.queue[index];

    onPlayMediaItem(mediaItem);

    AudioServiceBackground.setMediaItem(mediaItem);
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
      (element) => element.id == AudioServiceBackground.mediaItem.id,
    );
    index++;
    MediaItem mediaItem = AudioServiceBackground.queue[index];

    onPlayMediaItem(mediaItem);

    AudioServiceBackground.setMediaItem(mediaItem);
  }

  @override
  Future<void> onRemoveQueueItem(MediaItem mediaItem) async {
    print(mediaItem);
    var queue = AudioServiceBackground.queue;
    queue.remove(mediaItem);
    await AudioServiceBackground.setQueue(queue);
    return super.onRemoveQueueItem(mediaItem);
  }

  @override
  Future<void> onSkipToPrevious() async {
    int index = AudioServiceBackground.queue.indexWhere(
      (element) => element.id == AudioServiceBackground.mediaItem.id,
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
  Future<void> onSetRepeatMode(AudioServiceRepeatMode repeatMode) {
    loopMode = repeatMode;
    return super.onSetRepeatMode(repeatMode);
  }

  @override
  Future onCustomAction(String name, arguments) async {
    switch (name) {
      case 'UPDATE-INDEX':
        MediaItem mediaItem = AudioServiceBackground.mediaItem.copyWith(
          extras: {},
        );
        AudioServiceBackground.setMediaItem(mediaItem);
        break;
      case 'SET-FILE-PATH':
        await _player.setFilePath(arguments);
        break;
      case 'SET-STATE':
        await AudioServiceBackground.setState(
          controls: [
            MediaControl.skipToPrevious,
            MediaControl.play,
            MediaControl.stop,
            MediaControl.skipToNext,
          ],
          systemActions: [
            MediaAction.seekTo,
            MediaAction.seekForward,
            MediaAction.seekBackward,
          ],
          androidCompactActions: [0, 1, 3],
          playing: false,
          processingState: AudioProcessingState.ready,
          bufferedPosition: Duration(microseconds: arguments),
          position: Duration(microseconds: arguments),
        );

        break;

      default:
    }
    return super.onCustomAction(name, arguments);
  }
}
