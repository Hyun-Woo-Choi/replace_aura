"""Personal baseline normalization and rule-based scores (mirrors the Swift metrics engine)."""

from __future__ import annotations

import numpy as np
import pandas as pd

BASELINE_WINDOW_DAYS = 28


def rolling_baseline(series: pd.Series, window_days: int = BASELINE_WINDOW_DAYS) -> pd.DataFrame:
    """Rolling median/std over a time-indexed series, excluding the current sample."""
    shifted = series.shift(1)
    window = f"{window_days}D"
    return pd.DataFrame(
        {
            "median": shifted.rolling(window, min_periods=2).median(),
            "std": shifted.rolling(window, min_periods=2).std(),
        }
    )


def z_score(value: float, median: float, std: float) -> float:
    if not std or np.isnan(std):
        return 0.0
    return (value - median) / std


def stress_index(z_hrv: float, z_rhr: float, z_resp: float = 0.0,
                 w: tuple[float, float, float] = (1.0, 0.7, 0.3)) -> float:
    """README §3.1: 100 * sigmoid(-w1*z_hrv + w2*z_rhr + w3*z_resp)."""
    raw = -w[0] * z_hrv + w[1] * z_rhr + w[2] * z_resp
    return float(100.0 / (1.0 + np.exp(-raw)))
