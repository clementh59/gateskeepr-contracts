%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from tests.integration.deployer import (test_integration, DeployedContracts)
from tests.constants import (
    CALLER_ADDRESS,
    ADMIN
)
from contracts.utils.constants import (
    STEP_BEFORE,
    STEP_WHITELIST_SALE,
    STEP_PUBLIC_SALE,
    STEP_SOLD_OUT,
    MAX_MINT_PER_ROW,
)
from contracts.interfaces.IArtifacts import IArtifacts
from starkware.cairo.common.uint256 import (
    Uint256, 
    uint256_add
)
from contracts.interfaces.IVRF import IVRF

#@external
func test_should_set_artifacts_type_correctly{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
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
        # name, symbol, owner, vrfAddress, maxSupply
        [1, 1, ids.ADMIN, ids.vrf_address, 60,
        #types_len
        60,
        #types
        60,59,58,57,56,55,54,53,52,51,50,49,48,47,46,45,44,43,42,41,40,39,38,37,36,35,34,33,32,31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
        ]).contract_address
    %}

   %{ stop_prank_callable = start_prank(caller_address=ids.ADMIN, target_contract_address=ids.artifact_address)%}

    mint(60, artifact_address)

    let (availableTokens) = IArtifacts.numAvailableTokens(contract_address=artifact_address)

    assert availableTokens = 0

    %{ stop_prank_callable() %}

    return ()

end

func mint{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}(amount: felt, artifact_address: felt):
    alloc_locals
    if amount == 0:
        return ()
    end

    let (availableTokens) = IArtifacts.numAvailableTokens(contract_address=artifact_address)

    assert availableTokens = amount

    IArtifacts.mint(contract_address=artifact_address, to=ADMIN, amount=1)
    checkWhichTokenHasBeenMinted(artifact_address)
    mint(amount - 1, artifact_address)
    return ()
end

func checkWhichTokenHasBeenMinted{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}(artifact_address: felt):
    let (t1) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(1,0))
    let (t2) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(2,0))
    let (t3) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(3,0))
    let (t4) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(4,0))
    let (t5) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(5,0))
    let (t6) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(6,0))
    let (t7) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(7,0))
    let (t8) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(8,0))
    let (t9) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(9,0))
    let (t10) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(10,0))
    let (t11) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(11,0))
    let (t12) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(12,0))
    let (t13) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(13,0))
    let (t14) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(14,0))
    let (t15) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(15,0))
    let (t16) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(16,0))
    let (t17) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(17,0))
    let (t18) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(18,0))
    let (t19) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(19,0))
    let (t20) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(20,0))
    let (t21) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(21,0))
    let (t22) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(22,0))
    let (t23) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(23,0))
    let (t24) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(24,0))
    let (t25) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(25,0))
    let (t26) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(26,0))
    let (t27) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(27,0))
    let (t28) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(28,0))
    let (t29) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(29,0))
    let (t30) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(30,0))
    let (t31) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(31,0))
    let (t32) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(32,0))
    let (t33) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(33,0))
    let (t34) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(34,0))
    let (t35) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(35,0))
    let (t36) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(36,0))
    let (t37) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(37,0))
    let (t38) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(38,0))
    let (t39) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(39,0))
    let (t40) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(40,0))
    let (t41) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(41,0))
    let (t42) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(42,0))
    let (t43) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(43,0))
    let (t44) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(44,0))
    let (t45) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(45,0))
    let (t46) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(46,0))
    let (t47) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(47,0))
    let (t48) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(48,0))
    let (t49) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(49,0))
    let (t50) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(50,0))
    let (t51) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(51,0))
    let (t52) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(52,0))
    let (t53) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(53,0))
    let (t54) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(54,0))
    let (t55) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(55,0))
    let (t56) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(56,0))
    let (t57) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(57,0))
    let (t58) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(58,0))
    let (t59) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(59,0))
    let (t60) = IArtifacts.ownerOf(contract_address=artifact_address, tokenId = Uint256(60,0))
    %{
        str_mi = "MINTED: "
        str_av = "AVAILABLE: "
        
        if ids.t1 == ids.ADMIN:
            str_mi += "1, "
        else:
            str_av += "1, "
        if ids.t2 == ids.ADMIN:
            str_mi += "2, "
        else:
            str_av += "2, "
        if ids.t3 == ids.ADMIN:
            str_mi += "3, "
        else:
            str_av += "3, "
        if ids.t4 == ids.ADMIN:
            str_mi += "4, "
        else:
            str_av += "4, "
        if ids.t5 == ids.ADMIN:
            str_mi += "5, "
        else:
            str_av += "5, "
        if ids.t6 == ids.ADMIN:
            str_mi += "6, "
        else:
            str_av += "6, "
        if ids.t7 == ids.ADMIN:
            str_mi += "7, "
        else:
            str_av += "7, "
        if ids.t8 == ids.ADMIN:
            str_mi += "8, "
        else:
            str_av += "8, "
        if ids.t9 == ids.ADMIN:
            str_mi += "9, "
        else:
            str_av += "9, "
        if ids.t10 == ids.ADMIN:
            str_mi += "10, "
        else:
            str_av += "10, "
        if ids.t11 == ids.ADMIN:
            str_mi += "11, "
        else:
            str_av += "11, "
        if ids.t12 == ids.ADMIN:
            str_mi += "12, "
        else:
            str_av += "12, "
        if ids.t13 == ids.ADMIN:
            str_mi += "13, "
        else:
            str_av += "13, "
        if ids.t14 == ids.ADMIN:
            str_mi += "14, "
        else:
            str_av += "14, "
        if ids.t15 == ids.ADMIN:
            str_mi += "15, "
        else:
            str_av += "15, "
        if ids.t16 == ids.ADMIN:
            str_mi += "16, "
        else:
            str_av += "16, "
        if ids.t17 == ids.ADMIN:
            str_mi += "17, "
        else:
            str_av += "17, "
        if ids.t18 == ids.ADMIN:
            str_mi += "18, "
        else:
            str_av += "18, "
        if ids.t19 == ids.ADMIN:
            str_mi += "19, "
        else:
            str_av += "19, "
        if ids.t20 == ids.ADMIN:
            str_mi += "20, "
        else:
            str_av += "20, "
        if ids.t21 == ids.ADMIN:
            str_mi += "21, "
        else:
            str_av += "21, "
        if ids.t22 == ids.ADMIN:
            str_mi += "22, "
        else:
            str_av += "22, "
        if ids.t23 == ids.ADMIN:
            str_mi += "23, "
        else:
            str_av += "23, "
        if ids.t24 == ids.ADMIN:
            str_mi += "24, "
        else:
            str_av += "24, "
        if ids.t25 == ids.ADMIN:
            str_mi += "25, "
        else:
            str_av += "25, "
        if ids.t26 == ids.ADMIN:
            str_mi += "26, "
        else:
            str_av += "26, "
        if ids.t27 == ids.ADMIN:
            str_mi += "27, "
        else:
            str_av += "27, "
        if ids.t28 == ids.ADMIN:
            str_mi += "28, "
        else:
            str_av += "28, "
        if ids.t29 == ids.ADMIN:
            str_mi += "29, "
        else:
            str_av += "29, "
        if ids.t30 == ids.ADMIN:
            str_mi += "30, "
        else:
            str_av += "30, "
        if ids.t31 == ids.ADMIN:
            str_mi += "31, "
        else:
            str_av += "31, "
        if ids.t32 == ids.ADMIN:
            str_mi += "32, "
        else:
            str_av += "32, "
        if ids.t33 == ids.ADMIN:
            str_mi += "33, "
        else:
            str_av += "33, "
        if ids.t34 == ids.ADMIN:
            str_mi += "34, "
        else:
            str_av += "34, "
        if ids.t35 == ids.ADMIN:
            str_mi += "35, "
        else:
            str_av += "35, "
        if ids.t36 == ids.ADMIN:
            str_mi += "36, "
        else:
            str_av += "36, "
        if ids.t37 == ids.ADMIN:
            str_mi += "37, "
        else:
            str_av += "37, "
        if ids.t38 == ids.ADMIN:
            str_mi += "38, "
        else:
            str_av += "38, "
        if ids.t39 == ids.ADMIN:
            str_mi += "39, "
        else:
            str_av += "39, "
        if ids.t40 == ids.ADMIN:
            str_mi += "40, "
        else:
            str_av += "40, "
        if ids.t41 == ids.ADMIN:
            str_mi += "41, "
        else:
            str_av += "41, "
        if ids.t42 == ids.ADMIN:
            str_mi += "42, "
        else:
            str_av += "42, "
        if ids.t43 == ids.ADMIN:
            str_mi += "43, "
        else:
            str_av += "43, "
        if ids.t44 == ids.ADMIN:
            str_mi += "44, "
        else:
            str_av += "44, "
        if ids.t45 == ids.ADMIN:
            str_mi += "45, "
        else:
            str_av += "45, "
        if ids.t46 == ids.ADMIN:
            str_mi += "46, "
        else:
            str_av += "46, "
        if ids.t47 == ids.ADMIN:
            str_mi += "47, "
        else:
            str_av += "47, "
        if ids.t48 == ids.ADMIN:
            str_mi += "48, "
        else:
            str_av += "48, "
        if ids.t49 == ids.ADMIN:
            str_mi += "49, "
        else:
            str_av += "49, "
        if ids.t50 == ids.ADMIN:
            str_mi += "50, "
        else:
            str_av += "50, "
        if ids.t51 == ids.ADMIN:
            str_mi += "51, "
        else:
            str_av += "51, "
        if ids.t52 == ids.ADMIN:
            str_mi += "52, "
        else:
            str_av += "52, "
        if ids.t53 == ids.ADMIN:
            str_mi += "53, "
        else:
            str_av += "53, "
        if ids.t54 == ids.ADMIN:
            str_mi += "54, "
        else:
            str_av += "54, "
        if ids.t55 == ids.ADMIN:
            str_mi += "55, "
        else:
            str_av += "55, "
        if ids.t56 == ids.ADMIN:
            str_mi += "56, "
        else:
            str_av += "56, "
        if ids.t57 == ids.ADMIN:
            str_mi += "57, "
        else:
            str_av += "57, "
        if ids.t58 == ids.ADMIN:
            str_mi += "58, "
        else:
            str_av += "58, "
        if ids.t59 == ids.ADMIN:
            str_mi += "59, "
        else:
            str_av += "59, "
        if ids.t60 == ids.ADMIN:
            str_mi += "60, "
        else:
            str_av += "60, "

        print(str_av)
        print(str_mi)
        
    %}
    return ()

end