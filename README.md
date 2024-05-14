# Платформа курсов

## Описание базы данных и приложения

### 1. Описание базы данных
База данных предназначена для хранения информации о курсах, студентах, авторах и их прогрессе. Она включает в себя следующие основные таблицы:

- **authors**: содержит информацию об авторах курсов (ID, имя, фамилия, логин, и т.д.).
- **courses**: содержит информацию о курсах (ID, название, описание, цена, автор).
- **students**: содержит информацию о студентах (ID, имя, фамилия, логин, и т.д.).
- **enrollments**: связывает студентов с курсами, на которые они записаны.
- **lessons**: содержит информацию об уроках в каждом курсе.
- **students_progress**: отслеживает прогресс студентов по урокам.
- **responses**: хранит ответы студентов на задания.
![Схема базы данных](https://2.downloader.disk.yandex.ru/preview/5fe3ea6cc03ae7466556e0b79d3d09f3352247261d99512f104ef75b748e6361/inf/-lC2w3XpjqLOe9Yp0aEoDqZzqg_m9StX49O66G_xT5ytiTSdl8F08l3fpvASq3kqZMxM_lA1W3TNtPcgkzp3Gw%3D%3D?uid=366235886&filename=схема.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=366235886&tknv=v2&size=1920x925)

### 1.2 Описание приложения
Приложение предоставляет графический интерфейс для взаимодействия с базой данных. Доступно две роли в соответствии со структурой базы данных (студенты и авторы). Студенты могут просматривать доступные курсы, записываться на них, отмечать выполненные уроки и видеть свой прогресс по каждому курсу. Авторы могут создавать курсы и уроки и редактировать их. Приложение разделено на несколько окон, каждое из которых имеет свои функции.

#### 1.2.1 Окно авторизации
Окно авторизации позволяет пользователям входить в систему, вводя свои учетные данные (логин и пароль).
![Окно авторизации](https://disk.yandex.ru/i/YedbFhw5wx4dfg)

#### 1.2.2 Окно регистрации
Окно регистрации позволяет новым пользователям создавать учетную запись, заполнив необходимые данные.
![Окно регистрации](https://disk.yandex.ru/i/AiQ-QGBvTbGt7A)

#### 1.2.3 Окно редактирования профиля
Окно, позволяющее пользователю редактировать информацию о своем профиле.
![Окно редактирования профиля](https://disk.yandex.ru/i/DwJvWoH87cqhLQ)

#### 1.2.4 Окно главного меню авторах
Главное окно, отображающее основную информацию о пользователе (авторе) и список его курсов. Также предоставляет функции для добавления нового курса, редактирования профиля и выхода из системы.
![Окно главного меню автора](https://disk.yandex.ru/i/EDNjSRGVU13p0A)

#### 1.2.4 Окно создания курса
Окно, позволяющее автору добавить новый курс, заполнив поля для названия, описания и цены курса.
![Окно создания курса](https://disk.yandex.ru/i/mlTPo4h-AbMDcA)

#### 1.2.4 Окно редактирования курса
Окно, позволяющее автору редактировать информацию о выбранном курсе и управлять уроками.
![Окно редактирования курса](https://disk.yandex.ru/i/QlFm4V5d4FzpkA)
![Добавление урока](https://disk.yandex.ru/i/TILtSgusZC3nsg)
