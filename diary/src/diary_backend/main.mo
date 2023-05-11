import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
import Text "mo:base/Text";

actor {
  public type Time = Time.Time;
  public type Homework = {
    title : Text;
    description : Text;
    dueDate : Time;
    completed : Bool;
  };

  var homeworkDiary = Buffer.Buffer<Homework>(0);

  public func addHomework(homework : Homework) : async Nat {
    homeworkDiary.add(homework);
    let id = homeworkDiary.size();
    return (id -1);
  };

  public shared query func getHomework(id : Nat) : async Result.Result<Homework, Text> {
    if (id < homeworkDiary.size() and id >= 0) {
      let homework = homeworkDiary.get(id);
      return #ok(homework);
    } else {
      return #err("Invalid homework ID");
    };
  };

  public shared func updateHomework(id : Nat, homework : Homework) : async Result.Result<(), Text> {
    if (id >= homeworkDiary.size() and id < 0) {
      return #err "Homework doesn't exist";
    };
    switch (?homeworkDiary.put(id, homework)) {
      case null { #err "Homework doesn't exist" };
      case (?homework) { return #ok(()) };
    };
  };

  public shared func markAsCompleted(id : Nat) : async Result.Result<(), Text> {
    if (id >= homeworkDiary.size() and id < 0) {
      return #err "Homework doesn't exist";
    };
    switch (?homeworkDiary.get(id)) {
      case null { #err "Homework doesn't exist" };
      case (?homework) {
        let complete : Homework = {
          title = homework.title;
          description = homework.description;
          dueDate = homework.dueDate;
          completed = true;
        };
        homeworkDiary.put(id, complete);
        #ok();
      };
    };
  };

  public shared func deleteHomework(id : Nat) : async Result.Result<(), Text> {
    if (id >= homeworkDiary.size() and id < 0) {
      return #err "Invalid homework ID";
    };

    switch (?homeworkDiary.remove(id)) {
      case null { return #err "Invalid homework ID" };
      case (?Homework) { return #ok(()) };
    };
  };

  public shared func getAllHomework() : async [Homework] {
    return Buffer.toArray(homeworkDiary);
  };

  public shared func getPendingHomework() : async [Homework] {
    let pendingHomework = Buffer.clone(homeworkDiary);

    pendingHomework.filterEntries(func(_, x) = (x.completed == false));

    return Buffer.toArray(pendingHomework);
  };

  public shared func searchHomework(searchTerm : Text) : async [Homework] {
    let matchingHomework = Buffer.clone(homeworkDiary);

    matchingHomework.filterEntries(func(_, x) = (Text.contains(x.title, #text searchTerm) or Text.contains(x.description, #text searchTerm)));

    return Buffer.toArray(matchingHomework);
  };

};