//TaskCallBack
typedef OnDoCallback<T> = Function(T data);
typedef OnComplete<T> = Function(T data);
typedef OnFailed<T> = Function(T data);

typedef OnRunCallBack<T,U> = U Function(T data);
// abstract class Task<T>{
//    void onDo(String speed);
//    void onComplete(T ret);
//    void onFailed(String msg);
// }
