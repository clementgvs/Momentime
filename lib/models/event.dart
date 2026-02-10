import 'dart:ui';

class Event{
  Event(this.name, this.from, this.to, this.background, this.isAllDay);

  String name;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;

  @override
  String toString() {
    return """
    Name : $name,
    From : ${from.toString()},
    To : ${to.toString()},
    Color : ${background.toString()},
    AllDay ? : $isAllDay
    """
    ;
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