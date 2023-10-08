# sre-lab01

namespace: sre-cource-student-81
compute cloud: Проект для студента vergorun


##Пререквезиты: 
 - на хост-деплоер установлены ansible, kubectl, helm
 - развернуты ВМ в МТС Compute Cloud (1core, 1GBram). Для ВМ, которая будет выполнять роль LoadBalancer, выделен публичный IP-адрес для доступа из кластера Kubernetes к DB (ввиду ограничений среды и невозможности организовать связность вне паблик-сети).

```
91.185.85.11 lb-pub.sre.lab
10.0.10.6 lb-pvt.sre.lab
10.0.10.6 etcd3-pvt.sre.lab
10.0.10.5 etcd2-pvt.sre.lab
10.0.10.4 etcd1-pvt.sre.lab
10.0.10.3 db2-pvt.sre.lab
10.0.10.2 db1-pvt.sre.lab
```
Роль балансирощика и ноды etcd совмещены на одном хосте
 - сгенерированы SSH-ключи, открытый ключ и пользователь указаны в конфигурации ВМ
 - управление ВМ и запуск ansible playbook выполняется с внешнего хоста администратора. ВМ с ролью LoadBalancer используются для организации SSH-туннелей, для доступа требуется добавить в ~/.ssh/config записи вида
```
Host bastion
   User mcuser
   Hostname lb-pub.sre.lab
   IdentityFile ~/.ssh/id_ed25519_mc_lab

Host *-pvt.sre.lab
   ProxyJump bastion
```
и внести записи в DNS (путем правки /etc/hosts) на хосте-деплоере (локальной машине). На ВМ необходимые записи добавятся из конфигурации **vars/system.yml** при исполении playbook.
 - полученный kubeconfig активирован для доступа к namespace кластера Kubernetes 
 - Общая схема стенда

![lab1](https://github.com/vergorun/sre-lab01/assets/36616396/8cd43c47-2771-4fef-ab04-75f9946dff62)

## Деплой приложения в Kubernetes
- Проверить значения в *app/values.yaml*
- Применить Helm-Chart
```
helm install srecourseapi ./app
```
- Проверить, что приложение стартовало (*kubectl get pods, kubectl get svc, kubectl describe pods, kubectl logs <pod_id>*)
- Проверить доступ к swagger-ui (http://app.pub.sre.lab/swagger/index.html, при наличии статической записи для app.pub.sre.lab в DNS)
## Развертывание кластера PostgreSQL
- Проверить значения в *postgresql_cluster/vars/main.yml, postgresql_cluster/vars/system.yml*
- Применить playbook
```
ansible-playbook deploy_pgcluster.yml
```

После развертывания базы и инициализации кластера проверить доступ к API приложения
```
curl --location 'http://91.185.85.213/WeatherForecast' --header 'Host: app.pub.sre.lab'
```
![get_api](https://github.com/vergorun/sre-lab01/assets/36616396/10ce8bce-6836-4bbd-ba00-7772286d7da1)

## Удаление приложения из Kubernetes
- Применить Helm-Chart
```
helm uninstall srecourseapi
```

## Удаление кластера PostgreSQL (включая БД и конфигурации приложений)
- Применить playbook
```
ansible-playbook remove_cluster.yml
```

## Комментарий автора :)

- Ansible-роль на основе https://github.com/vitabaks/postgresql_cluster/, убрана часть неиспользуемых опций вместе с ролями (*backup, pgbouncer, consul и т.д.)
- Ограничение на debian-подобные ОС (на redhat-подобных не тестировал, поэтому убрал)
- Добавлена опция init_sql в *postgresql_cluster/vars/main.yml* и таски по инициализации базы с тестовой записью из файла при деплое.
