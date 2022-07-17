%lang starknet

from starkware.cairo.common.uint256 import Uint256
from contracts.utils.ArtifactTypeUtils import (
    ChuckyArtifact,
    RoomArtifact,
    OrbArtifact,
    CataclystArtifact,
    HackEyeArtifact,
    CopycatArtifact,
    FreeProposalsArtifact,
    GodModeArtifact
)

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

    func tokenURI(tokenId: Uint256) -> (token_uri_len : felt, token_uri : felt*):
    end

    func numAvailableTokens() -> (res: felt):
    end

    func setMintingStep(step: felt):
    end

    func mintingStep() -> (step: felt):
    end

    func getArtifactType(tokenId: Uint256) -> (res: felt):
    end

    func getChuckyArtifact(tokenId: Uint256) -> (chucky: ChuckyArtifact):
    end

    func getRoomArtifact(tokenId: Uint256) -> (room: RoomArtifact):
    end

    func getOrbArtifact(tokenId: Uint256) -> (orb: OrbArtifact):
    end

    func getCataclystArtifact(tokenId: Uint256) -> (cataclyst: CataclystArtifact):
    end

    func getHackEyeArtifact(tokenId: Uint256) -> (hackEye: HackEyeArtifact):
    end

    func getCopycatArtifact(tokenId: Uint256) -> (copycat: CopycatArtifact):
    end

    func getFreeProposalArtifact(tokenId: Uint256) -> (freeProposals: FreeProposalsArtifact):
    end

    func getGodModeArtifact(tokenId: Uint256) -> (godMode: GodModeArtifact):
    end

end