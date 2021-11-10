// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0;


contract seat {
    
    string public Title;
    string public Date;
    uint8 public Price;
    string public Link;
    
    uint8 public Number;
    uint8 public Row;
    
    bool public Available = true;
    string public Owner = "none";
    
    
    constructor(string memory _Title, string memory _Date, uint8 _Price, string memory _Link, uint8 _Number, uint8 _Row) {
        Title = _Title;
        Date = _Date;
        Price = _Price;
        Link = _Link;
        Number = _Number;
        Row = _Row;
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
