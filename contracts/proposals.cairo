%lang starknet
from starkware.cairo.common.math import (
    assert_nn, assert_not_zero
)
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import (
    get_caller_address,
    get_contract_address,
)
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add
)
from contracts.interfaces.IArtifacts import IArtifacts
from contracts.interfaces.IERC20 import IERC20
from contracts.utils.ArtifactTypeUtils import (
    ChuckyArtifact,
    RoomArtifact,
    OrbArtifact,
    CataclystArtifact,
    HackEyeArtifact,
    CopycatArtifact,
    FreeProposalsArtifact,
    GodModeArtifact,
)
from contracts.utils.constants import (
    R,
    PROPOSAL_PRICE
)

#
# Events
#

@event
func Proposal(from_: felt, room: felt, value: felt):
end

#
# Storage
#

@storage_var
func artifactContractAddress_() -> (address : felt):
end

@storage_var
func erc20ContractAddr_() -> (address : felt):
end

# todo: returns all the proposals as a list?
@storage_var
func proposals(account: felt) -> (number : felt):
end

#
# Constructor
#

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    artifactContractAddress: felt, erc20Addr: felt):
    artifactContractAddress_.write(value=artifactContractAddress)
    erc20ContractAddr_.write(value=erc20Addr)
    return ()
end

#
# View
#

@view
func get_proposals{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(account: felt) -> (
        res : felt):
    let (res) = proposals.read(account=account)
    return (res)
end

# When an user uses a FP NFT to make a proposal
@external
func proposeFromFreeProposal{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        room: felt, value: felt, tokenId: Uint256):
    let (caller) = get_caller_address()
    let (artifact_addr) = artifactContractAddress_.read()

    # if this call revert, it means that the token has been burned, or hasn't been minted yet
    let (owner) = IArtifacts.ownerOf(contract_address=artifact_addr, tokenId=tokenId)
    let (fpArtifact : FreeProposalsArtifact) = IArtifacts.getFreeProposalArtifact(contract_address=artifact_addr, tokenId=tokenId)

    # we check that the caller is the owner of the fp artifact
    with_attr error_message("Only the owner of the artifact can ask for free proposals"):
        assert owner = caller
    end
    
    # we check if the artifact is for ROOM_ALL, or if it is for the room in which we propose
    with_attr error_message("The artifact can't be used in this room"):
        assert ((room - fpArtifact.room_number) * (R.ROOM_ALL - fpArtifact.room_number)) = 0
    end

    IArtifacts.consumeFPArtifact(contract_address=artifact_addr, tokenId=tokenId)

    _propose(room, value)
    return ()
end

@external
func propose{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        room : felt, value: felt):
    let (erc20Addr) = erc20ContractAddr_.read()
    let (caller) = get_caller_address()
    let (contractAddr) = get_contract_address()
    let amount = Uint256(PROPOSAL_PRICE,0)
    IERC20.transferFrom(
        contract_address=erc20Addr,
        sender=caller,
        recipient=contractAddr,
        amount=amount
    )
    _propose(room, value)
    return ()
end

func _propose{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        room : felt, value: felt):
    let (caller) = get_caller_address()
    let (current_proposals) = proposals.read(account=caller)
    proposals.write(account=caller, value=current_proposals+1)
    Proposal.emit(caller, room, value)
    return ()
end