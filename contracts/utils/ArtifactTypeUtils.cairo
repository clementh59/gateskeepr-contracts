from contracts.utils.constants import (
    ROOM_1,
    ROOM_2,
    ROOM_3,
    ROOM_4,
    ROOM_5,
    ROOM_6,
    ROOM_7,
    ROOM_8,
    ROOM_9,
    ROOM_10,
    ROOM_11,
    ROOM_12,
    ROOM_ALL,
)

#
# Artifacts codes
#

namespace TYPES:
    # Core Artifacts
    const ORB_OF_OSUVOX = 0
    const CATACLYST = 1
    const EXTRA_PASS = 2
    const HACK_EYE = 3
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
end



#
# Structs
#

# Some artifacts don't have a type because they don't have any properties
# -> Extra Pass (you can make a proposal in every room even though there is an orb activated)
# -> Happy Hour (50% off on your proposals)

# Steal X% of proposal fees for X minutes
struct ChuckyArtifact:
    member room_number : felt
end

# Share the revenue of the room with the protocol
struct RoomArtifact:
    member room_number : felt
    member rarity : felt
end

# block all the proposals of a given room, except for me (and my guild)
struct OrbArtifact:
    member room_number : felt
    # how many time?
    member rarity : felt
end

# destory an orb
struct CataclystArtifact:
    member room_number : felt
end

# You see every X proposals on a given room.
struct HackEyeArtifact:
    member room_number : felt
end

# Everyday, you see a set of proposition from random rooms
struct CopycatArtifact:
    # how many proposition do we see?
    member rarity: felt
    # if true, we know in which room we set a proposition
    member knowRoom: felt
end

# Everyday, you see a set of proposition from random rooms
struct FreeProposalsArtifact:
    # In which room do I have the free proposals?
    member room_number: felt
    # Number of free proposals
    member number: felt
end

# God mode
struct GodModeArtifact:
    # In which room do I have the god mode?
    member room_number: felt
end

#
# utils
#

func buildChuckyFromData(room: felt) -> (chucky: ChuckyArtifact):
    alloc_locals
    local chucky: ChuckyArtifact
    assert chucky.room_number = room
    return (chucky)
end

func buildRoomFromData(param1: felt, param2: felt) -> (room: RoomArtifact):
    alloc_locals
    local room: RoomArtifact
    assert room.room_number = param1
    assert room.rarity = param2
    return (room)
end

func buildOrbOfOsuvoxFromData(param1: felt, param2: felt) -> (orb: OrbArtifact):
    alloc_locals
    local orb: OrbArtifact
    assert orb.room_number = param1
    assert orb.rarity = param2
    return (orb)
end

func buildCataclystFromData(param1: felt) -> (cataclyst: CataclystArtifact):
    alloc_locals
    local cataclyst: CataclystArtifact
    assert cataclyst.room_number = param1
    return (cataclyst)
end

func buildHackEyeFromData(param1: felt) -> (hackEye: HackEyeArtifact):
    alloc_locals
    local hackEye: HackEyeArtifact
    assert hackEye.room_number = param1
    return (hackEye)
end

func buildCopycatFromData(param1: felt, param2: felt) -> (copycat: CopycatArtifact):
    alloc_locals
    local copycat: CopycatArtifact
    assert copycat.rarity = param1
    assert copycat.knowRoom = param2
    return (copycat)
end

func buildFreeProposalsFromData(param1: felt, param2: felt) -> (freeProposals: FreeProposalsArtifact):
    alloc_locals
    local freeProposals: FreeProposalsArtifact
    assert freeProposals.room_number = param1
    assert freeProposals.number = param2
    return (freeProposals)
end

func buildGodModeFromData(param1: felt) -> (godMode: GodModeArtifact):
    alloc_locals
    local godMode: GodModeArtifact
    assert godMode.room_number = param1
    return (godMode)
end