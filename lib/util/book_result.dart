class BookResult {
  String title;
  String author;
  String description;
  String infoLink;
  String thumbLink;

  BookResult(this.title, this.author, this.description, this.infoLink,
      this.thumbLink) {
    // TODO: Find a better alternative to avoid null issues
    if (this.title == null) this.title = 'No Title';
    if (this.author == null) this.author = 'No Author';
    if (this.description == null) this.description = 'No Description';
    if (this.infoLink == null) this.infoLink = 'https://google.com/';
    if (this.thumbLink == null)
      this.thumbLink = 'http://via.placeholder.com/350x150';
  }
}
