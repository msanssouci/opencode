#!/usr/bin/env bash
# Bootstrap a project for PRD workflow and agent orchestration
# Usage: ./scripts/bootstrap-project.sh [project-name] [--stack=backend|frontend|fullstack]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
info() { echo -e "${BLUE}ℹ${NC} $*"; }
success() { echo -e "${GREEN}✅${NC} $*"; }
warning() { echo -e "${YELLOW}⚠️${NC} $*"; }
error() { echo -e "${RED}❌${NC} $*"; }

# Check prerequisites
check_prerequisites() {
    info "Checking prerequisites..."
    
    # Check if in git repo
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        error "Not in a git repository. Run 'git init' first."
        exit 1
    fi
    
    # Check if bd (beads) is available
    if ! command -v bd &> /dev/null; then
        error "beads (bd) command not found. Please install beads first."
        exit 1
    fi
    
    success "Prerequisites satisfied"
}

# Detect project name from current directory
detect_project_name() {
    basename "$(pwd)"
}

# Detect tech stack
detect_stack() {
    local stack="unknown"
    local has_backend=false
    local has_frontend=false
    
    # Check for backend (Kotlin/Spring Boot)
    if [[ -f "build.gradle.kts" ]] || [[ -f "settings.gradle.kts" ]] || [[ -d "apps/api" ]]; then
        has_backend=true
    fi
    
    # Check for frontend (Next.js/React)
    if [[ -f "package.json" ]]; then
        if grep -q '"next"' package.json 2>/dev/null; then
            has_frontend=true
        fi
    fi
    if [[ -d "apps/web" ]]; then
        has_frontend=true
    fi
    
    # Determine stack type
    if [[ "$has_backend" == true ]] && [[ "$has_frontend" == true ]]; then
        stack="fullstack"
    elif [[ "$has_backend" == true ]]; then
        stack="backend"
    elif [[ "$has_frontend" == true ]]; then
        stack="frontend"
    else
        stack="custom"
    fi
    
    echo "$stack"
}

# Initialize beads
init_beads() {
    local project_name="$1"
    
    info "Initializing beads for project: $project_name"
    
    # Check if already initialized
    if [[ -d ".beads" ]]; then
        warning "Beads already initialized (.beads/ exists)"
        read -p "Reinitialize? This will reset all tasks (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "Skipping beads initialization"
            return 0
        fi
        rm -rf .beads
    fi
    
    # Initialize beads
    bd init "$project_name"
    success "Beads initialized with prefix: $project_name"
}

# Create project-specific .agents/AGENTS.md
create_agents_config() {
    local project_name="$1"
    local stack="$2"
    
    info "Creating .agents/AGENTS.md configuration..."
    
    mkdir -p .agents
    
    # Determine stack description
    local stack_desc=""
    case "$stack" in
        fullstack)
            stack_desc="Backend (Kotlin/Spring Boot) + Frontend (Next.js/React)"
            ;;
        backend)
            stack_desc="Backend (Kotlin/Spring Boot)"
            ;;
        frontend)
            stack_desc="Frontend (Next.js/React)"
            ;;
        custom)
            stack_desc="Custom stack (update this manually)"
            ;;
    esac
    
    # Generate build commands based on stack
    local build_commands=""
    if [[ "$stack" == "fullstack" ]] || [[ "$stack" == "backend" ]]; then
        build_commands+="### Backend
- Build: \`./gradlew build\` or \`just build\`
- Test: \`./gradlew test\` or \`just test\`
- Run: \`./gradlew bootRun\` or \`just run-api\`

"
    fi
    
    if [[ "$stack" == "fullstack" ]] || [[ "$stack" == "frontend" ]]; then
        build_commands+="### Frontend
- Build: \`npm run build\` or \`just build-web\`
- Test: \`npm test\` or \`just test-web\`
- Run: \`npm run dev\` or \`just run-web\`"
    fi
    
    if [[ "$stack" == "custom" ]]; then
        build_commands="- Build: \`<your-build-command>\`
- Test: \`<your-test-command>\`
- Run: \`<your-run-command>\`"
    fi
    
    # Create the file
    cat > .agents/AGENTS.md <<EOF
# Project Configuration

## Project Context
- **Name:** $project_name
- **Beads Prefix:** $project_name
- **Stack:** $stack_desc

## Build Commands

$build_commands

## Directory Structure

EOF
    
    # Add directory structure based on stack
    if [[ "$stack" == "fullstack" ]]; then
        cat >> .agents/AGENTS.md <<EOF
- \`apps/api/\` - Spring Boot backend
- \`apps/web/\` - Next.js frontend
- \`apps/cli/\` - CLI tools (if applicable)
- \`libs/\` - Shared libraries
EOF
    elif [[ "$stack" == "backend" ]]; then
        cat >> .agents/AGENTS.md <<EOF
- \`apps/api/\` - Spring Boot backend
- \`apps/cli/\` - CLI tools (if applicable)
- \`libs/\` - Shared libraries
EOF
    elif [[ "$stack" == "frontend" ]]; then
        cat >> .agents/AGENTS.md <<EOF
- \`apps/web/\` - Next.js frontend
- \`src/\` - Source code
- \`components/\` - React components
EOF
    else
        cat >> .agents/AGENTS.md <<EOF
- \`<update-this>/\` - Your project structure
EOF
    fi
    
    # Add stack references
    cat >> .agents/AGENTS.md <<EOF

## Stack References

EOF
    
    if [[ "$stack" == "fullstack" ]] || [[ "$stack" == "backend" ]]; then
        echo "- **Backend Stack:** See \`~/.config/opencode/stacks/backend.md\`" >> .agents/AGENTS.md
    fi
    
    if [[ "$stack" == "fullstack" ]] || [[ "$stack" == "frontend" ]]; then
        echo "- **Frontend Stack:** See \`~/.config/opencode/stacks/frontend.md\`" >> .agents/AGENTS.md
    fi
    
    if [[ "$stack" == "custom" ]]; then
        echo "- Update with your stack-specific references" >> .agents/AGENTS.md
    fi
    
    cat >> .agents/AGENTS.md <<EOF

## PRD Workflow

This project is configured for PRD-driven development:

1. **Create a PRD:** Use \`/prd\` command to create a Product Requirements Document
2. **Auto-generate tasks:** The prd-planner will break down requirements into beads tasks
3. **Agent orchestration:** build-orchestrator coordinates parallel execution across:
   - backend-dev (for API/backend work)
   - frontend-dev (for UI/frontend work)
   - test-runner (for test execution)
   - code-reviewer (for quality verification)

### Quick Commands

\`\`\`bash
# Create and implement a PRD
/prd

# Continue after PRD modifications
/prd-continue

# Check what's ready to work on
bd ready

# View project statistics
bd stats
\`\`\`

---

_Generated by bootstrap-project on $(date +%Y-%m-%d)_
EOF
    
    success "Created .agents/AGENTS.md"
}

# Set up git hooks
setup_git_hooks() {
    info "Setting up git hooks..."
    
    local hooks_dir=".git/hooks"
    
    # Create post-commit hook for beads sync
    cat > "$hooks_dir/post-commit" <<'EOF'
#!/usr/bin/env bash
# Auto-sync beads after commit

if command -v bd &> /dev/null; then
    bd sync --quiet 2>/dev/null || true
fi
EOF
    chmod +x "$hooks_dir/post-commit"
    
    # Create pre-push hook to verify beads sync
    cat > "$hooks_dir/pre-push" <<'EOF'
#!/usr/bin/env bash
# Verify beads is synced before push

if command -v bd &> /dev/null; then
    if ! bd sync --status &> /dev/null; then
        echo "⚠️  Warning: Beads may not be synced. Run 'bd sync' before pushing."
    fi
fi
EOF
    chmod +x "$hooks_dir/pre-push"
    
    success "Git hooks installed"
}

# Print summary
print_summary() {
    local project_name="$1"
    local stack="$2"
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    success "Bootstrap Complete! 🚀"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Project: ${GREEN}$project_name${NC}"
    echo "Stack:   ${GREEN}$stack${NC}"
    echo ""
    echo "📁 Created:"
    echo "   ✅ .beads/           - Beads task tracking"
    echo "   ✅ .agents/AGENTS.md - Project configuration"
    echo "   ✅ .git/hooks/       - Auto-sync hooks"
    echo ""
    echo "🎯 Next Steps:"
    echo ""
    echo "   1. Review configuration:"
    echo "      ${BLUE}cat .agents/AGENTS.md${NC}"
    echo ""
    echo "   2. Create your first PRD:"
    echo "      ${BLUE}/prd${NC}"
    echo ""
    echo "   3. Or create tasks manually:"
    echo "      ${BLUE}bd create --title=\"Your task\" --type=feature --priority=2${NC}"
    echo "      ${BLUE}bd ready${NC}"
    echo ""
    echo "   4. View project stats:"
    echo "      ${BLUE}bd stats${NC}"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Main execution
main() {
    local project_name=""
    local stack=""
    
    # Parse arguments
    if [[ $# -gt 0 ]]; then
        project_name="$1"
        shift
    fi
    
    # Parse flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --stack=*)
                stack="${1#*=}"
                shift
                ;;
            *)
                error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Check prerequisites
    check_prerequisites
    
    # Detect or prompt for project name
    if [[ -z "$project_name" ]]; then
        project_name=$(detect_project_name)
        info "Detected project name: $project_name"
        read -p "Use this name? (Y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            read -p "Enter project name: " project_name
        fi
    fi
    
    # Detect or use provided stack
    if [[ -z "$stack" ]]; then
        stack=$(detect_stack)
        info "Detected stack: $stack"
        if [[ "$stack" == "custom" ]]; then
            echo "Select stack:"
            echo "  1) Backend (Kotlin/Spring Boot)"
            echo "  2) Frontend (Next.js/React)"
            echo "  3) Fullstack (Backend + Frontend)"
            echo "  4) Custom"
            read -p "Choice (1-4): " -n 1 -r
            echo
            case "$REPLY" in
                1) stack="backend" ;;
                2) stack="frontend" ;;
                3) stack="fullstack" ;;
                4) stack="custom" ;;
                *) stack="custom" ;;
            esac
        fi
    fi
    
    # Execute bootstrap steps
    echo ""
    info "Bootstrapping project: $project_name ($stack)"
    echo ""
    
    init_beads "$project_name"
    create_agents_config "$project_name" "$stack"
    setup_git_hooks
    
    # Print summary
    print_summary "$project_name" "$stack"
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
