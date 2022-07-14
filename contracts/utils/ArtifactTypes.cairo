%lang starknet

from starkware.cairo.common.math import (
    unsigned_div_rem
)
#
# Artifacts codes
#

# Core Artifacts
const ORB_OF_OSUVOX = 0
const CATACLYST = 1
const EXTRA_PASS = 2
const HACH_EYE = 3
const COPYCAT = 4
const VIP_PASS = 5
const FREE_PROPOSALS = 6
const GOD_MODE = 7
const CHUCKY = 8
const HAPPY_HOUR = 9
const SPY = 10
const FOG = 11

# Rooms
const ROOM = 99

#
# Structs
#

struct RoomArtifact:
    member room_number : felt
    member rarity : felt
end

# # Returns a struct describing the artifact type
# func getRoomArtifactInfo{range_check_ptr}(metadata: felt) -> (roomArtifact: RoomArtifact):
#     alloc_locals
#     let (type) = getTypeRelatedNumber(metadata)
#     # First, I ensure that the artifact is a room
#     with_attr error_message("The type of the artifact shall be a room"):
#         assert type = ROOM
#     end
#     let (_, room_number_multiplied) = unsigned_div_rem(metadata - type, 10000)
#     let (rarity, _) = unsigned_div_rem(metadata - type - room_number_multiplied, 10000)
    
#     local roomA: RoomArtifact
#     assert roomA.room_number = room_number_multiplied
#     assert roomA.rarity = rarity
#     return (roomA)
# end

func attributeArtifactTypeFromVRF{range_check_ptr}(vrf: felt) -> (type: felt):
    let (_, remainder) = unsigned_div_rem(vrf, 3)
    return (remainder)
end

func attributeArtifactFromVRF{range_check_ptr}(vrf: felt) -> (number: felt):
    let (type) = attributeArtifactTypeFromVRF(vrf)
end