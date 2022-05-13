
import 'chat_message_model.dart';

abstract class Observer<T> {
  update(T data);
}

// class Test2 extends Observer<int>{
//   @override
//   update(int data) {
//     // TODO: implement update
//     return null;
//   }
// }

// class MyObserver<T>{
//   List<Observer<T>> list = List();
//   T msg;

//   // register(Observer<T> ob){
//   //   list.add(ob);
//   // }
//   register(dynamic obj){
//     // Observer<T> ob = obj;
//     list.add(obj);

//     List<Observer<int>> l2;
//     l2.add(new Test2());
//     list.add(new Test2());
//   }

//   unregister(Observer<T> ob){
//     list.remove(ob);
//   }

//   notifyAll(){
//     for (var item in list) {
//       item.update(msg);
//     }
//   }

//   changeMsg(T msg){
//     this.msg = msg;
//     notifyAll();
//   }
// }

class MyObserver{
  List<Observer<ChatMessage>> list = List();
  ChatMessage msg;

  register(Observer<ChatMessage> obj){
    list.add(obj);
  }

  unregister(Observer<ChatMessage> ob){
    list.remove(ob);
  }

  notifyAll(){
    for (var item in list) {
      item.update(msg);
    }
  }

  changeMsg(ChatMessage msg){
    this.msg = msg;
    notifyAll();
  }
}


