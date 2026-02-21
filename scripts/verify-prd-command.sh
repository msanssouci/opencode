#!/bin/bash

# /prd Command Verification Script
# Run this to verify the /prd command is properly installed

set -e

echo "🔍 Verifying /prd Command Installation..."
echo ""

# Check 1: Command files exist
echo "✓ Checking command files..."
if [ -f ~/.config/opencode/commands/prd.md ]; then
    echo "  ✅ prd.md found"
else
    echo "  ❌ prd.md NOT found"
    exit 1
fi

if [ -f ~/.config/opencode/commands/prd-continue.md ]; then
    echo "  ✅ prd-continue.md found"
else
    echo "  ❌ prd-continue.md NOT found"
    exit 1
fi

# Check 2: Frontmatter syntax
echo ""
echo "✓ Checking frontmatter syntax..."
if grep -q "^---$" ~/.config/opencode/commands/prd.md; then
    echo "  ✅ prd.md has valid frontmatter"
else
    echo "  ❌ prd.md frontmatter invalid"
    exit 1
fi

if grep -q "description:" ~/.config/opencode/commands/prd.md; then
    echo "  ✅ prd.md has description"
else
    echo "  ❌ prd.md missing description"
    exit 1
fi

# Check 3: Documentation files
echo ""
echo "✓ Checking documentation..."
if [ -f ~/.config/opencode/skills/prd-command/INSTALLATION.md ]; then
    echo "  ✅ INSTALLATION.md found"
else
    echo "  ⚠️  INSTALLATION.md not found (optional)"
fi

if [ -f ~/.config/opencode/skills/prd-command/TEST_RUN.md ]; then
    echo "  ✅ TEST_RUN.md found"
else
    echo "  ⚠️  TEST_RUN.md not found (optional)"
fi

# Check 4: File sizes
echo ""
echo "✓ Checking file sizes..."
PRD_SIZE=$(wc -c < ~/.config/opencode/commands/prd.md)
if [ "$PRD_SIZE" -gt 1000 ]; then
    echo "  ✅ prd.md is $(($PRD_SIZE / 1024))KB (healthy size)"
else
    echo "  ⚠️  prd.md is only ${PRD_SIZE} bytes (might be truncated)"
fi

# Check 5: Key workflow sections
echo ""
echo "✓ Checking workflow sections..."
if grep -q "Phase 1:" ~/.config/opencode/commands/prd.md; then
    echo "  ✅ Phase 1 (Analysis) found"
else
    echo "  ❌ Phase 1 missing"
fi

if grep -q "CHECKPOINT" ~/.config/opencode/commands/prd.md; then
    echo "  ✅ Interactive checkpoint found"
else
    echo "  ❌ Checkpoint missing"
fi

if grep -q "Phase 2:" ~/.config/opencode/commands/prd.md; then
    echo "  ✅ Phase 2 (Implementation) found"
else
    echo "  ❌ Phase 2 missing"
fi

if grep -q "Phase 3:" ~/.config/opencode/commands/prd.md; then
    echo "  ✅ Phase 3 (Commit) found"
else
    echo "  ❌ Phase 3 missing"
fi

# Check 6: Skill references
echo ""
echo "✓ Checking skill integrations..."
if grep -q "prd-planner" ~/.config/opencode/commands/prd.md; then
    echo "  ✅ prd-planner skill referenced"
else
    echo "  ❌ prd-planner skill NOT referenced"
fi

if grep -q "build-orchestrator" ~/.config/opencode/commands/prd.md; then
    echo "  ✅ build-orchestrator skill referenced"
else
    echo "  ❌ build-orchestrator skill NOT referenced"
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Installation Verified Successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📚 Documentation:"
echo "  - Quick Start: ~/.config/opencode/skills/prd-command/README.md"
echo "  - Full Guide:  ~/.config/opencode/skills/prd-command/INSTALLATION.md"
echo "  - Test Run:    ~/.config/opencode/skills/prd-command/TEST_RUN.md"
echo ""
echo "🚀 Usage:"
echo "  /prd \"Your feature description\""
echo ""
echo "📝 Example:"
echo "  /prd \"Add GET /api/health endpoint\""
echo ""
echo "💡 Next Steps:"
echo "  1. Navigate to your spending-tracker project"
echo "  2. Start OpenCode: opencode"
echo "  3. Run: /prd \"your feature description\""
echo "  4. Review task breakdown at checkpoint"
echo "  5. Approve and watch it execute!"
echo ""
