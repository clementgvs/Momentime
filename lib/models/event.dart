import 'dart:ui';

class Event{
  Event(this.id, this.name, this.from, this.to, this.background, this.isAllDay);
  String id;
  String name;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;

  @override
  String toString() {
    return """
    ID : $id,
    Name : $name,
    From : ${from.toString()},
    To : ${to.toString()},
    Color : ${background.toString()},
    AllDay ? : $isAllDay
    """
    ;
  }

  void setId(String id){
    this.id = id;
  }

  void setName(String nName){
    name = nName;
  }

  void setFrom(DateTime nfrom){
    from = nfrom;
  }

  void setTo(DateTime nto){
    to = nto;
  }

  void setIsAllDay(bool nIsAllDay){
    isAllDay = nIsAllDay;
  }
}