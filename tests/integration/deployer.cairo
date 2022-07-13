from tests.constants import (
    ADMIN,
    ARTIFACTS_NAME,
    ARTIFACTS_SYMBOL,
    METADATA_HASH_STATE
)
from starkware.cairo.common.cairo_builtins import HashBuiltin


struct DeployedContracts:
    member artifact_address : felt
    member proposals_address : felt
end

namespace test_integration:
    func deploy_contracts{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        deployed_contracts : DeployedContracts
    ):
        alloc_locals

        local artifact_address : felt
        #local proposals_address : felt

        %{
            ids.artifact_address = deploy_contract(
            "./contracts/Artifacts.cairo",
            # name, symbol, owner
            [ids.ARTIFACTS_NAME, ids.ARTIFACTS_SYMBOL, ids.ADMIN, ids.METADATA_HASH_STATE]).contract_address
        %}

        # Replace mocks with deployed contract addresses here
        let deployed_contracts = DeployedContracts(
            artifact_address=artifact_address,
            proposals_address=0x123
        )
        return (deployed_contracts)
    end

    func get_deployed_contracts_from_context() -> (deployed_contracts : DeployedContracts):
        tempvar artifact_address
        %{ ids.artifact_address = context.artifact_address %}

        let deployed_contracts = DeployedContracts(
            artifact_address=artifact_address,
            proposals_address=0x123
        )
        return (deployed_contracts)
    end
end