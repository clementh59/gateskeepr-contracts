%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from tests.integration.deployer import (test_integration, DeployedContracts)
from tests.constants import (
    CALLER_ADDRESS
)
from contracts.interfaces.IArtifacts import IArtifacts
from starkware.cairo.common.uint256 import Uint256

func test_should_be_able_to_mint{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    let (deployed_contracts : DeployedContracts) = test_integration.deploy_contracts()

    IArtifacts.mint(
        contract_address=deployed_contracts.artifact_address,
        to=CALLER_ADDRESS,
        tokenId=Uint256(1,0)
    )

    let (user_balance) = IArtifacts.balanceOf(
        contract_address=deployed_contracts.artifact_address,
        owner=CALLER_ADDRESS,
    )

    with_attr error_message("Token 1 hasn't been minted correctly"):
        # Verifying that token 1 belongs to evaluator
        assert user_balance = Uint256(1,0)
    end
    
    return ()
end

func test_should_be_able_to_mint_multiple_tokens{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    let (deployed_contracts : DeployedContracts) = test_integration.deploy_contracts()

    IArtifacts.mint(
        contract_address=deployed_contracts.artifact_address,
        to=CALLER_ADDRESS,
        tokenId=Uint256(1,0)
    )

    let (user_balance) = IArtifacts.balanceOf(
        contract_address=deployed_contracts.artifact_address,
        owner=CALLER_ADDRESS,
    )

    with_attr error_message("Token 1 hasn't been minted correctly"):
        # Verifying that token 1 belongs to evaluator
        assert user_balance = Uint256(1,0)
    end

    let (user_balance) = IArtifacts.balanceOf(
        contract_address=deployed_contracts.artifact_address,
        owner=CALLER_ADDRESS,
    )

    with_attr error_message("Token 2 hasn't been minted correctly"):
        # Verifying that token 1 belongs to evaluator
        assert user_balance = Uint256(2,0)
    end

    let (user_balance) = IArtifacts.balanceOf(
        contract_address=deployed_contracts.artifact_address,
        owner=CALLER_ADDRESS,
    )

    with_attr error_message("Token 3 hasn't been minted correctly"):
        # Verifying that token 1 belongs to evaluator
        assert user_balance = Uint256(3,0)
    end
    
    return ()
end