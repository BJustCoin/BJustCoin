// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {VestingManager} from "./VestingManager.sol";
import {Schedule, Vesting} from "./IVestingToken.sol";
import {VestingToken} from "./VestingToken.sol";
import {Bjustcoin} from "./Bjustcoin.sol";
import {Oracle} from "./Oracle.sol";

/**
 * @notice enumeration of the types of tokenomics used
 */
enum TokenomicType {
    Strategic,
    Seed,
    PrivateSale,
    IDO,
    PublicSale,
    Advisors,
    Team,
    FutureTeam,
    Incentives,
    Liquidity,
    Ecosystem,
    Loyalty
}

/**
 *  @notice enumeration of the stage ICO
 */
enum ICOStage {
    NoICO,
    Strategic,
    Seed,
    PrivateSale,
    IDO,
    PublicSale,
    EndICO
}

/**
 *  @notice tokenomics settings
 */
struct TokenomicSetting {
    address stageToken; //адрес по которому хранится тип токена
    string nameToken; //наименование токена
    string simvolToken; //символ токена
    uint256 maxTokenCount; //максимальное количество токенов
    uint256 soldTokenCount; //продано токенов
    uint8 price; //цена
    uint8 cliffMonth; //период less, в месяцах
    uint8 vestingMonth; //период vesting, в месяцах
    uint8 unlockTokensPercent; //процент разблокированных токенов по окончании периода less
}

/**
 * @title   Manager ICO for BJustCoin
 * @dev     Implements ICO mechanisms
 * @notice  Implements ICO mechanisms
 */
contract ICOManager is Ownable2Step {
    /**
     * @dev the smallest common multiple for the values of the westing months in tokenomics
     */
    uint256 private constant BASIS_TOKENS_FOR_VESTING_TOKENS = 5040;
    uint256 private constant MONTH = 365 days / 12;
    /**
     * @dev the default course value, in case the oracle returned an error
     */
    uint256 private constant DEFAULT_RATE = 257673;
    uint256 private constant MIN_SOLD_VOLUME = 1000; //10$
    Oracle internal immutable _oracle;
    VestingToken internal immutable _vestingTokenImpl;
    VestingManager internal immutable _vestingManager;
    Bjustcoin internal immutable _baseToken;
    ICOStage private icoStage;
    mapping(address => bool) public blacklists;
    mapping(TokenomicType => TokenomicSetting) private tokenomicSettings;

    //region - Events
    /////////////////////
    //      Ewents     //
    /////////////////////
    event ICOStageChanged(address indexed from, ICOStage initialStage, ICOStage newStage);
    event BuyToken(address indexed from, address indexed to, string tokenSimvol, uint256 tokenCount, uint256 rate);
    event Withdraw(address indexed to, uint256 amount);
    //endregion

    //region - Errors
    /////////////////////
    //      Errors     //
    /////////////////////
    error Blacklisted();
    error ICONotStarted();
    error ICOCompleted();
    error TokenAlreadyExist();
    error MinSoldError();
    error InsufficientFunds();
    error WithdrawError();
    error NotApprove();
    //endregion

    //region - Modifier
    /////////////////////
    //     Modifier    //
    /////////////////////
    /**
     * @notice  we check whether the address is included in the blocked list
     * @dev     we check whether the address is included in the blocked list
     * @param   to  the address being checked
     */
    modifier notInBlackList(address to) {
        if (blacklists[to]) revert Blacklisted();
        _;
    }
    //endregion

    constructor() Ownable(msg.sender) {
        _vestingTokenImpl = new VestingToken(BASIS_TOKENS_FOR_VESTING_TOKENS);
        _vestingManager = new VestingManager(address(_vestingTokenImpl));
        _baseToken = new Bjustcoin(address(this));
        _oracle = new Oracle();

        icoStage = ICOStage.NoICO;
        initTokenomics();
        initVestingToken(tokenomicSettings[TokenomicType.Advisors]);
        initVestingToken(tokenomicSettings[TokenomicType.Team]);
        initVestingToken(tokenomicSettings[TokenomicType.FutureTeam]);
        initVestingToken(tokenomicSettings[TokenomicType.Incentives]);
        initVestingToken(tokenomicSettings[TokenomicType.Liquidity]);
        initVestingToken(tokenomicSettings[TokenomicType.Ecosystem]);
        initVestingToken(tokenomicSettings[TokenomicType.Loyalty]);
    }

    //region External
    /**
     * @notice  purchase of an ICO stage token
     * @dev     purchase stage token. The type of token depends on the ICO stage
     */
    function buyICOToken() external payable notInBlackList(msg.sender) {
        if (icoStage == ICOStage.NoICO) revert ICONotStarted();
        else if (icoStage == ICOStage.EndICO) revert ICOCompleted();
        else if (icoStage == ICOStage.Strategic) buyStrategicToken();
        else if (icoStage == ICOStage.Seed) buySeedToken();
        else if (icoStage == ICOStage.PrivateSale) buyPrivateSaleToken();
        else if (icoStage == ICOStage.IDO) buyIDOToken();
        else if (icoStage == ICOStage.PublicSale) buyPublicSaleToken();
    }

    /**
     * @notice  purchase of a Advisors token
     * @dev     purchase of a Advisors token
     */
    function buyAdvisorsToken() external payable notInBlackList(msg.sender) {
        buyToken(tokenomicSettings[TokenomicType.Advisors]);
    }

    /**
     * @notice  purchase of a Team token
     * @dev     purchase of a Team token
     */
    function buyTeamToken() external payable notInBlackList(msg.sender) {
        buyToken(tokenomicSettings[TokenomicType.Team]);
    }

    /**
     * @notice  purchase of a Future Team token
     * @dev     purchase of a Future Team token
     */
    function buyFutureTeamToken() external payable notInBlackList(msg.sender) {
        buyToken(tokenomicSettings[TokenomicType.FutureTeam]);
    }

    /**
     * @notice  purchase of a Incentives token
     * @dev     purchase of a Incentives token
     */
    function buyIncentivesToken() external payable notInBlackList(msg.sender) {
        buyToken(tokenomicSettings[TokenomicType.Incentives]);
    }

    /**
     * @notice  purchase of a Liquidity token
     * @dev     purchase of a Liquidity token
     */
    function buyLiquidityToken() external payable notInBlackList(msg.sender) {
        buyToken(tokenomicSettings[TokenomicType.Liquidity]);
    }

    /**
     * @notice  purchase of a Ecosystem token
     * @dev     purchase of a Ecosystem token
     */
    function buyEcosystemToken() external payable notInBlackList(msg.sender) {
        buyToken(tokenomicSettings[TokenomicType.Ecosystem]);
    }

    /**
     * @notice  purchase of a Loyalty token
     * @dev     purchase of a Loyalty token
     */
    function buyLoyaltyToken() external payable notInBlackList(msg.sender) {
        buyToken(tokenomicSettings[TokenomicType.Loyalty]);
    }

    /**
     * @notice  withdraw eth from the contract
     * @dev     withdraw eth from the contract
     */
    function withdraw() external payable onlyOwner {
        //payable(owner()).transfer(address(this).balance);
        // get the amount of Ether stored in this contract
        uint256 amount = address(this).balance;
        emit Withdraw(owner(), amount);
        // send all Ether to owner
        (bool success,) = address(owner()).call{value: amount}("");
        if (!success) revert WithdrawError();
    }

    /**
     * @notice  Adding or removing an address to the blacklist
     * @dev     Adding or removing an address to the blacklist
     * @param   _address  Address additing or removing to the blacklist
     * @param   _isBlacklisting  true - add; false - remov;
     */
    function blacklist(address _address, bool _isBlacklisting) external payable onlyOwner {
        if (blacklists[_address] != _isBlacklisting) {
            blacklists[_address] = _isBlacklisting;
            _baseToken.blacklist(_address, _isBlacklisting);
        }
    }

    /**
     * @notice  Moving the ICO to the next stage
     * @dev     Moving the ICO to the next stage
     */
    function nextICOStage() external payable onlyOwner {
        //"ICO completed"
        if (icoStage == ICOStage.EndICO) {
            revert ICOCompleted();
        }
        ICOStage initialStage = icoStage;
        icoStage = ICOStage(uint256(icoStage) + 1);
        emit ICOStageChanged(msg.sender, initialStage, icoStage);
        if (icoStage != ICOStage.EndICO && initialStage != ICOStage.NoICO) {
            TokenomicType _initTokenomicType = getTokenomicType(initialStage);
            TokenomicType _tokenomicType = getTokenomicType(icoStage);

            tokenomicSettings[_tokenomicType].maxTokenCount += (
                tokenomicSettings[_initTokenomicType].maxTokenCount
                    - tokenomicSettings[_initTokenomicType].soldTokenCount
            );
            tokenomicSettings[_initTokenomicType].maxTokenCount = tokenomicSettings[_initTokenomicType].soldTokenCount;
            initVestingToken(tokenomicSettings[_tokenomicType]);
        } else if (icoStage == ICOStage.EndICO) {
            uint256 burnCount = tokenomicSettings[TokenomicType.PublicSale].maxTokenCount
                - tokenomicSettings[TokenomicType.PublicSale].soldTokenCount;
            tokenomicSettings[TokenomicType.PublicSale].maxTokenCount =
                tokenomicSettings[TokenomicType.PublicSale].soldTokenCount;
            _baseToken.burn(burnCount);
        } else {
            initVestingToken(tokenomicSettings[TokenomicType.Strategic]);
        }
    }

    //endregion

    //region Public

    /**
     * @notice  get a Bjustcoin
     * @dev     get a basic token
     * @return  Bjustcoin  basic token
     */
    function getBaseToken() public view returns (Bjustcoin) {
        return _baseToken;
    }

    /**
     * @notice  get ICO stage
     * @dev     get ICO stage
     * @return  ICOStage  stage
     */
    function getICOStage() public view returns (ICOStage) {
        return icoStage;
    }

    /**
     * @notice  get stategic token
     * @dev     get stategic token
     * @return  VestingToken
     */
    function strategicToken() public view returns (VestingToken) {
        return VestingToken(tokenomicSettings[TokenomicType.Strategic].stageToken);
    }

    /**
     * @notice  get seed token
     * @dev     get seed token
     * @return  VestingToken
     */
    function seedToken() public view returns (VestingToken) {
        return VestingToken(tokenomicSettings[TokenomicType.Seed].stageToken);
    }

    /**
     * @notice  get private sale token
     * @dev     get private sale token
     * @return  VestingToken
     */
    function privateSaleToken() public view returns (VestingToken) {
        return VestingToken(tokenomicSettings[TokenomicType.PrivateSale].stageToken);
    }

    /**
     * @notice  get IDO token
     * @dev     get IDO token
     * @return  VestingToken
     */
    function idoToken() public view returns (VestingToken) {
        return VestingToken(tokenomicSettings[TokenomicType.IDO].stageToken);
    }

    /**
     * @notice  get public sale token
     * @dev     get public sale token
     * @return  VestingToken
     */
    function publicSaleToken() public view returns (VestingToken) {
        return VestingToken(tokenomicSettings[TokenomicType.PublicSale].stageToken);
    }

    /**
     * @notice  get advisors token
     * @dev     get advisors token
     * @return  VestingToken
     */
    function advisorsToken() public view returns (VestingToken) {
        return VestingToken(tokenomicSettings[TokenomicType.Advisors].stageToken);
    }

    /**
     * @notice  get teem token
     * @dev     get teem token
     * @return  VestingToken
     */
    function teamToken() public view returns (VestingToken) {
        return VestingToken(tokenomicSettings[TokenomicType.Team].stageToken);
    }

    /**
     * @notice  get future team token
     * @dev     get future team token
     * @return  VestingToken
     */
    function futureTeamToken() public view returns (VestingToken) {
        return VestingToken(tokenomicSettings[TokenomicType.FutureTeam].stageToken);
    }

    /**
     * @notice  get incentives token
     * @dev     get incentives token
     * @return  VestingToken
     */
    function incentivesToken() public view returns (VestingToken) {
        return VestingToken(tokenomicSettings[TokenomicType.Incentives].stageToken);
    }

    /**
     * @notice  get liquidity token
     * @dev     get liquidity token
     * @return  VestingToken
     */
    function liquidityToken() public view returns (VestingToken) {
        return VestingToken(tokenomicSettings[TokenomicType.Liquidity].stageToken);
    }

    /**
     * @notice  get ecosystem token
     * @dev     get ecosystem token
     * @return  VestingToken
     */
    function ecosystemToken() public view returns (VestingToken) {
        return VestingToken(tokenomicSettings[TokenomicType.Ecosystem].stageToken);
    }

    /**
     * @notice  get loyalty token
     * @dev     get loyalty token
     * @return  VestingToken
     */
    function loyaltyToken() public view returns (VestingToken) {
        return VestingToken(tokenomicSettings[TokenomicType.Loyalty].stageToken);
    }

    /**
     * @notice  get tokenomic type for ICO stage
     * @dev     get tokenomic type for ICO stage
     * @return  TokenomicType
     */
    function getTokenomicType() public view returns (TokenomicType) {
        return getTokenomicType(icoStage);
    }

    /**
     * @notice  get rate eth/usd
     * @dev     get rate eth/usd from oracle. if the oracle did not return the value of the exchange rate, the default value is returned
     * @return  rate  .
     */
    function getRate() public view returns (uint256 rate) {
        try _oracle.getLatestPrice() returns (int256 _rate) {
            return uint256(_rate);
        } catch {
            return DEFAULT_RATE;
        }
    }

    //endregion

    //region Private
    /**
     * @notice  get tokenomic type
     * @dev     get tokenomic type
     * @param   _icoStage  ICO stage
     * @return  TokenomicType
     */
    function getTokenomicType(ICOStage _icoStage) private pure returns (TokenomicType) {
        if (_icoStage == ICOStage.NoICO) {
            revert ICONotStarted();
        }
        if (_icoStage == ICOStage.EndICO) {
            revert ICOCompleted();
        }

        if (_icoStage == ICOStage.Strategic) return TokenomicType.Strategic;
        else if (_icoStage == ICOStage.Seed) return TokenomicType.Seed;
        else if (_icoStage == ICOStage.PrivateSale) return TokenomicType.PrivateSale;
        else if (_icoStage == ICOStage.IDO) return TokenomicType.IDO;
        else return TokenomicType.PublicSale;
    }

    /**
     * @notice  Initial tokenomics params
     * @dev     Initial tokenomics params
     */
    function initTokenomics() private {
        tokenomicSettings[TokenomicType.Strategic] =
            TokenomicSetting(address(0), "BJCStrategic", "BJCSTR", 3_000_000 * 1e18, 0, 35, 12, 24, 0);
        tokenomicSettings[TokenomicType.Seed] =
            TokenomicSetting(address(0), "BJCSeed", "BJCSEED", 4_000_000 * 1e18, 0, 45, 12, 24, 0);
        tokenomicSettings[TokenomicType.PrivateSale] =
            TokenomicSetting(address(0), "BJCPrivateSale", "BJCPRI", 6_000_000 * 1e18, 0, 55, 12, 28, 5);
        tokenomicSettings[TokenomicType.IDO] =
            TokenomicSetting(address(0), "BJCIDO", "BJCIDO", 5_000_000 * 1e18, 0, 65, 6, 30, 15);
        tokenomicSettings[TokenomicType.PublicSale] =
            TokenomicSetting(address(0), "BJCPublicSale", "BJCPUB", 15_000_000 * 1e18, 0, 75, 9, 24, 5);
        tokenomicSettings[TokenomicType.Advisors] =
            TokenomicSetting(address(0), "BJCAdvisors", "BJCADV", 1_500_000 * 1e18, 0, 75, 12, 36, 3);
        tokenomicSettings[TokenomicType.Team] =
            TokenomicSetting(address(0), "BJCTeam", "BJCTEAM", 4_500_000 * 1e18, 0, 75, 24, 24, 5);
        tokenomicSettings[TokenomicType.FutureTeam] =
            TokenomicSetting(address(0), "BJCFutureTeam", "BJCFUT", 5_000_000 * 1e18, 0, 75, 12, 24, 0);
        tokenomicSettings[TokenomicType.Incentives] =
            TokenomicSetting(address(0), "BJCIncentives", "BJCINC", 11_000_000 * 1e18, 0, 75, 0, 18, 15);
        tokenomicSettings[TokenomicType.Liquidity] =
            TokenomicSetting(address(0), "BJCLiquidity", "BJCLIQ", 15_000_000 * 1e18, 0, 75, 0, 18, 25);
        tokenomicSettings[TokenomicType.Ecosystem] =
            TokenomicSetting(address(0), "BJCEcosystem", "BJCECO", 15_000_000 * 1e18, 0, 75, 0, 12, 10);
        tokenomicSettings[TokenomicType.Loyalty] =
            TokenomicSetting(address(0), "BJCLoyalty", "BJCLOY", 15_000_000 * 1e18, 0, 75, 0, 48, 0);
    }

    /**
     * @notice  Initial tokenomic vesting data
     * @dev     Initial tokenomic vesting data
     * @param   _settings  Settings tokenomic
     */
    function initVestingToken(TokenomicSetting storage _settings) private {
        TokenomicSetting memory tsSettings = _settings;
        Schedule[] memory schedule = new Schedule[](tsSettings.vestingMonth);
        uint256 partTokenVesting = BASIS_TOKENS_FOR_VESTING_TOKENS / tsSettings.vestingMonth;
        for (uint256 i = 0; i < tsSettings.vestingMonth; i++) {
            schedule[i] = Schedule(block.timestamp + tsSettings.cliffMonth * MONTH + (i + 1) * MONTH, partTokenVesting);
        }
        Vesting memory vestingParams = Vesting(
            block.timestamp, block.timestamp + tsSettings.cliffMonth * MONTH, tsSettings.unlockTokensPercent, schedule
        );
        _settings.stageToken = _vestingManager.createVesting(
            tsSettings.nameToken, tsSettings.simvolToken, address(_baseToken), address(this), vestingParams
        );
    }

    /**
     * @notice  buy token
     * @dev     buy token
     * @param   settings  setting tokens for purchase
     */
    function buyToken(TokenomicSetting storage settings) private {
        uint256 rate = getRate();
        if (msg.value <= MIN_SOLD_VOLUME * 1e18 / rate) {
            revert MinSoldError();
        }
        uint256 tokens = msg.value * rate / settings.price;
        if (tokens > settings.maxTokenCount - settings.soldTokenCount) {
            revert InsufficientFunds();
        }
        emit BuyToken(owner(), msg.sender, settings.simvolToken, tokens, rate);
        if (!_baseToken.approve(settings.stageToken, tokens)) revert NotApprove();
        VestingToken(settings.stageToken).mint(msg.sender, tokens);
        settings.soldTokenCount += tokens;
    }

    /**
     * @notice  purchase strategic token
     * @dev     purchase strategic token
     */
    function buyStrategicToken() private {
        buyToken(tokenomicSettings[TokenomicType.Strategic]);
    }

    /**
     * @notice  purchase seed token
     * @dev     purchase seed token
     */
    function buySeedToken() private {
        buyToken(tokenomicSettings[TokenomicType.Seed]);
    }

    /**
     * @notice  purchase private sale token
     * @dev     purchase private sale token
     */
    function buyPrivateSaleToken() private {
        buyToken(tokenomicSettings[TokenomicType.PrivateSale]);
    }

    /**
     * @notice  purchase IDO token
     * @dev     purchase IDO token
     */
    function buyIDOToken() private {
        buyToken(tokenomicSettings[TokenomicType.IDO]);
    }

    /**
     * @notice  purchase public sale token
     * @dev     purchase public sale token
     */
    function buyPublicSaleToken() private {
        buyToken(tokenomicSettings[TokenomicType.PublicSale]);
    }
    //endregion
}
