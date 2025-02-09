# SystemV Init: Running HelloApp in Runlevel 4 on Raspberry Pi

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

**The same `rawshana`
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

## **4. Configuring SysVInit to Run HelloApp in Runlevel 4**

### **Step 1: Modify `/etc/inittab`**
Edit `/etc/inittab` and add the following line **if not present**:
```sh
rcl4:4:wait:/etc/init.d/rc 4
```
This ensures that when you switch to runlevel 4 (`init 4`), the scripts in `/etc/rc4.d/` execute.

### **Step 2: Create a Symlink in `/etc/rc4.d/`**
SysVInit runs services from `/etc/rcX.d/`, where `X` is the runlevel number. We must create a symbolic link for `HelloApp`:

```sh
ln -s ../init.d/HelloApp /etc/rc4.d/S99HelloApp
```

**Explanation:**
- `S99HelloApp` → "S" means start, "99" is the priority (higher runs last).
- The script will execute when `init 4` is called.

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

## **6. Debugging Issues**

If `HelloApp` does not run:
1. **Check if the script is executable:**
   ```sh
   ls -l /etc/init.d/HelloApp
   ls -l /usr/bin/HelloApp.sh
   ```
   If it’s not executable, run `chmod +x`.

2. **Manually test HelloApp:**
   ```sh
   /etc/init.d/HelloApp start
   ```
   If it doesn't print "Hello from HelloApp!", check logs:
   ```sh
   dmesg | tail -20
   cat /var/log/messages
   ```

3. **Check runlevel:**
   ```sh
   runlevel
   ```
   Ensure it’s `4`.

4. **Check process status:**
   ```sh
   ps aux | grep HelloApp
   ```

## Result 
![Result](Result/Hello.png)
---

## **7. Conclusion**
You have successfully:

✅ Configured SystemV init to run `HelloApp` in runlevel 4.  
✅ Used `start-stop-daemon` to manage a process.  
✅ Created a fully functional `/etc/init.d/` script.  
✅ Linked it properly in `/etc/rc4.d/`.  

Now, every time you switch to **runlevel 4**, `HelloApp` will run and print a message! 🚀
