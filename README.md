# UPS Voltage Polling Enhancement Scripts

## Overview
This project provides scripts to temporarily increase the polling interval for UPS voltage monitoring on a farm server, enabling more frequent data collection and visualization.

## Scripts

### `grafana_poll_faster.sh`
- A script to configure NUT server, Prometheus, and Grafana for high-frequency UPS voltage data polling (once per second).

#### Usage
- Enable faster polling:
```bash
./grafana_poll_faster.sh fast
```
- Restore default monitoring configuration:
```bash
./grafana_poll_faster.sh back
```

### `local_poll.sh`
- A script to poll local UPS voltage metrics and log changes.

#### Features

- Polls the /ups_metrics endpoint every 0.04 seconds
- Logs voltage data to /tmp/ directory
- Records only voltage changes to minimize data storage

#### Usage

Run for default duration (one hour):
```bash
./local_poll.sh
```

Run in background for one hour:
```bash
./local_poll.sh &
```

Specify custom polling duration (in seconds) and run in the background:
```bash
./local_poll.sh 3600 &
```
## Requirements

- Requires access to local UPS metrics endpoint
- NUT server
- Prometheus
- Grafana

## Notes

- Designed for temporary, high-frequency monitoring
- Helps track rapid voltage changes

