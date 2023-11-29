
# Docker Setup with Tor and Privoxy

This setup provides a Docker container running Tor and Privoxy on Alpine Linux with OpenRC, focusing on high security and privacy standards.

## Prerequisites

- Docker installed on your machine.
- Basic knowledge of Docker, Tor, and Privoxy.

## Setup Instructions

### Step 1: Build the Docker Image

Navigate to the directory containing your Dockerfile and configuration files (`torrc` and `privoxy-config`). Build the Docker image using the following command:

```bash
docker build -t tor-privoxy-image .
```

### Step 2: Run the Docker Container

Run the Docker container with the necessary port mappings:

```bash
docker run -p 127.0.0.1:9050:9050 -p 127.0.0.1:8118:8118 -p 127.0.0.1:9051:9051 tor-privoxy-image
```

### Step 3: Generate HashedControlPassword

To generate a HashedControlPassword for Tor:

1. Run the following command on your host machine:
   ```bash
   tor --hash-password my_password
   ```
2. Replace `my_password` with your desired password.
3. Insert the generated hash into the `torrc` configuration file under `HashedControlPassword`.

### Step 4: Configure Tor Control Port

- Ensure the Tor Control Port is correctly configured in the `torrc` file.
- By default, the Control Port is set to `9051`. Ensure this port is exposed in the Dockerfile if you plan to access it from outside the container.
- Use strong authentication (hashed password) for any access to the Control Port.

### Step 5: Configure Firewall Settings

Configure your host machine's firewall to allow traffic only through the necessary ports. For example, using iptables:

```bash
iptables -A INPUT -p tcp --dport 9050 -j ACCEPT
iptables -A INPUT -p tcp --dport 8118 -j ACCEPT
iptables -A INPUT -p tcp --dport 9051 -j ACCEPT # If using the Control Port externally
```

### Step 6: Network Isolation

Use Docker's network features for additional isolation:

```bash
docker network create --driver bridge isolated_network
docker run --network isolated_network tor-privoxy-image
```

### Step 7: Applying Configuration Changes

If you make changes to the configuration files (`torrc` or `privoxy-config`), restart the Docker container to apply these changes:

```bash
docker restart [container_id]
```

### Step 8: Starting and Stopping the Container

To start the Docker container:

```bash
docker start [container_id]
```

To stop the Docker container:

```bash
docker stop [container_id]
```

## Usage Examples

### Using with a Node.js Application

In a Node.js application, configure the HTTP request to use the Privoxy proxy:

```javascript
const axios = require('axios');

axios.get('https://check.torproject.org/api/ip', {
   proxy: {
      host: '127.0.0.1',
      port: 8118
   }
})
        .then(response => {
           console.log(response.data);
        })
        .catch(error => {
           console.error('Error:', error);
        });
```

### Using with a Curl Command

To use the Privoxy proxy with a curl command:

```bash
curl --proxy http://127.0.0.1:8118 https://check.torproject.org/api/ip
```

## Monitoring and Logs

Regularly monitor the logs for any unusual activity. Use the following command to view the logs of the Docker container:

```bash
docker logs [container_id]
```

## Updates

Keep your Docker image and host system updated with the latest security patches.

## Conclusion

This setup offers a secure environment for routing web traffic through Tor with Privoxy's filtering capabilities. Ensure you stay informed about updates and best practices in network security.


## Usage Examples

### Using with Node.js and Playwright

This example demonstrates how to use Playwright in a Node.js application to route web requests through the Privoxy proxy configured in the Docker container.

#### Prerequisites
- Node.js installed on your machine.
- Playwright installed in your Node.js project (`npm install playwright`).

#### Example Code

```javascript
const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({
    proxy: {
      server: 'http://127.0.0.1:8118'
    }
  });

  const page = await browser.newPage();
  await page.goto('https://check.torproject.org/api/ip');
  console.log(await page.content());
  await browser.close();
})();
```

This script launches a Chromium browser through Playwright, directing its traffic through the Privoxy proxy. The script navigates to 'https://check.torproject.org/api/ip' to verify the Tor connection.

### Interacting with the Tor Control Port

This example shows how to interact with the Tor Control Port to get information about the current Tor circuit.

#### Prerequisites
- Telnet or a similar tool to interact with the Control Port.
- The hashed control password for your Tor instance.

#### Example Commands

1. Open a connection to the Tor Control Port:

```bash
telnet 127.0.0.1 9051
```

2. Authenticate using your hashed control password (replace `[hashed_password]` with your actual password):

```bash
AUTHENTICATE "[hashed_password]"
```

3. After successful authentication, you can execute various commands. For example, to get information about the current circuit:

```bash
GETINFO circuit-status
```

4. To close the connection, use:

```bash
QUIT
```

These commands will allow you to interact directly with the Tor instance running inside your Docker container, giving you insights into its status and control over its operations.
