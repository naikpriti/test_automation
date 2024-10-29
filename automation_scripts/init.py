import requests
import re
from collections import defaultdict
import os
import subprocess
import time
import json
from packaging import version
from bs4 import BeautifulSoup

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

if not token:
    raise ValueError("GitHub token not found. Please set the GITHUB_TOKEN environment variable.")

# Add the authentication header with the token
headers = {
    "Authorization": f"token {token}",
    "Accept": "application/vnd.github.v3+json"
}

# URL of the Microsoft download page
download_page_url = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=56519"

def fetch_releases():
    response = requests.get(releases_url, headers=headers)
    if response.status_code == 200:
        return response.json()
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

def update_files(branch_name, new_tag_name, ip_addresses):
    # Clone the repository and checkout the new branch
    if os.path.exists(repo):
        subprocess.run(["rm", "-rf", repo])
    subprocess.run(["git", "clone", f"https://{token}@github.com/{owner}/{repo}.git"])
    os.chdir(repo)
    
    # Fetch the latest changes from the remote branch
    subprocess.run(["git", "fetch", "origin"])
    
    # Checkout the new branch
    subprocess.run(["git", "checkout", branch_name])

    # Configure Git user
    subprocess.run(["git", "config", "user.email", "priti.naik@elexisnexisrisk.com"])
    subprocess.run(["git", "config", "user.name", "naikpriti"])

    # Update variable.tf
    variable_tf_path = os.path.join("key-vault", "variables.tf")
    update_variables_tf(variable_tf_path, ip_addresses)

    # Format the Terraform file
    subprocess.run(["terraform", "fmt", variable_tf_path])

    # Update version.txt
    version_txt_path =  'version.txt'
    with open(version_txt_path, "w") as f:
        f.write(f"Version: {new_tag_name}")

    # Add, commit, and push the changes
    subprocess.run(["git", "add", variable_tf_path, version_txt_path])
    subprocess.run(["git", "commit", "-m", f"Update variables.tf and version.txt for release {new_tag_name}"])

    # Pull the latest changes from the remote branch to avoid non-fast-forward error
    try:
        subprocess.run(["git", "pull", "--rebase", "origin", branch_name], check=True)
    except subprocess.CalledProcessError:
        print("Conflict detected, resolving manually...")
        # Resolve conflicts here if necessary
        subprocess.run(["git", "rebase", "--continue"])

    # Push the changes, forcing update if necessary
    push_result = subprocess.run(["git", "push", "-u", "origin", branch_name])

    # Handle non-fast-forward error and force push if needed
    if push_result.returncode != 0:
        print(f"Non-fast-forward push detected, force pushing branch '{branch_name}'")
        subprocess.run(["git", "push", "-u", "--force", "origin", branch_name])

    # Go back to the original directory
    os.chdir("..")

def update_main_branch(ip_addresses, new_tag_name):
    # Clone the repository and checkout the main branch
    if os.path.exists(repo):
        subprocess.run(["rm", "-rf", repo])
    subprocess.run(["git", "clone", f"https://{token}@github.com/{owner}/{repo}.git"])
    os.chdir(repo)
    
    # Checkout the main branch
    subprocess.run(["git", "checkout", "main"])

    # Configure Git user
    subprocess.run(["git", "config", "user.email", "priti.naik@elexisnexisrisk.com"])
    subprocess.run(["git", "config", "user.name", "naikpriti"])

    # Update variable.tf
    variable_tf_path = os.path.join("key-vault", "variables.tf")
    update_variables_tf(variable_tf_path, ip_addresses)

    # Format the Terraform file
    subprocess.run(["terraform", "fmt", variable_tf_path])

    # Update version.txt
    version_txt_path = 'version.txt'
    with open(version_txt_path, "w") as f:
        f.write(f"Version: {new_tag_name}")

    # Add, commit, and push the changes
    subprocess.run(["git", "add", variable_tf_path, version_txt_path])
    subprocess.run(["git", "commit", "-m", f"Update variables.tf and version.txt for release {new_tag_name}"])
    subprocess.run(["git", "push", "origin", "main"])

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

def delete_branch(branch_name):
    delete_url = f"{branch_url}/heads/{branch_name}"
    response = requests.delete(delete_url, headers=headers)
    if response.status_code == 204:
        print(f"Branch '{branch_name}' deleted successfully.")
    else:
        print(f"Error deleting branch '{branch_name}': {response.status_code} - {response.json()}")

def update_variables_tf(file_path, ip_addresses):
    with open(file_path, 'r') as file:
        lines = file.readlines()

    updated = False
    with open(file_path, 'w') as file:
        inside_default_block = False
        for line in lines:
            if 'variable "azure_allowed_ip_list"' in line:
                inside_default_block = True
            if inside_default_block and line.strip().startswith('default ='):
                file.write(f'default = [{", ".join(ip_addresses)}]\n')
                inside_default_block = False
                updated = True
            elif inside_default_block and line.strip().startswith('['):
                # Skip the old IP list
                continue
            else:
                file.write(line)
    return updated

def fetch_and_process_json():
    # Step 1: Fetch the HTML content of the confirmation page
    response = requests.get(download_page_url, headers={'User-Agent': 'Github Actions'})
    if response.status_code != 200:
        print(f"Failed to fetch the confirmation page. Status code: {response.status_code}")
        exit(2)

    # Step 2: Parse the HTML content using BeautifulSoup
    soup = BeautifulSoup(response.content, 'html.parser')

    # Step 3: Find the download link for the JSON file
    download_link = soup.find('a', href=re.compile(r'ServiceTags_Public_\d{8}\.json'))
    if not download_link:
        print("Download link not found")
        exit(2)

    # Extract the JSON file name from the href attribute
    json_file_name = download_link['href'].split('/')[-1]

    # Extract the version from the JSON file name (format: yyyymmdd)
    version_date = re.search(r'\d{8}', json_file_name).group(0)
    version_formatted = f"{version_date[:4]}.{version_date[4:6]}.{version_date[6:]}"

    # Step 4: Read the current version from version.txt
    version_file = 'version.txt'
    with open(version_file, 'r') as file:
        current_version_line = next((line for line in file if line.startswith('Version:')), None)
        if current_version_line:
            current_version = current_version_line.split('Version:')[1].strip()
        else:
            print(f"Version line not found in {version_file}")
            exit(2)

    # Step 5: Compare the versions
    if version.parse(version_formatted) <= version.parse(current_version):
        print("IPs are already updated with the latest version.")
        exit(1)

    # Step 6: Construct the download URL
    download_url = download_link['href']

    # Step 7: Download the JSON file with retries
    retry_count = 3
    for attempt in range(retry_count):
        try:
            json_response = requests.get(download_url, timeout=60)
            if json_response.status_code == 200:
                break
        except requests.RequestException as e:
            print(f"Attempt {attempt + 1} failed: {e}")
        if attempt < retry_count - 1:
            print("Retrying...")
            time.sleep(15)
    else:
        print(f"Failed to download the JSON file after {retry_count} attempts.")
        exit(2)

    # Step 8: Save the JSON file locally with the correct name format
    with open(json_file_name, 'wb') as json_file:
        json_file.write(json_response.content)

    print(f"Downloaded {json_file_name}")

    # Step 9: Read the JSON file
    with open(json_file_name, 'r') as json_file:
        data = json.load(json_file)

    # Step 10: Extract IPv4 addresses for the eastus region
    ipv4_addresses = []
    for value in data['values']:
        if value['id'] == 'AzureCloud.eastus':
            for prefix in value['properties']['addressPrefixes']:
                if ':' not in prefix:  # Check if the address is IPv4
                    ipv4_addresses.append(f'"{prefix}"')  # Ensure each IP is double-quoted

    # Step 11: Print the extracted IPv4 addresses
    print("IPv4 addresses for eastus region:")
    for address in ipv4_addresses:
        print(address)

    return version_formatted, ipv4_addresses

def main():
    releases = fetch_releases()
    if not releases:
        return

    versions = extract_versions(releases)
    
    # Get the latest minor versions for all major.minor versions
    latest_versions = get_latest_minor_versions(versions)
    
    # Sort the latest versions and get the last three
    sorted_latest_versions = sorted(latest_versions.items(), key=lambda x: (x[0][0], x[0][1]), reverse=True)[:3]

    # Debug print to check the structure of latest_versions
    print("Latest Versions:", sorted_latest_versions)

    # Fetch and process the JSON file
    new_tag_name, ip_addresses = fetch_and_process_json()

    # Update the main branch with the new IP addresses and version
    update_main_branch(ip_addresses, new_tag_name)

    # Create a branch for each latest version, incrementing the patch version
    for (major_minor, (patch, tag_name)) in sorted_latest_versions:
        print("Processing:", major_minor, patch, tag_name)  # Debug print
        major, minor = major_minor
        new_patch = patch + 1
        new_branch_name = f"release-v{major}.{minor}.{new_patch}"
        new_release_tag = f"v{major}.{minor}.{new_patch}"
        
        # Create the branch from the tag
        create_branch(new_branch_name, tag_name)
        
        # Update variable.tf and version.txt in the new branch with the JSON file version
        update_files(new_branch_name, new_tag_name, ip_addresses)
        
        # Create a new release from the new branch
        create_release(new_branch_name, new_release_tag)
        
        # Delete the branch after creating the release
        delete_branch(new_branch_name)

if __name__ == "__main__":
    main()
