# TianXuan Sect (天玄宗)

<div align="center">

**A Professional Multi-Agent Collaboration System with Chinese Cultivation Theme for Claude Code**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude-Code-blue.svg)](https://claude.ai/code)
[![中文](https://img.shields.io/badge/语言-中文-red.svg)](README.md)

English | [简体中文](README.md)

</div>

---

## 📖 Introduction

TianXuan Sect is a Claude Code plugin based on Chinese cultivation sect theme, providing complete workflow support for software development through collaboration of 7 professional roles.

### ✨ Core Features

- 🏯 **Multi-Agent Collaboration** - 7 professional roles with clear division of labor
- 🎨 **Chinese Cultivation Theme** - Unique cultural characteristics and fun user experience
- 🛡️ **HARD-GATE Principle** - Never guess, never use placeholders, never skip steps
- 📚 **Scripture Library Mechanism** - Enforce knowledge reuse, avoid redundant research
- ✅ **Two-Stage Review** - Function first, then quality, ensuring delivery standards
- 🧪 **TDD Workflow** - Test-Driven Development with quality assurance
- 📝 **14 Professional Skills** - Covering requirements, development, testing, and review

---

## 🚀 Quick Start

### Installation

See [Installation Guide](INSTALL.md)

### Initialization

```bash
/init-tianxuan
```

This creates the TianXuan Sect directory structure:

```
天玄宗/ (TianXuan Sect)
├── 宗门任务榜/        # Task Board
│   ├── 进行中/        # In Progress
│   ├── 已完成/        # Completed
│   └── 计划/          # Plans
├── 藏经阁/            # Scripture Library (Knowledge Base)
│   ├── 技术文档/      # Technical Docs
│   └── 最佳实践/      # Best Practices
├── 执法堂/            # Law Enforcement Hall (Test Reports)
└── 丹堂/              # Alchemy Hall (Data Analysis)
```

### First Task

```
User: I want to implement a user login feature

Sect Master: Got it! Let me understand the requirements first...
             - What authentication method? JWT or Session?
             - Need third-party login support?
             - Password complexity requirements?

User: Use JWT, no third-party login for now, minimum 8 characters

Sect Master: Understood! I will:
             1. Create a detailed implementation plan
             2. Assign tasks to Array Hall (backend) and Artifact Hall (frontend)
             3. Law Enforcement Hall handles testing and quality control
             
             Starting execution...
```

---

## 🏛️ Role System

TianXuan Sect adopts a multi-agent collaboration model with clear role responsibilities:

| Role | Responsibilities | Characteristics | Model |
|------|-----------------|-----------------|-------|
| **Sect Master** | Requirements exploration, task breakdown, coordination, acceptance | Overall coordination, ensuring project direction | Claude Sonnet |
| **Scripture Librarian** | Knowledge management, documentation research, experience accumulation | Enforce knowledge reuse, avoid redundant research | Claude Sonnet |
| **Alchemy Elder** | Data queries, log analysis, environment diagnosis | Data expert, decision support | Claude Sonnet |
| **Array Elder** | Backend development, API design, business implementation | Backend expert, following best practices | Claude Sonnet |
| **Artifact Elder** | Frontend development, UI design, user experience | Frontend expert, focusing on UX | Claude Sonnet |
| **Law Enforcement Elder** | Testing, quality control, defect diagnosis | Quality guardian, strict standards | Claude Sonnet |
| **Servant Disciple** | Handle simple tasks, assist elders | Execute simple and clear tasks | Claude Haiku |

---

## 💡 Core Concepts

### HARD-GATE Principle

All roles in TianXuan Sect follow the HARD-GATE principle:

```
✅ Never Guess - Ask when uncertain, don't assume
✅ Never Use Placeholders - No TODO/FIXME/placeholder
✅ Never Skip Steps - Follow steps strictly, no shortcuts
```

### Scripture Library Mechanism

All technical research and best practices are stored in the Scripture Library:

1. **Before Starting Tasks** - Must query the Scripture Library first
2. **Discovering New Knowledge** - Scripture Librarian researches and stores
3. **Knowledge Reuse** - Avoid redundant research, improve efficiency

### Two-Stage Review

Law Enforcement Elder adopts a two-stage review method:

1. **Stage 1: Functional Review** - Verify if functionality meets requirements
2. **Stage 2: Quality Review** - Check code quality, test coverage, documentation completeness

---

## 🎓 Skills System

TianXuan Sect has 14 professional skills covering the complete development process:

### Requirements & Planning
- **Requirements Exploration** - Requirements exploration, design confirmation (Sect Master)
- **Plan Writing** - Write detailed implementation plans (Sect Master)
- **Plan Execution** - Execute task plans (Sect Master)

### Development
- **Scripture Library Priority** - Enforce Scripture Library queries (Array, Artifact, Servant)
- **Self-Review** - Post-completion self-check (Array, Artifact, Servant)
- **Code Review Request** - Request code review (Array, Artifact)
- **Code Review Reception** - Receive review feedback (Array, Artifact)

### Testing & Quality
- **Test-Driven Development** - TDD Red-Green-Refactor (Law Enforcement)
- **Two-Stage Review** - Function first, then quality (Law Enforcement)
- **Systematic Debugging** - Diagnose root causes, reject and fix (Law Enforcement)
- **Pre-Completion Verification** - Final verification (Sect Master, Law Enforcement)

### Tools
- **Git Workflow** - Git branch management (All Halls)
- **Code Review Checklist** - Code review checklist (Law Enforcement)
- **Documentation Generation** - Auto-generate documentation (All Halls)

See [Complete Skills Summary](SKILLS_COMPLETE_SUMMARY.md)

---

## 🔄 Complete Workflow

```
1. User submits requirements
   ↓
2. Sect Master (Requirements Exploration)
   - Ask questions to understand requirements
   - Propose design solutions
   - Get user confirmation
   ↓
3. Sect Master (Plan Writing)
   - Create detailed implementation plan
   - Assign tasks to halls
   ↓
4. Law Enforcement (Test-Driven Development)
   - Write test cases
   - Run tests (Red)
   ↓
5. Array/Artifact Halls
   - Scripture Library Priority (Query best practices)
   - Review test cases
   - Implement functionality
   - Self-Review (Self-check)
   ↓
6. Law Enforcement
   - Run tests (Green)
   - Two-Stage Review (Function + Quality)
   - Code Review Checklist (Detailed review)
   ↓
7. Array/Artifact Halls
   - Code Review Reception (Handle feedback)
   - Fix issues
   ↓
8. Law Enforcement
   - Pre-Completion Verification (Comprehensive check)
   ↓
9. Sect Master
   - Pre-Completion Verification (Final acceptance)
   - Archive to Scripture Library
```

---

## 📚 Documentation

- 📖 [Installation Guide](INSTALL.md) - Detailed installation steps
- 🚀 [Getting Started](docs/guides/getting-started.md) - Beginner tutorial
- 🤝 [Contributing Guide](CONTRIBUTING.md) - How to contribute
- 📝 [Complete Skills Summary](SKILLS_COMPLETE_SUMMARY.md) - Detailed skill descriptions
- 📋 [Changelog](CHANGELOG.md) - Version update history

---

## 🌟 Why Choose TianXuan Sect?

### 🎯 Professional Multi-Agent Collaboration
- 7 professional roles with clear division of labor
- Each role has dedicated skills
- Clear and efficient collaboration process

### 📚 Enforced Knowledge Management
- Scripture Library mechanism avoids redundant research
- All experience is accumulated
- Knowledge reuse improves efficiency

### ✅ Strict Quality Assurance
- HARD-GATE principle ensures no guessing
- Two-stage review ensures quality
- TDD process ensures test coverage

### 🎨 Unique Cultural Characteristics
- Chinese cultivation theme
- Distinctive role naming
- Unique and fun user experience

---

## 🤝 Contributing

Contributions are welcome! Please see [Contributing Guide](CONTRIBUTING.md) for details.

---

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details

---

## 🙏 Acknowledgments

- Inspired by [Superpowers](https://github.com/obra/superpowers)
- Thanks to the Claude Code team for the plugin platform
- Thanks to all contributors and users

---

## 📧 Contact

- **Author**: XuJiaKai
- **Issues**: [GitHub Issues](https://github.com/xjk2000/tianxuan-sect/issues)

---

<div align="center">

**TianXuan Sect - Making AI Development More Professional, Efficient, and Fun!** 🎊

Made with ❤️ by XuJiaKai

</div>
