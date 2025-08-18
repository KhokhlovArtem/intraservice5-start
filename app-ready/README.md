### Инструкция по использованию:

1. Сохраните проект на сервер управления
2. Скопируйте  `.env.example` в файл `.env` и заполните своими значениями
3. Укажите свои значения в файле `your_inventory_file` или используйте свой inventory файл
4. (Опция) Скопируйте архивы `intraservice.zip` и `intraservice.agent.zip` в `/tmp/intraservice-install/` на целевом сервере
5. Запустите playbook командой:
   
   ```bash
   ansible-playbook -i your_inventory_file ansible-intraservice-nginx-setup.yml --extra-vars "@.env"
   ```

### Примечания:
- Для работы с шаблонами appsettings.json может потребоваться дополнительная настройка в зависимости от полной структуры ваших конфигурационных файлов
- Убедитесь, что у вас есть доступ к репозиториям Microsoft для установки .NET 6 runtime
- Для работы с PostgreSQL может потребоваться дополнительная настройка SSL в connection string
