// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title ARVRChallengeToken
 * @dev This smart contract issues tokens to developers for completing AR/VR development challenges.
 */
contract ARVRChallengeToken {
    string public name = "ARVR Challenge Token";
    string public symbol = "ARVR";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    mapping(uint256 => Challenge) public challenges;
    mapping(address => mapping(uint256 => bool)) public hasCompletedChallenge;

    uint256 public challengeCount;
    address public owner;

    struct Challenge {
        string name;
        uint256 reward;
        bool isActive;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event ChallengeCreated(uint256 indexed challengeId, string name, uint256 reward);
    event ChallengeCompleted(uint256 indexed challengeId, address indexed developer);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
        totalSupply = 1000000 * (10 ** uint256(decimals));
        balanceOf[owner] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function createChallenge(string memory _name, uint256 _reward) public onlyOwner {
        challenges[challengeCount] = Challenge({
            name: _name,
            reward: _reward,
            isActive: true
        });
        emit ChallengeCreated(challengeCount, _name, _reward);
        challengeCount++;
    }

    function completeChallenge(uint256 _challengeId, address _developer) public onlyOwner {
        require(_challengeId < challengeCount, "Challenge does not exist");
        require(challenges[_challengeId].isActive, "Challenge is not active");
        require(!hasCompletedChallenge[_developer][_challengeId], "Challenge already completed");

        hasCompletedChallenge[_developer][_challengeId] = true;
        require(balanceOf[owner] >= challenges[_challengeId].reward, "Insufficient contract balance");

        balanceOf[owner] -= challenges[_challengeId].reward;
        balanceOf[_developer] += challenges[_challengeId].reward;

        emit ChallengeCompleted(_challengeId, _developer);
        emit Transfer(owner, _developer, challenges[_challengeId].reward);
    }

    function deactivateChallenge(uint256 _challengeId) public onlyOwner {
        require(_challengeId < challengeCount, "Challenge does not exist");
        challenges[_challengeId].isActive = false;
    }

    function getChallengeDetails(uint256 _challengeId) public view returns (string memory name, uint256 reward, bool isActive) {
        require(_challengeId < challengeCount, "Challenge does not exist");
        Challenge memory challenge = challenges[_challengeId];
        return (challenge.name, challenge.reward, challenge.isActive);
    }
}
