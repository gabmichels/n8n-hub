# Workflow Management Conventions

This document outlines the conventions and best practices for managing n8n workflows within this `n8n-hub` repository. The goal is to facilitate version control, collaboration, and easy migration of workflows between environments.

## 1. Workflow Storage

All exported n8n workflows should be stored in the `workflows/` directory.

*   `workflows/`
    *   `README.md`: Explains workflow management (this document).
    *   `project-name/` (or `category/`)
        *   `workflow-name-v1.0.0.json`
        *   `workflow-name-v1.1.0.json`
    *   `examples/`: Contains example workflows that can be used as a starting point.
    *   `backups/`: Intended for automated backups of production workflows.

## 2. Naming Conventions

To maintain consistency and clarity:

*   **Workflow Files**: Use a descriptive name followed by a version number and `.json` extension.
    *   Format: `[project_or_category]-[workflow_description]-vX.Y.Z.json`
    *   Example: `ecommerce-order-processing-v1.0.0.json`
*   **Directory Structure**: Organize workflows into subdirectories based on logical groups, projects, or categories.
    *   Example: `workflows/marketing/email-campaigns/` or `workflows/jira-integrations/`

## 3. Version Control

Workflows stored in this repository should be managed under Git.

1.  **Export Workflow**: In n8n, export your workflow as a `.json` file.
2.  **Save to Repository**: Place the exported `.json` file in the appropriate subdirectory under `workflows/`.
3.  **Commit Changes**:
    ```bash
    git add workflows/project-name/your-workflow-vX.Y.Z.json
    git commit -m "feat: Add/Update workflow 'Your Workflow Name' to vX.Y.Z"
    git push origin main # or your main branch
    ```
4.  **Avoid Direct Edits**: Do not directly edit the `.json` files in the repository. Always export from the n8n UI.

## 4. Importing Workflows

To import a workflow from the repository into your n8n instance:

1.  **Copy Content**: Open the desired `.json` workflow file in your code editor. Copy its entire content.
2.  **Paste in n8n**: In the n8n UI, click "Workflows" -> "New" -> "Import from JSON". Paste the copied content and click "Import".
3.  **Activate**: After importing, make sure to activate the workflow in n8n if it should run automatically.

## 5. Handling Credentials and Sensitive Data

*   **Never embed credentials or sensitive data directly in exported workflow JSONs.**
*   n8n handles credentials separately. When exporting a workflow, only references to credentials are included, not the sensitive values themselves.
*   Ensure that any required credentials are set up within your n8n instance.

## 6. Automated Workflow Backups (Optional)

Consider setting up an n8n workflow or an external script that periodically exports all active workflows and commits them into the `workflows/backups/` directory.

*   This provides an additional layer of safety and a historical record of all deployed workflows.
*   Ensure the backup process includes proper naming (e.g., `backup_YYYY-MM-DD_HHMM.json`) and respects the `.gitignore` rules if you only want to track changes and not every single backup file. An example of how to configure `.gitignore` for this is already included.