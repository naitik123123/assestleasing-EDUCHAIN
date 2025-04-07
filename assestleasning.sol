// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AssetLeasing {
    // Define variables
    address public owner;
    struct Asset {
        uint256 id;
        string name;
        uint256 pricePerDay;
        address lessee;
        bool isLeased;
    }

    mapping(uint256 => Asset) public assets;
    uint256 public assetCount;

    event AssetAdded(uint256 assetId, string assetName, uint256 pricePerDay);
    event AssetLeased(uint256 assetId, address lessee, uint256 duration);
    event LeaseEnded(uint256 assetId);

    // Constructor
    constructor() {
        owner = msg.sender; // Contract deployer is the owner
    }

    // Modifier to check ownership
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    // Add new assets
    function addAsset(string memory _name, uint256 _pricePerDay) public onlyOwner {
        assetCount++;
        assets[assetCount] = Asset(assetCount, _name, _pricePerDay, address(0), false);
        emit AssetAdded(assetCount, _name, _pricePerDay);
    }

    // Lease an asset
    function leaseAsset(uint256 _assetId, uint256 _duration) public payable {
        Asset storage asset = assets[_assetId];
        require(!asset.isLeased, "Asset is already leased");
        require(msg.value == asset.pricePerDay * _duration, "Incorrect payment amount");

        asset.lessee = msg.sender;
        asset.isLeased = true;
        emit AssetLeased(_assetId, msg.sender, _duration);
    }

    // End a lease
    function endLease(uint256 _assetId) public {
        Asset storage asset = assets[_assetId];
        require(asset.isLeased, "Asset is not leased");
        require(
            msg.sender == owner || msg.sender == asset.lessee,
            "Only owner or lessee can end the lease"
        );

        asset.lessee = address(0);
        asset.isLeased = false;
        emit LeaseEnded(_assetId);
    }

    // Withdraw contract balance
    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
