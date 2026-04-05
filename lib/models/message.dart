import 'package:cloud_firestore/cloud_firestore.dart';

class Message{
  Message(this.id, this.senderId, this.text, this.timestamp);
  String id;
  String senderId;
  String text;
  Timestamp timestamp;

  @override
  String toString() {
    return """
    ID : $id,
    Sender ID : $senderId,
    Text : $text,
    Timestamp : ${timestamp.toString()}
    """
    ;
  }

  void setId(String id){
    this.id = id;
  }

  void setSenderId(String senderId){
    this.senderId = senderId;
  }

  void setText(String text){
    this.text = text;
  }

  void setTimestamp(Timestamp timestamp) {
    this.timestamp = timestamp;
  }
}