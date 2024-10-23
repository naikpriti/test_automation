import requests
import re
from collections import defaultdict
import os
import subprocess

# GitHub repository information
owner = "naikpriti"  # Replace with your GitHub username
repo = "test_automation"  # Replace with your repository name

# GitHub API URLs for releases and branches
releases_url = f"https://api.github.com/repos/{owner}/{repo}/releases"
branch_url = f"https://api.github.com/repos/{owner}/{repo}/git/refs"
tags_url = f"https://api.github.com/repos/{owner}/{repo}/tags"
create_release_url = f"https://api.github.com/repos/{owner}/{repo}/releases"

# Regular expression for version tags (e.g., v1.2.3 or 1.2.4)
version_regex = re.compile(r"^v?(\d+)\.(\d+)\.(\d+)$")

# Get your GitHub token from environment variables or replace with your token directly
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

def fetch_tag_sha(tag_name):
    response = requests.get(tags_url, headers=headers)
    if response.status_code == 200:
        tags = response.json()
        for tag in tags:
            if tag["name"] == tag_name:
                return tag["commit"]["sha"]
    print(f"Error: Tag '{tag_name}' not found.")
    return None

def create_branch(branch_name, tag_name):
    sha = fetch_tag_sha(tag_name)
    if not sha:
        return

    # Create a new branch from the tag
    data = {
        "ref": f"refs/heads/{branch_name}",
        "sha": sha
    }
    response = requests.post(branch_url, headers=headers, json=data)
    
    if response.status_code == 201:
        print(f"Branch '{branch_name}' created successfully.")
    else:
        print(f"Error creating branch '{branch_name}': {response.status_code} - {response.json()}")

def update_variable_tf(branch_name):
    # Clone the repository and checkout the new branch
    if os.path.exists(repo):
        subprocess.run(["rm", "-rf", repo])
    subprocess.run(["git", "clone", f"https://{token}@github.com/{owner}/{repo}.git"])
    os.chdir(repo)
    
    # Fetch and create the branch if not already present
    subprocess.run(["git", "fetch", "origin"])
    subprocess.run(["git", "checkout", "-b", branch_name])

    # Configure Git user
    subprocess.run(["git", "config", "user.email", "priti.naik@elexisnexisrisk.com"])
    subprocess.run(["git", "config", "user.name", "naikpriti"])

    # Update the variable.tf file
    with open("variable.tf", "a") as f:
        f.write("\n# Updated variable.tf for new release\n")

    # Commit and push the changes
    subprocess.run(["git", "add", "variable.tf"])
    subprocess.run(["git", "commit", "-m", "Update variable.tf for new release"])
    
    # Push the branch with the token for authentication
    subprocess.run(["git", "push", "-u", "origin", branch_name])

    # Go back to the original directory
    os.chdir("..")

def create_release(branch_name, new_tag_name):
    data = {
        "tag_name": new_tag_name,
        "target_commitish": branch_name,
        "name": new_tag_name,
        "body": f"Release {new_tag_name}",
        "draft": False,
        "prerelease": False
    }
    response = requests.post(create_release_url, headers=headers, json=data)
    
    if response.status_code == 201:
        print(f"Release '{new_tag_name}' created successfully.")
    else:
        print(f"Error creating release '{new_tag_name}': {response.status_code} - {response.json()}")

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
        minor_versions = {(major, minor): versions[(major, minor)] for (maj, minor) in versions.keys() if maj == major}
        latest_minor_versions = get_latest_minor_versions(minor_versions)
        latest_versions.update(latest_minor_versions)

    # Debug print to check the structure of latest_versions
    print("Latest Versions:", latest_versions)

    # Create a branch for each latest version, incrementing the patch version
    for (major_minor, (patch, tag_name)) in latest_versions.items():
        print("Processing:", major_minor, patch, tag_name)  # Debug print
        major, minor = major_minor
        new_patch = patch + 1
        new_branch_name = f"release-v{major}.{minor}.{new_patch}"
        new_tag_name = f"v{major}.{minor}.{new_patch}"
        
        # Create the branch from the tag
        create_branch(new_branch_name, tag_name)
        
        # Update variable.tf in the new branch
        update_variable_tf(new_branch_name)
        
        # Create a new release from the new branch
        create_release(new_branch_name, new_tag_name)

if __name__ == "__main__":
    main()
