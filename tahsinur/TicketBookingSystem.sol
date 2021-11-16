// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract TicketBookingSystem is ERC721URIStorage {
    
    using Counters for Counters.Counter;
    
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    address payable theatre;

    struct Seat {
        uint itemId;
        address nftContract;
        address payable owner;
        uint256 price;
        string title;
        string date;
        string link;
        uint8 number;
        uint8 row;
    }
    
    mapping(uint256 => Seat) private idToSeat;

    event TicketCreated (
        uint indexed seatId,
        address indexed nftContract,
        uint256 price,
        string title,
        string date,
        string link,
        uint8 number,
        uint8 row
    );
    
    event TicketSold (
        uint indexed seatId,
        address indexed nftContract,
        address payable owner,
        uint256 price,
        string title,
        string date,
        string link,
        uint8 number,
        uint8 row
    );
    

    constructor() ERC721("Ticket Booking System", "TBS") {
        theatre = payable(msg.sender);
    }
    
    function memcmp(bytes memory a, bytes memory b) internal pure returns(bool){
        return (a.length == b.length) && (keccak256(a) == keccak256(b));
    }
    function strcmp(string memory a, string memory b) internal pure returns(bool){
        return memcmp(bytes(a), bytes(b));
    }

    function getSeatItem(uint256 seatId) public view returns (Seat memory) {
        return idToSeat[seatId];
    }
    
    function findSeat(
        string memory title,
        string memory date,
        uint8 number,
        uint8 row
        ) public view returns (uint256){
        
        uint seatAmount = _itemIds.current();  // Get length of seats
        
        // Loop through all current seats and match. Return seat ID
        for (uint i = 0; i < seatAmount; i++) {
            if (strcmp(idToSeat[i + 1].title, title) && strcmp(idToSeat[i + 1].date, date) && idToSeat[i + 1].number == number && idToSeat[i + 1].row == row) {
                return idToSeat[i + 1].itemId;
            }
        }
        return 0;
    }


    
    // 100000000,"test show", "01/01/1970", "test.com", 1,1
    function createTcketToSale(
        uint256 price,
        string memory title,
        string memory date,
        string memory link,
        uint8 number,
        uint8 row
        ) public payable {
            
    require(msg.sender == theatre, "You cannot create tickets");

    _itemIds.increment();
    uint256 itemId = _itemIds.current();
    
    _mint(theatre, itemId);
    _setTokenURI(itemId, link);
    setApprovalForAll(address(this), true);
  
    idToSeat[itemId] = Seat(itemId, address(this), theatre, price, title, date, link, number, row);

    emit TicketCreated(itemId, address(this), price, title, date, link, number, row);
    
    }
    
    // "test show", "01/01/1970", 1,1
    function Buy(
        string memory title,
        string memory date,
        uint8 number,
        uint8 row
        ) public payable {
            
        uint256 itemId = findSeat(title, date, number, row);
        require(itemId != 0, "Seat not existing");
        
        address payable owner = idToSeat[itemId].owner;
        require(owner == theatre, "Seat already sold, choose another one"); // If the owner is not theatre, then ticket already sold
        
        uint price = idToSeat[itemId].price;
        require(msg.value == price, "Please submit the asking price in order to complete the purchase");

        theatre.transfer(msg.value);
        IERC721(address(this)).transferFrom(theatre, msg.sender, itemId);  // Send token to sender
        idToSeat[itemId].owner = payable(msg.sender);
        _itemsSold.increment();
        
        emit TicketSold(itemId, address(this), payable(msg.sender), idToSeat[itemId].price, idToSeat[itemId].title, idToSeat[itemId].date, idToSeat[itemId].link, idToSeat[itemId].number, idToSeat[itemId].row);
    
    }
    
    function showAvailableTickets() public view returns (Seat[] memory){
        uint itemCount = _itemIds.current();
        uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint currentIndex = 0;

        Seat[] memory items = new Seat[](unsoldItemCount);
        for (uint i = 0; i < itemCount; i++) {
            if (idToSeat[i + 1].owner == theatre) {
                uint currentId = i + 1;
                Seat storage currentItem = idToSeat[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
   
        return items;
    }
    
    function showSoldTickets() public view returns (Seat[] memory){
        uint itemCount = _itemIds.current();
        uint currentIndex = 0;

        Seat[] memory items = new Seat[](itemCount);

        for (uint i = 0; i < itemCount; i++) {
            if (idToSeat[i + 1].owner != theatre) {
                uint currentId = i + 1;
                Seat storage currentItem = idToSeat[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        
        return items;
    }
    
    
    event Log(address indexed sender, string message);
    event intLog(address indexed sender, uint256 message);
    event seatLog(address indexed sender, Seat message);
    
    
    function verify(uint256 tokenID) public payable{
        address buyer = address(this);
        // require(buyer == idToSeat[tokenID].owner, "Not allowed to view")
        emit TicketSold(tokenID, buyer, idToSeat[tokenID].owner, idToSeat[tokenID].price, idToSeat[tokenID].title, idToSeat[tokenID].date, idToSeat[tokenID].link, idToSeat[tokenID].number, idToSeat[tokenID].row);
    }
    
    
  
}
