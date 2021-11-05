// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;


struct Place {
    uint8 Number;
    uint8 Row;
}

struct Seat {
    string Title;
    string Date;
    uint8 Price;
    mapping(uint => Place) place;
    string Link;
}

contract TicketBookingSystem {
    {
        
    }
}