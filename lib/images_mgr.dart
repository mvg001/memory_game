import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics.dart';

class ImageAssetsManager {
  static final List<String> _files = [
    'emoji_u1f335.svg.vec',
    'emoji_u1f349.svg.vec',
    'emoji_u1f34e.svg.vec',
    'emoji_u1f352.svg.vec',
    'emoji_u1f354.svg.vec',
    'emoji_u1f369.svg.vec',
    'emoji_u1f36d.svg.vec',
    'emoji_u1f381.svg.vec',
    'emoji_u1f3a0.svg.vec',
    'emoji_u1f3a1.svg.vec',
    'emoji_u1f3af.svg.vec',
    'emoji_u1f3b8.svg.vec',
    'emoji_u1f3ba.svg.vec',
    'emoji_u1f3c0.svg.vec',
    'emoji_u1f407.svg.vec',
    'emoji_u1f412.svg.vec',
    'emoji_u1f415.svg.vec',
    'emoji_u1f41e.svg.vec',
    'emoji_u1f426.svg.vec',
    'emoji_u1f427.svg.vec',
    'emoji_u1f42c.svg.vec',
    'emoji_u1f4a1.svg.vec',
    'emoji_u1f4a3.svg.vec',
    'emoji_u1f5dd.svg.vec',
    'emoji_u1f680.svg.vec',
    'emoji_u1f6e9.svg.vec',
    'emoji_u1f6f5.svg.vec',
    'emoji_u1f95d.svg.vec',
    'emoji_u1f96a.svg.vec',
    'emoji_u1f986.svg.vec',
    'emoji_u1f992.svg.vec',
    'emoji_u1f998.svg.vec',
    'emoji_u1f99a.svg.vec',
    'emoji_u1f99c.svg.vec',
    'emoji_u1f9c1.svg.vec',
    'emoji_u1f9ed.svg.vec',
    'emoji_u1f9f8.svg.vec',
    'emoji_u1f9fb.svg.vec',
    'emoji_u1fa81.svg.vec',
    'emoji_u1fa91.svg.vec',
    'emoji_u1fab2.svg.vec',
    'emoji_u1fab4.svg.vec',
    'emoji_u1fabb.svg.vec',
    'emoji_u2615.svg.vec',
  ];

  static final Map<String, SvgPicture> _loaded = {};
  static int totalNumber() {
    return _files.length;
  }

  static List<int> shuffledSubset(int n) {
    if (n <= 0 || n > _files.length) {
      throw ArgumentError();
    }
    List<int> ids = List<int>.filled(_files.length, 0, growable: false);
    for (int i = 0; i < ids.length; i++) {
      ids[i] = i;
    }
    ids.shuffle();
    return ids.sublist(0, n);
  }

  static SvgPicture loadPicByIndex(int index) {
    if (index < 0 || index >= _files.length) {
      throw ArgumentError();
    }
    return _load(_files[index]);
  }

  static SvgPicture _load(String assetName) {
    if (_loaded.containsKey(assetName)) return _loaded[assetName]!;
    var pic = SvgPicture(AssetBytesLoader('assets/images/$assetName'));
    _loaded[assetName] = pic;
    return pic;
  }

  static final questionMarkPic = _load('red_question_mark.svg.vec');
}
