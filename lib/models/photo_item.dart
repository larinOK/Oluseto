class PhotoItem {
  String image;
  List<dynamic> tags;
  late String uniqueId;
  PhotoItem(this.image, this.tags, this.uniqueId) {
    // id = uniqueId;
  }

  void addTag(String tag) {
    tags.add(tag);
  }

  List<dynamic> getTags() {
    return tags;
  }

  setID(String id) {
    uniqueId = id;
  }

  getID() {
    return uniqueId;
  }

  bool equals(PhotoItem b) {
    return uniqueId == b.uniqueId;
  }
}
