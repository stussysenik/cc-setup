/**
 * Secret Detection Script
 *
 * Scans files for potential API keys, secrets, and sensitive information
 * before they're committed to Git. Use this as a pre-commit hook.
 *
 * Usage: node scripts/check-secrets.js
 */

const fs = require('fs');
const path = require('path');

// =============================================================================
// CONFIGURATION
// =============================================================================

const SECRET_PATTERNS = [
  // JWT tokens
  /eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+/g,

  // Supabase keys
  /SUPABASE_SERVICE_ROLE_KEY\s*=\s*[a-zA-Z0-9_-]{50,}/gi,
  /NEXT_PUBLIC_SUPABASE_ANON_KEY\s*=\s*[a-zA-Z0-9_-]{50,}/gi,

  // OpenAI API keys
  /sk-[a-zA-Z0-9]{20,}/g,

  // Anthropic API keys
  /sk-ant-[a-zA-Z0-9_-]{20,}/g,

  // Google API keys
  /AIza[a-zA-Z0-9_-]{35}/g,

  // AWS access keys
  /AKIA[0-9A-Z]{16}/g,

  // GitHub tokens
  /ghp_[a-zA-Z0-9]{36}/g,
  /github_pat_[a-zA-Z0-9_]{22,}/g,

  // Stripe keys
  /sk_live_[a-zA-Z0-9]{24,}/g,
  /pk_live_[a-zA-Z0-9]{24,}/g,

  // Generic patterns
  /api[_-]?key\s*[:=]\s*['"]?[a-zA-Z0-9_-]{20,}['"]?/gi,
  /secret[_-]?key\s*[:=]\s*['"]?[a-zA-Z0-9_-]{20,}['"]?/gi,
  /private[_-]?key\s*[:=]\s*['"]?[a-zA-Z0-9_-]{20,}['"]?/gi,
  /access[_-]?token\s*[:=]\s*['"]?[a-zA-Z0-9_-]{20,}['"]?/gi,
];

const IGNORE_PATTERNS = [
  /\.env\.example$/,
  /\.example$/,
  /package-lock\.json$/,
  /yarn\.lock$/,
  /pnpm-lock\.yaml$/,
  /bun\.lock$/,
  /node_modules/,
  /\.next/,
  /\.git/,
  /coverage/,
  /dist/,
  /build/,
];

const INCLUDE_EXTENSIONS = ['.js', '.jsx', '.ts', '.tsx', '.json', '.md', '.yml', '.yaml', '.env', '.toml'];

// =============================================================================
// UTILITY FUNCTIONS
// =============================================================================

function shouldIgnoreFile(filePath) {
  return IGNORE_PATTERNS.some(pattern => pattern.test(filePath));
}

function shouldScanFile(filePath) {
  const ext = path.extname(filePath);
  return INCLUDE_EXTENSIONS.includes(ext);
}

function checkForSecrets(filePath) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');

    if (content.length > 102400) return null;
    if (filePath.includes('.example') || filePath.includes('.sample')) return null;

    for (const pattern of SECRET_PATTERNS) {
      const matches = content.match(pattern);
      if (matches) {
        const realMatches = matches.filter(match => {
          if (match.includes('your-') || match.includes('YOUR_')) return false;
          if (match.includes('example') || match.includes('EXAMPLE')) return false;
          if (match.includes('xxx') || match.includes('XXX')) return false;
          if (match.length < 30) return false;
          return true;
        });

        if (realMatches.length > 0) {
          return {
            filePath,
            pattern: pattern.source,
            matches: realMatches.slice(0, 3),
            count: realMatches.length,
          };
        }
      }
    }
  } catch (error) {
    // Ignore unreadable files
  }

  return null;
}

function getStagedFiles() {
  try {
    const { execSync } = require('child_process');
    const output = execSync('git diff --cached --name-only', { encoding: 'utf8' });
    return output.trim().split('\n').filter(Boolean);
  } catch (error) {
    return [];
  }
}

function getAllFiles(dir, fileList = []) {
  const files = fs.readdirSync(dir);

  files.forEach(file => {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);

    if (stat.isDirectory()) {
      if (!shouldIgnoreFile(filePath)) {
        getAllFiles(filePath, fileList);
      }
    } else {
      fileList.push(filePath);
    }
  });

  return fileList;
}

// =============================================================================
// MAIN
// =============================================================================

function main() {
  console.log('🔍 Scanning for secrets...\n');

  const filesToScan = getStagedFiles().length > 0 ? getStagedFiles() : getAllFiles('.');

  if (filesToScan.length === 0) {
    console.log('✅ No files to scan\n');
    process.exit(0);
  }

  console.log(`Scanning ${filesToScan.length} file(s)...\n`);

  let secretsFound = [];

  filesToScan.forEach(filePath => {
    const normalizedPath = filePath.replace(/^\.\//, '');
    if (shouldIgnoreFile(normalizedPath)) return;
    if (!shouldScanFile(normalizedPath)) return;

    const secret = checkForSecrets(normalizedPath);
    if (secret) secretsFound.push(secret);
  });

  if (secretsFound.length > 0) {
    console.error('❌ POTENTIAL SECRETS FOUND!\n');
    secretsFound.forEach((secret, index) => {
      console.error(`${index + 1}. ${secret.filePath}`);
      console.error(`   Pattern: ${secret.pattern}`);
      console.error(`   Found ${secret.count} potential secret(s)\n`);
    });
    console.error('⚠️  COMMIT BLOCKED - Remove secrets before committing.\n');
    process.exit(1);
  } else {
    console.log('✅ No secrets detected\n');
    process.exit(0);
  }
}

main();
