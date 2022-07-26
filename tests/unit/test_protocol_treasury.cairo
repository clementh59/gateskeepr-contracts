%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.interfaces.IProtocolTreasury import IProtocolTreasury
from contracts.interfaces.IERC20 import IERC20
from tests.integration.deployer import (test_integration, DeployedContracts)
from tests.constants import (
    CALLER_ADDRESS,
    ADMIN
)

from starkware.cairo.common.uint256 import Uint256

@external
func __setup__{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals

    local token_address : felt
    local protocol_treasury_address : felt

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

    %{ context.vrf_address = 0x123 %}
    %{ context.token_address = ids.token_address %}
    %{ context.protocol_treasury_address = ids.protocol_treasury_address %}

    # we don't care about proposals address and token here here
    %{ context.proposals_address = 0x123 %}
    %{ context.artifact_address = 0x123 %}
    %{ context.game_treasury_address = 0x123 %}
    return ()
end

@external
func test_deposit_and_withdraw{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (deployed_contracts : DeployedContracts) = test_integration.get_deployed_contracts_from_context()

    %{ stop_prank_callable = start_prank(caller_address=ids.CALLER_ADDRESS, target_contract_address=ids.deployed_contracts.proposals_address)%}

    let amount = Uint256(1111,0)

    IERC20.transfer(contract_address=deployed_contracts.token_address, recipient=deployed_contracts.protocol_treasury_address, amount=amount)

    let (balanceOfContract) = IERC20.balanceOf(deployed_contracts.token_address, deployed_contracts.protocol_treasury_address)
    assert balanceOfContract = amount

    IProtocolTreasury.withdraw(deployed_contracts.protocol_treasury_address)

    let (balanceOfContractAfter) = IERC20.balanceOf(deployed_contracts.token_address, deployed_contracts.protocol_treasury_address)
    let (balanceOfOwner) = IERC20.balanceOf(deployed_contracts.token_address, deployed_contracts.protocol_treasury_address)

    assert balanceOfContractAfter = Uint256(0,0)
    assert balanceOfOwner = amount
    
    %{ stop_prank_callable() %}

    return ()
end