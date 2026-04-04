from aiogram.types import (
    InlineKeyboardButton,
    InlineKeyboardMarkup,
    ReplyKeyboardMarkup,
    KeyboardButton,
    WebAppInfo,
)


def main_menu_kb(webapp_url: str | None = None) -> InlineKeyboardMarkup:
    buttons = [
        [InlineKeyboardButton(text="🎯 Подобрать профессии", callback_data="cmd_professions")],
        [InlineKeyboardButton(text="🗺 Карьерный план", callback_data="cmd_career_plan")],
        [InlineKeyboardButton(text="💼 Найти вакансии", callback_data="cmd_vacancies")],
        [InlineKeyboardButton(text="💬 Чат с консультантом", callback_data="cmd_chat")],
        [InlineKeyboardButton(text="📝 Мой профиль", callback_data="cmd_profile")],
    ]
    if webapp_url:
        buttons.append([
            InlineKeyboardButton(text="🚀 Открыть приложение", web_app=WebAppInfo(url=webapp_url))
        ])
    return InlineKeyboardMarkup(inline_keyboard=buttons)


def education_kb() -> InlineKeyboardMarkup:
    buttons = [
        [InlineKeyboardButton(text="Школьник (9-11 класс)", callback_data="edu_school")],
        [InlineKeyboardButton(text="Студент колледжа/СПО", callback_data="edu_college")],
        [InlineKeyboardButton(text="Студент вуза", callback_data="edu_university")],
        [InlineKeyboardButton(text="Выпускник", callback_data="edu_graduate")],
    ]
    return InlineKeyboardMarkup(inline_keyboard=buttons)


def back_kb() -> InlineKeyboardMarkup:
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="◀️ Главное меню", callback_data="cmd_menu")],
    ])


def vacancy_actions_kb(vacancy_url: str) -> InlineKeyboardMarkup:
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="🔗 Открыть на hh.ru", url=vacancy_url)],
        [InlineKeyboardButton(text="➡️ Ещё вакансии", callback_data="cmd_vacancies_more")],
        [InlineKeyboardButton(text="◀️ Главное меню", callback_data="cmd_menu")],
    ])
