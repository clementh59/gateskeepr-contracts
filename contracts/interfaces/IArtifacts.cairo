%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IArtifacts:
    func balanceOf(owner: felt) -> (balance: Uint256):
    end

    func owner() -> (owner: felt):    
    end

    func ownerOf(tokenId: Uint256) -> (owner: felt):
    end

    func safeTransferFrom(
            from_: felt, 
            to: felt, 
            tokenId: Uint256, 
            data_len: felt,
            data: felt*
        ):
    end

    func transferFrom(from_: felt, to: felt, tokenId: Uint256):
    end

    func mint(to: felt, amount: felt):
    end

    func approve(approved: felt, tokenId: Uint256):
    end

    func setApprovalForAll(operator: felt, approved: felt):
    end

    func getApproved(tokenId: Uint256) -> (approved: felt):
    end

    func isApprovedForAll(owner: felt, operator: felt) -> (isApproved: felt):
    end

    func tokenURI(tokenId: Uint256) -> (tokenURI: felt):
    end

    func metadataHashState() -> (hash: felt):
    end

    func setMintingStep(step: felt):
    end

    func nextTokenId() -> (tokenId: Uint256):
    end
end