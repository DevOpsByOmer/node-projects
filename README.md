Setting Up SigNoz and Collecting Application Logs from Log file


In this guide, we'll walk through the steps to configure SigNoz, a monitoring and observability tool, along with an OpenTelemetry (OTel) Collector to export logs from your application server to SigNoz, which may be running on a different host. This allows you to centralize your logs for analysis and monitoring.

**Step 1: Configure SigNoz Server**

1. SSH into your SigNoz server.

2. Update package lists and install required dependencies:
    ```bash
    sudo apt update
    sudo apt install -y git docker.io docker-compose
    ```

3. Clone the SigNoz repository from GitHub:
    ```bash
    git clone https://github.com/SigNoz/signoz.git
    ```

4. Navigate to the deployment directory:
    ```bash
    cd signoz/deploy
    ```

5. Run the installation script to set up SigNoz containers:
    ```bash
    ./install
    ```

6. After installation, SigNoz UI will be accessible at port 3301. Ensure that the necessary ports (4317-4318, 3301) are open if you're using AWS EC2.

**Step 2: Configure Application Server**

1. SSH into your application server.

2. Install Docker and Docker Compose:
    ```bash
    sudo apt update
    sudo apt install -y git docker.io docker-compose
    ```

3. Create an `otel-collector-config.yaml` file with the following configuration:
    ```yaml
    receivers:
      filelog:
        include: [ /tmp/app.log ]
        start_at: end
    processors:
      batch:
        send_batch_size: 10000
        send_batch_max_size: 11000
        timeout: 10s
    exporters:
      otlp/log:
        endpoint: http://<host>:<port>
        tls:
          insecure: true
    service:
      pipelines:
        logs:
          receivers: [filelog]
          processors: [batch]
          exporters: [ otlp/log ]
    ```
    Replace `<host>:<port>` with the IP address and port where your SigNoz instance is running.

4. Run the OTel Collector container:
    ```bash
    docker run -d --name signoz-host-otel-collector --user root \
    -v /path/to/your/app.log:/tmp/app.log:ro \
    -v /path/to/otel-collector-config.yaml:/etc/otel/config.yaml \
    signoz/signoz-otel-collector:0.88.11
    ```
    Replace `/path/to/your/app.log` with the path to your application log file and ensure that the file is named `app.log`.

**Step 3: Verify Log Export**

After running the OTel Collector, your logs should be exported to SigNoz. You can verify this by checking the SigNoz UI for incoming logs. If there are no errors, your logs will be visible and available for analysis in SigNoz.

By following these steps, you've successfully set up SigNoz along with an OTel Collector to export logs from your application server to SigNoz, facilitating centralized log management and analysis.
