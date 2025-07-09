#!/usr/bin/env bash
# stop script on error
set -e

# Check for python 3
# if ! python3 --version &> /dev/null; then
#   printf "\nERROR: python3 must be installed.\n"
#   exit 1
# fi

# Check to see if root CA file exists, download if not
if [ ! -f ./root-CA.crt ]; then
  printf "\nDownloading AWS IoT Root CA certificate from AWS...\n"
  curl https://www.amazontrust.com/repository/AmazonRootCA1.pem > root-CA.crt
fi

# Check to see if AWS Device SDK for Python exists, download if not
if [ ! -d ./aws-iot-device-sdk-python-v2 ]; then
  printf "\nCloning the AWS SDK...\n"
  git clone https://github.com/aws/aws-iot-device-sdk-python-v2.git --recursive
fi

# Ensure pip is up to date
python3 -m pip install --upgrade pip

# Function to install a package if it's not already available
check_and_install() {
  import_name=$1
  package_name=$2
  friendly_name=$3

  if ! python3 -c "import $import_name" &> /dev/null; then
    printf "\nInstalling %s...\n" "$friendly_name"
    python3 -m pip install "$package_name"
    result=$?
    if [ $result -ne 0 ]; then
      printf "\nERROR: Failed to install %s.\n" "$friendly_name"
      exit $result
    fi
  else
    printf "\n%s is already installed.\n" "$friendly_name"
  fi
}

check_and_install "cv2" "opencv-python" "OpenCV"
check_and_install "awsiot" "./aws-iot-device-sdk-python-v2" "AWS SDK"

printf "\nRunning FrED Factory Foresight Vision application...\n"
python3 fredfactory-vision-mqtt/fredfactory-foresight-vision.py --endpoint a2jz91nv8kralk-ats.iot.us-east-1.amazonaws.com --ca_file root-CA.crt --cert thing_FredFactory5.cert.pem --key thing_FredFactory5.private.key