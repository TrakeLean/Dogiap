import time
def script():
    while True:
        print(time.strftime("%Y-%m-%d %H:%M:%S"))
        time.sleep(60)