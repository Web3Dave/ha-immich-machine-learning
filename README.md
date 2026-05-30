# Immich Machine Learning — Home Assistant Add-on

Runs the [Immich](https://immich.app) machine learning server as a standalone Home Assistant OS add-on.
Offloads smart search (CLIP embeddings) and facial recognition from your NAS to the machine running Home Assistant, freeing NAS resources.

## How it works

The add-on runs `ghcr.io/immich-app/immich-machine-learning` directly, exposing port **3003**.
Your NAS Immich instance connects to it over the local network instead of running the ML server itself.
Downloaded models are cached in `/share/immich-ml/cache` so they survive add-on restarts and updates.

---

## Installation

### 1. Add this repository to Home Assistant

1. In Home Assistant, go to **Settings → Add-ons → Add-on Store**.
2. Click the **⋮** menu (top-right) and choose **Repositories**.
3. Paste the repository URL and click **Add**:
   ```
   https://github.com/Web3Dave/ha-immich-machine-learning
   ```
4. Refresh the page. The **Immich Machine Learning** add-on will appear in the store.

### 2. Install and configure the add-on

1. Click **Immich Machine Learning → Install**.
2. Go to the **Configuration** tab and adjust options if needed:

   | Option | Default | Description |
   |---|---|---|
   | `machine_learning_host` | `0.0.0.0` | Interface to bind (keep as-is to accept all connections) |
   | `machine_learning_port` | `3003` | Port the ML server listens on |
   | `machine_learning_workers` | `1` | Number of worker processes |
   | `machine_learning_worker_timeout` | `120` | Worker request timeout in seconds |

3. Click **Save**, then switch to the **Info** tab and click **Start**.
4. Check the **Log** tab to confirm the server started successfully.

### 3. Find your Home Assistant IP

You need the **local IP address** of your Home Assistant machine (e.g. `192.168.1.50`).
Find it under **Settings → System → Network**.

### 4. Point your NAS Immich instance at the add-on

On the machine running Immich (NAS or otherwise), edit the Immich `.env` file and set:

```env
MACHINE_LEARNING_URL=http://192.168.1.50:3003
```

Replace `192.168.1.50` with the actual IP of your Home Assistant machine.

Then restart the Immich stack:

```bash
docker compose down && docker compose up -d
```

To confirm the connection, check the Immich server logs — you should see the ML server URL being used, and smart search / face detection should continue working normally.

---

## Firewall / network notes

- Port `3003/tcp` must be reachable from your NAS to the Home Assistant machine on your local network.
- No internet exposure is needed; this is purely LAN traffic.
- If you run Home Assistant in a VLAN separate from your NAS, ensure inter-VLAN routing allows port 3003.

## Updating the ML server

The add-on tracks the `release` tag of the upstream image.
To update, go to **Settings → Add-ons → Immich Machine Learning → Info** and click **Update** when one is available.
The model cache in `/share/immich-ml/cache` is preserved across updates.

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| Add-on fails to start | Check the **Log** tab; the base image may have changed its entrypoint |
| Smart search returns no results | Confirm `MACHINE_LEARNING_URL` is set correctly in the Immich `.env` and the stack was restarted |
| High memory usage | The first request per model downloads and loads it into RAM; this is expected |
| Timeout errors from Immich | Increase `machine_learning_worker_timeout` in add-on config |
