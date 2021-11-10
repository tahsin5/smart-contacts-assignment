// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0;


contract seat {
    
    string Title;
    string Date;
    uint8 Price;
    string Link;
    
    uint8 Number;
    uint8 Row;
    
    bool public Available = true;
    string Owner = "none";
    
    
    constructor(string memory _Title, string memory _Date, uint8 _Price, string memory _Link, uint8 _Number, uint8 _Row) {
        Title = _Title;
        Date = _Date;
        Price = _Price;
        Link = _Link;
        Number = _Number;
        Row = _Row;
    }
    
    function getInfos() view public returns(string memory, string memory, uint8, string memory, uint8, uint8, bool, string memory) {
        return (Title, Date, Price, Link, Number, Row, Available, Owner);
    }
    
    function buy(string memory name) public returns(uint){
        Available = false;
        Owner = name;
        uint token = 1234;
        return token;
    }
    
    function refund() public {
        Available = true;
        Owner = "none";
    }
    
}
