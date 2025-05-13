import yaml

def read_yaml(file_path):
    with open(file_path, "r") as file:
        return yaml.safe_load(file)

def generate_tex(cv_data):
    tex_content = ""

    for section in cv_data:
        title = section.get("title", "Untitled")
        print(f"Processing section: {title}")
        tex_content += f"\\section*{{{title}}}\n"

        if section["type"] == "map":
            for entry in section["contents"]:
                for key, value in entry.items():
                    if key != "value":
                        tex_content += f"\\textbf{{{key.capitalize()}:}} {value} \\\\\n"

        elif section["type"] == "time_table":
            tex_content += "\\begin{itemize}\n"
            for entry in section["contents"]:
                section_title = entry.get("title", "No Title")  # Handle missing 'title'
                year = entry.get("year", "N/A")
                institution = entry.get("institution", "")

                tex_content += f"  \\item \\textbf{{{section_title}}} ({year})\n"
                if institution:
                    tex_content += f"    \\textit{{{institution}}}\n"

                if "description" in entry:
                    tex_content += "    \\begin{itemize}\n"
                    for desc in entry["description"]:
                        if isinstance(desc, dict):
                            desc_title = desc.get("title", "No Title")
                            tex_content += f"      \\item \\textbf{{{desc_title}}}\n"
                            if "contents" in desc:
                                for subdesc in desc["contents"]:
                                    tex_content += f"        \\item {subdesc}\n"
                        else:
                            tex_content += f"      \\item {desc}\n"
                    tex_content += "    \\end{itemize}\n"
            tex_content += "\\end{itemize}\n"

    return tex_content

def write_tex(file_path, tex_content):
    with open(file_path, 'w') as file:
        file.write(tex_content)

def main():
    yaml_path = '../../_data/cv.yml'  # Modify this to your actual YAML file path
    tex_path = 'cv.tex'  # Output TeX file
    
    cv_data = read_yaml(yaml_path)
    tex_content = generate_tex(cv_data)
    write_tex(tex_path, tex_content)
    
    print(f"LaTeX file generated: {tex_path}")

if __name__ == "__main__":
    main()
