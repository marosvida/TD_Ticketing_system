// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract TicketingSystem {

    // VARIABLES AND STRUCTS

    //An artist as a name, a category and has an address
    struct artist {
        bytes32 name;
        uint256 artistCategory;
        address owner;
        uint256 totalTicketSold;
    }

    struct venue {
        bytes32 name;
        uint256 capacity;
        uint256 standardComission;
        address payable owner;
    }

    struct concert {
        uint256 artistId;
        uint256 venueId;
        uint256 concertDate;
        uint256 ticketPrice;
        //not declared by user
        bool validatedByArtist;
        bool validatedByVenue;
        uint256 totalSoldTicket;
        uint256 totalMoneyCollected;
    }

    struct ticket {
        uint256 concertId;
        address payable owner;
        bool isAvailable;
        bool isAvailableForSale;
        uint256 amountPaid;
    }

    //Counts number of artists created
    uint256 public artistCount = 0;
    //Counts the number of venues
    uint256 public venueCount = 0;
    //Counts the number of concerts
    uint256 public concertCount = 0;

    uint256 public ticketCount = 0;

    //MAPPINGS & ARRAYS
    mapping(uint256 => artist) public artistsRegister;
    mapping(bytes32 => uint256) private artistsID;

    mapping(uint256 => venue) public venuesRegister;
    mapping(bytes32 => uint256) private venuesID;

    mapping(uint256 => concert) public concertsRegister;

    mapping(uint256 => ticket) public ticketsRegister;

    //EVENTS
    event CreatedArtist(bytes32 name, uint256 id);
    event ModifiedArtist(bytes32 name, uint256 id, address sender);
    event CreatedVenue(bytes32 name, uint256 id);
    event ModifiedVenue(bytes32 name, uint256 id);
    event CreatedConcert(uint256 concertDate, bytes32 name, uint256 id);

    constructor() {}

    //FUNCTIONS TEST 1 -- ARTISTS

    function createArtist(bytes32 _name, uint256 _artistCategory) public {
        uint256 artistId = ++artistCount;
        artistsRegister[artistId] = artist(_name, _artistCategory, payable(msg.sender), 0);
        artistsID[_name] = artistId;
        emit CreatedArtist(_name, artistId);
    }

    function getArtistId(bytes32 _name) public view returns (uint256 ID) {
        return artistsID[_name];
    }

    function modifyArtist(uint256 _artistId, bytes32 _name, uint256 _artistCategory, address payable _newOwner) public {
        require(artistsRegister[_artistId].owner == msg.sender, "not the owner");
        artistsRegister[_artistId].name = _name;
        artistsRegister[_artistId].artistCategory = _artistCategory;
        artistsRegister[_artistId].owner = _newOwner;
        emit ModifiedArtist(_name, _artistId, msg.sender);
    }

    //FUNCTIONS TEST 2 -- VENUES
    function createVenue(bytes32 _name, uint256 _capacity, uint256 _standardComission) public {
        uint256 venueId = ++venueCount;
        venuesRegister[venueId] = venue(_name, _capacity,_standardComission, payable(msg.sender));
        venuesID[_name] = venueId;
        emit CreatedVenue(_name, venueId);
    }

    function getVenueId(bytes32 _name) public view returns (uint256 ID) {
        return venuesID[_name];
    }

    function modifyVenue(
        uint256 _venueId,
        bytes32 _name,
        uint256 _capacity,
        uint256 _standardComission,
        address payable _newOwner
    ) public {
        require(venuesRegister[_venueId].owner == msg.sender, "not the venue owner");
        venuesRegister[_venueId].name = _name;
        venuesRegister[_venueId].capacity = _capacity;
        venuesRegister[_venueId].standardComission = _standardComission;
        venuesRegister[_venueId].owner = _newOwner;
        emit ModifiedVenue(_name, _venueId);
    }

    //FUNCTIONS TEST 3 -- CONCERTS
    function createConcert(uint256 _artistId, uint256 _venueId, uint256 _concertDate, uint256 _ticketPrice) public {
        uint256 concertId = ++concertCount;

        bool validatedByUser = false;
        bool validatedByVenue = false;

        if (artistsRegister[_artistId].owner == msg.sender) {
            validatedByUser = true;
        }

        if (venuesRegister[_venueId].owner == msg.sender) {
            validatedByVenue = true;
        }

        concertsRegister[concertId] = concert(_artistId, _venueId, _concertDate, _ticketPrice, validatedByUser, validatedByVenue, 0, 0);
        emit CreatedConcert(_concertDate, venuesRegister[_venueId].name, concertId);
    }

    function validateConcert(uint256 _concertId) public {
        // require(artistsRegister[concertsRegister[_concertId].artistId].owner == msg.sender
        // || venuesRegister[concertsRegister[_concertId].venueId].owner == msg.sender, "not the artist nor venue");

        if (artistsRegister[concertsRegister[_concertId].artistId].owner == msg.sender) {
            concertsRegister[_concertId].validatedByArtist = true;
        }

        if (venuesRegister[concertsRegister[_concertId].venueId].owner == msg.sender) {
            concertsRegister[_concertId].validatedByVenue = true;
        }
    }

    //Creation of a ticket, only artists can create tickets
    function emitTicket(uint256 _concertId, address payable _ticketOwner) public {
        require(artistsRegister[concertsRegister[_concertId].artistId].owner == msg.sender, "not the owner");
        uint256 ticketId = ++ticketCount;
        ticketsRegister[ticketId] = ticket(_concertId, _ticketOwner, true, false, 0);
        concertsRegister[_concertId].totalSoldTicket++;
        artistsRegister[concertsRegister[_concertId].artistId].totalTicketSold++;
    }

    function useTicket(uint256 _ticketId) public {
        uint256 oneDay = 60 * 60 * 24;

        require(ticketsRegister[_ticketId].owner == msg.sender, "sender should be the owner");
        require(concertsRegister[ticketsRegister[_ticketId].concertId].concertDate - oneDay < block.timestamp, "should be used the d-day");

        require(concertsRegister[ticketsRegister[_ticketId].concertId].validatedByVenue == true, "should be validated by the venue");
        ticketsRegister[_ticketId].isAvailable = false;
    }

    //FUNCTIONS TEST 4 -- BUY/TRANSFER
    function buyTicket(uint256 _concertId) public payable {}

    function transferTicket(uint256 _ticketId, address payable _newOwner) public {}

    //FUNCTIONS TEST 5 -- CONCERT CASHOUT
    function cashOutConcert(uint256 _concertId, address payable _cashOutAddress) public {}

    //FUNCTIONS TEST 6 -- TICKET SELLING
    function offerTicketForSale(uint256 _ticketId, uint256 _salePrice) public {}

    function buySecondHandTicket(uint256 _ticketId) public payable {}

}