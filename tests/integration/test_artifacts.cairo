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

@external
func __setup__{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    let (deployed_contracts : DeployedContracts) = test_integration.deploy_contracts()
    let artifact_address = deployed_contracts.artifact_address
    let vrf_address = deployed_contracts.vrf_address

    %{ context.artifact_address = ids.artifact_address %}
    %{ context.vrf_address = ids.vrf_address %}
    return ()
end

@external
func test_should_set_artifacts_type_correctly{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()

    let (t1) = IArtifacts.getArtifactType(
        contract_address=deployed_contracts.artifact_address,
        tokenId = Uint256(1,0)
    )

    let (t2) = IArtifacts.getArtifactType(
        contract_address=deployed_contracts.artifact_address,
        tokenId = Uint256(2,0)
    )

    let (t3) = IArtifacts.getArtifactType(
        contract_address=deployed_contracts.artifact_address,
        tokenId = Uint256(3,0)
    )

    let (t4) = IArtifacts.getArtifactType(
        contract_address=deployed_contracts.artifact_address,
        tokenId = Uint256(4,0)
    )

    let (t5) = IArtifacts.getArtifactType(
        contract_address=deployed_contracts.artifact_address,
        tokenId = Uint256(5,0)
    )

    assert t1 = 1
    assert t2 = 3
    assert t3 = 2
    assert t4 = 4
    assert t5 = 6
    
    return ()
end

@external
func test_admin_and_owner_should_be_equal{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()

    let (owner) = IArtifacts.owner(
        contract_address=deployed_contracts.artifact_address
    )

    assert owner = ADMIN
    
    return ()
end

@external
func test_should_not_be_able_to_change_step_as_a_normal_user{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()

    %{ stop_prank_callable = start_prank(caller_address=ids.CALLER_ADDRESS, target_contract_address=ids.deployed_contracts.artifact_address)%}

    %{ expect_revert("TRANSACTION_FAILED") %}
    IArtifacts.setMintingStep(
        contract_address=deployed_contracts.artifact_address,
        step=1
    )

    %{ stop_prank_callable() %}
    return ()
end

@external
func test_should_be_able_to_change_step{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()

    changeStep(deployed_contracts.artifact_address, 1)

    let (step) = IArtifacts.mintingStep(deployed_contracts.artifact_address)

    assert step = 1
    
    return ()
end

@external
func test_should_not_be_able_to_mint_in_stage_BEFORE_as_a_normal_user{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()

    changeStep(deployed_contracts.artifact_address, STEP_BEFORE)

    %{ expect_revert("TRANSACTION_FAILED") %}
    IArtifacts.mint(
        contract_address=deployed_contracts.artifact_address,
        to=CALLER_ADDRESS,
        amount=1
    )
    
    return ()
end

@external
func test_should_not_be_able_to_mint_in_stage_WHITELIST_as_a_normal_user{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()

    changeStep(deployed_contracts.artifact_address, STEP_WHITELIST_SALE)

    %{ expect_revert("TRANSACTION_FAILED") %}
    IArtifacts.mint(
        contract_address=deployed_contracts.artifact_address,
        to=CALLER_ADDRESS,
        amount=1
    )
    
    return ()
end

@external
func test_should_be_able_to_mint_in_stage_BEFORE_as_admin{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()

    changeStep(deployed_contracts.artifact_address, STEP_BEFORE)

    %{ stop_prank_callable = start_prank(caller_address=ids.ADMIN, target_contract_address=ids.deployed_contracts.artifact_address)%}

    IArtifacts.mint(
        contract_address=deployed_contracts.artifact_address,
        to=CALLER_ADDRESS, 
        amount=1
    )

    %{ stop_prank_callable() %}
    
    return ()
end

@external
func test_should_be_able_to_mint_in_stage_PUBLIC_as_admin_or_normal_user{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()

    changeStep(deployed_contracts.artifact_address, STEP_PUBLIC_SALE)

    IArtifacts.mint(
        contract_address=deployed_contracts.artifact_address,
        to=CALLER_ADDRESS,
        amount=1
    )

    let (user_balance) = IArtifacts.balanceOf(
        contract_address=deployed_contracts.artifact_address,
        owner=CALLER_ADDRESS,
    )

    with_attr error_message("Token 1 hasn't been minted correctly"):
        # Verifying that token 1 belongs to caller
        assert user_balance = Uint256(1,0)
    end
    
    return ()
end

@external
func test_should_be_able_to_mint_multiple_tokens_in_multiple_row{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()

    changeStep(deployed_contracts.artifact_address, STEP_PUBLIC_SALE)

    IArtifacts.mint(contract_address=deployed_contracts.artifact_address, to=0x19283928374011918, amount=1)
    IArtifacts.mint(contract_address=deployed_contracts.artifact_address, to=0x19283928374011918, amount=1)
    IArtifacts.mint(contract_address=deployed_contracts.artifact_address, to=0x19283928374011918, amount=1)

    let (user_balance) = IArtifacts.balanceOf(contract_address=deployed_contracts.artifact_address, owner=0x19283928374011918)

    with_attr error_message("Couldn't mint 3 tokens"):
        assert user_balance = Uint256(3,0)
    end
    
    return ()
end

@external
func test_should_be_able_to_mint_multiple_tokens_in_one_row{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()

    changeStep(deployed_contracts.artifact_address, STEP_PUBLIC_SALE)

    IArtifacts.mint(contract_address=deployed_contracts.artifact_address, to=0x19230918374011918, amount=MAX_MINT_PER_ROW)

    let (user_balance) = IArtifacts.balanceOf(contract_address=deployed_contracts.artifact_address, owner=0x19230918374011918)

    with_attr error_message("Couldn't mint MAX_MINT_PER_ROW tokens"):
        assert user_balance = Uint256(MAX_MINT_PER_ROW,0)
    end
    
    return ()
end

@external
func test_should_not_be_able_to_provide_a_negative_number_when_minting{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()

    changeStep(deployed_contracts.artifact_address, STEP_PUBLIC_SALE)

    %{ expect_revert(error_message="amount should be between 1 and MAX_MINT_PER_ROW") %}
    IArtifacts.mint(contract_address=deployed_contracts.artifact_address, to=CALLER_ADDRESS, amount=-1)
    
    return ()
end

@external
func test_should_not_be_able_to_provide_0_as_amount_when_minting{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()

    changeStep(deployed_contracts.artifact_address, STEP_PUBLIC_SALE)

    %{ expect_revert(error_message="amount should be between 1 and MAX_MINT_PER_ROW") %}
    IArtifacts.mint(contract_address=deployed_contracts.artifact_address, to=CALLER_ADDRESS, amount=0)
    
    return ()
end

@external
func test_should_not_be_able_to_provide_more_than_MAX_MINT_PER_ROW_as_amount_when_minting{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()

    changeStep(deployed_contracts.artifact_address, STEP_PUBLIC_SALE)

    %{ expect_revert(error_message="amount should be between 1 and MAX_MINT_PER_ROW") %}
    IArtifacts.mint(contract_address=deployed_contracts.artifact_address, to=CALLER_ADDRESS, amount=MAX_MINT_PER_ROW+1)
    
    return ()
end

#
# Test utils
#

func changeStep{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}(artifact_address : felt, step: felt):
    %{ stop_prank_callable = start_prank(caller_address=ids.ADMIN, target_contract_address=ids.artifact_address)%}

    IArtifacts.setMintingStep(
        contract_address=artifact_address,
        step=step
    )

    %{ stop_prank_callable() %}
    return ()
end