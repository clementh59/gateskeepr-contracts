from tests.constants import (
    TD,
    ADMIN,
    ARTIFACTS_NAME,
    ARTIFACTS_SYMBOL,
    CALLER_ADDRESS
)
from starkware.cairo.common.cairo_builtins import HashBuiltin

from contracts.utils.constants import (
    MAX_SUPPLY
)

struct DeployedContracts:
    member artifact_address : felt
    member proposals_address : felt
    member vrf_address : felt
    member token_address: felt
    member season_treasury_address: felt
    member protocol_treasury_address: felt
end

namespace test_integration:
    func deploy_contracts{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(maxSupply: felt) -> (
        deployed_contracts : DeployedContracts
    ):
        alloc_locals

        local artifact_address : felt
        local vrf_address : felt
        local proposals_address : felt
        local token_address : felt
        local protocol_treasury_address: felt
        local season_treasury_address: felt

        %{
            ids.token_address = deploy_contract(
            "./contracts/ERC20.cairo",
            [0x1, 0x1, 0x1, 1000000000, 0, ids.CALLER_ADDRESS]).contract_address
        %}

        %{
            ids.protocol_treasury_address = deploy_contract(
            "./contracts/treasuries/ProtocolTreasury.cairo",
            # owner, erc20
            [ids.ADMIN, ids.token_address]).contract_address
        %}

        %{
            ids.season_treasury_address = deploy_contract(
            # todo
            "./contracts/treasuries/ProtocolTreasury.cairo",
            # owner
            [ids.ADMIN]).contract_address
        %}

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
            [ids.ARTIFACTS_NAME, ids.ARTIFACTS_SYMBOL, ids.ADMIN, ids.vrf_address, ids.maxSupply, ids.token_address,
            # baseUri_len: felt, baseUri: felt*, 
            ids.TD.BASE_URI_LEN, ids.TD.BASE_URI_1,
            # uriSuffix: felt,
            ids.TD.TOKEN_URI_SUFFIX,
            #types_len
            ids.TD.NUM_METADATA_DEF,
            #types
            ids.TD.T1_TYPE, ids.TD.T2_TYPE, ids.TD.T3_TYPE, ids.TD.T4_TYPE, ids.TD.T5_TYPE, ids.TD.T6_TYPE, ids.TD.T7_TYPE, ids.TD.T8_TYPE, ids.TD.T9_TYPE, ids.TD.T10_TYPE, ids.TD.T11_TYPE, ids.TD.T12_TYPE, ids.TD.T13_TYPE, ids.TD.T14_TYPE, ids.TD.T15_TYPE, ids.TD.T16_TYPE, ids.TD.T17_TYPE,
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

        %{
            ids.proposals_address = deploy_contract("./contracts/Proposals.cairo", [ ids.artifact_address, ids.token_address, ids.protocol_treasury_address, ids.game_treasury_address ] ).contract_address
        %}

        # Replace mocks with deployed contract addresses here
        let deployed_contracts = DeployedContracts(
            artifact_address=artifact_address,
            proposals_address=proposals_address,
            vrf_address=vrf_address,
            token_address=token_address,
            season_treasury_address=season_treasury_address,
            protocol_treasury_address=protocol_treasury_address
        )
        return (deployed_contracts)
    end

    func get_deployed_contracts_from_context() -> (deployed_contracts : DeployedContracts):
        tempvar artifact_address
        tempvar vrf_address
        tempvar token_address
        tempvar proposals_address
        tempvar protocol_treasury_address
        tempvar season_treasury_address
        %{ ids.artifact_address = context.artifact_address %}
        %{ ids.vrf_address = context.vrf_address %}
        %{ ids.proposals_address = context.proposals_address %}
        %{ ids.token_address = context.token_address %}
        %{ ids.season_treasury_address = context.season_treasury_address %}
        %{ ids.protocol_treasury_address = context.protocol_treasury_address %}

        let deployed_contracts = DeployedContracts(
            artifact_address=artifact_address,
            proposals_address=proposals_address,
            vrf_address=vrf_address,
            token_address=token_address,
            season_treasury_address=season_treasury_address,
            protocol_treasury_address=protocol_treasury_address
        )
        return (deployed_contracts)
    end
end