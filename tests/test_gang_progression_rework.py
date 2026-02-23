import re
from pathlib import Path

SOURCE = Path('lua/bricks_gangs/sh_gang_progression_rework.lua').read_text()


def _extract_number(name: str) -> float:
    match = re.search(rf"{name}\s*=\s*([0-9]+(?:\.[0-9]+)?)", SOURCE)
    assert match, f"missing numeric config for {name}"
    return float(match.group(1))


def test_progression_curve_uses_soft_and_hard_caps():
    soft = _extract_number("SoftCapLevel")
    hard = _extract_number("HardCapLevel")
    assert hard > soft >= 20


def test_progression_curve_not_too_fast_for_long_term_server():
    base = _extract_number("BaseXP")
    linear = _extract_number("LinearXP")
    quad = _extract_number("QuadraticXP")

    def required_xp(level: int) -> float:
        xp = base + (linear * (level - 1)) + (quad * ((level - 1) ** 2))
        if level >= _extract_number("HardCapLevel"):
            xp *= _extract_number("HardCapMultiplier")
        elif level >= _extract_number("SoftCapLevel"):
            xp *= _extract_number("SoftCapMultiplier")
        return xp

    assert required_xp(1) >= 2000
    assert required_xp(35) > required_xp(20) * 1.8
    assert required_xp(60) > required_xp(35) * 1.4


def test_upgrade_catalog_has_variety_and_depth():
    upgrade_keys = re.findall(r"\n\t([a-z_]+)\s*=\s*{\n\t\tname\s*=", SOURCE)
    assert len(upgrade_keys) >= 10

    categories = set(re.findall(r'category\s*=\s*"([a-z]+)"', SOURCE))
    assert {"economy", "defense", "logistics", "warfare", "influence", "identity"}.issubset(categories)


def test_doctrine_system_provides_unique_paths():
    doctrine_ids = re.findall(r'\n\t([a-z_]+)\s*=\s*{\n\t\tname\s*=\s*"[^\"]+",\n\t\tdescription', SOURCE)
    assert {"ledger", "ironwall", "nightfall"}.issubset(set(doctrine_ids))


def test_custom_job_premium_credit_action_provides_store_cta_on_shortfall():
    assert 'PremiumCreditsStoreURL = "https://smgrpdonate.shop/"' in SOURCE
    assert 'function GangProgression.ResolvePremiumCreditsStoreURL()' in SOURCE
    assert 'Prometheus.GetCreditsStoreURL' in SOURCE
    assert 'function GangProgression.GetCustomJobPremiumCreditAction(premiumCredits, customJobCost)' in SOURCE
    assert 'errorCode = "insufficient_premium_credits"' in SOURCE
    assert 'ctaURL = GangProgression.ResolvePremiumCreditsStoreURL()' in SOURCE
