# Multi-Repository Merge Request Workflow

**Purpose:** Automate the process of creating merge requests across multiple Git repositories in a coordinated manner.

**Use Case:** When you need to apply changes across many repositories (e.g., catalog migration, API updates, dependency upgrades) and create merge requests for all of them.

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Workflow Steps](#workflow-steps)
4. [Step 1: Identify Modified Repositories](#step-1-identify-modified-repositories)
5. [Step 2: Create Git Commits](#step-2-create-git-commits)
6. [Step 3: Create and Push Branches](#step-3-create-and-push-branches)
7. [Step 4: Create Merge Requests](#step-4-create-merge-requests)
8. [Step 5: Format DMR List](#step-5-format-dmr-list)
9. [Python Script Reference](#python-script-reference)
10. [Troubleshooting](#troubleshooting)
11. [Best Practices](#best-practices)

---

## Overview

This workflow automates the creation of merge requests across multiple repositories using:
- **repo forall** - Execute commands across all repositories
- **Git** - Version control operations
- **Python script** - GitLab API automation
- **DMR format** - Standardized merge request list format

### Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. Make code changes across multiple repositories               │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 2. Identify modified repositories (repo forall + git status)    │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 3. Create commits with descriptive messages (repo forall)       │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 4. Create feature branch (repo forall + git checkout -B)        │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 5. Push branches to remote (repo forall + git push)             │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 6. Create merge requests (Python script + GitLab API)           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 7. Format DMR list for tracking/approval                        │
└─────────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

### Required Tools

- **repo** - Android repo tool for multi-repository management
- **git** - Version control system
- **python3** - Python 3.6 or later
- **GitLab Personal Access Token** - With `api` scope

### Environment Setup

```bash
# Verify tools are installed
repo version
git --version
python3 --version

# Set up Git identity (if not already configured)
git config --global user.name "Your Name"
git config --global user.email "your.email@company.com"
```

### GitLab Token

1. Go to: https://gitlabee.dt.renault.com/-/profile/personal_access_tokens
2. Create a new token with `api` scope
3. Copy the token value
4. Export it as an environment variable:
   ```bash
   export GITLAB_TOKEN="your_token_here"
   ```

---

## Workflow Steps

## Step 1: Identify Modified Repositories

After making code changes across multiple repositories, identify which ones have modifications.

### Command

```bash
repo forall -c '
if git status --porcelain | grep -q "^"; then
    echo "=== PROJECT: $REPO_PROJECT ==="
    git status --short
fi
' 2>/dev/null | grep -E "^(===|^ [MD])" > /tmp/modified_repos.txt
```

### Extract Repository List

```bash
repo forall -c '
if git status --porcelain | grep -q "^"; then
    REMOTE=$(git remote | head -1)
    REMOTE_URL=$(git remote get-url "$REMOTE" 2>/dev/null)
    if [ -n "$REMOTE_URL" ]; then
        echo "$REPO_PROJECT|$REMOTE_URL"
    fi
fi
' 2>/dev/null | grep "^platform\|^device\|^DICE" | sort -u > /tmp/repo_urls_clean.txt
```

### Verify

```bash
# Count modified repositories
wc -l /tmp/repo_urls_clean.txt

# View the list
cat /tmp/repo_urls_clean.txt
```

**Expected Output:**
```
platform_vendor_renault_vehicle_lifecycle_manager.git|https://gitlabee.dt.renault.com/sdv/platforms/sweet500/pcu/mainlines/pcu/platform_vendor_renault_vehicle_lifecycle_manager.git
platform_vendor_ampere_ltmc.git|https://gitlabee.dt.renault.com/sdv/domains/caros/mainlines/ampere/platform_vendor_ampere_ltmc.git
...
```

---

## Step 2: Create Git Commits

Create commits for all modified repositories with appropriate commit messages.

### Strategy

Choose a commit message strategy based on your changes:

**Option A: Same message for all repositories**
```bash
COMMIT_MSG="feat: Your feature description here"

repo forall -c '
if git status --porcelain | grep -q "^"; then
    echo "=== Committing: $REPO_PROJECT ==="
    git add -A
    git commit -m "'"$COMMIT_MSG"'"
fi
' 2>&1 | grep -E "^(===|\[)"
```

**Option B: Custom message per repository type**
```bash
repo forall -c '
if git status --porcelain | grep -q "^"; then
    echo "=== $REPO_PROJECT ==="
    
    # Determine commit message based on repo
    case "$REPO_PROJECT" in
        *"vehicle_lifecycle_manager"*)
            MSG="feat(nvm): Replace MessageFull with NvmMessage trait"
            ;;
        *"ltmc"*)
            MSG="feat(nvm): Migrate to NvmMessage trait system"
            ;;
        *)
            MSG="feat(catalog): Migrate to split protobuf catalogs"
            ;;
    esac
    
    git add -A
    git commit -m "$MSG"
    echo "Committed: $MSG"
fi
' 2>&1 | grep -E "^(===|Committed:)"
```

### Verify Commits

```bash
# Check that commits were created
repo forall -c '
if git log HEAD --not --remotes --oneline 2>/dev/null | grep -q "^"; then
    echo "$REPO_PROJECT: $(git log -1 --oneline)"
fi
' 2>/dev/null
```

---

## Step 3: Create and Push Branches

Create a feature branch in all modified repositories and push to remote.

### Create Branch

```bash
BRANCH_NAME="dev/pt/your_feature_name"

repo forall -c '
if git log HEAD --not --remotes --oneline 2>/dev/null | grep -q "^"; then
    echo "=== Creating branch in: $REPO_PROJECT ==="
    git checkout -B "'"$BRANCH_NAME"'"
    echo "Branch created: '"$BRANCH_NAME"'"
fi
' 2>&1 | grep -E "^(===|Branch created:)"
```

### Push Branches

```bash
repo forall -c '
BRANCH_NAME="dev/pt/your_feature_name"
if git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1; then
    echo "=== Pushing: $REPO_PROJECT ==="
    
    # Get the first remote (usually ampere, pcu, swcar, etc.)
    REMOTE=$(git remote | head -1)
    echo "Using remote: $REMOTE"
    
    # Check if remote branch exists
    if git ls-remote --heads "$REMOTE" "$BRANCH_NAME" 2>/dev/null | grep -q "$BRANCH_NAME"; then
        echo "Force pushing to existing remote branch..."
        git push -f "$REMOTE" "$BRANCH_NAME"
    else
        echo "Creating new remote branch..."
        git push -u "$REMOTE" "$BRANCH_NAME"
    fi
    
    if [ $? -eq 0 ]; then
        echo "✓ Successfully pushed $BRANCH_NAME"
    else
        echo "✗ Failed to push $BRANCH_NAME"
    fi
    echo "---"
fi
' 2>&1 | grep -E "^(===|Using|✓|✗|Creating|Force)"
```

### Verify Branches

```bash
# Verify all branches are on remote
repo forall -c '
BRANCH_NAME="dev/pt/your_feature_name"
if git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1; then
    REMOTE=$(git remote | head -1)
    if git ls-remote --heads "$REMOTE" "$BRANCH_NAME" 2>/dev/null | grep -q "$BRANCH_NAME"; then
        echo "✓ $REPO_PROJECT"
    else
        echo "✗ $REPO_PROJECT (branch not on remote)"
    fi
fi
' 2>/dev/null | sort
```

---

## Step 4: Create Merge Requests

Use the Python script to automatically create merge requests via GitLab API.

### Prerequisites

Ensure you have:
1. GitLab token exported: `export GITLAB_TOKEN="your_token"`
2. Repository list file: `/tmp/repo_urls_clean.txt`
3. Python script: `create_merge_requests.py`

### Run the Script

```bash
# Normal mode
python3 create_merge_requests.py

# Debug mode (to see API requests/responses)
DEBUG=1 python3 create_merge_requests.py
```

### Script Configuration

Before running, you may want to customize these variables in the script:

```python
# In create_merge_requests.py, edit these lines:

SOURCE_BRANCH = "dev/pt/your_feature_name"  # Your feature branch
TARGET_BRANCH = "sweet500-caros-stable-bl6.0"  # Target branch
MR_TITLE = "feat: Your feature title"  # MR title
MR_DESCRIPTION = """
Your detailed MR description here...
"""
```

### Expected Output

```
╔══════════════════════════════════════════════════════════════════════════════╗
║              Creating GitLab Merge Requests for SSOT Lite Migration         ║
╚══════════════════════════════════════════════════════════════════════════════╝

Configuration:
  GitLab Host: https://gitlabee.dt.renault.com
  Source Branch: dev/pt/your_feature_name
  Target Branch: sweet500-caros-stable-bl6.0
  Debug Mode: OFF

Found 28 repositories to process

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Creating MR for: platform_vendor_renault_vehicle_lifecycle_manager.git
Project ID: sdv%2Fplatforms%2Fsweet500%2Fpcu%2Fmainlines%2Fpcu%2Fplatform_vendor_renault_vehicle_lifecycle_manager
Source branch: dev/pt/your_feature_name
Target branch: sweet500-caros-stable-bl6.0
✅ SUCCESS: MR !57 created
   URL: https://gitlabee.dt.renault.com/sdv/platforms/sweet500/pcu/mainlines/pcu/platform_vendor_renault_vehicle_lifecycle_manager/-/merge_requests/57

...

╔══════════════════════════════════════════════════════════════════════════════╗
║                              SUMMARY                                         ║
╚══════════════════════════════════════════════════════════════════════════════╝

Total repositories: 28
✅ Successfully created: 20
⚠️  Already existed: 8
❌ Failed: 0

Merge Request URLs:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
platform_vendor_renault_vehicle_lifecycle_manager.git        !57    https://...
platform_vendor_ampere_ltmc.git                              !80    https://...
...

📋 DMR list format available in: /tmp/dmr_list.txt

Results saved to: /tmp/mr_results.txt
DMR list saved to: /tmp/dmr_list.txt
Done! 🎉
```

### Output Files

The script automatically generates two output files:

1. **`/tmp/mr_results.txt`** - Raw results in pipe-delimited format
2. **`/tmp/dmr_list.txt`** - DMR format ready for tracking/approval

```bash
# View raw results
cat /tmp/mr_results.txt

# View DMR list (ready to use)
cat /tmp/dmr_list.txt

# Count DMRs
grep -c "^DMR:" /tmp/dmr_list.txt

# Count by status
grep -c "SUCCESS" /tmp/mr_results.txt
grep -c "ALREADY_EXISTS" /tmp/mr_results.txt
grep -c "FAILED" /tmp/mr_results.txt
```

---

## Step 5: Use DMR List

The Python script automatically generates a DMR (Dependent Merge Request) list for tracking and approval.

### Automatic Generation

The script automatically creates `/tmp/dmr_list.txt` with all successful merge requests in DMR format. No manual conversion needed!

```bash
# View the DMR list
cat /tmp/dmr_list.txt

# Count total DMRs
grep -c "^DMR:" /tmp/dmr_list.txt
```

### Manual Conversion (if needed)

If you need to regenerate the DMR list from existing results:

```bash
# Convert results to DMR format
grep -E "SUCCESS|ALREADY_EXISTS" /tmp/mr_results.txt | \
  cut -d'|' -f2 | \
  awk '{print "DMR: " $0 "\n"}' > /tmp/dmr_list.txt
```


### DMR Format Specification

The DMR format is:
```
DMR: <full_gitlab_merge_request_url>

DMR: <full_gitlab_merge_request_url>

...
```

**Example:**
```
DMR: https://gitlabee.dt.renault.com/sdv/platforms/sweet500/pcu/mainlines/pcu/platform_vendor_renault_vehicle_lifecycle_manager/-/merge_requests/57

DMR: https://gitlabee.dt.renault.com/sdv/domains/caros/mainlines/ampere/platform_vendor_ampere_ltmc/-/merge_requests/80

DMR: https://gitlabee.dt.renault.com/sdv/platforms/sweet500/pcu/mainlines/pcu/platform_vendor_renault_adas_services/-/merge_requests/335
```

### Merge Multiple DMR Lists

If you have multiple DMR lists from different sessions, use the merge utility:

```bash
# Merge two lists (output to stdout)
python3 merge_dmr_lists.py old_list.txt new_list.txt

# Merge multiple lists to a file
python3 merge_dmr_lists.py list1.txt list2.txt list3.txt -o merged.txt

# Merge with existing merged list
python3 merge_dmr_lists.py merged_mr_list.txt /tmp/dmr_list.txt -o updated_merged.txt
```

The merge utility:
- Removes duplicates (same project)
- Keeps the higher MR number (newer MR)
- Sorts output by project path
- Validates DMR format

### Validate DMR List

```bash
# Count DMRs
grep -c "^DMR:" /tmp/dmr_list.txt

# Check for duplicates
grep "^DMR:" /tmp/dmr_list.txt | sort | uniq -d

# Verify all URLs are valid
grep "^DMR:" /tmp/dmr_list.txt | \
  grep -v "https://gitlabee.dt.renault.com" && \
  echo "Invalid URLs found!" || \
  echo "All URLs valid"
```

---

## Python Script Reference

### Full Script: `create_merge_requests.py`

see `.opencode/skills/mr_creation/create_merge_requests.py`

### Script Customization

Edit these variables at the top of the script:

```python
# Branch names
SOURCE_BRANCH = "dev/<developer_initials>/your_feature_name"
TARGET_BRANCH = "sweet500-caros-stable-bl6.0"  # or "main", "master", etc.

# MR details
MR_TITLE = "feat: Your feature title"
MR_DESCRIPTION = """
Your detailed description here...
"""
```

---

## Troubleshooting

### Issue: "Repository list file not found"

**Solution:**
```bash
# Regenerate the repository list
repo forall -c '
if git status --porcelain | grep -q "^"; then
    REMOTE=$(git remote | head -1)
    REMOTE_URL=$(git remote get-url "$REMOTE" 2>/dev/null)
    if [ -n "$REMOTE_URL" ]; then
        echo "$REPO_PROJECT|$REMOTE_URL"
    fi
fi
' 2>/dev/null | grep "^platform\|^device\|^DICE" | sort -u > /tmp/repo_urls_clean.txt
```

### Issue: "GITLAB_TOKEN not set"

**Solution:**
```bash
export GITLAB_TOKEN="your_token_here"
```

### Issue: "HTTP 401 Unauthorized"

**Cause:** Invalid or expired GitLab token

**Solution:**
1. Go to https://gitlabee.dt.renault.com/-/profile/personal_access_tokens
2. Create a new token with `api` scope
3. Export the new token

### Issue: "HTTP 404 Not Found"

**Cause:** Project path is incorrect or you don't have access

**Solution:**
1. Verify the repository URL is correct
2. Check you have access to the repository
3. Verify the project exists on GitLab

### Issue: "MR already exists but URL is N/A"

**Cause:** API couldn't retrieve existing MR details

**Solution:**
1. Check GitLab manually: `https://gitlabee.dt.renault.com/[project-path]/-/merge_requests`
2. Search for MRs with your source branch
3. Use DEBUG mode to see API responses: `DEBUG=1 python3 create_merge_requests.py`

### Issue: "Branch not found on remote"

**Cause:** Branch wasn't pushed successfully

**Solution:**
```bash
# Re-push the branch
BRANCH_NAME="dev/pt/your_feature_name"
repo forall -c '
if git rev-parse --verify "'"$BRANCH_NAME"'" >/dev/null 2>&1; then
    REMOTE=$(git remote | head -1)
    git push -f "$REMOTE" "'"$BRANCH_NAME"'"
fi
'
```

---

## Best Practices

### 1. Branch Naming Convention

Use a consistent naming pattern:
- `dev/<username>/<feature_name>` - Development branches
- `feat/<feature_name>` - Feature branches
- `fix/<bug_name>` - Bug fix branches
- `refactor/<refactor_name>` - Refactoring branches

### 2. Commit Message Guidelines

Follow conventional commits:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring
- `docs`: Documentation changes
- `test`: Test changes
- `chore`: Build/tooling changes

**Example:**
```
feat(nvm): Replace MessageFull with NvmMessage trait

- Migrate storage_manager.rs to use NvmMessage + Debug trait
- Add libltmc_traits dependency to Android.bp
- Part of SSOT Lite migration to remove MessageFull dependencies
```

### 3. MR Description Template

Include these sections:
- **Summary** - What changed and why
- **Changes** - Detailed list of modifications
- **Testing** - How it was tested
- **Related MRs** - Links to dependent MRs
- **Checklist** - Pre-merge verification items

### 4. Batch Processing

Process repositories in batches if you have many:
```bash
# Process first 10 repos
head -10 /tmp/repo_urls_clean.txt > /tmp/batch1.txt
# Update script to use /tmp/batch1.txt
python3 create_merge_requests.py
```

### 5. Verification Steps

Before creating MRs:
1. ✅ All changes committed
2. ✅ Branches pushed to remote
3. ✅ Build passes locally
4. ✅ Commit messages are descriptive
5. ✅ MR description is complete

After creating MRs:
1. ✅ All MRs created successfully
2. ✅ DMR list generated
3. ✅ No duplicate MRs
4. ✅ All URLs are valid

### 6. Rate Limiting

The script includes a 1-second delay between requests. If you hit rate limits:
```python
# Increase delay in the script
time.sleep(2)  # Change from 1 to 2 seconds
```

### 7. Dry Run

Test the workflow on a small subset first:
```bash
# Create a test list with 2-3 repos
head -3 /tmp/repo_urls_clean.txt > /tmp/test_repos.txt

# Update script to use test list
# Then run the script
python3 create_merge_requests.py
```

---

## Summary Checklist

Use this checklist for each multi-repo MR workflow:

- [ ] **Step 1:** Identify modified repositories
  - [ ] Run `repo forall` to find changes
  - [ ] Generate `/tmp/repo_urls_clean.txt`
  - [ ] Verify repository count

- [ ] **Step 2:** Create commits
  - [ ] Stage all changes (`git add -A`)
  - [ ] Create commits with descriptive messages
  - [ ] Verify commits created

- [ ] **Step 3:** Create and push branches
  - [ ] Create feature branch
  - [ ] Push to remote
  - [ ] Verify branches on remote

- [ ] **Step 4:** Create merge requests
  - [ ] Export `GITLAB_TOKEN`
  - [ ] Customize script configuration
  - [ ] Run `create_merge_requests.py`
  - [ ] Review results

- [ ] **Step 5:** Format DMR list
  - [ ] Convert results to DMR format
  - [ ] Merge with existing DMR list (if needed)
  - [ ] Validate DMR list
  - [ ] Save final list

- [ ] **Post-workflow:**
  - [ ] Add reviewers to MRs
  - [ ] Monitor CI/CD pipelines
  - [ ] Address review comments
  - [ ] Coordinate merging

---

## Appendix: Quick Reference

### Essential Commands

```bash
# Find modified repos
repo forall -c 'git status --porcelain | grep -q "^" && echo $REPO_PROJECT'

# Create commits
repo forall -c 'git status --porcelain | grep -q "^" && git add -A && git commit -m "Your message"'

# Create branch
repo forall -c 'git checkout -B dev/pt/feature_name'

# Push branches
repo forall -c 'git push -u $(git remote | head -1) dev/pt/feature_name'

# Create MRs
GITLAB_TOKEN=xxx python3 create_merge_requests.py

# Generate DMR list
grep -E "SUCCESS|ALREADY_EXISTS" /tmp/mr_results.txt | cut -d'|' -f2 | sed 's/^/DMR: /' > dmr_list.txt
```

### File Locations

- Repository list: `/tmp/repo_urls_clean.txt`
- MR results: `/tmp/mr_results.txt`
- DMR list: `/tmp/dmr_list.txt`
- Python script: `create_merge_requests.py`

### Environment Variables

- `GITLAB_TOKEN` - GitLab personal access token (required)
- `DEBUG` - Enable debug mode (optional, set to `1`)

---

**End of Documentation**
