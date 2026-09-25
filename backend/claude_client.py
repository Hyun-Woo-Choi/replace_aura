"""Claude insight generation. Only aggregated metrics are ever sent (README §5)."""

from __future__ import annotations

import json
import os

import anthropic

DEFAULT_MODEL = "claude-opus-5"

SYSTEM_PROMPT = (
    "You write short, friendly wellness summaries for a personal health app. "
    "You receive aggregated stress and sleep metrics relative to the user's own baseline. "
    "Write 2-3 sentences in plain language. This is wellness information, not medical advice: "
    "never diagnose, and suggest seeing a professional only if the user asks about symptoms."
)


class InsightClient:
    def __init__(self, client: anthropic.Anthropic | None = None, model: str | None = None):
        self.client = client or anthropic.Anthropic()
        self.model = model or os.environ.get("CLAUDE_MODEL", DEFAULT_MODEL)

    def summarize(self, metrics: dict) -> str:
        response = self.client.beta.messages.create(
            model=self.model,
            max_tokens=1024,
            system=SYSTEM_PROMPT,
            output_config={"effort": "low"},
            # Re-run a refused request on Anthropic's recommended fallback model.
            betas=["server-side-fallback-2026-07-01"],
            fallbacks="default",
            messages=[{
                "role": "user",
                "content": "Summarize these metrics:\n" + json.dumps(metrics, sort_keys=True),
            }],
        )
        if response.stop_reason == "refusal":
            return ""
        return "".join(block.text for block in response.content if block.type == "text").strip()
