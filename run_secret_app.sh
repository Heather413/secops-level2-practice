#!/bin/bash

if [ -z "$1" ]; then
    echo "Ошибка: Не передан API ключ!"
    echo "Использование: $0 <API_TOKEN>"
    exit 1
fi

API_KEY="$1"
CONTAINER_NAME="secret_app_instance"

docker rm -f "$CONTAINER_NAME" 2>/dev/null

echo "[+] Запуск контейнера python:alpine с HTTP-сервером..."
docker run -d --name "$CONTAINER_NAME" -p 8081:8000 -e APP_API_TOKEN="$API_KEY" python:alpine python -c '
import os
from http.server import HTTPServer, BaseHTTPRequestHandler

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        token = os.getenv("APP_API_TOKEN", "Not Set")
        self.send_response(200)
        self.send_header("Content-type", "text/plain; charset=utf-8")
        self.end_headers()
        self.wfile.write(f"APP_API_TOKEN is: {token}\n".encode("utf-8"))

HTTPServer(("", 8000), Handler).serve_forever()
'

echo "[+] Проверка значения переменной внутри контейнера:"
docker exec "$CONTAINER_NAME" printenv APP_API_TOKEN

echo "[+] Проверка через HTTP-запрос:"
curl -s http://localhost:8081
