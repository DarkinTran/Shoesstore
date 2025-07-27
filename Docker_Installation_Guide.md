# Hướng dẫn cài đặt Docker trên Jenkins Server

## 1. Kiểm tra Docker hiện tại

Trước tiên, kiểm tra xem Docker đã được cài đặt chưa:

```bash
docker --version
docker-compose --version
```

## 2. Cài đặt Docker trên Windows Server

### Bước 1: Tải Docker Desktop
- Truy cập: https://www.docker.com/products/docker-desktop
- Tải Docker Desktop cho Windows
- Chạy file cài đặt và làm theo hướng dẫn

### Bước 2: Cài đặt WSL 2 (nếu cần)
```powershell
# Mở PowerShell với quyền Administrator
wsl --install
```

### Bước 3: Khởi động Docker
- Khởi động Docker Desktop
- Đợi Docker Engine khởi động hoàn tất

## 3. Cài đặt Docker trên Linux Server

### Ubuntu/Debian:
```bash
# Cập nhật package index
sudo apt-get update

# Cài đặt các package cần thiết
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Thêm Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Thêm Docker repository
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Cài đặt Docker Engine
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

# Khởi động Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Thêm user vào docker group (để chạy docker không cần sudo)
sudo usermod -aG docker $USER
```

### CentOS/RHEL:
```bash
# Cài đặt yum-utils
sudo yum install -y yum-utils

# Thêm Docker repository
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

# Cài đặt Docker Engine
sudo yum install docker-ce docker-ce-cli containerd.io

# Khởi động Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Thêm user vào docker group
sudo usermod -aG docker $USER
```

## 4. Cấu hình Jenkins để sử dụng Docker

### Bước 1: Cài đặt Docker Plugin trong Jenkins
1. Vào Jenkins Dashboard
2. Manage Jenkins > Manage Plugins
3. Tìm và cài đặt "Docker Pipeline" plugin
4. Restart Jenkins

### Bước 2: Cấu hình Docker Tool
1. Manage Jenkins > Global Tool Configuration
2. Tìm phần "Docker installations"
3. Thêm Docker installation:
   - Name: `Docker`
   - Docker installation: Chọn Docker installation từ dropdown
4. Lưu cấu hình

### Bước 3: Kiểm tra quyền truy cập
```bash
# Kiểm tra Docker daemon
docker info

# Test Docker với Jenkins user
sudo -u jenkins docker run hello-world
```

## 5. Cấu hình Docker Hub

### Bước 1: Tạo Docker Hub account
- Truy cập: https://hub.docker.com
- Tạo tài khoản mới

### Bước 2: Tạo Personal Access Token
1. Vào Account Settings > Security
2. Tạo New Access Token
3. Lưu token này để sử dụng trong Jenkins

### Bước 3: Cấu hình credentials trong Jenkins
1. Manage Jenkins > Manage Credentials
2. System > Global credentials > Add Credentials
3. Chọn "Username with password"
4. ID: `docker-hub-credentials`
5. Username: Docker Hub username
6. Password: Personal Access Token

## 6. Test Docker với Jenkins

### Tạo test job:
```groovy
pipeline {
    agent any
    
    stages {
        stage('Test Docker') {
            steps {
                script {
                    sh 'docker --version'
                    sh 'docker run hello-world'
                }
            }
        }
    }
}
```

## 7. Troubleshooting

### Lỗi thường gặp:

1. **Permission denied khi chạy docker**
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

2. **Docker daemon không chạy**
```bash
sudo systemctl status docker
sudo systemctl start docker
```

3. **Jenkins không tìm thấy docker command**
- Đảm bảo Docker được cài đặt trong PATH
- Restart Jenkins service

4. **Docker Hub authentication failed**
- Kiểm tra credentials trong Jenkins
- Đảm bảo Personal Access Token còn hiệu lực

## 8. Cập nhật Jenkinsfile để sử dụng Docker Hub

Sau khi cài đặt xong, bạn có thể cập nhật Jenkinsfile để push image lên Docker Hub:

```groovy
stage('Push to Docker Hub') {
    steps {
        script {
            withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                sh 'docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}'
                sh 'docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest'
            }
        }
    }
}
```

## 9. Kiểm tra hoàn tất

Chạy lại pipeline và kiểm tra:
- Docker build thành công
- Image được tạo
- Có thể push lên Docker Hub (nếu đã cấu hình) 