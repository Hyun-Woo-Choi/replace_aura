"""Optional backend: Claude insights from aggregated metrics."""

from __future__ import annotations

from functools import lru_cache

from dotenv import load_dotenv
from fastapi import Depends, FastAPI, HTTPException
from pydantic import BaseModel, Field

from claude_client import InsightClient

load_dotenv()

app = FastAPI(title="WatchWell backend")


class AggregatedMetrics(BaseModel):
    """Aggregates only; raw HealthKit samples are never accepted."""

    period: str = Field(pattern="^(daily|weekly)$")
    stress_index_avg: float | None = Field(default=None, ge=0, le=100)
    sleep_score_avg: float | None = Field(default=None, ge=0, le=100)
    hrv_vs_baseline_pct: float | None = None
    sleep_hours_vs_goal_pct: float | None = None
    consent: bool = Field(description="User explicitly consented to sending metrics to Claude")


class Insight(BaseModel):
    summary: str


@lru_cache
def get_insight_client() -> InsightClient:
    return InsightClient()


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


@app.post("/insights", response_model=Insight)
def create_insight(metrics: AggregatedMetrics,
                   client: InsightClient = Depends(get_insight_client)) -> Insight:
    if not metrics.consent:
        raise HTTPException(status_code=403, detail="User consent is required")
    payload = metrics.model_dump(exclude={"consent"}, exclude_none=True)
    return Insight(summary=client.summarize(payload))
