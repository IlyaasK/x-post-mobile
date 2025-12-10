import 'package:twitter_api_v2/twitter_api_v2.dart';
import 'storage_service.dart';

import 'dart:io';

class XService {
  TwitterApi? _twitterApi;
  final _storage = StorageService();

  Future<void> init() async {
    final consumerKey = await _storage.read(key: 'CONSUMER_KEY');
    final consumerSecret = await _storage.read(key: 'CONSUMER_SECRET');
    final accessToken = await _storage.read(key: 'ACCESS_TOKEN');
    final accessTokenSecret = await _storage.read(key: 'ACCESS_TOKEN_SECRET');

    if (consumerKey == null ||
        consumerSecret == null ||
        accessToken == null ||
        accessTokenSecret == null) {
      throw Exception('API Keys not found');
    }

    _twitterApi = TwitterApi(
      bearerToken: '', 
      oauthTokens: OAuthTokens(
        consumerKey: consumerKey,
        consumerSecret: consumerSecret,
        accessToken: accessToken,
        accessTokenSecret: accessTokenSecret,
      ),
    );
  }

  Future<String> uploadMedia(File file) async {
    if (_twitterApi == null) await init();
    
    try {
      final media = await _twitterApi!.media.uploadMedia(
        file: file,
      );
      return media.data.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<TweetData> postTweet(String text, {List<String>? mediaIds, String? replyToId}) async {
    if (_twitterApi == null) {
      await init();
    }
    
    try {
      final response = await _twitterApi!.tweets.createTweet(
        text: text,
        media: mediaIds != null && mediaIds.isNotEmpty
            ? TweetMediaParam(mediaIds: mediaIds)
            : null,
        reply: replyToId != null 
            ? TweetReplyParam(inReplyToTweetId: replyToId) 
            : null,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  Future<List<TweetData>> getReplies(String tweetId) async {
    if (_twitterApi == null) await init();

    try {
      final response = await _twitterApi!.tweets.searchRecent(
        query: 'conversation_id:$tweetId',
        tweetFields: [
          TweetField.createdAt,
          TweetField.authorId,
        ],
      );
      return response.data;
    } catch (e) {
      print('Error fetching replies: $e');
      return [];
    }
  }
}
