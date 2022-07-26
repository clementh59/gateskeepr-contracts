%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from tests.integration.deployer import (test_integration, DeployedContracts)
from tests.constants import (
    CALLER_ADDRESS,
    ADMIN,
    TD
)
from contracts.utils.constants import (
    STEP_BEFORE,
    STEP_WHITELIST_SALE,
    STEP_PUBLIC_SALE,
    STEP_SOLD_OUT,
    MAX_MINT_PER_ROW,
    R,
)

from contracts.utils.ArtifactTypeUtils import (
    TYPES,
    ChuckyArtifact,
    RoomArtifact,
    OrbArtifact,
    CataclystArtifact,
    HackEyeArtifact,
    CopycatArtifact,
    FreeProposalsArtifact,
    GodModeArtifact
)

from contracts.interfaces.IArtifacts import IArtifacts
from starkware.cairo.common.uint256 import (
    Uint256, 
    uint256_add
)
from contracts.interfaces.IVRF import IVRF

@external
func __setup__{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals

    local artifact_address : felt
    local vrf_address : felt

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
        [1, 1, ids.ADMIN, ids.vrf_address, 7,
        # baseUri_len: felt, baseUri: felt*, 
        5, 18, 19, 20, 21, 22,
        # uriSuffix: felt,
        100,
        #types_len
        7,
        #types
        8,8,8,0,0,0,0,
        # chuckyInfo_len
        6,
        # chuckyInfo
        1,1,2,7,3,13,
        # roomArtifactData_len
        0,
        # orbData_len
        12,
        4, 1, 2, 5, 10, 7, 6, 8, 10, 7, 12, 12,
        # cataclyst
        0,
        # hack eye
        0,
        # copycat
        0,
        # fp
        0,
        # god mode
        0,
        ]).contract_address
    %}

    %{ context.artifact_address = ids.artifact_address %}
    %{ context.vrf_address = ids.vrf_address %}

    # we don't care about proposals address and token here here
    %{ context.proposals_address = 0x123 %}
    %{ context.token_address = 0x123 %}
    %{ context.game_treasury_address = 0x123 %}
    %{ context.protocol_treasury_address = 0x123 %}
    return ()
end

@external
func test_tokenUri{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()

    %{ stop_prank_callable = start_prank(caller_address=ids.ADMIN, target_contract_address=ids.deployed_contracts.artifact_address)%}

    IArtifacts.mint(contract_address=deployed_contracts.artifact_address, to=ADMIN ,amount=7)
    let (len, uri) = IArtifacts.tokenURI(contract_address=deployed_contracts.artifact_address, tokenId = Uint256(1, 0))
    assert len = 7
    assert 18 = uri[0]
    assert 19 = uri[1]
    assert 20 = uri[2]
    assert 21 = uri[3]
    assert 22 = uri[4]
    assert 3694385 = uri[5]
    assert 100 = uri[6]

    let (len, uri) = IArtifacts.tokenURI(contract_address=deployed_contracts.artifact_address, tokenId = Uint256(2, 0))
    assert 3694391 = uri[5]

    let (len, uri) = IArtifacts.tokenURI(contract_address=deployed_contracts.artifact_address, tokenId = Uint256(3, 0))
    assert 945762611 = uri[5]

    let (len, uri) = IArtifacts.tokenURI(contract_address=deployed_contracts.artifact_address, tokenId = Uint256(4, 0))
    assert 207755501362 = uri[5]

    let (len, uri) = IArtifacts.tokenURI(contract_address=deployed_contracts.artifact_address, tokenId = Uint256(5, 0))
    assert 53185405280055 = uri[5]

    let (len, uri) = IArtifacts.tokenURI(contract_address=deployed_contracts.artifact_address, tokenId = Uint256(6, 0))
    assert 53185525788976 = uri[5]

    let (len, uri) = IArtifacts.tokenURI(contract_address=deployed_contracts.artifact_address, tokenId = Uint256(7, 0))
    assert 13615463785247026 = uri[5]

    %{ stop_prank_callable() %}
    return ()
end
