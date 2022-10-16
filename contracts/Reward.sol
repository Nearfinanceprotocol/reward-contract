// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;




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


    /**
     * ===================================================
     * ----------------- ERROR ---------------------------
     * ===================================================
     */

    error NotSnapMaster();
    error NotAdmin();


    /**
     * ===================================================
     * ----------------- EVENTS --------------------------
     * ===================================================
     */

    event SnapShotTaken(address snapMaster, uint256 time);



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




}
