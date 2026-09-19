from datetime import datetime, timezone

from fastapi import FastAPI

app = FastAPI(
    title="Life Saarthi API",
    version="1.0.0",
)


@app.get("/api/time")
def get_server_time():
    return {
        "server_time": datetime.now(timezone.utc).isoformat(),
    }