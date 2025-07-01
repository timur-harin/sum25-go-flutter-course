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

### Lab Submission Process

#### Step 1: Create a Lab Branch
```bash
# Keep your main branch up to date
git checkout main
git pull upstream main
git push origin main

# Create a new branch for the lab
git checkout -b lab01-surname-name
```

**Branch naming convention**: `labXX-surname-name` (all lowercase, no spaces, like in Moodle)
- ✅ `lab01-smith-john`
- ✅ `lab03-garcia-maria`
- ❌ `lab01-John-Smith`
- ❌ `lab01_john_smith`

#### Step 2: Complete the Assignment
1. Navigate to the lab directory: `labs/labXX/`
2. Read the `README.md` for specific requirements
3. Implement both **Go backend** and **Flutter frontend** components
4. Follow the existing code style and structure

#### Step 3: Test Your Implementation
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

#### Step 4: Commit and Push
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

#### Step 5: Create Merge Request
1. Go to your fork on GitHub
2. Click "Compare & pull request"
3. **Title**: `Lab XX: [Brief description] - Surname Name`
4. **Description**: Use the template below

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
- [ ] All tests pass (`make test`)
- [ ] Code passes linting (`make lint`)
- [ ] Both Go and Flutter components work
- [ ] README updated if necessary
- [ ] Follows course coding standards
```

## 🔍 Code Review Process

### As an Author
- **Respond promptly** to review feedback
- **Address all comments** before requesting re-review
- **Test thoroughly** after making changes
- **Update documentation** if implementation changes

### As a Reviewer
Every student is expected to participate in peer reviews:

1. **Review 2-3 merge requests** from other students
2. **Focus on**:
   - Correctness and functionality
   - Code readability and style
   - Test coverage
   - Documentation quality
3. **Be constructive** and respectful
4. **Ask questions** if something is unclear
5. **Suggest improvements** rather than just pointing out problems

## 📋 Code Quality Standards

### Go Backend Standards
- Follow `gofmt` formatting
- Use descriptive variable and function names
- Include error handling for all operations
- Write unit tests for all public functions
- Document public APIs with comments
- Follow Go conventions and idioms

### Flutter Frontend Standards  
- Follow Dart formatting (`dart format`)
- Use consistent widget structure
- Implement proper state management (Riverpod/Bloc)
- Include widget tests for UI components
- Handle loading and error states
- Follow Material Design principles

### General Standards
- **No hardcoded values** - use configuration
- **Meaningful commit messages**
- **Clear documentation** in READMEs
- **Proper error handling** throughout
- **Comprehensive test coverage**

## 🚨 Common Issues and Solutions

### Build Failures
```bash
# Clean and rebuild
make clean
make setup
make build
```

### Go Module Issues
```bash
cd backend
go mod tidy
go mod download
```

### Flutter Issues
```bash
cd frontend  
flutter clean
flutter pub get
flutter pub deps
```

### Git Issues
```bash
# If your branch is behind main
git checkout main
git pull upstream main
git checkout your-branch
git rebase main

# If you have merge conflicts
git status
# Edit conflicted files
git add .
git rebase --continue
```

## 🎯 Assessment Criteria

Your lab submissions will be evaluated on:

| Criteria | Weight | Description |
|----------|--------|-------------|
| **Functionality** | 40% | Implementation meets requirements, works as expected |
| **Code Quality** | 25% | Clean, readable, well-structured code |
| **Testing** | 20% | Comprehensive tests, good coverage |
| **Documentation** | 10% | Clear README, code comments, API documentation |
| **Collaboration** | 5% | Participation in code reviews, helping others |

## 💡 Tips for Success

1. **Start early** - Don't wait until the deadline
2. **Read requirements carefully** - Make sure you understand what's needed
3. **Test frequently** - Don't wait until the end to test
4. **Ask questions** - Use discussions, office hours, or Slack
5. **Help others** - Participate actively in code reviews
6. **Keep learning** - Explore beyond the minimum requirements

## 🔗 Resources

- [Go Style Guide](https://golang.org/doc/effective_go.html)
- [Flutter Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Git Best Practices](https://git-scm.com/doc)
- [How to Write a Git Commit Message](https://chris.beams.io/posts/git-commit/)

## 📞 Getting Help

- **Slack**: #go-flutter-course
- **Office Hours**: Tuesdays 2-4 PM, Thursdays 10-12 PM
- **Email**: instructor@university.edu
- **Discussion Forum**: GitHub Discussions in this repository

Remember: **Collaboration is encouraged, copying is not**. Learn together, but submit your own work! 