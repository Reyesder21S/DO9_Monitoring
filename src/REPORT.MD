## Part 1. Получение метрик и логов

1. Использовать Docker Swarm из первого проекта.

2. Написать при помощи библиотеки Micrometer сборщики следующих метрик приложения:

В файл pom.xml каждого сервиса добавил:

![](images/part_1.png)

Actuator — это модуль Spring Boot, который добавляет в приложение возможности производственного мониторинга и управления. Он предоставляет готовые эндпоинты (endpoints) для получения информации о работающем приложении.

Micrometer — это фасад для сбора метрик. Он поддерживает множество систем мониторинга. Данная конкретная зависимость добавляет поддержку Prometheus

В application.properties добавил:

![](images/part_1.1.png)

Actuator configuration - Открывает доступ к указанным эндпоинтам.

Micrometer configuration - Включает экспорт метрик в формате Prometheus.

Add common tags for Prometheus - Добавляет эти теги ко всем метрикам приложения.

- количество отправленных сообщений в rabbitmq;

В класс QueueProducer.java booking-service добавил:

![](images/part_1.2.png)

- количество обработанных сообщений в rabbitmq;

В QueueConsumer.java report-service так же добавил:

![](images/part_1.3.png)

- количество бронирований;

В класс BookingServiceImplementation.java добавлен счётчик:

![](images/part_1.4.png)
![](images/part_1.5.png)
![](images/part_1.6.png)

- количество полученных запросов на gateway;

В src/services/gateway-service/src/main/java/com/s21/devops/sample/gatewayservice/Controller/GatewayController.java добавил:

![](images/part_1.7.png)

В каждый метод добавил gatewayRequestsCounter.increment(), который увеличивает значение счетчика на 1 и этим регистрирует факт обращения к gateway сервису.

![](images/part_1.8.png)

- количество полученных запросов на авторизацию пользователей;

В /src/services/session-service/src/main/java/com/s21/devops/sample/sessionservice/Controller/SessionController.java был добавлен счётчик:

![](images/part_1.9.png)

После всех изменений образы были собраны и загружены в DockerHub с тегом 2:

![](images/part_1.10.png)


3. Добавить логи приложения с помощью Loki.

![](images/part_1.11.png)

Loki нужен для централизованного сбора, хранения и анализа логов от всех сервисов и приложений.

4. Создать новый стек для Docker Swarm из сервисов с Prometheus Server, Loki, node_exporter, blackbox_exporter, cAdvisor. Проверить получение метрик на порту 9090 через браузер.

![](images/part_1.12.png)
![](images/part_1.13.png)
![](images/part_1.14.png)
![](images/part_1.15.png)


Node Exporter: Метрики операционной системы (хоста/ноды).

cAdvisor: Метрики контейнеров Docker.

Blackbox Exporter: Проверка доступности эндпоинтов извне.

Promtail: Агент для сбора логов и отправки их в Loki.

### Запуск стеков сервисов:

Был изменён файл docker-compose.yml:
![](images/part_1.18.png)

С помощью Vagrant были запущены 3 виртуальные машины и выполнен вход на manager. Созданы сети app-network и monitoring для стеков.
Развернут стек микросервисов приложения:

![](images/part_1.19.png)
![](images/part_1.20.png)


Развернут стек мониторинга:

![](images/part_1.21.png)

Все сервисы:

![](images/part_1.22.png)

Метрики на порту 9090:

![](images/part_1.16.png)
![](images/part_1.17.png)


## Part 2. Визуализация

1. Развернуть grafana как новый сервис в стеке мониторинга.

В docker-compose.monitoring.yml добавил:

![](images/part_2.png)

После деплоя Grafana доступен по адресу http://192.168.56.10:3000.
Добавил источники данных:

![](images/part_2.1.png)

2. Добавить в Grafana дашборд со следующими метриками:
   - количество нод;
![](images/part_2.2.png)

   - количество контейнеров;
![](images/part_2.3.png)

   - количество стеков;
![](images/part_2.4.png)

   - использование CPU по сервисам;
![](images/part_2.5.png)
![](images/part_2.6.png)

   - использование CPU по ядрам и узлам;
![](images/part_2.7.png)
![](images/part_2.8.png)

   - затраченная RAM;
![](images/part_2.9.png)

   - доступная и занятая память;
![](images/part_2.10.png)
![](images/part_2.11.png)
![](images/part_2.12.png)

   - количество CPU;
![](images/part_2.13.png)

   - доступность google.com;
![](images/part_2.14.png)

   - количество отправленных сообщений в rabbitmq;
![](images/part_2.15.png)

   - количество обработанных сообщений в rabbitmq;
![](images/part_2.16.png)

   - количество бронирований;
![](images/part_2.17.png)

   - количество полученных запросов на gateway;
![](images/part_2.18.png)

   - количество полученных запросов на авторизацию пользователей;
![](images/part_2.19.png)

   - логи приложения.
![](images/part_2.20.png)

Дашборд:
![](images/part_2.22.png)
![](images/part_2.23.png)


## Part 3. Отслеживание критических событий

1. Развернуть Alert Manager как новый сервис в стеке монтиторинга
В docker-compose.monitoring.yml добавил:
![](images/part_3.1.png)

После перезапуска стека мониторинга:
![](images/part_3.2.png)

Сервис alertmanager доступен по адресу http://192.168.56.10:9093
![](images/part_3.3.png)

2. Добавить следующие критические события:
   - доступная память меньше 100 Мб;
   - затраченная RAM больше 1 Гб;
   - использование CPU по сервису превышает 10%.

Создал файл alerts.yml:
![](images/part_3.4.png)

Добавил в docker-compose.monitoring.yml:
![](images/part_3.png)

Алерты доступны по адресу http://192.168.56.10:9090/alerts:
![](images/part_3.6.png)

3. Настроить получение оповещений через личные email и Телеграм.
Создал файл:
![](images/part_3.5.png)

Перезапустил сервис. С worker02 зашел внутрь Docker контейнера `docker exec -it -u root $(docker ps -q --filter name=gateway) sh`, 
установил stress-ng и запустил:

![](images/part_3.7.png)

Состояние алертов через 2 минуты:
![](images/part_3.8.png)

Уведомления:

![](images/part_3.9.png)
![](images/part_3.10.png)

На worker01 так же установил stress-ng и запустил:

![](images/part_3.12.png)

Состояние:
![](images/part_3.13.png)

Уведомления:

![](images/part_3.14.png)
![](images/part_3.15.png)
