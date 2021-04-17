// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./lib/Ownable.sol";


// 慈善勋章
contract CharityMedal is ERC721 ,Ownable{
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  string itemURI = "https://ipfs.io/ipfs/QmZb9yftwSV6NEW8RfDVHHrJ9dGPZdWhAxecqTSV78wQUt";
  address charityFactoryAddress;
  mapping(address => uint[]) public myItems;

  modifier onlyCharityFactory() {
    require(msg.sender == charityFactoryAddress,'Must CharityFactory');
    _;
  }

  constructor(address _charityFactoryAddress) public ERC721("CharityMedal", "CM") {
    charityFactoryAddress = _charityFactoryAddress;
  }

  function updateCharityFactoryAddress(address _newAddress) public onlyOwner{
    charityFactoryAddress = _newAddress;
  }

  function updateItemURI(string memory _uri) public onlyOwner{
    itemURI = _uri;
  }

  function awardItem(address player)
    public
    onlyCharityFactory
    returns (uint256)
  {
    _tokenIds.increment();

    uint256 newItemId = _tokenIds.current();
    _mint(player, newItemId);
    _setTokenURI(newItemId, itemURI);
    myItems[player].push(newItemId);
    return newItemId;
  }

  function getMyItems(address player) public view returns(uint[] memory itemIds){
    itemIds = myItems[player];
  }

  //合约销毁
  function destroy() public onlyOwner{
    selfdestruct(msg.sender);
  }
}