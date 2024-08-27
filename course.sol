// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CourseCompletionCertificate {

    struct User {
        bool registered;
        uint256 levelCompleted;
        bool isCertified;
    }

    mapping(address => User) public users;
    mapping(address => bool) public certificates;
    address public owner;
    uint256 public totalLevels = 5;

    event UserRegistered(address indexed user);
    event VideoCompleted(address indexed user, uint256 level);
    event QuizPassed(address indexed user, uint256 level);
    event CertificateIssued(address indexed user);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    modifier onlyRegistered() {
        require(users[msg.sender].registered, "You must be registered to perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function register() external {
        require(!users[msg.sender].registered, "User already registered.");
        users[msg.sender] = User(true, 0, false);
        emit UserRegistered(msg.sender);
    }

    function completeVideo() external onlyRegistered {
        User storage user = users[msg.sender];
        require(user.levelCompleted < totalLevels, "All levels completed.");
        user.levelCompleted++;
        emit VideoCompleted(msg.sender, user.levelCompleted);
    }

    function passQuiz() external onlyRegistered {
        User storage user = users[msg.sender];
        require(user.levelCompleted > 0, "You must complete a video first.");
        require(!user.isCertified, "You are already certified.");
        
        if (user.levelCompleted == totalLevels) {
            user.isCertified = true;
            certificates[msg.sender] = true;
            emit CertificateIssued(msg.sender);
        } else {
            emit QuizPassed(msg.sender, user.levelCompleted);
        }
    }

    function verifyCertificate(address _user) external view returns (bool) {
        return certificates[_user];
    }

    function setTotalLevels(uint256 _totalLevels) external onlyOwner {
        totalLevels = _totalLevels;
    }

    function isCertified(address _user) external view returns (bool) {
        return users[_user].isCertified;
    }
}