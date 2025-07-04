# Contributing to Summer 2025 Go + Flutter Course

This guide explains how to submit lab assignments and participate in the collaborative learning process.

## 🔄 Submission Workflow

### Initial Setup (One-time)
1. **Fork** this repository to your GitHub account
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/sum25-go-flutter-course.git
   cd sum25-go-flutter-course
   ```
3. **Add upstream** remote:
   ```bash
   git remote add upstream https://github.com/timur-harin/sum25-go-flutter-course.git
   ```
4. **Install dependencies**:
   ```bash
   make setup
   ```

### Lab Submission Process (Step-by-Step with Screenshots)

#### Step 0: Update Branch Using Sync Fork
![Step 0: Update Branch Using Sync Fork](assets/0.%20update%20branch%20using%20sync%20fork.png)

1. Go to your fork on GitHub
2. Click "Sync fork" to update your repository with the latest changes from the base repository
3. This ensures you have the most recent version before starting your lab work

#### Step 1: Git Pull
![Step 1: Git Pull](assets/1.%20git%20pull.png)

```bash
# Pull the latest changes from upstream
git checkout main
git pull upstream main
git push origin main
```

#### Step 2: Checkout
![Step 2: Checkout](assets/2.%20checkout.png)

```bash
# Create and checkout a new branch for your lab
git checkout -b lab01-surname-name
```

**Branch naming convention**: `labXX-surname-name` (all lowercase, no spaces, like in Moodle)
- ✅ `lab01-smith-john`
- ✅ `lab03-garcia-maria`
- ❌ `lab01-John-Smith`
- ❌ `lab01_john_smith`

#### Step 3: Commit and Push Your Changes
![Step 3: Commit and Push](assets/3.%20commit%20and%20push.png)

```bash
# Stage your changes
git add .

# Commit with a descriptive message
git commit -m "lab01: implement user authentication with JWT

- Add login/logout endpoints in Go backend
- Implement authentication screens in Flutter
- Add JWT token validation middleware
- Include comprehensive unit tests
- Update documentation"

# Push to your fork
git push origin lab01-surname-name
```

**Commit message guidelines**:
- Start with `labXX:` prefix
- Use present tense ("add" not "added")
- Include what was implemented
- Mention tests and documentation updates

#### Step 4: Create Local Pull Request
![Step 4: Create Local Pull Request](assets/4.%20create%20local%20pull%20request.png)

1. Go to your fork on GitHub
2. Click "Compare & pull request" for your lab branch
3. **Title**: `Lab XX: [Brief description] - Surname Name`
4. **Description**: Use the template below

#### Step 5: Write Information for Local PR
![Step 5: Write Information for Local PR](assets/5.%20write%20info%20for%20local%20pr.png)

Fill out the pull request template with:
- What was implemented
- How to test
- Questions/Notes
- Checklist completion

#### Step 6: See Open Status
![Step 6: See Open Status](assets/6.%20see%20open%20status.png)

Verify that your pull request is open and the workflow is running.

#### Step 7: Wait and Check Workflow
![Step 7: Wait and Check Workflow](assets/7.%20wait%20and%20check%20that%20full%20workflow%20is%20correct%20-%20you%20see%20comment%20with%20points.png)

Wait for the automated workflow to complete and check that you see a comment with your points/score.

#### Step 8: Create Pull Request to Base Repository
![Step 8: Create Pull Request to Base Repository](assets/8.%20create%20pull%20request%20to%20base%20repo.png)

1. Go to the main course repository
2. Create a new pull request from your fork
3. This will be your final submission

#### Step 9: See Pull Request to Base is Blocked
![Step 9: See Pull Request to Base is Blocked](assets/9.%20see%20pull%20request%20to%20base%20is%20blocked.png)

The pull request to the base repository should be blocked (this is expected).

#### Step 10: Copy Link to Local PR
![Step 10: Copy Link to Local PR](assets/10.%20copy%20link%20to%20local%20pr.png)

Copy the URL of your local pull request (from your fork).

#### Step 11: Put Link to Local PR into Description
![Step 11: Put Link to Local PR into Description](assets/11.%20put%20link%20to%20local%20pr%20into%20desciption%20to%20global%20pr.png)

Add the link to your local pull request in the description of the global pull request.

#### Step 12: Check That It is Correct
![Step 12: Check That It is Correct](assets/12.%20check%20that%20it%20is%20correct.png)

Double-check that all information is correct and complete.

#### Step 13: Copy Link to Global PR
![Step 13: Copy Link to Global PR](assets/13.%20copy%20link%20to%20global%20pr.png)

Copy the URL of your global pull request (to the base repository).

#### Step 14: Submit Link to Global PR into Moodle
![Step 14: Submit Link to Global PR into Moodle](assets/14.%20submit%20link%20to%20global%20pr%20into%20moodle.png)

Submit the link to your global pull request in Moodle for grading.

### 🔄 Getting Updates While Working on Your Branch

If you're already working on your lab branch and the base repository has been updated (new features, bug fixes, etc.), you'll need to get those updates into your branch. Here's how:

> **⚠️ Important**: Before updating your branch, make sure to commit or stash your current changes. If you have uncommitted changes, Git will prevent you from switching branches or updating.
>
> ```bash
> # Check if you have uncommitted changes
> git status
> 
> # If you have changes, either commit them:
> git add .
> git commit -m "WIP: save current progress before updating branch"
> 
> # OR stash them temporarily:
> git stash push -m "WIP: save changes before updating branch"
> # Later, restore with: git stash pop
> ```

#### Option 1: Rebase Your Branch (Recommended)
```bash
# Switch to main branch and update it
git checkout main
git pull upstream main
git push origin main

# Switch back to your lab branch
git checkout lab01-surname-name

# Rebase your branch onto the updated main
git rebase main
```

**What this does**: Replays your commits on top of the updated main branch, keeping a clean history.

#### Option 2: Merge Updates into Your Branch
```bash
# Switch to main branch and update it
git checkout main
git pull upstream main
git push origin main

# Switch back to your lab branch
git checkout lab01-surname-name

# Merge the updated main into your branch
git merge main
```

**What this does**: Creates a merge commit that combines your work with the updates.

#### Handling Conflicts
If you encounter conflicts during rebase or merge:

1. **Git will pause** and show you which files have conflicts
2. **Open the conflicted files** and look for conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)
3. **Edit the files** to resolve conflicts by choosing which changes to keep
4. **Stage the resolved files**:
   ```bash
   git add <filename>
   ```
5. **Continue the process**:
   - For rebase: `git rebase --continue`
   - For merge: `git commit` (Git will create a merge commit)

#### When to Update Your Branch
- **Before starting new work** on your lab
- **When you see announcements** about base repository updates
- **If you encounter issues** that might be fixed in recent updates
- **Before submitting** your final pull request

#### Pro Tip: Check for Updates Regularly
```bash
# Check if there are updates without switching branches
git fetch upstream
git log HEAD..upstream/main --oneline
```
If this command shows commits, there are updates available.

### Lab Development Process

#### Complete the Assignment
1. Navigate to the lab directory: `labs/labXX/`
2. Read the `README.md` for specific requirements
3. Implement both **Go backend** and **Flutter frontend** components
4. Follow the existing code style and structure

#### Test Your Implementation
```bash
# Run all tests
make test

# Run linting
make lint

# Test your specific lab
cd labs/labXX
# Run Go tests
cd backend && go test ./...
# Run Flutter tests  
cd ../frontend && flutter test
```

## 📝 Merge Request Template

```markdown
## Lab XX: [Brief Description]

### What was implemented:
- [ ] Go backend component with [specific features]
- [ ] Flutter frontend component with [specific features]  
- [ ] Unit tests for all major functions
- [ ] Integration between backend and frontend
- [ ] Documentation updates

### How to test:
1. Step-by-step instructions to test your implementation
2. Expected behavior and outcomes
3. Any special setup required

### Questions/Notes:
- Any challenges faced
- Design decisions made
- Areas where feedback is needed

### Checklist:
- [ ] All tests pass 
- [ ] Code passes linting 
- [ ] Both Go and Flutter components work
- [ ] README updated if necessary
- [ ] Follows course coding standards
```
