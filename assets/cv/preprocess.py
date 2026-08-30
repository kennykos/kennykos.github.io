"""
Process ../../_data folder into tex documents
"""
import re
import yaml
from pathlib import Path

DATA_DIR = Path("../../_data/")
TEX_DIR = Path("sections/")
TAB_HEADER = r"\begin{tabular}{ p{\leftwidth} | p{\rightwidth}}"
TAB_FOOTER = "\n\\end{tabular}"
FILE_HEADER = f"%THIS FILE WAS AUTO-GENERATED\n"

def markdown_to_latex(text):
    # URL
    pattern = r'\[([^\]]+)\]\(([^)]+)\)'
    replacement = r'\\href{\2}{\1}'
    text = re.sub(pattern, replacement, text)
    # emph
    text = re.sub(r'\*(?!\s)([^*]+?)(?<!\s)\*', r'\\emph{\1}', text)
    # code
    text = re.sub(r'``([^`]+)``', r'\\texttt{\1}', text)

    return text

def main():
    # read education yaml
    with open(DATA_DIR / "education.yml", "r") as file:
        edu_data = yaml.load(file, Loader=yaml.SafeLoader)
    # write to education tex
    with open(TEX_DIR / "education.tex", "w") as file:
        file.write(FILE_HEADER)
        file.write(TAB_HEADER)
        for i, entry in enumerate(edu_data):
            # parse entry to string
            year = f"\n{entry["start-year"]} -- {entry["end-year"]}"
            info = rf"{entry["degree"]} \newline {entry["location"]}"
            if "advisor" in entry.keys():
                info += rf"\newline Advisor: {entry["advisor"]}"
            info = info.replace("&", "\\&")
            file.write(rf"{year} & {info} \\")
            if i < len(edu_data)-1:
                file.write(r"\\")
        file.write(TAB_FOOTER)

    # process repositories.yml
    with open(DATA_DIR / "repositories.yml", "r") as file:
        repo_data = yaml.load(file, Loader=yaml.SafeLoader)
    # write to repositories.tex
    with open(TEX_DIR / "repositories.tex", "w") as file:
        file.write(FILE_HEADER)
        users = ""
        users = [users.join(fr"\texttt{{\href{{https://github.com/{user}}}{{{user}}}}}, ") for user in repo_data["github_users"]][0][:-2]
        file.write(f"{{\\centering \\emph{{My open-source contributions are from the}} {users} \\emph{{GitHub account.}}\\par}}")

        # begin write to table
        file.write(r"\vspace{1em}")
        file.write(TAB_HEADER)
        for i, entry in enumerate(repo_data["github_repos"]):
            # parse entry to string
            name = entry["name"]
            name = name.replace("/", r"/\newline ")
            name = r"\href{https://github.com/" + entry["name"] + r"}{\texttt{" + name + "}}"

            contributions = markdown_to_latex(entry["contributions"]).replace("_", r"\_")
            file.write(rf"{name} & {contributions}\\")
            if i < len(edu_data)-1:
                file.write(r"\\")
                file.write("\n")
        file.write(TAB_FOOTER)

    # process students.yml
    with open(DATA_DIR / "students.yml", "r") as file:
        stu_data = yaml.load(file, Loader=yaml.SafeLoader)

    # write to students.tex
    with open(TEX_DIR / "students.tex", "w") as file:
        # NOTE: for now, just process undergrads
        undergrads = stu_data["Undergraduates"]
        file.write(FILE_HEADER)
        file.write(TAB_HEADER)
        for undergrad in undergrads:
            print("start-year" in undergrad.keys())
            year = f"\n{undergrad["start-year"]} -- {undergrad["end-year"]}"
            info = f"{undergrad["name"]} ({undergrad["school"]})\\newline {undergrad["description"]}"
            file.write(rf"{year} & {info} \\")
        file.write(TAB_FOOTER)





if __name__ == "__main__":
    exit(main())
