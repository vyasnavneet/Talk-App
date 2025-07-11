import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:talk/models/group.dart';
import 'package:talk/models/message.dart';

class ChatService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getUserStreamExcludingBlocked() {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('Users')
        .doc(currentUser.uid)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
          final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();
          final userSnapshot = await _firestore.collection('Users').get();

          final usersData = await Future.wait(
            userSnapshot.docs
                .where(
                  (doc) =>
                      doc.data()['email'] != currentUser.email &&
                      !blockedUserIds.contains(doc.id),
                )
                .map((doc) async {
                  final userData = doc.data();
                  final chatRoomId = [currentUser.uid, doc.id]..sort();
                  final unreadMessageSnapshot = await _firestore
                      .collection("chat_rooms")
                      .doc(chatRoomId.join('_'))
                      .collection("messages")
                      .where('reciverID', isEqualTo: currentUser.uid)
                      .where('isRead', isEqualTo: false)
                      .get();

                  userData['unreadCount'] = unreadMessageSnapshot.docs.length;
                  userData['profileImage'] =
                      userData['profileImage'] as String?;
                  return userData;
                })
                .toList(),
          );

          return usersData;
        });
  }

  Future<void> sendMessage(String reciverID, message, uname) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      reciverID: reciverID,
      message: message,
      timestamp: timestamp,
      isRead: false,
      uname: uname,
    );

    List<String> ids = [currentUserID, reciverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  Future<void> markMessageAsRead(String recevierId) async {
    final currentUserID = _auth.currentUser!.uid;
    List<String> ids = [currentUserID, recevierId];
    ids.sort();
    String chatRoomID = ids.join('_');
    final unreadMessageQuery = _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .where('reciverID', isEqualTo: currentUserID)
        .where('isRead', isEqualTo: false);

    final unreadMessageSnapshot = await unreadMessageQuery.get();
    for (var doc in unreadMessageSnapshot.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  Stream<QuerySnapshot> getMessage(String userID, otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  Future<void> reportUser(String messageId, String userId) async {
    final currentUser = _auth.currentUser;
    final report = {
      'reportedBy': currentUser!.uid,
      'messageId': messageId,
      'messageOwnerId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('Reports').add(report);
  }

  Future<void> blockUser(String userId) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(userId)
        .set({});
    notifyListeners();
  }

  Future<void> unblockUser(String blockedUserId) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(blockedUserId)
        .delete();
  }

  Stream<List<Map<String, dynamic>>> getBlockedUsersStream(String userId) {
    return _firestore
        .collection('Users')
        .doc(userId)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
          final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();
          final userDocs = await Future.wait(
            blockedUserIds.map(
              (id) => _firestore.collection('Users').doc(id).get(),
            ),
          );

          return userDocs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
  }

  Future<void> createGroup(String groupName, List<String> memberIds) async {
    final currentUserID = _auth.currentUser!.uid;

    if (!memberIds.contains(currentUserID)) {
      memberIds.add(currentUserID);
    }

    Group newGroup = Group(id: '', name: groupName, memberIds: memberIds);

    DocumentReference groupRef = await _firestore
        .collection('groups')
        .add(newGroup.toMap());

    newGroup = Group(id: groupRef.id, name: groupName, memberIds: memberIds);

    for (String memberId in memberIds) {
      await _firestore
          .collection('Users')
          .doc(memberId)
          .collection('Groups')
          .doc(newGroup.id)
          .set({'groupName': groupName});
    }
  }

  Future<void> sendGroupMessage(
    String groupId,
    String message,
    String uname,
  ) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      reciverID: groupId,
      message: message,
      timestamp: timestamp,
      isRead: false,
      uname: uname,
    );

    await _firestore
        .collection("groups")
        .doc(groupId)
        .collection("messages")
        .add(newMessage.toMap());
  }

  Stream<List<Map<String, dynamic>>> getGroupMessages(String groupId) {
    return _firestore
        .collection("groups")
        .doc(groupId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots()
        .asyncMap((querySnapshot) async {
          List<Map<String, dynamic>> messagesWithSenderData = [];
          for (var doc in querySnapshot.docs) {
            Map<String, dynamic> messageData = doc.data();
            String senderId = messageData['senderID'];

            DocumentSnapshot senderDoc = await _firestore
                .collection('Users')
                .doc(senderId)
                .get();
            if (senderDoc.exists) {
              messageData['senderUname'] =
                  (senderDoc.data() as Map<String, dynamic>?)?['uname'] ??
                  'Unknown User';
              messageData['senderProfileImage'] =
                  (senderDoc.data() as Map<String, dynamic>?)?['profileImage']
                      as String?;
            } else {
              messageData['senderUname'] = 'Unknown User';
              messageData['senderProfileImage'] = null;
            }
            messageData['messageId'] = doc.id;
            messagesWithSenderData.add(messageData);
          }
          return messagesWithSenderData;
        });
  }

  Stream<List<Group>> getUserGroups() {
    final currentUserID = _auth.currentUser!.uid;

    return _firestore
        .collection('Users')
        .doc(currentUserID)
        .collection('Groups')
        .snapshots()
        .asyncMap((snapshot) async {
          final groupDocs = await Future.wait(
            snapshot.docs.map(
              (doc) => _firestore.collection('groups').doc(doc.id).get(),
            ),
          );
          return groupDocs
              .map((doc) => Group.fromMap(doc.id, doc.data()!))
              .toList();
        });
  }

  Future<void> deleteGroup(String groupId) async {
    final groupSnapshot = await _firestore
        .collection('groups')
        .doc(groupId)
        .get();
    if (groupSnapshot.exists) {
      final List<String> memberIds = List<String>.from(
        groupSnapshot.data()!['memberIds'] ?? [],
      );

      for (String userId in memberIds) {
        await _firestore
            .collection("Users")
            .doc(userId)
            .collection('Groups')
            .doc(groupId)
            .delete();
      }
    }

    final messagesSnapshot = await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .get();
    for (var messageDoc in messagesSnapshot.docs) {
      await messageDoc.reference.delete();
    }

    await _firestore.collection('groups').doc(groupId).delete();
  }
}
