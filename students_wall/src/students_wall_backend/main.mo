import Int "mo:base/Int";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Result "mo:base/Result";
import Order "mo:base/Order";
import Buffer "mo:base/Buffer";

actor {

  public type Content = {
    #Text : Text;
    #Image : Blob;
    #Video : Blob;
  };

  public type Message = {
    vote : Int;
    content : Content;
    creator : Principal;
  };

  var messageId : Nat = 0;

  var wall = HashMap.HashMap<Nat, Message>(1, Nat.equal, Hash.hash);

  public shared (msg) func writeMessage(c : Content) : async Nat {
    let message : Message = { vote = 0; content = c; creator = msg.caller };
    wall.put(messageId, message);
    messageId += 1;
    return messageId -1;
  };

  public shared query func getMessage(messageId : Nat) : async Result.Result<Message, Text> {
    switch (wall.get(messageId)) {
      case (null) {
        return #err("Invalid message ID");
      };
      case (?message) {
        return #ok(message);
      };
    };
  };

  public shared (msg) func updateMessage(messageId : Nat, c : Content) : async Result.Result<(), Text> {
    switch (wall.get(messageId)) {
      case (null) {
        return #err("Invalid message ID");
      };
      case (?message) {
        if (message.creator == msg.caller) {
          let newMessage : Message = {
            vote = message.vote;
            content = c;
            creator = message.creator;
          };
          ignore wall.replace(messageId, newMessage);
          return #ok;
        } else {
          return #err("Caller is not the creator of the message");
        };
      };
    };
  };

  public shared (msg) func deleteMessage(id : Nat) : async Result.Result<(), Text> {
    if (id >= 0 and id < wall.size()) {
      wall.delete(id);
      return #ok();
    } else {
      return #err("Message ID requested invalid");
    };
  };

  public shared (msg) func upVote(id : Nat) : async Result.Result<(), Text> {
    switch (wall.get(id)) {
      case (null) {
        return #err("Error trying to obtain message");
      };
      case (?message) {
        let newMessage : Message = {
          vote = message.vote +1;
          content = message.content;
          creator = msg.caller;
        };
        ignore wall.replace(id, newMessage);
        return #ok;
      };
    };

  };
  public shared (msg) func downVote(id : Nat) : async Result.Result<(), Text> {
    switch (wall.get(id)) {
      case (null) {
        return #err("Error trying to obtain message");
      };
      case (?message) {
        let newMessage : Message = {
          vote = message.vote -1;
          content = message.content;
          creator = msg.caller;
        };
        ignore wall.replace(id, newMessage);
        return #ok;
      };
    };

  };

  private func compareVotes(m1 : Message, m2 : Message) : Order.Order {
    switch (Int.compare(m1.vote, m2.vote)) {
      case (#greater) return #less;
      case (#less) return #greater;
      case (_) return #equal;
    };
  };

  public shared query func getAllMessages() : async [Message] {
    var messagesBuffer = Buffer.Buffer<Message>(0);
    for (messages in wall.vals()) {
      messagesBuffer.add(messages);
    };
    return Buffer.toArray(messagesBuffer);
  };

  public shared query func getAllMessagesRanked() : async [Message] {
    var messagesBuffer = Buffer.Buffer<Message>(0);
    for (messages in wall.vals()) {
      messagesBuffer.add(messages);
    };
    messagesBuffer.sort(compareVotes);
    Buffer.reverse(messagesBuffer);
    return Buffer.toArray(messagesBuffer);
  };
};