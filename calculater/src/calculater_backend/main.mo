import Float "mo:base/Float";

actor {
  var counter : Float = 0;

  public shared func add(x : Float) : async Float {
    counter += x;

    return counter;
  };

  public shared func sub(x : Float) : async Float {
    counter -= x;

    return counter;
  };

  public shared func mul(x : Float) : async Float {
    counter *= x;

    return counter;
  };

  public shared func div(x : Float) : async Float {

    if (x == 0) {
      return 0;
    } else {
      counter /= x;
      return counter;
    };

  };

  public shared func reset() : async () {
    counter := 0;
  };

  public shared func see() : async Float {
    return counter;
  };

  public shared func power(x : Float) : async Float {
    counter **= x;
    return counter;
  };

  public shared func sqr() : async Float {
    var sqrtCount = Float.sqrt(counter);
    return sqrtCount;
  };

  public shared func floor() : async Int {
    var floorFloat : Float = Float.nearest(counter);
    var floorInt : Int = Float.toInt(floorFloat);
    return floorInt;
  };
};