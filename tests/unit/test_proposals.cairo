%lang starknet
from contracts.proposals import proposals, propose
from starkware.cairo.common.cairo_builtins import HashBuiltin
from tests.constants import (
    CALLER_ADDRESS
)

@external
func test_should_be_able_to_propose{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    %{ stop_prank_callable = start_prank(ids.CALLER_ADDRESS) %}
    let (result_before) = proposals.read(account=CALLER_ADDRESS)
    assert result_before = 0

    propose(3, 42)

    %{ expect_events({"name": "Proposal", "data": [ids.CALLER_ADDRESS, 3, 42]}) %}
    let (result_after) = proposals.read(account=CALLER_ADDRESS)
    assert result_after = 1

    %{ stop_prank_callable() %}
    return ()
end
