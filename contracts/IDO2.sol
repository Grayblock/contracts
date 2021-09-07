pragma solidity ^0.5.0;

import "./crowdsale/Crowdsale.sol";
import "./crowdsale/distribution/RefundablePostDeliveryCrowdsale.sol";

contract IDO2 is Crowdsale, TimedCrowdsale, PostDeliveryCrowdsale, RefundableCrowdsale {

    constructor(
        uint256 rate,            // rate, in TKNbits
        address payable wallet,  // wallet to send Ether
        IERC20 token,            // the token
        uint256 openingTime,     // opening time in unix epoch seconds
        uint256 closingTime,      // closing time in unix epoch seconds
        uint256 goal             // the minimum goal, in wei
    )
        PostDeliveryCrowdsale()
        RefundableCrowdsale(goal)
        TimedCrowdsale(openingTime, closingTime)
        Crowdsale(rate, wallet, token)
        
        public
    {
        // nice! this Crowdsale will keep all of the tokens until the end of the crowdsale
        // and then users can `withdrawTokens()` to get the tokens they're owed
    }
    
        function withdrawTokens(address beneficiary) public {
        require(finalized(), "RefundablePostDeliveryCrowdsale: not finalized");
        require(goalReached(), "RefundablePostDeliveryCrowdsale: goal not reached");

        super.withdrawTokens(beneficiary);
    }
}
