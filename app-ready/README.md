### Инструкция по использованию:

1. Предполагается наличие развернутого PostgresSQL
2. Скопируйте  `.env.yml.example` в файл `.env.yml` и заполните своими значениями
3. Скопируйте  `your_inventory_file.yml.example` в файл `your_inventory_file.yml` и заполните своими значениями или используйте свой inventory файл
4. (Опция) Скопируйте архивы `intraservice.zip` и `intraservice.agent.zip` в `/tmp/intraservice-install/` на целевом сервере
5. Pre-install asp.net

```bash
   ansible-playbook -i your_inventory_file.yml ansible-asp-net-6-install-binary.yml
```
6. Pre-install nginx
   
```bash
   ansible-playbook -i your_inventory_file.yml ansible-intraservice-nginx-deploy.yml
```
7. install website-instraservice

```bash
   ansible-playbook -i your_inventory_file.yml ansible-intraservice-site-setup.yml --extra-vars "@.env.yml"
```
### Playbook order

```bash
   ansible-playbook -i your_inventory_file.yml ansible-intraservice-nginx-deploy.yml
   ansible-playbook -i your_inventory_file.yml ansible-asp-net-6-install-binary.yml   
   ansible-playbook -i your_inventory_file.yml ansible-intraservice-site-setup.yml --extra-vars "@.env.yml"
   
```

### Примечания:
- Для работы с шаблонами appsettings.json может потребоваться дополнительная настройка в зависимости от полной структуры ваших конфигурационных файлов
- Убедитесь, что у вас есть доступ к репозиториям Microsoft для установки .NET 6 runtime
- asp.net 6 не поддерживается -> можно использовать установку binary
