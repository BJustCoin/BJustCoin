// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Initializable} from "@oz-upgradeable/contracts/proxy/utils/Initializable.sol";
import {ERC20Upgradeable} from "@oz-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";

import {Vesting, Schedule, IVestingToken} from "./IVestingToken.sol";

/**
 * @title The vesting token contract
 * @notice Responsible for the logic of blocking/unblocking funds
 */
contract VestingToken is IVestingToken, Initializable, ERC20Upgradeable {
    using SafeERC20 for IERC20;

    uint256 public immutable basisPoints;

    address private _minter;
    address private _vestingManager;
    IERC20 private _baseToken;
    Vesting private _vesting;
    uint256 private _initialLockedSupply;

    constructor(uint256 _basisPoints) {
        basisPoints = _basisPoints;
        _disableInitializers();
    }

    mapping(address => uint256) private _initialLocked;
    mapping(address => uint256) private _released;

    // region - Events
    /////////////////////
    //      Events     //
    /////////////////////

    event MintTokens(address indexed token, address indexed to, uint256 tokenCount);
    // endregion

    // region - Errors

    /////////////////////
    //      Errors     //
    /////////////////////

    error OnlyMinter();
    error MinterNotSet();
    error OnlyVestingManager();
    error NotEnoughTokensToClaim();
    error StartTimeAlreadyElapsed();
    error CliffBeforeStartTime();
    error IncorrectSchedulePortions();
    error IncorrectScheduleTime(uint256 incorrectTime);
    error TransfersNotAllowed();
    error PercentError();

    // endregion

    // region - Modifiers

    modifier onlyMinter() {
        if (msg.sender != _minter) {
            revert OnlyMinter();
        }

        _;
    }

    modifier onlyVestingManager() {
        if (msg.sender != _vestingManager) {
            revert OnlyVestingManager();
        }

        _;
    }

    // endregion

    // region - Initialize

    /**
     * @notice initialization
     * @dev It is created and initialized only by the VestingManager contract
     * @param   _name  name vesting token
     * @param   _symbol  symbol vesting token
     * @param   minter  address the address that owns the right to mint tokens
     * @param   baseToken  address base token.
     */
    function initialize(string calldata _name, string calldata _symbol, address minter, address baseToken)
        public
        initializer
    {
        if (minter == address(0)) revert MinterNotSet();

        __ERC20_init(_name, _symbol);

        _minter = minter;
        _baseToken = IERC20(baseToken);
        _vestingManager = msg.sender;
    }

    // endregion

    function getMinter() public view returns (address) {
        return _minter;
    }

    // region - Set vesting schedule

    /**
     * @notice The schedule is set by the VestingManager contract
     * @dev The schedule is set by the VestingManager contract
     * @param   startTime  start time
     * @param   cliff  cliff time
     * @param   initialUnlock  unlocked tokens after cliff time
     * @param   schedule  task scheduler
     */
    function setVestingSchedule(uint256 startTime, uint256 cliff, uint8 initialUnlock, Schedule[] calldata schedule)
        external
        onlyVestingManager
    {
        if (initialUnlock >= 101) {
            revert PercentError();
        }
        uint256 scheduleLength = schedule.length;

        _checkVestingSchedule(startTime, cliff, schedule, scheduleLength);

        _vesting.startTime = startTime;
        _vesting.cliff = cliff;
        _vesting.initialUnlock = initialUnlock;

        for (uint256 i = 0; i < scheduleLength;) {
            _vesting.schedule.push(schedule[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev     check vesting tasck schedule
     * @param   startTime  start time
     * @param   cliff  cliff time
     * @param   schedule  task shedule
     * @param   scheduleLength  shedule lenght
     */
    function _checkVestingSchedule(
        uint256 startTime,
        uint256 cliff,
        Schedule[] calldata schedule,
        uint256 scheduleLength
    ) private view {
        if (startTime < block.timestamp) {
            revert StartTimeAlreadyElapsed();
        }

        if (startTime > cliff) {
            revert CliffBeforeStartTime();
        }

        uint256 totalPercent;

        for (uint256 i = 0; i < scheduleLength;) {
            totalPercent += schedule[i].portion;
            bool isEndTimeOutOfOrder = (i != 0) && schedule[i - 1].endTime >= schedule[i].endTime;
            if (cliff >= schedule[i].endTime || isEndTimeOutOfOrder) {
                revert IncorrectScheduleTime(schedule[i].endTime);
            }
            unchecked {
                ++i;
            }
        }

        if (totalPercent != basisPoints) {
            revert IncorrectSchedulePortions();
        }
    }

    // endregion

    // region - Mint
    /**
     * @notice  we are writing off base token and mint vestingToken
     * @dev     we are writing off base token and mint vestingToken
     * @param   to  address to
     * @param   amount  count token
     */
    function mint(address to, uint256 amount) external onlyMinter {
        _initialLocked[to] = _initialLocked[to] + amount;
        _initialLockedSupply = _initialLockedSupply + amount;
        address thisAddress = address(this);
        emit MintTokens(thisAddress, to, amount);
        _mint(to, amount);
        _baseToken.safeTransferFrom(msg.sender, thisAddress, amount);
    }

    // endregion

    // region - Claim
    /**
     * @notice  Burt vestingTokens and transfer the unlocked basic tokens to the beneficiary
     * @dev     Burt vestingTokens and transfer the unlocked basic tokens to the beneficiary
     */
    function claim() external {
        uint256 releasable = availableBalanceOf(msg.sender);
        if (releasable <= 0) {
            revert NotEnoughTokensToClaim();
        }

        _released[msg.sender] = _released[msg.sender] + releasable;

        _burn(msg.sender, releasable);
        _baseToken.safeTransfer(msg.sender, releasable);
    }
    // endregion

    // region - Vesting getters
    /**
     * @notice  get vesting structure
     * @dev     get vesting structure
     * @return  Vesting  structure
     */
    function getVestingSchedule() public view returns (Vesting memory) {
        return _vesting;
    }

    /**
     * @notice  number of unlocked tokens
     * @dev     number of unlocked tokens
     * @return  uint256  count tokens
     */
    function unlockedSupply() external view returns (uint256) {
        return _totalUnlocked();
    }

    /**
     * @notice  number of locked tokens
     * @dev     number of locked tokens
     * @return  uint256  count tokens
     */
    function lockedSupply() external view returns (uint256) {
        return _initialLockedSupply - _totalUnlocked();
    }

    /**
     * @notice  the wallet balance available for withdrawal
     * @dev     the wallet balance available for withdrawal
     * @param   account  wallet address
     * @return  releasable  count tokens
     */
    function availableBalanceOf(address account) public view returns (uint256 releasable) {
        releasable = _unlockedOf(account) - _released[account];
    }
    // endregion

    // region - Private functions

    /**
     * @dev     determining the number of unlocked tokens
     * @param   account  wallet address
     * @return  uint256  count tokens
     */
    function _unlockedOf(address account) private view returns (uint256) {
        return _computeUnlocked(_initialLocked[account], block.timestamp);
    }

    /**
     * @dev     all unlocked tokens
     * @return  uint256  count tokens
     */
    function _totalUnlocked() private view returns (uint256) {
        return _computeUnlocked(_initialLockedSupply, block.timestamp);
    }

    /**
     * @notice The main function for calculating unlocked tokens
     * @dev It checks how many full periods have passed and how much time has passed since the last full period.
     * @param   lockedTokens  locked tokens
     * @param   time  time elapsed since the beginning of the vesting
     * @return  unlockedTokens  unlocked tokens
     */
    function _computeUnlocked(uint256 lockedTokens, uint256 time) private view returns (uint256 unlockedTokens) {
        if (time < _vesting.cliff) {
            return 0;
        }

        uint256 currentPeriodStart = _vesting.cliff;
        Schedule[] memory schedule = _vesting.schedule;
        uint256 scheduleLength = schedule.length;
        //initial unlock tokens
        uint256 initialUnlockedTokens = lockedTokens * _vesting.initialUnlock / 100;
        uint256 lockedTokensVesting = lockedTokens - initialUnlockedTokens;
        unlockedTokens = initialUnlockedTokens;
        //---
        for (uint256 i = 0; i < scheduleLength;) {
            Schedule memory currentPeriod = schedule[i];
            uint256 currentPeriodEnd = currentPeriod.endTime;
            uint256 currentPeriodPortion = currentPeriod.portion;

            if (time < currentPeriodEnd) {
                uint256 elapsedPeriodTime = time - currentPeriodStart;
                uint256 periodDuration = currentPeriodEnd - currentPeriodStart;

                unlockedTokens +=
                    (lockedTokensVesting * elapsedPeriodTime * currentPeriodPortion) / (periodDuration * basisPoints);
                break;
            } else {
                unlockedTokens += (lockedTokensVesting * currentPeriodPortion) / basisPoints;
                currentPeriodStart = currentPeriodEnd;
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice  Available only mint and claim
     * @dev     Available only mint and claim
     * @param   from  address from
     * @param   to  addres to
     * @param   amount  count tokens
     */
    function _update(address from, address to, uint256 amount) internal virtual override {
        if (from != address(0) && to != address(0)) {
            revert TransfersNotAllowed();
        }
        super._update(from, to, amount);
    }
    // endregion
}
