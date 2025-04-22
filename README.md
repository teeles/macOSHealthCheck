# MacOS Health Check (M.H.C.)

M.H.C. is a Bash script that uses [SwiftDialog](https://github.com/swiftDialog/) alongside macOS internal commands to assess your MacBook’s health and replacement readiness. Designed for HelpDesk and end-users, it provides battery health metrics, device age, and an overall status in an interactive dialog.

---

## Features

- **Battery Cycle Count** with thresholds.  
- **Maximum Battery Capacity** with health thresholds (%)  
- **Battery Condition** check (Normal, Service recommended)  
- **Device Build Year** and **Age** calculation  
- **Overall Status** suggesting reuse, donation, or attention  

---

## Prerequisites

- **macOS** (12.0+ recommended)  
- **SwiftDialog** installed  
- **PLIstBuddy** (built-in)  
- **jamf** CLI (optional, for custom triggers)  

---

## Installation

1. **Clone the repo**  
   ```bash
   git clone https://github.com/YOUR_USERNAME/mhc.git
   cd mhc
   ```
2. **Make the script executable**  
   ```bash
   chmod +x mhc.sh
   ```

---

## Usage

Run the script from Terminal or via MDM:

```bash
./mhc.sh
```

A dialog titled **MacBook Health Service** will appear, summarizing the device’s health. Use the provided buttons to proceed or generate logs.

---

## Deployment with Jamf Pro (Optional)

1. Upload `mhc.sh` as a Script in Jamf Pro.  
2. Create a Policy scoped to your target machines.  
3. Add `mhc.sh` in the Scripts payload and add to self service so users can access whenever. 

---

## Customization

- **Dialog Title & Icon:** Edit the `--title` and `--icon` flags in the final dialog command.  
- **Button Actions:** Update the `case` block for Button 2, 3, etc., to trigger logging or other workflows.  
- **Health Thresholds:** Modify the numeric bounds in `bat_cycle_count()`, `bat_max_capacity()`, and `macage()` functions for custom cutoff values.  

---

## Script Breakdown

| Function              | Description                                                                 |
| --------------------- | --------------------------------------------------------------------------- |
| `bat_cycle_count()`   | Retrieves battery cycle count and outputs tiered actions based on thresholds |
| `bat_max_capacity()`  | Checks battery maximum capacity (%) and outputs health status               |
| `bat_condition()`     | Reads battery condition (Normal, Service)                                    |
| `macage()`            | Calculates device age from build year and suggests replacement if older     |
| `overall_status()`    | Aggregates all checks to suggest reuse, donation, or service attention       |
| Dialog Launch         | Uses SwiftDialog to present findings and buttons                            |

---

## To Do

- **Add Logging:** Write health check outputs to `/var/log/mhc.log`  
- **Button Two Function:** Implement log file generation on Button 2 click  
- **Dependency Checks:** Verify SwiftDialog presence at script start  
- **Expand Variables:** Include CPU & memory checks  

---

