import os
import socket
from datetime import datetime

from flask import Flask

app = Flask(__name__)


@app.get("/")
def home():
    return {
        "message": "Hola desde EC2",
        "container_hostname": socket.gethostname(),
        "ec2_hostname": os.getenv("HOST_HOSTNAME", "desconocido"),
        "time": datetime.now().isoformat(),
    }


@app.get("/health")
def health():
    return {"status": "ok"}


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
