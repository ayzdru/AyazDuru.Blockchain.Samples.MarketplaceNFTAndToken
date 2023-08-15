// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/IERC1155MetadataURIUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/MulticallUpgradeable.sol";

contract SpaceWarsGame is    
    Initializable,
    PausableUpgradeable,
    IERC165Upgradeable,
    OwnableUpgradeable,
    IERC721ReceiverUpgradeable,
    IERC1155ReceiverUpgradeable,       
    ReentrancyGuardUpgradeable,
    MulticallUpgradeable    
{
    uint256 public totalNftStaked;

    IERC20Upgradeable tokenContract;
    IERC1155MetadataURIUpgradeable nftContract;
    IERC1155MetadataURIUpgradeable packContract;

    enum NFTTypes {
        None,
        Tool,
        Ship,
        Building,
        Robot
    }
    enum NFTStakeTypes {
        ShipTool,
        ToolRobotWorker,
        Ship,
        ShipRobotSoldier,
        Building,
        BuildingRobotWorker
    }

    struct CraftConfig{
       uint256 packId;       
       Resource[] resources;
    }
    mapping(NFTTypes => CraftConfig) public craftConfigs;

    mapping(string => NFTTypes) public nftTypes;

    struct NFTStaker {
        uint256 timeOfLastUpdate;
        uint256 totalNftStaked;
        mapping(uint256 => NFTStake) nftStakes;
    }
    struct NFTStake {
        uint256 tokenId;
        uint256 targetTokenId;
        uint256 parentTokenId;
        uint256 stakedAtTimestamp;
        NFTTypes nftType;
        NFTStakeTypes nftStakeType;
    }

    mapping(address => NFTStaker) public nftStakers;
    mapping(uint256 => address) public nftStakerAddresses;

    event NFTStaked(address owner, uint256 tokenId, uint256 value);
    event NFTUnstaked(address owner, uint256 tokenId, uint256 value);

    
    struct AccountShip {
        string tokenURI;
        Rarities rarity;
        uint256 currentEnergy;
        uint256 maximumEnergy;
        uint256 currentDurability;
        uint256 maximumDurability;
        uint256 currentToolCount;
        uint256 maximumToolCount;
        uint256 currentSoldierCount;
        uint256 maximumSoldierCount;
        uint256 nextAvailability;
        uint256 currentLandIndex;
        uint256 speed;
        uint256 totalTokenPower;
        uint256 totalResourcePower;
        bool isClaimed;
        mapping(uint256 => AccountTool) tools;
        mapping(uint256 => AccountRobot) soldiers;
    }
    struct AccountTool {
        string tokenURI;
        ResourceTypes resourceType;
        Rarities rarity;
        uint256 currentDurability;
        uint256 maximumDurability;
        uint256 energyConsumed;
        uint256 durabilityConsumed;
        uint256 currentWorkerRobotCount;
        uint256 maximumWorkerRobotCount;
        uint256 power;        
        mapping(uint256 => AccountRobot) workers;
    }
    struct AccountBuilding {
        string tokenURI;
        Rarities rarity;
        uint256 currentDurability;
        uint256 maximumDurability;
        bool isReady;
        uint256 upgradePrice;
        uint256 upgrades;       
        uint256 requiredUpgrades;
        uint256 currentWorkerRobotCount;
        uint256 maximumWorkerRobotCount;
         uint256 nextAvailability;
        uint256 chargeTime;
        uint256 energyConsumed;
        Resource[] rewardResources;
        Resource[] requiredResources;
        mapping(uint256 => AccountRobot) workers;
    }
    struct AccountRobot {
        string tokenURI;
        Rarities rarity;
        RobotTypes robotType;
        uint256 power;
        uint256 currentHealth;
        uint256 maximumHealth;
        uint256 currentDurability;
        uint256 maximumDurability;
        uint256 energyConsumed;
        uint256 durabilityConsumed;
    }
    enum ResourceTypes {
        Electric,
        Gasoline
    }

    struct Resource {
        ResourceTypes resourceType;
        uint256 balance;
    } 
 

    struct Account {
        uint256 currentEnergy;
        uint256 maximumEnergy;
        int256 x;
        int256 y;
        address referral;
        uint256 totalResourceCount;
        mapping(uint256 => Resource) resources;
        mapping(uint256 => AccountShip) ships;
        mapping(uint256 => AccountBuilding) buildings;
    }

    mapping(address => Account) public accounts;

    enum Rarities {
        None,
        Common,
        Rare,
        Epic,
        Legendary,
        Mythical
    }
    uint256 private baseTokenRewardRate;
    uint256 private baseResourceRewardRate;

    struct Land {
        uint256 tokenId;
        string tokenURI;
        Rarities rarity;
        uint256 commission;
        uint256 resourceRewardRate;
        uint256 tokenRewardRate;
        uint256 totalTokenPower;
        uint256 totalResourcePower;
        int256 x;
        int256 y;
    }

    uint256 private nextLandIndex;
    uint256 private totalLand;
    mapping(uint256 => Land) private lands;

    struct Ship {
        string tokenURI;
        Rarities rarity;
        uint256 maximumEnergy;
        uint256 maximumToolCount;
        uint256 maximumSoldierCount;
        uint256 maximumDurability;
        uint256 speed;
        uint256 power;       
    }

    mapping(string => Ship) public ships;

    struct Tool {
        string tokenURI;
        Rarities rarity;
        ResourceTypes resourceType;
        uint256 maximumDurability;
        uint256 energyConsumed;
        uint256 durabilityConsumed;
        uint256 maximumWorkerRobotCount;
        uint256 power;        
    }

    mapping(string => Tool) public tools;

    enum BuildingTypes {
        Gasoline
    }

    struct Building {
        string tokenURI;
        Rarities rarity;
        BuildingTypes buildingType;
        uint256 upgradePrice;
        uint256 requiredUpgrades;
        uint256 maximumWorkerRobotCount;
        uint256 chargeTime;
        uint256 energyConsumed;
        uint256 maximumDurability;       
        Resource[] rewardResources;
        Resource[] requiredResources;
    }

    mapping(string => Building) public buildings;

    enum RobotTypes {
        Worker,
        Soldier
    }

    struct Robot {
        string tokenURI;
        Rarities rarity;
        RobotTypes robotType;
        uint256 power;
        uint256 maximumHealth;
        uint256 maximumDurability;
        uint256 energyConsumed;
        uint256 durabilityConsumed;
    }

    mapping(string => Robot) public robots;

    struct Listing {
        address owner;
        uint256 listingId;
        Resource resource;
        uint256 price;
        uint256 createdAtTimestamp;
    }
    uint256 public totalListings;

    mapping(uint256 => Listing) public listings;

    function validateListing(
        address owner,
        Resource memory _resource,
        uint256 _price
    ) private view {
        require(_price > 0, "PRICE");
        require(_resource.balance > 0, "RESOURCE");
        Account storage account = accounts[owner];
        bool checkBalance = false;
        Resource memory resource;
        for (uint256 i; i < account.totalResourceCount; ++i) {
            resource = account.resources[i];
            if (
                resource.resourceType == _resource.resourceType &&
                resource.balance >= _resource.balance
            ) {
                checkBalance = true;
                break;
            }
        }

        require(checkBalance == true, "BALANCE");
    }

    function createListing(Resource memory _resource, uint256 _price)
        public
        whenNotPaused
    {
        address owner = _msgSender();
        validateListing(owner, _resource, _price);
        uint256 listingId = totalListings;
        totalListings += 1;
        Listing memory newListing = Listing({
            owner: owner,
            listingId: listingId,
            price: _price,
            resource: _resource,
            createdAtTimestamp: block.timestamp
        });
        listings[listingId] = newListing;
    }

    function buy(uint256 _listingId)
        public
        payable
        nonReentrant
        onlyExistingListing(_listingId)
        whenNotPaused
    {
        Listing memory targetListing = listings[_listingId];
        address payer = _msgSender();
        tokenContract.transferFrom(
            payer,
            targetListing.owner,
            targetListing.price
        );
        delete listings[_listingId];
    }

    function cancelDirectListing(uint256 _listingId)
        public
        onlyListingCreator(_listingId)
        whenNotPaused
    {
        delete listings[_listingId];
    }

    function updateListing(
        uint256 _listingId,
        Resource memory _resource,
        uint256 _price
    ) public onlyListingCreator(_listingId) whenNotPaused {
        address owner = _msgSender();
        validateListing(owner, _resource, _price);

        Listing memory newListing = Listing({
            owner: owner,
            listingId: _listingId,
            price: _price,
            resource: _resource,
            createdAtTimestamp: block.timestamp
        });
        listings[_listingId] = newListing;
    }

    /*///////////////////////////////////////////////////////////////
                                Modifiers
    //////////////////////////////////////////////////////////////*/

    /// @dev Checks whether caller is a listing creator.
    modifier onlyListingCreator(uint256 _listingId) {
        require(listings[_listingId].owner == _msgSender(), "!OWNER");
        _;
    }

    /// @dev Checks whether a listing exists.
    modifier onlyExistingListing(uint256 _listingId) {
        require(listings[_listingId].owner != address(0), "DNE");
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    uint256 energyMultiplier;
    uint256 repairDivisor;

    function initialize(
        address _tokenContractAddress,
        address _nftContractAddress,
        address _packContractAddress
    ) external initializer {
        __Pausable_init();
        __Ownable_init();
        __ReentrancyGuard_init();
        repairDivisor = 1;
        energyMultiplier = 5;
        tokenContract = IERC20Upgradeable(_tokenContractAddress);
        nftContract = IERC1155MetadataURIUpgradeable(_nftContractAddress);
        packContract = IERC1155MetadataURIUpgradeable(_packContractAddress);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    struct StakeParameter {
        uint256 tokenId;
        uint256 targetTokenId;
        uint256 parentTokenId;
    }

    function stake(StakeParameter[] calldata _stakeParameters)
        public
        nonReentrant
        whenNotPaused
    {
        Account storage account = accounts[msg.sender];
        require(account.maximumEnergy > 0, "Account not found!");
        StakeParameter memory stakeParameter;
        uint256 len = _stakeParameters.length;
        NFTStaker storage nftStaker = nftStakers[msg.sender];
        for (uint256 i; i < len; ++i) {
            stakeParameter = _stakeParameters[i];
            nftStaker.totalNftStaked += 1;
            NFTStake storage nftStake = nftStaker.nftStakes[
                nftStaker.totalNftStaked
            ];
            require(
                nftContract.balanceOf(msg.sender, stakeParameter.tokenId) > 0 ,
                "Can't stake tokens you don't own!"
            );
            string memory tokenUri = nftContract.uri(
                stakeParameter.tokenId
            );
            nftStake.tokenId = stakeParameter.tokenId;
            nftStake.nftType = nftTypes[tokenUri];
            require(nftStake.nftType != NFTTypes.None, "NFT Type");     
            nftStake.stakedAtTimestamp = block.timestamp;
            nftStakerAddresses[stakeParameter.tokenId] = msg.sender;

            if (nftStake.nftType == NFTTypes.Ship) {
                nftStake.nftStakeType = NFTStakeTypes.Ship;
                AccountShip storage accountShip = account.ships[
                    stakeParameter.tokenId
                ];
                Ship storage ship = ships[tokenUri];
                require(ship.rarity != Rarities.None, "Ship config error");
                accountShip.currentLandIndex = getNextLandIndex();
                accountShip.rarity = ship.rarity;
                accountShip.currentEnergy = ship.maximumEnergy;
                accountShip.maximumEnergy = ship.maximumEnergy;
                accountShip.currentDurability = ship.maximumDurability;
                accountShip.maximumDurability = ship.maximumDurability;
                accountShip.currentToolCount = ship.maximumToolCount;
                accountShip.maximumToolCount = ship.maximumToolCount;
                accountShip.currentSoldierCount = ship.maximumSoldierCount;
                accountShip.maximumSoldierCount = ship.maximumSoldierCount;
                accountShip.isClaimed = true;
                accountShip.totalTokenPower = ship.power;
                accountShip.tokenURI = ship.tokenURI;
            } else if (nftStake.nftType == NFTTypes.Tool) {
                require(
                    nftContract.balanceOf(msg.sender, stakeParameter.targetTokenId) > 0
                       ,
                    "Can't stake tokens you don't own!"
                );
                nftStake.nftStakeType = NFTStakeTypes.ShipTool;
                nftStake.targetTokenId = stakeParameter.targetTokenId;
                string memory targetTokenUri = nftContract.uri(
                    stakeParameter.targetTokenId
                );
                NFTTypes targetNFTType = nftTypes[targetTokenUri];               
                require(
                    targetNFTType == NFTTypes.Ship,
                    "Can't stake only ship"
                );
                AccountShip storage accountShip = account.ships[
                    stakeParameter.targetTokenId
                ];
                require(accountShip.rarity != Rarities.None, "Ship not staked");
                require(
                    accountShip.isClaimed == true,
                    "Can't stake wait mission"
                );
                require(
                    accountShip.currentToolCount + 1 <
                        accountShip.maximumToolCount,
                    "Ship Maximum Tool"
                );
                accountShip.currentToolCount += 1;
                AccountTool storage accountTool = accountShip.tools[
                    stakeParameter.tokenId
                ];
                require(accountTool.rarity != Rarities.None, "Tool not staked");
                Tool storage tool = tools[tokenUri];
                require(tool.rarity != Rarities.None, "Tool config error");
                accountTool.power = tool.power;
                accountTool.resourceType = tool.resourceType;
                accountShip.totalResourcePower += tool.power;
                accountTool.currentDurability = tool.maximumDurability;
                accountTool.maximumDurability = tool.maximumDurability;
                accountTool.energyConsumed = tool.energyConsumed;
                accountTool.durabilityConsumed = tool.durabilityConsumed;
                accountTool.tokenURI = tool.tokenURI;
            } else if (nftStake.nftType == NFTTypes.Robot) {
                require(
                    nftContract.balanceOf( msg.sender, stakeParameter.targetTokenId) > 0
                       ,
                    "Can't stake tokens you don't own!"
                );
                string memory targetTokenUri = nftContract.uri(
                    stakeParameter.targetTokenId
                );
                NFTTypes targetNFTType = nftTypes[targetTokenUri];
                Robot storage robot = robots[tokenUri];
                if (
                    targetNFTType == NFTTypes.Ship &&
                    robot.robotType == RobotTypes.Soldier
                ) {
                    AccountShip storage accountShip = account.ships[
                        stakeParameter.targetTokenId
                    ];

                    require(
                        accountShip.rarity != Rarities.None,
                        "Ship not staked"
                    );
                    require(
                        accountShip.isClaimed == true,
                        "Can't stake wait mission"
                    );
                    require(
                        accountShip.currentSoldierCount + 1 <
                            accountShip.maximumSoldierCount,
                        "Ship Maximum Soldier"
                    );
                    accountShip.currentSoldierCount += 1;
                    nftStake.nftStakeType = NFTStakeTypes.ShipRobotSoldier;
                    accountShip.soldiers[
                        stakeParameter.tokenId
                    ] = robotConvertToAccountRobot(robots[tokenUri]);
                    accountShip.totalTokenPower += accountShip
                        .soldiers[stakeParameter.tokenId]
                        .power;
                } else if (
                    targetNFTType == NFTTypes.Tool &&
                    robot.robotType == RobotTypes.Worker
                ) {
                    require(
                        nftContract.balanceOf(msg.sender, stakeParameter.parentTokenId) > 0
                            ,
                        "Can't stake tokens you don't own!"
                    );
                    nftStake.nftStakeType = NFTStakeTypes.ToolRobotWorker;
                    AccountShip storage accountShip = account.ships[
                        stakeParameter.parentTokenId
                    ];
                    require(
                        accountShip.rarity != Rarities.None,
                        "Ship not staked"
                    );
                    require(
                        accountShip.isClaimed == true,
                        "Can't stake wait mission"
                    );

                    AccountTool storage accountTool = accountShip.tools[
                        stakeParameter.targetTokenId
                    ];
                    require(
                        accountTool.rarity != Rarities.None,
                        "Tool not staked"
                    );
                    require(
                        accountTool.currentWorkerRobotCount + 1 <
                            accountTool.maximumWorkerRobotCount,
                        "Tool Maximum Worker"
                    );
                    accountTool.currentWorkerRobotCount += 1;
                    accountTool.workers[
                        stakeParameter.tokenId
                    ] = robotConvertToAccountRobot(robots[tokenUri]);
                    accountShip.totalResourcePower = accountTool
                        .workers[stakeParameter.tokenId]
                        .power;
                } else if (
                    targetNFTType == NFTTypes.Building &&
                    robot.robotType == RobotTypes.Worker
                ) {
                    require(
                        nftContract.balanceOf(msg.sender, stakeParameter.targetTokenId) >0
                            ,
                        "Can't stake tokens you don't own!"
                    );
                    nftStake.nftStakeType = NFTStakeTypes.BuildingRobotWorker;
                    AccountBuilding storage accountBuilding = account.buildings[
                        stakeParameter.targetTokenId
                    ];
                    require(
                        accountBuilding.rarity != Rarities.None,
                        "Building not staked"
                    );
                    accountBuilding.workers[
                        stakeParameter.tokenId
                    ] = robotConvertToAccountRobot(robots[tokenUri]);
                } else {
                    revert("Staked NFT type");
                }
            } else if (nftStake.nftType == NFTTypes.Building) {
                nftStake.nftStakeType = NFTStakeTypes.Building;
                AccountBuilding storage accountBuilding = account.buildings[
                    stakeParameter.tokenId
                ];
                require(
                    accountBuilding.rarity != Rarities.None,
                    "Building not staked"
                );
                Building storage building = buildings[tokenUri];
                require(
                    building.rarity != Rarities.None,
                    "Building config error"
                );
                accountBuilding.tokenURI = building.tokenURI;
                accountBuilding.rarity = building.rarity;
                accountBuilding.currentDurability = building.maximumDurability;
                accountBuilding.maximumDurability = building.maximumDurability;
                accountBuilding.isReady = false;
                accountBuilding.upgrades = 1;
                accountBuilding.requiredUpgrades = building.requiredUpgrades;
                accountBuilding.upgradePrice = building.upgradePrice;
                accountBuilding.currentWorkerRobotCount = building
                    .maximumWorkerRobotCount;
                accountBuilding.maximumWorkerRobotCount = building
                    .maximumWorkerRobotCount;
                accountBuilding.chargeTime = building.chargeTime;
                accountBuilding.energyConsumed = building.energyConsumed;
                accountBuilding.rewardResources = building.rewardResources;
                accountBuilding.requiredResources = building.requiredResources;
            }
            else
            {
                revert("Error");
            }
            nftContract.safeTransferFrom(
                msg.sender,
                address(this),
                stakeParameter.tokenId,
                1,
                ""
            );
            emit NFTStaked(msg.sender, stakeParameter.tokenId, block.timestamp);
        }
        nftStaker.timeOfLastUpdate = block.timestamp;
        totalNftStaked += len;
    }

    function unstake(uint256 _tokenId) public nonReentrant whenNotPaused {
        Account storage account = accounts[msg.sender];
        require(account.maximumEnergy > 0, "Account not found!");
        NFTStaker storage nftStaker = nftStakers[msg.sender];
        require(nftStaker.totalNftStaked > 0, "You have no tokens staked");
        NFTStake storage nftStake;
        require(
            nftStakerAddresses[_tokenId] == msg.sender,
            "Can't unstake tokens you don't own!"
        );
        for (uint256 j; j < nftStaker.totalNftStaked; ++j) {
            nftStake = nftStaker.nftStakes[j];
            if (nftStake.tokenId == _tokenId) {
                if (nftStake.nftType == NFTTypes.Ship) {
                    AccountShip storage accountShip = account.ships[_tokenId];
                    require(
                        accountShip.isClaimed == true,
                        "Can't unstake wait mission"
                    );
                    require(
                        accountShip.currentDurability ==
                            accountShip.maximumDurability,
                        "Ship durability is not full"
                    );
                    require(
                        accountShip.currentEnergy == accountShip.maximumEnergy,
                        "Ship energy is not full"
                    );
                    require(
                        accountShip.currentSoldierCount == 0 &&
                            accountShip.currentToolCount == 0,
                        "Ship not empty"
                    );
                    delete account.ships[_tokenId];
                } else if (nftStake.nftType == NFTTypes.Tool) {
                    AccountShip storage accountShip = account.ships[
                        nftStake.targetTokenId
                    ];
                    require(
                        accountShip.isClaimed == true,
                        "Can't unstake wait mission"
                    );
                    accountShip.currentToolCount -= 1;
                    AccountTool storage accountTool = accountShip.tools[
                        nftStake.tokenId
                    ];
                    require(
                        accountTool.currentDurability ==
                            accountTool.maximumDurability,
                        "Tool durability is not full"
                    );
                    require(
                        accountTool.currentWorkerRobotCount == 0,
                        "Tool not empty"
                    );
                    delete accountShip.tools[nftStake.tokenId];
                } else if (nftStake.nftType == NFTTypes.Robot) {
                    if (
                        nftStake.nftStakeType == NFTStakeTypes.ToolRobotWorker
                    ) {
                        AccountShip storage accountShip = account.ships[
                            nftStake.parentTokenId
                        ];
                        require(
                            accountShip.isClaimed == true,
                            "Can't unstake wait mission"
                        );
                        AccountTool storage accountTool = accountShip.tools[
                            nftStake.targetTokenId
                        ];
                        accountTool.currentWorkerRobotCount -= 1;
                        delete accountTool.workers[nftStake.tokenId];
                    } else if (
                        nftStake.nftStakeType ==
                        NFTStakeTypes.BuildingRobotWorker
                    ) {
                        AccountBuilding storage accountBuilding = account
                            .buildings[nftStake.targetTokenId];
                        accountBuilding.currentWorkerRobotCount -= 1;
                        delete accountBuilding.workers[nftStake.tokenId];
                    } else if (
                        nftStake.nftStakeType == NFTStakeTypes.ShipRobotSoldier
                    ) {
                        AccountShip storage accountShip = account.ships[
                            nftStake.targetTokenId
                        ];
                        require(
                            accountShip.isClaimed == true,
                            "Can't unstake wait mission"
                        );
                        accountShip.currentSoldierCount -= 1;
                        delete accountShip.soldiers[nftStake.tokenId];
                    } else {
                        revert("Stake NFT type");
                    }
                } else if (nftStake.nftType == NFTTypes.Building) {
                    AccountBuilding storage accountBuilding = account.buildings[
                        _tokenId
                    ];
                    require(
                        accountBuilding.currentDurability ==
                            accountBuilding.maximumDurability,
                        "Ship durability is not full"
                    );
                    delete account.buildings[_tokenId];
                } else {
                    revert("NFT type");
                }

                delete nftStaker.nftStakes[_tokenId];
                delete nftStakerAddresses[_tokenId];
                nftContract.safeTransferFrom(address(this), msg.sender, _tokenId, 1, "");
                emit NFTStaked(msg.sender, _tokenId, block.timestamp);
                break;
            }
        }

        nftStaker.totalNftStaked -= 1;
        nftStaker.timeOfLastUpdate = block.timestamp;
        totalNftStaked -= 1;
    }

    function register(address _referral) public whenNotPaused {
        Account storage account = accounts[msg.sender];
        require(account.maximumEnergy == 0, "Account exist!");
        account.maximumEnergy = 500;
        account.currentEnergy = 500;
        account.referral = _referral;
    }

    function sendShip(uint256 _shipTokenId) public whenNotPaused {
        Account storage account = accounts[msg.sender];
        require(account.maximumEnergy > 0, "Account not found!");
        AccountShip storage accountShip = account.ships[_shipTokenId];
        require(accountShip.isClaimed == true, "Can't send");
        require(accountShip.nextAvailability < block.timestamp, "Can't send");
        Land storage land = lands[accountShip.currentLandIndex];
        int256 x = land.x - account.x;
        int256 y = land.y - account.y;
        uint256 distance;
        if (x < 0) {
            x = x * -1;
        }
        distance += uint256(x * x);
        if (y < 0) {
            y = y * -1;
        }
        distance += uint256(y * y);
        uint256 time = (squareRoot(distance) * 10000000) / accountShip.speed;
        land.totalResourcePower += accountShip.totalResourcePower;
        land.totalTokenPower += accountShip.totalTokenPower;
        accountShip.isClaimed = false;
        accountShip.nextAvailability = block.timestamp + time;
    }

    function claimShip(uint256 _shipTokenId) public whenNotPaused {
        Account storage account = accounts[msg.sender];
        require(account.maximumEnergy > 0, "Account not found!");
        NFTStaker storage nftStaker = nftStakers[msg.sender];
        require(nftStaker.totalNftStaked > 0, "You have no tokens staked");
        AccountShip storage accountShip = account.ships[_shipTokenId];
        require(accountShip.isClaimed == false, "Can't claim");
        require(accountShip.nextAvailability >= block.timestamp, "Can't claim");
        Land storage land = lands[accountShip.currentLandIndex];
        uint256 tokenReward = ((land.totalTokenPower /
            accountShip.totalTokenPower) * 100) / baseTokenRewardRate;
        tokenReward += (tokenReward * 1000) / (generateRandomNumber(20) * 1000);
        require(
            tokenContract.balanceOf(msg.sender) == tokenReward,
            "Token Game balance error"
        );
        tokenContract.transfer(msg.sender, tokenReward);
        uint256[] memory toolTokenIds = new uint256[](
            accountShip.currentToolCount
        );
        NFTStake storage nftStake;
        uint256 toolIndex = 0;
        for (uint256 j; j < nftStaker.totalNftStaked; ++j) {
            nftStake = nftStaker.nftStakes[j];
            if (
                nftStake.nftStakeType == NFTStakeTypes.ShipTool &&
                nftStake.targetTokenId == _shipTokenId
            ) {
                toolTokenIds[toolIndex] = nftStake.tokenId;
                toolIndex += 1;
            }
        }

        uint256 toolTokenId;
        for (uint256 i = 0; i < toolIndex; i++) {
            toolTokenId = toolTokenIds[i];
            AccountTool storage accountTool = accountShip.tools[toolTokenId];
            uint256 resourceReward = ((land.totalResourcePower /
                accountTool.power) * 100) / baseResourceRewardRate;
            resourceReward +=
                (resourceReward * 1000) /
                (generateRandomNumber(20) * 1000);
            bool checkResource = false;
            Resource storage accountResource;
            uint256 totalResourceCount = account.totalResourceCount;
            for (uint256 x = 0; x < totalResourceCount; x++) {
                accountResource = account.resources[x];
                if (accountResource.resourceType == accountTool.resourceType) {
                    accountResource.balance += resourceReward;
                    checkResource = true;
                    break;
                }
            }
            if (checkResource == false) {
                totalResourceCount += 1;
                account.totalResourceCount = totalResourceCount;
                account.resources[totalResourceCount] = Resource({
                    balance: resourceReward,
                    resourceType: accountTool.resourceType
                });
            }
        }

        land.totalResourcePower -= accountShip.totalResourcePower;
        land.totalTokenPower -= accountShip.totalTokenPower;
        accountShip.isClaimed = true;
        accountShip.currentLandIndex = getNextLandIndex();
    }

    function shipEnergyRecover(uint256 _shipTokenId, uint256 _energy)
        public
        whenNotPaused
    {
        Account storage account = accounts[msg.sender];
        require(account.maximumEnergy > 0, "Account not found!");
        AccountShip storage accountShip = account.ships[_shipTokenId];
        require(
            accountShip.currentEnergy + _energy <= accountShip.maximumEnergy,
            "maximum energy exceeded"
        );
        require(accountShip.isClaimed == true, "Can't energy recover");
        require(
            accountShip.nextAvailability < block.timestamp,
            "Can't energy recover"
        );
        uint256 requiredElectric = _energy * energyMultiplier;
        bool checkResource = false;
        Resource storage accountResource;
        for (uint256 x = 0; x < account.totalResourceCount; x++) {
            accountResource = account.resources[x];
            if (accountResource.resourceType == ResourceTypes.Electric) {
                if (accountResource.balance >= requiredElectric) {
                    accountResource.balance -= requiredElectric;
                    accountShip.currentEnergy += _energy;
                } else {
                    revert("not enough electric");
                }
                checkResource = true;
                break;
            }
        }
        require(checkResource == true, "no electric for energy");
    }

    function accountEnergyRecover(uint256 _energy) public whenNotPaused {
        Account storage account = accounts[msg.sender];
        require(account.maximumEnergy > 0, "Account not found!");
        require(
            account.currentEnergy + _energy <= account.maximumEnergy,
            "maximum energy exceeded"
        );
        uint256 requiredElectric = _energy * energyMultiplier;
        bool checkResource = false;
        Resource storage accountResource;
        for (uint256 x = 0; x < account.totalResourceCount; x++) {
            accountResource = account.resources[x];
            if (accountResource.resourceType == ResourceTypes.Electric) {
                if (accountResource.balance >= requiredElectric) {
                    accountResource.balance -= requiredElectric;
                    account.currentEnergy += _energy;
                } else {
                    revert("not enough electric");
                }
                checkResource = true;
                break;
            }
        }
        require(checkResource == true, "no electric for energy");
    }

    function repair(uint256 _tokenId) public whenNotPaused {
        Account storage account = accounts[msg.sender];
        require(account.maximumEnergy > 0, "Account not found!");
        NFTStaker storage nftStaker = nftStakers[msg.sender];
        require(nftStaker.totalNftStaked > 0, "You have no tokens staked");
        NFTStake storage nftStake;
        require(
            nftStakerAddresses[_tokenId] == msg.sender,
            "Can't unstake tokens you don't own!"
        );
        uint256 requiredToken;
        for (uint256 j; j < nftStaker.totalNftStaked; ++j) {
            nftStake = nftStaker.nftStakes[j];
            if (nftStake.tokenId == _tokenId) {
                uint256 requiredDurability;
                if (nftStake.nftType == NFTTypes.Ship) {
                    AccountShip storage accountShip = account.ships[_tokenId];
                    requiredDurability =
                        accountShip.maximumDurability -
                        accountShip.currentDurability;
                    require(requiredDurability <= 0, "not need to repair");
                    accountShip.currentDurability = requiredDurability;
                } else if (nftStake.nftType == NFTTypes.Tool) {
                    AccountShip storage accountShip = account.ships[
                        nftStake.targetTokenId
                    ];
                    require(
                        accountShip.isClaimed == true,
                        "Can't unstake wait mission"
                    );
                    AccountTool storage accountTool = accountShip.tools[
                        nftStake.tokenId
                    ];
                    requiredDurability =
                        accountTool.maximumDurability -
                        accountTool.currentDurability;
                    require(requiredDurability <= 0, "not need to repair");
                    accountTool.currentDurability = requiredDurability;
                } else if (nftStake.nftType == NFTTypes.Robot) {
                    if (
                        nftStake.nftStakeType == NFTStakeTypes.ToolRobotWorker
                    ) {
                        AccountShip storage accountShip = account.ships[
                            nftStake.parentTokenId
                        ];
                        require(
                            accountShip.isClaimed == true,
                            "Can't unstake wait mission"
                        );
                        AccountTool storage accountTool = accountShip.tools[
                            nftStake.targetTokenId
                        ];
                        require(
                            accountTool.rarity != Rarities.None,
                            "Tool not exist"
                        );

                        AccountRobot storage accountRobot = accountTool.workers[
                            nftStake.tokenId
                        ];

                        requiredDurability =
                            accountRobot.maximumDurability -
                            accountRobot.currentDurability;
                        require(requiredDurability <= 0, "not need to repair");
                        accountRobot.currentDurability = requiredDurability;
                    } else if (
                        nftStake.nftStakeType ==
                        NFTStakeTypes.BuildingRobotWorker
                    ) {
                        AccountBuilding storage accountBuilding = account
                            .buildings[nftStake.targetTokenId];

                        require(
                            accountBuilding.rarity != Rarities.None,
                            "Building not exist"
                        );
                        AccountRobot storage accountRobot = accountBuilding
                            .workers[nftStake.tokenId];
                        require(
                            accountRobot.rarity != Rarities.None,
                            "Robot not exist"
                        );
                        requiredDurability =
                            accountRobot.maximumDurability -
                            accountRobot.currentDurability;
                        require(requiredDurability <= 0, "no need to repair");
                        accountRobot.currentDurability = requiredDurability;
                    } else if (
                        nftStake.nftStakeType == NFTStakeTypes.ShipRobotSoldier
                    ) {
                        AccountShip storage accountShip = account.ships[
                            nftStake.targetTokenId
                        ];
                        require(
                            accountShip.isClaimed == true,
                            "Can't unstake wait mission"
                        );
                        AccountRobot storage accountRobot = accountShip
                            .soldiers[nftStake.tokenId];
                        require(
                            accountRobot.rarity != Rarities.None,
                            "Robot not exist"
                        );
                        requiredDurability =
                            accountRobot.maximumDurability -
                            accountRobot.currentDurability;
                        require(requiredDurability <= 0, "no need to repair");
                        accountRobot.currentDurability = requiredDurability;
                    } else {
                        revert("Stake NFT type");
                    }
                } else if (nftStake.nftType == NFTTypes.Building) {
                    AccountBuilding storage accountBuilding = account.buildings[
                        _tokenId
                    ];
                    require(
                        accountBuilding.rarity != Rarities.None,
                        "Building not exist"
                    );
                    requiredDurability =
                        accountBuilding.maximumDurability -
                        accountBuilding.currentDurability;
                    require(requiredDurability <= 0, "no need to repair");
                    accountBuilding.currentDurability = requiredDurability;
                } else {
                    revert("NFT type");
                }
                requiredToken = requiredDurability / repairDivisor;
                require(
                    tokenContract.balanceOf(msg.sender) >= requiredToken,
                    "balance"
                );
                tokenContract.transferFrom(
                    msg.sender,
                    address(this),
                    requiredToken
                );
                break;
            }
        }
    }
    function craft(NFTTypes nftType) public whenNotPaused {        
        Account storage account = accounts[msg.sender];
        require(account.maximumEnergy > 0, "Account not found!");
        uint256 checkedResourceCount = 0;
        Resource storage accountResource;
        Resource memory craftResource;
        CraftConfig storage craftConfig  = craftConfigs[nftType];
        require(craftConfig.resources.length != 0, "craft config not found");
        require(packContract.balanceOf(address(this), craftConfig.packId) > 0, "Pack Balance");
        

        for (uint256 x = 0; x < account.totalResourceCount; x++) {
            accountResource = account.resources[x];
            for (uint256 i = 0; i < craftConfig.resources.length; i++) {
                craftResource = craftConfig.resources[i];
                if (accountResource.resourceType == craftResource.resourceType) {
                if (accountResource.balance >= craftResource.balance) {
                    accountResource.balance -= craftResource.balance;  
                    checkedResourceCount +=1;                 
                } else {
                    revert("not enough resource");
                }
                                
                }
            }            
        }
        require(checkedResourceCount == craftConfig.resources.length, "crafting resource error");

       packContract.safeTransferFrom(address(this), msg.sender, craftConfig.packId, 1, "");
    
    }

    function buildingUpgrade(uint256 _buildingTokenId) public {
        Account storage account = accounts[msg.sender];
        require(account.maximumEnergy > 0, "Account not found!");
        AccountBuilding storage accountBuilding = account.buildings[
            _buildingTokenId
        ];
        require(
            accountBuilding.rarity != Rarities.None &&
                accountBuilding.isReady == false && accountBuilding.nextAvailability <= block.timestamp,
            "Building not exist"
        );
        require(
                    tokenContract.balanceOf(msg.sender) >= accountBuilding.upgradePrice,
                    "balance"
                );
                tokenContract.transferFrom(
                    msg.sender,
                    address(this),
                    accountBuilding.upgradePrice
                );
            accountBuilding.nextAvailability = block.timestamp + accountBuilding.chargeTime;
           accountBuilding.upgrades+=1;
           if(accountBuilding.upgrades == accountBuilding.requiredUpgrades)
           {
            accountBuilding.isReady = true;
           }     

        
    }

    function buildingClaim(uint256 _buildingTokenId) public whenNotPaused {

        Account storage account = accounts[msg.sender];
        require(account.maximumEnergy > 0, "Account not found!");
        AccountBuilding storage accountBuilding = account.buildings[
            _buildingTokenId
        ];
        require(
            accountBuilding.rarity != Rarities.None &&
                accountBuilding.isReady == true && accountBuilding.nextAvailability <= block.timestamp,
            "Account Building not exist"
        );
        Building storage building = buildings[
            accountBuilding.tokenURI
        ];
         require(building.rarity != Rarities.None, "Building not exist");

        uint256 checkedResourceCount = 0;
        Resource storage accountResource;
        Resource memory resource;

        for (uint256 x = 0; x < account.totalResourceCount; x++) {
            accountResource = account.resources[x];
            for (uint256 i = 0; i < building.requiredResources.length; i++) {
                resource = building.requiredResources[i];
                if (accountResource.resourceType == resource.resourceType) {
                if (accountResource.balance >= resource.balance) {
                    accountResource.balance -= resource.balance;    
                     checkedResourceCount +=1;               
                } else {
                    revert("not enough resource");                  
                }
                               
                }
            }            
        }
        require(checkedResourceCount == building.requiredResources.length, "required resources error");   
        checkedResourceCount = 0;

         for (uint256 x = 0; x < account.totalResourceCount; x++) {
            accountResource = account.resources[x];
            for (uint256 i = 0; i < building.rewardResources.length; i++) {
                resource = building.rewardResources[i];
                if (accountResource.resourceType == resource.resourceType) {
                if (accountResource.balance >= resource.balance) {
                    accountResource.balance += resource.balance;    
                     checkedResourceCount +=1;               
                } else {
                    revert("not enough resource");                  
                }
                               
                }
            }            
        }
        require(checkedResourceCount == building.rewardResources.length, "reward resources error");

        accountBuilding.nextAvailability = block.timestamp + accountBuilding.chargeTime;

    }

    /*///////////////////////////////////////////////////////////////
                            Getter functions
    //////////////////////////////////////////////////////////////*/

     

    /*///////////////////////////////////////////////////////////////
                            Setter functions
    //////////////////////////////////////////////////////////////*/

   function addNFTType(string memory tokenURI, NFTTypes nftType)
        public
        onlyOwner
    {
        require(nftType != NFTTypes.None, "Error");   
        nftTypes[tokenURI] = nftType;       
    }

    function removeNFTType(string memory tokenURI) public onlyOwner {
        delete nftTypes[tokenURI];
    }

    function addLand(Land calldata land) 
    public
        onlyOwner
    {
        totalLand+=1;
        lands[totalLand] =land;
    }

    function removeLand(uint256 index) public
        onlyOwner
    {
        require(lands[index].rarity != Rarities.None, "Error");   
        totalLand-=1;
        delete lands[index];
    }

     function setBuilding(string memory tokenURI, Building calldata building) 
    public
        onlyOwner
    {        
        buildings[tokenURI] =building;
    }
    function removeBuilding(string memory tokenURI) public
        onlyOwner
    {
        require(buildings[tokenURI].rarity != Rarities.None, "Error");          
        delete buildings[tokenURI];
    }
    function setShip(string memory tokenURI, Ship calldata ship) 
    public
        onlyOwner
    {        
        ships[tokenURI] =ship;
    }
    function removeShip(string memory tokenURI) public
        onlyOwner
    {
        require(ships[tokenURI].rarity != Rarities.None, "Error");          
        delete ships[tokenURI];
    }
    function setTool(string memory tokenURI, Tool calldata tool) 
    public
        onlyOwner
    {        
        tools[tokenURI] = tool;
    }
    function removeTool(string memory tokenURI) public
        onlyOwner
    {
        require(tools[tokenURI].rarity != Rarities.None, "Error");          
        delete tools[tokenURI];
    }
    function setRobot(string memory tokenURI, Robot calldata robot) 
    public
        onlyOwner
    {        
        robots[tokenURI] = robot;
    }
    function removeRobot(string memory tokenURI) public
        onlyOwner
    {
        require(robots[tokenURI].rarity != Rarities.None, "Error");          
        delete robots[tokenURI];
    }

     function setCraftConfig(NFTTypes nftType, CraftConfig calldata craftConfig) 
    public
        onlyOwner
    {        
        require(craftConfigs[nftType].resources.length != 0, "Error");
        craftConfigs[nftType] = craftConfig;
    }
    function removeCraftConfig(NFTTypes nftType) public
        onlyOwner
    {
        require(craftConfigs[nftType].resources.length != 0, "Error");          
        delete craftConfigs[nftType];
    }
    

    /*///////////////////////////////////////////////////////////////
                        Miscellaneous
    //////////////////////////////////////////////////////////////*/

    uint256 randNonce;

    function generateRandomNumber(uint256 _modulus) internal returns (uint256) {
        randNonce++;
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.timestamp, msg.sender, randNonce)
                )
            ) % _modulus;
    }

    function getNextLandIndex() private returns (uint256) {
        if (nextLandIndex + 1 > totalLand) {
            nextLandIndex = 0;
        } else {
            nextLandIndex += 1;
        }
        return nextLandIndex;
    }

    function squareRoot(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function robotConvertToAccountRobot(Robot memory _robot)
        internal
        pure
        returns (AccountRobot memory accountRobot)
    {
        accountRobot.tokenURI = _robot.tokenURI;
        accountRobot.rarity = _robot.rarity;
        accountRobot.robotType = _robot.robotType;
        accountRobot.power = _robot.power;
        accountRobot.currentHealth = _robot.maximumHealth;
        accountRobot.maximumHealth = _robot.maximumHealth;
        accountRobot.currentDurability = _robot.maximumDurability;
        accountRobot.maximumDurability = _robot.maximumDurability;
        accountRobot.energyConsumed = _robot.energyConsumed;
        accountRobot.durabilityConsumed = _robot.durabilityConsumed;
        return accountRobot;
    }

    /*///////////////////////////////////////////////////////////////
                        ERC 721 logic
    //////////////////////////////////////////////////////////////*/

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
     function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC165Upgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IERC1155ReceiverUpgradeable).interfaceId ||
            interfaceId == type(IERC721ReceiverUpgradeable).interfaceId;
    }
}
