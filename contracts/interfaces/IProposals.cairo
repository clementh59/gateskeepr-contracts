%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IProposals:
    func generateVRF() -> (rnd: felt):
    end

    func get_proposals(account: felt) -> (res : felt):
    end

    func proposeFromFreeProposal(room : felt, value: felt, tokenId: Uint256):
    end

    func propose(room : felt, value: felt):
    end
end