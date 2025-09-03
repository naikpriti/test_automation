import requests
import re
from collections import defaultdict
import os
import subprocess
import time
import json
from packaging import version
from bs4 import BeautifulSoup
import shutil
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import sys

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

def send_email(subject, body):
    # Configure these via environment variables or update with your values.
    smtp_server = os.getenv("SMTP_SERVER", "Appmail-test.risk.regn.net'")
    smtp_port = int(os.getenv("SMTP_PORT", "25"))
    smtp_username = os.getenv("SMTP_USERNAME", "")
    smtp_password = os.getenv("SMTP_PASSWORD", "")
    recipients = os.getenv("EMAIL_RECIPIENTS", "priti.naik@lexisnexisrisk.com")

    msg = MIMEMultipart()
    msg["From"] = smtp_username
    msg["To"] = ", ".join(recipients)
    msg["Subject"] = subject
    msg.attach(MIMEText(body, "plain"))

    try:
        with smtplib.SMTP(smtp_server, smtp_port) as server:
            server.starttls()
            server.login(smtp_username, smtp_password)
            server.sendmail(smtp_username, recipients, msg.as_string())
        print(f"Email sent to {', '.join(recipients)}")
    except Exception as e:
        print(f"Failed to send email: {e}")

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

def update_files(branch_name, new_tag_name, ip_addresses):
    if os.path.exists(repo):
        subprocess.run(["rm", "-rf", repo])
    subprocess.run(["git", "clone", f"https://{token}@github.com/{owner}/{repo}.git"])
    os.chdir(repo)
    subprocess.run(["git", "fetch", "origin"])
    subprocess.run(["git", "checkout", branch_name])
    subprocess.run(["git", "config", "user.email", "priti.naik@elexisnexisrisk.com"])
    subprocess.run(["git", "config", "user.name", "naikpriti"])
    variable_tf_path = os.path.join("key-vault", "variables.tf")
    update_variables_tf(variable_tf_path, ip_addresses)
    if shutil.which("terraform"):
        subprocess.run(["terraform", "fmt", variable_tf_path])
    else:
        print("Terraform not found. Skipping formatting step.")
    os.makedirs("automation_scripts", exist_ok=True)
    version_txt_path = os.path.join("automation_scripts", "version.txt")
    with open(version_txt_path, "w") as f:
        f.write(f"Version: {new_tag_name}")
    subprocess.run(["git", "add", variable_tf_path, version_txt_path])
    subprocess.run(["git", "commit", "-m", f"Update variables.tf and version.txt for release {new_tag_name}"])
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

def update_main_branch(ip_addresses, new_tag_name):
    if os.path.exists(repo):
        subprocess.run(["rm", "-rf", repo])
    subprocess.run(["git", "clone", f"https://{token}@github.com/{owner}/{repo}.git"])
    os.chdir(repo)
    subprocess.run(["git", "checkout", "main"])
    subprocess.run(["git", "config", "user.email", "priti.naik@elexisnexisrisk.com"])
    subprocess.run(["git", "config", "user.name", "naikpriti"])
    variable_tf_path = os.path.join("key-vault", "variables.tf")
    update_variables_tf(variable_tf_path, ip_addresses)
    if shutil.which("terraform"):
        subprocess.run(["terraform", "fmt", variable_tf_path])
    else:
        print("Terraform not found. Skipping formatting step.")
    os.makedirs("automation_scripts", exist_ok=True)
    version_txt_path = os.path.join("automation_scripts", "version.txt")
    with open(version_txt_path, "w") as f:
        f.write(f"Version: {new_tag_name}")
    subprocess.run(["git", "add", variable_tf_path, version_txt_path])
    subprocess.run(["git", "commit", "-m", f"Update variables.tf and version.txt for release {new_tag_name}"])
    subprocess.run(["git", "push", "origin", "main"])
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
                continue
            else:
                file.write(line)
    return updated

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
                if ':' not in prefix:
                    ipv4_addresses.append(f'"{prefix}"')
    print("IPv4 addresses for eastus region:")
    for address in ipv4_addresses:
        print(address)
    return version_formatted, ipv4_addresses

def main():
    release_summary = []
    releases = fetch_releases()
    if not releases:
        return
    versions = extract_versions(releases)
    latest_versions = get_latest_minor_versions(versions)
    sorted_latest_versions = sorted(latest_versions.items(), key=lambda x: (x[0][0], x[0][1]), reverse=True)[:3]
    print("Latest Versions:", sorted_latest_versions)
    new_tag_name, ip_addresses = fetch_and_process_json()
    update_main_branch(ip_addresses, new_tag_name)
    for (major_minor, (patch, tag_name)) in sorted_latest_versions:
        print("Processing:", major_minor, patch, tag_name)
        major, minor = major_minor
        new_patch = patch + 1
        new_branch_name = f"release-v{major}.{minor}.{new_patch}"
        new_release_tag = f"v{major}.{minor}.{new_patch}"
        create_branch(new_branch_name, tag_name)
        update_files(new_branch_name, new_tag_name, ip_addresses)
        create_release(new_branch_name, new_release_tag)
        delete_branch(new_branch_name)
        release_summary.append(new_release_tag)
    if release_summary:
        subject = f"New Releases Created: {', '.join(release_summary)}"
        body = "The following new releases were created with updated IPs:\n\n" + "\n".join(release_summary)
        send_email(subject, body)

if __name__ == "__main__":
    try:
        main()
    except SystemExit as se:
        # When IPs are already updated, we exit with code 1 and skip emailing
        if se.code != 1:
            send_email("IP Automation Failure", f"Exited with status: {se.code}")
        sys.exit(se.code)
    except Exception as ex:
        send_email("IP Automation Failure", f"Error: {ex}")
        raise ex
