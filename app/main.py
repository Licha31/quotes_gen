from pathlib import Path

from fastapi import FastAPI, Request
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

APP_DIR = Path(__file__).resolve().parent

app = FastAPI(title="Presupuestador Adrytentaciones")
app.mount("/static", StaticFiles(directory=APP_DIR / "static"), name="static")

templates = Jinja2Templates(directory=APP_DIR / "templates")


@app.get("/quotes/new", name="new_quote")
def new_quote(request: Request):
    return templates.TemplateResponse(
        request=request,
        name="quotes/new.html",
        context={},
    )
