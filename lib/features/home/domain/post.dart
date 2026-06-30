/// Domain model for a Post.
///
/// Why this exists:
/// - Pure domain object with no framework or serialization dependencies.
/// - Represents a blog post from JSONPlaceholder.
/// - In a backend project, this is like a Mongoose schema or TypeORM entity.
class Post {
  final int id;
  final int userId;
  final String title;
  final String body;

  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });
}
