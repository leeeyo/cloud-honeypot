# Project Diagrams

This directory contains PlantUML diagrams for the Azure Cloud Honeypot project.

## Diagrams

| File | Description |
|------|-------------|
| `use-case.puml` | Use Case diagram showing actors and system interactions |
| `deployment.puml` | Deployment/Architecture diagram showing Azure infrastructure |
| `sequence.puml` | Sequence diagram showing attack detection flow |
| `cicd-pipeline.puml` | CI/CD pipeline flow diagram |

## Rendering Diagrams

### Online (PlantUML Server)

1. Visit [PlantUML Web Server](https://www.plantuml.com/plantuml/uml/)
2. Paste the content of any `.puml` file
3. Click "Submit" to render

### VS Code Extension

1. Install the "PlantUML" extension
2. Open any `.puml` file
3. Press `Alt+D` to preview

### Command Line

```bash
# Install PlantUML (requires Java)
# macOS
brew install plantuml

# Ubuntu
sudo apt install plantuml

# Render to PNG
plantuml -tpng *.puml

# Render to SVG
plantuml -tsvg *.puml
```

### GitHub Integration

PlantUML diagrams can be rendered directly in GitHub using:

```markdown
![Diagram](https://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/USERNAME/REPO/main/docs/diagrams/deployment.puml)
```

## Mermaid Alternatives

For GitHub README compatibility, the main README uses Mermaid diagrams which render natively on GitHub.

