// This should have been deployed to Remix
// We will be using Solidity version 0.5.3
pragma solidity 0.6.3;



import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol";


contract ViperToken is ERC721{
    using SafeMath for uint256;
    // This struct will be used to represent one viper
    struct Viper {
        uint8 genes;
        uint256 matronId;
        uint256 sireId;
    }
    
    // List of existing vipers
    Viper[] public vipers;

    // Event that will be emitted whenever a new viper is created
    event Birth(
        address owner,
        uint256 viperId,
        uint256 matronId,
        uint256 sireId,
        uint8 genes
    );

    // Initializing an ERC-721 Token named 'Vipers' with a symbol 'VPR'
    constructor() ERC721("Vipers", "VPR") public {
    }


    function generateViperGenes(
        uint256 matron,
        uint256 sire
    )
        internal
        pure
        returns (uint8)
    {
        return uint8(matron.add(sire)) % 6 + 1;
    }


    function createViper(uint256 matron, uint256 sire, address viperOwner) internal returns (uint) {
        require(viperOwner != address(0));
       
        uint8 newGenes = generateViperGenes(matron, sire);
        
        Viper memory newViper = Viper({
        
            genes: newGenes,
            matronId: matron,
            sireId: sire
        });
        
        vipers.push(newViper);
        uint256 newViperId = vipers.length;
        
       //uint256 newViperId = vipers.push(newViper);
       // uint256 newViperId = sub(vipers.push(newViper) - 1);
       //uint256 newViperId = vipers.push(newViper).sub(1);
       
       
        super._mint(viperOwner, newViperId);
        emit Birth(
            viperOwner,
            newViperId,
            newViper.matronId,
            newViper.sireId,
            newViper.genes
        );
        return newViperId;
    }
    

    function buyViper() external payable returns (uint256) {
        require(msg.value == 0.02 ether);
        return createViper(0, 0, msg.sender);
    }
    

    function breedVipers(uint256 matronId, uint256 sireId) external payable returns (uint256) {
        require(msg.value == 0.05 ether);
        return createViper(matronId, sireId, msg.sender);
    }
    

    function getViperDetails(uint256 viperId) external view returns (uint256, uint8, uint256, uint256) {
        Viper storage viper = vipers[viperId];
        return (viperId, viper.genes, viper.matronId, viper.sireId);
    }
    

    function ownedVipers() external view returns(uint256[] memory) {
        uint256 viperCount = balanceOf(msg.sender);
        if (viperCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](viperCount);
            uint256 totalVipers = vipers.length;
            uint256 resultIndex = 0;
            uint256 viperId = 0;
            while (viperId < totalVipers) {
                if (ownerOf(viperId) == msg.sender) {
                    result[resultIndex] = viperId;
                    resultIndex = resultIndex.add(1);
                }
                viperId = viperId.add(1);
            }
            return result;
        }
    }
}