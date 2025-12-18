# Статус сервисов
sudo systemctl status intraservice.service intraservice-agent.service

# Логи в реальном времени
sudo journalctl -u intraservice.service -f

# Проверка портов
sudo ss -tlnp | grep -E "5000|5001"

# Проверка HTTP
curl -f http://localhost:5001/
curl -f http://localhost:5000/health