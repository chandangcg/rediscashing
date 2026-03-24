# 3-Tier Architecture Project

**Terraform + Ansible + Nginx + Node.js + MySQL + Redis (VirtualBox Setup)**

---

## Project Description

This project demonstrates a **complete end-to-end DevOps setup** of a **3-tier web application architecture** using:

* Infrastructure provisioning (Virtual Machines)
* Configuration management (Ansible)
* Load balancing (Nginx)
* Backend application (Node.js)
* Database (MySQL)
* Caching layer (Redis)

The application supports:

* User **Signup**
* User **Login**
* Displays **Welcome message with username**
* Shows **which server handled the request (node1/node2)**
* Uses **Redis caching** to optimize login performance

---

## 🏗️ Architecture Overview

```id="arc1"
                 ┌──────────────┐
                 │   Client     │
                 └──────┬───────┘
                        │
                ┌───────▼────────┐
                │ Load Balancer  │ (Nginx)
                │ 192.168.1.x    │
                └───────┬────────┘
                        │
        ┌───────────────┴───────────────┐
        │                               │
 ┌──────▼──────┐                ┌───────▼──────┐
 │   Node1     │                │   Node2      │
 │192.168.1.x  │                │192.168.1.x   │
 └──────┬──────┘                └───────┬──────┘
        │                               │
        └──────────────┬────────────────┘
                       │
               ┌───────▼────────┐
               │   MySQL DB     │
               │192.168.1.x     │
               └───────┬────────┘
                       │
               ┌───────▼────────┐
               │    Redis       │
               │192.168.1.x     │
               └────────────────┘
```

---

## 🖥️ VM Configuration

| VM Name       | Role               
| ------------- | ------------------ 
| node1         | Application Server 
| node2         | Application Server 
| lb            | Load Balancer      
| grafana (mon) | MySQL Database     
| cache         | Redis Server       

---

## ⚙️ Prerequisites

* VirtualBox installed
* Ubuntu 22.04 on all VMs
* Bridged Network Adapter
* SSH enabled on all machines
* Ansible installed on host machine

---

## 🧾 Inventory Configuration

```ini id="arc3"
[web]
node1 ansible_host=192.168.1.x ansible_user=node1 ansible_password=admin
node2 ansible_host=192.168.1.x ansible_user=node2 ansible_password=admin

[lb]
loadbalancer ansible_host=192.168.1.x ansible_user=lb ansible_password=admin

[db]
grafana ansible_host=192.168.1.x ansible_user=mon ansible_password=admin

[cache]
redis ansible_host=192.168.1.x ansible_user=cache ansible_password=admin
```

---

##  Steps

### 1️⃣ Verify connectivity

```bash id="arc4"
ansible -i inventory.ini all -m ping -K
```

---

### 2️⃣ Run complete setup

```bash id="arc5"
ansible-playbook -i inventory.ini site.yml -K
```

---

### 3️⃣ Access application

```bash id="arc6"
http://192.168.1.x
```

---

## 🔥 Application Workflow

1. User opens app via Load Balancer
2. Request is routed to node1 or node2
3. User logs in:

   * Redis checked first
   * If cache hit → fast response
   * If miss → query MySQL
4. Response includes:

   * Username
   * Server name
   * Source (DB / CACHE)

---

## 🧠 Redis Caching Flow

```id="arc7"
Login Request →
   Check Redis →
      HIT → Return Fast
      MISS → Query MySQL → Store in Redis → Return
```

---

##  Redis Manual Verification

```bash id="arc8"
redis-cli
ping
keys *
get user:<username>
ttl user:<username>
```

---

## 🐞 Errors Faced & Solutions

---

###  Network Issue (No route to host)

```id="arc9"
ssh: No route to host
```

**Cause:** VM network misconfiguration
**Fix:**

* Use Bridged Adapter
* Restart VM
* Verify IP with:

```bash id="arc10"
ip a
```

---

###  Ansible SSH Failure

```id="arc11"
UNREACHABLE!
```

**Fix:** Ensure SSH service running:

```bash id="arc12"
sudo systemctl start ssh
```

---

###  Missing sudo password

```id="arc13"
Missing sudo password
```

**Fix:**

```bash id="arc14"
ansible-playbook site.yml -K
```

---

###  Node.js not starting

```id="arc15"
Connection refused on port 3000
```

**Fix:**

```bash id="arc16"
node app.js
```

---

###  Node version error

```id="arc17"
Cannot find module 'node:buffer'
```

**Cause:** Old Node version
**Fix:** Install Node 18 using NodeSource

---

###  MySQL connection issues

```id="arc18"
EHOSTUNREACH / ECONNREFUSED
```

**Fix:**

```bash id="arc19"
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

```id="arc20"
bind-address = 0.0.0.0
```

---

###  MySQL Access Denied

```id="arc21"
Access denied for user 'root'
```

**Fix:**

```sql id="arc22"
CREATE USER 'appuser'@'%' IDENTIFIED BY 'admin';
GRANT ALL PRIVILEGES ON userdb.* TO 'appuser'@'%';
FLUSH PRIVILEGES;
```

---

###  Unknown database

```id="arc23"
Unknown database 'userdb'
```

**Fix:**

```sql id="arc24"
CREATE DATABASE userdb;
```

---

###  Port already in use

```id="arc25"
EADDRINUSE: 3000
```

**Fix:**

```bash id="arc26"
sudo kill -9 $(sudo lsof -t -i:3000)
```

---

###  NPM permission error

```id="arc27"
EACCES permission denied
```

**Fix:**

```bash id="arc28"
sudo chown -R $USER:$USER ~/app
```

---

###  Load Balancer 502

```id="arc29"
502 Bad Gateway
```

**Cause:** Backend not reachable
**Fix:**

* Ensure app running on both nodes
* Restart Nginx

---

###  Redis not caching

```id="arc30"
keys * → empty
```

**Cause:** Only connection, no caching logic
**Fix:** Implement `GET` and `SET` in app

---

## ⚡ Useful Commands

```bash id="arc31"
# Check running app
ps -ef | grep node

# Kill app
pkill node

# Restart nginx
sudo systemctl restart nginx

# Check MySQL
sudo netstat -tulnp | grep 3306

# Check Redis
redis-cli monitor
```

---
