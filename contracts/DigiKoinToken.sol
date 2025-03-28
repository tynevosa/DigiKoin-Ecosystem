// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title DigiKoin Token (DGK)
 * @dev ERC20 token with governance and permit functionalities.
 */
contract DigiKoinToken is ERC20Permit, ERC20Votes, Ownable {
    uint256 public constant TOTAL_GOLD_RESERVE = 10000 * 1e18; // 10 kg (1 DGK = 1 gram)

    event TokensTransferredAndDelegated(
        address indexed sender,
        address indexed recipient,
        uint256 amount
    );

    constructor()
        ERC20("DigiKoin", "DGK")
        ERC20Permit("DigiKoin")
        Ownable(msg.sender)
    {
        _mint(address(this), TOTAL_GOLD_RESERVE); // Initial supply of 10 kg
        _delegate(address(this), address(this)); // Delegate initial votes to the owner
    }

    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20, ERC20Votes) {
        super._update(from, to, value);
    }

    function nonces(
        address owner
    ) public view override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }

    /**
     * @dev Custom transfer function with delegation logic.
     * Transfers tokens and delegates voting power automatically.
     */
    function hold(address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0), "Invalid recipient");
        require(balanceOf(address(this)) >= amount, "Insufficient balance");

        // Perform the token transfer
        _transfer(address(this), recipient, amount);

        // Automatically delegate votes to the recipient
        _delegate(recipient, recipient);

        emit TokensTransferredAndDelegated(address(this), recipient, amount);
        return true;
    }

    function redeem(address spender, uint256 amount) public returns (bool) {
        require(spender != address(0), "Invalid recipient");
        require(balanceOf(spender) >= amount, "Insufficient balance");

        // Perform the token transfer
        _transfer(spender, address(this), amount);

        // Automatically delegate votes to the recipient
        _delegate(address(this), address(this));

        emit TokensTransferredAndDelegated(spender, address(this), amount);
        return true;
    }
}
