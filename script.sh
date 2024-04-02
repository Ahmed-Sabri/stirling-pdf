#!/bin/bash

### Step 1: Prerequisites
sudo apt update && sudo apt full-upgrade
sudo apt install -y git  automake  autoconf  libtool  libleptonica-dev  pkg-config zlib1g-dev make g++ openjdk-17-jdk python3 python3-pip libreoffice-writer libreoffice-calc libreoffice-impress unpaper ocrmypdf python3-full curl nano glances
### Step 2: Clone and Build jbig2enc (Only required for certain OCR functionality)
mkdir ~/.git
cd ~/.git &&\
git clone https://github.com/agl/jbig2enc.git &&\
cd jbig2enc &&\
./autogen.sh &&\
./configure &&\
make &&\
sudo make install 
pip3 install uno opencv-python-headless unoconv pngquant WeasyPrint --break-system-packages
### Step 3: Clone and Build Stirling-PDF
cd ~/.git &&\
git clone https://github.com/Stirling-Tools/Stirling-PDF.git &&\
cd Stirling-PDF &&\
chmod +x ./gradlew &&\
./gradlew build
### Step 4: Move jar to desired location
#After the build process, a `.jar` file will be generated in the `build/libs` directory.
#You can move this file to a desired location, for example, `/opt/Stirling-PDF/`.
#You must also move the Script folder within the Stirling-PDF repo that you have downloaded to this directory.
#This folder is required for the python scripts using OpenCV
sudo mkdir /opt/Stirling-PDF &&\
sudo mv ./build/libs/Stirling-PDF-*.jar /opt/Stirling-PDF/ &&\
sudo mv scripts /opt/Stirling-PDF/ &&\
echo "Scripts installed."
### Step 5: Other files {OCR} [Installing All Languages]
sudo apt install -y 'tesseract-ocr-*'
### Step 6: View installed languages:
echo "View installed languages:"
dpkg-query -W tesseract-ocr- | sed 's/tesseract-ocr-//g'

##############################################################################
### Step 8: Adding a Desktop icon
#Note: Currently the app will run in the background until manually closed.

### Optional: Run Stirling-PDF as a service
cd /opt/Stirling-PDF
sudo curl https://raw.githubusercontent.com/Ahmed-Sabri/stirling-pdf/main/.env -o .env
cd /etc/systemd/system
sudo curl https://raw.githubusercontent.com/Ahmed-Sabri/stirling-pdf/main/stirlingpdf.service -o stirlingpdf.service 
#nano /etc/systemd/system/stirlingpdf.service
#Paste this content, make sure to update the filename of the jar-file. Press Ctrl+S and Ctrl+X to save and exit the nano editor:
#```
#[Unit]
#Description=Stirling-PDF service
#After=syslog.target network.target

#[Service]
#SuccessExitStatus=143
#User=root
#Group=root
#
#Type=simple
#
#EnvironmentFile=/opt/Stirling-PDF/.env
#WorkingDirectory=/opt/Stirling-PDF
#ExecStart=/usr/bin/java -jar Stirling-PDF-0.17.2.jar
#ExecStop=/bin/kill -15 $MAINPID
#
#[Install]
#WantedBy=multi-user.target
#```

systemctl daemon-reload
systemctl enable stirlingpdf
#sudo systemctl status stirlingpdf
#sudo systemctl start stirlingpdf
#sudo systemctl stop stirlingpdf
#sudo systemctl restart stirlingpdf
service stirlingpdf stop
service stirlingpdf start
service stirlingpdf restart
#################################################################
### Run Stirling-PDF ###
echo "Running Stirling-PDF"
java -jar /opt/Stirling-PDF/Stirling-PDF-*.jar
