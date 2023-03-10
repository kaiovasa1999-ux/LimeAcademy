// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract Library {
    address owner;

    constructor() {
        owner = msg.sender;
    }

    mapping(uint256 => Book) books;
    mapping(bytes32 => bool) doesBookExist;
    mapping(address => mapping(uint256 => bool)) borrowedBooks;
    mapping(uint256 => address[]) borrowHistory;

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can do that");
        _;
    }

    modifier checkIfBookExist(uint256 _id) {
        bytes32 keyHash = keccak256(abi.encodePacked(_id));
        require(
            doesBookExist[keyHash] == false,
            "book doesn't exist in our library"
        );
        _;
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
    ) external onlyOwner {
        bytes32 keyHash = keccak256(abi.encodePacked(_id));

        if (doesBookExist[keyHash] == true) {
            books[_id].quantity += _quantity;
            return;
        }

        books[_id] = Book(_id, _title, _quantity);
    }

    function BorrowBook(uint256 _id) external checkIfBookExist(_id) {
        require(borrowedBooks[msg.sender][_id] == false);
        require(books[_id].quantity > 0);
        borrowedBooks[msg.sender][_id] = true;
        books[_id].quantity--;
        borrowHistory[_id].push(msg.sender);
    }

    function ReturnBook(uint256 _id) external {
        require(borrowedBooks[msg.sender][_id] == true);
        borrowedBooks[msg.sender][_id] = false;
        books[_id].quantity++;
    }

    function BookTenantsHistory(uint256 _Id)
        external
        view
        returns (address[] memory)
    {
        return borrowHistory[_Id];
    }
}
