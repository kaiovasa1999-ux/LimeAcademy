// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract Library {
    address owner;

    constructor() {
        owner = msg.sender;
    }

    mapping(uint256 => Book) books;
    mapping(bytes32 => bool) doesBookExist;
    mapping(address => mapping(uint256 => bool)) borrowedBooks;
    mapping(uint256 => address[]) borrowHistory;

    event addedNewBook(uint256 _Id, string _title, uint256 _quantity);

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner cand do that");
        _;
    }

    modifier checkIfBookExist(uint256 _id) {
        bytes32 keyHash = keccak256(abi.encodePacked(_id));
        require(
            doesBookExist[keyHash] == true,
            "book doesn't exist in our library"
        );
        _;
    }

    /*
    if externel code size is > then 0 then the givan address
    is from contract
    */

    function isContractAddress(address _addr) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    struct Book {
        uint256 id;
        string title;
        uint256 quantity;
    }

    function AddNewBook(
        uint256 _id,
        string memory _title,
        uint256 _quantity
    ) public onlyOwner {
        bytes32 keyHash = keccak256(abi.encodePacked(_id));

        if (doesBookExist[keyHash] == true) {
            books[_id].quantity += _quantity;
            return;
        }

        books[_id] = Book(_id, _title, _quantity);
    }

    function RemoveBook(uint256 _bookID)
        public
        onlyOwner
        checkIfBookExist(_bookID)
    {
        delete books[_bookID];
    }

    function BorrowBook(uint256 _id) public checkIfBookExist(_id) {
        require(borrowedBooks[msg.sender][_id] == false);
        require(books[_id].quantity > 0);
        require(!isContractAddress(msg.sender));
        borrowedBooks[msg.sender][_id] = true;
        books[_id].quantity--;
        borrowHistory[_id].push(msg.sender);
    }

    //checks if this book is in library to be able to be returned back.
    function ReturnBook(uint256 _id) public checkIfBookExist(_id) {
        require(!isContractAddress(msg.sender));
        require(borrowedBooks[msg.sender][_id] == true);
        borrowedBooks[msg.sender][_id] = false;
        books[_id].quantity++;
    }

    function BookTenantsHistory(uint256 _Id)
        public
        view
        returns (address[] memory)
    {
        require(!isContractAddress(msg.sender));
        return borrowHistory[_Id];
    }
}
