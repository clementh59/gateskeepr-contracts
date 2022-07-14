%lang starknet
from contracts.proposals import proposals, propose
from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.utils.ArtifactTypes import (
    RoomArtifact,
    attributeArtifactTypeFromVRF,
    ORB_OF_OSUVOX,
    CATACLYST,
    EXTRA_PASS
)

@external
func test_should_return_valid_types{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    
    let (type1) = attributeArtifactTypeFromVRF(204990192)
    
    %{print(ids.type1)%}
    assert type1 = ORB_OF_OSUVOX

    let (type2) = attributeArtifactTypeFromVRF(204990193)
    
    %{print(ids.type2)%}
    assert type2 = CATACLYST

    let (type3) = attributeArtifactTypeFromVRF(204990194)
    
    %{print(ids.type3)%}
    assert type3 = EXTRA_PASS

    let (type4) = attributeArtifactTypeFromVRF(204990195)
    
    %{print(ids.type4)%}
    assert type4 = ORB_OF_OSUVOX
    
    return ()
end