import re

def remove_html_tags(input_file, output_file):
    with open(input_file, 'r', encoding='utf-8') as file:
        text = file.read()
    
    # Use regex to remove HTML tags
    cleaned_text = re.sub(r'<[^>]*>', '', text)
    
    with open(output_file, 'w', encoding='utf-8') as file:
        file.write(cleaned_text)

# Specify your input and output file paths
input_file = 'C:\\Users\\thero\\Dropbox\\Vaults\\Theron-Vault-Clean\\X1 WorkSpaces\\Dev\\FormatMess.txt'
output_file = 'C:\\Users\\thero\\Dropbox\\Vaults\\Theron-Vault-Clean\\X1 WorkSpaces\\Dev\\Cleaned.txt'

# Run the function
remove_html_tags(input_file, output_file)

print(f"HTML tags removed. Cleaned document saved as {output_file}.")