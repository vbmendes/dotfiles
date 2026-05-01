# GPU Setup

Configuration for NVIDIA GeForce RTX 3060 Ti on Ubuntu 24.04.

## Install drivers

```bash
bash setup.sh
```

## Chrome flags

Open `chrome://flags` and apply the following settings, then click **Relaunch**.

| Flag | Value |
|---|---|
| Override software rendering list | Enabled |
| Hardware-accelerated video decode | Disabled |

**Override software rendering list** forces Chrome to use GPU acceleration for features it would otherwise block on Linux NVIDIA drivers.

**Hardware-accelerated video decode** must be disabled to fix blank video on YouTube (audio plays but no picture). WebGL and WebGPU remain hardware-accelerated, so Google Meet background blur continues to work.

Verify at `chrome://gpu` that WebGL and WebGPU show **Hardware accelerated**.
