## requirements
```on client
sudo adduser deploy
sudo usermod -aG sudo deploy
```

```sudo visudo
deploy ALL=(ALL) NOPASSWD:ALL
```

```
cat ~/.ssh/id_rsa.pub
ssh deploy@server_ip_address 'mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys'
```


```ansible
python3 -m venv ansible-venv
source ansible-venv/bin/activate
pip install --upgrade pip setuptools wheel
pip install ansible
```
### Инструкция по использованию:

1. Предполагается наличие развернутого PostgresSQL
2. Скопируйте  `.env.yml.example` в файл `.env.yml` и заполните своими значениями
```bash
cp .env.yml.example .env.yml
```
3. Скопируйте  `your_inventory_file.yml.example` в файл `your_inventory_file.yml` и заполните своими значениями или используйте свой inventory файл
```bash
cp your_inventory_file.yml.example your_inventory_file.yml
```
4. Скопируйте архивы `intraservice.zip` и `intraservice.agent.zip` в `/tmp/intraservice-install/` на целевом сервере
```
ansible-playbook -i your_inventory_file.yml ansible-download-intraservice.yml --extra-vars "@.env.yml"
```
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

7. install services

```bash
   ansible-playbook -i your_inventory_file.yml ansible-intraservice-systemd.yml --extra-vars "@.env.yml"
```

9. Clean temp files 

```bash
   ansible-playbook -i your_inventory_file.yml ansible-intraservice-clean.yml --extra-vars "@.env.yml"
```
### Playbook order

```Playbook order

   ansible-playbook -i your_inventory_file.yml ansible-download-intraservice.yml --extra-vars "@.env.yml"
   ansible-playbook -i your_inventory_file.yml ansible-intraservice-nginx-deploy.yml
   ansible-playbook -i your_inventory_file.yml ansible-asp-net-6-install-binary.yml   
   ansible-playbook -i your_inventory_file.yml ansible-intraservice-site-setup.yml --extra-vars "@.env.yml"
   ansible-playbook -i your_inventory_file.yml ansible-intraservice-systemd.yml --extra-vars "@.env.yml"
   ansible-playbook -i your_inventory_file.yml ansible-intraservice-clean.yml --extra-vars "@.env.yml"
   
```

### Примечания:
- Для работы с шаблонами appsettings.json может потребоваться дополнительная настройка в зависимости от полной структуры ваших конфигурационных файлов
- Убедитесь, что у вас есть доступ к репозиториям Microsoft для установки .NET 6 runtime
- asp.net 6 не поддерживается -> можно использовать установку binary
