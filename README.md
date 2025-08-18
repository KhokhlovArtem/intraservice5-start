# Migration

### 1. **Подготовка исходной базы данных на Windows Server**
   - **Создайте дамп базы данных**:
     ```sh
     pg_dump -U username -h localhost -p 5432 -F c -b -v -f "./db_backup.dump" dbname
     ```
     - `-F c` — формат custom (бинарный, лучше для восстановления).
     - `-b` — сохраняет большие объекты.
     - `-v` — подробный вывод.

### 2. **Перенос дампа в Yandex Cloud**
   - **Восстановление из дампа**:
     1. Подключаемся к инстансу
        ```sh
        psql -h localhost -p 5432 -d intra5test -U postgres
        ```
     3. Создайте целевую БД:
        ```sql
        CREATE DATABASE new_db;
        ```
     4. Восстановите данные:
        ```sh
        pg_restore -U username -h <yandex-cluster-host> -p 6432 -d new_db -v db_backup.dump --no-owner
        ```
        - Порт **6432** — стандартный для Managed PostgreSQL.

### 4. **Проверка и настройка**
   - **Тестовые запросы**:
     ```sql
     SELECT count(*) FROM your_large_table;
     ```
   - **Настройте пользователей и права**:
     ```sql
     GRANT ALL PRIVILEGES ON DATABASE new_db TO app_user;
     ```
   - **Обновите строки подключения** в приложении.

### 5. **Дополнительные настройки**
   - **Резервное копирование**: Включите автоматические бэкапы в настройках кластера.
   - **Мониторинг**: Настройте алерты в **Yandex Monitoring**.

### Возможные проблемы:
1. **Ограничение на подклоючение**:
   - проверить файл pg_hcb.conf
2. Ограничения Managed PostgreSQL
   - Проверить включенные расширения и включить их в Managed PostgreSQL в настройках кластера.
список расширений:
```sql
SELECT extname FROM pg_extension;
```

Для переноса больших баз (от 100 ГБ) рассмотрите вариант с **логической репликацией** или **yc-transfer**.


### Link
https://intraservice.ru/support/
