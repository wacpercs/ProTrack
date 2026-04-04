import asyncio
import logging
import time

from aiogram import Router, F
from aiogram.types import Message, CallbackQuery
from aiogram.filters import CommandStart, Command
from aiogram.fsm.context import FSMContext

from bot.states import Onboarding, ChatMode
from bot.keyboards import main_menu_kb, education_kb, back_kb
from services import db_service, ai_service, hh_service
from config import WEBAPP_URL

logger = logging.getLogger(__name__)
router = Router()

TG_MSG_LIMIT = 4000  # safe limit under 4096


async def stream_to_message(message: Message, messages: list[dict], reply_markup=None):
    """Stream AI response, splitting into multiple messages if needed."""
    sent = await message.answer("⏳ Генерирую ответ...")
    full_text = ""
    current_msg = sent
    current_msg_text = ""
    last_edit = 0
    last_len = 0

    try:
        async for chunk in ai_service.stream_response(messages):
            full_text += chunk
            current_msg_text += chunk
            now = time.time()
            new_chars = len(current_msg_text) - last_len

            # If current message is getting close to limit, finalize it and start new
            if len(current_msg_text) > TG_MSG_LIMIT - 200:
                try:
                    await current_msg.edit_text(current_msg_text[:TG_MSG_LIMIT])
                except Exception:
                    pass
                current_msg = await message.answer("⏳ Продолжаю...")
                current_msg_text = ""
                last_len = 0
                last_edit = now
                continue

            # Edit every 1s but only if 30+ new chars accumulated
            if now - last_edit > 1 and new_chars >= 30:
                try:
                    await current_msg.edit_text(current_msg_text + " ▌")
                except Exception:
                    pass
                last_edit = now
                last_len = len(current_msg_text)

        # Final edit
        if current_msg_text:
            try:
                await current_msg.edit_text(current_msg_text, reply_markup=reply_markup)
            except Exception:
                try:
                    await message.answer(current_msg_text, reply_markup=reply_markup)
                except Exception:
                    pass

    except Exception as e:
        logger.error(f"Stream error: {e}")
        try:
            await current_msg.edit_text("Произошла ошибка. Попробуй ещё раз.", reply_markup=back_kb())
        except Exception:
            await message.answer("Произошла ошибка. Попробуй ещё раз.", reply_markup=back_kb())

    return full_text


# ─── /start ───

@router.message(CommandStart())
async def cmd_start(message: Message, state: FSMContext):
    await state.clear()
    user = await db_service.get_user(message.from_user.id)
    if user and user.get("name"):
        await message.answer(
            f"С возвращением, {user['name']}! 👋\nЧем могу помочь?",
            reply_markup=main_menu_kb(WEBAPP_URL),
        )
    else:
        await message.answer(
            "Привет! 👋 Я твой AI-карьерный консультант.\n\n"
            "Помогу подобрать профессию, составить карьерный план и найти подходящие вакансии.\n\n"
            "Давай сначала познакомимся. Как тебя зовут?"
        )
        await state.set_state(Onboarding.name)


@router.message(Command("edit"))
async def cmd_edit(message: Message, state: FSMContext):
    await state.clear()
    await message.answer("Давай обновим профиль. Как тебя зовут?")
    await state.set_state(Onboarding.name)


# ─── Онбординг ───

@router.message(Onboarding.name)
async def onb_name(message: Message, state: FSMContext):
    await state.update_data(name=message.text.strip().title())
    await message.answer("Сколько тебе лет?")
    await state.set_state(Onboarding.age)


@router.message(Onboarding.age)
async def onb_age(message: Message, state: FSMContext):
    text = message.text.strip()
    if not text.isdigit() or not (12 <= int(text) <= 60):
        await message.answer("Введи возраст числом (12-60):")
        return
    await state.update_data(age=int(text))
    await message.answer("В каком городе ты живёшь?")
    await state.set_state(Onboarding.city)


@router.message(Onboarding.city)
async def onb_city(message: Message, state: FSMContext):
    await state.update_data(city=message.text.strip().title())
    await message.answer("Какое у тебя образование?", reply_markup=education_kb())
    await state.set_state(Onboarding.education)


@router.callback_query(Onboarding.education, F.data.startswith("edu_"))
async def onb_education(callback: CallbackQuery, state: FSMContext):
    edu_map = {
        "edu_school": "Школьник (9-11 класс)",
        "edu_college": "Студент колледжа/СПО",
        "edu_university": "Студент вуза",
        "edu_graduate": "Выпускник",
    }
    edu = edu_map.get(callback.data, callback.data)
    await state.update_data(education=edu)
    await callback.message.answer(
        "Расскажи о своих интересах и хобби.\n"
        "Что тебе нравится делать? Чем увлекаешься?\n\n"
        "Например: программирование, рисование, спорт, музыка, видеоигры..."
    )
    await callback.answer()
    await state.set_state(Onboarding.interests)


@router.message(Onboarding.interests)
async def onb_interests(message: Message, state: FSMContext):
    await state.update_data(interests=message.text.strip())
    await message.answer(
        "Какие навыки у тебя уже есть?\n\n"
        "Например: знаю Python, умею работать в Figma, хорошо пишу тексты, "
        "базовый английский, опыт в фотошопе...\n\n"
        "Если пока ничего — так и напиши."
    )
    await state.set_state(Onboarding.skills)


@router.message(Onboarding.skills)
async def onb_skills(message: Message, state: FSMContext):
    await state.update_data(skills=message.text.strip())
    data = await state.get_data()

    await db_service.save_user(
        tg_id=message.from_user.id,
        name=data["name"],
        age=data["age"],
        city=data.get("city", ""),
        education=data["education"],
        interests=data["interests"],
        skills=data["skills"],
    )
    await state.clear()

    await message.answer(
        f"Отлично, {data['name']}! Профиль сохранён ✅\n\n"
        "Теперь я могу:\n"
        "🎯 Подобрать подходящие профессии\n"
        "🗺 Составить карьерный план\n"
        "💼 Найти вакансии под твой профиль\n"
        "💬 Ответить на любые вопросы о карьере\n\n"
        "Выбирай:",
        reply_markup=main_menu_kb(WEBAPP_URL),
    )


# ─── Главное меню ───

@router.callback_query(F.data == "cmd_menu")
async def cmd_menu(callback: CallbackQuery, state: FSMContext):
    await state.clear()
    await callback.message.answer("Главное меню:", reply_markup=main_menu_kb(WEBAPP_URL))
    await callback.answer()


@router.message(Command("menu"))
async def cmd_menu_msg(message: Message, state: FSMContext):
    await state.clear()
    await message.answer("Главное меню:", reply_markup=main_menu_kb(WEBAPP_URL))


# ─── Профиль ───

@router.callback_query(F.data == "cmd_profile")
async def cmd_profile(callback: CallbackQuery):
    user = await db_service.get_user(callback.from_user.id)
    if not user:
        await callback.message.answer("Профиль не найден. Нажми /start для регистрации.")
        await callback.answer()
        return

    text = (
        f"📝 Твой профиль\n\n"
        f"Имя: {user.get('name', '—')}\n"
        f"Возраст: {user.get('age', '—')}\n"
        f"Город: {user.get('city', '—')}\n"
        f"Образование: {user.get('education', '—')}\n"
        f"Интересы: {user.get('interests', '—')}\n"
        f"Навыки: {user.get('skills', '—')}\n"
    )

    await callback.message.answer(text, reply_markup=back_kb())
    await callback.answer()


# ─── Подбор профессий (стриминг) ───

@router.callback_query(F.data == "cmd_professions")
async def cmd_professions(callback: CallbackQuery):
    user = await db_service.get_user(callback.from_user.id)
    if not user:
        await callback.message.answer("Сначала пройди регистрацию: /start")
        await callback.answer()
        return
    await callback.answer()

    messages = ai_service.analyze_profile_messages(user)
    result = await stream_to_message(callback.message, messages, reply_markup=back_kb())
    if result:
        await db_service.save_user(callback.from_user.id, recommended_professions=result[:500])


# ─── Карьерный план (стриминг) ───

@router.callback_query(F.data == "cmd_career_plan")
async def cmd_career_plan(callback: CallbackQuery):
    user = await db_service.get_user(callback.from_user.id)
    if not user:
        await callback.message.answer("Сначала пройди регистрацию: /start")
        await callback.answer()
        return
    await callback.answer()

    messages = ai_service.career_plan_messages(user)
    result = await stream_to_message(callback.message, messages, reply_markup=back_kb())
    if result:
        await db_service.save_user(callback.from_user.id, career_plan=result[:1000])


# ─── Вакансии ───

@router.callback_query(F.data == "cmd_vacancies")
async def cmd_vacancies(callback: CallbackQuery, state: FSMContext):
    user = await db_service.get_user(callback.from_user.id)
    if not user:
        await callback.message.answer("Сначала пройди регистрацию: /start")
        await callback.answer()
        return

    await callback.message.answer("💼 Подбираю вакансии по твоему профилю...")
    await callback.answer()

    try:
        queries = await ai_service.suggest_search_queries(user)
        city = user.get("city", "")
        area_id = None
        if city:
            area_id = await hh_service.resolve_city_area(city)

        await state.update_data(vacancy_queries=queries, vacancy_idx=0, area_id=area_id)

        if queries:
            # Ищем в городе юзера
            results = await hh_service.search_vacancies(
                text=queries[0], experience="noExperience", per_page=5,
                area=area_id or 113,
            )
            # Добавляем удалёнку
            remote = await hh_service.search_vacancies(
                text=queries[0], experience="noExperience", per_page=3,
                schedule="remote",
            )
            # Объединяем, убирая дубли
            seen_ids = {v["id"] for v in results["items"]}
            for v in remote["items"]:
                if v["id"] not in seen_ids:
                    results["items"].append(v)
            results["total"] += remote["total"]

            label = f"{queries[0]} ({city})" if city else queries[0]
            await _send_vacancies(callback.message, results, label)
            await state.update_data(vacancy_idx=1)
        else:
            await callback.message.answer("Напиши, какие вакансии ищешь:")
            await state.set_state(ChatMode.vacancies)
    except Exception as e:
        logger.error(f"Vacancies error: {e}")
        await callback.message.answer("Ошибка при подборе вакансий. Попробуй ещё раз.", reply_markup=back_kb())


@router.callback_query(F.data == "cmd_vacancies_more")
async def cmd_vacancies_more(callback: CallbackQuery, state: FSMContext):
    data = await state.get_data()
    queries = data.get("vacancy_queries", [])
    idx = data.get("vacancy_idx", 0)

    if idx < len(queries):
        await callback.message.answer(f"🔍 Ищу: {queries[idx]}...")
        results = await hh_service.search_vacancies(
            text=queries[idx], experience="noExperience", per_page=5
        )
        await _send_vacancies(callback.message, results, queries[idx])
        await state.update_data(vacancy_idx=idx + 1)
    else:
        await callback.message.answer(
            "Все подборки показаны. Напиши свой запрос или вернись в меню:",
            reply_markup=back_kb(),
        )
    await callback.answer()


async def _send_vacancies(message: Message, results: dict, query: str):
    if not results["items"]:
        await message.answer(f"По запросу «{query}» ничего не нашлось.", reply_markup=back_kb())
        return

    text = f"💼 Вакансии: «{query}» (найдено {results['total']})\n\n"
    for i, v in enumerate(results["items"], 1):
        text += (
            f"{i}. {v['title']}\n"
            f"🏢 {v['company']} | 📍 {v['city']}\n"
            f"💰 {v['salary']} | 📋 {v['experience']}\n"
            f"🔗 {v['url']}\n\n"
        )

    await message.answer(text, parse_mode=None, reply_markup=back_kb())


# ─── Свободный чат (стриминг) ───

@router.callback_query(F.data == "cmd_chat")
async def cmd_chat(callback: CallbackQuery, state: FSMContext):
    await callback.message.answer(
        "💬 Режим чата. Задавай любые вопросы о карьере, "
        "профессиях, обучении.\n\n"
        "Для выхода — /menu"
    )
    await state.set_state(ChatMode.career)
    await callback.answer()


@router.message(ChatMode.career)
async def chat_message(message: Message, state: FSMContext):
    user = await db_service.get_user(message.from_user.id) or {}
    history = await db_service.get_history(message.from_user.id, limit=10)

    await db_service.save_message(message.from_user.id, "user", message.text)

    messages = ai_service.chat_messages(user, history, message.text)
    result = await stream_to_message(message, messages, reply_markup=back_kb())
    if result:
        await db_service.save_message(message.from_user.id, "assistant", result)


# ─── Поиск вакансий текстом ───

@router.message(ChatMode.vacancies)
async def vacancy_text_search(message: Message, state: FSMContext):
    await message.answer(f"🔍 Ищу: {message.text}...")
    try:
        results = await hh_service.search_vacancies(
            text=message.text, experience="noExperience", per_page=5
        )
        await _send_vacancies(message, results, message.text)
    except Exception as e:
        logger.error(f"Vacancy search error: {e}")
        await message.answer("Ошибка поиска. Попробуй другой запрос.", reply_markup=back_kb())
