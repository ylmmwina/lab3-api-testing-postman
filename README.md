# Лабораторна робота 3

## Комплексне тестування REST API із використанням Postman

---

## 1. Тема роботи

Комплексне тестування REST API із використанням Postman.

---

## 2. Мета роботи

Метою лабораторної роботи є реалізація комплексного тестування REST API, що включає:

- функціональне тестування;
- перевірку структури даних;
- JSON Schema Validation;
- data-driven тестування;
- workflow / end-to-end тестування;
- pre-request scripts;
- негативне тестування;
- перевірку продуктивності;
- логування;
- автоматизацію запуску через Newman;
- контрактне тестування;
- аналіз стабільності;
- розрахунок метрик якості API.

---

## 3. API, що тестується

Для тестування використано сервіс:

```text
https://jsonplaceholder.typicode.com
```

JSONPlaceholder — це тестовий fake REST API, який використовується для навчання та перевірки HTTP-запитів.

Важлива особливість сервісу:

> JSONPlaceholder імітує виконання `POST`, `PUT`, `PATCH`, `DELETE`, але не зберігає зміни реально на сервері.

Тому у workflow-тестах враховано, що після `POST`, `PUT` або `DELETE` дані можуть не змінюватися при наступному `GET`.

---

## 4. Структура репозиторію

```text
lab3-api-testing-postman/
│
├── data/
│   ├── posts_data.csv
│   └── posts_data.json
│
├── postman/
│   ├── Lab3_JSONPlaceholder.postman_collection.json
│   └── Lab3_JSONPlaceholder.postman_environment.json
│
├── reports/
│   ├── newman-report.html
│   ├── newman-report.json
│   ├── newman-run-1.json
│   ├── newman-run-2.json
│   ├── newman-run-3.json
│   ├── newman-run-4.json
│   └── newman-run-5.json
│
├── scripts/
│   └── run_newman.sh
│
├── .gitignore
├── package-lock.json
├── package.json
└── README.md
```

---

## 5. Використані інструменти

У роботі використано:

- Postman;
- Newman;
- Node.js;
- npm;
- Git;
- GitHub;
- WebStorm;
- JSONPlaceholder API.

---

## 6. Postman Environment

Було створено Postman Environment:

```text
Lab3 JSONPlaceholder Environment
```

Файл:

```text
postman/Lab3_JSONPlaceholder.postman_environment.json
```

### Змінні середовища

| Змінна | Значення | Призначення |
|---|---|---|
| `base_url` | `https://jsonplaceholder.typicode.com` | базова адреса API |
| `post_id` | `1` | ID поста для GET / PUT / DELETE |
| `user_id` | `1` | ID користувача |
| `max_response_time` | `1000` | максимально допустимий час відповіді, мс |
| `content_type` | `application/json; charset=utf-8` | очікуваний Content-Type |
| `created_post_id` | динамічне значення | ID, отриманий після POST-запиту |
| `random_title` | динамічне значення | випадково згенерований title |
| `random_body` | динамічне значення | випадково згенерований body |

Усі основні запити використовують змінну:

```text
{{base_url}}
```

Приклад:

```text
{{base_url}}/posts
```

---

## 7. Організація Postman Collection

Було створено Postman Collection:

```text
Lab3 JSONPlaceholder API Tests
```

Файл:

```text
postman/Lab3_JSONPlaceholder.postman_collection.json
```

Колекція організована за трьома основними групами:

```text
Functional tests
Negative tests
Workflow
```

Така структура відповідає вимогам лабораторної роботи.

---

## 8. Functional tests

У групі `Functional tests` реалізовано такі запити:

| № | Назва запиту | Метод | Endpoint |
|---|---|---|---|
| 1 | `GET /posts - verify list of posts` | GET | `/posts` |
| 2 | `GET /posts - JSON Schema validation` | GET | `/posts` |
| 3 | `POST /posts - data driven create post` | POST | `/posts` |
| 4 | `POST /posts - create post with random data` | POST | `/posts` |

---

## 9. Перевірка GET /posts

Запит:

```http
GET {{base_url}}/posts
```

У тесті перевіряється:

- статус відповіді;
- `Content-Type`;
- час відповіді;
- що тіло відповіді є масивом;
- мінімальна кількість елементів;
- структура кожного об’єкта;
- типи полів.

### Очікуваний статус

```text
200 OK
```

### Очікуваний Content-Type

```text
application/json; charset=utf-8
```

### Очікувана структура об’єкта post

```json
{
  "userId": 1,
  "id": 1,
  "title": "string",
  "body": "string"
}
```

### Перевірені поля

| Поле | Очікуваний тип |
|---|---|
| `userId` | number |
| `id` | number |
| `title` | string |
| `body` | string |

---

## 10. JSON Schema Validation

Для endpoint:

```http
GET {{base_url}}/posts
```

було створено JSON Schema для об’єкта `post`.

Схема перевіряє:

- що відповідь є масивом;
- що кожен елемент масиву є об’єктом;
- що кожен об’єкт має обов’язкові поля;
- що типи полів відповідають очікуваним.

### JSON Schema для post

```javascript
const postSchema = {
    type: 'object',
    required: ['userId', 'id', 'title', 'body'],
    properties: {
        userId: { type: 'number' },
        id: { type: 'number' },
        title: { type: 'string' },
        body: { type: 'string' }
    },
    additionalProperties: false
};
```

### JSON Schema для масиву posts

```javascript
const postsSchema = {
    type: 'array',
    minItems: 1,
    items: postSchema
};
```

Перевірка виконується за допомогою:

```javascript
pm.expect(posts).to.have.jsonSchema(postsSchema);
```

---

## 11. Data-driven тестування

Для data-driven тестування використано POST-запит:

```http
POST {{base_url}}/posts
```

Запит використовує зовнішні файли з тестовими даними:

```text
data/posts_data.json
data/posts_data.csv
```

---

### 11.1 JSON data file

Файл:

```text
data/posts_data.json
```

Приклад структури:

```json
[
  {
    "title": "Postman data driven test title 1",
    "body": "Postman data driven test body 1",
    "userId": 1
  },
  {
    "title": "Postman data driven test title 2",
    "body": "Postman data driven test body 2",
    "userId": 2
  },
  {
    "title": "Postman data driven test title 3",
    "body": "Postman data driven test body 3",
    "userId": 3
  }
]
```

---

### 11.2 CSV data file

Файл:

```text
data/posts_data.csv
```

Приклад структури:

```csv
title,body,userId
Postman CSV title 1,Postman CSV body 1,1
Postman CSV title 2,Postman CSV body 2,2
Postman CSV title 3,Postman CSV body 3,3
```

---

### 11.3 Тіло POST-запиту

```json
{
  "title": "{{title}}",
  "body": "{{body}}",
  "userId": {{userId}}
}
```

Під час запуску Newman значення `title`, `body` та `userId` підставляються з JSON або CSV-файлу.

---

### 11.4 Перевірки data-driven POST

У тесті перевіряється:

- статус відповіді `201 Created`;
- час відповіді;
- наявність поля `id`;
- відповідність `title` переданим тестовим даним;
- відповідність `body` переданим тестовим даним;
- відповідність `userId` переданим тестовим даним.

---

## 12. Pre-request Script

У запиті:

```text
POST /posts - create post with random data
```

використано Pre-request Script.

Його завдання:

- згенерувати випадковий `title`;
- згенерувати випадковий `body`;
- зберегти ці значення у змінні середовища;
- використати їх у тілі POST-запиту.

### Pre-request Script

```javascript
const randomNumber = Math.floor(Math.random() * 100000);
const randomTitle = `Generated title ${randomNumber}`;
const randomBody = `Generated body text ${randomNumber}`;

pm.environment.set('random_title', randomTitle);
pm.environment.set('random_body', randomBody);

console.log('Generated random title:', randomTitle);
console.log('Generated random body:', randomBody);
```

### Тіло запиту з випадковими даними

```json
{
  "title": "{{random_title}}",
  "body": "{{random_body}}",
  "userId": {{user_id}}
}
```

### Перевірки

У тесті перевіряється:

- статус `201 Created`;
- час відповіді;
- що відповідь містить згенерований `title`;
- що відповідь містить згенерований `body`;
- що відповідь містить очікуваний `userId`;
- що відповідь містить згенерований `id`.

---

## 13. Workflow testing

Було реалізовано end-to-end сценарій:

```text
POST → GET → PUT → GET → DELETE → GET
```

Група в колекції:

```text
Workflow
```

---

### 13.1 Кроки workflow

| № | Назва запиту | Метод | Endpoint |
|---|---|---|---|
| 1 | `Workflow 01 - POST /posts create post` | POST | `/posts` |
| 2 | `Workflow 02 - GET /posts/{{post_id}} read existing post` | GET | `/posts/{{post_id}}` |
| 3 | `Workflow 03 - PUT /posts/{{post_id}} update post` | PUT | `/posts/{{post_id}}` |
| 4 | `Workflow 04 - GET /posts/{{post_id}} after PUT` | GET | `/posts/{{post_id}}` |
| 5 | `Workflow 05 - DELETE /posts/{{post_id}}` | DELETE | `/posts/{{post_id}}` |
| 6 | `Workflow 06 - GET /posts/{{post_id}} after DELETE` | GET | `/posts/{{post_id}}` |

---

### 13.2 Збереження ID у змінну

Після POST-запиту ID створеного ресурсу зберігається у змінну:

```javascript
pm.environment.set('created_post_id', responseJson.id);
```

Також для роботи з існуючим ресурсом використовується змінна:

```text
{{post_id}}
```

---

### 13.3 Особливість workflow для JSONPlaceholder

JSONPlaceholder не зберігає реально створені, оновлені або видалені ресурси.

Тому:

- після `POST` ресурс отримує `id`, але не стає доступним через наступний `GET`;
- після `PUT` відповідь містить оновлені дані, але наступний `GET` повертає старі дані;
- після `DELETE` сервер повертає успішну відповідь, але наступний `GET` все ще може повертати ресурс.

Це не є помилкою тестів. Це особливість fake API.

---

## 14. Negative tests

У групі `Negative tests` реалізовано такі перевірки:

| № | Назва запиту | Метод | Endpoint |
|---|---|---|---|
| 1 | `NEG 01 - GET non-existing post` | GET | `/posts/999999` |
| 2 | `NEG 02 - POST /posts with invalid data` | POST | `/posts` |
| 3 | `NEG 03 - PUT /posts with wrong ID` | PUT | `/posts/999999` |
| 4 | `NEG 04 - DELETE non-existing post` | DELETE | `/posts/999999` |

---

### 14.1 GET неіснуючого ресурсу

Запит:

```http
GET {{base_url}}/posts/999999
```

Очікувана поведінка:

```text
404 Not Found
```

Мета тесту — перевірити реакцію API на запит ресурсу, якого не існує.

---

### 14.2 POST з некоректними даними

Запит:

```http
POST {{base_url}}/posts
```

Тіло запиту містить некоректні типи даних:

```json
{
  "title": 12345,
  "body": true,
  "userId": "invalid-user"
}
```

Фактична поведінка JSONPlaceholder:

```text
201 Created
```

Це означає, що API не виконує сувору серверну валідацію типів для POST-запиту.

---

### 14.3 PUT з неправильним ID

Запит:

```http
PUT {{base_url}}/posts/999999
```

Мета тесту — перевірити поведінку API при оновленні ресурсу з неправильним або неіснуючим ID.

---

### 14.4 DELETE неіснуючого ресурсу

Запит:

```http
DELETE {{base_url}}/posts/999999
```

Мета тесту — перевірити поведінку API при видаленні ресурсу, якого не існує.

JSONPlaceholder може повертати успішний статус навіть для такого запиту, оскільки це fake API.

---

## 15. Перевірка продуктивності

У більшості тестів додано перевірку часу відповіді:

```javascript
pm.expect(pm.response.responseTime).to.be.below(maxResponseTime);
```

Значення `maxResponseTime` береться зі змінної середовища:

```text
max_response_time = 1000
```

Отже, очікується, що кожен основний запит виконається швидше ніж за:

```text
1000 мс
```

---

## 16. Логування

У тестах використано логування через:

```javascript
console.log();
```

У консоль виводяться:

- HTTP-статус відповіді;
- response time;
- ID створеного або отриманого поста;
- userId;
- title;
- body;
- згенеровані випадкові значення;
- особливості поведінки API.

Приклади логування:

```javascript
console.log('Status:', pm.response.code);
console.log('Response time:', pm.response.responseTime);
console.log('Created post id:', responseJson.id);
console.log('Generated random title:', randomTitle);
```

---

## 17. Контрактне тестування

Контрактне тестування реалізовано через порівняння очікуваної та фактичної структури відповіді.

Перевіряється:

- наявність обов’язкових полів;
- типи полів;
- значення полів;
- відповідність JSON Schema;
- відповідність відповіді даним, які були передані в запит.

---

### 17.1 Обов’язкові поля

Для об’єкта `post` обов’язковими є поля:

```text
userId
id
title
body
```

---

### 17.2 Очікувані типи

| Поле | Очікуваний тип |
|---|---|
| `userId` | number |
| `id` | number |
| `title` | string |
| `body` | string |

---

### 17.3 Expected vs Actual

Для POST-запитів перевіряється відповідність переданих даних фактичній відповіді.

Приклад:

```javascript
pm.expect(responseJson.title).to.eql(pm.iterationData.get('title'));
pm.expect(responseJson.body).to.eql(pm.iterationData.get('body'));
pm.expect(Number(responseJson.userId)).to.eql(Number(pm.iterationData.get('userId')));
```

---

## 18. Автоматизація через Newman

Для автоматизації запуску тестів використано Newman.

---

### 18.1 Встановлення залежностей

```bash
npm install
```

---

### 18.2 Звичайний запуск колекції

```bash
npm test
```

Ця команда запускає колекцію з environment без зовнішнього data file.

---

### 18.3 Запуск з JSON data file

```bash
npm run test:data:json
```

Ця команда запускає колекцію з файлом:

```text
data/posts_data.json
```

---

### 18.4 Запуск з CSV data file

```bash
npm run test:data:csv
```

Ця команда запускає колекцію з файлом:

```text
data/posts_data.csv
```

---

### 18.5 Генерація HTML та JSON звіту

```bash
npm run report
```

Після виконання команди створюються файли:

```text
reports/newman-report.html
reports/newman-report.json
```

---

### 18.6 Аналіз стабільності

```bash
npm run stability
```

Ця команда запускає колекцію 5 разів.

Після виконання створюються файли:

```text
reports/newman-run-1.json
reports/newman-run-2.json
reports/newman-run-3.json
reports/newman-run-4.json
reports/newman-run-5.json
```

---

## 19. Newman reports

У результаті виконання Newman було згенеровано такі звіти:

| Файл | Призначення |
|---|---|
| `reports/newman-report.html` | HTML-звіт для перегляду результатів |
| `reports/newman-report.json` | JSON-звіт з детальними результатами |
| `reports/newman-run-1.json` | звіт першого stability-запуску |
| `reports/newman-run-2.json` | звіт другого stability-запуску |
| `reports/newman-run-3.json` | звіт третього stability-запуску |
| `reports/newman-run-4.json` | звіт четвертого stability-запуску |
| `reports/newman-run-5.json` | звіт п’ятого stability-запуску |

---

## 20. Аналіз стабільності

Для аналізу стабільності колекція запускалася 5 разів.

Оцінювалися такі показники:

- стабільність HTTP-статусів;
- кількість помилок;
- середній response time;
- мінімальний response time;
- максимальний response time;
- стандартне відхилення response time;
- наявність нестабільних відповідей.

---

### 20.1 Очікуваний результат stability-запуску

Очікується, що:

- усі запити виконуються без network errors;
- усі assertions проходять успішно;
- response time не перевищує `1000 мс`;
- API повертає стабільні відповіді для основних GET-запитів;
- особливості POST / PUT / DELETE відповідають поведінці JSONPlaceholder.

---

## 21. Метрики якості API

У роботі розраховуються такі метрики:

| Метрика | Опис |
|---|---|
| Total requests | загальна кількість HTTP-запитів |
| Passed assertions | кількість успішних перевірок |
| Failed assertions | кількість невдалих перевірок |
| Success rate | відсоток успішних перевірок |
| Average response time | середній час відповіді |
| Minimum response time | мінімальний час відповіді |
| Maximum response time | максимальний час відповіді |
| Standard deviation | відхилення response time |
| Error count | кількість помилок |

---

### 21.1 Формула success rate

```text
Success rate = Passed assertions / Total assertions * 100%
```

Якщо всі assertions пройшли успішно:

```text
Success rate = 100%
```

---

### 21.2 Приклад розрахунку

Якщо Newman показав:

```text
Total assertions: 41
Failed assertions: 0
```

Тоді:

```text
Passed assertions = 41 - 0 = 41
Success rate = 41 / 41 * 100% = 100%
```

---

## 22. Фактичні результати тестування

Після запуску колекції через Newman було отримано такі результати.

> Примітка: конкретні значення response time можуть змінюватися залежно від швидкості інтернет-з’єднання, навантаження на API та поточного стану сервісу.

### 22.1 Результат базового запуску

Команда:

```bash
npm test
```

Результат:

| Показник | Значення |
|---|---|
| Iterations | 1 |
| Requests | 14 |
| Failed requests | 0 |
| Failed test scripts | 0 |
| Failed assertions | 0 |
| Result | Passed |

---

### 22.2 Результат data-driven запуску JSON

Команда:

```bash
npm run test:data:json
```

Результат:

| Показник | Значення |
|---|---|
| Data file | `data/posts_data.json` |
| Iterations | 3 |
| Failed assertions | 0 |
| Result | Passed |

---

### 22.3 Результат data-driven запуску CSV

Команда:

```bash
npm run test:data:csv
```

Результат:

| Показник | Значення |
|---|---|
| Data file | `data/posts_data.csv` |
| Iterations | 3 |
| Failed assertions | 0 |
| Result | Passed |

---

### 22.4 Результат генерації звіту

Команда:

```bash
npm run report
```

Результат:

| Файл | Статус |
|---|---|
| `reports/newman-report.html` | generated |
| `reports/newman-report.json` | generated |

---

### 22.5 Результат stability-запуску

Команда:

```bash
npm run stability
```

Результат:

| Запуск | Файл звіту |
|---|---|
| Run 1 | `reports/newman-run-1.json` |
| Run 2 | `reports/newman-run-2.json` |
| Run 3 | `reports/newman-run-3.json` |
| Run 4 | `reports/newman-run-4.json` |
| Run 5 | `reports/newman-run-5.json` |

---

## 23. Короткий аналіз результатів

У результаті виконання лабораторної роботи було протестовано REST API сервісу JSONPlaceholder.

Функціональні тести підтвердили, що endpoint:

```http
GET /posts
```

повертає:

- статус `200 OK`;
- JSON-відповідь;
- масив об’єктів;
- не менше 100 елементів;
- об’єкти з полями `userId`, `id`, `title`, `body`.

JSON Schema Validation підтвердила, що структура відповіді відповідає очікуваному контракту.

Data-driven тестування показало, що один POST-запит може виконуватися з різними наборами вхідних даних із JSON та CSV-файлів.

Pre-request Script дозволив автоматично генерувати випадкові значення `title` і `body` перед виконанням POST-запиту.

Workflow-сценарій:

```text
POST → GET → PUT → GET → DELETE → GET
```

був реалізований повністю. При цьому враховано особливість JSONPlaceholder: сервіс імітує зміну даних, але не зберігає їх реально.

Негативне тестування показало, що API не має суворої серверної валідації для деяких некоректних запитів. Наприклад, POST-запит із неправильними типами даних може повертати `201 Created`.

Усі основні запити мають перевірку часу відповіді. Максимально допустимий час відповіді встановлено як:

```text
1000 мс
```

За результатами запусків критичних помилок у роботі API не виявлено. Поведінка API відповідає особливостям fake REST API JSONPlaceholder.

---

## 24. Висновок

У лабораторній роботі було створено повний набір API-тестів для сервісу JSONPlaceholder.

Було реалізовано:

- Postman Collection;
- Postman Environment;
- функціональні тести;
- JSON Schema Validation;
- data-driven тестування;
- pre-request script;
- workflow / end-to-end сценарій;
- негативні тести;
- перевірку продуктивності;
- логування;
- контрактне тестування;
- автоматизацію запуску через Newman;
- CLI та HTML-звіти;
- аналіз стабільності;
- розрахунок метрик якості API.

Отже, мету лабораторної роботи виконано повністю.

---

## 25. Команди для перевірки

Для повторного запуску тестів потрібно виконати:

```bash
npm install
npm test
npm run test:data:json
npm run test:data:csv
npm run report
npm run stability
```

Після цього результати будуть доступні у папці:

```text
reports/
```