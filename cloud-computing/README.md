# Облачные и туманные вычисления

## Проект: Хранилище результатов автотестов

### Концепт

Cервис организованного сбора и статистики для отчетов по автотестам с возможностью
анализа итоговых данных.
Описание возможностей системы:
• сохранение данных с различных автотестов
• аггрегация данных
• вывод статистики
• анализ с помощью графиков 

### Компоненты системы и выбор облака

Решено было использовать облачное решение от Amazon, так как это популярное и
гибкое решение и в нём я нашёл все необходимые мне возможности.

- **БД (Mongo DB)** было найдено несколько возможных решений, либо вручную поднять
экземпляр виртуальной машины и на нём запустить Mongo DB, либо воспользоваться
аналогом от Amazon, под названием Amazon DocumentDB, которая совместима с
MongoDB
- **Веб сервис апи (сбор статистики)** я решил использовать EC2 Environment, на котором
будет настроено виртуальное окружение. Гибкость этого решения позволяет обеспечить
бесшовный деплой, с помощью нескольких экземпляров виртуального окружения, из
которых прошлая задеплоенная версия останавливается только после запуска новой и
прохождения проверок.
- Также при необходимости есть возможность настроить scaling (AWS Auto Scaling) и load-
balancer (Amazon Lightsail) для использования нескольких экземпляров веб сервиса и
автоматической работе в случае пиковых нагрузок
- **Prometheus** предполагается использовать Amazon Prometheus
- **Grafana** предполагается использовать Amazon Grafana
- В качестве **брокера очередей** я решил воспользоваться Amazon SQS решением.
Изначально я предполагал использовать RabbitMQ, но решил что интереснее будет
воспользоваться и настроить решение от Amazon, которое в том числе предоставяет тип
очередей FIFO, который я и планировал использовать
- Для **фронтенда** я решил использовать S3 bucket в связке с CloudFront, который будет
выступать в качестве cdn для быстрой работы
