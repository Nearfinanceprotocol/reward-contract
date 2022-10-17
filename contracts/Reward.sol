// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {IERC20} from "./interfaces/IERC20.sol";
import {SnapshopLib} from "./libraries/Snap.sol";




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
    mapping(uint256 => RewardSnap) public rewardSnap;

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
    error WrongAction();
    error InvalidNonce();
    error WrongTiming();
    error UserHasAlreadyClaimed();
    error UnsuccessfulTransfer();


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
        onlySnapMaster();
        (uint256 blockNumber, bytes32 stateRoot) = SnapshopLib.blockStateRoot(_header);
        bytes32 storageRoot = SnapshopLib.accountStorageRoot(stateRoot, address(token), _proof);
        RewardSnap storage snap = rewardSnap[nonce++];
        snap.blockNumber = blockNumber;
        snap.endTimestamp = block.timestamp + 24 hours;
        snap.storageRoot = storageRoot;
    }

    /// @notice this fuunction would be used be the user to claim daily reward from this reward contract 
    /// @param _proof: this is a the proof need to get your balance as the snapshot 
    function claimReward(bytes[] memory _proof) public {
        RewardSnap storage r = rewardSnap[nonce];

        uint256 endTime = r.endTimestamp;

        if(endTime == 0) {
            revert InvalidNonce();
        }

        if(block.timestamp > endTime) {
            revert WrongTiming();
        }

        if(r.claimed[msg.sender] != false) {
            revert UserHasAlreadyClaimed();
        }

        uint256 balanceSlot = 23;
        uint256 balancesKey = uint160(address(msg.sender));

        r.claimed[msg.sender] = true;
        bytes32 slot = keccak256(abi.encodePacked(balancesKey, balanceSlot));
        uint256 balance = uint256(SnapshopLib.storageValue(r.storageRoot, slot, _proof));

        uint256 transferOut = balance * factor * 24 hours;
        bool sent = token.transfer(msg.sender, transferOut);

        if(!sent) {
            revert UnsuccessfulTransfer();
        }
    }

    /// @notice this function would allow the admin to pullout any token sent into this contract
    /// @dev logic should be placed to prevent the admin from pulling out the reward token
    /// @param _tokenAddress: this is the address of the locked token
    /// @param _amount: this is the amount of toen that is to be transfered 
    function pullOutArbitraryToken(IERC20 _tokenAddress, address _receiver, uint256 _amount) public {
        onlyAdmin();
        if(_tokenAddress == token) {
            revert WrongAction();
        }
        IERC20(_tokenAddress).transfer(_receiver, _amount);
    }

    /// @dev this function would be used to transfer the admin rigtht to this contract to the specified address 
    /// @param _newOwner: This is the new intended owner
    function transferOwner(address _newOwner) public {
        onlyAdmin();
        admin = _newOwner;
    }

    /// @dev this function would be used to change the account that would be making the snap shots 
    /// @param _newSnapMaster: this is the address of the new swapMaster 
    function setSwapMaster(address _newSnapMaster) public {
        onlyAdmin();
        snapMaster = _newSnapMaster;
    }
}
