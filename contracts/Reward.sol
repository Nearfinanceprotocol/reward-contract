// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {IERC20} from "./interfaces/IERC20.sol";




/// @author nearfinanceprotocol(@developeruche)
/// @notice This is the contract handling the reward mechainsm for the nearfinance protocol this would be using a snapshot mechanism
contract Reward {

    /**
     * ===================================================
     * ----------------- STATE VARIABLES -----------------
     * ===================================================
     */

    address private admin;
    address private snapMaster;
    IERC20 public token;
    uint256 public nonce;
    uint256 public factor;

    struct RewardSnap {
        uint256 blockNumber;
        uint256 endTimestamp;
        bytes32 storageRoot;
        mapping(address => bool) claimed;
    }


    /**
     * ===================================================
     * ----------------- ERROR ---------------------------
     * ===================================================
     */

    error NotSnapMaster();
    error NotAdmin();
    error AddressZeroNotAllowed();


    /**
     * ===================================================
     * ----------------- EVENTS --------------------------
     * ===================================================
     */

    event SnapShotTaken(address snapMaster, uint256 time);



    /**
     * ===================================================
     * ----------------- CONSTRUCTOR ---------------------
     * ===================================================
     */

    constructor(IERC20 _token, address _snapMaster) {
        token = _token;
        if(snapMaster == address(0)) {
            revert AddressZeroNotAllowed();
        }
        snapMaster = _snapMaster;
        admin = msg.sender;
    }


    function onlySnapMaster() public view {
        if(msg.sender != snapMaster) {
            revert NotSnapMaster();
        }
    }

    function onlyAdmin() public view {
        if(msg.sender != admin) {
            revert NotAdmin();
        }
    }

    /// @notice this is the function that would be called every 24hours to enable users claim their daliy rewards 
    /// @dev this function  would handling the taking of snapshot of the balances of the users 
    /// @param _header: this is the header of the block the spanshot would be taken based on 
    /// @param _proof: this is a merkle proof of the contract storage state of the token's contract 
    /// NOTE: When choose blocknumbers make sure the block is at least 256 blocks old which is eqivalent to 1hour on the ethereum blockchain
    function createSpanShot(bytes memory _header, bytes[] memory _proof) public {

    }




}
