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
    prompt = f"""Задача: составить пошаговый карьерный план-таймлайн.

{profile}

Формат — временная шкала с конкретными действиями:

Сейчас (неделя 1-2):
- конкретное действие (ссылка на ресурс или название курса)

Месяц 1-2:
- конкретное действие

Месяц 3-6:
- конкретное действие

Месяц 6-12:
- конкретное действие

Год 1-3:
- куда можно вырасти, какие позиции

НЕ перечисляй профессии. НЕ пиши общих советов типа "изучай новое". Только конкретные шаги с названиями курсов, платформ, проектов. Выбери ОДНО наиболее подходящее направление и строй план под него."""
    return build_messages("", prompt)


def chat_messages(user: dict, history: list[dict], user_message: str) -> list[dict]:
    system = SYSTEM_PROMPT + _build_profile_context(user)
    messages = [{"role": "system", "content": system}]
    messages.extend(history)
    messages.append({"role": "user", "content": user_message})
    return messages


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
