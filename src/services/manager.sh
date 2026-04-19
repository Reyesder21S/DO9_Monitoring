#!/bin/bash
echo "=== Настройка Docker Swarm Manager ==="

# Ждем запуска Docker
sleep 10

# Инициализируем Swarm, если еще не инициализирован
if ! docker swarm join-token worker 2>/dev/null; then
    echo "Инициализация Swarm..."
    docker swarm init --advertise-addr 192.168.56.10
fi

# Сохраняем токен
docker swarm join-token -q worker > /home/vagrant/worker_token
docker swarm join-token -q worker > /vagrant/worker_token

echo "Токен сохранен в /vagrant/worker_token"
echo "Токен: $(cat /vagrant/worker_token)"

# Выводим информацию
echo "=== Состояние кластера ==="
docker node ls