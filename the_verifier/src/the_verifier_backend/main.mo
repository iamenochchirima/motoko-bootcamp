import Bool "mo:base/Bool";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Iter "mo:base/Iter";

actor Verifier {
  public type StudentProfile = {
    name : Text;
    team : Text;
    graduate : Bool;
  };

  var studentProfileStore = HashMap.HashMap<Principal, StudentProfile>(0, Principal.equal, Principal.hash);

  private stable var studentsEntries : [(Principal, StudentProfile)] = [];

  public shared ({ caller }) func addMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    studentProfileStore.put(caller, profile);
    return #ok();
  };

  public shared query ({ caller }) func seeAProfile(p : Principal) : async Result.Result<StudentProfile, Text> {
    switch (studentProfileStore.get(p)) {
      case (null) {
        return #err "Invalid user id";
      };
      case (?profile) {
        return #ok(profile);
      };
    };
  };

  public shared ({ caller }) func updateMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    switch (studentProfileStore.get(caller)) {
      case (null) {
        return #err "Invalid user id";
      };
      case (?profile) {
        ignore studentProfileStore.replace(caller, profile);
        return #ok();
      };
    };
  };

  public shared ({ caller }) func deleteMyProfile() : async Result.Result<(), Text> {
    switch (studentProfileStore.get(caller)) {
      case (null) {
        return #err "The student doesn't have a profile";
      };
      case (?profile) {
        studentProfileStore.delete(caller);
        return #ok();
      };
    };
  };

  system func preupgrade() {
    studentsEntries := Iter.toArray(studentProfileStore.entries());
  };

  system func postupgrade() {
    studentProfileStore := HashMap.fromIter<Principal, StudentProfile>(studentsEntries.vals(), 1, Principal.equal, Principal.hash);
    // if (studentProfileStore.size() < 1) {
    //     studentProfileStore.put(owner, supply);
    // };
  };

  public type TestResult = Result.Result<(), TestError>;
  public type TestError = {
    #UnexpectedValue : Text;
    #UnexpectedError : Text;
  };

  public shared func test(canisterId : Principal): async TestResult {
    
  };
};
