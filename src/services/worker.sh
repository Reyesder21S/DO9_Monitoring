#!/bin/bash
echo "Worker: ожидание токена..."

# Ждем 10 секунд
sleep 10

# Проверяем токен 
if [ -f /vagrant/worker_token ]; then
    echo "✅ Токен найден в /vagrant/worker_token"
    SWARM_TOKEN=$(cat /vagrant/worker_token)
else
    echo "❌ Ошибка: Токен не найден в /vagrant/worker_token"
    echo "Проверьте файлы в /vagrant/:"
    ls -la /vagrant/ | grep -i token
    exit 1
fi

# Присоединяемся к Swarm
echo "Присоединение к Swarm..."
docker swarm join --token $SWARM_TOKEN 192.168.56.10:2377

if [ $? -eq 0 ]; then
    echo "✅ Worker $(hostname) успешно присоединен к Swarm"
else
    echo "❌ Ошибка при присоединении к Swarm"
    exit 1
fi