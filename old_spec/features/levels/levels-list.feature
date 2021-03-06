# language: ru

Функционал: Список заданий в игре
  Для удобства навигации и поиска информации в готовящейся игре
  Авторам игры нужно дать возможность просматривать списки уже внесённых в игры заданий

  Предыстория:
    Допустим пользователем Iv создана игра "Котлованы Бишкека"    
    И Iv добавляет задание "Общий старт" в игру "Котлованы Бишкека"
    И Iv добавляет задание "Обед" в игру "Котлованы Бишкека"

  Сценарий: Автор игры видит список её заданий
    Если я захожу в профиль игры "Котлованы Бишкека"
    То должен увидеть "Общий старт"
    И должен увидеть "Обед"
  
  Сценарий: Другие пользователи не видят списка заданий в профиле игры
    Допустим я зарегистрирован как Alisa
    Если я захожу в профиль игры "Котлованы Бишкека"
    То не должен видеть "Общий старт"
    И не должен видеть "Обед"