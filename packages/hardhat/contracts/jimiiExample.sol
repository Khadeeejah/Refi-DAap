//? this will be created for DAO members only right?
struct UserInfo {
    PersonalInfo personalInfo,
    FinancialInfo financialInfo, 
    Mortage[] mortages
}

struct PersonalInfo {
    string nameOrAlias,
    string contact, 
    string taxNo, /// CENTRIALIZED, use proof of funds instead?
    address walletAddress,
}

struct FinancialInfo {
    uint monthlyIncome, 
    uint creditScore,
    string[] assets, //array of URI assets he/she/... owns
    string proofOfIncome,//URI of letter of employment from employer
}


// holds the details about mortages taken out
struct Mortage {
    // string name,
    uint amtRequested,
    uint repayMentPeriod, //in years
    uint repaymentAmt, 
    uint repaymentFrequency,
    string proofOfPropery,  
}

// /// @notice address of the person taking out the mortage is mapped 
// /// to the mortage he took
// mapping (address => Mortage) mortages;

/// @notice address of the person taking out the mortage is mapped 
/// to the mortage he took
mapping (address => UserInfo) users;

/// @notice checks whether member has enough finances to take out a mortage
function approveMortageRequest() public returns (bool approval) {
    //check if the address is in the DAO

    //check whether his financial record match 
    //user will send the requested data in the Finance struct 
}

/// @notice when mortage request gets approved
function takeOutMortage(uint _amtRequested, uint _repaymentPeriod, uint _repaymentAmt, uint _repaymentFrequency, string _proofOfPropery) public {
    require(msg.sender !== address(0));
    //check request of approve request
    require(approveMortageRequest(), "Mortage request not approved");

    // address userAddress = msg.sender;

    //? populate the mortage data
    // check if user has more that one mortage
    uint mortages = users[msg.sender].mortages.length; 
    uint newMortagId = 0;
    if (mortages > 0){ 
        newMortagId = mortages + 1;
    } 
    newMortagId += 1; //start from 1
    uint[msg.sender].mortages[newMortagId].amtRequested = _amtRequested;
    uint[msg.sender].mortages[newMortagId]._repaymentPeriod = _repaymentPeriod;
    uint[msg.sender].mortages[newMortagId].repaymentAmt = _repaymentAmt;
    uint[msg.sender].mortages[newMortagId].repaymentFrequency = _repaymentFrequency;
    uint[msg.sender].mortages[newMortagId].proofOfPropery = _proofOfPropery;

    //internal function to make sure that propery exists. //? but how will we check

    //send the funds to person who requested it
    (bool success, ) = msg.sender.call{
        value: _amtRequested
    }("");

    require(bool, "failed to send the funds");
}