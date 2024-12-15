// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
 * @title   BJustCoin
 * @dev     Token ICO
 * @notice  Token ICO
 */
contract Bjustcoin is ERC20, Ownable2Step {
    uint256 private constant INITIAL_SUPPLY = 100_000_000 * 1e18;
    mapping(address => bool) public blacklists;

    event Blacklist(address indexed _address, bool isBlacklisting);

    error Blacklisted();

    constructor(address initialOwner) ERC20("Bjustcoin", "BJC") Ownable(initialOwner) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    /**
     * @notice  Adding or removing an address to the blacklist
     * @dev     Adding or removing an address to the blacklist
     * @param   _address  Address additing or removing to the blacklist
     * @param   _isBlacklisting  true - add; false - remove;
     */
    function blacklist(address _address, bool _isBlacklisting) external onlyOwner {
        if (blacklists[_address] != _isBlacklisting) {
            emit Blacklist(_address, _isBlacklisting);
            blacklists[_address] = _isBlacklisting;
        }
    }

    /**
     * @notice  burn BJustCoin. It is used if, at the end of the ICO, there are unsold tokens allocated for all stages of the ICO
     * @dev     burn BJustCoin. It is used if, at the end of the ICO, there are unsold tokens allocated for all stages of the ICO
     * @param   amount  count burn token
     */
    function burn(uint256 amount) external onlyOwner {
        super._burn(owner(), amount);
    }

    /**
     * @dev     moving tokens between wallets. If one of the participants is blacklisted, the Blacklisted error is called
     * @param   from  address from
     * @param   to  address to
     * @param   value  count tokens
     */
    function _update(address from, address to, uint256 value) internal virtual override {
        if (blacklists[to] || blacklists[from]) revert Blacklisted();
        super._update(from, to, value);
    }

    /**
     * @dev     moving tokens between wallets. If one of the participants is blacklisted, the Blacklisted error is called
     * @param   from  address from
     * @param   to  address to
     * @param   value  count tokens
     */
    function transferFrom(address from, address to, uint256 value) public virtual override returns (bool) {
        if (blacklists[to] || blacklists[from]) revert Blacklisted();
        return super.transferFrom(from, to, value);
    }
}
