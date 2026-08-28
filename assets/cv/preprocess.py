"""
Process ../../_data folder into tex documents
"""
import yaml
from pathlib import Path

DATA_DIR = Path("../../_data/")
TEX_DIR = Path("sections/")
TAB_HEADER = r"\begin{tabular}{ p{\leftwidth} | p{\rightwidth}}"
TAB_FOOTER = "\n\\end{tabular}"
FILE_HEADER = f"%THIS FILE WAS AUTO-GENERATED\n"

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
            year = f"\n{entry["start-year"]}-{entry["end-year"]}"
            info = rf"{entry["degree"]} \newline {entry["location"]}"
            if "advisor" in entry.keys():
                info += rf"\newline Advisor: {entry["advisor"]}"
            info = info.replace("&", "\\&")
            file.write(rf"{year} & {info} \\")
            if i < len(edu_data)-1:
                file.write(r"\\")
        file.write(TAB_FOOTER)


if __name__ == "__main__":
    exit(main())
