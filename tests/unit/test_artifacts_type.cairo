%lang starknet
from contracts.utils.ArtifactTypeUtils import (
    buildChuckyFromData,
    buildRoomFromData,
    buildOrbOfOsuvoxFromData,
    buildCataclystFromData,
    buildHackEyeFromData,
    buildCopycatFromData,
    buildFreeProposalsFromData,
    buildGodModeFromData,
    TYPES,
    ChuckyArtifact,
    RoomArtifact,
    OrbArtifact,
    CataclystArtifact,
    HackEyeArtifact,
    CopycatArtifact,
    FreeProposalsArtifact,
    GodModeArtifact,
    buildUriInfoFrom2Params
)
from starkware.cairo.common.cairo_builtins import HashBuiltin

@external
func test_build_chucky_artifact{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    let (chucky: ChuckyArtifact) = buildChuckyFromData(2)
    assert chucky.room_number = 2
    let (chucky: ChuckyArtifact) = buildChuckyFromData(13)
    assert chucky.room_number = 13
    return ()
end

@external
func test_build_room_artifact{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    let (room: RoomArtifact) = buildRoomFromData(2, 1)
    assert room.room_number = 2
    assert room.rarity = 1
    let (room: RoomArtifact) = buildRoomFromData(13, 2)
    assert room.room_number = 13
    assert room.rarity = 2
    return ()
end

@external
func test_build_orb_artifact{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    let (art: OrbArtifact) = buildOrbOfOsuvoxFromData(2, 1)
    assert art.room_number = 2
    assert art.rarity = 1
    let (art: OrbArtifact) = buildOrbOfOsuvoxFromData(11, 4)
    assert art.room_number = 11
    assert art.rarity = 4
    return ()
end

@external
func test_build_cataclyst_from_data_artifact{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    let (art: CataclystArtifact) = buildCataclystFromData(3)
    assert art.room_number = 3
    let (art: CataclystArtifact) = buildCataclystFromData(10)
    assert art.room_number = 10
    return ()
end

@external
func test_build_hack_eye_from_data_artifact{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    let (art: HackEyeArtifact) = buildHackEyeFromData(3)
    assert art.room_number = 3
    let (art: HackEyeArtifact) = buildHackEyeFromData(10)
    assert art.room_number = 10
    return ()
end

@external
func test_build_copycat_from_data_artifact{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    let (art: CopycatArtifact) = buildCopycatFromData(4, 1)
    assert art.rarity = 4
    assert art.knowRoom = 1
    let (art: CopycatArtifact) = buildCopycatFromData(1, 0)
    assert art.rarity = 1
    assert art.knowRoom = 0
    return ()
end

@external
func test_build_free_proposals_from_data_artifact{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    let (art: FreeProposalsArtifact) = buildFreeProposalsFromData(1, 2)
    assert art.room_number = 1
    assert art.number = 2
    let (art: FreeProposalsArtifact) = buildFreeProposalsFromData(4, 40)
    assert art.room_number = 4
    assert art.number = 40
    return ()
end

@external
func test_build_god_mode_from_data_artifact{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    let (art: GodModeArtifact) = buildGodModeFromData(7)
    assert art.room_number = 7
    let (art: GodModeArtifact) = buildGodModeFromData(5)
    assert art.room_number = 5
    return ()
end

@external 
func test_2():
    let (res) = buildUriInfoFrom2Params(48, 1, 2)
    %{print(ids.res)%}
    return ()
end