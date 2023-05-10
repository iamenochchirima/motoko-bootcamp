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

  var homeworkDiary = Buffer.Buffer<Homework>(1);

  public func addHomework(homework : Homework) : async Nat {
    homeworkDiary.add(homework);
    let id = homeworkDiary.size();
    return id;
  };

  public shared query func getHomework(id : Nat) : async Result.Result<Homework, Text> {
    if (id <= homeworkDiary.size()) {
      let homework = homeworkDiary.get(id - 1);
      return #ok(homework);
    } else {
      return #err("Invalid homework ID");
    };

  };

  public shared func updateHomework(id : Nat, homework : Homework) : async Result.Result<(), Text> {
    if (id >= homeworkDiary.size()) {
      return #err "Homework doesn't exist";
    };
    switch (?homeworkDiary.put(id, homework)) {
      case null { #err "Homework doesn't exist" };
      case (?homework) { return #ok(()) };
    };
  };

  public shared func markAsCompleted(id : Nat) : async Result.Result<(), Text> {
    if (id >= homeworkDiary.size()) {
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

  public shared func deleteHomework(homeworkId : Nat) : async Result.Result<(), Text> {
    if (homeworkId >= homeworkDiary.size()) {
      return #err "Invalid homework ID";
    };

    switch (?homeworkDiary.remove(homeworkId)) {
      case null { return #err "Invalid homework ID" };
      case (?Homework) { return #ok(()) };
    };
  };

  public shared func getAllHomework() : async [Homework] {
    return Buffer.toArray(homeworkDiary);
  };

  public shared func searchHomework(searchTerm : Text) : async [Homework] {
    let matchingHomework : Buffer.Buffer<Homework>(1);
    for (homework in homeworkDiary.vals()) {
      if (Text.contains(homework.title, searchTerm) or Text.contains(homework.description, searchTerm)) {
        matchingHomework.add(homework);
      };
    };
    return Buffer.toArray(matchingHomework);
  };

};

//  public shared func getPendingHomework() : async [Homework] {
//     var pendingHomework : [Homework] = [];
//     let allHomework = await getAllHomework();

//     for (homework in allHomework.vals()) {
//       if (not homework.completed) {
//         pendingHomework := Array.append(pendingHomework, homework);
//       };
//     };

//     return pendingHomework;
//   };

// public shared query func getPendingHomework() : async [Homework] {
//     var pendingHomework : [Homework] = [];
//     for (i in Iter.range(0, homeworkDiary.size())) {
//       let homework = homeworkDiary.get(i);
//       if (?homework.completed) {
//         pendingHomework.add(homework);
//       };
//     };
//     return pendingHomework;
//   };

// public shared func getAllHomework() : async [Homework] {
//   return homeworkDiary.toSeq();
// };

// public shared func getPendingHomework() : async [Homework] {
//   return homeworkDiary.toSeq().filter((homework) = >! homework.completed);
// };

// public shared func searchHomework(searchTerm : Text) : async [Homework] {
//   return homeworkDiary.toSeq().filter(
//     (homework) => homework.title.contains(searchTerm) | | homework.description.contains(searchTerm)
//   );
// };
