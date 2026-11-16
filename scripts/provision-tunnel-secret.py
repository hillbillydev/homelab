#!/usr/bin/env python3
"""Send the tunnel token directly from Cloudflare to a Swarm secret, never stdout."""
import json
import os
from pathlib import Path
import subprocess
import sys
import urllib.error
import urllib.request

root = Path(__file__).resolve().parent.parent
host = os.environ.get("SWARM_SSH", "hillbillydev@192.168.0.29")
secret = "cloudflare_tunnel_token"
ssh = ["ssh", "-o", "BatchMode=yes", host]
existing = subprocess.run(
    ssh + ["sudo -n docker secret ls --format '{{.Name}}'"],
    capture_output=True, text=True, check=True,
)
if secret in existing.stdout.splitlines():
    print("Swarm tunnel secret already exists; preserved.")
    sys.exit(0)

api_token = os.environ.get("CLOUDFLARE_API_TOKEN")
if not api_token:
    sys.exit("Set CLOUDFLARE_API_TOKEN in .env first.")
state = json.loads((root / "terraform/terraform.tfstate").read_text())
tunnels = [r for r in state["resources"]
           if r["type"] == "cloudflare_zero_trust_tunnel_cloudflared" and r["name"] == "homelab"]
attributes = tunnels[0]["instances"][0]["attributes"]
url = ("https://api.cloudflare.com/client/v4/accounts/" + attributes["account_id"]
       + "/cfd_tunnel/" + attributes["id"] + "/token")
request = urllib.request.Request(url, headers={"Authorization": "Bearer " + api_token})
try:
    with urllib.request.urlopen(request, timeout=30) as response:
        data = json.load(response)
except urllib.error.HTTPError as error:
    sys.exit(f"Cloudflare token retrieval failed: HTTP {error.code}")
if not data.get("success") or not isinstance(data.get("result"), str):
    sys.exit("Cloudflare did not return a tunnel token.")
result = subprocess.run(
    ssh + ["sudo -n docker secret create " + secret + " -"],
    input=data["result"].encode(), capture_output=True,
)
if result.returncode:
    sys.exit("Creating the Swarm secret failed; token was not printed.")
print("Created Swarm tunnel secret. No plaintext token file was written.")
