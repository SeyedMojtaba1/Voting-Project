// SPDX-License-Identifier: MIT
pragma solidity >0.7.0 <0.9.0;

struct Voter {
bool access_to_vote; 
bool voted;          
uint vote;                
} 

struct Proposal {
bytes32 name;
uint voteCount;
}

contract voting{

//  all variables defined here
    address public chairman;
    uint public endtime;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;

//  In constructor of voting contract determined chairman, proposals and endtime 
    constructor (uint _time, bytes32[] memory proposalNames) {
        chairman = msg.sender;
        for(uint i = 0 ; i < proposalNames.length ; i++){
            proposals.push(Proposal({name: proposalNames[i], voteCount: 0}));
        }

//      end of voting => deploying time + desired time
        endtime = block.timestamp + _time;
    }

//  after checking some conditions announces that who is winner
    function winner() public view end_voting returns (uint,bytes32,uint) {
        uint winnerID = getMostVote();
        return (winnerID , proposals[winnerID].name, proposals[winnerID].voteCount);
    }

//  By this function we can find winner's ID and return
    function getMostVote() public view returns(uint){
        uint largest = 0; 
        uint i; 
        uint save = 0;
        
        for(i = 0; i < proposals.length; i++){
            if(proposals[i].voteCount > largest) {
                largest = proposals[i].voteCount; 
                save = i;
            } 
        }
        return save;
    }
    
//  By this function chairman can give the voter the ability of voting
    function giveRightToVote(address voter) public not_voted(voter) is_chairman returns(bool){
        voters[voter].access_to_vote = true;
        voters[voter].voted = false;
        return true;
    }

//  Voter can vote by vote-function
    function vote(uint ID) public has_right_to_vote(msg.sender) not_voted(msg.sender) returns (bool){
        proposals[ID].voteCount += 1;
        voters[msg.sender].voted = true;
        voters[msg.sender].vote = ID;
        return true;
    }


    function votingEnd() public is_chairman returns (bool){
        endtime = block.timestamp;
        winner();
        return true;
    }

//  Definition of requiered modifiers
    modifier end_voting{
        require(block.timestamp > endtime,"Voting time is not over!");
        _;
    }

    modifier not_voted(address voter){
        require(voters[voter].voted == false,"You voted already!");
        _;
    }

    modifier is_chairman{
        require(msg.sender == chairman,"You are not chairman!");
        _;
    }

    modifier has_right_to_vote(address voter) {
        require(voters[voter].access_to_vote, "You have no right to vote!");
        _;
    }
}