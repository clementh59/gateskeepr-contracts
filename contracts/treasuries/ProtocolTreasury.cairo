%lang starknet
from starkware.cairo.common.math import (
    assert_nn, assert_not_zero
)
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import (
    get_caller_address,
    get_contract_address,
)
from starkware.cairo.common.uint256 import Uint256
from contracts.interfaces.IERC20 import IERC20

#
# Storage
#

@storage_var
func owner_() -> (address : felt):
end

@storage_var
func erc20ContractAddress_() -> (address : felt):
end

#
# Constructor
#

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner: felt, erc20ContractAddress: felt):
    erc20ContractAddress_.write(value=erc20ContractAddress)
    owner_.write(value=owner)
    return ()
end

# withdraw the funds in the contract to the owner address
@external
func withdraw{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (erc20_contract_address) = erc20ContractAddress_.read()
    let (contract_addr) = get_contract_address()
    let (owner) = owner_.read()
    let (balance) = IERC20.balanceOf(erc20_contract_address, contract_addr)
    IERC20.transfer(contract_address=erc20_contract_address, recipient=owner, amount=balance)
    return ()
end