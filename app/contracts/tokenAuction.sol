contract Exchange {

    struct Bid {
        uint price;
        uint amount;
    }

    struct Ask {
        uint price;
        uint amount;
    }

    Bid[] public Bids;
    Ask[] public Asks;

    modifier bidInMarket(uint _price) {
        if (Asks.length > 0) {
            if (_price < Asks[Asks.length -1].price) throw;
        }
        _;
    }

    modifier askInMarket(uint _price) {
        if (Bids.length > 0) {
            if (_price > Bids[Bids.length-1].price) throw;
        }
        _;
    }

    function submitBid(uint _price, uint _amount) bidInMarket(_price) returns (bool) {
        Bid memory b;
        b.price = _price;
        b.amount = _amount;
        for(uint i = 0; i < Bids.length; i++) {
            if(Bids[i].price > _price) {
                Bid[] memory tempBids = new Bid[](Bids.length - i);
                for(uint j = i; j < Bids.length; j++) {
                    tempBids[j-i] = Bids[j];
                }
                Bids[i] = b;
                Bids.length = Bids.length + 1;
                for(uint k = 0; k < tempBids.length; k++) {
                    Bids[i+k+1] = tempBids[k];
                }
                return true;
            }
        }
        Bids.push(b);
        return true;
    }

    function submitAsk(uint _price, uint _amount) askInMarket(_price) returns (bool) {
        Ask memory a;
        a.price = _price;
        a.amount = _amount;
        for (uint i = 0; i < Asks.length; i ++) {
            if(Asks[i].price < _price) {
                Ask[] memory tempAsks = new Ask[](Asks.length - i);
                for (uint j = i; j < Asks.length; j++) {
                    tempAsks[j-i] = Asks[j];
                }
                Asks[i] = a;
                Asks.length = Asks.length + 1;
                for (uint k = 0; k < tempAsks.length; k++) {
                    Asks[i+k+1] = tempAsks[k];
                }
                return true;
            }
        }
        Asks.push(a);
        return true;
    }

    modifier amountLeftBid(uint index) {
        if(Bids[index].amount <= 0) throw;
        _;
    }

    function matchBid(uint bid_index, uint ask_index) amountLeftBid(bid_index) {
        Asks[ask_index].amount--;
        Bids[bid_index].amount--;
        if(Asks[ask_index].amount <= 0) {
            matchBid(bid_index, ask_index--);
        }
        matchBid(bid_index, ask_index);
    }
}
