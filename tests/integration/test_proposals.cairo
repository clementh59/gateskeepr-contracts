%lang starknet
from contracts.interfaces.IProposals import IProposals
from contracts.interfaces.IArtifacts import IArtifacts
from starkware.cairo.common.cairo_builtins import HashBuiltin
from tests.constants import (
    CALLER_ADDRESS,
    CALLER_2_ADDRESS,
    ADMIN,
    TD,
)
from starkware.cairo.common.uint256 import Uint256
from contracts.utils.constants import (
    MAX_MINT_PER_ROW,
    R,
)
from tests.integration.deployer import (test_integration, DeployedContracts)

@external
func __setup__{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    let (deployed_contracts : DeployedContracts) = test_integration.deploy_contracts(maxSupply=17)
    let artifact_address = deployed_contracts.artifact_address
    let vrf_address = deployed_contracts.vrf_address
    let proposals_address = deployed_contracts.proposals_address

    %{ context.artifact_address = ids.artifact_address %}
    %{ context.vrf_address = ids.vrf_address %}
    %{ context.proposals_address = ids.proposals_address %}
    
    %{ stop_prank_callable = start_prank(caller_address=ids.ADMIN, target_contract_address=ids.deployed_contracts.artifact_address)%}

    IArtifacts.mint(
        contract_address=deployed_contracts.artifact_address,
        to=CALLER_ADDRESS,
        amount=MAX_MINT_PER_ROW
    )
    IArtifacts.mint(
        contract_address=deployed_contracts.artifact_address,
        to=CALLER_ADDRESS,
        amount=7
    )

    %{ stop_prank_callable() %}

    return ()
end

# @external
# func test_should_be_able_to_propose{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
#     %{ stop_prank_callable = start_prank(ids.CALLER_ADDRESS) %}
#     let (result_before) = proposals.read(account=CALLER_ADDRESS)
#     assert result_before = 0

#     propose(3, 42)

#     %{ expect_events({"name": "Proposal", "data": [ids.CALLER_ADDRESS, 3, 42]}) %}
#     let (result_after) = proposals.read(account=CALLER_ADDRESS)
#     assert result_after = 1

#     %{ stop_prank_callable() %}
#     return ()
# end

#
# Test - Proposal using Free Proposal artifacts
#
@external
func test_should_be_able_to_propose_for_free_with_valid_artifact_for_this_room{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()
    
    %{ stop_prank_callable = start_prank(caller_address=ids.CALLER_ADDRESS, target_contract_address=ids.deployed_contracts.proposals_address)%}

    IProposals.proposeFromFreeProposal(contract_address=deployed_contracts.proposals_address, room=R.ROOM_2, value=0x123, tokenId=Uint256(TD.FP_T1, 0))

    %{ expect_events({"name": "Proposal", "data": [ids.CALLER_ADDRESS, ids.R.ROOM_2, 0x123]}) %}

    %{ stop_prank_callable() %}
    return ()
end

@external
func test_should_be_able_to_propose_for_free_with_valid_artifact_for_ALL_rooms{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()
    
    %{ stop_prank_callable = start_prank(caller_address=ids.CALLER_ADDRESS, target_contract_address=ids.deployed_contracts.proposals_address)%}

    IProposals.proposeFromFreeProposal(contract_address=deployed_contracts.proposals_address, room=R.ROOM_4, value=27, tokenId=Uint256(TD.FP_T2, 0))

    %{ expect_events({"name": "Proposal", "data": [ids.CALLER_ADDRESS, ids.R.ROOM_4, 27]}) %}

    %{ stop_prank_callable() %}
    return ()
end

@external
func test_should_not_be_able_to_propose_for_free_with_valid_artifact_without_being_the_owner{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()
    
    %{ stop_prank_callable = start_prank(caller_address=ids.CALLER_2_ADDRESS, target_contract_address=ids.deployed_contracts.proposals_address)%}

    %{ expect_revert(error_message="Only the owner of the artifact can ask for free proposals") %}
    IProposals.proposeFromFreeProposal(contract_address=deployed_contracts.proposals_address, room=R.ROOM_2, value=0x123, tokenId=Uint256(TD.FP_T1, 0))

    %{ stop_prank_callable() %}
    return ()
end

@external
func test_should_not_be_able_to_propose_for_free_with_artifact_valid_for_another_room{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()
    
    %{ stop_prank_callable = start_prank(caller_address=ids.CALLER_ADDRESS, target_contract_address=ids.deployed_contracts.proposals_address)%}

    # The artifact allows the owner to make 2 free proposals - those 2 have already been used above

    %{ expect_revert(error_message="The artifact can't be used in this room") %}
    IProposals.proposeFromFreeProposal(contract_address=deployed_contracts.proposals_address, room=R.ROOM_3, value=0x123, tokenId=Uint256(TD.FP_T1, 0))

    %{ stop_prank_callable() %}
    return ()
end

@external
func test_should_not_be_able_to_propose_for_free_with_consumed_artifact{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()
    
    %{ stop_prank_callable = start_prank(caller_address=ids.CALLER_ADDRESS, target_contract_address=ids.deployed_contracts.proposals_address)%}

    %{ expect_revert(error_message="The artifact is consumed") %}
    IProposals.proposeFromFreeProposal(contract_address=deployed_contracts.proposals_address, room=R.ROOM_2, value=0x123, tokenId=Uint256(TD.FP_T1, 0))

    %{ stop_prank_callable() %}
    return ()
end

# todo: should not be able to mint if the token isn't a fp artifact