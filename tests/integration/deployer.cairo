from tests.constants import (
    TD,
    ADMIN,
    ARTIFACTS_NAME,
    ARTIFACTS_SYMBOL,
)
from starkware.cairo.common.cairo_builtins import HashBuiltin

from contracts.utils.constants import (
    MAX_SUPPLY
)


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
            # name, symbol, owner, vrfAddress
            [ids.ARTIFACTS_NAME, ids.ARTIFACTS_SYMBOL, ids.ADMIN, ids.vrf_address, ids.MAX_SUPPLY,
            #types_len
            ids.TD.NUM_METADATA_DEF,
            #types
            ids.TD.T1_TYPE, ids.TD.T2_TYPE, ids.TD.T3_TYPE, ids.TD.T4_TYPE, ids.TD.T5_TYPE,
            # chuckyInfo_len
            ids.TD.NUMBER_OF_CHUCKY * 2,
            # chuckyInfo
            ids.TD.CHUCKY_T1, ids.TD.CHUCKY_T1_ROOM, ids.TD.CHUCKY_T2, ids.TD.CHUCKY_T2_ROOM,
            # roomArtifactData_len
            ids.TD.NUMBER_OF_ROOM_ARTIFACT * 3,
            # roomArtifactData
            ids.TD.ROOM_ARTIFACT_T1, ids.TD.ROOM_T1_ROOM, ids.TD.ROOM_T1_RARITY, ids.TD.ROOM_ARTIFACT_T2, ids.TD.ROOM_T2_ROOM, ids.TD.ROOM_T2_RARITY, 
            # orbData_len
            ids.TD.NUMBER_OF_ORB_ARTIFACT * 3,
            # orbData
            ids.TD.ORB_T1, ids.TD.ORB_T1_ROOM, ids.TD.ORB_T1_RARITY, ids.TD.ORB_T2, ids.TD.ORB_T2_ROOM, ids.TD.ORB_T2_RARITY,
            # cataclyst
            ids.TD.NUMBER_OF_CATACLYST_ARTIFACT * 2,
            ids.TD.CATACLYST_T1, ids.TD.CATACLYST_T1_ROOM,
            # hack eye
            ids.TD.NUMBER_OF_HACK_EYE_ARTIFACT * 2,
            ids.TD.HACK_EYE_T1, ids.TD.HACK_EYE_T1_ROOM,
            # copycat
            ids.TD.NUMBER_OF_COPYCAT_ARTIFACT * 3,
            ids.TD.COPYCAT_T1, ids.TD.COPYCAT_T1_RARITY, ids.TD.COPYCAT_T1_KNOWN_ROOM, ids.TD.COPYCAT_T2, ids.TD.COPYCAT_T2_RARITY, ids.TD.COPYCAT_T2_KNOWN_ROOM,
            # fp
            ids.TD.NUMBER_OF_FP_ARTIFACT * 3,
            ids.TD.FP_T1, ids.TD.FP_T1_ROOM, ids.TD.FP_T1_NUMBER, ids.TD.FP_T2, ids.TD.FP_T2_ROOM, ids.TD.FP_T2_NUMBER,
            # god mode
            ids.TD.NUMBER_OF_GODMODE_ARTIFACT * 2,
            ids.TD.GODMODE_T1, ids.TD.GODMODE_T1_ROOM, ids.TD.GODMODE_T2, ids.TD.GODMODE_T2_ROOM,
            ]).contract_address
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