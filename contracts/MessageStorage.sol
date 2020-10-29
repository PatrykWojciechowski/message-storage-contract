pragma solidity ^0.6.0;

contract MessageStorage {
    struct RelatedMessage {
        string authorName;
        string message;
    }

    address public owner;
    mapping(address => RelatedMessage) public messages;

    constructor() public {
        owner = msg.sender;
    }

    function terminate() external ownerOnly {
        selfdestruct(msg.sender);
    }

    modifier ownerOnly() {
        require(msg.sender == owner, "Only owner is allowed to do this!");
        _;
    }

    function addData(string memory _message, string memory _authorName) public payable {
        RelatedMessage memory message = RelatedMessage({
            authorName : _authorName,
            message : _message
            });

        messages[msg.sender] = message;
    }

    function removeDataFromOwnAddress() public payable {
        RelatedMessage memory message = RelatedMessage({
            authorName : '',
            message : ''
            });

        messages[msg.sender] = message;
    }

    function removeDataFromAnyAddress(address _addressToRemoveData) public payable ownerOnly {
        RelatedMessage memory message = RelatedMessage({
            authorName : '',
            message : ''
            });

        messages[_addressToRemoveData] = message;
    }
}