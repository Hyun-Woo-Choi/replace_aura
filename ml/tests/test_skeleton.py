import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from bandit.linucb import LinUCB  # noqa: E402
from features.baseline import stress_index  # noqa: E402


def test_stress_index_is_50_at_baseline():
    assert stress_index(0.0, 0.0, 0.0) == 50.0


def test_low_hrv_raises_stress():
    assert stress_index(-2.0, 0.0) > 50.0


def test_linucb_learns_best_arm():
    rng = np.random.default_rng(0)
    bandit = LinUCB(n_features=2, alpha=0.1)
    for _ in range(300):
        x = np.array([1.0, rng.random()])
        a = bandit.select(x)
        bandit.update(a, x, 1.0 if a == "shortWalk" else 0.0)
    assert bandit.select(np.array([1.0, 0.5])) == "shortWalk"
