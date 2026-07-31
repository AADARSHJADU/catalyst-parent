// ignore_for_file: avoid_print
import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/chat_user_model.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Handles all REST calls for the Messages feature with candidate endpoint probing.
class MessageRepository {
  MessageRepository._();
  static final MessageRepository instance = MessageRepository._();

  final ApiClient _client = ApiClient.instance;

  // ── Conversations List ───────────────────────────────────────────────────────

  /// GET /api/v1/common/messages/conversations?archived=false
  Future<List<ConversationModel>> fetchConversations({
    bool archived = false,
  }) async {
    final candidates = [
      ApiConstants.conversations, // '/api/v1/common/messages/conversations'
      '/api/v1/messages/conversations',
      '/messages/conversations',
      '/api/messages/conversations',
    ];

    print('==================================================');
    print('💬 [MESSAGE REPO] FETCHING CONVERSATIONS (archived: $archived)...');
    print('==================================================');

    for (final endpoint in candidates) {
      try {
        print('[MESSAGE REPO] 🔄 Trying conversations endpoint: $endpoint?archived=$archived');
        final response = await _client.get(
          endpoint,
          queryParameters: {'archived': archived},
        );
        print('[MESSAGE REPO] HTTP ${response.statusCode} from $endpoint');
        print('[MESSAGE REPO] Raw body: ${response.data}');

        final rawData = response.data['data'] ?? response.data;
        List<dynamic> rows = [];
        if (rawData is Map) {
          if (rawData['rows'] is List) {
            rows = rawData['rows'];
          } else if (rawData['data'] is List) {
            rows = rawData['data'];
          }
        } else if (rawData is List) {
          rows = rawData;
        }

        final list = rows
            .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
            .toList();

        print('✅ [MESSAGE REPO] Loaded ${list.length} conversations from $endpoint');
        return list;
      } on DioException catch (e) {
        print('[MESSAGE REPO] ⚠️ Candidate $endpoint failed (${e.response?.statusCode}): ${e.message}');
        if (e.response?.statusCode != 404 && e.response?.statusCode != 405) {
          rethrow;
        }
      } catch (e) {
        print('[MESSAGE REPO] ⚠️ Candidate $endpoint error: $e');
      }
    }

    print('[MESSAGE REPO] ❌ All conversation list candidates failed.');
    return [];
  }

  /// GET /api/v1/common/messages/conversations/unread-count
  Future<int> fetchUnreadCount() async {
    final candidates = [
      ApiConstants.conversationsUnreadCount,
      '/api/v1/messages/conversations/unread-count',
      '/messages/conversations/unread-count',
    ];

    for (final endpoint in candidates) {
      try {
        final response = await _client.get(endpoint);
        final data = response.data['data'] ?? response.data;
        if (data is Map) {
          return (data['unreadCount'] ?? data['unread_count'] as num?)?.toInt() ?? 0;
        }
        return 0;
      } catch (_) {}
    }
    return 0;
  }

  // ── Users (search for new chat) ────────────────────────────────────────────

  /// GET /api/v1/common/messages/users?role=<role>
  Future<List<ChatUserModel>> searchUsers(String role) async {
    final candidates = [
      ApiConstants.messageUsers, // '/api/v1/common/messages/users'
      '/api/v1/messages/users',
      '/messages/users',
      '/users',
    ];

    print('[MESSAGE REPO] 🔄 Fetching users list for role: $role');

    for (final endpoint in candidates) {
      try {
        final response = await _client.get(
          endpoint,
          queryParameters: {'role': role},
        );
        final rawData = response.data['data'] ?? response.data;
        List<dynamic> rows = [];
        if (rawData is Map) {
          if (rawData['rows'] is List) {
            rows = rawData['rows'];
          } else if (rawData['data'] is List) {
            rows = rawData['data'];
          }
        } else if (rawData is List) {
          rows = rawData;
        }
        final result = rows
            .map((e) => ChatUserModel.fromJson(e as Map<String, dynamic>))
            .toList();
        print('✅ [MESSAGE REPO] Found ${result.length} users for role "$role" via $endpoint');
        return result;
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
      } catch (_) {}
    }
    return [];
  }

  // ── Start conversation ─────────────────────────────────────────────────────

  /// POST /api/v1/common/messages/conversations (Direct Message)
  Future<ConversationModel> startConversation({
    required String receiverId,
    String subject = 'New Chat',
  }) async {
    final candidates = [
      ApiConstants.conversations,
      '/api/v1/messages/conversations',
      '/messages/conversations',
    ];

    final payload = {
      'receiverId': int.tryParse(receiverId) ?? receiverId,
      'subject': subject,
    };

    for (final endpoint in candidates) {
      try {
        print('[MESSAGE REPO] 🔄 Starting 1-on-1 chat via $endpoint');
        final response = await _client.post(endpoint, data: payload);
        final data = response.data['data'] ?? response.data;
        print('✅ [MESSAGE REPO] Started conversation via $endpoint');
        return ConversationModel.fromJson(data as Map<String, dynamic>);
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
      } catch (_) {}
    }
    throw Exception('Failed to start conversation: All endpoints failed.');
  }

  /// POST /api/v1/common/messages/conversations (Group Conversation)
  Future<ConversationModel> createGroupConversation({
    required String name,
    required List<String> memberIds,
  }) async {
    final candidates = [
      ApiConstants.conversations,
      '/api/v1/messages/conversations',
      '/messages/conversations',
    ];

    final payload = {
      'isGroup': true,
      'name': name,
      'memberIds': memberIds.map((id) => int.tryParse(id) ?? id).toList(),
    };

    for (final endpoint in candidates) {
      try {
        print('[MESSAGE REPO] 🔄 Creating group conversation via $endpoint');
        final response = await _client.post(endpoint, data: payload);
        final data = response.data['data'] ?? response.data;
        print('✅ [MESSAGE REPO] Group created successfully via $endpoint');
        return ConversationModel.fromJson(data as Map<String, dynamic>);
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
      } catch (_) {}
    }
    throw Exception('Failed to create group conversation');
  }

  // ── Messages in a conversation ─────────────────────────────────────────────

  /// GET /api/v1/common/messages/conversations/:id/messages?limit=50&offset=0
  Future<List<MessageModel>> fetchMessages(
    String conversationId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final candidates = [
      ApiConstants.conversationMessages(conversationId),
      '/api/v1/messages/conversations/$conversationId/messages',
      '/messages/conversations/$conversationId/messages',
    ];

    print('[MESSAGE REPO] 🔄 Fetching messages for convId: $conversationId');

    for (final endpoint in candidates) {
      try {
        final response = await _client.get(
          endpoint,
          queryParameters: {'limit': limit, 'offset': offset},
        );
        final rawData = response.data['data'] ?? response.data;
        List<dynamic> rows = [];
        if (rawData is Map) {
          if (rawData['rows'] is List) {
            rows = rawData['rows'];
          } else if (rawData['data'] is List) {
            rows = rawData['data'];
          }
        } else if (rawData is List) {
          rows = rawData;
        }

        final list = rows
            .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
            .toList();
        print('✅ [MESSAGE REPO] Fetched ${list.length} messages from $endpoint');
        return list;
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
      } catch (_) {}
    }
    return [];
  }

  // ── Send message ───────────────────────────────────────────────────────────

  /// POST /api/v1/common/messages/conversations/:id/messages (multipart/form-data or JSON fallback)
  Future<MessageModel> sendMessage(
    String conversationId, {
    required String content,
    String? filePath,
    String? fileName,
  }) async {
    final candidates = [
      ApiConstants.conversationMessages(conversationId),
      '/api/v1/common/messages/conversations/$conversationId/messages',
      '/api/v1/messages/conversations/$conversationId/messages',
      '/messages/conversations/$conversationId/messages',
    ];

    print('==================================================');
    print('💬 [MESSAGE REPO] SENDING MESSAGE to Conv #$conversationId...');
    print('Content: "$content", File: $filePath');
    print('==================================================');

    DioException? lastException;

    for (final endpoint in candidates) {
      try {
        print('[MESSAGE REPO] 🔄 Trying postForm endpoint: $endpoint');
        final formData = FormData.fromMap({
          'content': content,
          if (filePath != null && filePath.isNotEmpty)
            'attachment': await MultipartFile.fromFile(filePath,
                filename: fileName ?? 'attachment'),
        });

        final response = await _client.postForm(
          endpoint,
          data: formData,
        );
        print('[MESSAGE REPO] ✅ HTTP ${response.statusCode} from postForm $endpoint');
        print('[MESSAGE REPO] Body: ${response.data}');
        final data = response.data['data'] ?? response.data;
        return MessageModel.fromJson(data as Map<String, dynamic>);
      } on DioException catch (e) {
        lastException = e;
        if (e.response?.statusCode != 404) rethrow;
      } catch (e) {
        print('[MESSAGE REPO] ⚠️ candidate $endpoint error: $e');
      }
    }
    print('[MESSAGE REPO] ❌ All candidate endpoints failed to send message.');
    if (lastException != null) throw lastException;
    throw Exception('Failed to send message: All candidate endpoints failed.');
  }

  // ── Mark as read ───────────────────────────────────────────────────────────

  /// PATCH /api/v1/common/messages/conversations/:id/messages/read
  Future<void> markAsRead(String conversationId) async {
    final candidates = [
      ApiConstants.markConversationRead(conversationId),
      '/api/v1/messages/conversations/$conversationId/messages/read',
      '/messages/conversations/$conversationId/messages/read',
    ];

    for (final endpoint in candidates) {
      try {
        await _client.patch(endpoint);
        print('✅ [MESSAGE REPO] Marked messages as read via $endpoint');
        return;
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
      } catch (_) {}
    }
  }

  // ── Archive ────────────────────────────────────────────────────────────────

  Future<void> toggleArchive(String conversationId, bool isArchived) async {
    final candidates = [
      ApiConstants.archiveConversation(conversationId),
      '/api/v1/messages/conversations/$conversationId/archive',
      '/messages/conversations/$conversationId/archive',
    ];

    for (final endpoint in candidates) {
      try {
        print('📦 [MESSAGE REPO] 🔄 Trying archive ($isArchived) via PATCH $endpoint');
        await _client.patch(
          endpoint,
          data: {'isArchived': isArchived, 'archived': isArchived},
        );
        print('📦 [MESSAGE REPO] ✅ Archive status updated via PATCH on $endpoint');
        return;
      } on DioException catch (e) {
        print('📦 [MESSAGE REPO] ⚠️ PATCH $endpoint failed (${e.response?.statusCode})');
        if (e.response?.statusCode == 404 || e.response?.statusCode == 405) {
          try {
            print('📦 [MESSAGE REPO] 🔄 Trying archive ($isArchived) via POST $endpoint');
            await _client.post(
              endpoint,
              data: {'isArchived': isArchived, 'archived': isArchived},
            );
            print('📦 [MESSAGE REPO] ✅ Archive status updated via POST on $endpoint');
            return;
          } catch (_) {}
          try {
            print('📦 [MESSAGE REPO] 🔄 Trying archive ($isArchived) via PUT $endpoint');
            await _client.put(
              endpoint,
              data: {'isArchived': isArchived, 'archived': isArchived},
            );
            print('📦 [MESSAGE REPO] ✅ Archive status updated via PUT on $endpoint');
            return;
          } catch (_) {}
        } else {
          rethrow;
        }
      } catch (e) {
        print('📦 [MESSAGE REPO] ⚠️ Archive error: $e');
      }
    }
  }

  // ── Group Member Management ────────────────────────────────────────────────

  /// POST /api/v1/common/messages/conversations/:id/members
  Future<ConversationModel> addMember(String convId, String userId) async {
    final candidates = [
      ApiConstants.conversationMembers(convId),
      '/api/v1/messages/conversations/$convId/members',
      '/messages/conversations/$convId/members',
    ];

    final payload = {'userId': int.tryParse(userId) ?? userId};

    for (final endpoint in candidates) {
      try {
        final response = await _client.post(endpoint, data: payload);
        final data = response.data['data'] ?? response.data;
        return ConversationModel.fromJson(data as Map<String, dynamic>);
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
      } catch (_) {}
    }
    throw Exception('Failed to add group member');
  }

  /// DELETE /api/v1/common/messages/conversations/:id/members/:userId
  Future<void> removeMember(String convId, String userId) async {
    final candidates = [
      ApiConstants.conversationMember(convId, userId),
      '/api/v1/messages/conversations/$convId/members/$userId',
      '/messages/conversations/$convId/members/$userId',
    ];

    for (final endpoint in candidates) {
      try {
        await _client.delete(endpoint);
        return;
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
      } catch (_) {}
    }
  }

  /// PATCH /api/v1/common/messages/conversations/:id/members/:userId/role
  Future<void> updateMemberRole(
      String convId, String userId, bool isAdmin) async {
    final candidates = [
      ApiConstants.conversationMemberRole(convId, userId),
      '/api/v1/messages/conversations/$convId/members/$userId/role',
      '/messages/conversations/$convId/members/$userId/role',
    ];

    for (final endpoint in candidates) {
      try {
        await _client.patch(
          endpoint,
          data: {'isAdmin': isAdmin},
        );
        return;
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
      } catch (_) {}
    }
  }
}
