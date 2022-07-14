from tests.constants import (
    ADMIN,
    ARTIFACTS_NAME,
    ARTIFACTS_SYMBOL
)
from starkware.cairo.common.cairo_builtins import HashBuiltin


struct DeployedContracts:
    member artifact_address : felt
    member proposals_address : felt
    member vrf_address : felt
end

namespace test_integration:
    func deploy_contracts{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        deployed_contracts : DeployedContracts
    ):
        alloc_locals

        local artifact_address : felt
        local vrf_address : felt
        #local proposals_address : felt

        %{
            ids.vrf_address = deploy_contract(
            "./contracts/vrf/pseudo-random.cairo",
            # seed
            [0x233f9e9aff81a8edf20a0a8d97600f3b2c4]).contract_address
        %}

        %{
            ids.artifact_address = deploy_contract(
            "./contracts/Artifacts.cairo",
            # name, symbol, owner
            [ids.ARTIFACTS_NAME, ids.ARTIFACTS_SYMBOL, ids.ADMIN, ids.vrf_address]).contract_address
        %}

        # Replace mocks with deployed contract addresses here
        let deployed_contracts = DeployedContracts(
            artifact_address=artifact_address,
            proposals_address=0x123,
            vrf_address=vrf_address
        )
        return (deployed_contracts)
    end

    func get_deployed_contracts_from_context() -> (deployed_contracts : DeployedContracts):
        tempvar artifact_address
        tempvar vrf_address
        %{ ids.artifact_address = context.artifact_address %}
        %{ ids.vrf_address = context.vrf_address %}

        let deployed_contracts = DeployedContracts(
            artifact_address=artifact_address,
            proposals_address=0x123,
            vrf_address=vrf_address
        )
        return (deployed_contracts)
    end
end