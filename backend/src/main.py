"""Elastic Local Compute main file."""

from fastapi import FastAPI

app = FastAPI()


@app.get("/")
async def root() -> dict[str, str]:
    """Docstring for root."""
    return {"message": "Hello World"}
