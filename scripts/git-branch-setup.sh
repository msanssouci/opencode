#!/usr/bin/env bash
# Git Branch Setup - Automated workflow for beads tasks
# Location: ~/.config/opencode/scripts/git-branch-setup.sh
# Version: 1.0.0

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
error() {
    echo -e "${RED}❌ ERROR: $1${NC}" >&2
    exit 1
}

warning() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    error "Not in a git repository"
fi

# Detect default branch
info "Detecting default branch..."
if ! DEFAULT_BRANCH=$(git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's|origin/||'); then
    warning "Could not detect default branch. Setting origin HEAD..."
    git remote set-head origin --auto || error "Failed to set origin HEAD"
    DEFAULT_BRANCH=$(git rev-parse --abbrev-ref origin/HEAD | sed 's|origin/||')
fi

CURRENT_BRANCH=$(git branch --show-current)

info "Default branch: ${BLUE}${DEFAULT_BRANCH}${NC}"
info "Current branch: ${BLUE}${CURRENT_BRANCH}${NC}"

# Check for uncommitted changes
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    warning "You have uncommitted changes"
    read -p "Stash changes before continuing? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git stash push -m "WIP: git-branch-setup auto-stash $(date +%Y-%m-%d-%H%M%S)"
        success "Changes stashed"
        STASHED=true
    else
        error "Cannot proceed with uncommitted changes. Commit or stash them first."
    fi
fi

# Scenario A: On default branch
if [ "$CURRENT_BRANCH" = "$DEFAULT_BRANCH" ]; then
    info "On default branch - updating from origin..."
    
    git fetch origin || error "Failed to fetch from origin"
    
    if ! git pull origin "$DEFAULT_BRANCH"; then
        error "Failed to pull from origin. You may have merge conflicts. Resolve manually."
    fi
    
    success "Default branch updated"
    
    # Prompt for new feature branch name
    echo ""
    read -p "Enter feature branch name (without 'feature/' prefix): " BRANCH_NAME
    
    if [ -z "$BRANCH_NAME" ]; then
        error "Branch name cannot be empty"
    fi
    
    FULL_BRANCH="feature/${BRANCH_NAME}"
    
    info "Creating branch: ${BLUE}${FULL_BRANCH}${NC}"
    git checkout -b "$FULL_BRANCH" || error "Failed to create branch"
    
    info "Setting upstream tracking..."
    git push -u origin "$FULL_BRANCH" || error "Failed to push branch"
    
    success "Ready to work on ${FULL_BRANCH}"
    
    [ "$STASHED" = true ] && git stash pop && success "Stashed changes restored"
    exit 0
fi

# Scenarios B & C: On feature branch
info "On feature branch - checking if diverged from main..."

git fetch origin || error "Failed to fetch from origin"

# Test merge to detect conflicts
info "Testing merge with ${DEFAULT_BRANCH}..."

if git merge --no-commit --no-ff "origin/${DEFAULT_BRANCH}" 2>/dev/null; then
    # No conflicts
    git merge --abort
    success "Branch is clean - no conflicts with ${DEFAULT_BRANCH}"
    success "Ready to work on ${CURRENT_BRANCH}"
    
    [ "$STASHED" = true ] && git stash pop && success "Stashed changes restored"
    exit 0
fi

# Has conflicts
git merge --abort 2>/dev/null || true

warning "Branch has conflicts with ${DEFAULT_BRANCH}"
warning "This is common after squash merges"

echo ""
echo "Choose resolution strategy:"
echo "  1) Start fresh feature branch (recommended for squash-merged branches)"
echo "  2) Resolve conflicts on current branch (if you have unmerged work)"
echo "  3) Exit and handle manually"
read -p "Choice (1-3): " -n 1 -r
echo ""

case $REPLY in
    1)
        info "Starting fresh feature branch..."
        
        git checkout "$DEFAULT_BRANCH" || error "Failed to checkout ${DEFAULT_BRANCH}"
        git pull origin "$DEFAULT_BRANCH" || error "Failed to pull ${DEFAULT_BRANCH}"
        
        read -p "Enter new feature branch name (without 'feature/' prefix): " BRANCH_NAME
        
        if [ -z "$BRANCH_NAME" ]; then
            error "Branch name cannot be empty"
        fi
        
        FULL_BRANCH="feature/${BRANCH_NAME}"
        
        git checkout -b "$FULL_BRANCH" || error "Failed to create branch"
        git push -u origin "$FULL_BRANCH" || error "Failed to push branch"
        
        success "Ready to work on ${FULL_BRANCH}"
        success "Old branch ${CURRENT_BRANCH} can be deleted if work is merged"
        
        [ "$STASHED" = true ] && git stash pop && success "Stashed changes restored"
        ;;
    2)
        info "Attempting to merge ${DEFAULT_BRANCH} into ${CURRENT_BRANCH}..."
        
        if git merge "origin/${DEFAULT_BRANCH}"; then
            success "Merge successful"
            git push || warning "Push failed - you may need to push manually"
            success "Ready to work on ${CURRENT_BRANCH}"
        else
            error "Merge has conflicts. Resolve manually:\n  1. Fix conflicts in files\n  2. git add <files>\n  3. git commit\n  4. git push"
        fi
        ;;
    3)
        info "Exiting. Current branch: ${CURRENT_BRANCH}"
        exit 0
        ;;
    *)
        error "Invalid choice"
        ;;
esac
