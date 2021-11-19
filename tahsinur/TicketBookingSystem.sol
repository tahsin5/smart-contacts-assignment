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
    
     event TicketCancelled (
        uint seatId,
        address owner,
        uint256 price,
        string title,
        string date,
        string link,
        uint8 number,
        uint8 row,
        string cancellation
    );
    
    event TicketTransfer (
        uint seatId,
        address transferredFrom,
        address transferredTo,
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
    
    
    function verify(uint256 tokenID) public payable{
        // address buyer = address(this);
        // require(buyer == idToSeat[tokenID].owner, "Not allowed to view")
        emit TicketSold(tokenID, idToSeat[tokenID].nftContract, idToSeat[tokenID].owner, idToSeat[tokenID].price, idToSeat[tokenID].title, idToSeat[tokenID].date, idToSeat[tokenID].link, idToSeat[tokenID].number, idToSeat[tokenID].row);
    }
    
    function refund(string memory title,
        string memory date,
        uint8 number,
        uint8 row
        ) public payable{
        //To refund we just need to transfer the token to the theatre again
        uint256 itemId = findSeat(title, date, number, row);
        require(itemId != 0, "Seat not existing");
        require(theatre != idToSeat[itemId].owner, "Seat not sold");
        idToSeat[itemId].owner = theatre;
        
        emit TicketCancelled(itemId, idToSeat[itemId].owner, idToSeat[itemId].price, idToSeat[itemId].title, idToSeat[itemId].date, idToSeat[itemId].link, idToSeat[itemId].number, idToSeat[itemId].row, "Show cancelled");
        
    }
    
    

    function tradeTicket(string memory titleA,
        string memory dateA,
        uint8 numberA,
        uint8 rowA,
        string memory titleB,
        string memory dateB,
        uint8 numberB,
        uint8 rowB) public payable{
        
        // Case A: Both have tokens
        // Approve the nft contracts address beforehand
        
        uint256 itemIdA = findSeat(titleA, dateA, numberA, rowA);
        uint256 itemIdB = findSeat(titleB, dateB, numberB, rowB);
        
        address payable owner_A = idToSeat[itemIdA].owner;
        address payable owner_B = idToSeat[itemIdB].owner;
        
        require(owner_A != theatre, "Seat has not been sold yet");
        require(owner_B != theatre, "Seat has not been sold yet");
        
        
        // setApprovalForAll(idToSeat[itemIdA].nftContract, true);
        // setApprovalForAll(idToSeat[itemIdB].nftContract, true);
        IERC721(address(this)).transferFrom(owner_A, owner_B, itemIdA);
        IERC721(address(this)).transferFrom(owner_B, owner_A, itemIdB);
        
        idToSeat[itemIdA].owner = owner_B;
        idToSeat[itemIdB].owner = owner_A;
        
        emit TicketTransfer(itemIdA, owner_A, owner_B, idToSeat[itemIdA].price, idToSeat[itemIdA].title, idToSeat[itemIdA].date, idToSeat[itemIdA].link, idToSeat[itemIdA].number, idToSeat[itemIdA].row);
        emit TicketTransfer(itemIdB, owner_B, owner_A, idToSeat[itemIdB].price, idToSeat[itemIdB].title, idToSeat[itemIdB].date, idToSeat[itemIdB].link, idToSeat[itemIdB].number, idToSeat[itemIdB].row);
        
    }
    
    function tradeTicket(
        string memory title,
        string memory date,
        uint8 number,
        uint8 row) public payable{
            
        // Case B: A has token, B has coins
        // Call only from B,send ticket price as value
        // Approve the nft contract address beforehand
        
        
        
        uint256 itemId = findSeat(title, date, number, row);
        address payable owner = idToSeat[itemId].owner;
        require(owner != theatre, "Seat has not been sold yet");
        
        uint price = idToSeat[itemId].price;
        require(msg.value == price, "Please send the asking price for the seat");
        
        // IERC721(address(this)).approve(idToSeat[itemId].nftContract, itemId);
        // setApprovalForAll(idToSeat[itemIdA].nftContract, true);
        IERC721(address(this)).transferFrom(owner, msg.sender, itemId);
        owner.transfer(msg.value);
        idToSeat[itemId].owner = payable(msg.sender);
        
        emit TicketTransfer(itemId, owner, payable(msg.sender), price, idToSeat[itemId].title, idToSeat[itemId].date, idToSeat[itemId].link, idToSeat[itemId].number, idToSeat[itemId].row);
        
    }
        
}
