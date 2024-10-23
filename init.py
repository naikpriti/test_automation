import requests
import re
from collections import defaultdict
import os

# GitHub repository information
owner = "naikpriti"  # e.g., "tensorflow"
repo = "test_automation"  # e.g., "tensorflow"

# GitHub API URLs for releases and branches
releases_url = f"https://api.github.com/repos/{owner}/{repo}/releases"
branch_url = f"https://api.github.com/repos/{owner}/{repo}/git/refs/heads"
tags_url = f"https://api.github.com/repos/{owner}/{repo}/tags"

# Regular expression for version tags (e.g., v1.2.3 or 1.2.4)
version_regex = re.compile(r"^v?(\d+)\.(\d+)\.(\d+)$")

# Add your GitHub token here if needed
token = os.getenv("GITHUB_TOKEN")

# Add the authentication header with the token if it's available
headers = {
    "Authorization": f"token {token}" if token else None,
    "Accept": "application/vnd.github.v3+json"
}

def fetch_releases():
    response = requests.get(releases_url, headers=headers)
    if response.status_code == 200:
        return response.json()
    elif response.status_code == 404:
        print("Error: Repository not found. Check the repository name and owner.")
    else:
        print(f"Error fetching releases: {response.status_code}")
    return []

def extract_versions(releases):
    versions = defaultdict(list)

    for release in releases:
        tag_name = release["tag_name"]
        match = version_regex.match(tag_name)
        if match:
            major, minor, patch = map(int, match.groups())
            versions[(major, minor)].append((patch, release["tag_name"]))  # Group by major.minor

    return versions

def get_latest_minor_versions(versions):
    latest_versions = {}
    for major_minor, patches in versions.items():
        # Sort by patch to find the latest
        latest_patch = max(patches, key=lambda x: x[0])
        latest_versions[major_minor] = latest_patch

    return latest_versions

def create_branch(branch_name, tag_name):
    # Create a new branch from the tag
    data = {
        "ref": f"refs/heads/{branch_name}",
        "sha": f"refs/tags/{tag_name}"
    }
    response = requests.post(branch_url, headers=headers, json=data)
    
    if response.status_code == 201:
        print(f"Branch '{branch_name}' created successfully.")
    else:
        print(f"Error creating branch '{branch_name}': {response.status_code} - {response.json()}")

def main():
    releases = fetch_releases()
    if not releases:
        return

    versions = extract_versions(releases)
    
    # Sort the major.minor versions and get the last three major versions
    sorted_major_versions = sorted(set(major for major, _ in versions.keys()), reverse=True)[:3]

    # Fetch the latest minor versions for the last three major versions
    latest_versions = {}
    for major in sorted_major_versions:
        minor_versions = {minor: versions[(major, minor)] for (maj, minor) in versions.keys() if maj == major}
        latest_minor_versions = get_latest_minor_versions(minor_versions)
        latest_versions.update(latest_minor_versions)

    # Create a branch for each latest version, incrementing the patch version
    for (major_minor, (patch, tag_name)) in latest_versions.items():
        major, minor = major_minor
        new_patch = patch + 1
        new_branch_name = f"release-v{major}.{minor}.{new_patch}"
        
        # Create the branch from the tag
        create_branch(new_branch_name, tag_name)

if __name__ == "__main__":
    main()
