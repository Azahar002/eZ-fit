import json


def test_home_returns_200(client):
    response = client.get("/")
    assert response.status_code == 200


def test_health_returns_200(client):
    response = client.get("/health")
    assert response.status_code == 200


def test_health_returns_json(client):
    response = client.get("/health")
    data = json.loads(response.data)
    assert data == {"status": "healthy"}


def test_login_get_returns_200(client):
    response = client.get("/login")
    assert response.status_code == 200


def test_register_get_returns_200(client):
    response = client.get("/register")
    assert response.status_code == 200


def test_login_post_not_405(client):
    response = client.post("/login")
    assert response.status_code != 405


def test_register_post_not_405(client):
    response = client.post("/register")
    assert response.status_code != 405
