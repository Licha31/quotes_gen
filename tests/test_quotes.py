from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_new_quote_page_renders() -> None:
    response = client.get("/quotes/new")

    assert response.status_code == 200
    assert "Adrytentaciones" in response.text
    assert "Nuevo presupuesto" in response.text
    assert '<form class="quote-workspace"' in response.text
