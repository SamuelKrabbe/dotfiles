with open("text.txt", "r") as f:
    text = f.read()

text_formatted = text.replace("\n", " ")

with open("text_formatted.txt", "w") as f:
    f.write(text_formatted)

print("File saved with success!")