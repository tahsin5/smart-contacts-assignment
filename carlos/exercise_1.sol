// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;


contract TicketBookingSystem {
    // Try to implement it with an struct
    /*struct Place{
        uint8 Number;
        uint8 Row;
    }*/
    uint8 Price;
    string Title;
    string Date;
    string Link;
    uint8 Number;
    uint8 Row;
    function initialize(uint8 pri, string memory tit, string memory dat, uint8 num, uint8 ro) public {
        Price = pri;
        Title = tit;
        Date = dat;
        Number = num;
        Row = ro;
        Link = "https://seatplan.com/";
    }
    
    function check_initialization() public view returns(uint8, string memory, string memory, string memory, uint8, uint8){
        return (Price, Title, Date, Link, Number, Row);
    }
    
}
