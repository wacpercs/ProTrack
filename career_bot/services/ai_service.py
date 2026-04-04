from openai import AsyncOpenAI
from config import DEEPSEEK_API_KEY, DEEPSEEK_BASE_URL

client = AsyncOpenAI(api_key=DEEPSEEK_API_KEY, base_url=DEEPSEEK_BASE_URL)

SYSTEM_PROMPT = """Ты — AI-карьерный консультант для молодёжи 16-22 лет (школьники, студенты СПО и вузов).

Твои задачи:
1. Помогать с профессиональным самоопределением
2. Рекомендовать направления развития и навыки
3. Строить индивидуальный карьерный план
4. Давать советы по трудоустройству

Правила:
- Отвечай дружелюбно, на "ты", без канцелярита
- Учитывай возраст и уровень образования пользователя
- Давай конкретные, практичные советы
- Если предлагаешь профессии — объясняй почему они подходят
- Если строишь план — разбивай на конкретные шаги с примерными сроками
- Используй эмодзи умеренно для дружелюбности
- ВАЖНО: отвечай компактно, не более 3500 символов
- НЕ используй Markdown-разметку (###, **, __, ```, [ссылки]())
- Для структуры используй эмодзи, нумерацию и переносы строк"""


def _build_profile_context(user: dict) -> str:
    parts = []
    if user.get("name"):
        parts.append(f"Имя: {user['name']}")
    if user.get("age"):
        parts.append(f"Возраст: {user['age']}")
    if user.get("city"):
        parts.append(f"Город: {user['city']}")
    if user.get("education"):
        parts.append(f"Образование: {user['education']}")
    if user.get("interests"):
        parts.append(f"Интересы: {user['interests']}")
    if user.get("skills"):
        parts.append(f"Навыки: {user['skills']}")
    if user.get("recommended_professions"):
        parts.append(f"Ранее рекомендованные профессии: {user['recommended_professions']}")
    if not parts:
        return ""
    return "\n\nПрофиль пользователя:\n" + "\n".join(parts)


async def stream_response(messages: list[dict], max_tokens: int = 1500):
    """Yield chunks of text as they come from DeepSeek."""
    stream = await client.chat.completions.create(
        model="deepseek-chat",
        messages=messages,
        max_tokens=max_tokens,
        temperature=0.7,
        stream=True,
    )
    async for chunk in stream:
        delta = chunk.choices[0].delta
        if delta.content:
            yield delta.content


def build_messages(system_extra: str, user_prompt: str) -> list[dict]:
    return [
        {"role": "system", "content": SYSTEM_PROMPT + system_extra},
        {"role": "user", "content": user_prompt},
    ]


async def chat(user: dict, history: list[dict], user_message: str) -> str:
    system = SYSTEM_PROMPT + _build_profile_context(user)
    messages = [{"role": "system", "content": system}]
    messages.extend(history)
    messages.append({"role": "user", "content": user_message})

    response = await client.chat.completions.create(
        model="deepseek-chat",
        messages=messages,
        max_tokens=1500,
        temperature=0.7,
    )
    return response.choices[0].message.content


async def analyze_profile(user: dict) -> str:
    msgs = analyze_profile_messages(user)
    response = await client.chat.completions.create(
        model="deepseek-chat", messages=msgs, max_tokens=1500, temperature=0.7,
    )
    return response.choices[0].message.content


async def build_career_plan(user: dict) -> str:
    msgs = career_plan_messages(user)
    response = await client.chat.completions.create(
        model="deepseek-chat", messages=msgs, max_tokens=1500, temperature=0.7,
    )
    return response.choices[0].message.content


def analyze_profile_messages(user: dict) -> list[dict]:
    profile = _build_profile_context(user)
    prompt = f"""Задача: подобрать профессии для пользователя.

{profile}

Выведи ровно 5 профессий в таком формате (для каждой):

[эмодзи] НАЗВАНИЕ ПРОФЕССИИ
Почему подходит: 1-2 предложения, связывая с интересами и навыками пользователя
Зарплата на старте: примерная вилка в рублях
Порог входа: что минимально нужно чтобы начать

НЕ пиши общих советов, НЕ пиши про навыки отдельно. Только 5 профессий с обоснованием."""
    return build_messages("", prompt)


def career_plan_messages(user: dict) -> list[dict]:
    profile = _build_profile_context(user)
    prompt = f"""Задача: составить пошаговый карьерный план с этапами роста и конкретными курсами.

{profile}

Формат ответа:

1) ЦЕЛЕВАЯ ПРОФЕССИЯ: выбери одну наиболее подходящую

2) ЭТАПЫ КАРЬЕРНОГО РОСТА:
[эмодзи] Стажёр/Новичок -> чем занимается, зарплата
[эмодзи] Junior -> чем занимается, зарплата
[эмодзи] Middle -> чем занимается, зарплата
[эмодзи] Senior/Lead -> чем занимается, зарплата

3) ПЛАН ДЕЙСТВИЙ (таймлайн):

Сейчас (неделя 1-2):
- Конкретное действие
- Курс: НАЗВАНИЕ (платформа: Stepik/Coursera/YouTube) — бесплатный

Месяц 1-2:
- Конкретное действие
- Курс: НАЗВАНИЕ (платформа)

Месяц 3-6:
- Что изучать и делать
- Проект для портфолио: описание

Месяц 6-12:
- Стажировка/первая работа
- Сертификация: НАЗВАНИЕ (если есть полезная)

Год 1-3:
- Переход на следующий уровень
- Что изучать для роста

ВАЖНО: указывай РЕАЛЬНЫЕ названия курсов на Stepik, Coursera, YouTube (бесплатные). НЕ выдумывай несуществующие курсы. Если не знаешь точное название — пиши "поищи на Stepik курс по [теме]"."""
    return build_messages("", prompt)


def skill_gap_messages(user: dict) -> list[dict]:
    profile = _build_profile_context(user)
    prompt = f"""Задача: провести анализ разрыва навыков (Skill Gap Analysis).

{profile}

Сделай следующее:

1) На основе профиля определи 2-3 наиболее подходящие профессии

2) Для КАЖДОЙ профессии составь таблицу навыков:

[эмодзи] ПРОФЕССИЯ

Навыки, которые УЖЕ ЕСТЬ (из профиля):
+ навык — как он поможет в этой профессии

Навыки, которых НЕ ХВАТАЕТ:
- навык — почему он нужен, где получить (конкретный курс/ресурс)

Общий процент готовности: X%

3) В конце напиши ИТОГ: какая профессия ближе всего к текущим навыкам и что нужно подтянуть в первую очередь (2-3 пункта).

ВАЖНО: будь конкретным. Не пиши "изучи программирование" — пиши "изучи Python: курс 'Поколение Python' на Stepik". Оценивай реалистично."""
    return build_messages("", prompt)


def chat_messages(user: dict, history: list[dict], user_message: str) -> list[dict]:
    system = SYSTEM_PROMPT + _build_profile_context(user)
    messages = [{"role": "system", "content": system}]
    messages.extend(history)
    messages.append({"role": "user", "content": user_message})
    return messages


async def skill_gap_analysis(user: dict) -> str:
    msgs = skill_gap_messages(user)
    response = await client.chat.completions.create(
        model="deepseek-chat", messages=msgs, max_tokens=2000, temperature=0.7,
    )
    return response.choices[0].message.content


async def score_vacancies(user: dict, vacancies: list[dict]) -> list[dict]:
    """Score each vacancy for compatibility with user profile."""
    profile = _build_profile_context(user)
    vacancy_texts = []
    for i, v in enumerate(vacancies):
        vacancy_texts.append(f"{i+1}. {v.get('title','')} — {v.get('company','')} | Опыт: {v.get('experience','')} | Зарплата: {v.get('salary','')}")
    vacancies_str = "\n".join(vacancy_texts)

    prompt = f"""Оцени совместимость каждой вакансии с профилем пользователя.

{profile}

Вакансии:
{vacancies_str}

Для каждой вакансии выведи ТОЛЬКО одну строку в формате:
НОМЕР|ПРОЦЕНТ|КОРОТКАЯ_ПРИЧИНА

Пример:
1|85|Навыки Python совпадают, подходит по возрасту
2|40|Требуется опыт 3+ года, не подходит для начинающего

Если вакансий нет — выведи "нет вакансий". Оценивай строго: учитывай возраст, образование, навыки, опыт."""

    messages = [
        {"role": "system", "content": "Ты эксперт по подбору персонала. Оцениваешь совместимость кандидата и вакансии."},
        {"role": "user", "content": prompt},
    ]
    response = await client.chat.completions.create(
        model="deepseek-chat", messages=messages, max_tokens=800, temperature=0.3,
    )
    text = response.choices[0].message.content.strip()

    scores = []
    for line in text.split("\n"):
        parts = line.strip().split("|")
        if len(parts) >= 3:
            try:
                idx = int(parts[0].strip()) - 1
                score = int(parts[1].strip().replace("%", ""))
                reason = parts[2].strip()
                if 0 <= idx < len(vacancies):
                    scored = dict(vacancies[idx])
                    scored["match_score"] = min(100, max(0, score))
                    scored["match_reason"] = reason
                    scores.append(scored)
            except (ValueError, IndexError):
                continue

    # Add unscored vacancies
    scored_ids = {v.get("id") for v in scores}
    for v in vacancies:
        if v.get("id") not in scored_ids:
            scored = dict(v)
            scored["match_score"] = 0
            scored["match_reason"] = ""
            scores.append(scored)

    scores.sort(key=lambda x: x.get("match_score", 0), reverse=True)
    return scores


async def suggest_search_queries(user: dict) -> list[str]:
    profile = _build_profile_context(user)
    prompt = f"""На основе профиля пользователя предложи 3-5 поисковых запросов для hh.ru,
которые помогут найти подходящие вакансии/стажировки.

{profile}

Верни ТОЛЬКО список запросов, по одному на строку, без нумерации и пояснений.
Например:
стажёр python
junior frontend разработчик
помощник дизайнера"""

    messages = [
        {"role": "system", "content": "Ты помощник по поиску работы."},
        {"role": "user", "content": prompt},
    ]
    response = await client.chat.completions.create(
        model="deepseek-chat",
        messages=messages,
        max_tokens=300,
        temperature=0.5,
    )
    text = response.choices[0].message.content.strip()
    return [line.strip() for line in text.split("\n") if line.strip()]
