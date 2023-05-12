import Bool "mo:base/Bool";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

actor {
  public type StudentProfile = {
    name : Text;
    team : Text;
    graduate : Bool;
  };

  var studentProfileStore = HashMap.HashMap<Principal, StudentProfile>(0, Principal.equal, Principal.hash);

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
};
