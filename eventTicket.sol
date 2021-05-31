pragma solidity ^0.5.0;

    /*
        The EventTickets contract keeps track of the details and ticket sales of one event.
     */

contract EventTickets {

    /*
        Create a public state variable called owner.
        Use the appropriate keyword to create an associated getter function.
        Use the appropriate keyword to allow ether transfers.
     */
     
     
    address payable owner;
    uint   TICKET_PRICE = 100 wei;

    /*
        Create a struct called "Event".
        The struct has 6 fields: description, website (URL), totalTickets, sales, buyers, and isOpen.
        Choose the appropriate variable type for each field.
        The "buyers" field should keep track of addresses and how many tickets each buyer purchases.
    */
    
    struct Event {
        
        string description;
        string website;
        uint256 totalTickets;
        uint256 sales;
        mapping(address => uint256) buyers;
        bool isOpen;
        
    }
    
    Event myEvent;
    
    
    /*
        Define 3 logging events.
        LogBuyTickets should provide information about the purchaser and the number of tickets purchased.
        LogGetRefund should provide information about the refund requester and the number of tickets refunded.
        LogEndSale should provide infromation about the contract owner and the balance transferred to them.
    */
    
    event LogBuyTickets(address purchaser, uint256 num_ticket);
    event LogGetRefund(address requester, uint256 num_ticket);
    event LogEndSale(address owner, uint256 balance_transfer);    

    /*
        Create a modifier that throws an error if the msg.sender is not the owner.
    */
    
      modifier OnlyOwner {
        require(owner == msg.sender, "Be a owner to execute the contract");
        _;
    }
    

    /*
        Define a constructor.
        The constructor takes 3 arguments, the description, the URL and the number of tickets for sale.
        Set the owner to the creator of the contract.
        Set the appropriate myEvent details.
    */
    
     constructor(
        string memory _description,
        string memory _url,
        uint256 _num_tickets
    ) public {
        owner = msg.sender;
        myEvent.website = _url;
        myEvent.totalTickets = _num_tickets;
        myEvent.description = _description;

        myEvent.isOpen = true;
    }

    /*
        Define a function called readEvent() that returns the event details.
        This function does not modify state, add the appropriate keyword.
        The returned details should be called description, website, uint totalTickets, uint sales, bool isOpen in that order.
    */
    function readEvent() public view returns(string memory, string memory, uint256, uint256, bool){
        string memory description = myEvent.description;
        string memory website = myEvent.website;
        uint256 totalTickets = myEvent.totalTickets;
        uint256 sales = myEvent.sales; 
        bool isOpen = myEvent.isOpen;
        
        return(description, website, totalTickets, sales, isOpen);
    
    }

    /*
        Define a function called getBuyerTicketCount().
        This function takes 1 argument, an address and
        returns the number of tickets that address has purchased.
    */
    
    function getBuyerTicketCount(address addr) public view returns (uint256) {
        return myEvent.buyers[addr];
    }
    
    

    /*
        Define a function called buyTickets().
        This function allows someone to purchase tickets for the event.
        This function takes one argument, the number of tickets to be purchased.
        This function can accept Ether.
        Be sure to check:
            - That the event isOpen
            - That the transaction value is sufficient for the number of tickets purchased
            - That there are enough tickets in stock
        Then:
            - add the appropriate number of tickets to the purchasers count
            - account for the purchase in the remaining number of available tickets
            - refund any surplus value sent with the transaction
            - emit the appropriate event
    */
    
      function buyTickets(uint256 _num_tickets) public payable returns (bool) {
        require(myEvent.isOpen == true, " Event Closed.....");
        uint256 remainingTickets = myEvent.totalTickets - myEvent.sales;
        require(remainingTickets >= _num_tickets, "Ticket Finished.....");
        uint256 ticketPrice = _num_tickets * TICKET_PRICE;
        require(msg.value >= ticketPrice, "Not Sufficient Amount...");

        // add tickets to sender account
        myEvent.buyers[msg.sender] += _num_tickets;
        myEvent.sales += _num_tickets;

        // refund surplus
        if (msg.value > ticketPrice) {
            uint256 surplus = msg.value - ticketPrice;
            msg.sender.transfer(surplus);
        }

        emit LogBuyTickets(msg.sender, _num_tickets);
        return true;
    }
    
    
    

    /*
        Define a function called getRefund().
        This function allows someone to get a refund for tickets for the account they purchased from.
        TODO:
            - Check that the requester has purchased tickets.
            - Make sure the refunded tickets go back into the pool of avialable tickets.
            - Transfer the appropriate amount to the refund requester.
            - Emit the appropriate event.
    */
        
    function getRefund() public returns (bool) {
        uint256 num_ticket = myEvent.buyers[msg.sender];
        require(num_ticket > 0, "Ticket require.......");

        // refund
        uint256 refundAmt = num_ticket * TICKET_PRICE;
        msg.sender.transfer(refundAmt);
        delete myEvent.buyers[msg.sender];

        myEvent.sales -= num_ticket;

        emit LogGetRefund(msg.sender, num_ticket);
        return true;
    }
    
    
    

    /*
        Define a function called endSale().
        This function will close the ticket sales.
        This function can only be called by the contract owner.
        TODO:
            - close the event
            - transfer the contract balance to the owner
            - emit the appropriate event
    */
    
    function endSale() public OnlyOwner returns (bool) {
        myEvent.isOpen = false;
        owner.transfer(myEvent.sales * TICKET_PRICE);

        emit LogEndSale(owner, myEvent.sales * TICKET_PRICE);
        return true;
    }
}
    
    

