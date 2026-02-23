from pathlib import Path


def test_weapon_stat_system_contains_rarity_and_stat_rules():
    path = Path("lua/autorun/server/rlua_weapon_stat_system.lua")
    assert path.exists()
    content = path.read_text()

    for rarity in ["common", "uncommon", "rare", "epic", "legendary"]:
        assert rarity in content

    for stat_key in [
        "damage",
        "fire_rate",
        "recoil_control",
        "accuracy",
        "reload_speed",
        "magazine_size",
    ]:
        assert stat_key in content


def test_weapon_stat_system_exposes_roll_and_apply_functions():
    content = Path("lua/autorun/server/rlua_weapon_stat_system.lua").read_text()
    assert "function RLuaWeaponStats.RollStats(rarity)" in content
    assert "function RLuaWeaponStats.ApplyRoll(weaponData, rolled)" in content
    assert "function RLuaWeaponStats.BuildSummary(rolled)" in content
    assert "Unknown rarity requested; falling back to common" in content
