// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./lib/Ownable.sol";
import "./lib/SponsorWhitelistControl.sol";

// 慈善勋章
contract CharityMedal is ERC721 ,Ownable{
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  string itemURI = "https://ipfs.io/ipfs/QmZb9yftwSV6NEW8RfDVHHrJ9dGPZdWhAxecqTSV78wQUt";
  address charityFactoryAddress;
  mapping(address => uint[]) private myItems;
  address[] private Owners;
  SponsorWhitelistControl constant public SPONSOR = SponsorWhitelistControl(0x0888000000000000000000000000000000000001);

  modifier onlyCharityFactory() {
    require(msg.sender == charityFactoryAddress,'Must CharityFactory');
    _;
  }

  constructor(address _charityFactoryAddress) public ERC721("CharityMedal", "CM") {
    charityFactoryAddress = _charityFactoryAddress;
    address[] memory users = new address[](1);
    users[0] = address(0);
    SPONSOR.addPrivilege(users);
  }

  // 更改需求工厂合约地址
  function updateCharityFactoryAddress(address _newAddress) public onlyOwner{
    charityFactoryAddress = _newAddress;
  }

  //更改物品URI
  function updateItemURI(string memory _uri) public onlyOwner{
    itemURI = _uri;
  }

  // 颁发物品(勋章)
  function awardItem(address player)
    public
    onlyCharityFactory
    returns (uint256)
  {
    _tokenIds.increment();

    uint256 newItemId = _tokenIds.current();
    _mint(player, newItemId);
    _setTokenURI(newItemId, itemURI);
    if(myItems[player].length==0){
      Owners.push(player);
    }
    myItems[player].push(newItemId);
    return newItemId;
  }

  //获取拥有的物品id
  function getItemIds(address player) public view returns(uint[] memory itemIds){
    itemIds = myItems[player];
  }

  //获取所有拥有者
  function getOwners() public view returns(address[] memory _Owners){
    _Owners = Owners;
  }

  //合约销毁
  function destroy() public onlyOwner{
    selfdestruct(msg.sender);
  }
}