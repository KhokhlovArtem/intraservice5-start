### **Этап 1: Создание Docker-образов**

Нужно создать два Dockerfile и настроить их сборку.

#### **1. Dockerfile для .NET приложения**

```dockerfile
# Dockerfile.dotnet
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime
WORKDIR /app
EXPOSE 5000

# Копируем опубликованное приложение
COPY published/ ./

ENTRYPOINT ["dotnet", "YourApp.dll"]
```

#### **2. Dockerfile для Nginx с конфигурацией**

```dockerfile
# Dockerfile.nginx
FROM nginx:alpine

# Удаляем дефолтную конфигурацию
RUN rm /etc/nginx/conf.d/default.conf

# Копируем нашу конфигурацию
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
```

#### **3. Конфигурация Nginx (nginx.conf)**

```nginx
events {
    worker_connections 1024;
}

http {
    upstream dotnet_app {
        server dotnet-app:5000;
    }

    server {
        listen 80;
        
        location / {
            proxy_pass http://dotnet_app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Для health check от Load Balancer
        location /health {
            proxy_pass http://dotnet_app/health;
            access_log off;
        }
    }
}
```

### **Этап 2: Ansible Playbook для развертывания на ВМ**

Теперь модифицируем ваш Ansible Playbook для установки Docker и запуска контейнеров:

```yaml
# deploy-app.yml
- name: Deploy .NET App and Nginx in Docker containers
  hosts: all
  become: yes
  vars:
    dotnet_image: "cr.yandex/your-registry/dotnet-app:latest"
    nginx_image: "cr.yandex/your-registry/nginx:latest"
    db_connection_string: "Host=your-pg-host;Database=your-db;Username=your-user;Password=your-password"

  tasks:
    - name: Install Docker dependencies
      apt:
        name:
          - apt-transport-https
          - ca-certificates
          - curl
          - gnupg
          - lsb-release
        state: present
        update_cache: yes

    - name: Add Docker GPG key
      apt_key:
        url: https://download.docker.com/linux/ubuntu/gpg
        state: present

    - name: Add Docker repository
      apt_repository:
        repo: "deb [arch=amd64] https://download.docker.com/linux/ubuntu {{ ansible_distribution_release }} stable"
        state: present

    - name: Install Docker Engine
      apt:
        name:
          - docker-ce
          - docker-ce-cli
          - containerd.io
        state: present
        update_cache: yes

    - name: Install Docker Compose
      get_url:
        url: https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-linux-x86_64
        dest: /usr/local/bin/docker-compose
        mode: '0755'

    - name: Start and enable Docker service
      systemd:
        name: docker
        state: started
        enabled: yes

    - name: Create application directory
      file:
        path: /opt/app
        state: directory
        mode: '0755'

    - name: Copy Docker Compose file
      template:
        src: docker-compose.yml.j2
        dest: /opt/app/docker-compose.yml

    - name: Login to Container Registry
      community.docker.docker_login:
        registry: cr.yandex
        username: iam
        password: "{{ yc_iam_token }}"

    - name: Pull latest images
      community.docker.docker_compose:
        project_src: /opt/app
        pull: yes

    - name: Stop and remove existing containers
      community.docker.docker_compose:
        project_src: /opt/app
        state: absent

    - name: Start containers
      community.docker.docker_compose:
        project_src: /opt/app
        state: present
        restarted: yes
        recreate: always

    - name: Enable Docker Compose service
      systemd:
        name: docker
        daemon_reload: yes
```

#### **Шаблон Docker Compose (docker-compose.yml.j2)**

```yaml
version: '3.8'
services:
  nginx:
    image: {{ nginx_image }}
    ports:
      - "80:80"
    depends_on:
      - dotnet-app
    restart: unless-stopped
    networks:
      - app-network

  dotnet-app:
    image: {{ dotnet_image }}
    environment:
      - ASPNETCORE_URLS=http://+:5000
      - ConnectionStrings__DefaultConnection={{ db_connection_string }}
    restart: unless-stopped
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

### **Этап 3: CI/CD Pipeline для сборки образов**

Добавим pipeline для автоматической сборки (пример для GitHub Actions):

```yaml
name: Build and Push Docker Images

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Build .NET app
      run: |
        dotnet publish -c Release -o published
        
    - name: Build and push .NET image
      uses: docker/build-push-action@v4
      with:
        context: .
        file: Dockerfile.dotnet
        push: true
        tags: cr.yandex/your-registry/dotnet-app:latest
        secrets: |
          "docker-password=${{ secrets.YC_IAM_TOKEN }}"
          
    - name: Build and push nginx image
      uses: docker/build-push-action@v4
      with:
        context: .
        file: Dockerfile.nginx
        push: true
        tags: cr.yandex/your-registry/nginx:latest
        secrets: |
          "docker-password=${{ secrets.YC_IAM_TOKEN }}"
```

### **Итоговый процесс развертывания:**

1. **Сборка образов**: CI/CD автоматически собирает образы при изменении кода
2. **Подготовка инфраструктуры**: Создаются ВМ через Instance Group
3. **Развертывание**: Ansible Playbook устанавливает Docker и запускает контейнеры
4. **Обновление**: Для обновления приложения достаточно пересобрать образы и перезапустить контейнеры через Ansible

Такой подход соответствует best practices и обеспечивает воспроизводимость развертывания.
