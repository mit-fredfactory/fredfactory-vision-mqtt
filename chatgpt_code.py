import cv2
import base64
import paho.mqtt.client as mqtt
import time

# MQTT Configuration
MQTT_BROKER = "test.mosquitto.org"  # Replace with your broker
MQTT_PORT = 1883
MQTT_TOPIC = "raspi/camera/image"

# Connect to MQTT
client = mqtt.Client()
client.connect(MQTT_BROKER, MQTT_PORT, 60)
client.loop_start()

# Initialize webcam
cap = cv2.VideoCapture(0)

if not cap.isOpened():
    print("Failed to open camera.")
    exit()

try:
    while True:
        ret, frame = cap.read()
        if not ret:
            continue

        # Resize (optional)
        frame = cv2.resize(frame, (320, 240))

        # Encode frame as JPEG
        _, buffer = cv2.imencode('.jpg', frame)
        jpg_as_text = base64.b64encode(buffer).decode('utf-8')

        # Publish
        client.publish(MQTT_TOPIC, jpg_as_text)
        print("Image sent to MQTT broker.")

        time.sleep(1)  # send every 1 second

except KeyboardInterrupt:
    print("Stopped by user.")

finally:
    cap.release()
    client.loop_stop()
    client.disconnect()
