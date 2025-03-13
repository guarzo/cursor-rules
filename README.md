# Project Setup Guide: Cursor Rules & Documentation

This guide explains how to set up a centralized set of Cursor rules, generate an updated directory structure document, and use AI prompts to create essential documentation files (such as <code>project_overview.md</code> and <code>architecture.md</code>).

---

## 1. Setting Up Cursor Rules

To set up a centralized set of Cursor rules without including them in your Git history, follow one of the methods below.

### Option A: Single Command Installation

Run the following command from your project root to download and execute the install script in a single step:

```bash
curl -fsSL https://raw.githubusercontent.com/guarzo/cursor-rules/main/install_rules.sh | bash
```

This command will:
- Download the <code>install_rules.sh</code> script from the central rules repository.
- Execute the script, which clones the repository and copies the rule files into the <code>.cursor/rules</code> directory.
- **Note:** Make sure to add <code>.cursor/rules/</code> to your <code>.gitignore</code> so these files do not appear in your project's Git history.

### Option B: Git Submodule

Alternatively, add the rules repository as a Git submodule:

```bash
git submodule add https://github.com/guarzo/cursor-rules.git .cursor/rules
```

After adding, you may choose to add <code>.cursor/rules/</code> to your <code>.gitignore</code> if you prefer not to track submodule updates in your main repository.

---

## 2. Generating the Directory Structure

```
curl -fsSL https://raw.githubusercontent.com/guarzo/cursor-rules/main/dir_setup.sh | bash
```

---

## 3. AI-Generated Documentation Prompts

Use the following prompts with your AI tool to generate or update essential project documentation:

### Project Overview Prompt

```
"Generate a detailed project overview for a [brief description of the project, e.g., a web mapping application]. The overview should include the project's purpose, key features, technology stack, and user workflows. Ensure the overview is clear and accessible to both technical and non-technical stakeholders."
```

### Architecture Documentation Prompt

```
"Generate a comprehensive architecture document for this project. Describe the overall system structure, including frontend and backend components, data flows, and integration points. Explain key design decisions, scalability considerations, and any critical technical challenges. The document should be detailed enough for developers and technical leads, yet understandable by project managers."
```

Review and refine the generated output to ensure it accurately reflects your project.

---

## Conclusion

By following this guide, you'll have:
- A centralized set of Cursor rules installed in the <code>.cursor/rules</code> directory (without cluttering your Git history).
- An automated method to generate an updated directory structure document.
- AI prompts that help generate essential documentation like <code>project_overview.md</code> and <code>architecture.md</code>.

Happy coding!

---

## Tips for Using These Rules Across Multiple Projects

To use these rules in multiple projects without including them in each project's Git history, consider one of the following methods:

1. **Centralized Repository with an Install Script:**
   - Create a repository (e.g. <code>project-rules</code>) that contains all your rule files.
   - Include an <code>install_rules.sh</code> script (as shown above) that clones the repository and copies the rule files into <code>.cursor/rules</code>.
   - Add <code>.cursor/rules/</code> to your <code>.gitignore</code> so the rules are not committed.

2. **Git Submodules:**
   - Add your rules repository as a Git submodule:
     ```bash
     git submodule add https://github.com/yourusername/project-rules.git .cursor/rules
     ```
   - Optionally, add <code>.cursor/rules/</code> to your <code>.gitignore</code> to avoid tracking submodule updates.

This setup allows you to maintain a single source of truth for your rules while keeping your projects clean and consistent.

---
