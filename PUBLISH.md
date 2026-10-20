# Publishing the prepared RHOSO repository package

Target: `https://github.com/sheejithkv/RHOSO.git`.

The archive has *repository contents* at its root. To preserve any pre-existing GitHub
history, clone the remote first, then merge these files into the cloned folder. Do not
initialize an unrelated Git repository and force-push over the existing history.

## Windows PowerShell

Run in the directory containing `RHOSO-github-ready.zip`:

```powershell
git clone https://github.com/sheejithkv/RHOSO.git
Expand-Archive -Path .\RHOSO-github-ready.zip -DestinationPath .\RHOSO -Force
Set-Location .\RHOSO

git switch -c docs/rhoso-18x-admin-reference
git add README.md PUBLISH.md docs scripts source .gitignore .gitattributes .editorconfig .github

git diff --cached --stat
git diff --cached --check
bash -n scripts/rhoso-healthcheck.sh
git commit -m "docs: publish RHOSO 18.x administration runbook and health check"
git push -u origin docs/rhoso-18x-admin-reference
```

Open a pull request on GitHub to merge this branch after reviewing the diff. If the branch
name already exists, choose a new branch name and use that name for `git push`.

## Linux / macOS

```bash
git clone https://github.com/sheejithkv/RHOSO.git
unzip -o RHOSO-github-ready.zip -d RHOSO
cd RHOSO
git switch -c docs/rhoso-18x-admin-reference
git add README.md PUBLISH.md docs scripts source .gitignore .gitattributes .editorconfig .github
git diff --cached --stat
git diff --cached --check
bash -n scripts/rhoso-healthcheck.sh
git commit -m "docs: publish RHOSO 18.x administration runbook and health check"
git push -u origin docs/rhoso-18x-admin-reference
```

**Authorization:** GitHub requires your repository write access and GitHub authentication.
Never embed access tokens in URLs or commit credentials. Do not use `--force` on the remote.
If the remote is empty or default-branch naming differs, adapt the branch command only
after inspecting `git branch -a` and remote repository settings.