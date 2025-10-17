# Data Vault для Sample Superstore (Greenplum)

Итоговое задание по модулю 1 (Системы хранения данных).

## Структура проекта

```
DSS_m1_finals/
├── sql/
│   ├── create_tables.sql      # DDL: схема + staging + Data Vault таблицы
│   ├── ingest_from_stg.sql    # Загрузка из staging в DV с хешированием
│   └── 03_validation.sql      # Проверка количества строк
├── ingest_raw_to_stg.py       # Python: загрузка CSV → staging
├── schema_design.svg          # Диаграмма Data Vault
├── .env                       # Креды Greenplum (не в git)
├── requirements.txt           # Python зависимости
├── GOOGLE_DOC.txt             # Отчет для Google Docs
└── SampleSuperstore.csv       # Исходный датасет
```

## Схема данных

- **4 Хаба** - customer, product, location, order
- **3 Линка** - order-customer, order-product, order-location
- **4 Спутника** - атрибуты клиентов, продуктов, локаций, метрики заказов

См. `schema_design.svg`.

## Использовано

- Составные бизнес-ключи (в CSV нет ID)
- Type-2 SCD через `hashdiff`
- Хеширование MD5 через `md5()` и `decode()`
- Загрузка в STG-таблицу из CSV через мастер-ноду 