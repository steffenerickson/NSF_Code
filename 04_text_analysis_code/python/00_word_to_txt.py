# ----------------------------------------------------------------- # 
# This code takes a directory of Word Documents and coverts them 
# into .txt files. The files are placeed in a new target directory
# with an identical file structure to the source directory 
# ----------------------------------------------------------------- # 

import os
import shutil
import pypandoc

# Define the source and target root directories
source_root = '/Users/steffenerickson/Desktop/spring2024/qpp/word_documents'
target_root = '/Users/steffenerickson/Desktop/spring2024/qpp/txt_files'

# Copy the file structure 
# Walk through the source directory
for src_dir, dirs, files in os.walk(source_root):
    # Determine the relative path from the source root directory
    rel_path = os.path.relpath(src_dir, source_root)
    # Create the corresponding target directory path
    target_dir = os.path.join(target_root, rel_path)
    
    # Create the target directory within the target root directory
    os.makedirs(target_dir, exist_ok=True)

print(f"The folder structure from {source_root} has been copied to {target_root}.")

# Convert Word Documents to .txt Files 
for src_dir, dirs, files in os.walk(source_root):
    rel_path = os.path.relpath(src_dir, source_root)
    target_dir = os.path.join(target_root, rel_path)
    
    # Ensure the target directory exists
    os.makedirs(target_dir, exist_ok=True)
    
    for file in files:
        if file.endswith('.docx'):
            src_file_path = os.path.join(src_dir, file)
            target_file_path = os.path.join(target_dir, os.path.splitext(file)[0] + '.txt')
            
            try:
                # Attempt to convert the Word document to text and save it
                pypandoc.convert_file(src_file_path, 'plain', outputfile=target_file_path)
            except RuntimeError as e:
                # Log or print the error message and continue with the next file
                print(f"Error converting {src_file_path}: {e}. Continuing with the next file.")
                
print(f"Conversion completed. Word documents have been converted to text files in: {target_root}")