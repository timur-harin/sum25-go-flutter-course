# Final project guidelines: Cross-platform Health & Wellness application

## Overview
This final project is designed as a team-based endeavor (2-5 students) to create a comprehensive cross-platform health and wellness application. Teams will apply all concepts learned throughout the course to deliver a production-ready solution.

> Note: Alternative themes may be proposed but must receive instructor approval.

## Possible project topics
1. Sleep tracking application
2. First aid kit companion
3. Hydration (Aqua) tracking
4. Fitness tracking hub
5. Nutrition management
6. Mental health companion
7. Cold shower training
8. Habit formation assistant
9. Posture improvement coach
10. Stress management system
11. ...

> Teams are encouraged to combine elements from different topics or propose entirely new ideas with instructor approval. Focus should be on creating a cohesive, well-implemented solution rather than implementing every possible feature.

## Team registration
Teams must register their project and members in the [Course projects spreadsheet](https://docs.google.com/spreadsheets/d/1W5FcjhBbfc6SNVqenk_UWRYlsDjw6WO_Xrm28dM8Ke4/edit?usp=sharing)

Required information:
- Team members (2-5 people)
- Team name
- Project topic (from the list above or a custom topic)
- GitHub organization link (once created)

Note: Topics are assigned on a first-come, first-served basis. Each team should choose a unique topic to avoid duplication

## Project ideas & inspiration
You can draw inspiration from previous successful projects in the [Fall 2024 Flutter Course](https://github.com/timur-harin/Fall24FlutterCourse?tab=readme-ov-file#team-projects-of-students). However, ensure your implementation is unique and incorporates all required technical components

---

## Technical requirements (20 points)

### Backend Development (8 points)
- Go-based microservices architecture (minimum 3 services) (3 points)
- RESTful API with Swagger documentation (1 point)
- gRPC implementation for communication between microservices (1 point)
- PostgreSQL database with proper schema design (1 point)
- JWT-based authentication and authorization (1 point)
- Comprehensive unit and integration tests (1 point)

### Frontend Development (8 points)
- Flutter-based cross-platform application (mobile + web) (3 points)
- Responsive UI design with custom widgets (1 point)
- State management implementation (1 point)
- Offline data persistence (1 point)
- Unit and widget tests (1 point)
- Support light and dark mode (1 point)

### DevOps & Deployment (4 points)
- Docker compose for all services (1 point)
- CI/CD pipeline implementation (1 point)
- Environment configuration management using config files (1 point)
- GitHub pages for the project (1 point)

---
## Non-Technical Requirements (10 points)

### Project Management (4 points)
- GitHub organization with well-maintained repository (1 point)
- Regular commits and meaningful pull requests from all team members (1 point)
- Project board (GitHub Projects) with task tracking (1 point)
- Team member roles and responsibilities documentation (1 point)

### Documentation (4 points)
- Comprehensive README with:
  - Project overview and setup instructions (1 point)
  - Screenshots and GIFs of key features (1 point)
  - API documentation (1 point)
  - Architecture diagrams and explanations (1 point)

### Code Quality (2 points)
- Consistent code style and formatting during CI/CD pipeline (1 point)
- Code review participation and resolution (1 point)

## Bonus points (up to 10 points total)
- Implement localization for Russian (RU) and English (ENG) languages (2 points)
- Good UI/UX design (up to 3 points) - subjective
- Integration with external APIs (fitness trackers, health devices) (up to 5 points)
- Comprehensive error handling and user feedback (up to 2 points)
- Advanced animations and transitions (up to 3 points)
- Widget implementation for native mobile elements (up to 2 points)

Note: Teams can implement multiple bonus features, but the total bonus points cannot exceed 10 points

## Suggested features for health app theme
1. User Management
   - Registration and authentication
   - Profile management
   - Health goals setting

2. Health Tracking
   - Activity logging
   - Vital signs monitoring
   - Progress visualization

3. Social Features
   - Community challenges
   - Achievement sharing
   - Friend connections

## Presentation requirements

### Attendance and format
- **In-person requirement**: All team members must attend the presentation in person
- **Exception policy**: Only team members with approved DOE may present remotely
- **Location**: Will be announced in the course Telegram channel
- **Technical setup**: Teams must bring their own device with HDMI connection capability
- **Q&A**: Teams should be prepared to answer questions from the instructor and peers to any member of the team

### Time management
- **Duration**: 10 minutes for presentation + 5 minutes for Q&A
- **Setup time**: Arrive more than10 minutes before your slot to prepare
- **Practice**: Teams should rehearse to ensure they stay within time limits

### Presentation Structure
1. **Team Introduction** (1 minute)
   - Team members and roles
   - Project topic and motivation

2. **Technical Implementation** (4 minutes)
   - Architecture overview
   - Key technical features
   - Development challenges and solutions

3. **Live Demo** (5 minutes)
   - Core functionality demonstration
   - Feature highlights
   - Technical capabilities

4. **Q&A Session** (5 minutes)
   - Technical questions from instructor
   - Peer questions
   - Implementation clarifications

### Technical Requirements
- Bring laptop with HDMI port/adapter
- Have project running locally (no reliance on internet)
- Prepare screenshots/recordings as backup
- Test all features before presentation

### Team coordination
- All present team members should participate in the presentation
- Clear role distribution during presentation
- Remote members (with DOE) should be available via voice call from the team device

## Submission Process
1. Create a GitHub organization for your team
2. Add all team members as organization owners
3. Create a public repository with:
   - Well-structured code
   - Comprehensive documentation
   - Setup instructions
   - Feature demonstrations
4. Submit a pdf file with:
   - Project name
   - List of team members with Name, Surname, and Innopolis University Email
   - Link to the organization
   - Link to the repository
   - Link to the presentation video
5. Prepare for live demonstration

## Documentation requirements

### README Checklist
Teams must include a checklist in their main README.md that clearly indicates which requirements have been implemented. The checklist should follow this format:

```markdown
## Implementation checklist

### Technical requirements (20 points)
#### Backend development (8 points)
- [ ] Go-based microservices architecture (minimum 3 services) (3 points)
- [ ] RESTful API with Swagger documentation (1 point)
- [ ] gRPC implementation for communication between microservices (1 point)
- [ ] PostgreSQL database with proper schema design (1 point)
- [ ] JWT-based authentication and authorization (1 point)
- [ ] Comprehensive unit and integration tests (1 point)

#### Frontend development (8 points)
- [ ] Flutter-based cross-platform application (mobile + web) (3 points)
- [ ] Responsive UI design with custom widgets (1 point)
- [ ] State management implementation (1 point)
- [ ] Offline data persistence (1 point)
- [ ] Unit and widget tests (1 point)
- [ ] Support light and dark mode (1 point)

#### DevOps & deployment (4 points)
- [ ] Docker compose for all services (1 point)
- [ ] CI/CD pipeline implementation (1 point)
- [ ] Environment configuration management using config files (1 point)
- [ ] GitHub pages for the project (1 point)

### Non-Technical Requirements (10 points)
#### Project management (4 points)
- [ ] GitHub organization with well-maintained repository (1 point)
- [ ] Regular commits and meaningful pull requests from all team members (1 point)
- [ ] Project board (GitHub Projects) with task tracking (1 point)
- [ ] Team member roles and responsibilities documentation (1 point)

#### Documentation (4 points)
- [ ] Project overview and setup instructions (1 point)
- [ ] Screenshots and GIFs of key features (1 point)
- [ ] API documentation (1 point)
- [ ] Architecture diagrams and explanations (1 point)

#### Code quality (2 points)
- [ ] Consistent code style and formatting during CI/CD pipeline (1 point)
- [ ] Code review participation and resolution (1 point)

### Bonus Features (up to 10 points)
- [ ] Localization for Russian (RU) and English (ENG) languages (2 points)
- [ ] Good UI/UX design (up to 3 points)
- [ ] Integration with external APIs (fitness trackers, health devices) (up to 5 points)
- [ ] Comprehensive error handling and user feedback (up to 2 points)
- [ ] Advanced animations and transitions (up to 3 points)
- [ ] Widget implementation for native mobile elements (up to 2 points)

Total points implemented: XX/30 (excluding bonus points)

Note: For each implemented feature, provide a brief description or link to the relevant implementation below the checklist.
```