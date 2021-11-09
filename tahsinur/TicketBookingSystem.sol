// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

// import './Seat.sol';

contract Seat {
    
    uint8 Price;
    string Title;
    string Date;
    string Link;
    uint8 Number;
    uint8 Row;
    
    function initialize(uint8 price, string memory title, string memory date, uint8 num, uint8 row) public returns(bool success){
        Price = price;
        Title = title;
        Date = date;
        Number = num;
        Row = row;
        Link = "https://seatplan.com/";
        return true;
    }
    
    function get() public view returns(uint8, string memory, string memory, string memory, uint8, uint8){
        return (Price, Title, Date, Link, Number, Row);
    }
    
    
}


contract TicketBookingSystem {
    // Try to implement it with an struct
    /*struct Place{
        uint8 Number;
        uint8 Row;
    }*/

    string Title;
    uint[] public seatsArray;
    
    Seat seat;  // Define a seat object
    
    function seatInstantiation() public{
        seat = new Seat();
    }
    
    function initialize(uint8 price, string memory title, string memory date, uint8 num, uint8 row) public returns(bool success){
        return seat.initialize(price, title, date, num, row);
    }
    
    function check_initialization() public view returns(uint8, string memory, string memory, string memory, uint8, uint8){
        return seat.get();
    }
    
}
