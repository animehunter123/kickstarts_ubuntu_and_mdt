#!/usr/bin/env python3

import re

# Path to the file
file_path = './result_01_wget.html'
# Read the contents of the file
with open(file_path, 'r') as file:
    content = file.read()

    # Regular expression to find the names between the anchor tags
    pattern = r'<a href="/simple/[^/]+/">([^<]+)</a>'

    # Find all matches
    names = re.findall(pattern, content)

    # Define a set of characters to skip
    skip_chars = {'>', '<', '='}

    print("OK STARTING PARSING AND OVERWRITING result_02_parsed.ini..." )
    # Open the results.ini file to write the extracted names
    with open('result_02_parsed.ini', 'w') as result_file:
        # Print the extracted names
        for name in names:
            if not any(char in name for char in skip_chars):
                #line = f'{name} = >0'
                line = f'{name}'
                #print(line)
                result_file.write(line + '\n')

print("""
Script is complete, feel free to also use 3 VM's to get 110Mbit/s x3 via:
      
To split the file "result_02_parsed.ini" into 3 separate chunks of equal size for your VMs to parse, you can use the split command in Linux. Here's how you can do it:
split -n 3 result_02_parsed.ini chunk_
      
""")