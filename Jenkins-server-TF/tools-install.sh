#!/bin/bash
# 1. تنظيف الحاويات القديمة (SonarQube)
echo "--- Cleaning old Docker containers ---"
sudo docker rm -f sonar || true

# 2. تنظيف ملفات التثبيت القديمة لـ AWS CLI
echo "--- Cleaning old installation files ---"
sudo rm -rf awscliv2.zip ./aws

# 3. التأكد من إزالة مفاتيح جينكنز القديمة المسببة للمشاكل
echo "--- Removing old Jenkins list ---"
sudo rm -f /etc/apt/sources.list.d/jenkins.list

# 4. تحديث المستودعات والمفاتيح بأحدث الروابط (2026)
echo "--- Fetching new GPG keys ---"
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/" | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# 5. تشغيل سكريبت التثبيت الحديث (الذي قمنا بتعديله سابقاً)
echo "--- Running the updated installation script ---"
# ملاحظة: سأقوم بدمج أوامر التثبيت المحدثة هنا مباشرة لضمان العمل
sudo apt update -y
sudo apt install openjdk-17-jdk -y
sudo apt install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins

# تثبيت Docker وأذونات المستخدم
sudo apt install docker.io -y
sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu
sudo chmod 666 /var/run/docker.sock

# تشغيل سونار كيوب بنسخة مستقرة
sudo docker run -d --name sonar -p 9000:9000 sonarqube:lts-community

# تثبيت AWS CLI و Kubectl و Terraform و Trivy
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y && unzip -o awscliv2.zip && sudo ./aws/install --update
K8S_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl"
sudo chmod +x kubectl && sudo mv kubectl /usr/local/bin/

echo "--- Setup Finished Successfully ---"
