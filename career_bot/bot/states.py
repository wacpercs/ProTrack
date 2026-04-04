from aiogram.fsm.state import State, StatesGroup


class Onboarding(StatesGroup):
    name = State()
    age = State()
    city = State()
    education = State()
    interests = State()
    skills = State()


class ChatMode(StatesGroup):
    career = State()
    vacancies = State()
