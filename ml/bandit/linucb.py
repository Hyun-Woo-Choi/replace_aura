"""Disjoint LinUCB, used for offline simulation and off-policy evaluation."""

from __future__ import annotations

import numpy as np

ACTIONS = ["breathing1Min", "breathing3Min", "shortWalk", "drinkWater", "noNotification"]


class LinUCB:
    def __init__(self, n_features: int, actions: list[str] = ACTIONS, alpha: float = 1.0):
        self.actions = actions
        self.alpha = alpha
        self.A = {a: np.eye(n_features) for a in actions}
        self.b = {a: np.zeros(n_features) for a in actions}

    def scores(self, x: np.ndarray) -> dict[str, float]:
        out = {}
        for a in self.actions:
            a_inv = np.linalg.inv(self.A[a])
            theta = a_inv @ self.b[a]
            out[a] = float(theta @ x + self.alpha * np.sqrt(x @ a_inv @ x))
        return out

    def select(self, x: np.ndarray) -> str:
        s = self.scores(x)
        return max(s, key=s.get)

    def update(self, action: str, x: np.ndarray, reward: float) -> None:
        self.A[action] += np.outer(x, x)
        self.b[action] += reward * x
