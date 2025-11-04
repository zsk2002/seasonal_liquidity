# read the pdf
OPENAI_API_KEY= ""

import openai
from pypdf import PdfReader
import os

 
reader = PdfReader('/Users/zhushangkai/Desktop/seasonal_liquidity/AER_2024_articles/aghamolla-et-al-2024-merchants-of-death-the-effect-of-credit-supply-shocks-on-hospital-outcomes.pdf')
print(len(reader.pages))
page = reader.pages[0]

# Try open AI API
import os
from openai import OpenAI

client = OpenAI(
    # This is the default and can be omitted
    api_key= OPENAI_API_KEY,
)

response = client.responses.create(
    model="gpt-4o",
    instructions="You are a coding assistant that talks like a pirate.",
    input="How do I check if a Python object is an instance of a class?",
)

print(response.output_text)

# print(completion.choices[0].message.content)
# question = """The following is an excerpt from a research paper: Does this paper mention:
# 1. Regression analysis?
# 2. Correlation analysis?
# 3. is this about predictiors and response?
# 4. Winsorization or trimming?
# 5. How are these techniques applied? Answer briefly. """
# intructions = question + page.extract_text() 

# response = client.responses.create(
#     model="gpt-4o",
#     instructions="",
#     input="How do I check if a Python object is an instance of a class?",
# )

# print(response.output_text)