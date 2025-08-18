### Инструкция по использованию:

1. Сохраните playbook как `intraservice_nginx_setup.yml`
2. Сохраните шаблон как `appsettings.json.j2` в той же директории
3. Создайте файл `.env` и заполните своими значениями
4. Скопируйте архивы `intraservice.zip` и `intraservice.agent.zip` уже находятся в `/tmp/intraservice-install/` на целевом сервере
5. Запустите playbook командой:
   ```bash
   ansible-playbook -i your_inventory_file intraservice_nginx_setup.yml --extra-vars "@.env"
   ```

### Примечания:
- Для работы с шаблонами appsettings.json может потребоваться дополнительная настройка в зависимости от полной структуры ваших конфигурационных файлов
- Убедитесь, что у вас есть доступ к репозиториям Microsoft для установки .NET 6 runtime
- Для работы с PostgreSQL может потребоваться дополнительная настройка SSL в connection string
