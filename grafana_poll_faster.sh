#!/bin/bash

restart_ups_service() {
	systemctl restart nut-server
	sleep 3
	if ! systemctl is-active --quiet "nut-server.service"; then
		echo "Erorr: nut-server.service is not running."
		exit 1
	fi
}

config_ups_faster() {
	sed -i 's/retrydelay =5/retrydelay = 1/g' /etc/nut/ups.conf
	sed -i 's/pollinterval =5/pollinterval = 1/g' /etc/nut/ups.conf
	restart_ups_service
}

config_ups_default() {
	sed -i 's/retrydelay =1/retrydelay = 5/g' /etc/nut/ups.conf
	sed -i 's/pollinterval =1/pollinterval = 5/g' /etc/nut/ups.conf
	restart_ups_service
}

prometheus_interval() {
	sed -i '/^[[:space:]]*metrics_path: \/ups_metrics$/a\
    scrape_interval: 1s\
    scrape_timeout: 1s' /opt/monitoring/prometheus/prometheus.yml
}

prometheus_restore() {
	sed -i '/^[[:space:]]*scrape_interval: 1s/d' /opt/monitoring/prometheus/prometheus.yml
	sed -i '/^[[:space:]]*scrape_timeout: 1s/d' /opt/monitoring/prometheus/prometheus.yml
}

grafana_interval() {
	sed -i '/^[[:space:]]*"id": 2,/a\
      "interval": "1",' /opt/monitoring/grafana/dashboards/ups-status.json
}

grafana_restore() {
	sed -i '/^[[:space:]]*"interval": "1",/d' /opt/monitoring/grafana/dashboards/ups-status.json
}

restart_monitoring() {
	pushd /opt/monitoring
	docker compose down
	docker compose up -d
	popd
}

gotta-go-fast() {
	config_ups_faster
	prometheus_interval
	grafana_interval
	restart_monitoring
}

restore_to_normal() {
	config_ups_default
	prometheus_restore
	grafana_restore
	restart_monitoring
}

if [[ "$1" == "fast" ]]; then
	echo "Setting configs to poll every second. Grafana will restart..."
	gotta-go-fast
elif [[ "$1" == "back" ]]; then
	echo "Restoring configs to the default values..."
	restore_to_normal
else
	echo "No parameters passed to the $0."
	echo "use 'fast' to set the polling rate to 1 sec"
	echo "use 'back' to return the default values"
fi

