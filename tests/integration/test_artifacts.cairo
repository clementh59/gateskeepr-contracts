%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from tests.integration.deployer import (test_integration, DeployedContracts)
from tests.constants import (
    CALLER_ADDRESS,
    ADMIN,
    METADATA_HASH_STATE
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

@external
func __setup__{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    let (deployed_contracts : DeployedContracts) = test_integration.deploy_contracts()
    let artifact_address = deployed_contracts.artifact_address

    %{ context.artifact_address = ids.artifact_address %}
    return ()
end

@external
func test_should_set_the_original_hash_correctly{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()

    let (hash) = IArtifacts.metadataHashState(contract_address=deployed_contracts.artifact_address)

    assert hash = METADATA_HASH_STATE
    
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
    let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()

    changeStep(deployed_contracts.artifact_address, 1)
    
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
func test_token_id_should_increment_automatically{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()

    changeStep(deployed_contracts.artifact_address, STEP_PUBLIC_SALE)

    let (next_t: Uint256) = IArtifacts.nextTokenId(contract_address=deployed_contracts.artifact_address)

    IArtifacts.mint(contract_address=deployed_contracts.artifact_address, to=CALLER_ADDRESS, amount=1)

    let (next_t1: Uint256) = IArtifacts.nextTokenId(contract_address=deployed_contracts.artifact_address)
    let (expect_t1: Uint256, _) = uint256_add(next_t, Uint256(1, 0))
    assert next_t1 = expect_t1

    IArtifacts.mint(contract_address=deployed_contracts.artifact_address, to=CALLER_ADDRESS, amount=1)

    let (next_t2: Uint256) = IArtifacts.nextTokenId(contract_address=deployed_contracts.artifact_address)
    let (expect_t2: Uint256, _) = uint256_add(next_t, Uint256(2, 0))
    assert next_t2 = expect_t2
    
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