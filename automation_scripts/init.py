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
            versions[(major, minor)].append((patch, release["tag_name"]))
    return versions

def get_latest_minor_versions(versions):
    latest_versions = {}
    for major_minor, patches in versions.items():
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
    data = {
        "ref": f"refs/heads/{branch_name}",
        "sha": sha
    }
    response = requests.post(branch_url, headers=headers, json=data)
    if response.status_code == 201:
        print(f"Branch '{branch_name}' created successfully.")
    else:
        print(f"Error creating branch '{branch_name}': {response.status_code} - {response.json()}")

def update_variables_tf(file_path, ip_addresses):
    # Build the new IP list string exactly as expected (e.g. ["104.44.95.160/27", "10.0.0.0/24"])
    new_ip_str = '[' + ", ".join(ip_addresses) + ']'
    with open(file_path, 'r') as file:
        lines = file.readlines()
    
    current_ip_str = None
    for line in lines:
        striped = line.strip()
        if striped.startswith("default ="):
            current_ip_str = striped.split("=", 1)[1].strip()
            break

    if current_ip_str == new_ip_str:
        print("No new IP addresses found. Skipping update of variables.tf.")
        return False, []

    # Parse current IPs to find newly added ones
    current_ips = set()
    if current_ip_str:
        # Remove brackets and split by comma, then clean each IP
        current_ip_list = current_ip_str.strip('[]').split(',')
        current_ips = {ip.strip().strip('"') for ip in current_ip_list if ip.strip()}
    
    # Get new IPs (without quotes for comparison)
    new_ips = {ip.strip('"') for ip in ip_addresses}
    newly_added_ips = list(new_ips - current_ips)
    
    new_lines = []
    inside_default_block = False
    for line in lines:
        if 'variable "azure_allowed_ip_list"' in line:
            inside_default_block = True
            new_lines.append(line)
        elif inside_default_block and line.strip().startswith("default ="):
            new_lines.append(f'  default = {new_ip_str}\n')
            inside_default_block = False
        elif inside_default_block and line.strip().startswith('['):
            continue
        else:
            new_lines.append(line)
    
    with open(file_path, 'w') as file:
        file.writelines(new_lines)
        
    print("Updated variables.tf with new IP addresses.")
    return True, newly_added_ips

def update_module_versions(new_release_tag):
    """Update module_version in all local.tf files to the new release tag"""
    # Define the modules and their local.tf file paths
    modules = [
        "controlplane/local.tf",
        "user-node-group/local.tf", 
        "system-node-group/local.tf",
        "ingress/local.tf"
    ]
    
    for module_path in modules:
        if os.path.exists(module_path):
            with open(module_path, 'r') as file:
                content = file.read()
            
            # For ingress module, version doesn't have 'v' prefix
            if "ingress/local.tf" in module_path:
                # Remove 'v' prefix for ingress module
                version_to_use = new_release_tag.lstrip('v')
                # Update module_version line in ingress
                updated_content = re.sub(
                    r'(module_version\s*=\s*")[^"]*(")',
                    r'\g<1>' + version_to_use + r'\g<2>',
                    content
                )
            else:
                # Keep 'v' prefix for other modules
                updated_content = re.sub(
                    r'(module_version\s*=\s*")[^"]*(")',
                    r'\g<1>' + new_release_tag + r'\g<2>',
                    content
                )
            
            if updated_content != content:
                with open(module_path, 'w') as file:
                    file.write(updated_content)
                print(f"Updated module_version in {module_path} to {new_release_tag}")
            else:
                print(f"No changes needed for {module_path}")
        else:
            print(f"Warning: {module_path} not found")

def update_files(branch_name, new_tag_name, ip_addresses, new_release_tag):
    if os.path.exists(repo):
        subprocess.run(["rm", "-rf", repo])
    subprocess.run(["git", "clone", f"https://{token}@github.com/{owner}/{repo}.git"])
    os.chdir(repo)
    subprocess.run(["git", "fetch", "origin"])
    subprocess.run(["git", "checkout", branch_name])
    subprocess.run(["git", "config", "user.email", "priti.naik@elexisnexisrisk.com"])
    subprocess.run(["git", "config", "user.name", "naikpriti"])
    
    # Update IP addresses in variables.tf
    variable_tf_path = os.path.join("key-vault", "variables.tf")
    ip_updated, newly_added_ips = update_variables_tf(variable_tf_path, ip_addresses)
    subprocess.run(["terraform", "fmt", variable_tf_path])
    
    # Update module versions in all local.tf files
    update_module_versions(new_release_tag)
    
    # Format all local.tf files
    local_tf_files = ["controlplane/local.tf", "user-node-group/local.tf", "system-node-group/local.tf", "ingress/local.tf"]
    for tf_file in local_tf_files:
        if os.path.exists(tf_file):
            subprocess.run(["terraform", "fmt", tf_file])
    
    # Update version.txt
    os.makedirs("automation_scripts", exist_ok=True)
    version_txt_path = os.path.join("automation_scripts", "version.txt")
    # Always update version.txt with the new version
    with open(version_txt_path, "w") as f:
        f.write(f"Version: {new_tag_name}")
    
    # Add all modified files to git
    subprocess.run(["git", "add", variable_tf_path, version_txt_path])
    # Add all local.tf files that might have been modified
    subprocess.run(["git", "add", "controlplane/local.tf", "user-node-group/local.tf", "system-node-group/local.tf", "ingress/local.tf"])
    
    subprocess.run(["git", "commit", "-m", f"Update variables.tf, version.txt, and module versions for release {new_release_tag}"])
    try:
        subprocess.run(["git", "pull", "--rebase", "origin", branch_name], check=True)
    except subprocess.CalledProcessError:
        print("Conflict detected, resolving manually...")
        subprocess.run(["git", "rebase", "--continue"])
    push_result = subprocess.run(["git", "push", "-u", "origin", branch_name])
    if push_result.returncode != 0:
        print(f"Non-fast-forward push detected, force pushing branch '{branch_name}'")
        subprocess.run(["git", "push", "-u", "--force", "origin", branch_name])
    os.chdir("..")
    return ip_updated, newly_added_ips

def update_main_branch(ip_addresses, new_tag_name, latest_release_tag=None):
    if os.path.exists(repo):
        subprocess.run(["rm", "-rf", repo])
    subprocess.run(["git", "clone", f"https://{token}@github.com/{owner}/{repo}.git"])
    os.chdir(repo)
    subprocess.run(["git", "checkout", "main"])
    subprocess.run(["git", "config", "user.email", "priti.naik@elexisnexisrisk.com"])
    subprocess.run(["git", "config", "user.name", "naikpriti"])
    
    # Update variables.tf and record if IP list changed
    variable_tf_path = os.path.join("key-vault", "variables.tf")
    ip_updated, newly_added_ips = update_variables_tf(variable_tf_path, ip_addresses)
    subprocess.run(["terraform", "fmt", variable_tf_path])
    
    # Update module versions in main branch if latest_release_tag is provided
    if latest_release_tag:
        update_module_versions(latest_release_tag)
        # Format all local.tf files
        local_tf_files = ["controlplane/local.tf", "user-node-group/local.tf", "system-node-group/local.tf", "ingress/local.tf"]
        for tf_file in local_tf_files:
            if os.path.exists(tf_file):
                subprocess.run(["terraform", "fmt", tf_file])
    
    # Update version.txt
    os.makedirs("automation_scripts", exist_ok=True)
    version_txt_path = os.path.join("automation_scripts", "version.txt")
    # Always update version.txt as version changes over time
    with open(version_txt_path, "w") as f:
        f.write(f"Version: {new_tag_name}")
    
    subprocess.run(["git", "add", variable_tf_path, version_txt_path])
    # Add all local.tf files that might have been modified
    if latest_release_tag:
        subprocess.run(["git", "add", "controlplane/local.tf", "user-node-group/local.tf", "system-node-group/local.tf", "ingress/local.tf"])
        subprocess.run(["git", "commit", "-m", f"Update version.txt and module versions for release {new_tag_name}"])
    else:
        subprocess.run(["git", "commit", "-m", f"Update version.txt for release {new_tag_name}"])
    
    subprocess.run(["git", "push", "origin", "main"])
    os.chdir("..")
    return ip_updated, newly_added_ips

def create_release(branch_name, new_tag_name, newly_added_ips, make_latest=False):
    # Create release body with newly added IP addresses
    if newly_added_ips:
        ip_list = "\n".join([f"- {ip}" for ip in newly_added_ips])
        ip_section = f"""## New IP Addresses Detected
{ip_list}"""
    else:
        ip_section = "## New IP Addresses Detected\nNo new IP addresses detected in this release."
    
    release_body = f"""Release {new_tag_name}

## Changes
- Updated Azure IP addresses for eastus region
- Updated module versions to {new_tag_name}

{ip_section}
"""
    
    data = {
         "tag_name": new_tag_name,
        "target_commitish": branch_name,
        "name": new_tag_name,
        "body": release_body,
        "draft": False,
        "prerelease": False,
        # Force which release is latest
        "make_latest": "true" if make_latest else "false"
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

def fetch_and_process_json():
    response = requests.get(download_page_url, headers={'User-Agent': 'Github Actions'})
    if response.status_code != 200:
        print(f"Failed to fetch the confirmation page. Status code: {response.status_code}")
        exit(2)
    soup = BeautifulSoup(response.content, 'html.parser')
    download_link = soup.find('a', href=re.compile(r'ServiceTags_Public_\d{8}\.json'))
    if not download_link:
        print("Download link not found")
        exit(2)
    json_file_name = download_link['href'].split('/')[-1]
    version_date = re.search(r'\d{8}', json_file_name).group(0)
    version_formatted = f"{version_date[:4]}.{version_date[4:6]}.{version_date[6:]}"
    version_file = os.path.join("automation_scripts", "version.txt")
    with open(version_file, 'r') as file:
        current_version_line = next((line for line in file if line.startswith('Version:')), None)
        if current_version_line:
            current_version = current_version_line.split('Version:')[1].strip()
        else:
            print(f"Version line not found in {version_file}")
            exit(2)
    if version.parse(version_formatted) <= version.parse(current_version):
        print("IPs are already updated with the latest version.")
        exit(1)
    download_url = download_link['href']
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
    with open(json_file_name, 'wb') as json_file:
        json_file.write(json_response.content)
    print(f"Downloaded {json_file_name}")
    with open(json_file_name, 'r') as json_file:
        data = json.load(json_file)
    ipv4_addresses = []
    for value in data['values']:
        if value['id'] == 'AzureCloud.eastus':
            for prefix in value['properties']['addressPrefixes']:
                if ':' not in prefix:  # Check IPv4 including CIDR
                    ipv4_addresses.append(f'"{prefix}"')
    print("IPv4 addresses for eastus region:")
    for address in ipv4_addresses:
        print(address)
    return version_formatted, ipv4_addresses

def main():
    releases = fetch_releases()
    if not releases:
        return
    versions = extract_versions(releases)
    latest_versions = get_latest_minor_versions(versions)
    # Sort in descending order so that the highest version is first.
    sorted_latest_versions = sorted(latest_versions.items(), key=lambda x: (x[0][0], x[0][1]), reverse=True)[:3]
    print("Sorted Versions:", sorted_latest_versions)
    new_tag_name, ip_addresses = fetch_and_process_json()
    
    # Determine the latest release tag that will be created
    latest_release_tag = None
    if sorted_latest_versions:
        major, minor = sorted_latest_versions[0][0]
        patch = sorted_latest_versions[0][1][0]
        latest_release_tag = f"v{major}.{minor}.{patch + 1}"
    
    # Always update the main branch with the new version.
    ip_updated, main_branch_new_ips = update_main_branch(ip_addresses, new_tag_name, latest_release_tag)
    if not ip_updated:
        print("No new IP addresses found in main branch. Skipping release branch creation.")
        exit(0)
    # Iterate over all version groups.
    # GitHub will mark the highest semver release as the latest.
    for idx, ((major, minor), (patch, tag_name)) in enumerate(sorted_latest_versions):
        new_patch = patch + 1
        new_branch_name = f"release-v{major}.{minor}.{new_patch}"
        new_release_tag = f"v{major}.{minor}.{new_patch}"
        print(f"Processing version group: {major}.{minor}, patch {patch} -> creating release {new_release_tag}")
        create_branch(new_branch_name, tag_name)
        branch_ip_updated, branch_new_ips = update_files(new_branch_name, new_tag_name, ip_addresses, new_release_tag)
        # Use the newly added IPs from the branch (should be the same as main branch)
        create_release(new_branch_name, new_release_tag, branch_new_ips, make_latest=(idx == 0))
        delete_branch(new_branch_name)

if __name__ == "__main__":
    main()