import Bool "mo:base/Bool";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
import IC "ic";
import Buffer "mo:base/Buffer";
import Error "mo:base/Error";
import Int "mo:base/Int";
import Nat "mo:base/Nat";

actor Verifier {
  public type StudentProfile = {
    name : Text;
    team : Text;
    graduate : Bool;
  };

  var studentProfileStore = HashMap.HashMap<Principal, StudentProfile>(0, Principal.equal, Principal.hash);

  private stable var studentsEntries : [(Principal, StudentProfile)] = [];

  public shared (mess) func addMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    switch (studentProfileStore.put(mess.caller, profile)) {
      case () { return #ok() };
    };
    return #err("Error");
  };

  //updateMyProfile : shared StudentProfile -> async Result.Result<(),Text>;
  public shared (mess) func updateMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    switch (studentProfileStore.replace(mess.caller, profile)) {
      case (null) { #err("Profile not found or not the owner") };
      case (?StudentProfile) { #ok() };
    };
  };

  //deleteMyProfile : shared () -> async Result.Result<(),Text>;
  public shared (mess) func deleteMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    switch (studentProfileStore.remove(mess.caller)) {
      case (null) { #err("Profile not found or not the owner") };
      case (?StudentProfile) { #ok() };
    };
  };

  //seeAProfile : shared Principal -> async Result.Result<StudentProfile, Text>;
  public shared query func seeAProfile(p : Principal) : async Result.Result<(), Text> {
    switch (studentProfileStore.get(p)) {
      case (null) { return #err("Profile does not exist") };
      case (?StudentProfile) { #ok() };
    };
  };

  public type CalculatorInterface = actor {
    add : shared (Int) -> async Int;
    sub : shared (Nat) -> async Int;
    reset : shared () -> async Int;
  };
  public type TestResult = Result.Result<(), TestError>;
  public type TestError = {
    #UnexpectedValue : Text;
    #UnexpectedError : Text;
  };

  public func test(canisterId : Principal) : async TestResult {

    let calculator : CalculatorInterface = actor (Principal.toText(canisterId));

    try {
      // Test reset function
      let resetResult = await calculator.reset();
      if (resetResult != 0) {
        return #err(#UnexpectedValue("Reset function failed"));
      };

      // Test add function
      let addResult = await calculator.add(1);
      if (addResult != 1) {
        return #err(#UnexpectedValue("Add function failed"));
      };

      // Test sub function
      let subResult = await calculator.sub(1);
      if (subResult != 0) {
        return #err(#UnexpectedValue("Sub function failed"));
      };

      return #ok();
    } catch (e) {
      return #err(#UnexpectedError("Something went wrong"));
    };
  };

  public func parseControllersFromCanisterStatusErrorIfCallerNotController(errorMessage : Text) : async [Principal] {
    let lines = Iter.toArray(Text.split(errorMessage, #text("\n")));
    let words = Iter.toArray(Text.split(lines[1], #text(" ")));
    var i = 2;
    let controllers = Buffer.Buffer<Principal>(0);
    while (i < words.size()) {
      controllers.add(Principal.fromText(words[i]));
      i += 1;
    };
    Buffer.toArray<Principal>(controllers);
  };

  public shared func verifyOwnership(canisterId : Principal, principalId : Principal) : async Bool {

    let ManagementCanister : IC.ManagementCanisterInterface = actor ("aaaaa-aa");
    try {
      let foo = await ManagementCanister.canister_status({
        canister_id = canisterId;
      });
      return false;
    } catch (e) {
      let canisterControllers = await parseControllersFromCanisterStatusErrorIfCallerNotController(Error.message(e));
      let canisterControllersBuffer = Buffer.fromArray<Principal>(canisterControllers);
      var returnBool : Bool = false;
      Buffer.iterate(
        canisterControllersBuffer,
        func(x : Principal) {
          if (x == principalId) {
            returnBool := true;
          };
        },
      );
      return returnBool;
    };
  };

  public shared func verifyWork(canisterId : Principal, principalId : Principal) : async Result.Result<(), Text> {
    let ownership = await verifyOwnership(canisterId, principalId);
    if (ownership == true) {
      let testing = await test(canisterId);
      if (Result.isOk(testing)) {
        return #ok;
      };
      return #err("Testing failed");
    } else {
      return #err("You're not the owner of this canister ID");
    };
    return #err("canister not found");
  };

};

// public shared func verifyWork(canisterId : Principal, principalId : Principal) : async Result.Result<(), Text> {
//   let isOwner = await verifyOwnership(canisterId, principalId);
//   if (isOwner == false) {
//     return #err("You are not the owner of this canister.");
//   };

//   let profileResult = await seeAProfile(principalId);
//   switch profileResult {
//     case (#ok(profile)) {
//       if (profile.graduate) {
//         return #err "You have already graduated.";
//       };
//       let testResult = await test(canisterId);
//       switch testResult {
//         case (#ok()) {
//           let updatedProfile = { profile with graduate = true };
//           let updateResult = await updateMyProfile(updatedProfile);
//           switch updateResult {
//             case (#ok()) {
//               return #ok();
//             };
//             case (#err(errMsg)) {
//               return #err errMsg;
//             };
//           };
//         };
//         case (#err(testError)) {
//           return #err "Test failed: ";
//         };
//       };
//     };
//     case (#err(errMsg)) {
//       return #err "No profile found for the given principalId.";
//     };
//   };
// };
