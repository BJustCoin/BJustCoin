// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @author  Code Tesla Labs
 * @title   BJustCoin
 * @dev     Token ICO
 * @notice  Token ICO
 */
contract Bjustcoin is ERC20, Ownable {
    uint256 private constant INITIAL_SUPPLY = 100_000_000 * 1e18;
    mapping(address => bool) public blacklists;

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
        blacklists[_address] = _isBlacklisting;
    }

    /**
     * @notice  burn BJustCoin
     * @dev     burn BJustCoin
     * @param   amount  count burn token
     */
    function burn(uint256 amount) external onlyOwner {
        super._burn(owner(), amount);
    }

    /**
     * @notice  token transfer
     * @dev     token transfer
     * @param   from  address from
     * @param   to  address to
     * @param   value  count tokens
     */
    function _update(address from, address to, uint256 value) internal virtual override {
        if (blacklists[to] || blacklists[from]) revert Blacklisted();
        super._update(from, to, value);
    }
}
