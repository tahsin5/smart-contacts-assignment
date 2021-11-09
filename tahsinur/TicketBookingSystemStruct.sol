// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.5.1;

contract TicketBookingSystem{

    struct seat {
        uint8 Price;
        string Title;
        string Date;
        string Link;
        uint8 Number;
        uint8 Row;
    }
    
    mapping(uint256 => seat) seats;  // Map int to a seat object
    uint256[] public seatIDs;        // Array containing IDs of the seat
    
         function initialize(uint8 price, string memory title, string memory date, uint8 num, uint8 row) public {
            uint256 id = num; // Create ID generation function later 
            seat storage newSeat = seats[id];
            newSeat.Price = price;
            newSeat.Title = title;
            newSeat.Date = date;
            newSeat.Number = num;
            newSeat.Row = row;
            seatIDs.push(id);
        }
        
        function getSeat(uint256 id) public view returns (uint8, string memory, string memory, string memory, uint8, uint8){
            seat storage s = seats[id];
            return (s.Price, s.Title, s.Date, s.Link, s.Number, s.Row);
        }
        
        // To be implemented
        // function getAllSeats() public view returns () {
            
        // }
        
}
