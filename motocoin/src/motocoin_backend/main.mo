import Account "account";
import TrieMap "mo:base/TrieMap";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Option "mo:base/Option";

actor MotoCoin {

  public type Subaccount = Blob;
  public type Account = Account.Account;

  var ledger = TrieMap.TrieMap<Account, Nat>(Account.accountsEqual, Account.accountsHash);

  public shared query func name() : async Text {
    "MotoCoin";
  };

  public shared query func symbol() : async Text {
    "MOC";
  };

  public shared query func totalSupply() : async Nat {
    var supply : Nat = 0;
    for ((key, value) in ledger.entries()) {
      supply += 1;
    };
    return supply;
  };

  public query func balanceOf(who : Account) : async Nat {
    let balance : Nat = switch (ledger.get(who)) {
      case null 0;
      case (?result) result;
    };
    return balance;
  };

  public shared (msg) func transfer(from : Account, to : Account, amount : Nat) : async Result.Result<(), Text> {
    let fromBalance = await balanceOf(from);

    if (fromBalance >= amount) {
      let newFromBalance : Nat = fromBalance - amount;
      ledger.put(from, newFromBalance);
      let toBalance = await balanceOf(to);
      let newToBalance = toBalance + amount;
      ledger.put(to, newToBalance);
      return #ok();
    } else {
      return #err "Insufficient funds";
    };
  };

  let studentsCall : actor {
    getAllStudentsPrincipal : shared () -> async [Principal];
  } = actor ("rww3b-zqaaa-aaaam-abioa-cai");

  public shared func airdrop() : async Result.Result<(), Text> {

    try {
      let students = await studentsCall.getAllStudentsPrincipal();

      for (p in students.vals()) {
        let mainAccount : Account = {
          owner = p;
          subaccount = null;
        };
        // let currentBalance = await balanceOf(mainAccount);
        let currentBalance = Option.get(ledger.get(mainAccount), 0);
        let newBalance = currentBalance + 100;
        ledger.put(mainAccount, newBalance);
      };
      #ok(());
    } catch (e) {
      return #err("Something went wrong");
    };

  };

};
