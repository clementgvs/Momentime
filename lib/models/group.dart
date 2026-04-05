import 'package:flutter/cupertino.dart';
import 'package:momentime/models/message.dart';

class Group{
  Group(this.id, this.name, this.members, this.messages);
  String id;
  String name;
  List<String> members;
  List<Message> messages;

  @override
  String toString() {
    return """
    ID: $id,
    Name : $name,
    Members : ${members.toString()}
    Messages : ${messages.toString()}
    """
    ;
  }

  void setId(String id){
    this.id = id;
  }

  void setName(String name){
    this.name = name;
  }

  void setMembers(List<String> members){
    this.members = members;
  }

  void setMessages(List<Message> messages){
    this.messages = messages;
  }
}