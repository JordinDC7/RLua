from pathlib import Path


def test_darkrp_groupchats_stub_exists_and_is_nonempty():
    path = Path("lua/darkrp_customthings/groupchats.lua")
    assert path.exists()
    content = path.read_text()
    assert "AddCSLuaFile" in content
    assert "CustomGroupChats" in content


def test_inventory_client_stub_exists():
    path = Path("lua/weapons/inventory/cl_init.lua")
    assert path.exists()
    assert "include(\"shared.lua\")" in path.read_text()


def test_bricks_unboxing_hotfix_targets_nil_button_error():
    path = Path("lua/autorun/client/bricks_unboxing_rewards_hotfix.lua")
    content = path.read_text()
    assert "bricks_server_unboxingmenu_rewards.lua" in content
    assert "field 'button'" in content
    assert "xpcall" in content
    assert "OnGamemodeLoaded" in content
    assert "timer.Create" in content
