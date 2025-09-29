# The Oracle of Slumber (Fun)

Toy console app that simulates classic analysts to interpret dreams. Entertainment only.

## Run locally

Requirements: Python 3.10+, an OpenAI API key.

```bash
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
export OPENAI_API_KEY=sk-... # set your key
pip install -r requirements.txt
python main.py --persona freud --text "I was falling into a cave then flying over the ocean"
