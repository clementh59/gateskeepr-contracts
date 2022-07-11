%lang starknet
from starkware.cairo.common.math import assert_nn
from starkware.cairo.common.cairo_builtins import HashBuiltin
from openzeppelin.token.erc20.library import ERC20
from starkware.starknet.common.syscalls import (
    get_caller_address,
)

#
# Events
#

@event
func Proposal(from_: felt, room: felt, value: felt):
end

#
# Storage
#

# todo: returns all the proposals as a list?
@storage_var
func proposals(account: felt) -> (number : felt):
end

@external
func propose{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        room : felt, value: felt):
    let (caller) = get_caller_address()
    let (current_proposals) = proposals.read(account=caller)
    proposals.write(account=caller, value=current_proposals+1)
    Proposal.emit(caller, room, value)
    return ()
end

@view
func get_proposals{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(account: felt) -> (
        res : felt):
    let (res) = proposals.read(account=account)
    return (res)
end

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    return ()
end
