#!/bin/bash
set -euo pipefail

sudo systemctl enable grafana-server
sudo systemctl start grafana-server