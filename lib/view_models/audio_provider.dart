import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../utils/enums.dart';
import '../utils/const.dart';

class AudioProvider extends ChangeNotifier {
  APIRequestStatus _apiPlaylistRequestStatus = APIRequestStatus.unInitialized;
  get getApiPlaylistRequestStatus => _apiPlaylistRequestStatus;

  List _audioItems = [];
  get audioItems => _audioItems;

  fetchPlaylist() async {
    setApiPlaylistRequestStatus(APIRequestStatus.loading);

    Dio dio = Dio();
    dio.options.headers['content-Type'] = 'application/json';
    var url = Constants.appPlaylistURL;

    try {
      final res = await dio.get(url);
      if (res.statusCode == 200) {
        // TODO This can be a PODO.
        List raw = res.data;
        raw.forEach(
          (ele) {
            _audioItems.add(
              MediaItem(
                id: ele['audiourl'],
                album: ele['album'],
                title: ele['title'],
                artist: ele['artist'],
                duration: Duration(milliseconds: ele['duration']),
                artUri: Uri.parse(ele['artUri']),
                extras: {
                  'episodeid': ele['extras']['episodeid'],
                  'index': ele['extras']['index']
                },
              ),
            );
          },
        );
        setApiPlaylistRequestStatus(APIRequestStatus.loaded);
      } else
        setApiPlaylistRequestStatus(APIRequestStatus.error);
    } catch (e) {
      setApiPlaylistRequestStatus(APIRequestStatus.error);
    }
  }

  setApiPlaylistRequestStatus(APIRequestStatus status) {
    _apiPlaylistRequestStatus = status;
    notifyListeners();
  }
}
