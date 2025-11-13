import re
import json

# Read posts from a text file
def read_posts(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = [line.strip() for line in f if line.strip()]
    return lines

# Extract hashtags from a single post
def extract_hashtags(post):
    # Pattern: words starting with # followed by letters, numbers, underscores
    pattern = r'#[A-Za-z0-9_]+'
    return re.findall(pattern, post)

# Count frequency of hashtags
def count_hashtags(posts):
    freq = {}
    for post in posts:
        tags = extract_hashtags(post)
        for tag in tags:
            freq[tag] = freq.get(tag, 0) + 1
    return freq

# Main function
def main():
    input_file = 'posts.txt'
    output_file = 'hashtags.json'

    posts = read_posts(input_file)
    counts = count_hashtags(posts)

    # Write JSON output
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(counts, f, ensure_ascii=False, indent=2)

    print(f'Hashtag counting complete. Results saved to {output_file}')

# Run main
if __name__ == '__main__':
    main()
