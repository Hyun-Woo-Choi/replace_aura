import sys
from pathlib import Path

from fastapi.testclient import TestClient

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.main import app, get_insight_client  # noqa: E402


class FakeInsightClient:
    def summarize(self, metrics: dict) -> str:
        return f"ok {sorted(metrics)}"


app.dependency_overrides[get_insight_client] = FakeInsightClient
client = TestClient(app)


def test_health():
    assert client.get("/health").json() == {"status": "ok"}


def test_insight_requires_consent():
    r = client.post("/insights", json={"period": "daily", "consent": False})
    assert r.status_code == 403


def test_insight_strips_consent_field():
    r = client.post("/insights", json={"period": "daily", "stress_index_avg": 40, "consent": True})
    assert r.status_code == 200
    assert "consent" not in r.json()["summary"]
