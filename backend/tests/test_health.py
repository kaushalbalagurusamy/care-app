from fastapi.testclient import TestClient
from main import app

client = TestClient(app)


def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert data["app"] == "CARE Backend"


def test_app_metadata():
    assert app.title == "CARE Backend API"
    assert app.version == "0.1.0"
