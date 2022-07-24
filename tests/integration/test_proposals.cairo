%lang starknet
from contracts.interfaces.IProposals import IProposals
from starkware.cairo.common.cairo_builtins import HashBuiltin
from tests.constants import (
    CALLER_ADDRESS
)
from tests.integration.deployer import (test_integration, DeployedContracts)

@external
func __setup__{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    let (deployed_contracts : DeployedContracts) = test_integration.deploy_contracts()
    let artifact_address = deployed_contracts.artifact_address
    let vrf_address = deployed_contracts.vrf_address
    let proposals_address = deployed_contracts.proposals_address

    %{ context.artifact_address = ids.artifact_address %}
    %{ context.vrf_address = ids.vrf_address %}
    %{ context.proposals_address = ids.proposals_address %}
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

func test_should_be_able_to_