from contracts.utils.constants import (
    R,
    STR_UNDERSCORE,
)

namespace STR_NUMBER:
    const _1 = 49
    const _2 = 50
    const _3 = 51
    const _4 = 52
    const _5 = 53
    const _6 = 54
    const _7 = 55
    const _8 = 56
    const _9 = 57
    const _10 = 12592
    const _11 = 12593
    const _12 = 12594
    const _ALL = 12595
end

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

    # Str
    const STR_ORB_OF_OSUVOX = 48
    const STR_CATACLYST = 49
    const STR_EXTRA_PASS = 50
    const STR_HACK_EYE = 51
    const STR_COPYCAT = 52
    const STR_VIP_PASS = 53
    const STR_FREE_PROPOSALS = 54
    const STR_GOD_MODE = 55
    const STR_CHUCKY = 56
    const STR_HAPPY_HOUR = 57
    const STR_SPY = 12592
    const STR_FOG = 12593
    const STR_ROOM = 14649
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

func buildUriInfoFromParam(type_str: felt, param1_felt: felt) -> (uri: felt):
    alloc_locals
    let (num, param) = getStrFromNumber(param1_felt)
    if num == 2:
        tempvar shift = 256
    else:
        tempvar shift = 1
    end
    return (type_str * 256 * 256 * shift + STR_UNDERSCORE * 256 * shift + param)
end

func buildUriInfoFrom2Params(type_str: felt, param1_felt: felt, param2_felt: felt) -> (uri: felt):
    alloc_locals
    let (num1, param1) = getStrFromNumber(param1_felt)
    let (num2, param2) = getStrFromNumber(param2_felt)

    if num1 == 2:
        tempvar shift1 = 256
    else:
        tempvar shift1 = 1
    end
    
    if num2 == 2:
        tempvar shift2 = 256
    else:
        tempvar shift2 = 1
    end

    return (
        type_str * 256 * 256 * 256 * 256 * shift1 * shift2 + 
        STR_UNDERSCORE * 256 * 256 * 256 * shift1 * shift2 + 
        param1 * 256 * 256 * shift2 + 
        STR_UNDERSCORE * 256 * shift2 + 
        param2
    )
end

func getStrFromNumber(num: felt) -> (num_letters: felt, str: felt):
    if num == R.ROOM_1:
        return (1,STR_NUMBER._1)
    end
    if num == R.ROOM_2:
        return (1,STR_NUMBER._2)
    end
    if num == R.ROOM_3:
        return (1,STR_NUMBER._3)
    end
    if num == R.ROOM_4:
        return (1,STR_NUMBER._4)
    end
    if num == R.ROOM_5:
        return (1,STR_NUMBER._5)
    end
    if num == R.ROOM_6:
        return (1,STR_NUMBER._6)
    end
    if num == R.ROOM_7:
        return (1,STR_NUMBER._7)
    end
    if num == R.ROOM_8:
        return (1,STR_NUMBER._8)
    end
    if num == R.ROOM_9:
        return (1,STR_NUMBER._9)
    end
    if num == R.ROOM_10:
        return (2,STR_NUMBER._10)
    end
    if num == R.ROOM_11:
        return (2,STR_NUMBER._11)
    end
    if num == R.ROOM_12:
        return (2,STR_NUMBER._12)
    end
    if num == R.ROOM_ALL:
        return (2,STR_NUMBER._ALL)
    end
    return (1, 0)
end