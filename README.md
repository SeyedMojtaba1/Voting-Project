
# Voting Contract

This Solidity-based voting contract allows for a secure and transparent voting process on the Ethereum blockchain. The contract ensures that only authorized voters can cast their votes, and the results can be verified publicly. The project includes features for initializing a voting session, giving voting rights, casting votes, and determining the winner after the voting period ends.

## Features

1. **Chairman Authorization**: Only the chairman, who deploys the contract, can grant voting rights and end the voting session.
2. **Secure Voting Process**: Ensures that each voter can vote only once, and only authorized voters can participate.
3. **Transparent Winner Announcement**: After the voting period ends, the contract allows the public to view the winning proposal.

## Contract Components

### Structs

- **Voter**:
  - `access_to_vote` (bool): Indicates if the voter has the right to vote.
  - `voted` (bool): Indicates if the voter has already voted.
  - `vote` (uint): The ID of the proposal the voter voted for.

- **Proposal**:
  - `name` (bytes32): The name of the proposal.
  - `voteCount` (uint): The number of votes the proposal has received.

### State Variables

- `chairman` (address): The address of the chairman.
- `endtime` (uint): The timestamp when the voting ends.
- `voters` (mapping(address => Voter)): A mapping to store voter details.
- `proposals` (Proposal[]): An array of proposals.

### Constructor

Initializes the contract with the duration of the voting period and a list of proposal names. The chairman is set to the address deploying the contract, and the end time is calculated.

```solidity
constructor (uint _time, bytes32[] memory proposalNames) {
    chairman = msg.sender;
    for(uint i = 0 ; i < proposalNames.length ; i++){
        proposals.push(Proposal({name: proposalNames[i], voteCount: 0}));
    }
    endtime = block.timestamp + _time;
}
```

### Functions

- **winner**:
  Returns the winning proposal details after the voting period ends.
  ```solidity
  function winner() public view end_voting returns (uint, bytes32, uint) {
      uint winnerID = getMostVote();
      return (winnerID, proposals[winnerID].name, proposals[winnerID].voteCount);
  }
  ```

- **getMostVote**:
  Finds the proposal with the highest vote count.
  ```solidity
  function getMostVote() public view returns(uint) {
      uint largest = 0; 
      uint save = 0;
      for(uint i = 0; i < proposals.length; i++){
          if(proposals[i].voteCount > largest) {
              largest = proposals[i].voteCount; 
              save = i;
          } 
      }
      return save;
  }
  ```

- **giveRightToVote**:
  Grants a voter the right to vote. Can only be called by the chairman.
  ```solidity
  function giveRightToVote(address voter) public is_chairman returns (bool) {
      require(!voters[voter].voted, "You voted already!");
      voters[voter].access_to_vote = true;
      voters[voter].voted = false;
      return true;
  }
  ```

- **vote**:
  Allows a voter to cast their vote for a proposal.
  ```solidity
  function vote(uint ID) public has_right_to_vote(msg.sender) not_voted(msg.sender) returns (bool) {
      proposals[ID].voteCount += 1;
      voters[msg.sender].voted = true;
      voters[msg.sender].vote = ID;
      return true;
  }
  ```

- **votingEnd**:
  Ends the voting session and triggers the winner announcement. Can only be called by the chairman.
  ```solidity
  function votingEnd() public is_chairman end_voting returns (bool) {
      winner();
      return true;
  }
  ```

### Modifiers

- **end_voting**:
  Ensures that the function can only be called after the voting period ends.
  ```solidity
  modifier end_voting {
      require(block.timestamp > endtime, "Voting time is not over!");
      _;
  }
  ```

- **not_voted**:
  Ensures that the voter has not already voted.
  ```solidity
  modifier not_voted(address voter) {
      require(!voters[voter].voted, "You voted already!");
      _;
  }
  ```

- **is_chairman**:
  Ensures that the function can only be called by the chairman.
  ```solidity
  modifier is_chairman {
      require(msg.sender == chairman, "You are not chairman!");
      _;
  }
  ```

- **has_right_to_vote**:
  Ensures that the voter has the right to vote.
  ```solidity
  modifier has_right_to_vote(address voter) {
      require(voters[voter].access_to_vote, "You have no right to vote!");
      _;
  }
  ```

## Deployment

Deploy the contract with the duration of the voting period (in seconds) and an array of proposal names. The chairman will be the address that deploys the contract.

## Example

```solidity
bytes32[] memory proposalNames = new bytes32[](2);
proposalNames[0] = "Proposal 1";
proposalNames[1] = "Proposal 2";
Voting voting = new Voting(604800, proposalNames); // Voting period is 1 week
```

## License

This project is licensed under the MIT License.
