import 'package:flutter/material.dart';
import 'package:user_maternityapp/screens/community/addpost.dart';
import 'package:user_maternityapp/main.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:user_maternityapp/screens/community/view_comments.dart';

class Viewpost extends StatefulWidget {
  const Viewpost({super.key});

  @override
  State<Viewpost> createState() => _ViewpostState();
}

class _ViewpostState extends State<Viewpost> {
  List<Map<String, dynamic>> posts = [];
  bool isLoading = true;
  String? errorMessage;
  final TextEditingController _commentController = TextEditingController();
  Map<int, bool> loadingComments = {};
  Map<int, List<Map<String, dynamic>>> postComments = {};
  Map<int, bool> isSubmittingComment = {};

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> fetchPosts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await supabase
          .from('tbl_post')
          .select('*, tbl_user(*)')
          .order('post_datetime', ascending: false);

      // Get current user ID
      final currentUserId = supabase.auth.currentUser!.id;

      // For each post, fetch like count and check if user liked it
      List<Map<String, dynamic>> postsWithLikes = [];
      for (var post in response) {
        // Get likes for this post
        final likesResponse = await supabase
            .from('tbl_like')
            .select('user_id')
            .eq('post_id', post['post_id']);

        // Check if current user liked this post
        bool isLiked =
            likesResponse.any((like) => like['user_id'] == currentUserId);

        // Add like info to post
        post['like_count'] = likesResponse.length;
        post['is_liked_by_user'] = isLiked;

        postsWithLikes.add(post);
      }

      setState(() {
        posts = postsWithLikes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading posts. Please try again.';
      });
      print('Error fetching posts: $e');
    }
  }

  Future<void> toggleLike(int postId, bool isLiked) async {
    try {
      final currentUserId = supabase.auth.currentUser!.id;

      // Optimistically update UI
      setState(() {
        for (var post in posts) {
          if (post['post_id'] == postId) {
            post['is_liked_by_user'] = !isLiked;
            post['like_count'] =
                isLiked ? (post['like_count'] - 1) : (post['like_count'] + 1);
          }
        }
      });

      if (isLiked) {
        // Unlike
        await supabase
            .from('tbl_like')
            .delete()
            .match({'post_id': postId, 'user_id': currentUserId});
      } else {
        // Like
        await supabase
            .from('tbl_like')
            .insert({'post_id': postId, 'user_id': currentUserId});
      }
    } catch (e) {
      // Revert optimistic update on error
      await fetchPosts();
      print('Error toggling like: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update like. Please try again.')),
      );
    }
  }

  Future<void> fetchComments(int postId) async {
    print("Fetching comments for post $postId");
    if (loadingComments[postId] == true) return;

    setState(() {
      loadingComments[postId] = true;
    });

    try {
      final response = await supabase
          .from('tbl_comment')
          .select('*, tbl_user(*)')
          .eq('post_id', postId)
          .order('created_at', ascending: false);

      setState(() {
        postComments[postId] = response;
        loadingComments[postId] = false;
      });
    } catch (e) {
      setState(() {
        loadingComments[postId] = false;
      });
      print('Error fetching comments: $e');
    }
  }

  Future<void> addComment(int postId) async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      isSubmittingComment[postId] = true;
    });

    try {
      final currentUserId = supabase.auth.currentUser!.id;

      // Insert comment
      await supabase.from('tbl_comment').insert({
        'comment_content': _commentController.text.trim(),
        'user_id': currentUserId,
        'post_id': postId,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Clear input
      _commentController.clear();

      // Refresh comments
      await fetchComments(postId);

      setState(() {
        isSubmittingComment[postId] = false;
      });
    } catch (e) {
      setState(() {
        isSubmittingComment[postId] = false;
      });
      print('Error adding comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment. Please try again.')),
      );
    }
  }

  void showCommentsSheet(int postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsBottomSheet(
        postId: postId,
        fetchCommentsCallback: fetchComments,
        addCommentCallback: addComment,
        commentController: _commentController,
      ),
    );
  }

  String getTimeAgo(String dateTime) {
    final date = DateTime.parse(dateTime);
    return timeago.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[700],
        title: Text(
          'Community',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchPosts,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue[300]))
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(errorMessage!,
                          style: TextStyle(color: Colors.grey[700])),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: fetchPosts,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[300],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text("Try Again"),
                      ),
                    ],
                  ),
                )
              : posts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.forum_outlined,
                              size: 64, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text(
                            "No posts yet",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Be the first to share with the community",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchPosts,
                      color: Colors.blue[300],
                      child: ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          final isLiked = post['is_liked_by_user'] ?? false;
                          final likeCount = post['like_count'] ?? 0;
                          final postId = post['post_id'];

                          return Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: Colors.grey[200]!, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // User info and timestamp
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.blue[100],
                                        child: Text(
                                          (post['tbl_user']['user_name'] ??
                                                  'U')[0]
                                              .toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.blue[700],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              post['tbl_user']['user_name'] ??
                                                  'Unknown User',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              getTimeAgo(post['post_datetime']),
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.more_horiz,
                                            color: Colors.grey[600]),
                                        onPressed: () {
                                          // Show options menu
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                // Post content
                                if (post['post_content'] != null &&
                                    post['post_content'].trim().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                    child: Text(
                                      post['post_content'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),

                                // Post image if exists
                                if (post['post_file'] != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: post['post_file'],
                                      placeholder: (context, url) => Container(
                                        height: 200,
                                        color: Colors.grey[300],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.blue[300],
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        height: 200,
                                        color: Colors.grey[300],
                                        child: Center(
                                          child: Icon(Icons.error,
                                              color: Colors.grey[500]),
                                        ),
                                      ),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),

                                // Like and comment counts
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  child: Row(
                                    children: [
                                      if (likeCount > 0)
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.favorite,
                                              size: 16,
                                              color: Colors.pink[400],
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              '$likeCount',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      Spacer(),
                                      if ((postComments[postId]?.length ?? 0) >
                                          0)
                                        Text(
                                          '${postComments[postId]?.length} comments',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // Divider
                                Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Colors.grey[200]),

                                // Like and Comment buttons
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Row(
                                    children: [
                                      // Like button
                                      Expanded(
                                        child: TextButton.icon(
                                          icon: Icon(
                                            isLiked
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isLiked
                                                ? Colors.pink[400]
                                                : Colors.grey[600],
                                          ),
                                          label: Text(
                                            'Like',
                                            style: TextStyle(
                                              color: isLiked
                                                  ? Colors.blue[400]
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12),
                                          ),
                                          onPressed: () =>
                                              toggleLike(postId, isLiked),
                                        ),
                                      ),

                                      // Comment button
                                      Expanded(
                                        child: TextButton.icon(
                                          icon: Icon(
                                            Icons.chat_bubble_outline,
                                            color: Colors.grey[600],
                                          ),
                                          label: Text(
                                            'Comment',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CommentsPage(
                                                          postId: postId),
                                                ));
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => CreatePost()));
        },
        backgroundColor: Colors.blue[400],
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class CommentsBottomSheet extends StatefulWidget {
  final int postId;
  final Future<void> Function(int)
      fetchCommentsCallback; // Callback to fetch comments
  final Future<void> Function(int)
      addCommentCallback; // Callback to add a comment
  final TextEditingController commentController;

  const CommentsBottomSheet({
    super.key,
    required this.postId,
    required this.fetchCommentsCallback,
    required this.addCommentCallback,
    required this.commentController,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  List<Map<String, dynamic>> comments = [];
  bool isLoading = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchComments(); // Fetch comments when the bottom sheet opens
  }

  Future<void> _fetchComments() async {
    setState(() {
      isLoading = true;
    });
    await widget.fetchCommentsCallback(widget.postId);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _addComment() async {
    if (widget.commentController.text.trim().isEmpty) return;

    setState(() {
      isSubmitting = true;
    });
    await widget.addCommentCallback(widget.postId);
    await _fetchComments(); // Refresh comments after adding
    setState(() {
      isSubmitting = false;
    });
  }

  String getTimeAgo(String dateTime) {
    final date = DateTime.parse(dateTime);
    return timeago.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 1, color: Colors.grey[200]),
              Expanded(
                child: isLoading
                    ? Center(
                        child:
                            CircularProgressIndicator(color: Colors.blue[300]))
                    : comments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No comments yet',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Be the first to comment',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: comments.length,
                            padding: EdgeInsets.all(16),
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.blue[100],
                                      child: Text(
                                        (comment['tbl_user']['user_name'] ??
                                                'U')[0]
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  comment['tbl_user']
                                                          ['user_name'] ??
                                                      'Unknown User',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  comment['comment_content'],
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, top: 4.0),
                                            child: Text(
                                              getTimeAgo(comment['created_at']),
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.commentController,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue[400],
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: isSubmitting
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(Icons.send, color: Colors.white),
                        onPressed: isSubmitting ? null : _addComment,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
