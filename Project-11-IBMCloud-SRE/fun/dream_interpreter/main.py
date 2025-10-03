# AI Dream Interpreter — portable CLI
# Works locally with OPENAI_API_KEY in env.

from openai import OpenAI
import argparse
import os
import sys

PERSONAS = {
    "freud": {
        "name": "Sigmund Freud",
        "prompt": (
            "You are Sigmund Freud, the renowned psychoanalyst. Your tone is academic, "
            "slightly eccentric, and confident. When a user tells you their dream, analyze it "
            "strictly through the lens of psychoanalytic theory, focusing on wish-fulfillment, "
            "the unconscious mind, and symbols related to early life experiences. Refer to the user "
            "as 'the patient'. Keep your analysis to 2-3 concise paragraphs. Begin with "
            "'Ah, a fascinating glimpse into the unconscious...'"
        ),
    },
    "jung": {
        "name": "Carl Jung",
        "prompt": (
            "You are Carl Jung, the famous analytical psychologist. Your tone is wise, mystical, "
            "and deeply insightful. Analyze dreams via archetypes, the collective unconscious, and "
            "individuation. Look for universal symbols and their meanings. Refer to the user as "
            "'the dreamer'. Keep your analysis to 2-3 concise paragraphs. Begin with "
            "'Let us journey into the collective unconscious together...'"
        ),
    },
}

def interpret(dream_text: str, persona_key: str, model: str = "gpt-4o-mini") -> str:
    if persona_key not in PERSONAS:
        raise ValueError(f"Unknown persona: {persona_key}")
    if not os.getenv("OPENAI_API_KEY"):
        raise RuntimeError("OPENAI_API_KEY not set in environment.")
    client = OpenAI()
    system_prompt = PERSONAS[persona_key]["prompt"]
    r = client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": dream_text},
        ],
    )
    return r.choices[0].message.content.strip()

def main():
    p = argparse.ArgumentParser(description="Fun psychoanalysis dream interpreter.")
    p.add_argument("--persona", choices=list(PERSONAS.keys()), default="freud",
                   help="Choose analyst persona.")
    p.add_argument("--model", default="gpt-4o-mini", help="OpenAI model name.")
    p.add_argument("--text", help="Dream text. If omitted, runs an interactive loop.")
    args = p.parse_args()

    if args.text:
        try:
            out = interpret(args.text, args.persona, args.model)
            print(out)
        except Exception as e:
            print(f"Error: {e}", file=sys.stderr)
            sys.exit(1)
        return

    # Interactive loop
    print("AI Dream Interpreter")
    print(f"Persona: {args.persona}  |  Model: {args.model}")
    print("Type 'exit' to quit.\n")
    while True:
        try:
            dream = input("Your dream> ").strip()
        except (EOFError, KeyboardInterrupt):
            print()
            break
        if dream.lower() in {"exit", "quit"}:
            break
        if not dream:
            continue
        try:
            print("\n--- Interpretation ---")
            print(interpret(dream, args.persona, args.model))
            print("----------------------\n")
        except Exception as e:
            print(f"Error: {e}", file=sys.stderr)

if __name__ == "__main__":
    main()
