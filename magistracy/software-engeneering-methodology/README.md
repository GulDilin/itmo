# Методология программной инженерии (Software engineering methodology)

Идея по автоматизации какой-либо выдуманной системы

### Тема: Автоматизация производства передвижных бань на курьих ножках в княжестве Новгородском

[Vision](./vision.pdf)
[Software Requirements Specification](./Software Requirements Specification.pdf)
[Glossary](./Glossary.pdf)
[Risk List](./Risk List.pdf)
[Use Case Specification](./Use Case Specification.pdf)

## Прототип проекта

[Backend](https://github.com/GulDilin/itmo-SEM-back)
[Frontend](https://github.com/GulDilin/itmo-SEM-front)

Используемые технологии (backend):
- Python 3.8 (https://www.python.org/downloads/release/python-3810/)
- FastApi (https://fastapi.tiangolo.com/)
- poetry >= 1.4.1 (https://python-poetry.org/)

- PostgreSQL (https://www.postgresql.org/)
- Docker >= 20.10 (for dev) (https://www.docker.com/)
- Docker compose >= 2.15 (for dev) (https://www.docker.com/)
- Keycloak 20 (https://www.keycloak.org/)

Используемые технологии (frontend):
- Vue js 3 (https://vuejs.org/)
- Vue router (https://router.vuejs.org/)
- Vite (https://vitejs.dev/)
- Tailwindcss (https://tailwindcss.com/)
- Vuetify (https://vuetifyjs.com/en/)


### Идея бизнес процесса

```mermaid
flowchart TD;
    A[Лесоповал] --> B[Доставка для подготовки сруба];
    B --> C[Подготовка брёвен под сруб];
    C  -- Возможно возврат брака --> A;
    C --> E;
    D[Заказ мха для утепления] --> E[Утепление сруба];
    E --> F[Присоединение курьих ножен];
    F --> G[Установка центра управления <br> заколдованной ступы];
    L[Заказ печи] --> T;
    G --> T[Установка печи];
    R[Заказ дверей] --> J;
    T --> J[Установка дверей];
    J --> H[Установка ёмкости для воды];
    H --> O[Наполнение печи камнями];
    O --> U[Добавление опций];
```

### Состав бани

- Сруб
- Мох
- Крыша, кровля
- Скамьи
- Пол
- Лежаки
- Дверь
- Окно
- Печь
- Труба
- Камни
- Емкость для воды
- Курьи ножки
- Ступа заколдованная

Опции

- черпаки
- ведра
- вместимость бани
- размер ступы
- максимальная скорость
- полотенца
- веники
- ящики
- усиленная подвеска для крупных господ
- кол-во окон
- стол

## Лабораторная работа №2


### Разработка бизнес процесса (BPMN диаграмма)
![BPMN](./bpmn.png)

### Описание передаваемых данных
![Данные](./data.png)

### Sequence Diagram
```mermaid
sequenceDiagram
    participant Бани
    participant Лесоповал
    participant Доставка
    participant Йоги
    participant Ремесленники

    Бани ->> Бани: Согласование требований
    par Подготовка сруба
        Бани ->>+ Лесоповал: Заявка на бревна
        Лесоповал -->>- Бани: Подготовленные бревна
        Бани ->>+ Лесоповал: Заявка на сруб
        Лесоповал ->>+ Доставка: Передача сруба
        Доставка -->>- Бани: Подготовленный готовый сруб
    end

    par Подготовка курьих ножен
        Бани ->>+ Йоги: Заявка на курьи ножки
        Йоги -->>- Бани: Готовые Курьи ножки
        Бани ->>+ Йоги: Заявка на ступу
        note right of Йоги: Колдуют
        Йоги -->>- Бани: Готовая ступа
    end

    loop Подготовка изделий
        Бани ->>+ Ремесленники: Заявка на изделие
        Ремесленники -->>- Бани: Готовое изделие
        Бани ->> Бани: Установка изделия
    end

    Бани ->> Бани: Передача заказчику
```
