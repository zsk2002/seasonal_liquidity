from pathlib import Path
from pypdf import PdfReader
import re
import pandas as pd
from difflib import get_close_matches

def extract_text_from_pdf(pdf_path):
    pdf_path = Path(pdf_path)
    text = ""
    reader = PdfReader(str(pdf_path))
    for page in reader.pages:
       text = text + page.extract_text() + "\n" 
    return text


def remove_references(text: str) -> str:
    pat = re.compile(r"^(?:\s*)references\s*[:\-]?\s*$", re.IGNORECASE | re.MULTILINE)
    matches = list(pat.finditer(text))
    if not matches:
        return text
    cut = matches[-1].start()
    return text[:cut].rstrip()


def find_key_words(key_words, text: str) -> int:
    t = text.lower()
    return int(any(kw.lower() in t for kw in key_words))

def tail_after_year(stem: str) -> str:
    # find the LAST "-YYYY-" occurrence (handles 2023/2024 etc.)
    hits = list(re.finditer(r"-(?:19|20)\d{2}-", stem))
    if not hits:
        return stem  # no year found; return full stem as fallback
    j = hits[-1].end()  # position after "-YYYY-"
    return stem[j:]

def normalize_title(s: str) -> str:
    # lower, remove non-alphanum, collapse whitespace
    s = s.lower()
    s = re.sub(r"[^a-z0-9\s]", " ", s)
    s = re.sub(r"\s+", " ", s).strip()
    return s

# ---------- main pipeline ----------

def batch_extract_pdf_dir(in_dir: str | Path, input_excel_path,
                          output_file_path: str | Path) -> None:
    in_dir = Path(in_dir).expanduser()
    pdfs = sorted(in_dir.glob("*.pdf"))

    df = pd.read_excel(input_excel_path)

    # prepare/clean title column once
    if "title cleaned" not in df.columns:
        df["title cleaned"] = (
            df["title"]
            .astype(str)
            .str.lower()
            .str.replace(r"[^a-z0-9\s]", " ", regex=True)
            .str.replace(r"\s+", " ", regex=True)
            .str.strip()
        )

    # make sure output columns exist
    for col in ["pdf_path", "using_winsorization", "using_regression"]:
        if col not in df.columns:
            df[col] = pd.NA

    print(f"Found {len(pdfs)} PDFs in {in_dir}")

    for k, pdf in enumerate(pdfs, start=1):
        print(k)
        stem = Path(pdf).stem  # filename without .pdf
        # try to cut leading year tokens like "...-2024-<title>"
        tail = tail_after_year(stem)
        norm_title = normalize_title(tail)

        # find exact match row(s)
        mask = df["title cleaned"] == norm_title
        idx = df.index[mask]

        # if no exact match, try a fuzzy fallback on close strings
        if len(idx) == 0:
            candidates = df["title cleaned"].tolist()
            nearest = get_close_matches(norm_title, candidates, n=1, cutoff=0.85)
            if nearest:
                idx = df.index[df["title cleaned"] == nearest[0]]


        if len(idx) == 0:
            print(f"[WARN] No match in Excel for PDF: {pdf.name}  -> cleaned='{norm_title}'")
            continue  # skip to next PDF

        # extract and analyze text
        text = extract_text_from_pdf(pdf)
        text = remove_references(text)

        use_winsorization = find_key_words(
            ["winsorization", "winsorized", "winsorizing", "winsor"], text
        )
        use_regression = find_key_words(
            ["regression", "correlation"], text
        )

        # assign into the matched rows (usually 1)
        df.loc[idx, "pdf_path"] = str(pdf)
        df.loc[idx, "using_winsorization"] = use_winsorization
        df.loc[idx, "using_regression"] = use_regression

    # write out the updated sheet
    output_file_path = Path(output_file_path)
    output_file_path.parent.mkdir(parents=True, exist_ok=True)
    df.to_excel(output_file_path, index=False)

# batch_extract_pdf_dir("/Users/zhushangkai/Desktop/seasonal_liquidity/AER_2024_articles", 
#                       "/Users/zhushangkai/Desktop/seasonal_liquidity/AER_2024/whole_list.xlsx",
#                       "/Users/zhushangkai/Desktop/seasonal_liquidity/AER_2024/whole_list_automatic_labled.xlsx") 



df = pd.read_excel("/Users/zhushangkai/Desktop/seasonal_liquidity/AER_2024/whole_list_manually_labled.xlsx")
df["have_dataset"] = df["dataset_url"].notna() & (df["dataset_url"].astype(str).str.strip() != "")
df["have_dataset"] = df["have_dataset"].astype(int)

subset_winsorized  = df[df['using_winsorization'] == 1]

from difflib import get_close_matches

# 1) Normalize column names (handles hidden spaces, NBSP, etc.)
subset_winsorized.columns = (
    subset_winsorized.columns.astype(str)
    .str.normalize("NFKC")
    .str.replace("\u00A0", " ", regex=False)  # NBSP to space
    .str.replace(r"\s+", " ", regex=True)     # collapse spaces
    .str.strip()
)

# 2) Drop only if present (no KeyError)
to_drop = ["document_type", "authors", "start_page", "end_page", "abstract"]
present = [c for c in to_drop if c in subset_winsorized.columns]
subset_winsorized.drop(columns=present, inplace=True)
subset_winsorized.to_excel("/Users/zhushangkai/Desktop/seasonal_liquidity/AER_2024/paper_using_winsorization.xlsx")


# import matplotlib.pyplot as plt
# # choose the columns you care about
# cols = ["have_dataset","using_winsorization", "using_regression", "manually_using_winsorization", "manually_using_regression"]

# # (optional) keep only those that exist
# cols = [c for c in cols if c in df.columns]

# # sum them (coerce non-numeric safely)
# col_sums = df[cols].apply(pd.to_numeric, errors="coerce").sum()

# # plt.figure(figsize=(12,6))
# # col_sums.plot(kind="bar")
# # plt.title("Sum for Selected Columns")
# # plt.ylabel("Sum")
# # plt.xticks(rotation=0)
# # plt.tight_layout()
# # plt.savefig("/Users/zhushangkai/Desktop/seasonal_liquidity/plots/bar_plots.png")
# print(df['manually_using_regression'].sum())
# subset_have_dataset = df[df['have_dataset'] == 1]
# print(subset_have_dataset)
# print("subset using winsorization",subset_have_dataset['manually_using_winsorization'].sum())
# # so all paper using winsorization has the dataset
# print("subset using manually regression ",subset_have_dataset['manually_using_regression'].sum())
# print("subset using regression ",subset_have_dataset['using_regression'].sum())




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