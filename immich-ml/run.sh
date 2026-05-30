#!/usr/bin/with-contenv bashio

# Read config values from Home Assistant add-on options
MACHINE_LEARNING_HOST=$(bashio::config 'machine_learning_host')
MACHINE_LEARNING_PORT=$(bashio::config 'machine_learning_port')
MACHINE_LEARNING_WORKERS=$(bashio::config 'machine_learning_workers')
MACHINE_LEARNING_WORKER_TIMEOUT=$(bashio::config 'machine_learning_worker_timeout')
OPENVINO_DEVICE_IDS=$(bashio::config 'openvino_device_ids')

# Export as environment variables consumed by the Immich ML server
export MACHINE_LEARNING_HOST="${MACHINE_LEARNING_HOST}"
export MACHINE_LEARNING_PORT="${MACHINE_LEARNING_PORT}"
export MACHINE_LEARNING_WORKERS="${MACHINE_LEARNING_WORKERS}"
export MACHINE_LEARNING_WORKER_TIMEOUT="${MACHINE_LEARNING_WORKER_TIMEOUT}"
# OpenVINO device index — "0" targets the first Intel iGPU (correct for N100)
export MACHINE_LEARNING_DEVICE_IDS="${OPENVINO_DEVICE_IDS}"

# Model cache lives in /share/immich-ml/cache so it survives add-on restarts/updates
export MACHINE_LEARNING_CACHE_FOLDER="/share/immich-ml/cache"
mkdir -p "${MACHINE_LEARNING_CACHE_FOLDER}"

bashio::log.info "Starting Immich Machine Learning server..."
bashio::log.info "  Host:           ${MACHINE_LEARNING_HOST}"
bashio::log.info "  Port:           ${MACHINE_LEARNING_PORT}"
bashio::log.info "  Workers:        ${MACHINE_LEARNING_WORKERS}"
bashio::log.info "  Worker timeout: ${MACHINE_LEARNING_WORKER_TIMEOUT}s"
bashio::log.info "  Cache folder:   ${MACHINE_LEARNING_CACHE_FOLDER}"
bashio::log.info "  OpenVINO device IDs: ${OPENVINO_DEVICE_IDS}"

exec python -m immich_ml
