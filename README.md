# OpsWerks Academy: Mini Project 1 — Employee Shift Scheduler

This repository contains a **Bash-based employee shift scheduler** with strict constraints, JSON persistence, and Dockerization.  
This was built as part of **OpsWerks Academy: Mini Project 1**.

---

## BASH script Guidelines:
1. Accept user input for:
    - Employee Name
    - Shift (morning / mid / night)
    - Team (A1 / A2 / A3 / B1 / B2 / B3)
2. Continuously loop to accept additional employees, until an exit condition is met.
3. Enforces shift limits:
    - Only two employees per shift per team are allowed.
    - If a third employee is added to a shift within the same team, the script must error out and exit.
4. Support an exit condition, where entering "print" as the employee’s name displays the current shift schedule per team in a tabulated format.
5. Store all valid shift entries in a structured JSON file, so that data is persistent and Docker-ready with volume mounts.

---

## Requirements

* **Bash** 4+
* **jq** (JSON processor)
* **Docker** (Dockerization)

Install `jq` on Ubuntu/Debian:

```bash
sudo apt update && sudo apt install -y jq
```

Install `Docker` for supported platforms:

https://docs.docker.com/engine/install/#installation-procedures-for-supported-platforms/


Install `Docker` for Windows:

https://docs.docker.com/desktop/setup/install/windows-install/

Install `Docker` for Mac:

https://docs.docker.com/desktop/setup/install/mac-install/

---

## Clone this Repository

```bash
git clone https://github.com/pbernal-academy/Mini-Project-1--Group-3-.git
```
---

## Quick Start (Docker)

```bash
docker compose build 
```
---

## Test the script:

```bash
docker compose run --rm scheduler
```


---

### Happy Path 
Runs two valid employee inserts and prints schedule.

```bash
Enter Employee Name: Gab
Enter Shift (morning, mid, night): night
Enter Team (A1, A2, A3, B1, B2, B3): b1
Added Gab to team B1 (night shift).

Enter Employee Name: Karl
Enter Shift (morning, mid, night): night
Enter Team (A1, A2, A3, B1, B2, B3): b1
Added Karl to team B1 (night shift).
```

Expected: Table shows Gab & Karl in Team B1 (morning).

Enter Employee Name: print

```bash
+------+---------+----------------+
| Team | Shift   | Employees      |
+------+---------+----------------+
| A1   | morning | Perry, Clarissa |
| A1   | night   | Cherish, Rex   |
| A2   | mid     | Perry, Cherish |
| B1   | night   | Gab, Karl      |
+------+---------+----------------+
```
### Unhappy Path Test
Runs three inserts in the same team/shift → triggers limit error.

```bash
Enter Employee Name: Hannah
Enter Shift (morning, mid, night): morning
Enter Team (A1, A2, A3, B1, B2, B3): a3
Added Hannah to team A3 (morning shift).

Enter Employee Name: rose
Enter Shift (morning, mid, night): morning
Enter Team (A1, A2, A3, B1, B2, B3): a3
Added Rose to team A3 (morning shift).

Enter Employee Name: john
Enter Shift (morning, mid, night): morning
Enter Team (A1, A2, A3, B1, B2, B3): a3
```

Expected: Error: maximum employees per shift reached.

---

## Git Workflow (Team Requirements)
- Use a **private GitHub repo** as main.
  - For this Project the Main Repository is under pbernal-academy with Repository name pbernal-academy/Mini-Project-1--Group-3-
- Each teammate forks → works on branches → opens Pull Requests.
  - Github accounts of each member with forked main repository:
    - pbernal-opswerks/Mini-Project-1--Group-3- (pj.bernal@academy.opswerks.com)
    - cgohee-academy/Mini-Project-1--Group-3- (cp.gohee@academy.opswerks.com)
    - cmagdadaro-academy/Mini-Project-1--Group-3- (cb.magdadaro@academy.opswerks.com)
- No direct commits to `main` branch.
- Example branches:
  - `feature/scriptcore`
    - Push/Pull Request by pbernal-opswerks/Mini-Project-1--Group-3-
  - `feature/Dockercompose`
    - Push/Pull Request by cgohee-academy/Mini-Project-1--Group-3-
  - `feature/Dockerfile`
    - Push/Pull Request by cmagdadaro-academy/Mini-Project-1--Group-3-
  - `docs/readme`
    - Push/Pull Request by pbernal-opswerks/Mini-Project-1--Group-3-

---

## Deliverables
- `shift_scheduler.sh` — Bash scheduler script
- `Dockerfile` — Dockerization
- `docker-compose.yml` — Container Build
- `README.md` — Documentation

---

# Setup Documentation

# Shift Scheduler Script

A tiny interactive Bash tool for assigning employees to teams and shifts, backed by a JSON file and powered by `jq`.

---

## Features

* Stores assignments in a JSON file (default: `/data/shifts.json`).
* Lets you add employees interactively to **Team** (`A1–A3`, `B1–B3`) and **Shift** (`morning`, `mid`, `night`).
* Caps each team/shift at **2 employees**.
* Type `print` instead of a name to see a formatted table and exit.


## How it works — Step by Step

Below is a walkthrough of what each part of the script does.

### 1) Pick the data file

```bash
DATA_FILE="${DATA_FILE:-/data/shifts.json}"
```

* If the `DATA_FILE` environment variable is set, use it.
* Otherwise, default to `/data/shifts.json`.

### 2) Ensure `jq` exists

```bash
if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required. Install with: sudo apt install jq"
  exit 1
fi
```

* Exits early with a helpful message if `jq` is not installed.

### 3) Initialize the data file if missing

```bash
if [ ! -f "$DATA_FILE" ]; then
  mkdir -p "$(dirname "$DATA_FILE")"
  cat > "$DATA_FILE" <<'JSON'
{
  "A1": { "morning": [], "mid": [], "night": [] },
  "A2": { "morning": [], "mid": [], "night": [] },
  "A3": { "morning": [], "mid": [], "night": [] },
  "B1": { "morning": [], "mid": [], "night": [] },
  "B2": { "morning": [], "mid": [], "night": [] },
  "B3": { "morning": [], "mid": [], "night": [] }
}
JSON
fi
```

* Creates the parent directory for the JSON file if it doesn’t exist.
* Seeds an empty structure for all teams and shifts.

**Data file shape:**

```json
{
  "A1": { "morning": ["Alice"], "mid": [], "night": ["Bob"] },
  "A2": { "morning": [], "mid": [], "night": [] },
  "A3": { "morning": [], "mid": [], "night": [] },
  "B1": { "morning": [], "mid": [], "night": [] },
  "B2": { "morning": [], "mid": [], "night": [] },
  "B3": { "morning": [], "mid": [], "night": [] }
}
```

### 4) Enter the main loop

```bash
while true; do
  ...
done
```

* The script repeatedly prompts for input until you either hit an error (capacity full) or type `print` to display results and exit.

### 5) Prompt for employee name (with a special command)

```bash
read name
name="${name^}"
if [[ "${name,,}" == "print" ]]; then
  # render table + exit
fi
```

* Reads a name and **capitalizes the first letter** (`${name^}`).
* If you type `print` (case‑insensitive), the script **prints the current roster** and **exits**.

**Print output example:**

```
+------+---------+----------------+
| Team | Shift   | Employees      |
+------+---------+----------------+
| A1   | morning | Alice, Bob     |
| A1   | night   | Carol          |
+------+---------+----------------+
```

The table is generated by querying JSON with `jq`:

```bash
jq -r --arg t "$team" --arg s "$shift" '.[$t][$s] | join(", ")' "$DATA_FILE"
```

### 6) Prompt for shift and normalize case

```bash
read shift
shift="${shift,,}"
if [[ ! " morning mid night " =~ " $shift " ]]; then
  echo "Invalid shift!"
  continue
fi
```

* Converts input to **lowercase**.
* Validates against the allowed set: `morning`, `mid`, `night`.

### 7) Prompt for team and normalize case

```bash
read team
team="${team^^}"
if [[ ! " A1 A2 A3 B1 B2 B3 " =~ " $team " ]]; then
  echo "Invalid team!"
  continue
fi
```

* Converts input to **UPPERCASE**.
* Validates against allowed teams: `A1–A3`, `B1–B3`.

### 8) Enforce capacity per team/shift

```bash
count=$(jq -r --arg t "$team" --arg s "$shift" '.[$t][$s] | length' "$DATA_FILE")
if [ "$count" -ge 2 ]; then
  echo "Error: Maximum employees per shift in team $team reached. Exiting..."
  exit 1
fi
```

* Uses `jq` to count how many employees are already assigned.
* If there are **2 or more**, exit with an error (current max is 2).

### 9) Prevent duplicate names

Insert a duplicate check before adding:

```bash
# Check if employee is already on the same shift
exists=$(jq -r --arg t "$team" --arg s "$shift" --arg n "$name" '(.[$t][$s] | index($n)) // empty' "$DATA_FILE")
if [ -n "$exists" ]; then
  echo "Error: $name is already assigned to $team ($shift)."
  continue
fi
```

### 10) Add the employee safely

```bash
tmp=$(mktemp)
jq --arg t "$team" --arg s "$shift" --arg n "$name" '.[$t][$s] += [$n]' "$DATA_FILE" > "$tmp"
mv "$tmp" "$DATA_FILE"
```

* Builds the new JSON in a **temporary file** first (`mktemp`).
* Moves it over the original file to avoid partial writes.

### 11) Confirm and loop

```bash
echo "Added $name to team $team ($shift shift)."
```

* Prints a confirmation message and loops back for the next employee.

---

## Usage Example (interactive)

```
$ ./shift-scheduler.sh
Enter Employee Name: alice
Enter Shift (morning, mid, night): morning
Enter Team (A1, A2, A3, B1, B2, B3): a1
Added Alice to team A1 (morning shift).

Enter Employee Name: bob
Enter Shift (morning, mid, night): morning
Enter Team (A1, A2, A3, B1, B2, B3): a1
Added Bob to team A1 (morning shift).

Enter Employee Name: print

+------+---------+----------------+
| Team | Shift   | Employees      |
+------+---------+----------------+
| A1   | morning | Alice, Bob     |
+------+---------+----------------+
```

---
## Tips & Troubleshooting

* **`jq: command not found`** → Install `jq` (`sudo apt install jq`).
* **Permission denied writing data** → Ensure the directory for `DATA_FILE` exists and is writable.
* **Script exits with capacity error** → Raise the capacity or choose another team/shift.
* **Run non‑interactively?** → This script is intentionally interactive. For automation, wrap it and call `jq` directly to manipulate the JSON.

---

## Project Structure

```
├── tests/
│   └── shift_scheduler.sh  # The script
└── data/shifts.json        # Created locally, stores shifts.json
```

---

## Security & Data Notes

* The JSON file is plain text. Treat it like any other non‑sensitive roster.
* No locking is implemented; avoid concurrent writes from multiple processes.

---

# Shift Scheduler – Dockerfile & Docker Compose Setup
 
This project uses Docker and Docker Compose to run the **Shift Scheduler CLI**, a Bash script that manages employee assignments across teams and shifts using a JSON file for storage.
 
---
 
## Overview
 
* **Dockerfile** → builds a container image with all dependencies and the script.
* **docker-compose.yml** → defines how to run the container, mount volumes, and keep data persistent.
 
Together, these files make it simple to run the scheduler interactively, with data saved outside the container.
 
---
 
## Dockerfile Explained
 
### 1. Base Image
 
```dockerfile
FROM debian:bookworm-slim
```
 
* Starts with a minimal Debian image to keep size small.
 
### 2. Install Dependencies
 
```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends bash jq && rm -rf /var/lib/apt/lists/*
```
 
* Installs only what is needed:
 
  * **Bash** → required for the script.
  * **jq** → JSON parsing tool.
* Cleans package lists to minimize image size.
 
### 3. Working Directory
 
```dockerfile
WORKDIR /app
```
 
* Sets `/app` as the working directory inside the container.
 
### 4. Copy Script
 
```dockerfile
COPY tests/shift_scheduler.sh /app/shift_scheduler.sh
RUN chmod +x /app/shift_scheduler.sh
```
 
* Copies the `shift_scheduler.sh` script into the container.
* Grants execute permissions.
 
### 5. Data Persistence
 
```dockerfile
VOLUME ["/data"]
ENV DATA_FILE=/data/shifts.json
```
 
* Declares `/data` as a **volume** (persistent storage location).
* Sets `DATA_FILE` environment variable so the script always uses `/data/shifts.json`.
 
### 6. Entrypoint
 
```dockerfile
ENTRYPOINT ["/app/shift_scheduler.sh"]
```
 
* Defines the script as the default command when the container runs.
 
---

## docker-compose.yml Explained
 
```yaml
services:
  scheduler:
    build: .
    image: mini-project-1-scheduler:latest
    container_name: shift-scheduler
    stdin_open: true
    tty: true
    volumes:
      - ./data:/data
```
 
### 1. services → scheduler
 
* Defines a service named `scheduler`.
 
### 2. build
 
```yaml
build: .
```
 
* Builds the Docker image from the `Dockerfile` in the current directory.
 
### 3. image
 
```yaml
image: mini-project-1-scheduler:latest
```
 
* Tags the built image as `mini-project-1-scheduler:latest`.
 
### 4. container\_name
 
```yaml
container_name: shift-scheduler
```
 
* Names the running container `shift-scheduler` (instead of a random auto‑generated name).
 
### 5. stdin\_open & tty
 
```yaml
stdin_open: true
tty: true
```
 
* Keeps STDIN open and allocates a TTY, allowing interactive input (required since the script prompts for names, teams, shifts).
 
### 6. volumes
 
```yaml
volumes:
  - ./data:/data
```
 
* Mounts the local `./data` folder into the container’s `/data` directory.
* Ensures the `shifts.json` file is stored on the host machine, so data is preserved even if the container is removed.
 
---
 
## How They Connect
 
* The **Dockerfile** builds an image that contains everything needed to run the scheduler.
* The **docker-compose.yml** sets up a service that runs that image interactively and mounts a persistent data directory.
* The script always writes to `/data/shifts.json`, and because `/data` is mapped to `./data` on the host, the file is saved locally.
 
---
 
## Build & Run
 
### 1. Build the image with Compose
 
```bash
docker compose build
```
 
### 2. Start the service interactively
 
```bash
docker compose run scheduler
```
or
```bash
docker compose run --rm scheduler
```
--rm flag
Automatically removes the container after it stops.
 
→ Keeps things clean, so you don’t end up with lots of stopped containers.
 
This launches the script inside the container with interactive prompts.
 
---
 
## Example Run
 
```bash
$ docker compose run --rm scheduler
Enter Employee Name: alice
Enter Shift (morning, mid, night): morning
Enter Team (A1, A2, A3, B1, B2, B3): a1
Added Alice to team A1 (morning shift).
 
Enter Employee Name: print
 
+------+---------+----------------+
| Team | Shift   | Employees      |
+------+---------+----------------+
| A1   | morning | Alice          |
+------+---------+----------------+
```
 
After exit, check the data on the host:
 
```bash
cat ./data/shifts.json
```
 
---
 
## Project Structure
 
```
.
├── Dockerfile
├── docker-compose.yml
├── tests/
│   └── shift_scheduler.sh
└── data/                 # Created locally, stores shifts.json
```
 
---
 
## Tips & Troubleshooting
 
* **`jq: command not found`** → ensure the Docker image is rebuilt (`docker-compose build`).
* **No data saved** → confirm `./data` exists and is mounted correctly.
* **Script exits immediately** → must run with `docker-compose run` (not `up`), because it’s an interactive service.
 
---
 
## Team Members
- Cherish Gohee
- Clarissa Bianca Magdadaro
- Perry Bernal
