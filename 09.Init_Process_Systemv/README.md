# SystemV Init: Running HelloApp in Runlevel 4 on Raspberry Pi

## **Building Buildroot with SystemV Init**
To set up **Buildroot** with SystemV Init, follow these steps:

### **Step 1: Clone Buildroot Repository**
```sh
git clone git@github.com:buildroot/buildroot.git
```
This will download Buildroot source code.

### **Step 2: Checkout a Specific Version**
```sh
cd buildroot
git checkout 2024.11.1
```
This ensures that you are using a stable(latest) version of Buildroot.

### **Step 3: Select a Raspberry Pi Configuration**
```sh
cd buildroot/configs
ls | grep raspberrypi
```
This lists available configurations for Raspberry Pi.

### **Step 4: Configure Buildroot for Raspberry Pi 3 (64-bit)**
```sh
make raspberrypi3_64_defconfig
```
This sets up the default configuration for the Raspberry Pi 3 (64-bit).

### **Step 5: Enable SystemV Init**
```sh
make menuconfig
```
- Navigate to `System Configuration`
- Change `Init system` to `SystemV` instead of `BusyBox`
- Save and exit

After this, proceed with building Buildroot.

## **Introduction**
This project demonstrates how to set up a **SysVInit** service using `start-stop-daemon` to print a message when switching to **runlevel 4** on a Raspberry Pi running Buildroot.

Content:
- **SysVInit and runlevels**
- How to **create a service script** in `/etc/init.d/`
- How to **use start-stop-daemon** to manage services
- How to **modify `/etc/inittab`** to handle custom runlevels
- How to **properly link services in `/etc/rcX.d/` directories**

---

## **1. Understanding SysVInit and Runlevels**

### **What is SysVInit?**
SysVInit is an initialization system used in Unix-like operating systems to manage system startup and services. It relies on the `/etc/inittab` file and uses **runlevels** to determine system states.

### **Runlevels Explained**
Runlevels define different states of the system:

| Runlevel | Description |
|----------|-------------|
| 0        | Halt (shutdown) |
| 1        | Single-user mode |
| 2        | Multi-user mode without networking |
| 3        | Full multi-user mode (default for many systems) |
| 4        | **Custom runlevel (we use this for HelloApp)** |
| 5        | Multi-user with GUI |
| 6        | Reboot |

Our project configures **runlevel 4** to start a custom service, `HelloApp`.

---

## **2. Creating `HelloApp` Service Script**
We need a script that **runs during runlevel 4** and prints `Hello from HelloApp!` to the console.

### **Step 1: Create the Service Script**
Run the following command to create the service script:

**Introduced another way `rewsha gedan` instead of using vi editor**

```sh
cat <<EOF > /etc/init.d/HelloApp
#!/bin/sh
### BEGIN INIT INFO
# Provides:          HelloApp
# Required-Start:    $remote_fs
# Required-Stop:     $remote_fs
# Default-Start:     4
# Default-Stop:      0 1 6
# Short-Description: Prints Hello using start-stop-daemon
### END INIT INFO

DAEMON=/usr/bin/HelloApp.sh
PIDFILE=/var/run/helloapp.pid

case "$1" in
  start)
    echo "Starting HelloApp..."
    start-stop-daemon --start --background --make-pidfile --pidfile $PIDFILE --exec $DAEMON
    ;;
  stop)
    echo "Stopping HelloApp..."
    start-stop-daemon --stop --pidfile $PIDFILE
    rm -f $PIDFILE
    ;;
  restart)
    $0 stop
    sleep 1
    $0 start
    ;;
  status)
    if [ -f "$PIDFILE" ]; then
      echo "HelloApp is running (PID $(cat $PIDFILE))"
    else
      echo "HelloApp is not running."
    fi
    ;;
  *)
    echo "Usage: /etc/init.d/HelloApp {start|stop|restart|status}"
    exit 1
    ;;
esac
exit 0
EOF
```

### **Step 2: Make the Script Executable**
```sh
chmod +x /etc/init.d/HelloApp
```

---

## **3. Creating the Executable Application**
The `HelloApp` service relies on an actual script (`HelloApp.sh`) that prints a message.

### **Step 1: Create `HelloApp.sh`**

**The same `rawshana`**
```sh
cat <<EOF > /usr/bin/HelloApp.sh
#!/bin/sh
echo "Hello from HelloApp!" > /dev/console
EOF
```

### **Step 2: Make It Executable**
```sh
chmod +x /usr/bin/HelloApp.sh
```

---

## **Preparing the SD Card**
To flash the Buildroot-generated image onto an SD card, use the following command:

```sh
sudo dd if=buildroot/output/images/sdcard.img of=/dev/mmcblk0 bs=4M status=progress && sync
```

This writes the `sdcard.img` file from Buildroot to the SD card.

---

## **5. Testing the Setup**

### **Step 1: Reload Init Configuration**
```sh
telinit q
```

### **Step 2: Switch to Runlevel 4**
```sh
init 4
```

### **Expected Output**
You should see:
```
INIT: Switching to runlevel: 4
INIT: No inittab.d directory found
Starting HelloApp...
Hello from HelloApp!
```

### **Step 3: Check If HelloApp is Running**
```sh
ps aux | grep HelloApp
```

### **Step 4: Stop the Service**
```sh
/etc/init.d/HelloApp stop
```
Expected output:
```
Stopping HelloApp...
```

---

## **7. Conclusion**
You have successfully:

✅ Configured SystemV init to run `HelloApp` in runlevel 4.  
✅ Used `start-stop-daemon` to manage a process.  
✅ Created a fully functional `/etc/init.d/` script.  
✅ Linked it properly in `/etc/rc4.d/`.  

Now, every time you switch to **runlevel 4**, `HelloApp` will run and print a message! 🚀
