# main.py
# AI Dream Interpreter: A competition entry for the Programiz PRO Playground AI Challenge.
# This version uses the special, pre-configured contest environment.

import openai
import time

# --- The "Mind" of the Analysts ---
PERSONAS = {
    "1": {
        "name": "Sigmund Freud",
        "prompt": """
        You are Sigmund Freud, the renowned psychoanalyst. Your tone is academic, slightly eccentric, and confident.
        When a user tells you their dream, analyze it strictly through the lens of psychoanalytic theory,
        focusing on wish-fulfillment, the unconscious mind, and symbols related to early life experiences.
        Refer to the user as 'the patient'. Keep your analysis to 2-3 concise paragraphs.
        Begin your response with 'Ah, a fascinating glimpse into the unconscious...'
        """
    },
    "2": {
        "name": "Carl Jung",
        "prompt": """
        You are Carl Jung, the famous analytical psychologist. Your tone is wise, mystical, and deeply insightful.
        When a user tells you their dream, analyze it through the lens of archetypes, the collective unconscious,
        and the process of individuation. Look for universal symbols and their meanings.
        Refer to the user as 'the dreamer'. Keep your analysis to 2-3 concise paragraphs.
        Begin your response with 'Let us journey into the collective unconscious together...'
        """
    }
}

# --- Main Application ---

# 👉 In the Programiz AI Challenge environment, the client is initialized without an API key.
# The platform handles authentication automatically.
try:
    client = openai.OpenAI()
except Exception as e:
    print("Error: Could not initialize OpenAI client.")
    print("Please ensure you are running this in the official Programiz AI Challenge playground.")
    print(f"Details: {e}")
    exit()

def get_dream_interpretation(dream_text, persona):
    """
    Sends the dream and persona prompt to the OpenAI API and returns the interpretation.
    """
    system_prompt = persona["prompt"]
    
    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": dream_text}
            ],
            temperature=0.7,
            max_tokens=250
        )
        return response.choices[0].message.content.strip()
    except Exception as e:
        return f"An error occurred while contacting the AI: {e}"

def main():
    """The main function to run the application."""
    print("=" * 60)
    print("  AI Dream Interpreter 🧠✨")
    print("=" * 60)
    print("Welcome to your personal psychoanalysis session.")
    print("Describe your dream, and a world-renowned analyst will interpret it.")
    print("Type 'quit' or 'exit' at any time to end the session.\n")

    # Persona Selection
    while True:
        print("Choose your analyst:")
        for key, value in PERSONAS.items():
            print(f"  {key}. Dr. {value['name']}")
        
        choice = input("> ")
        if choice in PERSONAS:
            selected_persona = PERSONAS[choice]
            print(f"\nDr. {selected_persona['name']} is ready to see you. Please, tell us about your dream.\n")
            break
        else:
            print("Invalid selection. Please choose a valid number.\n")

    # Main Interaction Loop
    while True:
        user_input = input("My dream: ")
        
        if user_input.lower() in ["quit", "exit"]:
            print(f"\nDr. {selected_persona['name']} nods. 'Our session is over. Reflect on what we've discussed.'")
            break
        
        if not user_input:
            print("Please describe your dream.\n")
            continue

        print("\nThinking...")
        interpretation = get_dream_interpretation(user_input, selected_persona)
        
        print("\n" + "="*20 + " Analysis " + "="*20)
        print(f"\nDr. {selected_persona['name']} considers your dream and says:")
        print(f'"{interpretation}"\n')
        print("=" * 50 + "\n")
        print("Tell me about another dream, or type 'quit' to exit.")

if __name__ == "__main__":
    main()
