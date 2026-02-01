# EC2 as Service Locally

This is a local AWS EC2 like system that allow users to provision, manage and interact with compute instances on their host system.

## 0. TERMINOLOGIES

1. **Ubiquitous** - Always active: `The system shall...`
2. **Event-driven** - Triggered by event: `WHEN <event> the system shall...`
3. **Unwanted-behavior** - What to avoid: `IF <condition> THEN the system shall...`
4. **State-driven** - Depends on state: `WHILE <state> the system shall...`

## 1. SYSTEM OVERVIEW

- **Product Name**: EC2 as Service Locally
- **Purpose**: A local AWS EC2 like virtualization service running on macOS using libvirt/QEMU.
- **Platform**: macOS (Apple Silicon)

## 2. FUNCTIONAL REQUIREMENT

### 2.1 Instance Creation

- **REQ-INST-001** [*Ubiquitous*]: The system shall create virtual machine instance using libvirt/QEMU
- **REQ-INST-002** [*Ubiquitous*]: The system shall support the following instance types:
    | Instance Type | vCPU | Memory | Disk  |
    | ------------- | ---- | ------ | ----- |
    | t2.nano       | 1    | 512 MB | 8 GB  |
    | t2.micro      | 1    | 1 GB   | 8 GB  |
    | t2.small      | 1    | 2 GB   | 20 GB |
    | t2.medium     | 2    | 4 GB   | 30 GB |
    | t2.large      | 2    | 8 GB   | 30 GB |
- **REQ-INST-003** [*Event-driven*]: WHEN a user creates an instance, the system shall assign a unique instance ID with format:
    ```
    i-[8 hexadecimal characters]
    ```
- **REQ-INST-004** [*Event-driven*]: WHEN a user creates an instance, the system shall allow the user to optionally specify:
    - Instance name
    - SSH key pair
    - User data (cloud-init script)
- **REQ-INST-005** [*Event-driven*]: WHEN an instance is created with an SSH key, the system shall inject the public key into instance using cloud-init.
- **REQ-INST-006** [*Event-driven*]: WHEN an instance is created, the system shall boot the instance and transition its status to `running`.
- **REQ-INST-007** [*Unwanted-behavior*]: IF instance creation fails, THEN the system shall set the instance status to `error`.

### 2.2 Instance Lifecycle

- **REQ-INST-008** [*Ubiquitous*]: The system shall support the following instance states:
    - `pending`— Instance is being created
    - `running`— Instance is active
    - `stopping`— Instance is shutting down
    - `stopped`— Instance is halted
    - `error`— Instance creation or operation failed
    - `terminated`— Instance is deleted
- **REQ-INST-009** [*Event-driven*]: WHEN a user start a stopped instance, the system shall transition to `running` state.
- **REQ-INST-010** [*Event-driven*]: WHEN a user stop a running instnace, the system shall shutdown the guest OS.
- **REQ-INST-011** [*Event-driven*]: WHEN a user reboots an instnace, the system shall restart the instance while maintaining its configuration.
- **REQ-INST-012** [*Event-driven*]: WHEN a user terminates an instance, the system shall:
    - Stop the instance if running
    - Delete the instance's disk
    - Delete the instance's cloud-init ISO
    - Mark the instance as `terminated` in the database.
- **REQ-INST-013** [*State-driven*]: WHILE an instance is in `running` state, the system shall continiously monitor and update the instance's IP address.

### 2.3 Instance Information

- **REQ-INST-014** [*Ubiquitous*]: The system shall provide the following information for each instance.
    - Instance ID
    - Instance name
    - Instance type
    - vCPU count
    - Memory allocation
    - Disk size
    - Current status
    - IP address (when available)
    - SSH key name (if used)
    - Creation timestamp
    - Launch timestamp
    - Termination timestamp (if terminated)
- **REQ-INST-015** [*Event-drive*]: WHEN a user requests instance details, the system shall retrieve current status and IP address from libvirt.

### 2.4 Network Management

- **REQ-NET-001** [*Ubiquitous*]: The system shall create a NAT network name `ec2-as-service` for instance connectivity.
- **REQ-NET-002** [*Ubiquitous*]: The system shall allocate IP address from the range `192.168.100.10` to `192.168.100.254` using DHCP.
- **REQ-NET-003** [*Event-driven*]: WHEN an instance boots, the system shall assign an IP address via DHCP.
- **REQ-NET-004** [*Event-drive*]: WHEN an instance obtains an IP address, the system shall update the instance record with IP address.
- **REQ-NET-005** [*Ubiquitous*]: The system shall provide NAT for outbout connectivity from instance to the internet.
- **REQ-NET-006** [*Event-driven*]: WHEN an instance is created, the system shall assign a unique MAC address based on the instance ID
- **REQ-NET-007** [*Unwanted-behavior*]: IF the DHCP pool is exhaused, the system shall prevent new instance creation and return an error.
- **REQ-NET-008** [*Ubiquitous*]: The system shall guarantee network access to instance IP address from the local host running the libvirt hypervisor.

### 2.5 SSH Key Management

- **REQ-SSH-001** [*Event-driven] WHEN a user imports an SSH public key, the system shall validate that the key is in valid OpenSSH format.
- **REQ-SSH-002** [*Ubiquitous*] The system shall support the following SSH key type:
    - ssh-rsa
    - ssh-ed25519
    - ecdsa-sha2-nistp256
    - ecdsa-sha2-nistp384
    - ecdsa-sha2-nistp521
- **REQ-SSH-003** [*Event-driven*]: WHEN a user imports a SSH key, the system shall calculate and store the MD5 fingerprint.
- **REQ-SSH-004** [*Event-driven*]: WHEN a user imports SSH key, the system shall require a unique key name.
- **REQ-SSH-005** [*Unwanted-behavior*]: WHEN a user import a duplicate SSH key, the system shall reject the import with status code `409`
- **REQ-SSH-006** [*Event-driven*]: WHEN a user deletes a SSH key, the system shall remove it from the database but not affect the existing instance using that key.
- **REQ-SSH-007** [*Ubiquitous*]: The system shall store the SSH public key securely in the database, metadata including.
    - Name
    - Public Key
    - Fingerprint
    - Created At

### 2.6 Image Management

- **REQ-IMG-001** [*Ubiquitous*]: The system shall support Ubuntu 22.04 and 20.04 cloud images.
- **REQ-IMG-002** [*Ubiquitous*]: The system shall automatically detect the host architecture and use appropriate images.
- **REQ-IMG-003** [*Event-driven*]: WHEN the system initialize, the system shall verify that base image exist in the image directory.
- **REQ-IMG-004** [*Unwanted-behavior*]: IF a required base image is missing, THEN the system shall prevent instance creation for that image type and return and error.
- **REQ-IMG-005** [*Ubiquitous*] The system shall store image metadata including:
    - Image ID
    - Image name
    - Description
    - Operating system
    - Architecture
    - File path
    - Creation timestamp

### 2.7 Web Terminal

- **REQ-TERM-001** [*Event-driven*]: WHEN a user connects to a instance terminal, the system shall establish a WebSocket connection.
- **REQ-TERM-002** [*Event-driven*]: WHEN a WebSocket terminal connection is established, the system shall create an SSH connection to the instance.
- **REQ-TERM-003** [*State-driven*]: WHILE a terminal session is active, the system shall bidirectionally relay data between the WebSocket and SSH connection.
- **REQ-TERM-004** [*Event-driven*]: WHEN a user sends input through terminal, the system shall transmit it to the SSH session.
- **REQ-TERM-005** [*Event-driven*]: WHEN the SSH session produces output, the system shall send it to WebSocket.
- **REQ-TERM-006** [*Event-driven*]: WHEN a user resizes the terminal window, the systeam shall update the SSH PTY size accordingly.
- **REQ-TERM-007** [*Unwanted-behavior*]: IF the instance is not running, THEN the system shall reject the terminal connection attempts with an appropriate error message.
- **REQ-TERM-008** [*Unwanted-behavior*]: IF the instance does not have an IP address, THEN the system shall reject terminal connection attemps.
- **REQ-TERM-009** [*Event-driven*]: WHEN the SSH connection closes, the system shall notifiy the WebSocket client and close the WebSocket.
- **REQ-TERM-010** [*Event-driven*]: WHEN the WebSocket disconnects, the shall close the SSH connection and cleanup resources.
- **REQ-TERM-011** [*State-driven*]: WHILE the terminal session is active, the system shall send keep-alive pings every 30 seconds.
- **REQ-TERM-012** [*Ubiquitous*]: The system shall authentical SSH connections using private key corresponding to the instance's configured SSH key.

### 2.8 Storage

- **REQ-STOR-001** [*Ubiquitous*]: The system shall create a libvirt storage pool name `.ec2-as-service` in the user's home directory.
- **REQ-STOR-002** [*Event-driven*]: WHEN an instance is created, the system shall create instance disk image in `qcow2` format.
- **REQ-STOR-003** [*Event-driven*]: WHEN creating instance disk, the system shall use copy-on-write to minimize the storage usage.
- **REQ-STOR-004** [*Even-driven*]: WHEN an instance is terminated, the system shall delete all associated disk images.
- **REQ-STOR-005** [*Ubiquitous*]: The system shall organize storage in the following directory structure:
    ```
    ~/.ec2-as-service/
    |---storage/                # libvirt storage pool
    |---images/                 # base OS images
    |---instances/              # per-instance data
    |   |---i-xxxxxxxx/
    |   |   |---disk.qcow2
    |   |   |---cloud-init.iso
    ```

### 2.9 Resource Limits

- **REQ-LIM-001** [*Unwanted-behavior*]: IF host available memory < 4GB, THEN the system shall prevent new instance creation with error message.
- **REQ-LIM-002** [*Event-driven*]: WHEN user creates instances, the system shall check if disk space > (instance_disk_size + 5GB), else reject.
- **REQ-LIM-003** [*Ubiquitous*]: The system shall display host resource usage (total RAM, used RAM, disk space) in UI.

## 3. NOT-FUNCTIONAL REQUIREMENTS

### 3.1 Reliability

- **REQ-REL-001** [*Ubiquitous*]: The system shall persist instance metadata in SQLite database to survive host restarts.
- **REQ-REL-002** [*Event-driven*]: WHEN the system shall verify the connectivity to libvert and report status
- **REQ-REL-003** [*Unwanted-behavior*]: IF the libvirt connection fails, THEN the system shall return HTTP 503 Service Unavailable.

### 3.2 Usability

- **REQ-USE-001** [*Ubiquitous*]: The system shall provide a web-based user interface accessible at `http://localhost:8000`
- **REQ-USE-002** [*Ubiquitous*]: The system shall provide a REST API with OpenAPI documentation at `/docs`.
- **REQ-USE-003** [*Event-driven*]: WHEN a use performs an action, the system shall provide a clear feedback on success or failure.

### 3.3 Logging

- **REQ-LOG-001** [*Ubiquitous*]: The system shall log error and warning to `~/.ec2-as-service/logs/app.log`.
- **REQ-LOG-002** [*Ubiquitous*]: The system shall rotate logs when exceeding 10MB.
- **REQ-LOG-003** [*Ubiquitous*]: The system shall create new log for each day.
- **REQ-LOG-004** [*Ubiquiouts*]: The system shall retain logs for a maximum of 7 days.
