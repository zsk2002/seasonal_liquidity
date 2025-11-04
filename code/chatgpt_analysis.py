from pathlib import Path
from pypdf import PdfReader
import re

def extract_text_from_pdf(pdf_path):
    pdf_path = Path(pdf_path)
    text = ""
    reader = PdfReader(str(pdf_path))
    for page in reader.pages:
       text = text + page.extract_text() + "\n" 
    return text

text = extract_text_from_pdf('//Users/zhushangkai/Desktop/seasonal_liquidity/AER_2024_articles/castro-pires-et-al-2023-disentangling-moral-hazard-and-adverse-selection.pdf')

def remove_references(text: str) -> str:
    pat = re.compile(r"^(?:\s*)references\s*[:\-]?\s*$", re.IGNORECASE | re.MULTILINE)
    matches = list(pat.finditer(text))
    if not matches:
        return text
    cut = matches[-1].start()
    return text[:cut].rstrip()
print(remove_references(text))

def find_key_words(key_words, text):
    output = 0
    for key_word in key_words:
        if text.find(key_word):
            output = 1
    return output

def batch_extract_pdf_dir(in_dir: str | Path,
                          output_file_path: str | Path) -> None:
    in_dir = Path(in_dir).expanduser()
    pdfs = sorted(in_dir.glob("*.pdf"))
    print(f"Found {len(pdfs)} PDFs in {in_dir}")

    for k, pdf in enumerate(pdfs, start=1):
        text = extract_text_from_pdf(pdf)
        text = remove_references(text)
        use_winsorization = find_key_words(["winsorization", "winsorized", "winsorizing", "winsor"])
    
    return None





# OPENAI_API_KEY= ""

# import openai
# from pypdf import PdfReader
# import os

# # Try open AI API
# import os
# from openai import OpenAI

# client = OpenAI(
#     # This is the default and can be omitted
#     api_key= OPENAI_API_KEY,
# )

# response = client.responses.create(
#     model="gpt-4o",
#     instructions="You are a coding assistant that talks like a pirate.",
#     input="How do I check if a Python object is an instance of a class?",
# )

# print(response.output_text)

# # print(completion.choices[0].message.content)
# # question = """The following is an excerpt from a research paper: Does this paper mention:
# # 1. Regression analysis?
# # 2. Correlation analysis?
# # 3. is this about predictiors and response?
# # 4. Winsorization or trimming?
# # 5. How are these techniques applied? Answer briefly. """
# # intructions = question + page.extract_text() 

# # response = client.responses.create(
# #     model="gpt-4o",
# #     instructions="",
# #     input="How do I check if a Python object is an instance of a class?",
# # )

# # print(response.output_text)