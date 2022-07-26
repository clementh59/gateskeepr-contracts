%lang starknet
from contracts.interfaces.IProposals import IProposals
from contracts.interfaces.IArtifacts import IArtifacts
from contracts.interfaces.IERC20 import IERC20
from starkware.cairo.common.cairo_builtins import HashBuiltin
from tests.constants import (
    CALLER_ADDRESS,
    CALLER_2_ADDRESS,
    ADMIN,
    TD,
)
from starkware.cairo.common.uint256 import (Uint256, uint256_add)
from contracts.utils.constants import (
    MAX_MINT_PER_ROW,
    R,
    PROPOSAL_PRICE,
)
from tests.integration.deployer import (test_integration, DeployedContracts)

@external
func __setup__{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    let (deployed_contracts : DeployedContracts) = test_integration.deploy_contracts(maxSupply=100)
    let artifact_address = deployed_contracts.artifact_address
    let vrf_address = deployed_contracts.vrf_address
    let proposals_address = deployed_contracts.proposals_address
    let protocol_treasury_address = deployed_contracts.protocol_treasury_address
    let game_treasury_address = deployed_contracts.game_treasury_address

    %{ context.artifact_address = ids.artifact_address %}
    %{ context.vrf_address = ids.vrf_address %}
    %{ context.proposals_address = ids.proposals_address %}
    %{ context.token_address = ids.token_address %}
    %{ context.game_treasury_address = ids.game_treasury_address%}
    %{ context.protocol_treasury_address = ids.protocol_treasury_address%}
    
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

#
# Test - regular propositions
#

@external
func test_should_be_able_to_propose{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()
    
    %{ stop_prank_callable = start_prank(caller_address=ids.CALLER_ADDRESS, target_contract_address=ids.deployed_contracts.token_address)%}

    IERC20.approve(contract_address=deployed_contracts.token_address, spender=deployed_contracts.proposals_address, amount=Uint256(PROPOSAL_PRICE,0))

    %{ stop_prank_callable() %}
    %{ stop_prank_callable = start_prank(caller_address=ids.CALLER_ADDRESS, target_contract_address=ids.deployed_contracts.proposals_address)%}

    IProposals.propose(deployed_contracts.proposals_address, 3, 42)

    %{ expect_events({"name": "Proposal", "data": [ids.CALLER_ADDRESS, 3, 42]}) %}

    # checking the balance of proposal address
    let (contract_balance) = IERC20.balanceOf(deployed_contracts.token_address, deployed_contracts.proposals_address)
    # it should be equal to the price of 1 proposal (i.e 1)
    assert contract_balance = Uint256(PROPOSAL_PRICE,0)

    %{ stop_prank_callable() %}

    return ()
end

# @external
# func test_should_not_be_able_to_propose_if_spender_didnt_approve{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
#     alloc_locals
#     let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()
    
#     %{ stop_prank_callable = start_prank(caller_address=ids.CALLER_2_ADDRESS, target_contract_address=ids.deployed_contracts.proposals_address)%}

#     %{ expect_revert(error_message="ERC20: insufficient allowance") %}
#     IProposals.propose(deployed_contracts.proposals_address, 2, 42)

#     %{ stop_prank_callable() %}

#     return ()
# end

# @external
# func test_should_not_be_able_to_propose_if_spender_doesnt_have_enough_funds{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
#     alloc_locals
#     let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()
    
#     %{ stop_prank_callable = start_prank(caller_address=ids.CALLER_2_ADDRESS, target_contract_address=ids.deployed_contracts.token_address)%}

#     IERC20.approve(contract_address=deployed_contracts.token_address, spender=deployed_contracts.proposals_address, amount=Uint256(1,1))

#     %{ stop_prank_callable() %}
#     %{ stop_prank_callable = start_prank(caller_address=ids.CALLER_2_ADDRESS, target_contract_address=ids.deployed_contracts.proposals_address)%}

#     %{ expect_revert(error_message="ERC20: transfer amount exceeds balance") %}
#     IProposals.propose(deployed_contracts.proposals_address, 2, 42)


#     %{ stop_prank_callable() %}

#     return ()
# end

# #
# # Test - Proposal using Free Proposal artifacts
# #
# @external
# func test_should_be_able_to_propose_for_free_with_valid_artifact_for_this_room{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
#     alloc_locals
#     let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()
    
#     %{ stop_prank_callable = start_prank(caller_address=ids.CALLER_ADDRESS, target_contract_address=ids.deployed_contracts.proposals_address)%}

#     %{
#         value_val = load(ids.deployed_contracts.artifact_address, "freeProposalsArtifact_", "FreeProposalsArtifact", key=[ids.TD.FP_T1,0])
#         assert value_val == [2, 2]
#     %}

#     IProposals.proposeFromFreeProposal(contract_address=deployed_contracts.proposals_address, room=R.ROOM_2, value=0x123, tokenId=Uint256(TD.FP_T1, 0))

#     %{ expect_events({"name": "Proposal", "data": [ids.CALLER_ADDRESS, ids.R.ROOM_2, 0x123]}) %}

#     %{
#         value_val = load(ids.deployed_contracts.artifact_address, "freeProposalsArtifact_", "FreeProposalsArtifact", key=[ids.TD.FP_T1,0])
#         assert value_val == [2, 1]
#     %}

#     %{ stop_prank_callable() %}
#     return ()
# end

# @external
# func test_should_be_able_to_propose_for_free_with_valid_artifact_for_ALL_rooms{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
#     alloc_locals
#     let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()
    
#     %{ stop_prank_callable = start_prank(caller_address=ids.CALLER_ADDRESS, target_contract_address=ids.deployed_contracts.proposals_address)%}

#     IProposals.proposeFromFreeProposal(contract_address=deployed_contracts.proposals_address, room=R.ROOM_4, value=27, tokenId=Uint256(TD.FP_T2, 0))

#     %{ expect_events({"name": "Proposal", "data": [ids.CALLER_ADDRESS, ids.R.ROOM_4, 27]}) %}

#     %{ stop_prank_callable() %}
#     return ()
# end

# @external
# func test_should_not_be_able_to_propose_for_free_with_valid_artifact_without_being_the_owner{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
#     alloc_locals
#     let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()
    
#     %{ stop_prank_callable = start_prank(caller_address=ids.CALLER_2_ADDRESS, target_contract_address=ids.deployed_contracts.proposals_address)%}

#     %{ expect_revert(error_message="Only the owner of the artifact can ask for free proposals") %}
#     IProposals.proposeFromFreeProposal(contract_address=deployed_contracts.proposals_address, room=R.ROOM_2, value=0x123, tokenId=Uint256(TD.FP_T1, 0))

#     %{ stop_prank_callable() %}
#     return ()
# end

# @external
# func test_should_not_be_able_to_propose_for_free_with_artifact_valid_for_another_room{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
#     alloc_locals
#     let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()
    
#     %{ stop_prank_callable = start_prank(caller_address=ids.CALLER_ADDRESS, target_contract_address=ids.deployed_contracts.proposals_address)%}

#     # The artifact allows the owner to make 2 free proposals - those 2 have already been used above

#     %{ expect_revert(error_message="The artifact can't be used in this room") %}
#     IProposals.proposeFromFreeProposal(contract_address=deployed_contracts.proposals_address, room=R.ROOM_3, value=0x123, tokenId=Uint256(TD.FP_T1, 0))

#     %{ stop_prank_callable() %}
#     return ()
# end

# @external
# func test_should_not_be_able_to_propose_for_free_with_consumed_artifact{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
#     alloc_locals
#     let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()

#     %{ stop_prank_callable = start_prank(caller_address=ids.CALLER_ADDRESS, target_contract_address=ids.deployed_contracts.proposals_address)%}

#     # 1. Let's do the last proposal available with T1
#     let (balance) = IArtifacts.balanceOf(contract_address=deployed_contracts.artifact_address, owner=CALLER_ADDRESS)

#     IProposals.proposeFromFreeProposal(contract_address=deployed_contracts.proposals_address, room=R.ROOM_2, value=0x123, tokenId=Uint256(TD.FP_T1, 0))

#     %{
#         value_val = load(ids.deployed_contracts.artifact_address, "freeProposalsArtifact_", "FreeProposalsArtifact", key=[ids.TD.FP_T1,0])
#         assert value_val == [2, 1]
#     %}

#     IProposals.proposeFromFreeProposal(contract_address=deployed_contracts.proposals_address, room=R.ROOM_2, value=0x123, tokenId=Uint256(TD.FP_T1, 0))

#     %{
#         value_val = load(ids.deployed_contracts.artifact_address, "freeProposalsArtifact_", "FreeProposalsArtifact", key=[ids.TD.FP_T1,0])
#         assert value_val == [2, 0]
#     %}

#     # the token should now be burnt
#     let (balance2) = IArtifacts.balanceOf(contract_address=deployed_contracts.artifact_address, owner=CALLER_ADDRESS)
#     let (b2, _) = uint256_add(Uint256(1,0), balance2)
#     assert balance = b2

#     # 2. let's try to use it again
    
#     %{ expect_revert(error_message="ERC721: owner query for nonexistent token") %}
#     IProposals.proposeFromFreeProposal(contract_address=deployed_contracts.proposals_address, room=R.ROOM_2, value=0x123, tokenId=Uint256(TD.FP_T1, 0))

#     %{ stop_prank_callable() %}
#     return ()
# end

# todo: should not be able to mint if the token isn't a fp artifact