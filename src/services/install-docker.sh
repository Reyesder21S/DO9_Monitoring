#!/bin/bash

echo "=== Установка Docker и Docker Compose ==="

# Установка Docker
sudo apt-get update
sudo apt-get install -y docker.io

# Установка Docker Compose
sudo apt-get install -y docker-compose

# Настройка
sudo systemctl enable docker
sudo systemctl start docker

# Добавляем пользователя vagrant в группу docker
sudo usermod -aG docker vagrant

# Применяем изменения группы без перелогина
sudo su - vagrant -c "newgrp docker" || true

# Альтернативный метод: меняем разрешения на Docker socket
sudo chmod 666 /var/run/docker.sock 2>/dev/null || true

echo "Готово!"
echo "Docker: $(sudo docker --version)"
echo "Docker Compose: $(docker-compose --version)"