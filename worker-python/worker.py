import time
import redis
import json

print("Python Worker background service started...")

# Redis server se connect hone ki koshish (docker-compose me service ka naam 'redis' hoga)
try:
    r = redis.Redis(host='redis', port=6379, db=0, decode_responses=True)
    print("Successfully connected to Redis queue!")
except Exception as e:
    print(f"Redis connection failed: {e}. Running in simulation mode.")
    r = None

# Background processing loop
task_counter = 1
while True:
    if r:
        try:
            # Redis list 'task_queue' se task nikalna
            task = r.blpop("task_queue", timeout=2)
            if task:
                task_data = json.loads(task[1])
                print(f"[WORKER] Processing task: {task_data['title']} (ID: {task_data['id']})")
                time.sleep(1) # Simulation delay
                print(f"[WORKER] Task {task_data['id']} successfully completed!")
        except Exception as e:
            print(f"Error reading from queue: {e}")
    else:
        # Agar local bina docker chalayein to simulate karega
        print(f"[SIMULATION] Python Worker is processing simulated task #{task_counter}...")
        task_counter += 1
        time.sleep(3)